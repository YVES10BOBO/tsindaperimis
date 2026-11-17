import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import '../state/app_state.dart';
import '../widgets/road_scene.dart';
import '../widgets/sign_backdrop.dart';
import 'info_screens.dart';
import 'main_shell.dart';
import 'password_screens.dart';

/// Kwinjira / Kwiyandikisha: a card with the form, centred in front of an
/// animated road scene (same style as the welcome page).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.isRegister});

  final bool isRegister;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _hidePassword = true;
  bool _loading = false;
  bool _awaitingEmailConfirmation = false;
  String? _error;

  late final AnimationController _intro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 24));
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _intro.value = 1;
      _loop
        ..stop()
        ..value = 0.3;
    } else if (!_started || !_loop.isAnimating) {
      _started = true;
      _intro.forward();
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading ||
        _awaitingEmailConfirmation ||
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
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
      if (mounted) {
        // "Not initialized" means the app was built without the Supabase
        // address/key; anything else is most likely a network problem.
        final bool notConfigured =
            error is AssertionError || error.toString().contains('initialize');
        setState(() => _error = notConfigured
            ? 'App ntihujwe na seriveri. Ifunge uyifungure, cyangwa uyubake ukoresheje supabase.local.json.'
            : 'Ntibyashobotse kwinjira. Reba ko ufite internet, hanyuma ugerageze nanone.');
      }
      debugPrint('Supabase authentication failed: $error');
    } finally {
      if (mounted && _loading) setState(() => _loading = false);
    }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Uzuza aha' : null;

  /// Fade + slide-up between [begin] and [end] (0..1) of the intro animation.
  Widget _reveal(double begin, double end, Widget child,
      {Offset from = const Offset(0, 0.12)}) {
    final Animation<double> a = CurvedAnimation(
      parent: _intro,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween<Offset>(begin: from, end: Offset.zero).animate(a),
        child: child,
      ),
    );
  }

  /// Field label above the box, so it is always clear what to type.
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 2),
        child: Text(text,
            style: TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      );

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    final Color edge =
        AppColors.isDark ? const Color(0xFF3A4A63) : const Color(0xFFB9C6D6);
    OutlineInputBorder b(Color c, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.muted),
      prefixIcon: Icon(icon, color: AppColors.primary),
      suffixIcon: suffix,
      filled: true,
      fillColor:
          AppColors.isDark ? const Color(0xFF0F1828) : const Color(0xFFF3F7FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      enabledBorder: b(edge, 1.3),
      border: b(edge, 1.3),
      focusedBorder: b(AppColors.primary, 2.2),
      errorBorder: b(AppColors.error, 1.6),
      focusedErrorBorder: b(AppColors.error, 2.2),
      errorStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

  Widget _formBody(bool reg) {
    return Column(
      key: const ValueKey<String>('form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (reg) ...<Widget>[
          _label('Amazina yawe'),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.name],
            decoration: _decoration(
                hint: 'Andika amazina yawe', icon: Icons.person_outline),
            validator: _required,
          ),
          const SizedBox(height: 16),
        ],
        _label('Email'),
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const <String>[AutofillHints.email],
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          decoration: _decoration(
              hint: 'urugero@email.com', icon: Icons.email_outlined),
          validator: (String? v) {
            if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                .hasMatch((v ?? '').trim())) {
              return 'Andika email yemewe';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _label('Ijambo ry\'ibanga'),
        TextFormField(
          controller: _password,
          obscureText: _hidePassword,
          textInputAction: TextInputAction.done,
          autofillHints: <String>[
            reg ? AutofillHints.newPassword : AutofillHints.password
          ],
          onFieldSubmitted: (_) => _submit(),
          decoration: _decoration(
            hint: 'Nibura inyuguti 6',
            icon: Icons.lock_outline,
            suffix: IconButton(
              tooltip: _hidePassword ? 'Erekana' : 'Hisha',
              icon: Icon(
                _hidePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.muted,
              ),
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
            ),
          ),
          validator: (String? v) =>
              (v == null || v.length < 6) ? 'Nibura inyuguti 6' : null,
        ),
        if (!reg)
          Align(
            alignment: Alignment.centerRight,
            child: PressScale(
                child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => const ForgotPasswordScreen()),
              ),
              child: const Text('Wibagiwe ijambo ry\'ibanga?'),
            )),
          )
        else
          const SizedBox(height: 12),
        if (_error != null) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.errorSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.errorBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.error_outline, size: 20, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_error!,
                      style: TextStyle(
                          color: AppColors.errorText,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        PressScale(
            child: ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.4, color: Colors.white))
              : Text(reg ? 'Iyandikishe' : 'Injira'),
        )),
        if (reg) ...<Widget>[
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text('Kwiyandikisha byemeza ko wemeye ',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const TermsScreen()),
                ),
                child: Text("Amategeko n'Amabwiriza",
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700)),
              ),
              Text(' na ',
                  style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const PrivacyScreen()),
                ),
                child: Text("Politiki y'Ibanga",
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        PressScale(
            child: TextButton(
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
                builder: (_) => AuthScreen(isRegister: !reg)),
          ),
          child: Text(reg
              ? 'Usanzwe ufite konti? Injira'
              : 'Nta konti ufite? Iyandikishe'),
        )),
      ],
    );
  }

  Widget _confirmBody() {
    return Column(
      key: const ValueKey<String>('confirm'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: AppColors.primarySoft, shape: BoxShape.circle),
            child: Icon(Icons.mark_email_read_outlined,
                size: 32, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Twohereje umurongo wo kwemeza konti kuri ${_email.text.trim()}. '
          'Reba muri email yawe, ukande uwo murongo, hanyuma winjire.',
          textAlign: TextAlign.center,
          style:
              TextStyle(color: AppColors.bodyText, fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 20),
        PressScale(
            child: ElevatedButton(
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
                builder: (_) => const AuthScreen(isRegister: false)),
          ),
          child: const Text('Nemeje email, injira'),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool reg = widget.isRegister;
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final String title = _awaitingEmailConfirmation
        ? 'Reba email yawe'
        : (reg ? 'Fungura konti' : 'Murakaza neza');
    final String subtitle = _awaitingEmailConfirmation
        ? 'Konti yawe yarakozwe.'
        : reg
            ? 'Iyandikishe kugira ngo iterambere ryawe ribikwe.'
            : 'Injira ukomeze aho wari ugeze.';

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF0B3C66),
              Color(0xFF0F4C81),
              Color(0xFF14609F)
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            // Faint road signs drifting slowly behind everything.
            Positioned.fill(
              child: FadeTransition(
                opacity: _intro,
                child: SignBackdrop(animation: _loop),
              ),
            ),
            // Animated road at the bottom, behind the card (hidden while typing).
            if (!keyboardOpen)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 150,
                child: IgnorePointer(
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                        parent: _intro, curve: const Interval(0.4, 1.0)),
                    child: RoadScene(animation: _loop),
                  ),
                ),
              ),
            SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints box) =>
                    SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: box.maxHeight),
                    child: Padding(
                      // Balanced so the visible logo and card edges sit evenly top and bottom.
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ScaleTransition(
                            scale: CurvedAnimation(
                              parent: _intro,
                              curve: const Interval(0.0, 0.5,
                                  curve: Curves.easeOutBack),
                            ),
                            child: SizedBox(
                              width: 96,
                              height: 70,
                              child: AnimatedBuilder(
                                animation: _loop,
                                builder: (BuildContext context, Widget? logo) {
                                  // Whole cycles per loop, so it never jumps.
                                  final double pulse = (_loop.value * 12) % 1;
                                  final double bob = _intro.isCompleted
                                      ? 4 *
                                          math.sin(
                                              _loop.value * 12 * 2 * math.pi)
                                      : 0;
                                  return Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: <Widget>[
                                      // Soft ring that expands and fades, like a signal.
                                      Opacity(
                                        opacity: (1 - pulse) * 0.4,
                                        child: Transform.scale(
                                          scale: 1 + pulse * 0.45,
                                          child: Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color:
                                                      const Color(0xFFBFE3F7),
                                                  width: 2),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Transform.translate(
                                          offset: Offset(0, bob), child: logo),
                                    ],
                                  );
                                },
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const <BoxShadow>[
                                      BoxShadow(
                                          color: Color(0x4D000000),
                                          blurRadius: 18,
                                          offset: Offset(0, 8)),
                                    ],
                                  ),
                                  child: const Icon(Icons.directions_car,
                                      size: 34, color: AppColors.primary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _reveal(
                            0.15,
                            0.6,
                            Column(
                              children: <Widget>[
                                Text(title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 6),
                                Text(subtitle,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Color(0xFFBFE3F7),
                                        fontSize: 15)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // The form card, centred and in front.
                          _reveal(
                            0.3,
                            1.0,
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 440),
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 22, 20, 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: const <BoxShadow>[
                                    BoxShadow(
                                        color: Color(0x40000000),
                                        blurRadius: 30,
                                        offset: Offset(0, 14)),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: AnimatedSize(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                    alignment: Alignment.topCenter,
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      child: _awaitingEmailConfirmation
                                          ? _confirmBody()
                                          : _formBody(reg),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            from: const Offset(0, 0.18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  tooltip: 'Garuka',
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
