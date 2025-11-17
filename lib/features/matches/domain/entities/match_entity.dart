import 'package:equatable/equatable.dart';

class MatchEntity extends Equatable {
  const MatchEntity({
    required this.id,
    required this.creatorId,
    required this.pitchId,
    required this.dateTimeStart,
    required this.durationMinutes,
    required this.maxPlayers,
    required this.visibility,
    required this.status,
    required this.playersJoined,
    required this.teamA,
    required this.teamB,
    this.title,
  });

  final String id;
  final String creatorId;
  final String pitchId;
  final DateTime dateTimeStart;
  final int durationMinutes;
  final int maxPlayers;
  final String visibility; // public or private
  final String status; // upcoming/full/in-progress/finished/cancelled
  final List<String> playersJoined;
  final List<String> teamA;
  final List<String> teamB;
  final String? title;

  MatchEntity copyWith({
    String? id,
    String? creatorId,
    String? pitchId,
    DateTime? dateTimeStart,
    int? durationMinutes,
    int? maxPlayers,
    String? visibility,
    String? status,
    List<String>? playersJoined,
    List<String>? teamA,
    List<String>? teamB,
    String? title,
  }) {
    return MatchEntity(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      pitchId: pitchId ?? this.pitchId,
      dateTimeStart: dateTimeStart ?? this.dateTimeStart,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      playersJoined: playersJoined ?? this.playersJoined,
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      title: title ?? this.title,
    );
  }

  @override
  List<Object?> get props => [id, creatorId, pitchId, dateTimeStart, durationMinutes, maxPlayers, visibility, status, playersJoined, teamA, teamB, title];
}
