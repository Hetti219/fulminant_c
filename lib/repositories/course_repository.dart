import '../models/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();

  Future<Course> getCourse(String courseId);

  Future<List<Module>> getCourseModules(String courseId);

  Future<Module> getModule(String moduleId);

  Future<List<UserProgress>> getUserProgress(String userId);

  Future<void> updateUserProgress(UserProgress progress);

  Future<void> completeModule(String userId, String courseId, String moduleId);

  Future<void> completeActivity(String userId, String courseId, String moduleId, String activityId);
}

class CourseException implements Exception {
  final String message;
  CourseException(this.message);

  @override
  String toString() => message;
}
