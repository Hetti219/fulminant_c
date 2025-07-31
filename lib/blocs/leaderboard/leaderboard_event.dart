import 'package:equatable/equatable.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object> get props => [];
}

class LoadTopUsers extends LeaderboardEvent {
  final int limit;

  const LoadTopUsers({this.limit = 50});

  @override
  List<Object> get props => [limit];
}

class LoadUserRank extends LeaderboardEvent {
  final String userId;

  const LoadUserRank(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadUsersAroundRank extends LeaderboardEvent {
  final String userId;
  final int range;

  const LoadUsersAroundRank(this.userId, {this.range = 5});

  @override
  List<Object> get props => [userId, range];
}