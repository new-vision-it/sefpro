import 'dart:async';

import 'package:play5/core/utils/result.dart';
import 'package:play5/features/auth/domain/entities/auth_user.dart';
import 'package:play5/features/auth/domain/repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

class MockAuthRepository implements AuthRepository {
  AuthUser? _currentUser;
  final _controller = StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> authStateChanges() => _controller.stream;

  @override
  Future<void> logout() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<Result<String>> sendOtp(String phoneNumber) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _currentUser = AuthUser(id: const Uuid().v4(), phone: phoneNumber, isNew: true);
    return const Success('mock-verification');
  }

  @override
  Future<Result<AuthUser>> verifyOtp({required String code}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _currentUser ??= AuthUser(id: const Uuid().v4(), phone: 'mock', isNew: true);
    final user = _currentUser!;
    _controller.add(user);
    return Success(user);
  }
}
