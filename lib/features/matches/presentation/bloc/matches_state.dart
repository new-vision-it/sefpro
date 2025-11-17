part of 'matches_bloc.dart';

enum MatchesStatus { initial, loading, loaded, error }

class MatchesState extends Equatable {
  const MatchesState({
    this.status = MatchesStatus.initial,
    this.matches = const [],
    this.error,
  });

  final MatchesStatus status;
  final List<MatchEntity> matches;
  final String? error;

  MatchesState copyWith({
    MatchesStatus? status,
    List<MatchEntity>? matches,
    String? error,
  }) {
    return MatchesState(
      status: status ?? this.status,
      matches: matches ?? this.matches,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, matches, error];
}
