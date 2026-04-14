import 'package:cloud_firestore/cloud_firestore.dart';

class Parser {
  /// Parse dynamic to Timestamp
  static Timestamp parseTimestamp(dynamic value, {Timestamp? defaultValue}) {
    if (value == null) return defaultValue ?? Timestamp.now();
    if (value is Timestamp) return value;
    if (value is int) return Timestamp.fromMillisecondsSinceEpoch(value);
    // Handle other potential types (String, etc.) if needed
    return defaultValue ?? Timestamp.now();
  }

  /// Parse dynamic to List<String>
  static List<String> parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Parse dynamic to double
  static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Parse dynamic to int
  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}
