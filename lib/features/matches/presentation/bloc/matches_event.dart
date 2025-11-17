part of 'matches_bloc.dart';

abstract class MatchesEvent extends Equatable {
  const MatchesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMatches extends MatchesEvent {
  const LoadMatches();
}

class LoadMatchesCompleted extends MatchesEvent {
  const LoadMatchesCompleted(this.matches);
  final List<MatchEntity> matches;
}

class JoinMatchRequested extends MatchesEvent {
  const JoinMatchRequested({required this.matchId, required this.userId});
  final String matchId;
  final String userId;
}

class LeaveMatchRequested extends MatchesEvent {
  const LeaveMatchRequested({required this.matchId, required this.userId});
  final String matchId;
  final String userId;
}

class CreateMatchRequested extends MatchesEvent {
  const CreateMatchRequested(this.match);
  final MatchEntity match;
}
