import 'package:equatable/equatable.dart';

class PitchEntity extends Equatable {
  const PitchEntity({
    required this.id,
    required this.name,
    this.description,
    this.locationDescription,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? description;
  final String? locationDescription;
  final bool isActive;

  PitchEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? locationDescription,
    bool? isActive,
  }) {
    return PitchEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      locationDescription: locationDescription ?? this.locationDescription,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, description, locationDescription, isActive];
}
