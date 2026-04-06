import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'leaderboard_repository.dart';

class FirebaseLeaderboardRepository implements LeaderboardRepository {
  final FirebaseFirestore _firestore;

  FirebaseLeaderboardRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
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

  @override
  Future<UserRank?> getUserRank(String userId) async {
    try {
      // Get user's current points
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      final user = User.fromMap({...userDoc.data()!, 'id': userDoc.id});

      // Use count() aggregation to avoid fetching all higher-ranked user documents
      final countQuery = await _firestore
          .collection('users')
          .where('points', isGreaterThan: user.points)
          .count()
          .get();

      final rank = (countQuery.count ?? 0) + 1;

      return UserRank(
        user: user,
        rank: rank,
      );
    } catch (e) {
      throw LeaderboardException(e.toString());
    }
  }

  @override
  Future<List<User>> getUsersAroundRank(String userId, {int range = 5}) async {
    try {
      // Get user's current points directly instead of computing rank first
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];
      final user = User.fromMap({...userDoc.data()!, 'id': userDoc.id});

      // Fetch users ranked above (strictly higher points), closest first
      final aboveFuture = _firestore
          .collection('users')
          .where('points', isGreaterThan: user.points)
          .orderBy('points')
          .limit(range)
          .get();

      // Fetch users at or below (equal or lower points), closest first
      final belowFuture = _firestore
          .collection('users')
          .where('points', isLessThanOrEqualTo: user.points)
          .orderBy('points', descending: true)
          .limit(range + 1)
          .get();

      // Run both queries in parallel
      final results = await Future.wait([aboveFuture, belowFuture]);

      final aboveUsers = results[0].docs
          .map((doc) => User.fromMap({...doc.data(), 'id': doc.id}))
          .toList()
        ..sort((a, b) => b.points.compareTo(a.points));

      final belowUsers = results[1].docs
          .map((doc) => User.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      // Combine: above users (descending) + below users (already descending)
      final combined = [...aboveUsers, ...belowUsers];

      // Deduplicate by user ID
      final seen = <String>{};
      combined.retainWhere((u) => seen.add(u.id));

      return combined;
    } catch (e) {
      throw LeaderboardException(e.toString());
    }
  }
}
