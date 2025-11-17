import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play5/config/app_config.dart';
import 'package:play5/core/firebase/firebase_initializer.dart';
import 'package:play5/core/localization/app_localizations.dart';
import 'package:play5/core/localization/language_cubit.dart';
import 'package:play5/core/theme/app_theme.dart';
import 'package:play5/features/admin/presentation/views/admin_panel_view.dart';
import 'package:play5/features/auth/data/firebase_auth_repository.dart';
import 'package:play5/features/auth/data/mock_auth_repository.dart';
import 'package:play5/features/auth/domain/repositories/auth_repository.dart';
import 'package:play5/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:play5/features/auth/presentation/views/language_selection_view.dart';
import 'package:play5/features/auth/presentation/views/otp_view.dart';
import 'package:play5/features/auth/presentation/views/phone_input_view.dart';
import 'package:play5/features/matches/data/firebase_match_repository.dart';
import 'package:play5/features/matches/data/mock_match_repository.dart';
import 'package:play5/features/matches/presentation/bloc/matches_bloc.dart';
import 'package:play5/features/matches/presentation/views/create_match_view.dart';
import 'package:play5/features/matches/presentation/views/home_view.dart';
import 'package:play5/features/matches/presentation/views/match_details_view.dart';
import 'package:play5/features/profile/data/firebase_profile_repository.dart';
import 'package:play5/features/profile/data/mock_profile_repository.dart';
import 'package:play5/features/profile/domain/repositories/profile_repository.dart';
import 'package:play5/features/profile/domain/entities/player_profile.dart';
import 'package:play5/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:play5/features/profile/presentation/views/profile_form_view.dart';
import 'package:play5/features/profile/presentation/views/profile_overview_view.dart';
import 'package:play5/features/pitches/data/firebase_pitch_repository.dart';
import 'package:play5/features/pitches/data/mock_pitch_repository.dart';
import 'package:play5/features/pitches/domain/repositories/pitch_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!AppConfig.useMockData) {
    await initFirebase();
  }
  runApp(const Play5App());
}

class Play5App extends StatelessWidget {
  const Play5App({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AppConfig.useMockData ? MockAuthRepository() : FirebaseAuthRepository();
    final profileRepository = AppConfig.useMockData ? MockProfileRepository() : FirebaseProfileRepository();
    final pitchRepository = AppConfig.useMockData ? MockPitchRepository() : FirebasePitchRepository();
    final matchRepository = AppConfig.useMockData
        ? MockMatchRepository(profileRepository)
        : FirebaseMatchRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<ProfileRepository>.value(value: profileRepository),
        RepositoryProvider<PitchRepository>.value(value: pitchRepository),
        RepositoryProvider.value(value: matchRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LanguageCubit()),
          BlocProvider(create: (_) => AuthBloc(authRepository)),
          BlocProvider(create: (_) => ProfileBloc(repository: profileRepository)),
          BlocProvider(create: (_) => MatchesBloc(repository: matchRepository)),
        ],
        child: BlocBuilder<LanguageCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp(
              title: 'Play5',
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: AppTheme.lightTheme(locale),
              darkTheme: AppTheme.darkTheme(locale),
              themeMode: ThemeMode.light,
              builder: (context, child) {
                final direction = locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
                return Directionality(textDirection: direction, child: child ?? const SizedBox.shrink());
              },
              home: const AppFlow(),
            );
          },
        ),
      ),
    );
  }
}

class AppFlow extends StatefulWidget {
  const AppFlow({super.key});

  @override
  State<AppFlow> createState() => _AppFlowState();
}

class _AppFlowState extends State<AppFlow> {
  bool _languageSelected = false;
  bool _awaitingOtp = false;
  String? _phone;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated && state.user != null) {
          context.read<ProfileBloc>().add(LoadProfile(state.user!.id));
        }
      },
      builder: (context, state) {
        if (!_languageSelected) {
          return LanguageSelectionView(onContinue: () => setState(() => _languageSelected = true));
        }
        if (state.status == AuthStatus.unauthenticated) {
          if (_awaitingOtp && _phone != null) {
            return OtpView(
              phoneNumber: _phone!,
              onVerified: () => setState(() => _awaitingOtp = false),
            );
          }
          return PhoneInputView(
            onOtpSent: (phone) {
              setState(() {
                _phone = phone;
                _awaitingOtp = true;
              });
            },
          );
        }
        final userId = state.user!.id;
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            if (profileState.status == ProfileStatus.initial || profileState.status == ProfileStatus.empty) {
              return ProfileFormView(
                userId: userId,
                onSaved: () => context.read<ProfileBloc>().add(LoadProfile(userId)),
              );
            }
            if (profileState.status == ProfileStatus.loading && profileState.profile == null) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final profile = profileState.profile;
            return HomeView(
              userId: userId,
              onCreateMatch: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateMatchView(userId: userId))),
              onOpenProfile: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProfileOverviewView(
                        onEdit: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ProfileFormView(
                                userId: userId,
                                onSaved: () {
                                  context.read<ProfileBloc>().add(LoadProfile(userId));
                                  Navigator.pop(context);
                                },
                              ),
                            )),
                      ))),
              onOpenAdmin: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminPanelView())),
              isAdmin: profile?.role == PlayerRole.admin,
            );
          },
        );
      },
    );
  }
}

// Example navigator extensions for match details.
extension MatchNavigation on BuildContext {
  void openMatchDetails(String matchId, String userId) {
    Navigator.of(this).push(MaterialPageRoute(builder: (_) => MatchDetailsView(matchId: matchId, userId: userId)));
  }
}
