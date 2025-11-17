import 'package:collection/collection.dart';
import 'package:play5/features/profile/domain/entities/player_profile.dart';

class TeamBalancer {
  /// Splits players into two balanced teams according to skill and position hints.
  Map<String, List<PlayerProfile>> split(List<PlayerProfile> players) {
    final List<PlayerProfile> teamA = [];
    final List<PlayerProfile> teamB = [];

    int skillA = 0;
    int skillB = 0;

    void assign(PlayerProfile player) {
      if (skillA <= skillB) {
        teamA.add(player);
        skillA += player.skillLevel;
      } else {
        teamB.add(player);
        skillB += player.skillLevel;
      }
    }

    final goalkeepers = players.where((p) => p.positions.contains('GK')).sortedBy<num>((p) => -p.skillLevel);
    for (final keeper in goalkeepers.take(2)) {
      assign(keeper);
    }

    final remaining = players.where((p) => !goalkeepers.take(2).contains(p)).toList();
    final defenders = remaining.where((p) => p.positions.contains('DEF')).sortedBy<num>((p) => -p.skillLevel);
    for (final def in defenders.take(4)) {
      assign(def);
    }

    final others = remaining.where((p) => !defenders.take(4).contains(p)).sortedBy<num>((p) => -p.skillLevel);
    for (final player in others) {
      assign(player);
    }

    return {
      'A': teamA,
      'B': teamB,
    };
  }
}
