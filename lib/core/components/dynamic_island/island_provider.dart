import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'island_models.dart';

class IslandStateNotifier extends StateNotifier<IslandState> {
  IslandStateNotifier() : super(IslandState.collapsed);

  void changeState(IslandState newState) {
    if (state == newState) {
      state = IslandState.collapsed;
    } else {
      state = newState;
    }
  }

  void collapse() {
    state = IslandState.collapsed;
  }
}

final islandProvider = StateNotifierProvider<IslandStateNotifier, IslandState>((ref) {
  return IslandStateNotifier();
});
