import 'package:fulminant_c/repositories/course_repository.dart';
import 'package:fulminant_c/repositories/leaderboard_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:fulminant_c/repositories/auth_repository.dart';

import 'package:fulminant_c/models/user.dart'
    as domain; // alias to avoid name clashes
import 'package:fulminant_c/models/course.dart' as models;

@GenerateMocks([
  AuthRepository,
  CourseRepository,
  LeaderboardRepository,
// Domain types returned/consumed by repos
  domain.User,
  models.Course,
  models.Module,
  models.UserProgress,
])
void main() {}
