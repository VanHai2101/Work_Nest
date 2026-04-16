import 'package:flutter/material.dart';
import '../domain/models/index.dart';

/// Centralized notification utilities
/// Maps notification types to colors, icons, titles, etc.
class NotificationUtils {
  /// Get color for notification type
  static Color getTypeColor(NotificationType type) {
    return _colorMap[type] ?? Colors.grey;
  }

  /// Get icon for notification type
  static IconData getTypeIcon(NotificationType type) {
    return _iconMap[type] ?? Icons.notifications;
  }

  /// Get display label for notification type
  static String getTypeLabel(NotificationType type) {
    return _labelMap[type] ?? 'Notification';
  }

  /// Color mapping for notification types
  static final Map<NotificationType, Color> _colorMap = {
    NotificationType.messageReceived: Colors.blue,
    NotificationType.groupMessageReceived: Colors.blue,
    NotificationType.taskAssigned: Colors.orange,
    NotificationType.projectCreated: Colors.green,
    NotificationType.callIncoming: Colors.red,
    NotificationType.planUpgraded: Colors.purple,
  };

  /// Icon mapping for notification types
  static final Map<NotificationType, IconData> _iconMap = {
    NotificationType.messageReceived: Icons.chat,
    NotificationType.groupMessageReceived: Icons.groups,
    NotificationType.taskAssigned: Icons.assignment,
    NotificationType.projectCreated: Icons.folder,
    NotificationType.callIncoming: Icons.call,
    NotificationType.planUpgraded: Icons.star,
  };

  /// Label mapping for notification types
  static final Map<NotificationType, String> _labelMap = {
    NotificationType.messageReceived: 'New Message',
    NotificationType.groupMessageReceived: 'Group Message',
    NotificationType.taskAssigned: 'Task Assigned',
    NotificationType.projectCreated: 'Project Created',
    NotificationType.callIncoming: 'Incoming Call',
    NotificationType.planUpgraded: 'Plan Upgraded',
  };

  /// Get background color with opacity for type
  static Color getBackgroundColor(NotificationType type) {
    return getTypeColor(type).withOpacity(0.2);
  }
}
