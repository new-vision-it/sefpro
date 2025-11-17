import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:play5/core/utils/result.dart';
import 'package:play5/features/matches/domain/entities/match_entity.dart';
import 'package:play5/features/matches/domain/repositories/match_repository.dart';

part 'matches_event.dart';
part 'matches_state.dart';

class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  MatchesBloc({required this.repository}) : super(const MatchesState()) {
    on<LoadMatches>(_onLoad);
    on<LoadMatchesCompleted>(_onLoaded);
    on<JoinMatchRequested>(_onJoinMatch);
    on<LeaveMatchRequested>(_onLeaveMatch);
    on<CreateMatchRequested>(_onCreateMatch);
  }

  final MatchRepository repository;
  StreamSubscription<List<MatchEntity>>? _matchesSubscription;

  Future<void> _onLoad(LoadMatches event, Emitter<MatchesState> emit) async {
    emit(state.copyWith(status: MatchesStatus.loading));
    await _matchesSubscription?.cancel();
    _matchesSubscription = repository.watchUpcomingMatches().listen((matches) {
      add(LoadMatchesCompleted(matches));
    });
  }

  void _onLoaded(LoadMatchesCompleted event, Emitter<MatchesState> emit) {
    emit(state.copyWith(status: MatchesStatus.loaded, matches: event.matches));
  }

  Future<void> _onJoinMatch(JoinMatchRequested event, Emitter<MatchesState> emit) async {
    final result = await repository.joinMatch(matchId: event.matchId, userId: event.userId);
    if (result is Failure<MatchEntity>) {
      emit(state.copyWith(error: result.message));
    }
  }

  Future<void> _onLeaveMatch(LeaveMatchRequested event, Emitter<MatchesState> emit) async {
    final result = await repository.leaveMatch(matchId: event.matchId, userId: event.userId);
    if (result is Failure<MatchEntity>) {
      emit(state.copyWith(error: result.message));
    }
  }

  Future<void> _onCreateMatch(CreateMatchRequested event, Emitter<MatchesState> emit) async {
    emit(state.copyWith(status: MatchesStatus.loading));
    final result = await repository.createMatch(event.match);
    if (result is Failure<MatchEntity>) {
      emit(state.copyWith(status: MatchesStatus.error, error: result.message));
    }
  }

  @override
  Future<void> close() {
    _matchesSubscription?.cancel();
    return super.close();
  }
}
