import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class LeaderboardRepository {
  final FirebaseFirestore _firestore;

  LeaderboardRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<User>> getTopUsers({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('points', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => User.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw LeaderboardException(e.toString());
    }
  }

  Future<UserRank?> getUserRank(String userId) async {
    try {
      // Get user's current points
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      final user = User.fromMap({...userDoc.data()!, 'id': userDoc.id});

      // Count users with higher points
      final higherPointsQuery = await _firestore
          .collection('users')
          .where('points', isGreaterThan: user.points)
          .get();

      final rank = higherPointsQuery.docs.length + 1;

      return UserRank(
        user: user,
        rank: rank,
      );
    } catch (e) {
      throw LeaderboardException(e.toString());
    }
  }

  Future<List<User>> getUsersAroundRank(String userId, {int range = 5}) async {
    try {
      final userRank = await getUserRank(userId);
      if (userRank == null) return [];

      final startRank = (userRank.rank - range).clamp(1, double.infinity).toInt();
      final endRank = userRank.rank + range;

      // Get users sorted by points, then slice for the range
      final snapshot = await _firestore
          .collection('users')
          .orderBy('points', descending: true)
          .limit(endRank)
          .get();

      final allUsers = snapshot.docs
          .map((doc) => User.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      // Return users in the specified range
      final startIndex = (startRank - 1).clamp(0, allUsers.length);
      final endIndex = endRank.clamp(0, allUsers.length);

      return allUsers.sublist(startIndex, endIndex);
    } catch (e) {
      throw LeaderboardException(e.toString());
    }
  }
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