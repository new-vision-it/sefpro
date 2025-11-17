import 'dart:async';

import 'package:play5/core/utils/result.dart';
import 'package:play5/features/pitches/domain/entities/pitch_entity.dart';
import 'package:play5/features/pitches/domain/repositories/pitch_repository.dart';
import 'package:uuid/uuid.dart';

class MockPitchRepository implements PitchRepository {
  final List<PitchEntity> _pitches = [
    PitchEntity(id: const Uuid().v4(), name: 'Pitch 1', description: 'Near main gate'),
    PitchEntity(id: const Uuid().v4(), name: 'Pitch 2', description: 'Near clubhouse'),
  ];
  final _controller = StreamController<List<PitchEntity>>.broadcast();

  MockPitchRepository() {
    _controller.add(_pitches);
  }

  @override
  Future<Result<PitchEntity>> addPitch(PitchEntity pitch) async {
    _pitches.add(pitch);
    _controller.add(List.unmodifiable(_pitches));
    return Success(pitch);
  }

  @override
  Future<Result<void>> deletePitch(String pitchId) async {
    _pitches.removeWhere((p) => p.id == pitchId);
    _controller.add(List.unmodifiable(_pitches));
    return const Success(null);
  }

  @override
  Stream<List<PitchEntity>> watchPitches() => _controller.stream;

  @override
  Future<Result<PitchEntity>> updatePitch(PitchEntity pitch) async {
    final index = _pitches.indexWhere((p) => p.id == pitch.id);
    if (index == -1) return Failure('not_found');
    _pitches[index] = pitch;
    _controller.add(List.unmodifiable(_pitches));
    return Success(pitch);
  }
}
