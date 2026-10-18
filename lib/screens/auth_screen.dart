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
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  bool _hidePassword = true;
  bool _loading = false;
  bool _awaitingOtp = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    _otp.dispose();
    super.dispose();
  }

  String _normalizedPhone() {
    final input = _phone.text.trim();
    if (input.startsWith('+'))
      return '+${input.substring(1).replaceAll(RegExp(r'\D'), '')}';
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('250')) return '+$digits';
    if (digits.startsWith('0')) return '+25${digits}';
    return '+$digits';
  }

  Future<void> _submit() async {
    if (_loading ||
        (!_awaitingOtp && !(_formKey.currentState?.validate() ?? false)))
      return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = Supabase.instance.client.auth;
      final phone = _normalizedPhone();
      if (_awaitingOtp) {
        await auth.verifyOTP(
            phone: phone, token: _otp.text.trim(), type: OtpType.sms);
      } else if (widget.isRegister) {
        final result = await auth.signUp(
          phone: phone,
          password: _password.text,
          data: {'full_name': _name.text.trim()},
        );
        if (result.session == null) {
          setState(() {
            _awaitingOtp = true;
            _loading = false;
          });
          return;
        }
      } else {
        await auth.signInWithPassword(phone: phone, password: _password.text);
      }
      if (!mounted) return;
      final name = widget.isRegister ? _name.text : 'Umukoresha';
      AppScope.of(context).signIn(name, phone: phone);
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
                  _awaitingOtp
                      ? 'Emeza nimero ya telefoni'
                      : (reg ? 'Fungura konti' : 'Murakaza neza'),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Text(
                _awaitingOtp
                    ? 'Andika kode twohereje kuri telefoni yawe.'
                    : reg
                        ? 'Iyandikishe kugira ngo iterambere ryawe ribikwe.'
                        : 'Injira ukomeze aho wari ugeze.',
                style: TextStyle(color: AppColors.muted, fontSize: 15),
              ),
              SizedBox(height: 28),
              if (reg && !_awaitingOtp) ...<Widget>[
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
              if (!_awaitingOtp)
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nimero ya telefoni',
                    hintText: '07X XXX XXXX',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (String? v) {
                    final String digits =
                        (v ?? '').replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 10) return 'Andika nimero yuzuye';
                    return null;
                  },
                ),
              if (!_awaitingOtp) SizedBox(height: 14),
              if (_awaitingOtp)
                TextFormField(
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Kode ya SMS'),
                  validator: (v) => (v == null || v.trim().length < 4)
                      ? 'Andika kode wakiriye'
                      : null,
                ),
              if (!_awaitingOtp)
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
              if (!reg && !_awaitingOtp)
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
              if (reg && !_awaitingOtp) ...<Widget>[
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
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_awaitingOtp
                        ? 'Emeza'
                        : (reg ? 'Iyandikishe' : 'Injira')),
              ),
              if (!_awaitingOtp) const SizedBox(height: 12),
              if (!_awaitingOtp)
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
