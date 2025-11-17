import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:play5/core/utils/result.dart';
import 'package:play5/features/auth/domain/entities/auth_user.dart';
import 'package:play5/features/auth/domain/repositories/auth_repository.dart';
import 'package:play5/features/profile/domain/entities/player_profile.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  String? _verificationId;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final isNew = !doc.exists;
      final data = doc.data();
      final roleString = data != null ? data['role'] as String? : null;
      final role = _parseRole(roleString);
      final isApproved = data == null ? true : (data['isApproved'] as bool? ?? true);
      return AuthUser(
        id: user.uid,
        phone: user.phoneNumber ?? '',
        isNew: isNew,
        isAdmin: role == PlayerRole.admin,
        isOrganizer: role == PlayerRole.organizer,
        isApproved: isApproved,
      );
    });
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

  @override
  Future<Result<String>> sendOtp(String phoneNumber) async {
    final completer = Completer<Result<String>>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        try {
          await _auth.signInWithCredential(credential);
          if (!completer.isCompleted) {
            completer.complete(Success('')); // Auto-retrieval completed.
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.complete(Failure(e.toString()));
          }
        }
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.complete(Failure(e.message ?? 'verification_failed'));
        }
      },
      codeSent: (verificationId, _) {
        _verificationId = verificationId;
        if (!completer.isCompleted) {
          completer.complete(Success(verificationId));
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );

    return completer.future;
  }

  @override
  Future<Result<AuthUser>> verifyOtp({required String code}) async {
    final verificationId = _verificationId;
    if (verificationId == null) {
      return const Failure('missing_verification_id');
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) return const Failure('no_user');
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final isNew = !doc.exists;
      final data = doc.data();
      final roleString = data != null ? data['role'] as String? : null;
      final role = _parseRole(roleString);
      final isApproved = data == null ? true : (data['isApproved'] as bool? ?? true);
      return Success(
        AuthUser(
          id: user.uid,
          phone: user.phoneNumber ?? '',
          isNew: isNew,
          isAdmin: role == PlayerRole.admin,
          isOrganizer: role == PlayerRole.organizer,
          isApproved: isApproved,
        ),
      );
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<void> logout() => _auth.signOut();
}
