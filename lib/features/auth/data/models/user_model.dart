import 'package:json_annotation/json_annotation.dart';
import 'package:lumbungemas/features/auth/domain/entities/user_entity.dart';

part 'user_model.g.dart';

/// User data model for JSON serialization
@JsonSerializable()
class UserModel {
  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'display_name')
  final String? displayName;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  @JsonKey(name: 'created_at')
  final int createdAt;

  @JsonKey(name: 'last_login')
  final int lastLogin;

  const UserModel({
    required this.userId,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLogin,
  });

  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      lastLogin: DateTime.fromMillisecondsSinceEpoch(lastLogin),
    );
  }

  /// Create from domain entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      userId: entity.userId,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      lastLogin: entity.lastLogin.millisecondsSinceEpoch,
    );
  }

  /// Create from Google Sheets row
  factory UserModel.fromSheetRow(List<Object?> row) {
    return UserModel(
      userId: row[0]?.toString() ?? '',
      email: row[1]?.toString() ?? '',
      displayName: row.length > 2 ? row[2]?.toString() : null,
      photoUrl: row.length > 3 ? row[3]?.toString() : null,
      createdAt: row.length > 4
          ? int.tryParse(row[4]?.toString() ?? '0') ?? 0
          : DateTime.now().millisecondsSinceEpoch,
      lastLogin: row.length > 5
          ? int.tryParse(row[5]?.toString() ?? '0') ?? 0
          : DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Convert to Google Sheets row
  List<Object?> toSheetRow() {
    return [
      userId,
      email,
      displayName ?? '',
      photoUrl ?? '',
      createdAt.toString(),
      lastLogin.toString(),
    ];
  }

  /// JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? photoUrl,
    int? createdAt,
    int? lastLogin,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
