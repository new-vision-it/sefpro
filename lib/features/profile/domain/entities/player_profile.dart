import 'package:equatable/equatable.dart';

enum PreferredFoot { left, right, both }

enum PlayerRole { player, organizer, admin }

enum TimeWindow { morning, afternoon, night }

class PlayerProfile extends Equatable {
  const PlayerProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.preferredFoot,
    required this.positions,
    required this.skillLevel,
    required this.preferredDays,
    required this.preferredTimeWindows,
    this.phone = '',
    this.role = PlayerRole.player,
    this.isApproved = true,
  });

  final String id;
  final String name;
  final int age;
  final PreferredFoot preferredFoot;
  final List<String> positions;
  final int skillLevel;
  final List<String> preferredDays;
  final List<TimeWindow> preferredTimeWindows;
  final String phone;
  final PlayerRole role;
  final bool isApproved;

  PlayerProfile copyWith({
    String? name,
    int? age,
    PreferredFoot? preferredFoot,
    List<String>? positions,
    int? skillLevel,
    List<String>? preferredDays,
    List<TimeWindow>? preferredTimeWindows,
    String? phone,
    PlayerRole? role,
    bool? isApproved,
  }) {
    return PlayerProfile(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      preferredFoot: preferredFoot ?? this.preferredFoot,
      positions: positions ?? this.positions,
      skillLevel: skillLevel ?? this.skillLevel,
      preferredDays: preferredDays ?? this.preferredDays,
      preferredTimeWindows: preferredTimeWindows ?? this.preferredTimeWindows,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  @override
  List<Object?> get props => [id, name, age, preferredFoot, positions, skillLevel, preferredDays, preferredTimeWindows, phone, role, isApproved];
}
