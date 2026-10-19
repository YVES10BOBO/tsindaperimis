import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';

// Ibi byose ni UI gusa. Nyuma bizahuzwa na backend:
//   POST /auth/forgot-password  { phone }          -> yohereza SMS ifite kode
//   POST /auth/verify-otp       { phone, code }    -> isubiza reset token
//   POST /auth/reset-password   { token, password }
//   POST /auth/change-password  { current, new }   (umukoresha winjiye)

String? validatePhone(String? v) {
  final String digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.length < 10) return 'Andika nimero ya telefoni yuzuye';
  return null;
}

String? validateNewPassword(String? v) {
  final String p = v ?? '';
  if (p.length < 8) return 'Nibura inyuguti 8';
  if (!RegExp(r'[A-Za-z]').hasMatch(p)) return 'Shyiramo nibura inyuguti imwe';
  if (!RegExp(r'\d').hasMatch(p)) return 'Shyiramo nibura umubare umwe';
  return null;
}

String maskPhone(String phone) {
  final String d = phone.replaceAll(RegExp(r'\D'), '');
  if (d.length < 4) return phone;
  return '${d.substring(0, 3)} *** ** ${d.substring(d.length - 2)}';
}

/// Umutwe uri hejuru ya buri paji y'ijambo ry'ibanga.
class _Header extends StatelessWidget {
  const _Header(
      {required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IconBadge(
          icon: icon,
          color: AppColors.primary,
          background: AppColors.primarySoft,
          size: 60,
        ),
        const SizedBox(height: 20),
        Text(title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(subtitle,
            style:
                TextStyle(color: AppColors.muted, fontSize: 15, height: 1.45)),
        const SizedBox(height: 28),
      ],
    );
  }
}

/// Igipimo cy'imbaraga z'ijambo ry'ibanga.
class PasswordStrength extends StatelessWidget {
  const PasswordStrength({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password) || password.length >= 12)
      score++;

