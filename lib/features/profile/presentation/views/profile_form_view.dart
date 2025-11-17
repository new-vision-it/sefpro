import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play5/core/localization/app_localizations.dart';
import 'package:play5/core/widgets/primary_button.dart';
import 'package:play5/features/profile/domain/entities/player_profile.dart';
import 'package:play5/features/profile/presentation/bloc/profile_bloc.dart';

class ProfileFormView extends StatefulWidget {
  const ProfileFormView({super.key, required this.userId, required this.onSaved});

  final String userId;
  final VoidCallback onSaved;

  @override
  State<ProfileFormView> createState() => _ProfileFormViewState();
}

class _ProfileFormViewState extends State<ProfileFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '25');
  PreferredFoot _foot = PreferredFoot.right;
  int _skill = 3;
  final List<String> _positions = [];
  final List<String> _days = [];
  final List<TimeWindow> _times = [];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('createProfile'))),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.loaded) {
            widget.onSaved();
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: l10n.t('fullName')),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(labelText: l10n.t('age')),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PreferredFoot>(
                    value: _foot,
                    decoration: InputDecoration(labelText: l10n.t('preferredFoot')),
                    items: PreferredFoot.values
                        .map((f) => DropdownMenuItem(value: f, child: Text(l10n.t(f.name))))
                        .toList(),
                    onChanged: (value) => setState(() => _foot = value ?? PreferredFoot.right),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.t('preferredPositions')),
                  Wrap(
                    spacing: 8,
                    children: ['GK', 'DEF', 'MID', 'ATT']
                        .map((p) => FilterChip(
                              label: Text(p),
                              selected: _positions.contains(p),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _positions.add(p);
                                  } else {
                                    _positions.remove(p);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text('${l10n.t('skillLevel')}: $_skill'),
                  Slider(
                    value: _skill.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (value) => setState(() => _skill = value.round()),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.t('preferredDays')),
                  Wrap(
                    spacing: 8,
                    children: ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri']
                        .map((d) => FilterChip(
                              label: Text(d),
                              selected: _days.contains(d),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _days.add(d);
                                  } else {
                                    _days.remove(d);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.t('preferredTimes')),
                  Wrap(
                    spacing: 8,
                    children: TimeWindow.values
                        .map((t) => FilterChip(
                              label: Text(l10n.t(t.name)),
                              selected: _times.contains(t),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _times.add(t);
                                  } else {
                                    _times.remove(t);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: state.status == ProfileStatus.loading ? l10n.t('loading') : l10n.t('save'),
                    onPressed: state.status == ProfileStatus.loading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              final profile = PlayerProfile(
                                id: widget.userId,
                                name: _nameController.text,
                                age: int.tryParse(_ageController.text) ?? 18,
                                preferredFoot: _foot,
                                positions: _positions.isEmpty ? ['MID'] : _positions,
                                skillLevel: _skill,
                                preferredDays: _days,
                                preferredTimeWindows: _times,
                              );
                              context.read<ProfileBloc>().add(SaveProfile(profile));
                            }
                          },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
