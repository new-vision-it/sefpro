import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play5/core/localization/app_localizations.dart';
import 'package:play5/core/widgets/app_scaffold.dart';
import 'package:play5/core/widgets/primary_button.dart';
import 'package:play5/features/matches/domain/entities/match_entity.dart';
import 'package:play5/features/matches/presentation/bloc/matches_bloc.dart';
import 'package:uuid/uuid.dart';

class CreateMatchView extends StatefulWidget {
  const CreateMatchView({super.key, required this.userId});

  final String userId;

  @override
  State<CreateMatchView> createState() => _CreateMatchViewState();
}

class _CreateMatchViewState extends State<CreateMatchView> {
  DateTime _date = DateTime.now().add(const Duration(hours: 2));
  TimeOfDay _time = TimeOfDay.now();
  int _duration = 60;
  int _maxPlayers = 10;
  String _visibility = 'public';
  final _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.t('create_match_title'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.t('create_match_subtitle'), style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: l10n.t('match_title_label')),
                    ),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('${l10n.t('date')}: ${_date.toLocal().toString().split(' ').first}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (selected != null) setState(() => _date = selected);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text('${l10n.t('time')}: ${_time.format(context)}'),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final selected = await showTimePicker(context: context, initialTime: _time);
                          if (selected != null) setState(() => _time = selected);
                        },
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          value: _duration,
                          items: const [60, 90]
                              .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                              .toList(),
                          decoration: InputDecoration(labelText: l10n.t('duration')),
                          onChanged: (value) => setState(() => _duration = value ?? 60),
                        ),
                        const SizedBox(height: 12),
                        Text(l10n.t('maxPlayers'), style: Theme.of(context).textTheme.titleSmall),
                        Slider(
                          value: _maxPlayers.toDouble(),
                          min: 8,
                          max: 14,
                          divisions: 3,
                          label: _maxPlayers.toString(),
                          onChanged: (value) => setState(() => _maxPlayers = value.round()),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _visibility,
                          decoration: InputDecoration(labelText: l10n.t('visibility')),
                          items: ['public', 'private']
                              .map((v) => DropdownMenuItem(value: v, child: Text(l10n.t(v))))
                              .toList(),
                          onChanged: (value) => setState(() => _visibility = value ?? 'public'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: l10n.t('create'),
            onPressed: () {
              final dateTime = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
              final match = MatchEntity(
                id: const Uuid().v4(),
                creatorId: widget.userId,
                pitchId: 'pitch-1',
                dateTimeStart: dateTime,
                durationMinutes: _duration,
                maxPlayers: _maxPlayers,
                visibility: _visibility,
                status: 'upcoming',
                playersJoined: [widget.userId],
                teamA: const [],
                teamB: const [],
                title: _titleController.text.isEmpty ? l10n.t('matchDetails') : _titleController.text,
              );
              context.read<MatchesBloc>().add(CreateMatchRequested(match));
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}
