import 'package:flutter/material.dart';

mixin UIStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    if (!mounted) return;
    setState(() {
      _isLoading = value;
    });
  }

  void setError(String? message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
    });
  }

  void resetUIState() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = null;
    });
  }
}
