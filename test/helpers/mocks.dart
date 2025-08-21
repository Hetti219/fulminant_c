import 'package:fulminant_c/repositories/course_repository.dart';
import 'package:fulminant_c/repositories/leaderboard_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:fulminant_c/repositories/auth_repository.dart';

import 'package:fulminant_c/models/user.dart' as domain;

@GenerateNiceMocks([
  MockSpec<AuthRepository>(),
  MockSpec<CourseRepository>(),
  MockSpec<LeaderboardRepository>(),
  MockSpec<domain.User>(),
])
void main() {}
