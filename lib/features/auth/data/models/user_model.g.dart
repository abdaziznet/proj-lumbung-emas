// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  userId: json['user_id'] as String,
  email: json['email'] as String,
  displayName: json['display_name'] as String?,
  photoUrl: json['photo_url'] as String?,
  createdAt: (json['created_at'] as num).toInt(),
  lastLogin: (json['last_login'] as num).toInt(),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'user_id': instance.userId,
  'email': instance.email,
  'display_name': instance.displayName,
  'photo_url': instance.photoUrl,
  'created_at': instance.createdAt,
  'last_login': instance.lastLogin,
};
