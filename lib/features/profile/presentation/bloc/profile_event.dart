part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile(this.userId);
  final String userId;
}

class ProfileUpdated extends ProfileEvent {
  const ProfileUpdated(this.profile);
  final PlayerProfile profile;
}

class ProfileNotFound extends ProfileEvent {
  const ProfileNotFound();
}

class SaveProfile extends ProfileEvent {
  const SaveProfile(this.profile);
  final PlayerProfile profile;
}
