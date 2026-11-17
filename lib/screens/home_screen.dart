import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/exam_config.dart';
import '../data/content_repository.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/daily_goal.dart';
import 'auth_screen.dart';
import 'category_screen.dart';
import 'more_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final ContentRepository repo = ContentRepository.instance;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: <Widget>[
          // ---------- Header ----------
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Muraho, ${state.displayName}',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Komeza wige, witegure utsinde!',
                        style: TextStyle(color: AppColors.muted, fontSize: 14)),
                  ],
                ),
              ),
              IconButton.outlined(
                tooltip: 'Ubutumwa',
                style: IconButton.styleFrom(
                  side: BorderSide(color: AppColors.border),
                  backgroundColor: AppColors.surface,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => NotificationsScreen()),
                ),
                icon: Icon(Icons.notifications_none),
              ),
            ],
          ),
          SizedBox(height: 18),

          // ---------- Daily goal ----------
          DailyGoalCard(onPractice: () => onOpenTab(1)),
          SizedBox(height: 16),

          // ---------- Practice and exam: first thing the learner sees ----------
          SectionTitle('Itegure ikizamini'),
          SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: _QuickAction(
                    icon: Icons.edit_note,
                    colors: <Color>[Color(0xFF2FA8E8), AppColors.primary],
                    title: 'Imyitozo',
                    subtitle: 'Subiza ibibazo, uhite ubona igisubizo',
                    onTap: () => onOpenTab(1),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.assignment,
                    colors: <Color>[AppColors.primary, AppColors.primaryDark],
                    title: 'Ikizamini',
                    subtitle:
                        "Ibibazo ${ExamConfig.questionCount} mu minota ${ExamConfig.durationMinutes}, nk'ukuri",
                    onTap: () => onOpenTab(2),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // ---------- Progress ----------
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Iterambere ryawe',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    ProgressRing(value: state.readiness, size: 88, stroke: 9),
                    SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          _StatRow('Amasomo warangije',
                              '${state.completedLessons.length} / ${repo.totalLessons}'),
                          _StatRow('Ibibazo wakoze', '${state.totalAnswered}'),
                          _StatRow('Ibizamini wakoze',
                              '${state.examResults.length}'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                SizedBox(
                  height: 42,
                  child: PressScale(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: Size(0, 42)),
                    onPressed: () => onOpenTab(3),
                    child:
                        Text('Reba iterambere', style: TextStyle(fontSize: 14)),
                  )),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // ---------- Search ----------
          AppCard(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            radius: 14,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => SearchScreen()),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.search, color: AppColors.muted),
                SizedBox(width: 10),
                Text('Shakisha amategeko, ibimenyetso...',
                    style: TextStyle(color: AppColors.muted, fontSize: 15)),
              ],
            ),
          ),

          if (state.isGuest) ...<Widget>[
            SizedBox(height: 16),
            AppCard(
              color: AppColors.warningSoft,
              borderColor: AppColors.warningBorder,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => AuthScreen(isRegister: true)),
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.info_outline, color: AppColors.warningIcon),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Uri gukoresha app nka Mushyitsi. Iyandikishe kugira ngo iterambere ryawe ribikwe.',
                      style:
                          TextStyle(color: AppColors.warningText, height: 1.4),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.warningIcon),
                ],
              ),
            ),
          ],
          SizedBox(height: 22),

          // ---------- Categories ----------
          SectionTitle('Ibyiciro byo kwiga'),
          SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.78,
            children: <Widget>[
              for (final LearnCategory c in repo.categories)
                CategoryTile(
                  category: c,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => CategoryScreen(category: c)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(label,
                style: TextStyle(color: AppColors.muted, fontSize: 13.5)),
          ),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final List<Color> colors;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: colors.last.withAlpha(70),
                  blurRadius: 14,
                  offset: Offset(0, 6)),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white24,
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(46),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: Colors.white, size: 26),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 22),
                    ],
                  ),
                  SizedBox(height: 14),
                  Text(title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFFE3F4FD),
                          height: 1.35)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
