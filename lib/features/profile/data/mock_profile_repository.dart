import 'dart:async';

import 'package:play5/core/utils/result.dart';
import 'package:play5/features/profile/domain/entities/player_profile.dart';
import 'package:play5/features/profile/domain/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  final Map<String, PlayerProfile> _profiles = {};
  final Map<String, StreamController<PlayerProfile?>> _controllers = {};

  @override
  Future<Result<PlayerProfile>> createOrUpdateProfile(PlayerProfile profile) async {
    _profiles[profile.id] = profile;
    _controllers.putIfAbsent(profile.id, () => StreamController<PlayerProfile?>.broadcast()).add(profile);
    return Success(profile);
  }

  @override
  Future<Result<PlayerProfile>> fetchProfile(String userId) async {
    final profile = _profiles[userId];
    if (profile == null) {
      return Failure('profile_not_found');
    }
    return Success(profile);
  }

  @override
  Stream<PlayerProfile?> watchProfile(String userId) {
    _controllers.putIfAbsent(userId, () => StreamController<PlayerProfile?>.broadcast());
    _controllers[userId]!.add(_profiles[userId]);
    return _controllers[userId]!.stream;
  }
}
