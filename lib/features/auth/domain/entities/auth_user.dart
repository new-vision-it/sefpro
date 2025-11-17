import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.phone,
    required this.isNew,
    this.isAdmin = false,
    this.isOrganizer = false,
    this.isApproved = true,
  });

  final String id;
  final String phone;
  final bool isNew;
  final bool isAdmin;
  final bool isOrganizer;
  final bool isApproved;

  @override
  List<Object?> get props => [id, phone, isNew, isAdmin, isOrganizer, isApproved];
}
