import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/core/providers/incoming_otp_provider.dart';
import 'package:work_nest/main.dart'; // To access navigatorKey

class DeepLinkService {
  final Ref ref;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  DeepLinkService(this.ref) {
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    // 1. Xử lý link khi ứng dụng đang đóng (Cold Start)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial deep link: $e');
    }

    // 2. Lắng nghe link khi ứng dụng đang mở hoặc chạy ngầm
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('Received deep link: $uri');
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Deep link stream error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Processing deep link: $uri');
    
    // Ví dụ link: worknest://task/12345
    // uri.host = task
    // uri.pathSegments = [12345]
    
    final segments = uri.pathSegments;
    final host = uri.host;

    if (host == 'task' && segments.isNotEmpty) {
      final taskId = segments[0];
      _navigateTo('/tasks/detail', taskId);
    } else if (host == 'project' && segments.isNotEmpty) {
      final projectId = segments[0];
      _navigateTo('/projects/detail', projectId);
    } else if (host == 'calendar') {
      _navigateTo('/calendar', null);
    } else if (host == 'verify-otp') {
      final code = uri.queryParameters['code'];
      final purpose = uri.queryParameters['purpose'];

      if (code != null && purpose != null) {
        debugPrint('Auto-verifying OTP: $code for $purpose');
        // Lưu code vào provider
        ref.read(incomingOtpProvider.notifier).state =
            IncomingOtp(code: code, purpose: purpose);

        // Chuyển hướng đến màn hình bảo mật
        _navigateTo('/profile/security', {'auto_trigger': purpose});
      }
    }
  }

  void _navigateTo(String routeName, dynamic arguments) {
    navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}

// Provider để sử dụng trong toàn app
final deepLinkServiceProvider = Provider((ref) {
  final service = DeepLinkService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});
