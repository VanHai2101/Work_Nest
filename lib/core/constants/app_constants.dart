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
  static const String chats = 'Chats';
  static const String groups = 'Groups';
  static const String notifications = 'Notifications';
  static const String calls = 'Calls';
  static const String profile = 'Profile';

  // Empty States
  static const String noChatsYet = 'No chats yet';
  static const String noGroupsYet = 'No groups yet';
  static const String noNotifications = 'No notifications';
  static const String noCalls = 'No calls yet';

  // Default Values
  static const String unknown = 'Unknown';
  static const String noDescription = 'No description';
  static const String unnamed = 'Unnamed';

  // Chat States
  static const String inCall = 'In Call';
  static const String ringing = 'Ringing...';
  static const String callEnded = 'Call ended';
  static const String missedCall = 'Missed call';

  // Actions
  static const String send = 'Send';
  static const String delete = 'Delete';
  static const String markAsRead = 'Mark as read';
  static const String markAllAsRead = 'Mark all as read';
  static const String accept = 'Accept';
  static const String reject = 'Reject';
  static const String endCall = 'End Call';
  static const String add = 'Add';
  static const String create = 'Create';

  // Time Format
  static const String now = 'now';
  static const String minuteShort = 'm';
  static const String hourShort = 'h';
  static const String dayShort = 'd';

  // Members label
  static const String members = 'members';
}

// ============================================================================
// STRINGS - ERROR MESSAGES
// ============================================================================

class AppErrors {
  static const String genericError = 'Something went wrong';
  static const String networkError = 'Network error';
  static const String loadingFailed = 'Failed to load';
  static const String saveFailed = 'Failed to save';
  static const String deleteFailed = 'Failed to delete';
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
