import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'island_models.dart';
import 'island_provider.dart';
import 'dynamic_island.dart';

class DynamicIslandOverlay extends StatelessWidget {
  final Widget child;

  const DynamicIslandOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Consumer(
          builder: (context, ref, _) {
            final islandState = ref.watch(islandProvider).state;
            if (islandState == IslandState.none) return const SizedBox.shrink();

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: const DynamicIslandWidget(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
