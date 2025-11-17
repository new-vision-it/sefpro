import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play5/core/localization/app_localizations.dart';
import 'package:play5/core/widgets/app_scaffold.dart';
import 'package:play5/core/widgets/primary_button.dart';
import 'package:play5/features/auth/presentation/bloc/auth_bloc.dart';

class PhoneInputView extends StatefulWidget {
  const PhoneInputView({super.key, required this.onOtpSent});

  final void Function(String phoneNumber) onOtpSent;

  @override
  State<PhoneInputView> createState() => _PhoneInputViewState();
}

class _PhoneInputViewState extends State<PhoneInputView> {
  final _controller = TextEditingController();
  bool _codeSent = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.t('phoneNumber'),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
          if (state.verificationId != null && !_codeSent) {
            _codeSent = true;
            widget.onOtpSent(_controller.text);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.t('authSlogan'), style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: l10n.t('phoneNumber'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: state.loading ? l10n.t('loading') : l10n.t('sendCode'),
                onPressed: state.loading
                    ? null
                    : () {
                        context.read<AuthBloc>().add(AuthSendOtp(_controller.text));
                      },
              ),
            ],
          );
        },
      ),
    );
  }
}
