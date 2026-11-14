import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../state/app_state.dart';
import 'common.dart';

/// "Intego ya none": how many questions were answered today, the day streak,
/// and a way to change the daily goal. Tap the card to pick another goal.
class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({super.key, this.onPractice});

  /// When given, shows a button that takes the learner to practice.
  final VoidCallback? onPractice;

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final bool reached = state.goalReachedToday;
    final int streak = state.streak;
    final Color accent = reached ? AppColors.success : AppColors.primary;
    final int left =
        (state.dailyGoal - state.answeredToday).clamp(0, state.dailyGoal);

    return AppCard(
      onTap: () => showDailyGoalSheet(context),
      child: Row(
        children: <Widget>[
          ProgressRing(
            value: state.goalProgress,
            size: 76,
            stroke: 8,
            color: accent,
            fontSize: 17,
            label: '${state.answeredToday.clamp(0, 999)}/${state.dailyGoal}',
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('Intego ya none',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text)),
                    ),
                    _StreakChip(days: streak),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reached
                      ? 'Intego yuzuye! Komeza ubigenze.'
                      : 'Subiza ibibazo $left kugira ngo wuzuze intego.',
                  style: TextStyle(
                      color: AppColors.muted, fontSize: 13.5, height: 1.35),
                ),
                if (onPractice != null && !reached) ...<Widget>[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onPractice,
                    child: Text('Itoze ubu',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final bool on = days > 0;
    final Color color = on ? const Color(0xFFEA580C) : AppColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            on ? const Color(0xFFEA580C).withAlpha(28) : AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.local_fire_department, size: 16, color: color),
          const SizedBox(width: 3),
          Text('$days',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }
}

/// Lets the learner pick the daily goal (5, 10, 20 or 30 questions).
void showDailyGoalSheet(BuildContext context) {
  final AppState state = AppScope.of(context);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (BuildContext ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Intego ya buri munsi',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text)),
              const SizedBox(height: 6),
              Text(
                'Hitamo umubare w\'ibibazo ushaka gukora buri munsi. Iminsi ikurikiranye wujuje intego igukura mu murongo.',
                style: TextStyle(
                    color: AppColors.muted, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  for (final int g in AppState.goalChoices)
                    PressScale(
                      child: ChoiceChip(
                        label: Text('$g ibibazo'),
                        selected: state.dailyGoal == g,
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          state.setDailyGoal(g);
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Floating message shown right after the answer that completes today's goal.
void showGoalReachedMessage(BuildContext context, int streak) {
  HapticFeedback.heavyImpact();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 4),
        content: Row(
          children: <Widget>[
            const Icon(Icons.emoji_events, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                streak > 1
                    ? 'Intego ya none yuzuye! Iminsi $streak ikurikiranye.'
                    : 'Intego ya none yuzuye! Komeza utyo.',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
}
