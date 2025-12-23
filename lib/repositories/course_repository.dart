import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/course.dart';

class CourseRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CourseRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

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

  /// Complete a module using server-side Cloud Function for secure points validation
  /// This prevents client-side manipulation of points
  Future<void> completeModule(String userId, String courseId, String moduleId, int points) async {
    try {
      // Call Cloud Function instead of directly updating Firestore
      // The server validates and awards the correct points
      final HttpsCallable callable = _functions.httpsCallable('completeModule');
      final result = await callable.call(<String, dynamic>{
        'courseId': courseId,
        'moduleId': moduleId,
      });

      // Cloud Function returns success status and actual points earned
      if (result.data['success'] != true) {
        throw CourseException(result.data['message'] ?? 'Failed to complete module');
      }
    } on FirebaseFunctionsException catch (e) {
      // Handle Cloud Functions errors
      if (e.code == 'already-exists') {
        throw CourseException('Module already completed');
      } else if (e.code == 'not-found') {
        throw CourseException('Module not found');
      } else if (e.code == 'unauthenticated') {
        throw CourseException('You must be logged in to complete modules');
      }
      throw CourseException(e.message ?? 'Failed to complete module');
    } catch (e) {
      throw CourseException(e.toString());
    }
  }

  /// Complete an activity using server-side Cloud Function for secure points validation
  /// This prevents client-side manipulation of points
  Future<void> completeActivity(String userId, String courseId, String moduleId, String activityId, int points) async {
    try {
      // Call Cloud Function instead of directly updating Firestore
      // The server validates and awards the correct points
      final HttpsCallable callable = _functions.httpsCallable('completeActivity');
      final result = await callable.call(<String, dynamic>{
        'courseId': courseId,
        'moduleId': moduleId,
        'activityId': activityId,
      });

      // Cloud Function returns success status and actual points earned
      if (result.data['success'] != true) {
        throw CourseException(result.data['message'] ?? 'Failed to complete activity');
      }
    } on FirebaseFunctionsException catch (e) {
      // Handle Cloud Functions errors
      if (e.code == 'already-exists') {
        throw CourseException('Activity already completed');
      } else if (e.code == 'not-found') {
        throw CourseException('Activity not found');
      } else if (e.code == 'unauthenticated') {
        throw CourseException('You must be logged in to complete activities');
      }
      throw CourseException(e.message ?? 'Failed to complete activity');
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