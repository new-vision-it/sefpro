part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded, empty, error }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.error,
  });

  final ProfileStatus status;
  final PlayerProfile? profile;
  final String? error;

  ProfileState copyWith({
    ProfileStatus? status,
    PlayerProfile? profile,
    String? error,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, profile, error];
}
