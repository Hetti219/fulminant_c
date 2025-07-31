import 'package:equatable/equatable.dart';
import '../../models/user.dart';
import '../../repositories/leaderboard_repository.dart';

enum LeaderboardStatus { initial, loading, success, failure }

class LeaderboardState extends Equatable {
  final LeaderboardStatus status;
  final List<User> topUsers;
  final UserRank? userRank;
  final List<User> usersAroundRank;
  final String? errorMessage;

  const LeaderboardState({
    this.status = LeaderboardStatus.initial,
    this.topUsers = const [],
    this.userRank,
    this.usersAroundRank = const [],
    this.errorMessage,
  });

  LeaderboardState copyWith({
    LeaderboardStatus? status,
    List<User>? topUsers,
    UserRank? userRank,
    List<User>? usersAroundRank,
    String? errorMessage,
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      topUsers: topUsers ?? this.topUsers,
      userRank: userRank ?? this.userRank,
      usersAroundRank: usersAroundRank ?? this.usersAroundRank,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        topUsers,
        userRank,
        usersAroundRank,
        errorMessage,
      ];
}