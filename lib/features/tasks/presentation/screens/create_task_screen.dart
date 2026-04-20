import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/index.dart';
import '../../../../core/data/repositories/index.dart';
import '../providers/tasks_provider.dart';

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
  String _selectedDueTime = '09:00';

  // ── design tokens ──────────────────────────────
  static const _bg = Color(0xFF0F1117);
  static const _surface = Color(0xFF161B24);
  static const _card = Color(0xFF1A2030);
  static const _border = Color(0xFF252D3D);
  static const _accent = Color(0xFF3B82F6);
  static const _white = Colors.white;
  static const _textSec = Color(0xFF6B7A99);
  static const _textHint = Color(0xFF3A4560);

  // priority config
  static const _priorities = [
    ('low', 'Thấp', Color(0xFF34D399), Color(0xFF1A2E23), Color(0xFF0B6E38)),
    (
      'medium',
      'Trung',
      Color(0xFFFBBF24),
      Color(0xFF2A2010),
      Color(0xFF856C0A),
    ),
    ('high', 'Cao', Color(0xFFF87171), Color(0xFF2A1414), Color(0xFF8B2020)),
  ];

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
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

  // ── actions ────────────────────────────────────

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              success
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              color: success
                  ? const Color(0xFF34D399)
                  : const Color(0xFFF87171),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(
                  color: success
                      ? const Color(0xFF34D399)
                      : const Color(0xFFF87171),
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
          colorScheme: const ColorScheme.dark(
            primary: _accent,
            surface: _surface,
            onSurface: _white,
          ),
          dialogBackgroundColor: _card,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDueDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_selectedDueTime.split(':')[0]),
        minute: int.parse(_selectedDueTime.split(':')[1]),
      ),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _accent,
            surface: _surface,
            onSurface: _white,
          ),
          dialogBackgroundColor: _card,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDueTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  // ── helpers ────────────────────────────────────

  String get _dueDateLabel {
    final d = _selectedDueDate;
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${m[d.month - 1]}, ${d.year}';
  }

  int get _daysLeft => _selectedDueDate.difference(DateTime.now()).inDays;

  // ── build ──────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
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
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHero(),
                        const SizedBox(height: 20),
                        _sectionLabel('Chi tiết công việc'),
                        const SizedBox(height: 8),
                        _buildInfoCard(),
                        const SizedBox(height: 20),
                        _sectionLabel('Mức độ ưu tiên'),
                        const SizedBox(height: 8),
                        _buildPriorityPicker(),
                        const SizedBox(height: 20),
                        _sectionLabel('Thời hạn'),
                        const SizedBox(height: 8),
                        _buildScheduleRow(),
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
                color: _surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: _white,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Tạo công việc',
                style: TextStyle(
                  color: _white,
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
            color: _accent.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Task Setup',
          style: TextStyle(
            color: _white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Điền thông tin để tạo công việc mới',
          style: TextStyle(color: _textHint, fontSize: 13),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        letterSpacing: 1.4,
        color: _textSec,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
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
          Divider(height: 1, color: _border),
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
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1,
              color: _textSec,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: _white, fontSize: 14),
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: _textHint, fontSize: 14),
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
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: sel ? bgColor : _card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? Color(borderColor.value) : _border,
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
                      color: sel ? color : _textSec,
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
          flex: 3,
          child: GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: _accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NGÀY',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.8,
                            color: _textSec,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _dueDateLabel,
                          style: const TextStyle(
                            color: _white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$_daysLeft ngày',
                          style: const TextStyle(color: _accent, fontSize: 10),
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
          flex: 2,
          child: GestureDetector(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 8),
                  const Text(
                    'GIỜ',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      color: _textSec,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _selectedDueTime,
                    style: const TextStyle(
                      color: _white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
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
    final (_, __, priColor, _, __2) = _priorities.firstWhere(
      (p) => p.$1 == _selectedPriority,
    );

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCreate,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          disabledBackgroundColor: _accent.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: _white),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tạo công việc',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.add_task_rounded, size: 18, color: _white),
                ],
              ),
      ),
    );
  }
}
