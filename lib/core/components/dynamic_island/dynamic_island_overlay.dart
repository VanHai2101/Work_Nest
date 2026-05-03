import 'package:flutter/material.dart';
import 'dynamic_island.dart';

class DynamicIslandOverlay extends StatelessWidget {
  final Widget child;

  const DynamicIslandOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Align(
              alignment: Alignment.topCenter,
              child: const DynamicIslandWidget(),
            ),
          ),
        ),
      ],
    );
  }
}
