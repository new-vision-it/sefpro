import 'package:flutter/material.dart';
import 'package:play5/core/theme/app_colors.dart';
import 'package:play5/features/profile/domain/entities/player_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final initials = profile.name.isNotEmpty
        ? profile.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'P5';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.gold.withOpacity(0.2),
              child: Text(initials, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Chip(
                        label: Text('${profile.skillLevel}/5'),
                        avatar: const Icon(Icons.star, color: AppColors.gold, size: 18),
                        backgroundColor: AppColors.gold.withOpacity(0.15),
                        labelStyle: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600),
                        visualDensity: VisualDensity.compact,
                      ),
                      ...profile.positions
                          .map((pos) => Chip(
                                label: Text(pos),
                                backgroundColor: Colors.grey.shade200,
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
