import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:play5/core/utils/result.dart';
import 'package:play5/features/auth/domain/entities/auth_user.dart';
import 'package:play5/features/auth/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this.repository) : super(const AuthState()) {
    on<AuthSendOtp>(_onSendOtp);
    on<AuthVerifyOtp>(_onVerifyOtp);
    on<AuthLoggedOut>(_onLogout);
    on<AuthStatusChanged>(_onStatusChanged);
    _authSubscription = repository.authStateChanges().listen((user) {
      add(AuthStatusChanged(user));
    });
  }

  final AuthRepository repository;
  late final StreamSubscription<AuthUser?> _authSubscription;

  Future<void> _onSendOtp(AuthSendOtp event, Emitter<AuthState> emit) async {
    emit(state.copyWith(loading: true));
    final result = await repository.sendOtp(event.phoneNumber);
    if (result is Success<String>) {
      emit(state.copyWith(loading: false, verificationId: result.data));
    } else if (result is Failure<String>) {
      emit(state.copyWith(loading: false, error: result.message));
    }
  }

  Future<void> _onVerifyOtp(AuthVerifyOtp event, Emitter<AuthState> emit) async {
    emit(state.copyWith(loading: true));
    final result = await repository.verifyOtp(code: event.code);
    if (result is Success<AuthUser>) {
      emit(state.copyWith(user: result.data, status: AuthStatus.authenticated, loading: false));
    } else if (result is Failure<AuthUser>) {
      emit(state.copyWith(loading: false, error: result.message));
    }
  }

  Future<void> _onLogout(AuthLoggedOut event, Emitter<AuthState> emit) async {
    await repository.logout();
    emit(const AuthState());
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }

  void _onStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      user: event.user,
      status: event.user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated,
      loading: false,
    ));
  }
}
