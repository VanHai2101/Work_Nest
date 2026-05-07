import '../providers/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/index.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/components/index.dart';
import '../../../../core/utils/index.dart';
import '../../../../core/data/repositories/index.dart';
import '../providers/index.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  final String? projectId;

  const CreateTaskScreen({this.projectId, super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String currentUserId;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  bool _isLoading = false;
  String _selectedPriority = 'medium';
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 7));
  late String _selectedDueTime;
  bool _isTimePickerExpanded = false;

  // Design tokens used from AppColors (Premium Dark Palette)

  // priority config
  static final _priorities = [
    (
      'low',
      'Thấp',
      AppColors.success,
      AppColors.success.withOpacity(0.12),
      AppColors.success.withOpacity(0.4),
    ),
    (
      'medium',
      'Trung',
      AppColors.warning,
      AppColors.warning.withOpacity(0.12),
      AppColors.warning.withOpacity(0.4),
    ),
    (
      'high',
      'Cao',
      AppColors.error,
      AppColors.error.withOpacity(0.12),
      AppColors.error.withOpacity(0.4),
    ),
  ];

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _selectedDueTime = TimeFormatUtils.formatTime(DateTime.now());
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final taskRepo = ref.read(taskRepositoryProvider);
      final taskId = await taskRepo.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        creatorId: currentUserId,
        projectId: widget.projectId ?? 'default',
        dueDate: _selectedDueDate,
        dueTime: _selectedDueTime,
        assigneeIds: [currentUserId],
        priority: _selectedPriority,
        tags: [],
      );

      final currentUser = FirebaseAuth.instance.currentUser;
      final actorName = currentUser?.displayName ?? 'Someone';
      final actorPhotoURL = currentUser?.photoURL;

      await NotificationRepository().createNotification(
        userId: currentUserId,
        type: 'task_assigned',
        title: 'New Task Assigned',
        body:
            '$actorName assigned you a new task: "${_titleController.text.trim()}"',
        actorId: currentUserId,
        actorName: actorName,
        actorPhotoURL: actorPhotoURL,
        relatedEntityId: taskId,
        relatedEntityType: 'task',
      );

      if (mounted) {
        _showSnack('Task created successfully!', success: true);
        await Future.delayed(const Duration(milliseconds: 600));
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) _showSnack('Error: ${e.toString()}', success: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: success
            ? const Color(0xFF1A2E23)
            : const Color(0xFF2A1414),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        content: Row(
          children: [
            Icon(
              success
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              color: success ? AppColors.darkSuccess : AppColors.error,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(
                  color: success ? AppColors.darkSuccess : AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.info,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDueDate = picked);
  }

  void _selectTime() {
    setState(() {
      _isTimePickerExpanded = !_isTimePickerExpanded;
    });
  }

  String get _dueDateLabel =>
      TimeFormatUtils.formatShortMonthDate(_selectedDueDate);
  int get _daysLeft => TimeFormatUtils.getDaysLeft(_selectedDueDate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppPadding.medium,
                      AppPadding.small / 2,
                      AppPadding.medium,
                      AppPadding.large,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHero(),
                        AppLayout.gapMedium,
                        _sectionLabel('Chi tiết công việc'),
                        AppLayout.gapSmall,
                        _buildInfoCard(),
                        AppLayout.gapMedium,
                        _sectionLabel('Mức độ ưu tiên'),
                        AppLayout.gapSmall,
                        _buildPriorityPicker(),
                        AppLayout.gapMedium,
                        _sectionLabel('Thời hạn'),
                        AppLayout.gapSmall,
                        _buildScheduleRow(),
                        _buildInlineTimePicker(),
                        const SizedBox(height: 28),
                        _buildCTA(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── widgets ────────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Tạo công việc',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // placeholder to balance
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TẠO MỚI',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 2,
            color: AppColors.info.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Task Setup',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Điền thông tin để tạo công việc mới',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        letterSpacing: 1.4,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildField(
            controller: _titleController,
            label: 'Tên công việc',
            hint: 'Nhập tên công việc...',
            isFirst: true,
            maxLines: 1,
            validator: (v) => (v?.isEmpty ?? true) ? 'Tên là bắt buộc' : null,
          ),
          Divider(height: 1, color: AppColors.border),
          _buildField(
            controller: _descriptionController,
            label: 'Mô tả',
            hint: 'Chi tiết về công việc này...',
            isFirst: false,
            maxLines: 4,
            validator: (v) => (v?.isEmpty ?? true) ? 'Mô tả là bắt buộc' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isFirst,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              errorStyle: const TextStyle(
                fontSize: 11,
                color: Color(0xFFF87171),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityPicker() {
    return Row(
      children: _priorities.asMap().entries.map((e) {
        final i = e.key;
        final (value, label, color, bgColor, borderColor) = e.value;
        final sel = _selectedPriority == value;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPriority = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: i < _priorities.length - 1 ? 10 : 0,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppPadding.medium - 2,
              ),
              decoration: BoxDecoration(
                color: sel ? bgColor : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.large - 2),
                border: Border.all(
                  color: sel ? Color(borderColor.value) : AppColors.border,
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: sel ? color : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScheduleRow() {
    return Row(
      children: [
        // Date
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.info,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NGÀY',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.8,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _dueDateLabel,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$_daysLeft ngày',
                          style: TextStyle(color: AppColors.info, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Time
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GIỜ',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.8,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _selectedDueTime,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12, // matching the 12px of Date label
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Cố định', // dynamic if needed, placeholder for balance
                          style: TextStyle(
                            color: const Color(0xFF8B5CF6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCTA() {
    // resolve current priority color
    final (_, _, priColor, _, _) = _priorities.firstWhere(
      (p) => p.$1 == _selectedPriority,
    );

    return CustomButton(
      text: 'Tạo công việc',
      onPressed: _handleCreate,
      isLoading: _isLoading,
      suffixIcon: Icons.add_task_rounded,
      height: 54,
      gradientColors: [AppColors.info, AppColors.info],
    );
  }

  Widget _buildInlineTimePicker() {
    return AnimatedCrossFade(
      firstChild: const SizedBox.shrink(),
      secondChild: Container(
        height: 180,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          initialDateTime: DateTime(
            2024,
            1,
            1,
            int.parse(_selectedDueTime.split(':')[0]),
            int.parse(_selectedDueTime.split(':')[1]),
          ),
          use24hFormat: true,
          onDateTimeChanged: (DateTime newDateTime) {
            setState(() {
              _selectedDueTime =
                  '${newDateTime.hour.toString().padLeft(2, '0')}:${newDateTime.minute.toString().padLeft(2, '0')}';
            });
          },
        ),
      ),
      crossFadeState: _isTimePickerExpanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }
}