    final List<String> labels = <String>[
      'Rifite intege nke cyane',
      'Rifite intege nke',
      'Riraringaniye',
      'Rikomeye',
      'Rikomeye cyane'
    ];
    final List<Color> colors = <Color>[
      AppColors.error,
      AppColors.error,
      AppColors.warning,
      AppColors.success,
      AppColors.success
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (int i = 0; i < 4; i++) ...<Widget>[
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: i < score ? colors[score] : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              if (i < 3) const SizedBox(width: 6),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          password.isEmpty
              ? 'Nibura inyuguti 8, harimo inyuguti n\'umubare'
              : labels[score],
          style: TextStyle(
            fontSize: 12.5,
            color: password.isEmpty ? AppColors.muted : colors[score],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// 1. Wibagiwe ijambo ry'ibanga: saba reset link kuri email
// =====================================================================
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  bool _sending = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth
          .resetPasswordForEmail(_email.text.trim().toLowerCase());
      if (mounted) setState(() => _sent = true);
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Ntibyashobotse kohereza email.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: <Widget>[
              _Header(
                icon: Icons.lock_reset,
                title: 'Wibagiwe ijambo ry\'ibanga?',
                subtitle: _sent
                    ? 'Niba iyi email ifite konti, twohereje umurongo wo guhindura ijambo ry\'ibanga. Reba muri inbox no muri spam.'
                    : 'Andika email wakoresheje wiyandikisha. Turakoherereza umurongo wo guhindura ijambo ry\'ibanga.',
              ),
              if (!_sent) ...[
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'urugero@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                          .hasMatch((value ?? '').trim())
                      ? null
                      : 'Andika email yemewe',
                  onFieldSubmitted: (_) => _send(),
                ),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                ],
                ElevatedButton(
                  onPressed: _sending ? null : _send,
                  child: _sending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Ohereza umurongo'),
                ),
              ],
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Wibutse ijambo ry\'ibanga? Injira'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// 2. Andika kode wahawe kuri SMS
// =====================================================================
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _length = 6;
  static const int _resendSeconds = 60;

  final TextEditingController _code = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  bool _verifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() {});
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _resend() {
    // TODO: hamagara API yongere yohereze kode
    setState(_startTimer);
    showComingSoon(
        context, 'Kode nshya yoherejwe kuri ${maskPhone(widget.phone)}');
  }

  Future<void> _verify() async {
    if (_verifying) return;
    if (_code.text.length != _length) {
      setState(() => _error = 'Andika imibare yose uko ari 6');
      return;
    }
    setState(() {
      _error = null;
      _verifying = true;
    });
    await Future<void>.delayed(
        const Duration(milliseconds: 800)); // TODO: hamagara API
    if (!mounted) return;
    setState(() => _verifying = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
          builder: (_) => ResetPasswordScreen(phone: widget.phone)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String code = _code.text;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: <Widget>[
            _Header(
              icon: Icons.sms_outlined,
              title: 'Andika kode',
              subtitle:
                  'Twohereje kode y\'imibare 6 kuri ${maskPhone(widget.phone)}.',
            ),
            // Utuzu 6 tugaragaza imibare; TextField nyayo irihishe inyuma.
            GestureDetector(
              onTap: () => _focus.requestFocus(),
              child: Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      for (int i = 0; i < _length; i++) ...<Widget>[
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 0.85,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _error != null
                                      ? AppColors.error
                                      : (i == code.length && _focus.hasFocus
                                          ? AppColors.primary
                                          : AppColors.border),
                                  width: i == code.length && _focus.hasFocus
                                      ? 2
                                      : 1.2,
                                ),
                              ),
                              child: Text(
                                i < code.length ? code[i] : '',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                        if (i < _length - 1) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0,
                      child: TextField(
                        controller: _code,
                        focusNode: _focus,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        maxLength: _length,
                        showCursor: false,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(counterText: ''),
                        onChanged: (String v) {
                          setState(() => _error = null);
                          if (v.length == _length) _verify();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 10),
              Text(_error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _verifying ? null : _verify,
              child: _verifying
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Emeza kode'),
            ),
            const SizedBox(height: 16),
            Center(
              child: _secondsLeft > 0
                  ? Text(
                      'Ushobora gusaba indi kode nyuma y\'amasegonda $_secondsLeft',
                      style: TextStyle(color: AppColors.muted),
                    )
                  : TextButton(
                      onPressed: _resend,
                      child: const Text('Ntiwabonye kode? Ohereza indi'),
                    ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hindura nimero ya telefoni'),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// 3. Shyiraho ijambo ry'ibanga rishya
// =====================================================================
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.phone});

  final String phone;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    await Future<void>.delayed(
        const Duration(milliseconds: 900)); // TODO: hamagara API
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
          builder: (_) => const PasswordResetSuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: <Widget>[
              const _Header(
                icon: Icons.password,
                title: 'Ijambo ry\'ibanga rishya',
                subtitle:
                    'Hitamo ijambo ry\'ibanga rishya utigeze ukoresha mbere.',
              ),
              PasswordField(
                controller: _password,
                label: 'Ijambo ry\'ibanga rishya',
                validator: validateNewPassword,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              PasswordStrength(password: _password.text),
              const SizedBox(height: 16),
              PasswordField(
                controller: _confirm,
                label: 'Ongera wandike ijambo ry\'ibanga',
                validator: (String? v) =>
                    v != _password.text ? 'Amagambo y\'ibanga ntahuye' : null,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Bika ijambo ry\'ibanga'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// 4. Byagenze neza
// =====================================================================
class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              const Spacer(),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                    color: AppColors.successSoft, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle,
                    color: AppColors.success, size: 64),
              ),
              const SizedBox(height: 24),
              const Text('Byagenze neza!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Ijambo ry\'ibanga ryawe ryahinduwe.\nInjira ukoresheje irishya.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.muted, fontSize: 15, height: 1.45),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                      builder: (_) => const AuthScreen(isRegister: false)),
                  (Route<dynamic> r) => r.isFirst,
                ),
                child: const Text('Injira'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Hindura ijambo ry'ibanga (umukoresha winjiye)
// =====================================================================
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _current = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    await Future<void>.delayed(
        const Duration(milliseconds: 900)); // TODO: hamagara API
    if (!mounted) return;
    setState(() => _saving = false);
    showComingSoon(context, 'Ijambo ry\'ibanga ryahinduwe.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hindura ijambo ry\'ibanga')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: <Widget>[
              PasswordField(
                controller: _current,
                label: 'Ijambo ry\'ibanga usanganywe',
                validator: (String? v) => (v == null || v.isEmpty)
                    ? 'Andika ijambo ry\'ibanga usanganywe'
                    : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const ForgotPasswordScreen()),
                  ),
                  child: const Text('Wibagiwe ijambo ry\'ibanga?'),
                ),
              ),
              const SizedBox(height: 4),
              PasswordField(
                controller: _password,
                label: 'Ijambo ry\'ibanga rishya',
                validator: (String? v) {
                  final String? base = validateNewPassword(v);
                  if (base != null) return base;
                  if (v == _current.text)
                    return 'Rigomba gutandukana n\'irya mbere';
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              PasswordStrength(password: _password.text),
              const SizedBox(height: 16),
              PasswordField(
                controller: _confirm,
                label: 'Ongera wandike ijambo ry\'ibanga rishya',
                validator: (String? v) =>
                    v != _password.text ? 'Amagambo y\'ibanga ntahuye' : null,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Bika impinduka'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
