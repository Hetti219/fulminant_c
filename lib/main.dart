import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'repositories/auth_repository.dart';
import 'repositories/course_repository.dart';
import 'repositories/leaderboard_repository.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final authRepository = AuthRepository();
  final courseRepository = CourseRepository();
  final leaderboardRepository = LeaderboardRepository();
  
  runApp(App(
    authRepository: authRepository,
    courseRepository: courseRepository,
    leaderboardRepository: leaderboardRepository,
  ));
}
