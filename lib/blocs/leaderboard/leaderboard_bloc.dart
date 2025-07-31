import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/leaderboard_repository.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository _leaderboardRepository;

  LeaderboardBloc({required LeaderboardRepository leaderboardRepository})
      : _leaderboardRepository = leaderboardRepository,
        super(const LeaderboardState()) {
    on<LoadTopUsers>(_onLoadTopUsers);
    on<LoadUserRank>(_onLoadUserRank);
    on<LoadUsersAroundRank>(_onLoadUsersAroundRank);
  }

  void _onLoadTopUsers(LoadTopUsers event, Emitter<LeaderboardState> emit) async {
    emit(state.copyWith(status: LeaderboardStatus.loading));
    try {
      final topUsers = await _leaderboardRepository.getTopUsers(limit: event.limit);
      emit(state.copyWith(
        status: LeaderboardStatus.success,
        topUsers: topUsers,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: LeaderboardStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onLoadUserRank(LoadUserRank event, Emitter<LeaderboardState> emit) async {
    try {
      final userRank = await _leaderboardRepository.getUserRank(event.userId);
      emit(state.copyWith(userRank: userRank));
    } catch (error) {
      emit(state.copyWith(
        status: LeaderboardStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onLoadUsersAroundRank(LoadUsersAroundRank event, Emitter<LeaderboardState> emit) async {
    try {
      final usersAroundRank = await _leaderboardRepository.getUsersAroundRank(
        event.userId,
        range: event.range,
      );
      emit(state.copyWith(usersAroundRank: usersAroundRank));
    } catch (error) {
      emit(state.copyWith(
        status: LeaderboardStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }
}