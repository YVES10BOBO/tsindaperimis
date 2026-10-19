import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import '../state/app_state.dart';
import 'info_screens.dart';
import 'main_shell.dart';
import 'password_screens.dart';

/// Kwinjira / Kwiyandikisha (UI gusa — nyuma bizahuzwa na API + JWT).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.isRegister});

  final bool isRegister;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _hidePassword = true;
  bool _loading = false;
  bool _awaitingEmailConfirmation = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading ||
        _awaitingEmailConfirmation ||
        !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = Supabase.instance.client.auth;
      final email = _email.text.trim().toLowerCase();
      if (widget.isRegister) {
        final result = await auth.signUp(
          email: email,
          password: _password.text,
          data: {'full_name': _name.text.trim()},
        );
        if (result.session == null) {
          setState(() {
            _awaitingEmailConfirmation = true;
            _loading = false;
          });
          return;
        }
      } else {
        await auth.signInWithPassword(email: email, password: _password.text);
      }
      if (!mounted) return;
      final name = (auth.currentUser?.userMetadata?['full_name'] as String?) ??
          (widget.isRegister ? _name.text : 'Umukoresha');
      AppScope.of(context).signIn(name, email: email);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => MainShell()),
        (Route<dynamic> route) => false,
      );
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (error) {
      if (mounted)
        setState(() => _error =
            'Ntibyashobotse kwinjira. Reba internet na Supabase Auth settings.');
      debugPrint('Supabase authentication failed: $error');
    } finally {
      if (mounted && _loading) setState(() => _loading = false);
    }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Uzuza aha' : null;

  @override
  Widget build(BuildContext context) {
    final bool reg = widget.isRegister;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: <Widget>[
              Text(
                  _awaitingEmailConfirmation
                      ? 'Reba email yawe'
                      : (reg ? 'Fungura konti' : 'Murakaza neza'),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Text(
                _awaitingEmailConfirmation
                    ? 'Twohereje umurongo wo kwemeza konti kuri ${_email.text.trim()}. Reba muri email yawe, ukande uwo murongo, hanyuma winjire.'
                    : reg
                        ? 'Iyandikishe kugira ngo iterambere ryawe ribikwe.'
                        : 'Injira ukomeze aho wari ugeze.',
                style: TextStyle(color: AppColors.muted, fontSize: 15),
              ),
              SizedBox(height: 28),
              if (reg && !_awaitingEmailConfirmation) ...<Widget>[
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Amazina yawe',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: _required,
                ),
                SizedBox(height: 14),
              ],
              if (!_awaitingEmailConfirmation)
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'urugero@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (String? v) {
                    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                        .hasMatch((v ?? '').trim())) {
                      return 'Andika email yemewe';
                    }
                    return null;
                  },
                ),
              if (!_awaitingEmailConfirmation) SizedBox(height: 14),
              if (!_awaitingEmailConfirmation)
                TextFormField(
                  controller: _password,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Ijambo ry\'ibanga',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _hidePassword ? 'Erekana' : 'Hisha',
                      icon: Icon(_hidePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                    ),
                  ),
                  validator: (String? v) =>
                      (v == null || v.length < 6) ? 'Nibura inyuguti 6' : null,
                ),
              if (!reg && !_awaitingEmailConfirmation)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const ForgotPasswordScreen()),
                    ),
                    child: Text('Wibagiwe ijambo ry\'ibanga?'),
                  ),
                ),
              SizedBox(height: 20),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              if (reg && !_awaitingEmailConfirmation) ...<Widget>[
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text('Kwiyandikisha byemeza ko wemeye ',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => const TermsScreen()),
                      ),
                      child: Text("Amategeko n'Amabwiriza",
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                    Text(' na ',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => const PrivacyScreen()),
                      ),
                      child: Text("Politiki y'Ibanga",
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                SizedBox(height: 12),
              ],
              if (!_awaitingEmailConfirmation)
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(reg ? 'Iyandikishe' : 'Injira'),
                ),
              if (_awaitingEmailConfirmation)
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                        builder: (_) => const AuthScreen(isRegister: false)),
                  ),
                  child: const Text('Nemeje email, injira'),
                ),
              if (!_awaitingEmailConfirmation) const SizedBox(height: 12),
              if (!_awaitingEmailConfirmation)
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                        builder: (_) => AuthScreen(isRegister: !reg)),
                  ),
                  child: Text(reg
                      ? 'Usanzwe ufite konti? Injira'
                      : 'Nta konti ufite? Iyandikishe'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
