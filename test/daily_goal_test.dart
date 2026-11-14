import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amategeko_app/data/content_repository.dart';
import 'package:amategeko_app/data/models.dart';
import 'package:amategeko_app/widgets/daily_goal.dart';
import 'package:amategeko_app/screens/practice_screens.dart';
import 'package:amategeko_app/state/app_state.dart';

void main() {
  test('daily goal counts answers, reaches the goal once and builds a streak', () {
    final AppState s = AppState();
    s.setDailyGoal(5);
    final Question q = ContentRepository.instance.allQuestions.first;
    for (int i = 0; i < 4; i++) {
      s.recordAnswer(q, true, persist: false);
    }
    expect(s.answeredToday, 4);
    expect(s.goalReachedToday, isFalse);
    expect(s.consumeGoalReached(), isFalse);
    s.recordAnswer(q, true, persist: false);
    expect(s.goalReachedToday, isTrue);
    expect(s.consumeGoalReached(), isTrue);
    expect(s.consumeGoalReached(), isFalse);
    expect(s.streak, 1);
    s.recordAnswer(q, true, persist: false);
    expect(s.consumeGoalReached(), isFalse);
  });

  testWidgets('goal card + sheet', (WidgetTester t) async {
    t.view.physicalSize = const Size(360, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(AppScope(notifier: AppState(), child: const MaterialApp(home: Scaffold(body: Padding(padding: EdgeInsets.all(20), child: DailyGoalCard())))));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Intego ya none'), findsOneWidget);
    await t.tap(find.text('Intego ya none'));
    await t.pumpAndSettle();
    expect(find.text('Intego ya buri munsi'), findsOneWidget);
    await t.tap(find.text('20 ibibazo'));
    await t.pumpAndSettle();
    expect(find.textContaining('/20'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('practice home shows the bookmarked-questions card', (WidgetTester t) async {
    t.view.physicalSize = const Size(360, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(AppScope(notifier: AppState(), child: const MaterialApp(home: Scaffold(body: PracticeHomeScreen()))));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Itoze ibibazo nabitse'), findsOneWidget);
    expect(find.text('Intego ya none'), findsOneWidget);
  });
}
