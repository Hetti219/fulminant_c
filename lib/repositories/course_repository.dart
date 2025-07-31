import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';

class CourseRepository {
  final FirebaseFirestore _firestore;

  CourseRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Course>> getCourses() async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Course.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw CourseException(e.toString());
    }
  }

  Future<Course> getCourse(String courseId) async {
    try {
      final doc = await _firestore.collection('courses').doc(courseId).get();
      if (doc.exists) {
        return Course.fromMap({...doc.data()!, 'id': doc.id});
      }
      throw CourseException('Course not found');
    } catch (e) {
      throw CourseException(e.toString());
    }
  }

  Future<List<Module>> getCourseModules(String courseId) async {
    try {
      final snapshot = await _firestore
          .collection('modules')
          .where('courseId', isEqualTo: courseId)
          .orderBy('createdAt')
          .get();

      return snapshot.docs
          .map((doc) => Module.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw CourseException(e.toString());
    }
  }

  Future<Module> getModule(String moduleId) async {
    try {
      final doc = await _firestore.collection('modules').doc(moduleId).get();
      if (doc.exists) {
        return Module.fromMap({...doc.data()!, 'id': doc.id});
      }
      throw CourseException('Module not found');
    } catch (e) {
      throw CourseException(e.toString());
    }
  }

  Future<List<UserProgress>> getUserProgress(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('userProgress')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => UserProgress.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw CourseException(e.toString());
    }
  }

  Future<void> updateUserProgress(UserProgress progress) async {
    try {
      await _firestore
          .collection('userProgress')
          .doc(progress.id)
          .set(progress.toMap());
    } catch (e) {
      throw CourseException(e.toString());
    }
  }

  Future<void> completeModule(String userId, String courseId, String moduleId, int points) async {
    try {
      final progressId = '${userId}_${moduleId}';
      
      // Check if already completed
      final existingDoc = await _firestore
          .collection('userProgress')
          .doc(progressId)
          .get();
      
      if (existingDoc.exists) {
        final existingProgress = UserProgress.fromMap({...existingDoc.data()!, 'id': existingDoc.id});
        if (existingProgress.isCompleted) {
          throw CourseException('Module already completed');
        }
      }

      final progress = UserProgress(
        id: progressId,
        userId: userId,
        courseId: courseId,
        moduleId: moduleId,
        isCompleted: true,
        pointsEarned: points,
        completedAt: DateTime.now(),
      );

      await _firestore
          .collection('userProgress')
          .doc(progressId)
          .set(progress.toMap());

      // Update user's total points
      await _firestore.collection('users').doc(userId).update({
        'points': FieldValue.increment(points),
      });
    } catch (e) {
      throw CourseException(e.toString());
    }
  }

  Future<void> completeActivity(String userId, String courseId, String moduleId, String activityId, int points) async {
    try {
      final progressId = '${userId}_${activityId}';
      
      // Check if already completed
      final existingDoc = await _firestore
          .collection('userProgress')
          .doc(progressId)
          .get();
      
      if (existingDoc.exists) {
        final existingProgress = UserProgress.fromMap({...existingDoc.data()!, 'id': existingDoc.id});
        if (existingProgress.isCompleted) {
          throw CourseException('Activity already completed');
        }
      }

      final progress = UserProgress(
        id: progressId,
        userId: userId,
        courseId: courseId,
        moduleId: moduleId,
        activityId: activityId,
        isCompleted: true,
        pointsEarned: points,
        completedAt: DateTime.now(),
      );

      await _firestore
          .collection('userProgress')
          .doc(progressId)
          .set(progress.toMap());

      // Update user's total points
      await _firestore.collection('users').doc(userId).update({
        'points': FieldValue.increment(points),
      });
    } catch (e) {
      throw CourseException(e.toString());
    }
  }
}

class CourseException implements Exception {
  final String message;
  CourseException(this.message);

  @override
  String toString() => message;
}