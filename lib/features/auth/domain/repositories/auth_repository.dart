import 'package:play5/features/auth/domain/entities/auth_user.dart';
import 'package:play5/core/utils/result.dart';

abstract class AuthRepository {
  Future<Result<String>> sendOtp(String phoneNumber);
  Future<Result<AuthUser>> verifyOtp({required String code});
  Future<void> logout();
  Stream<AuthUser?> authStateChanges();
}
