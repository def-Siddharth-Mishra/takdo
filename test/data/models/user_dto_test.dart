import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:takdo/data/models/user_dto.dart';
import 'package:takdo/domain/entities/user.dart';

void main() {
  group('UserDto', () {
    final testDateTime = DateTime(2024, 1, 1, 12, 0, 0);
    final testTimestamp = Timestamp.fromDate(testDateTime);

    final testUserDto = UserDto(
      id: 'test-id',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: testDateTime,
    );

    final testUser = User(
      id: 'test-id',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: testDateTime,
    );

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        // Act
        final json = testUserDto.toJson();

        // Assert
        expect(json['id'], 'test-id');
        expect(json['email'], 'test@example.com');
        expect(json['displayName'], 'Test User');
        expect(json['createdAt'], isA<Timestamp>());
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'id': 'test-id',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'createdAt': testTimestamp,
        };

        // Act
        final userDto = UserDto.fromJson(json);

        // Assert
        expect(userDto, testUserDto);
      });
    });

    group('Domain conversion', () {
      test('should convert from domain entity correctly', () {
        // Act
        final userDto = UserDto.fromDomain(testUser);

        // Assert
        expect(userDto.id, testUser.id);
        expect(userDto.email, testUser.email);
        expect(userDto.displayName, testUser.displayName);
        expect(userDto.createdAt, testUser.createdAt);
      });

      test('should convert to domain entity correctly', () {
        // Act
        final user = testUserDto.toDomain();

        // Assert
        expect(user.id, testUserDto.id);
        expect(user.email, testUserDto.email);
        expect(user.displayName, testUserDto.displayName);
        expect(user.createdAt, testUserDto.createdAt);
      });
    });

    group('copyWith functionality', () {
      test('should create copy with updated fields', () {
        // Act
        final updatedDto = testUserDto.copyWith(
          email: 'updated@example.com',
          displayName: 'Updated User',
        );

        // Assert
        expect(updatedDto.email, 'updated@example.com');
        expect(updatedDto.displayName, 'Updated User');
        expect(updatedDto.id, testUserDto.id); // unchanged
        expect(updatedDto.createdAt, testUserDto.createdAt); // unchanged
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        // Arrange
        final dto1 = testUserDto;
        final dto2 = testUserDto.copyWith();

        // Assert
        expect(dto1, dto2);
        expect(dto1.hashCode, dto2.hashCode);
      });

      test('should not be equal when fields differ', () {
        // Arrange
        final dto1 = testUserDto;
        final dto2 = testUserDto.copyWith(email: 'different@example.com');

        // Assert
        expect(dto1, isNot(dto2));
        expect(dto1.hashCode, isNot(dto2.hashCode));
      });
    });
  });
}