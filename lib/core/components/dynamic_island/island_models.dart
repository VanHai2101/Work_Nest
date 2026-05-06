import 'package:flutter/material.dart';

enum IslandState {
  none,
  collapsed,
  musicPlayer,
  phoneCall,
  notification,
  activeTask,
}

class IslandContext {
  final String? title;
  final String? subtitle;
  final String? extraInfo;
  final IconData? icon;
  final Color? color;

  const IslandContext({
    this.title,
    this.subtitle,
    this.extraInfo,
    this.icon,
    this.color,
  });
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
  IslandState.none: IslandSize(width: 0, height: 0, radius: 20),
  IslandState.collapsed: IslandSize(width: 120, height: 34, radius: 20),
  IslandState.musicPlayer: IslandSize(width: 340, height: 160, radius: 28),
  IslandState.phoneCall: IslandSize(width: 320, height: 110, radius: 28),
  IslandState.notification: IslandSize(width: 340, height: 90, radius: 28),
  IslandState.activeTask: IslandSize(width: 340, height: 80, radius: 28),
};

