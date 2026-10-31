import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'welcome_screen.dart';

/// Gusiba konti burundu. Google Play isaba ko umukoresha abyikorera muri app.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  bool _understood = false;
  bool _deleting = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_deleting ||
        !_understood ||
        !(_formKey.currentState?.validate() ?? false)) return;
    final AppState state = AppScope.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    setState(() {
      _deleting = true;
      _error = null;
    });
    try {
      final client = Supabase.instance.client;
      final String? email = client.auth.currentUser?.email;
      if (email == null) {
        setState(() => _error =
            'Banza winjire muri konti yawe, hanyuma wongere ugerageze.');
        return;
      }
      // Asking for the password again stops anyone holding an unlocked phone
      // from deleting the owner's account.
      await client.auth.signInWithPassword(
          email: email, password: _password.text);
      await client.rpc('delete_my_account');
      await state.forgetDeletedAccount();
      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => WelcomeScreen()),
        (Route<dynamic> r) => false,
      );
      messenger.showSnackBar(
        SnackBar(content: Text('Konti yawe yasibwe burundu.')),
      );
    } on AuthException catch (error) {
      if (mounted) {
        setState(() => _error =
            error.code == 'invalid_credentials' || error.statusCode == '400'
                ? 'Ijambo ry\'ibanga si ryo.'
                : error.message);
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        setState(() => _error = switch (error.code) {
              '42501' => 'Konti ya admin ntishobora gusibwa muri app.',
              'PGRST202' =>
                'Iki gikorwa ntikiraboneka kuri seriveri. Twandikire tugusibire konti.',
              _ => 'Gusiba konti ntibyakunze: ${error.message}',
            });
      }
    } catch (error) {
      debugPrint('Account deletion failed: $error');
      if (mounted) {
        setState(() =>
            _error = 'Ntibyakunze. Reba internet, hanyuma wongere ugerageze.');
      }
    } finally {
      if (mounted && _deleting) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Siba konti')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: <Widget>[
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 48),
              SizedBox(height: 12),
              Text('Gusiba konti ni burundu',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Text(
                'Nyuma yo gusiba, ntibishobora gusubizwa. Ibi bikurikira birasibwa:',
                style: TextStyle(color: AppColors.muted, height: 1.5),
              ),
              SizedBox(height: 16),
              AppCard(
                child: Column(
                  children: <Widget>[
                    _DeletedItem(
                        icon: Icons.person_off_outlined,
                        text: 'Konti yawe n\'email yayo'),
                    _DeletedItem(
                        icon: Icons.cloud_off_outlined,
                        text:
                            'Iterambere ryawe ribitswe kuri seriveri: amasomo warangije, ibisubizo n\'ibizamini'),
                    _DeletedItem(
                        icon: Icons.phone_android,
                        text: 'Iterambere n\'ibyo wabitse kuri iyi telefoni'),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Ushobora gukomeza gukoresha app nka mushyitsi, cyangwa ugafungura konti nshya igihe cyose.',
                style: TextStyle(color: AppColors.muted, height: 1.5),
              ),
              SizedBox(height: 24),
              PasswordField(
                controller: _password,
                label: 'Ijambo ry\'ibanga ryawe (kugira ngo wemeze)',
                validator: (String? v) => (v == null || v.isEmpty)
                    ? 'Andika ijambo ry\'ibanga'
                    : null,
              ),
              SizedBox(height: 8),
              CheckboxListTile(
                value: _understood,
                onChanged: _deleting
                    ? null
                    : (bool? v) => setState(() => _understood = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                    'Ndabyumva ko konti yanjye n\'iterambere ryanjye bizasibwa burundu.'),
              ),
              if (_error != null) ...<Widget>[
                SizedBox(height: 8),
                Text(_error!,
                    style: TextStyle(
                        color: AppColors.error, fontWeight: FontWeight.w600)),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white),
                onPressed: _understood && !_deleting ? _delete : null,
                child: _deleting
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text('Siba konti burundu'),
              ),
              SizedBox(height: 10),
              OutlinedButton(
                onPressed:
                    _deleting ? null : () => Navigator.of(context).pop(),
                child: Text('Reka, singisiba'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeletedItem extends StatelessWidget {
  const _DeletedItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.error),
          SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}
