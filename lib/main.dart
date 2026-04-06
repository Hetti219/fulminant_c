import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'repositories/firebase_auth_repository.dart';
import 'repositories/firebase_course_repository.dart';
import 'repositories/firebase_leaderboard_repository.dart';
import 'repositories/local_biometric_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authRepository = FirebaseAuthRepository();
  final courseRepository = FirebaseCourseRepository();
  final leaderboardRepository = FirebaseLeaderboardRepository();
  final biometricService = LocalBiometricService();

  runApp(App(
    authRepository: authRepository,
    courseRepository: courseRepository,
    leaderboardRepository: leaderboardRepository,
    biometricService: biometricService,
  ));
}
