import 'package:flutter/material.dart';

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
  bool _hidePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final String name = widget.isRegister ? _name.text : 'Umukoresha';
    AppScope.of(context).signIn(name, phone: _phone.text);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => MainShell()),
      (Route<dynamic> route) => false,
    );
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
              Text(reg ? 'Fungura konti' : 'Murakaza neza',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Text(
                reg
                    ? 'Iyandikishe kugira ngo iterambere ryawe ribikwe.'
                    : 'Injira ukomeze aho wari ugeze.',
                style: TextStyle(color: AppColors.muted, fontSize: 15),
              ),
              SizedBox(height: 28),
              if (reg) ...<Widget>[
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
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Nimero ya telefoni',
                  hintText: '07X XXX XXXX',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (String? v) {
                  final String digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  if (digits.length < 10) return 'Andika nimero yuzuye';
                  return null;
                },
              ),
              SizedBox(height: 14),
              TextFormField(
                controller: _password,
                obscureText: _hidePassword,
                decoration: InputDecoration(
                  labelText: 'Ijambo ry\'ibanga',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _hidePassword ? 'Erekana' : 'Hisha',
                    icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                  ),
                ),
                validator: (String? v) =>
                    (v == null || v.length < 6) ? 'Nibura inyuguti 6' : null,
              ),
              if (!reg)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const ForgotPasswordScreen()),
                    ),
                    child: Text('Wibagiwe ijambo ry\'ibanga?'),
                  ),
                ),
              SizedBox(height: 20),
              if (reg) ...<Widget>[
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text('Kwiyandikisha byemeza ko wemeye ',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const TermsScreen()),
                      ),
                      child: Text("Amategeko n'Amabwiriza",
                          style: TextStyle(
                              color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                    Text(' na ', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const PrivacyScreen()),
                      ),
                      child: Text("Politiki y'Ibanga",
                          style: TextStyle(
                              color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                SizedBox(height: 12),
              ],
              ElevatedButton(
                onPressed: _submit,
                child: Text(reg ? 'Iyandikishe' : 'Injira'),
              ),
              SizedBox(height: 12),
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
