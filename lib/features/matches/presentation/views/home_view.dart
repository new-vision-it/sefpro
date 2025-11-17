import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:play5/core/localization/app_localizations.dart';
import 'package:play5/core/widgets/app_loader.dart';
import 'package:play5/core/widgets/app_scaffold.dart';
import 'package:play5/core/widgets/empty_state.dart';
import 'package:play5/features/matches/domain/entities/match_entity.dart';
import 'package:play5/features/matches/presentation/bloc/matches_bloc.dart';
import 'package:play5/features/matches/presentation/widgets/filter_chips_row.dart';
import 'package:play5/features/matches/presentation/widgets/match_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.onCreateMatch, required this.onOpenProfile, required this.onOpenAdmin, required this.isAdmin, required this.userId});

  final VoidCallback onCreateMatch;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenAdmin;
  final bool isAdmin;
  final String userId;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _selectedFilter = '';

  @override
  void initState() {
    super.initState();
    context.read<MatchesBloc>().add(const LoadMatches());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedFilter = AppLocalizations.of(context).t('all');
  }

  Future<void> _refresh() async {
    context.read<MatchesBloc>().add(const LoadMatches());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        title: l10n.t('home_title'),
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: widget.onOpenProfile),
          if (widget.isAdmin)
            IconButton(icon: const Icon(Icons.admin_panel_settings), onPressed: widget.onOpenAdmin),
        ],
        floatingActionButton: FloatingActionButton(
          onPressed: widget.onCreateMatch,
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context).colorScheme.secondary,
                  tabs: [
                    Tab(text: l10n.t('upcomingMatches')),
                    Tab(text: l10n.t('myMatches')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilterChipsRow(
              options: [l10n.t('all'), l10n.t('open'), l10n.t('full')],
              selected: _selectedFilter,
              onSelected: (value) => setState(() => _selectedFilter = value),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<MatchesBloc, MatchesState>(
                builder: (context, state) {
                  if (state.status == MatchesStatus.loading && state.matches.isEmpty) {
                    return AppLoader(message: l10n.t('loading'));
                  }
                  final myMatches = state.matches.where((m) => m.playersJoined.contains(widget.userId)).toList();
                  final List<MatchEntity> filtered = state.matches.where((m) {
                    if (_selectedFilter == l10n.t('open')) {
                      return m.status.toLowerCase() == 'upcoming';
                    }
                    if (_selectedFilter == l10n.t('full')) {
                      return m.status.toLowerCase() == 'full';
                    }
                    return true;
                  }).toList();

                  if (state.matches.isEmpty) {
                    return EmptyState(
                      title: l10n.t('matches_empty_title'),
                      subtitle: l10n.t('matches_empty_subtitle'),
                      actionLabel: l10n.t('createMatch'),
                      onAction: widget.onCreateMatch,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: TabBarView(
                      children: [
                        _MatchList(matches: filtered, userId: widget.userId),
                        _MatchList(matches: myMatches, userId: widget.userId),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchList extends StatelessWidget {
  const _MatchList({required this.matches, required this.userId});

  final List<MatchEntity> matches;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (matches.isEmpty) {
      return EmptyState(
        title: l10n.t('matches_empty_title'),
        subtitle: l10n.t('matches_empty_subtitle'),
      );
    }
    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return MatchCard(
          match: match,
          isJoined: match.playersJoined.contains(userId),
          onTap: () => context.push('/match/${match.id}'),
        );
      },
    );
  }
}
