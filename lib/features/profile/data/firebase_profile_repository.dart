import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:play5/core/utils/result.dart';
import 'package:play5/features/profile/domain/entities/player_profile.dart';
import 'package:play5/features/profile/domain/repositories/profile_repository.dart';

class FirebaseProfileRepository implements ProfileRepository {
  FirebaseProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');

  @override
  Future<Result<PlayerProfile>> createOrUpdateProfile(PlayerProfile profile) async {
    try {
      await _users.doc(profile.id).set(_toMap(profile), SetOptions(merge: true));
      return Success(profile);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<PlayerProfile>> fetchProfile(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (!doc.exists) return const Failure('not_found');
      return Success(_fromDoc(doc));
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Stream<PlayerProfile?> watchProfile(String userId) {
    return _users.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _fromDoc(doc);
    });
  }

  PlayerProfile _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PlayerProfile(
      id: doc.id,
      name: data['name'] as String? ?? '',
      age: (data['age'] as num?)?.toInt() ?? 18,
      preferredFoot: _parseFoot(data['preferredFoot'] as String?),
      positions: List<String>.from(data['positions'] as List? ?? []),
      skillLevel: (data['skillLevel'] as num?)?.toInt() ?? 1,
      preferredDays: List<String>.from(data['preferredDays'] as List? ?? []),
      preferredTimeWindows: _parseTimeWindows(data['preferredTimeWindows'] as List?),
      phone: data['phone'] as String? ?? '',
      role: _parseRole(data['role'] as String?),
      isApproved: data['isApproved'] as bool? ?? true,
    );
  }

  Map<String, dynamic> _toMap(PlayerProfile profile) {
    return {
      'name': profile.name,
      'age': profile.age,
      'preferredFoot': profile.preferredFoot.name,
      'positions': profile.positions,
      'skillLevel': profile.skillLevel,
      'preferredDays': profile.preferredDays,
      'preferredTimeWindows': profile.preferredTimeWindows.map((e) => e.name).toList(),
      'phone': profile.phone,
      'role': profile.role.name,
      'isApproved': profile.isApproved,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  PreferredFoot _parseFoot(String? value) {
    switch (value) {
      case 'left':
        return PreferredFoot.left;
      case 'right':
        return PreferredFoot.right;
      case 'both':
        return PreferredFoot.both;
      default:
        return PreferredFoot.right;
    }
  }

  List<TimeWindow> _parseTimeWindows(List? raw) {
    return (raw ?? []).map<TimeWindow>((e) {
      switch (e) {
        case 'afternoon':
          return TimeWindow.afternoon;
        case 'night':
          return TimeWindow.night;
        default:
          return TimeWindow.morning;
      }
    }).toList();
  }

  PlayerRole _parseRole(String? value) {
    switch (value) {
      case 'admin':
        return PlayerRole.admin;
      case 'organizer':
        return PlayerRole.organizer;
      default:
        return PlayerRole.player;
    }
  }
}
