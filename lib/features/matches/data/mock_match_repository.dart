import 'dart:async';

import 'package:play5/core/utils/result.dart';
import 'package:play5/features/matches/domain/entities/match_entity.dart';
import 'package:play5/features/matches/domain/repositories/match_repository.dart';
import 'package:play5/features/matches/domain/usecases/team_balancer.dart';
import 'package:play5/features/profile/domain/entities/player_profile.dart';
import 'package:play5/features/profile/domain/repositories/profile_repository.dart';
import 'package:uuid/uuid.dart';

class MockMatchRepository implements MatchRepository {
  MockMatchRepository(this.profileRepository) {
    final now = DateTime.now();
    _matches = [
      MatchEntity(
        id: const Uuid().v4(),
        creatorId: 'organizer-1',
        pitchId: 'pitch-1',
        dateTimeStart: now.add(const Duration(hours: 2)),
        durationMinutes: 60,
        maxPlayers: 10,
        visibility: 'public',
        status: 'upcoming',
        playersJoined: const [],
        teamA: const [],
        teamB: const [],
        title: 'Evening friendly',
      ),
      MatchEntity(
        id: const Uuid().v4(),
        creatorId: 'organizer-2',
        pitchId: 'pitch-2',
        dateTimeStart: now.add(const Duration(days: 1)),
        durationMinutes: 90,
        maxPlayers: 10,
        visibility: 'public',
        status: 'upcoming',
        playersJoined: const [],
        teamA: const [],
        teamB: const [],
        title: 'Weekend derby',
      ),
    ];
    _controller.add(_matches);
  }

  final ProfileRepository profileRepository;
  final _controller = StreamController<List<MatchEntity>>.broadcast();
  final TeamBalancer _teamBalancer = TeamBalancer();
  late List<MatchEntity> _matches;

  @override
  Future<Result<MatchEntity>> cancelMatch(String matchId) async {
    final index = _matches.indexWhere((m) => m.id == matchId);
    if (index == -1) return Failure('not_found');
    final updated = _matches[index].copyWith(status: 'cancelled');
    _matches[index] = updated;
    _controller.add(_matches);
    return Success(updated);
  }

  @override
  Future<Result<MatchEntity>> createMatch(MatchEntity match) async {
    final created = match.copyWith(id: const Uuid().v4());
    _matches = [..._matches, created];
    _controller.add(_matches);
    return Success(created);
  }

  @override
  Future<Result<MatchEntity>> fetchMatch(String matchId) async {
    final match = _matches.firstWhere((m) => m.id == matchId, orElse: () => throw Exception('not_found'));
    return Success(match);
  }

  @override
  Future<Result<MatchEntity>> updateMatch(MatchEntity match) async {
    final index = _matches.indexWhere((m) => m.id == match.id);
    if (index == -1) return const Failure('not_found');
    _matches[index] = match;
    _controller.add(_matches);
    return Success(match);
  }

  @override
  Future<Result<MatchEntity>> joinMatch({required String matchId, required String userId}) async {
    final index = _matches.indexWhere((m) => m.id == matchId);
    if (index == -1) return Failure('not_found');
    final match = _matches[index];
    if (match.playersJoined.contains(userId)) return Success(match);
    if (match.playersJoined.length >= match.maxPlayers) return Failure('match_full');
    var updated = match.copyWith(playersJoined: [...match.playersJoined, userId]);
    if (updated.playersJoined.length == updated.maxPlayers) {
      final profiles = <PlayerProfile>[];
      for (final id in updated.playersJoined) {
        final profileResult = await profileRepository.fetchProfile(id);
        if (profileResult is Success<PlayerProfile>) {
          profiles.add(profileResult.data);
        }
      }
      final balanced = _teamBalancer.split(profiles);
      updated = updated.copyWith(teamA: balanced['A']!.map((p) => p.id).toList(), teamB: balanced['B']!.map((p) => p.id).toList(), status: 'full');
    }
    _matches[index] = updated;
    _controller.add(_matches);
    return Success(updated);
  }

  @override
  Future<Result<MatchEntity>> leaveMatch({required String matchId, required String userId}) async {
    final index = _matches.indexWhere((m) => m.id == matchId);
    if (index == -1) return Failure('not_found');
    final match = _matches[index];
    final updatedPlayers = [...match.playersJoined]..remove(userId);
    final updated = match.copyWith(playersJoined: updatedPlayers, teamA: [], teamB: [], status: 'upcoming');
    _matches[index] = updated;
    _controller.add(_matches);
    return Success(updated);
  }

  @override
  Stream<List<MatchEntity>> watchMyMatches(String userId) {
    return _controller.stream.map((matches) => matches.where((m) => m.playersJoined.contains(userId) || m.creatorId == userId).toList());
  }

  @override
  Stream<List<MatchEntity>> watchUpcomingMatches() => _controller.stream;
}
