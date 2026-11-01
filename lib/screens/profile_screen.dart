import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import '../data/content_repository.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'password_screens.dart';

/// Uturere 30 tw'u Rwanda.
const List<String> rwandaDistricts = <String>[
  'Bugesera', 'Burera', 'Gakenke', 'Gasabo', 'Gatsibo', 'Gicumbi',
  'Gisagara', 'Huye', 'Kamonyi', 'Karongi', 'Kayonza', 'Kicukiro',
  'Kirehe', 'Muhanga', 'Musanze', 'Ngoma', 'Ngororero', 'Nyabihu',
  'Nyagatare', 'Nyamagabe', 'Nyamasheke', 'Nyanza', 'Nyarugenge', 'Nyaruguru',
  'Rubavu', 'Ruhango', 'Rulindo', 'Rusizi', 'Rutsiro', 'Rwamagana',
];

/// Ubwoko bw'uruhushya umukoresha yitegura.
/// ICYITONDERWA: genzura ibyiciro byemewe n'amabwiriza agezweho.
const Map<String, String> licenseCategories = <String, String>{
  'A': 'Moto',
  'B': 'Imodoka nto',
  'C': 'Amakamyo',
  'D': 'Bisi',
};

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  String? _district;
  late String _license;
  late int _avatar;
  bool _initialized = false;
  bool _saving = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final AppState s = AppScope.of(context);
    _name = TextEditingController(text: s.isGuest ? '' : s.displayName);
    _phone = TextEditingController(text: s.phone);
    _email = TextEditingController(text: s.email);
    _district = s.district.isEmpty ? null : s.district;
    _license = s.licenseCategory;
    _avatar = s.avatarColor;
    _name.addListener(() => setState(() {}));
    _initialized = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    final AppState state = AppScope.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ContentRepository.instance.saveProfile(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        district: _district ?? '',
        licenseCategory: _license,
        avatarColor: _avatar,
      );
      state.updateProfile(
        name: _name.text,
        phone: _phone.text,
        email: state.email,
        district: _district ?? '',
        licenseCategory: _license,
        avatarColor: _avatar,
      );
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
            const SnackBar(content: Text('Umwirondoro wawe wabitswe.')));
      navigator.pop();
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Ntibyashobotse kubika. Reba internet.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hindura umwirondoro')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: <Widget>[
              // ---------- Ishusho ----------
              Center(
                child: UserAvatar(
                  name: _name.text.isEmpty ? '?' : _name.text,
                  colorIndex: _avatar,
                  radius: 44,
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text('Hitamo ibara ry\'ishusho yawe',
                    style: TextStyle(color: AppColors.muted, fontSize: 13)),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (int i = 0; i < AppColors.avatarColors.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Semantics(
                        button: true,
                        selected: i == _avatar,
                        label: 'Ibara rya ${i + 1}',
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => setState(() => _avatar = i),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.avatarColors[i],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: i == _avatar ? AppColors.text : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: i == _avatar
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),

              // ---------- Amakuru ----------
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Amazina yawe',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (String? v) =>
                    (v == null || v.trim().length < 2) ? 'Andika amazina yawe' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nimero ya telefoni',
                  hintText: '07X XXX XXXX',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: validatePhone,
              ),
              const SizedBox(height: 14),
              // The sign-in email: changing it needs a confirmed new address,
              // so it is shown here but not editable.
              TextFormField(
                controller: _email,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email yo kwinjira',
                  helperText: 'Email ukoresha winjira ntishobora guhindurwa hano.',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _district,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Akarere',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: <DropdownMenuItem<String>>[
                  for (final String d in rwandaDistricts)
                    DropdownMenuItem<String>(value: d, child: Text(d)),
                ],
                onChanged: (String? v) => setState(() => _district = v),
              ),
              const SizedBox(height: 22),

              // ---------- Ubwoko bw'uruhushya ----------
              const Text('Uruhushya witegura',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final MapEntry<String, String> e in licenseCategories.entries)
                    ChoiceChip(
                      label: Text('${e.key} · ${e.value}'),
                      selected: _license == e.key,
                      onSelected: (_) => setState(() => _license = e.key),
                    ),
                ],
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: 20),
                Text(_error!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Bika impinduka'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ChangePasswordScreen()),
                ),
                icon: const Icon(Icons.lock_reset),
                label: const Text('Hindura ijambo ry\'ibanga'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
