import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fulminant_c/screens/main_navigation.dart';
import 'package:fulminant_c/repositories/course_repository.dart';
import 'package:fulminant_c/repositories/leaderboard_repository.dart';
import 'package:fulminant_c/repositories/auth_repository.dart';
import 'package:fulminant_c/blocs/auth/auth_bloc.dart';
import 'package:fulminant_c/models/user.dart' as app;
import 'package:mockito/mockito.dart';

import '../helpers/pump_app.dart';
import '../helpers/mocks.mocks.dart';

void main() {
  group('MainNavigation', () {
    late MockCourseRepository courseRepo;
    late MockLeaderboardRepository lbRepo;
    late MockAuthRepository authRepo;
    late AuthBloc authBloc;

    setUp(() {
      courseRepo = MockCourseRepository();
      lbRepo = MockLeaderboardRepository();
      authRepo = MockAuthRepository();

// Unauthenticated stream
      when(authRepo.user).thenAnswer((_) => Stream<fb.User?>.value(null));

// Leaderboard initial fetch → typed empty list
      when(lbRepo.getTopUsers(limit: anyNamed('limit')))
          .thenAnswer((_) async => <app.User>[]);

// NOTE: Removed fetchCourses() stub because your repo doesn't expose it.
// If Courses tab triggers another method, tell me its name/signature and I'll stub it here.

      authBloc = AuthBloc(authRepository: authRepo);
    });

    tearDown(() async {
      await authBloc.close();
    });

    testWidgets(
        'tapping Courses tab switches to Courses view (spinner on initial)',
        (tester) async {
      await pumpApp(
        tester,
        repositories: [
          RepositoryProvider<CourseRepository>.value(value: courseRepo),
          RepositoryProvider<LeaderboardRepository>.value(value: lbRepo),
          RepositoryProvider<AuthRepository>.value(value: authRepo),
        ],
        blocs: [
          BlocProvider<AuthBloc>.value(value: authBloc),
        ],
        child: const MainNavigation(),
      );

      await tester.tap(find.text('Courses'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
