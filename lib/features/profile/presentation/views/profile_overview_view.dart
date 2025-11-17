import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play5/core/localization/app_localizations.dart';
import 'package:play5/core/widgets/app_scaffold.dart';
import 'package:play5/core/widgets/primary_button.dart';
import 'package:play5/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:play5/features/profile/presentation/widgets/profile_header.dart';

class ProfileOverviewView extends StatelessWidget {
  const ProfileOverviewView({super.key, required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.t('profile'),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final profile = state.profile;
          if (profile == null) {
            return Center(child: Text(l10n.t('pendingApproval')));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(profile: profile),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.t('player_info'), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('${l10n.t('age')}: ${profile.age}'),
                      Text('${l10n.t('preferredFoot')}: ${profile.preferredFoot.name}'),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.t('preferences'), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 4, children: profile.positions.map((p) => Chip(label: Text(p))).toList()),
                      const SizedBox(height: 8),
                      Text('${l10n.t('preferredDays')}: ${profile.preferredDays.join(', ')}'),
                      Text('${l10n.t('preferredTimes')}: ${profile.preferredTimeWindows.join(', ')}'),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(onPressed: onEdit, label: l10n.t('editProfile')),
            ],
          );
        },
      ),
    );
  }
}
