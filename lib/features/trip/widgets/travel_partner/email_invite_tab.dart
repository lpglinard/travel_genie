import 'package:flutter/material.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

/// Email invite tab content
/// Follows Single Responsibility Principle - only handles email invitation form
class EmailInviteTab extends StatefulWidget {
  const EmailInviteTab({super.key});

  @override
  State<EmailInviteTab> createState() => _EmailInviteTabState();
}

class _EmailInviteTabState extends State<EmailInviteTab> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.emailAddress,
                hintText: AppLocalizations.of(context)!.enterFriendEmail,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.pleaseEnterEmailAddress;
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return AppLocalizations.of(
                    context,
                  )!.pleaseEnterValidEmailAddress;
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _sendInvite,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B6EFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.sendInvitation,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendInvite() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invitationSentTo(email)),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
