import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum AppAsset {
  broIcon,
  uncheckedIcon,
  checkedIcon,
  googleBorderIcon,
  onboardingBg,
  onboardingIllustration,
  avatar,
  iconCalendar,
  iconClock,
  iconEdit,
  iconHome2,
  iconMessage1,
  iconNotification1,
  iconSetting2,
  iconTask,
  iconUserAdd,
  iconVideo,
}

extension AppAssetPath on AppAsset {
  String get path {
    switch (this) {
      case AppAsset.iconCalendar:
        return 'assets/icons/calendar.svg';
      case AppAsset.iconClock:
        return 'assets/icons/clock.svg';
      case AppAsset.broIcon:
        return 'assets/icons/bro.svg';
      case AppAsset.uncheckedIcon:
        return 'assets/icons/unchecked.svg';
      case AppAsset.checkedIcon:
        return 'assets/icons/checked.svg';
      case AppAsset.googleBorderIcon:
        return 'assets/icons/google_border.svg';
      case AppAsset.iconEdit:
        return 'assets/icons/edit.svg';
      case AppAsset.onboardingBg:
        return 'assets/images/phong.png';
      case AppAsset.onboardingIllustration:
        return 'assets/images/pana.png';
      case AppAsset.avatar:
        return 'assets/images/avata.png';
      case AppAsset.iconHome2:
        return 'assets/icons/home_2.svg';
      case AppAsset.iconMessage1:
        return 'assets/icons/message_1.svg';
      case AppAsset.iconNotification1:
        return 'assets/icons/notification_1.svg';
      case AppAsset.iconSetting2:
        return 'assets/icons/setting_2.svg';
      case AppAsset.iconTask:
        return 'assets/icons/task.svg';
      case AppAsset.iconUserAdd:
        return 'assets/icons/user_add.svg';
      case AppAsset.iconVideo:
        return 'assets/icons/video.svg';
    }
  }

  Widget toWidget({
    double? width,
    double? height,
    double? size,
    BoxFit fit = BoxFit.contain,
    Color? color,
  }) {
    if (size != null) {
      height = size;
      width = size;
    }

    if (path.endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      );
    } else {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        color: color,
      );
    }
  }
}
