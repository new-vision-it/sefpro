import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:play5/core/utils/result.dart';
import 'package:play5/features/pitches/domain/entities/pitch_entity.dart';
import 'package:play5/features/pitches/domain/repositories/pitch_repository.dart';

class FirebasePitchRepository implements PitchRepository {
  FirebasePitchRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _pitches => _firestore.collection('pitches');

  @override
  Stream<List<PitchEntity>> watchPitches() {
    return _pitches.snapshots().map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Future<Result<PitchEntity>> addPitch(PitchEntity pitch) async {
    try {
      final doc = pitch.id.isEmpty ? _pitches.doc() : _pitches.doc(pitch.id);
      final entity = pitch.copyWith(id: doc.id);
      await doc.set(_toMap(entity));
      return Success(entity);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> deletePitch(String pitchId) async {
    try {
      await _pitches.doc(pitchId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<PitchEntity>> updatePitch(PitchEntity pitch) async {
    try {
      await _pitches.doc(pitch.id).update(_toMap(pitch));
      return Success(pitch);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  PitchEntity _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PitchEntity(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      locationDescription: data['locationDescription'] as String?,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> _toMap(PitchEntity pitch) {
    return {
      'name': pitch.name,
      'description': pitch.description,
      'locationDescription': pitch.locationDescription,
      'isActive': pitch.isActive,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
