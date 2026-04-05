import 'package:equatable/equatable.dart';

abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object> get props => [];
}

class LoadCourses extends CourseEvent {}

class LoadCourse extends CourseEvent {
  final String courseId;

  const LoadCourse(this.courseId);

  @override
  List<Object> get props => [courseId];
}

class LoadCourseModules extends CourseEvent {
  final String courseId;

  const LoadCourseModules(this.courseId);

  @override
  List<Object> get props => [courseId];
}

class LoadModule extends CourseEvent {
  final String moduleId;
  final String? userId;

  const LoadModule(this.moduleId, {this.userId});

  @override
  List<Object> get props => [moduleId, if (userId != null) userId!];
}

class CompleteModule extends CourseEvent {
  final String userId;
  final String courseId;
  final String moduleId;

  const CompleteModule({
    required this.userId,
    required this.courseId,
    required this.moduleId,
  });

  @override
  List<Object> get props => [userId, courseId, moduleId];
}

class CompleteActivity extends CourseEvent {
  final String userId;
  final String courseId;
  final String moduleId;
  final String activityId;

  const CompleteActivity({
    required this.userId,
    required this.courseId,
    required this.moduleId,
    required this.activityId,
  });

  @override
  List<Object> get props => [userId, courseId, moduleId, activityId];
}