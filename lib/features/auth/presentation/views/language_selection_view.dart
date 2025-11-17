import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play5/core/localization/app_localizations.dart';
import 'package:play5/core/localization/language_cubit.dart';

class LanguageSelectionView extends StatelessWidget {
  const LanguageSelectionView({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.t('appName'), style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                Text(l10n.t('authSlogan'), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<LanguageCubit>().change(const Locale('ar'));
                          onContinue();
                        },
                        child: Text(l10n.t('languageArabic')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<LanguageCubit>().change(const Locale('en'));
                          onContinue();
                        },
                        child: Text(l10n.t('languageEnglish')),
                      ),
                    ),
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
