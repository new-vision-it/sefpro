import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play5/core/localization/app_localizations.dart';
import 'package:play5/core/widgets/app_scaffold.dart';
import 'package:play5/core/widgets/primary_button.dart';
import 'package:play5/features/auth/presentation/bloc/auth_bloc.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key, required this.phoneNumber, required this.onVerified});

  final String phoneNumber;
  final VoidCallback onVerified;

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.t('otpCode'),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            widget.onVerified();
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.t('otpCode'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: state.loading ? l10n.t('loading') : l10n.t('verify'),
                onPressed: state.loading
                    ? null
                    : () => context.read<AuthBloc>().add(AuthVerifyOtp(code: _controller.text)),
              ),
            ],
          );
        },
      ),
    );
  }
}
