import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fulminant_c/blocs/leaderboard/leaderboard_bloc.dart';
import 'package:fulminant_c/blocs/leaderboard/leaderboard_event.dart';
import 'package:fulminant_c/blocs/leaderboard/leaderboard_state.dart';
import 'package:fulminant_c/repositories/leaderboard_repository.dart';
import 'package:mockito/mockito.dart';
import '../helpers/mocks.mocks.dart';
import 'package:fulminant_c/models/user.dart' as domain;

void main() {
  late MockLeaderboardRepository lb;
  late LeaderboardBloc bloc;

  setUp(() {
    lb = MockLeaderboardRepository();
    bloc = LeaderboardBloc(leaderboardRepository: lb);
  });

  tearDown(() => bloc.close());

  blocTest<LeaderboardBloc, LeaderboardState>(
    'LoadTopUsers → invokes getTopUsers(limit)',
    build: () {
      final u = MockUser() as domain.User;
      when(lb.getTopUsers(limit: anyNamed('limit')))
          .thenAnswer((_) async => [u]);
      return bloc;
    },
    act: (b) => b.add(LoadTopUsers(limit: 10)),
    expect: () => [isA<LeaderboardState>(), isA<LeaderboardState>()],
    verify: (_) => verify(lb.getTopUsers(limit: 10)).called(1),
  );

  blocTest<LeaderboardBloc, LeaderboardState>(
    'LoadUserRank → invokes getUserRank(userId)',
    build: () {
      final u = MockUser() as domain.User;
      when(lb.getUserRank(any))
          .thenAnswer((_) async => UserRank(user: u, rank: 7));
      return bloc;
    },
    act: (b) => b.add(LoadUserRank('u_1')), // positional argument
    expect: () => [isA<LeaderboardState>(), isA<LeaderboardState>()],
    verify: (_) => verify(lb.getUserRank('u_1')).called(1),
  );

  blocTest<LeaderboardBloc, LeaderboardState>(
    'LoadUsersAroundRank → invokes getUsersAroundRank(userId, range)',
    build: () {
      final me = MockUser() as domain.User;
      final near = MockUser() as domain.User;
      when(lb.getUsersAroundRank(any, range: anyNamed('range')))
          .thenAnswer((_) async => [me, near]);
      return bloc;
    },
    act: (b) => b.add(LoadUsersAroundRank('u_1', range: 2)),
    // positional + named
    expect: () => [isA<LeaderboardState>(), isA<LeaderboardState>()],
    verify: (_) => verify(lb.getUsersAroundRank('u_1', range: 2)).called(1),
  );
}
