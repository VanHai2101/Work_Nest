import 'package:flutter/material.dart';

/// Central constants file for the entire app
/// Avoid hardcoding strings, numbers, colors, icons, and durations

// ============================================================================
// PADDING & SPACING
// ============================================================================

class AppPadding {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xLarge = 32.0;
}

class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
}

// ============================================================================
// SIZES
// ============================================================================

class AppSize {
  // Icon sizes
  static const double iconSmall = 24.0;
  static const double iconMedium = 32.0;
  static const double iconLarge = 64.0;
  static const double iconXLarge = 96.0;

  // Avatar sizes
  static const double avatarSmall = 40.0;
  static const double avatarMedium = 56.0;
  static const double avatarLarge = 72.0;

  // Button sizes
  static const double buttonHeight = 48.0;
  static const double buttonWidth = 120.0;

  // Control button
  static const double controlButtonSmall = 56.0;
  static const double controlButtonLarge = 70.0;

  // Divider height
  static const double dividerHeight = 1.0;

  // Unread badge
  static const double unreadBadge = 8.0;

  // Video call mini window
  static const double videoMiniWidth = 120.0;
  static const double videoMiniHeight = 180.0;
}

// ============================================================================
// DURATIONS
// ============================================================================

class AppDuration {
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);
  static const Duration animationLong = Duration(milliseconds: 500);
  static const Duration snackbar = Duration(seconds: 3);
}

// ============================================================================
// STRINGS - UI LABELS
// ============================================================================

class AppStrings {
  // Navigation & Titles
  static const String chats = 'Trò chuyện';
  static const String groups = 'Nhóm';
  static const String notifications = 'Thông báo';
  static const String profile = 'Cá nhân';
  static const String schedule = 'Lịch trình';
  static const String projects = 'Dự án';
  static const String projectDetails = 'Chi tiết dự án';
  static const String description = 'Mô tả';
  static const String tags = 'Thẻ';

  // Empty States
  static const String noChatsYet = 'Chưa có cuộc trò chuyện';
  static const String noProjectsYet = 'Chưa có dự án nào';
  static const String noTasksYet = 'Chưa có công việc nào';
  static const String noGroupsYet = 'Chưa có nhóm nào';
  static const String createGroupToWork = 'Tạo nhóm để làm việc cùng nhau';
  static const String noNotifications = 'Chưa có thông báo';
  static const String startNewChat = 'Bắt đầu một cuộc trò chuyện mới';

  // Dashboard
  static const String recentProjects = 'Dự án gần đây';
  static const String recentTasks = 'Công việc gần đây';
  static const String quickActions = 'Hành động nhanh';
  static const String viewAll = 'Xem tất cả';
  static const String projectsCount = 'Dự án';
  static const String tasksInProgress = 'Đang làm';
  static const String tasksCompleted = 'Hoàn thành';

  // Placeholders
  static const String searchChat = 'Tìm kiếm cuộc trò chuyện...';
  static const String searchGroup = 'Tìm kiếm nhóm...';
  static const String noMessages = 'Chưa có tin nhắn';
  static const String chatWith = 'Chat với';
  static const String membersCount = 'thành viên';

  // Default Values
  static const String unknown = 'Không xác định';
  static const String noDescription = 'Không có mô tả';
  static const String unnamed = 'Chưa đặt tên';

  // Chat/Call States
  static const String inCall = 'Trong cuộc gọi';
  static const String ringing = 'Đang đổ chuông...';
  static const String callEnded = 'Cuộc gọi đã kết thúc';
  static const String missedCall = 'Cuộc gọi nhỡ';
  static const String endCall = 'Kết thúc';

  // Actions
  static const String send = 'Gửi';
  static const String delete = 'Xóa';
  static const String accept = 'Chấp nhận';
  static const String reject = 'Từ chối';
  static const String add = 'Thêm';
  static const String create = 'Tạo';
  static const String edit = 'Sửa';
  static const String cancel = 'Hủy';
  static const String deleteProject = 'Xóa dự án';
  static const String areYouSureShort = 'Bạn có chắc chắn không?';
  static const String cannotBeUndone = 'Hành động này không thể hoàn tác.';
  static const String projectDeleted = 'Đã xóa dự án';

  // Time Format
  static const String now = 'vừa xong';
  static const String minuteShort = 'p';
  static const String hourShort = 'g';
  static const String dayShort = 'n';

  // Members label
  static const String members = 'thành viên';
}

// ============================================================================
// STRINGS - ERROR MESSAGES
// ============================================================================

class AppErrors {
  static const String genericError = 'Đã có lỗi xảy ra';
  static const String networkError = 'Lỗi kết nối mạng';
  static const String loadingFailed = 'Tải dữ liệu thất bại';
  static const String saveFailed = 'Lưu thất bại';
  static const String deleteFailed = 'Xóa thất bại';
}


// ============================================================================
// NUMERIC CONSTANTS
// ============================================================================

class AppNumbers {
  // List pagination
  static const int itemsPerPage = 20;
  static const int messageItemsPerPage = 50;

  // Member limits
  static const int freeUserMemberLimit = 3;
  static const int proUserMemberLimit = 10;

  // Text limits
  static const int maxGroupNameLength = 100;
  static const int maxMessageLength = 2000;

  // Timeouts
  static const int callTimeoutSeconds = 60;
  static const int debounceMs = 300;

  // Offsets
  static const int maxBubbles = 3;
  static const int particleBurst = 20;
}

// ============================================================================
// LAYOUT CONSTANTS
// ============================================================================

class AppLayout {
  // Padding
  static const EdgeInsets paddingSmall = EdgeInsets.all(AppPadding.small);
  static const EdgeInsets paddingMedium = EdgeInsets.all(AppPadding.medium);
  static const EdgeInsets paddingLarge = EdgeInsets.all(AppPadding.large);
  static const EdgeInsets paddingHorizontalMedium = EdgeInsets.symmetric(horizontal: AppPadding.medium);
  static const EdgeInsets paddingVerticalMedium = EdgeInsets.symmetric(vertical: AppPadding.medium);

  // Standard gaps
  static const SizedBox gapSmall = SizedBox(height: AppPadding.small);
  static const SizedBox gapMedium = SizedBox(height: AppPadding.medium);
  static const SizedBox gapLarge = SizedBox(height: AppPadding.large);
  static const SizedBox gapXLarge = SizedBox(height: AppPadding.xLarge);

  static const SizedBox horizontalGapSmall = SizedBox(width: AppPadding.small);
  static const SizedBox horizontalGapMedium = SizedBox(width: AppPadding.medium);
  static const SizedBox horizontalGapLarge = SizedBox(width: AppPadding.large);
}

// ============================================================================
// BORDER RADIUS STYLES
// ============================================================================

class AppBorderRadius {
  static final BorderRadius small = BorderRadius.circular(AppRadius.small);
  static final BorderRadius medium = BorderRadius.circular(AppRadius.medium);
  static final BorderRadius large = BorderRadius.circular(AppRadius.large);
}
