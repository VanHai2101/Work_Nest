import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/index.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/components/index.dart';
import '../../domain/entities/project_entity.dart';
import '../providers/projects_provider.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String currentUserId;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  bool _isLoading = false;
  String _selectedStatus = 'active';
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 30));
  double _progress = 0.0;
  final List<String> _allTags = [
    'Frontend',
    'Backend',
    'Q2',
    'Payment',
    'Mobile',
    'API',
  ];
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: AppDuration.animationLong,
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
      final newProject = ProjectEntity(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        ownerId: currentUserId,
        memberIds: [currentUserId],
        status: _selectedStatus,
        progress: _progress,
        dueDate: _selectedDueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: _selectedTags.toList(),
      );

      await ref.read(projectRepositoryProvider).createProject(newProject);

      if (mounted) {
        _showSuccess();
        await Future.delayed(const Duration(milliseconds: 800));
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showError('Không thể tạo project. Vui lòng thử lại.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.success.withOpacity(0.1)),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 16,
              ),
            ),
            AppLayout.horizontalGapMedium,
            Text(
              'Project created successfully!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.error.withOpacity(0.1)),
        ),
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
            AppLayout.horizontalGapMedium,
            Text(
              msg,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.info,
            surface: Colors.white,
            onSurface: AppColors.textPrimary,
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDueDate = picked);
  }

  int get _daysLeft => _selectedDueDate.difference(DateTime.now()).inDays;

  String get _dueDateLabel =>
      DateFormat('d MMM, yyyy').format(_selectedDueDate);

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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHero(),
                        AppLayout.gapLarge,
                        _sectionLabel('Basic info'),
                        AppLayout.gapSmall,
                        _buildInfoCard(),
                        AppLayout.gapLarge,
                        _sectionLabel('Status'),
                        AppLayout.gapSmall,
                        _buildStatusPicker(),
                        AppLayout.gapLarge,
                        _sectionLabel('Tags'),
                        AppLayout.gapSmall,
                        _buildTagPicker(),
                        AppLayout.gapLarge,
                        _sectionLabel('Initial progress'),
                        AppLayout.gapSmall,
                        _buildProgressCard(),
                        AppLayout.gapXLarge,
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'New Project',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Draft',
              style: TextStyle(
                color: AppColors.info,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CREATE',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 2,
              color: AppColors.info,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppLayout.gapSmall,
          Text(
            'Project Setup',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          AppLayout.gapSmall,
          Text(
            'Fill in the details below to get started',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 1.2,
        color: AppColors.textTertiary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.large,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _titleController,
            label: 'Project title',
            hint: 'e.g. Payment Module Q2',
            isFirst: true,
            validator: (v) => (v?.isEmpty ?? true) ? 'Title is required' : null,
          ),
          Divider(height: 1, color: AppColors.divider),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'What is this project about?',
            maxLines: 4,
            isFirst: false,
            validator: (v) =>
                (v?.isEmpty ?? true) ? 'Description is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
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
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppLayout.gapSmall,
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textTertiary.withOpacity(0.6),
                fontSize: 15,
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorStyle: const TextStyle(
                fontSize: 11,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPicker() {
    final statuses = [
      ('active', 'Active', AppColors.success),
      ('on hold', 'On hold', AppColors.warning),
      ('completed', 'Completed', AppColors.info),
    ];

    return Row(
      children: statuses.map((s) {
        final sel = _selectedStatus == s.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedStatus = s.$1),
            child: AnimatedContainer(
              duration: AppDuration.animationShort,
              margin: EdgeInsets.only(right: s.$1 != 'completed' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: sel
                    ? s.$3.withOpacity(0.1)
                    : AppColors.surfaceVariant.withOpacity(0.5),
                borderRadius: AppBorderRadius.large,
                border: Border.all(
                  color: sel ? s.$3.withOpacity(0.5) : AppColors.border,
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: s.$3,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AppLayout.gapSmall,
                  Text(
                    s.$2,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: sel ? s.$3 : AppColors.textSecondary,
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

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: AppLayout.paddingMedium,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppBorderRadius.large,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: AppBorderRadius.medium,
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: AppColors.info,
                size: 22,
              ),
            ),
            AppLayout.horizontalGapMedium,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DUE DATE',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppLayout.gapSmall,
                  Text(
                    _dueDateLabel,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppLayout.gapSmall,
                  Text(
                    '$_daysLeft days remaining',
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.large,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ..._allTags.map((tag) {
            final on = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () => setState(
                () => on ? _selectedTags.remove(tag) : _selectedTags.add(tag),
              ),
              child: AnimatedContainer(
                duration: AppDuration.animationShort,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: on
                      ? AppColors.info.withOpacity(0.08)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: on
                        ? AppColors.info.withOpacity(0.4)
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 13,
                    color: on ? AppColors.info : AppColors.textSecondary,
                    fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final pct = (_progress * 100).round();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.large,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COMPLETION',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.info,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: AppColors.info,
              inactiveTrackColor: AppColors.divider,
              thumbColor: Colors.white,
              // Xóa bớt khoảng cách mặc định của Slider để gọn hơn
              padding: EdgeInsets.zero,
            ),
            child: Slider(
              value: _progress,
              min: 0,
              max: 1,
              divisions: 20,
              onChanged: (v) => setState(() => _progress = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA() {
    return CustomButton(
      text: 'Create Project',
      onPressed: _isLoading ? null : _handleCreate,
      isLoading: _isLoading,
      suffixIcon: Icons.arrow_forward_rounded,
      gradientColors: [AppColors.info, AppColors.info.withOpacity(0.8)],
    );
  }
}
