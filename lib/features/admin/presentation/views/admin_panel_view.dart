import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play5/core/localization/app_localizations.dart';
import 'package:play5/features/pitches/domain/entities/pitch_entity.dart';
import 'package:play5/features/pitches/domain/repositories/pitch_repository.dart';
import 'package:uuid/uuid.dart';

class AdminPanelView extends StatelessWidget {
  const AdminPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = RepositoryProvider.of<PitchRepository>(context);
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.t('admin')),
          bottom: TabBar(tabs: [Tab(text: l10n.t('pitches')), Tab(text: l10n.t('matches'))]),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<List<PitchEntity>>(
              stream: repo.watchPitches(),
              builder: (context, snapshot) {
                final pitches = snapshot.data ?? [];
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: pitches.length,
                        itemBuilder: (context, index) {
                          final pitch = pitches[index];
                          return ListTile(
                            title: Text(pitch.name),
                            subtitle: Text(pitch.description ?? ''),
                            trailing: Switch(
                              value: pitch.isActive,
                              onChanged: (value) => repo.updatePitch(pitch.copyWith(isActive: value)),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final name = await _showCreatePitchDialog(context, l10n.t('pitchName'));
                          if (name != null && name.isNotEmpty) {
                            await repo.addPitch(PitchEntity(id: const Uuid().v4(), name: name));
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: Text(l10n.t('create')),
                      ),
                    ),
                  ],
                );
              },
            ),
            Center(child: Text(l10n.t('teamBuilder'))),
          ],
        ),
      ),
    );
  }

  Future<String?> _showCreatePitchDialog(BuildContext context, String label) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: TextField(controller: controller, decoration: InputDecoration(labelText: label)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
  }
}
