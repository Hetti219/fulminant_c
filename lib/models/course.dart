import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Course extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> moduleIds;
  final DateTime createdAt;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.moduleIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'moduleIds': moduleIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      moduleIds: List<String>.from(map['moduleIds'] ?? []),
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
    );
  }

  @override
  List<Object> get props => [id, title, description, imageUrl, moduleIds, createdAt];
}

class Module extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final List<Activity> activities;
  final int pointsReward;
  final DateTime createdAt;

  const Module({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.activities,
    required this.pointsReward,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'content': content,
      'activities': activities.map((x) => x.toMap()).toList(),
      'pointsReward': pointsReward,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      id: map['id'] ?? '',
      courseId: map['courseId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      activities: List<Activity>.from(
        map['activities']?.map((x) => Activity.fromMap(x)) ?? [],
      ),
      pointsReward: map['pointsReward']?.toInt() ?? 0,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
    );
  }

  @override
  List<Object> get props => [id, courseId, title, content, activities, pointsReward, createdAt];
}

class Activity extends Equatable {
  final String id;
  final String moduleId;
  final String title;
  final ActivityType type;
  final Map<String, dynamic> data;
  final int pointsReward;

  const Activity({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.type,
    required this.data,
    required this.pointsReward,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moduleId': moduleId,
      'title': title,
      'type': type.toString(),
      'data': data,
      'pointsReward': pointsReward,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] ?? '',
      moduleId: map['moduleId'] ?? '',
      title: map['title'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => ActivityType.quiz,
      ),
      data: map['data'] ?? {},
      pointsReward: map['pointsReward']?.toInt() ?? 0,
    );
  }

  @override
  List<Object> get props => [id, moduleId, title, type, data, pointsReward];
}

enum ActivityType {
  quiz,
  questionnaire,
}

class UserProgress extends Equatable {
  final String id;
  final String userId;
  final String courseId;
  final String moduleId;
  final String? activityId;
  final bool isCompleted;
  final int pointsEarned;
  final DateTime completedAt;

  const UserProgress({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.moduleId,
    this.activityId,
    required this.isCompleted,
    required this.pointsEarned,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'moduleId': moduleId,
      'activityId': activityId,
      'isCompleted': isCompleted,
      'pointsEarned': pointsEarned,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      courseId: map['courseId'] ?? '',
      moduleId: map['moduleId'] ?? '',
      activityId: map['activityId'],
      isCompleted: map['isCompleted'] ?? false,
      pointsEarned: map['pointsEarned']?.toInt() ?? 0,
      completedAt: map['completedAt'] is Timestamp 
          ? (map['completedAt'] as Timestamp).toDate()
          : DateTime.parse(map['completedAt']),
    );
  }

  @override
  List<Object?> get props => [id, userId, courseId, moduleId, activityId, isCompleted, pointsEarned, completedAt];
}