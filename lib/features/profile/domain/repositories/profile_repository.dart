import 'package:play5/features/profile/domain/entities/player_profile.dart';
import 'package:play5/core/utils/result.dart';

abstract class ProfileRepository {
  Future<Result<PlayerProfile>> createOrUpdateProfile(PlayerProfile profile);
  Future<Result<PlayerProfile>> fetchProfile(String userId);
  Stream<PlayerProfile?> watchProfile(String userId);
}
