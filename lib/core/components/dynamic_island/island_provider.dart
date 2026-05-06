import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'island_models.dart';

class IslandData {
  final IslandState state;
  final IslandContext? context;

  const IslandData({required this.state, this.context});

  IslandData copyWith({IslandState? state, IslandContext? context}) {
    return IslandData(
      state: state ?? this.state,
      context: context ?? this.context,
    );
  }
}

class IslandStateNotifier extends StateNotifier<IslandData> {
  IslandStateNotifier() : super(const IslandData(state: IslandState.none));

  void changeState(IslandState newState, {IslandContext? context}) {
    if (state.state == newState && newState != IslandState.none) {
      state = const IslandData(state: IslandState.none);
    } else {
      state = IslandData(state: newState, context: context);
    }
  }

  void showNotification({required String title, required String message}) {
    state = IslandData(
      state: IslandState.notification,
      context: IslandContext(
        title: title,
        subtitle: message,
        icon: Icons.notifications_active_rounded,
        color: const Color(0xFF0A84FF),
      ),
    );

    // Auto collapse after 5 seconds if it's just a notification
    Future.delayed(const Duration(seconds: 5), () {
      if (state.state == IslandState.notification) {
        collapse();
      }
    });
  }

  void startTask(String taskName) {
    state = IslandData(
      state: IslandState.activeTask,
      context: IslandContext(
        title: taskName,
        icon: Icons.play_circle_filled_rounded,
        color: const Color(0xFF30D158),
      ),
    );
  }

  void collapse() {
    state = const IslandData(state: IslandState.none);
  }
}

final islandProvider = StateNotifierProvider<IslandStateNotifier, IslandData>((
  ref,
) {
  return IslandStateNotifier();
});
