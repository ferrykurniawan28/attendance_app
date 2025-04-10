part of 'models.dart';

class UserModel {
  final int? id;
  final String userId;
  final String? name;
  final String? email;
  final String? photoProfileUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    this.id,
    required this.userId,
    this.name,
    this.email,
    this.photoProfileUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      photoProfileUrl: json['photo_profile_url'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'photo_profile_url': photoProfileUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
