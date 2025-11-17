import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:play5/core/utils/result.dart';
import 'package:play5/features/matches/domain/entities/match_entity.dart';
import 'package:play5/features/matches/domain/repositories/match_repository.dart';
import 'package:play5/features/matches/domain/usecases/team_balancer.dart';
import 'package:play5/features/profile/domain/entities/player_profile.dart';

class FirebaseMatchRepository implements MatchRepository {
  FirebaseMatchRepository({
    FirebaseFirestore? firestore,
    TeamBalancer? teamBalancer,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _teamBalancer = teamBalancer ?? TeamBalancer();

  final FirebaseFirestore _firestore;
  final TeamBalancer _teamBalancer;

  CollectionReference<Map<String, dynamic>> get _matches => _firestore.collection('matches');
  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');

  @override
  Stream<List<MatchEntity>> watchUpcomingMatches() {
    return _matches
        .orderBy('dateTimeStart')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Stream<List<MatchEntity>> watchMyMatches(String userId) {
    return _matches
        .where('playersJoined', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Future<Result<MatchEntity>> createMatch(MatchEntity match) async {
    try {
      final doc = _matches.doc();
      final entity = match.copyWith(id: doc.id);
      await doc.set(_toMap(entity));
      return Success(entity);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<MatchEntity>> fetchMatch(String matchId) async {
    try {
      final doc = await _matches.doc(matchId).get();
      if (!doc.exists) return const Failure('not_found');
      return Success(_fromDoc(doc));
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<MatchEntity>> joinMatch({required String matchId, required String userId}) async {
    try {
      return await _firestore.runTransaction<Result<MatchEntity>>((transaction) async {
        final ref = _matches.doc(matchId);
        final snapshot = await transaction.get(ref);
        if (!snapshot.exists) return const Failure('not_found');
        final match = _fromDoc(snapshot);
        if (match.playersJoined.contains(userId)) return Success(match);
        if (match.playersJoined.length >= match.maxPlayers) return const Failure('full');

        final updatedPlayers = [...match.playersJoined, userId];
        List<String> teamA = match.teamA;
        List<String> teamB = match.teamB;

        if (updatedPlayers.length == match.maxPlayers) {
          final playerProfiles = <PlayerProfile>[];
          for (final id in updatedPlayers) {
            final profileSnap = await transaction.get(_users.doc(id));
            if (profileSnap.exists) {
              playerProfiles.add(_profileFromDoc(profileSnap));
            }
          }
          final balanced = _teamBalancer.split(playerProfiles);
          teamA = balanced['A']?.map((e) => e.id).toList() ?? [];
          teamB = balanced['B']?.map((e) => e.id).toList() ?? [];
        }

        final updated = match.copyWith(
          playersJoined: updatedPlayers,
          teamA: teamA,
          teamB: teamB,
          status: updatedPlayers.length == match.maxPlayers ? 'full' : match.status,
        );
        transaction.update(ref, _toMap(updated, includeCreatedAt: false));
        return Success(updated);
      });
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<MatchEntity>> leaveMatch({required String matchId, required String userId}) async {
    try {
      return await _firestore.runTransaction<Result<MatchEntity>>((transaction) async {
        final ref = _matches.doc(matchId);
        final snapshot = await transaction.get(ref);
        if (!snapshot.exists) return const Failure('not_found');
        final match = _fromDoc(snapshot);
        if (!match.playersJoined.contains(userId)) return Success(match);
        final updatedPlayers = [...match.playersJoined]..remove(userId);
        final updated = match.copyWith(
          playersJoined: updatedPlayers,
          teamA: updatedPlayers.length < match.maxPlayers ? <String>[] : match.teamA,
          teamB: updatedPlayers.length < match.maxPlayers ? <String>[] : match.teamB,
          status: 'upcoming',
        );
        transaction.update(ref, _toMap(updated, includeCreatedAt: false));
        return Success(updated);
      });
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<MatchEntity>> cancelMatch(String matchId) async {
    try {
      final ref = _matches.doc(matchId);
      await ref.update({'status': 'cancelled', 'updatedAt': FieldValue.serverTimestamp()});
      final doc = await ref.get();
      return Success(_fromDoc(doc));
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<MatchEntity>> updateMatch(MatchEntity match) async {
    try {
      await _matches.doc(match.id).update(_toMap(match, includeCreatedAt: false));
      return Success(match);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  MatchEntity _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MatchEntity(
      id: doc.id,
      creatorId: data['creatorId'] as String? ?? '',
      pitchId: data['pitchId'] as String? ?? '',
      dateTimeStart: (data['dateTimeStart'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 60,
      maxPlayers: (data['maxPlayers'] as num?)?.toInt() ?? 10,
      visibility: data['visibility'] as String? ?? 'public',
      status: data['status'] as String? ?? 'upcoming',
      playersJoined: List<String>.from(data['playersJoined'] as List? ?? []),
      teamA: List<String>.from(data['teamA'] as List? ?? []),
      teamB: List<String>.from(data['teamB'] as List? ?? []),
      title: data['title'] as String?,
    );
  }

  Map<String, dynamic> _toMap(MatchEntity match, {bool includeCreatedAt = true}) {
    return {
      'creatorId': match.creatorId,
      'pitchId': match.pitchId,
      'dateTimeStart': Timestamp.fromDate(match.dateTimeStart),
      'durationMinutes': match.durationMinutes,
      'maxPlayers': match.maxPlayers,
      'visibility': match.visibility,
      'status': match.status,
      'playersJoined': match.playersJoined,
      'teamA': match.teamA,
      'teamB': match.teamB,
      'title': match.title,
      'updatedAt': FieldValue.serverTimestamp(),
      if (includeCreatedAt) 'createdAt': FieldValue.serverTimestamp(),
    };
  }

  PlayerProfile _profileFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PlayerProfile(
      id: doc.id,
      name: data['name'] as String? ?? '',
      age: (data['age'] as num?)?.toInt() ?? 18,
      preferredFoot: PreferredFoot.values.firstWhere(
        (e) => e.name == (data['preferredFoot'] as String? ?? 'right'),
        orElse: () => PreferredFoot.right,
      ),
      positions: List<String>.from(data['positions'] as List? ?? []),
      skillLevel: (data['skillLevel'] as num?)?.toInt() ?? 1,
      preferredDays: List<String>.from(data['preferredDays'] as List? ?? []),
      preferredTimeWindows: (data['preferredTimeWindows'] as List? ?? [])
          .map<TimeWindow>((e) => TimeWindow.values.firstWhere((tw) => tw.name == e, orElse: () => TimeWindow.morning))
          .toList(),
      phone: data['phone'] as String? ?? '',
      role: PlayerRole.values.firstWhere(
        (r) => r.name == (data['role'] as String? ?? 'player'),
        orElse: () => PlayerRole.player,
      ),
      isApproved: data['isApproved'] as bool? ?? true,
    );
  }
}
