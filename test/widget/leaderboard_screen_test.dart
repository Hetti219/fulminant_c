import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb; // firebase auth user

import 'package:fulminant_c/screens/leaderboard/leaderboard_screen.dart';
import 'package:fulminant_c/repositories/leaderboard_repository.dart';
import 'package:fulminant_c/repositories/auth_repository.dart';
import 'package:fulminant_c/blocs/auth/auth_bloc.dart';
import 'package:fulminant_c/models/user.dart' as app; // your domain User model

import '../helpers/pump_app.dart';
import '../helpers/mocks.mocks.dart';

void main() {
  group('LeaderboardScreen', () {
    late MockLeaderboardRepository lbRepo;
    late MockAuthRepository authRepo;
    late AuthBloc authBloc;

    setUp(() {
      lbRepo = MockLeaderboardRepository();
      authRepo = MockAuthRepository();

// Auth stream → unauthenticated
      when(authRepo.user).thenAnswer((_) => Stream<fb.User?>.value(null));

// Typed empty list for your app-domain users
      when(lbRepo.getTopUsers(limit: anyNamed('limit')))
          .thenAnswer((_) async => <app.User>[]);

      authBloc = AuthBloc(authRepository: authRepo);
    });

    tearDown(() async {
      await authBloc.close();
    });

    testWidgets('shows login prompt on "Around You" tab when not authenticated',
        (tester) async {
      await pumpApp(
        tester,
        repositories: [
          RepositoryProvider<LeaderboardRepository>.value(value: lbRepo),
          RepositoryProvider<AuthRepository>.value(value: authRepo),
        ],
        blocs: [
          BlocProvider<AuthBloc>.value(value: authBloc),
        ],
        child: const LeaderboardScreen(showScaffold: true),
      );

      await tester.tap(find.text('Around You'));
      await tester.pumpAndSettle();

      expect(find.text('Please log in to view your ranking'), findsOneWidget);
    });
  });
}
