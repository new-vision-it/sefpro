import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:play5/core/utils/result.dart';
import 'package:play5/features/profile/domain/entities/player_profile.dart';
import 'package:play5/features/profile/domain/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required this.repository}) : super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<SaveProfile>(_onSaveProfile);
    on<ProfileUpdated>(_onProfileUpdated);
    on<ProfileNotFound>(_onProfileNotFound);
  }

  final ProfileRepository repository;
  StreamSubscription<PlayerProfile?>? _profileSubscription;

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    await _profileSubscription?.cancel();
    _profileSubscription = repository.watchProfile(event.userId).listen((profile) {
      if (profile == null) {
        add(ProfileNotFound());
      } else {
        add(ProfileUpdated(profile));
      }
    });
  }

  Future<void> _onSaveProfile(SaveProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await repository.createOrUpdateProfile(event.profile);
    if (result is Success<PlayerProfile>) {
      emit(state.copyWith(status: ProfileStatus.loaded, profile: result.data));
    } else if (result is Failure<PlayerProfile>) {
      emit(state.copyWith(status: ProfileStatus.error, error: result.message));
    }
  }

  void _onProfileUpdated(ProfileUpdated event, Emitter<ProfileState> emit) {
    emit(state.copyWith(status: ProfileStatus.loaded, profile: event.profile));
  }

  void _onProfileNotFound(ProfileNotFound event, Emitter<ProfileState> emit) {
    emit(state.copyWith(status: ProfileStatus.empty, profile: null));
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
