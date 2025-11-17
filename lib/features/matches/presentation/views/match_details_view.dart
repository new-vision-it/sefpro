import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play5/core/localization/app_localizations.dart';
import 'package:play5/core/theme/app_colors.dart';
import 'package:play5/core/widgets/app_loader.dart';
import 'package:play5/core/widgets/app_scaffold.dart';
import 'package:play5/core/widgets/primary_button.dart';
import 'package:play5/core/widgets/secondary_button.dart';
import 'package:play5/features/matches/domain/entities/match_entity.dart';
import 'package:play5/features/matches/presentation/bloc/matches_bloc.dart';

class MatchDetailsView extends StatelessWidget {
  const MatchDetailsView({super.key, required this.matchId, required this.userId});

  final String matchId;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.t('matchDetails'),
      body: BlocBuilder<MatchesBloc, MatchesState>(
        builder: (context, state) {
          final match = state.matches.firstWhere((m) => m.id == matchId, orElse: () => MatchEntity(
                id: matchId,
                creatorId: '',
                pitchId: '',
                dateTimeStart: DateTime.now(),
                durationMinutes: 60,
                maxPlayers: 10,
                visibility: 'public',
                status: 'upcoming',
                playersJoined: const [],
                teamA: const [],
                teamB: const [],
              ));
          if (state.matches.isEmpty && state.status == MatchesStatus.loading) {
            return AppLoader(message: l10n.t('loading'));
          }
          final joined = match.playersJoined.contains(userId);
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(match.title ?? l10n.t('matchDetails'), style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 18, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text('${match.dateTimeStart}'),
                            const SizedBox(width: 12),
                            const Icon(Icons.timer_outlined, size: 18, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text('${match.durationMinutes} ${l10n.t('minutes')}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.group_outlined, size: 18, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text('${match.playersJoined.length}/${match.maxPlayers} ${l10n.t('players')}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (match.teamA.isNotEmpty || match.teamB.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _teamColumn(l10n.t('teamA'), match.teamA)),
                      Expanded(child: _teamColumn(l10n.t('teamB'), match.teamB)),
                    ],
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(l10n.t('teamBuilder'), style: Theme.of(context).textTheme.bodyLarge),
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (joined)
                      Expanded(
                        child: SecondaryButton(
                          label: l10n.t('leaveMatch'),
                          onPressed: () => context.read<MatchesBloc>().add(LeaveMatchRequested(matchId: match.id, userId: userId)),
                          icon: Icons.logout,
                        ),
                      )
                    else
                      Expanded(
                        child: PrimaryButton(
                          label: l10n.t('joinMatch'),
                          onPressed: match.playersJoined.length >= match.maxPlayers
                              ? null
                              : () => context.read<MatchesBloc>().add(JoinMatchRequested(matchId: match.id, userId: userId)),
                          icon: Icons.sports_soccer,
                        ),
                      ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _teamColumn(String title, List<String> ids) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...ids.map((e) => Text(e)).toList(),
      ],
    );
  }
}
