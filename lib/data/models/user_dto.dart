import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';
import '../converters/timestamp_converter.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

/// Data Transfer Object for User entity with Firestore serialization
@freezed
class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String email,
    required String displayName,
    @TimestampConverter() required DateTime createdAt,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

  /// Convert from domain User entity to UserDto
  factory UserDto.fromDomain(User user) {
    return UserDto(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      createdAt: user.createdAt,
    );
  }
}

/// Extension to convert UserDto to domain User entity
extension UserDtoX on UserDto {
  User toDomain() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      createdAt: createdAt,
    );
  }
}

