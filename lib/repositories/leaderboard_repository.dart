import '../models/user.dart';

abstract class LeaderboardRepository {
  Future<List<User>> getTopUsers({int limit = 50});

  Future<UserRank?> getUserRank(String userId);

  Future<List<User>> getUsersAroundRank(String userId, {int range = 5});
}

class UserRank {
  final User user;
  final int rank;

  UserRank({
    required this.user,
    required this.rank,
  });

  @override
  String toString() => rank.toString();
}

class LeaderboardException implements Exception {
  final String message;
  LeaderboardException(this.message);

  @override
  String toString() => message;
}
