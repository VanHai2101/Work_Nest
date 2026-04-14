import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work_nest/core/domain/entities/user_entity.dart';
import 'package:work_nest/core/utils/parser.dart';

class UserModel {
  final String id;
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String plan;
  final List<String> fcmTokens;
  final Timestamp? planExpiresAt;
  final Timestamp? planUpdatedAt;

  UserModel({
    required this.id,
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.updatedAt,
    required this.plan,
    this.fcmTokens = const [],
    this.planExpiresAt,
    this.planUpdatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic>? json, {String? id}) {
    if (json == null) return UserModel.empty();
    return UserModel(
      id: id ?? '',
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      photoURL: json['photoURL'] as String?,
      createdAt: Parser.parseTimestamp(json['createdAt']),
      updatedAt: Parser.parseTimestamp(json['updatedAt']),
      plan: json['plan'] as String? ?? 'free',
      fcmTokens: Parser.parseStringList(json['fcmTokens']),
      planExpiresAt: json['planExpiresAt'] != null 
          ? Parser.parseTimestamp(json['planExpiresAt']) 
          : null,
      planUpdatedAt: json['planUpdatedAt'] != null 
          ? Parser.parseTimestamp(json['planUpdatedAt']) 
          : null,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    id: entity.id,
    uid: entity.uid,
    email: entity.email,
    displayName: entity.displayName,
    photoURL: entity.photoURL,
    createdAt: Timestamp.fromDate(entity.createdAt),
    updatedAt: Timestamp.fromDate(entity.updatedAt),
    plan: entity.plan,
    fcmTokens: entity.fcmTokens,
    planExpiresAt: entity.planExpiresAt != null 
        ? Timestamp.fromDate(entity.planExpiresAt!) 
        : null,
    planUpdatedAt: entity.planUpdatedAt != null 
        ? Timestamp.fromDate(entity.planUpdatedAt!) 
        : null,
  );

  factory UserModel.empty() => UserModel(
    id: '',
    uid: '',
    email: '',
    displayName: '',
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
    plan: 'free',
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoURL': photoURL,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'plan': plan,
    'fcmTokens': fcmTokens,
    'planExpiresAt': planExpiresAt,
    'planUpdatedAt': planUpdatedAt,
  };

  UserEntity toEntity() => UserEntity(
    id: id,
    uid: uid,
    email: email,
    displayName: displayName,
    photoURL: photoURL,
    createdAt: createdAt.toDate(),
    updatedAt: updatedAt.toDate(),
    plan: plan,
    fcmTokens: fcmTokens,
    planExpiresAt: planExpiresAt?.toDate(),
    planUpdatedAt: planUpdatedAt?.toDate(),
  );

  UserModel copyWith({
    String? id,
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? plan,
    List<String>? fcmTokens,
    Timestamp? planExpiresAt,
    Timestamp? planUpdatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      plan: plan ?? this.plan,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      planExpiresAt: planExpiresAt ?? this.planExpiresAt,
      planUpdatedAt: planUpdatedAt ?? this.planUpdatedAt,
    );
  }

  static List<UserModel> fromJsonList(List<dynamic>? jsonList) =>
      jsonList?.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];

  static List<UserEntity> toEntityList(List<UserModel> models) =>
      models.map((m) => m.toEntity()).toList();
}
