import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_info.dart';
import '../data/content_repository.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';
import 'info_screens.dart';
import 'lesson_screen.dart';
import 'password_screens.dart';
import 'profile_screen.dart';
import 'welcome_screen.dart';

// =====================================================================
// Ibindi (konti, ibyabitswe, premium, igenamiterere)
// =====================================================================
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _chooseLanguage(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (BuildContext ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.check_circle, color: AppColors.primary),
              title: Text('Ikinyarwanda'),
            ),
            ListTile(
              leading: Icon(Icons.radio_button_unchecked),
              title: Text('English'),
              subtitle: Text('Izaza vuba'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: Icon(Icons.radio_button_unchecked),
              title: Text('Français'),
              subtitle: Text('Izaza vuba'),
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'Urumuri';
      case ThemeMode.dark:
        return 'Umwijima';
      case ThemeMode.system:
        return 'Nk\'iya telefoni';
    }
  }

  Future<void> _chooseTheme(BuildContext context, AppState state) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        Widget option(ThemeMode mode, IconData icon, String subtitle) {
          final bool selected = state.themeMode == mode;
          return ListTile(
            leading: Icon(icon),
            title: Text(_themeLabel(mode)),
            subtitle: Text(subtitle),
            trailing: Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : AppColors.muted,
            ),
            onTap: () {
              state.setThemeMode(mode);
              Navigator.pop(ctx);
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              option(ThemeMode.light, Icons.light_mode_outlined, 'Inyuma h\'umweru'),
              option(ThemeMode.dark, Icons.dark_mode_outlined, 'Inyuma hijimye, byiza nijoro'),
              option(ThemeMode.system, Icons.phone_android, 'Bikurikira imiterere ya telefoni'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: <Widget>[
          Text('Ibindi', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          SizedBox(height: 16),
          AppCard(
            onTap: state.isGuest ? null : () => _push(context, const EditProfileScreen()),
            child: Row(
              children: <Widget>[
                UserAvatar(name: state.displayName, colorIndex: state.avatarColor),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(state.displayName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text(
                        state.isGuest
                            ? 'Mushyitsi · iterambere ntiribikwa'
                            : (state.isPremium ? 'Konti ya Premium' : 'Konti isanzwe'),
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (state.isGuest)
                  TextButton(
                    onPressed: () => _push(context, const AuthScreen(isRegister: true)),
                    child: Text('Iyandikishe'),
                  )
                else
                  Icon(Icons.edit_outlined, color: AppColors.muted),
              ],
            ),
          ),
          SizedBox(height: 14),
          if (!state.isPremium)
            AppCard(
              color: AppColors.primaryDark,
              borderColor: AppColors.primaryDark,
              onTap: () => _push(context, PremiumScreen()),
              child: Row(
                children: <Widget>[
                  Icon(Icons.workspace_premium, color: Color(0xFFFACC15), size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Fungura Premium',
                            style: TextStyle(
                                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                        SizedBox(height: 2),
                        Text('Ibizamini byose, ibibazo byinshi, nta matangazo',
                            style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 13)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          if (!state.isGuest) ...<Widget>[
            SizedBox(height: 14),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  _MenuTile(
                    icon: Icons.person_outline,
                    title: 'Hindura umwirondoro',
                    onTap: () => _push(context, const EditProfileScreen()),
                  ),
                  _MenuTile(
                    icon: Icons.lock_reset,
                    title: 'Hindura ijambo ry\'ibanga',
                    onTap: () => _push(context, const ChangePasswordScreen()),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 14),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                _MenuTile(
                  icon: Icons.bookmark_outline,
                  title: 'Ibyo nabitse',
                  onTap: () => _push(context, BookmarksScreen()),
                ),
                _MenuTile(
                  icon: Icons.notifications_none,
                  title: 'Ubutumwa',
                  onTap: () => _push(context, NotificationsScreen()),
                ),
                _MenuTile(
                  icon: AppColors.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  title: 'Imiterere y\'amabara',
                  trailingText: _themeLabel(state.themeMode),
                  onTap: () => _chooseTheme(context, state),
                ),
                _MenuTile(
                  icon: Icons.language,
                  title: 'Ururimi',
                  trailingText: 'Ikinyarwanda',
                  onTap: () => _chooseLanguage(context),
                ),
                SwitchListTile(
                  secondary: Icon(Icons.alarm, color: AppColors.text),
                  title: Text('Unyibutse kwiga buri munsi'),
                  value: state.notificationsOn,
                  onChanged: state.setNotifications,
                ),
              ],
            ),
          ),
          SizedBox(height: 14),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                _MenuTile(
                  icon: Icons.help_outline,
                  title: 'Ibibazo bikunze kubazwa (FAQ)',
                  onTap: () => _push(context, const FaqScreen()),
                ),
                _MenuTile(
                  icon: Icons.description_outlined,
                  title: "Amategeko n'Amabwiriza",
                  onTap: () => _push(context, const TermsScreen()),
                ),
                _MenuTile(
                  icon: Icons.privacy_tip_outlined,
                  title: "Politiki y'Ibanga",
                  onTap: () => _push(context, const PrivacyScreen()),
                ),
                _MenuTile(
                  icon: Icons.info_outline,
                  title: 'Ibyerekeye app',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: AppInfo.name,
                    applicationVersion: AppInfo.version,
                    children: <Widget>[
                      Text('App yo kwiga amategeko y\'umuhanda no kwitegura ikizamini cy\'uruhushya rwo gutwara. '
                          'Ibirimo bigomba kugenzurwa n\'amabwiriza agezweho ya Polisi y\'u Rwanda.'),
                    ],
                  ),
                ),
                if (!state.isGuest)
                  _MenuTile(
                    icon: Icons.logout,
                    title: 'Sohoka',
                    color: AppColors.error,
                    onTap: () {
                      state.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(builder: (_) => WelcomeScreen()),
                        (Route<dynamic> r) => false,
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.color,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailingText;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color color = this.color ?? AppColors.text;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (trailingText != null)
            Text(trailingText!, style: TextStyle(color: AppColors.muted, fontSize: 13)),
          Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
      onTap: onTap,
    );
  }
}

// =====================================================================
// Ibyo nabitse
// =====================================================================
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final ContentRepository repo = ContentRepository.instance;
    final List<Lesson> lessons = <Lesson>[
      for (final String id in state.bookmarkedLessons)
        if (repo.lessonById(id) != null) repo.lessonById(id)!,
    ];
    final List<Question> questions = <Question>[
      for (final String id in state.bookmarkedQuestions)
        if (repo.questionById(id) != null) repo.questionById(id)!,
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Ibyo nabitse')),
      body: (lessons.isEmpty && questions.isEmpty)
          ? EmptyState(
              icon: Icons.bookmark_border,
              title: 'Nta kintu urabika',
              message: 'Kanda ikimenyetso cyo kubika ku isomo cyangwa ku kibazo kugira ngo kize hano.',
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: <Widget>[
                if (lessons.isNotEmpty) ...<Widget>[
                  SectionTitle('Amasomo'),
                  SizedBox(height: 6),
                  for (final Lesson l in lessons)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        radius: 14,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => LessonScreen(lesson: l)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.article_outlined, color: AppColors.primary),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(l.title,
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            Icon(Icons.chevron_right, color: AppColors.muted),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 12),
                ],
                if (questions.isNotEmpty) ...<Widget>[
                  SectionTitle('Ibibazo'),
                  SizedBox(height: 6),
                  for (final Question q in questions)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        radius: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(q.text,
                                      style: TextStyle(fontWeight: FontWeight.w700, height: 1.4)),
                                ),
                                IconButton(
                                  tooltip: 'Kuramo',
                                  icon: Icon(Icons.bookmark, color: AppColors.primary),
                                  onPressed: () => state.toggleQuestionBookmark(q.id),
                                ),
                              ],
                            ),
                            Text('Igisubizo: ${q.correctAnswer}',
                                style: TextStyle(
                                    color: AppColors.success, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}

// =====================================================================
// Ubutumwa
// =====================================================================
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<AppNotification> items = ContentRepository.instance.notifications;
    return Scaffold(
      appBar: AppBar(title: Text('Ubutumwa')),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: 10),
        itemBuilder: (BuildContext context, int i) {
          final AppNotification n = items[i];
          return AppCard(
            radius: 14,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                IconBadge(
                    icon: n.icon, color: AppColors.primary, background: AppColors.primarySoft, size: 40),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(n.title, style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text(n.body, style: TextStyle(color: AppColors.muted, height: 1.4)),
                      SizedBox(height: 4),
                      Text(n.when, style: TextStyle(color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =====================================================================
// Premium (kwishyura na MoMo / Airtel Money) — UI gusa
// =====================================================================
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _method = 'mtn';
  final TextEditingController _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _pay() {
    final String digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      showComingSoon(context, 'Andika nimero ya telefoni yuzuye.');
      return;
    }
    // TODO: Hamagara backend (Payments module) ihuza na MTN MoMo / Airtel Money API.
    AppScope.of(context).activatePremium();
    showComingSoon(context, 'Igerageza: Premium yafunguwe. Kwishyura nyabyo bizahuzwa na backend.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Premium')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: <Widget>[
          Center(
            child: Icon(Icons.workspace_premium, size: 64, color: Color(0xFFEAB308)),
          ),
          SizedBox(height: 10),
          Text('Fungura Premium',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text('[IGICIRO] RWF / ukwezi',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 15)),
          SizedBox(height: 18),
          AppCard(
            child: Column(
              children: <Widget>[
                _Perk('Ibizamini by\'igerageza bitagira umubare'),
                _Perk('Ibibazo byose n\'ibisobanuro byabyo'),
                _Perk('Amasomo yose akora nta interineti'),
                _Perk('Nta matangazo'),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text('Uburyo bwo kwishyura',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          SizedBox(height: 10),
          _PayMethod(
            label: 'MTN Mobile Money',
            color: Color(0xFFFFCC00),
            selected: _method == 'mtn',
            onTap: () => setState(() => _method = 'mtn'),
          ),
          SizedBox(height: 10),
          _PayMethod(
            label: 'Airtel Money',
            color: Color(0xFFE40000),
            selected: _method == 'airtel',
            onTap: () => setState(() => _method = 'airtel'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Nimero ya telefoni',
              hintText: '07X XXX XXXX',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: _pay, child: Text('Ishyura')),
          SizedBox(height: 10),
          Text(
            'Uzakira ubutumwa kuri telefoni bwo kwemeza kwishyura.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _Perk extends StatelessWidget {
  const _Perk(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Icon(Icons.check_circle, color: AppColors.success, size: 20),
          SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _PayMethod extends StatelessWidget {
  const _PayMethod({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      radius: 14,
      color: selected ? AppColors.primarySoft : AppColors.surface,
      borderColor: selected ? AppColors.primary : AppColors.border,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.phone_android, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w700))),
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : AppColors.muted),
        ],
      ),
    );
  }
}
