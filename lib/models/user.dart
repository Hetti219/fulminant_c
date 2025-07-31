import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final DateTime dateOfBirth;
  final int points;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.dateOfBirth,
    this.points = 0,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    DateTime? dateOfBirth,
    int? points,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'points': points,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      dateOfBirth: map['dateOfBirth'] is Timestamp 
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : DateTime.parse(map['dateOfBirth']),
      points: map['points']?.toInt() ?? 0,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
    );
  }

  @override
  List<Object> get props => [id, email, fullName, dateOfBirth, points, createdAt];
}