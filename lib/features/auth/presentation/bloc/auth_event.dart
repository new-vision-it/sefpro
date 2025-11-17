part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSendOtp extends AuthEvent {
  const AuthSendOtp(this.phoneNumber);
  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthVerifyOtp extends AuthEvent {
  const AuthVerifyOtp({required this.code});
  final String code;

  @override
  List<Object?> get props => [code];
}

class AuthLoggedOut extends AuthEvent {}

class AuthStatusChanged extends AuthEvent {
  const AuthStatusChanged(this.user);
  final AuthUser? user;
}
