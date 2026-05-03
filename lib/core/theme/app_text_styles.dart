import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _headingFont = 'Poppins';
  static const String _bodyFont = 'Poppins';

  static const TextStyle _headingBase = TextStyle(
    fontFamily: _headingFont,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle _bodyBase = TextStyle(
    fontFamily: _bodyFont,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get titleLarge => _headingBase.copyWith(
    fontSize: 64,
    height: 1.05,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get titleMedium => _headingBase.copyWith(fontSize: 24);

  static TextStyle get titleSmall => _headingBase.copyWith(fontSize: 16);

  static TextStyle get subtitleLarge => _bodyBase.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  static TextStyle get subtitleMedium => _bodyBase.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle get subtitle => _bodyBase.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle get body => _bodyBase.copyWith(fontSize: 14);

  static TextStyle get caption => _bodyBase.copyWith(fontSize: 12, height: 1.4);
}
