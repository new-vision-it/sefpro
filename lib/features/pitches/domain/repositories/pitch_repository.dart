import 'package:play5/features/pitches/domain/entities/pitch_entity.dart';
import 'package:play5/core/utils/result.dart';

abstract class PitchRepository {
  Stream<List<PitchEntity>> watchPitches();
  Future<Result<PitchEntity>> addPitch(PitchEntity pitch);
  Future<Result<PitchEntity>> updatePitch(PitchEntity pitch);
  Future<Result<void>> deletePitch(String pitchId);
}
