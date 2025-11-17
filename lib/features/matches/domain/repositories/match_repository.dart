import 'package:play5/features/matches/domain/entities/match_entity.dart';
import 'package:play5/core/utils/result.dart';

abstract class MatchRepository {
  Stream<List<MatchEntity>> watchUpcomingMatches();
  Stream<List<MatchEntity>> watchMyMatches(String userId);
  Future<Result<MatchEntity>> createMatch(MatchEntity match);
  Future<Result<MatchEntity>> joinMatch({required String matchId, required String userId});
  Future<Result<MatchEntity>> leaveMatch({required String matchId, required String userId});
  Future<Result<MatchEntity>> cancelMatch(String matchId);
  Future<Result<MatchEntity>> fetchMatch(String matchId);
  Future<Result<MatchEntity>> updateMatch(MatchEntity match);
}
