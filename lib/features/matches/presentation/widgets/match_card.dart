import 'package:flutter/material.dart';
import 'package:play5/core/theme/app_colors.dart';
import 'package:play5/features/matches/domain/entities/match_entity.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({super.key, required this.match, required this.onTap, required this.isJoined});

  final MatchEntity match;
  final VoidCallback onTap;
  final bool isJoined;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'full':
        return Colors.grey;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return AppColors.success;
    }
  }

  String _statusLabel(String status) => status[0].toUpperCase() + status.substring(1);

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: 1,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match.title ?? '',
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Chip(
                      label: Text(_statusLabel(match.status)),
                      backgroundColor: _statusColor(match.status).withOpacity(0.15),
                      labelStyle: TextStyle(color: _statusColor(match.status), fontWeight: FontWeight.bold),
                      visualDensity: VisualDensity.compact,
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 18, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${match.dateTimeStart}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 18, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(match.pitchId, style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    const Icon(Icons.group_outlined, size: 18, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text('${match.playersJoined.length}/${match.maxPlayers}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    if (isJoined) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
