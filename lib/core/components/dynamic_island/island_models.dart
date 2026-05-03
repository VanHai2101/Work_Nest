import 'package:flutter/material.dart';

enum IslandState {
  collapsed,
  musicPlayer,
  phoneCall,
  notification,
}

class IslandSize {
  final double width;
  final double height;
  final double radius;

  const IslandSize({
    required this.width,
    required this.height,
    required this.radius,
  });
}

const Map<IslandState, IslandSize> islandSizes = {
  IslandState.collapsed: IslandSize(width: 120, height: 34, radius: 20),
  IslandState.musicPlayer: IslandSize(width: 340, height: 160, radius: 28),
  IslandState.phoneCall: IslandSize(width: 320, height: 110, radius: 28),
  IslandState.notification: IslandSize(width: 340, height: 90, radius: 28),
};
