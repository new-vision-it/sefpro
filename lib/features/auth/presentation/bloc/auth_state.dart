part of 'auth_bloc.dart';

enum AuthStatus { unauthenticated, authenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.loading = false,
    this.error,
    this.verificationId,
  });

  final AuthStatus status;
  final AuthUser? user;
  final bool loading;
  final String? error;
  final String? verificationId;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool? loading,
    String? error,
    String? verificationId,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error,
      verificationId: verificationId ?? this.verificationId,
    );
  }

  @override
  List<Object?> get props => [status, user, loading, error, verificationId];
}
