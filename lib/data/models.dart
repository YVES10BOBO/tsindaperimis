import 'dart:math';

import 'package:flutter/material.dart';

/// Ubwoko bw'ibimenyetso app ishobora gushushanya (nta mafoto akenewe).
enum SignType {
  stop,
  giveWay,
  noEntry,
  speedLimit,
  noOvertaking,
  noParking,
  danger,
  children,
  aheadOnly,
  turnRight,
  roundabout,
  pedestrianCrossing,
  turnLeft,
  noLeftTurn,
  noUTurn,
  roadWorks,
  trafficSignalsAhead,
  pedestriansAhead,
  noPedestrians,
  parking,
  steepAscent,
  trafficLight,
  plainWarningTriangle,
  sideRoadRight,
  crosswind,
  deadEnd,
  railwayCrossing,
  priorityOverOncoming,
  twoWayTraffic,
  speedBump,
}

class LearnCategory {
  const LearnCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.softColor,
    required this.lessons,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color softColor;
  final List<Lesson> lessons;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.minutes,
    required this.sections,
  });

  final String id;
  final String categoryId;
  final String title;
  final int minutes;
  final List<LessonSection> sections;
}

class LessonSection {
  const LessonSection(this.heading, this.body, {this.sign, this.signLabel});

  final String heading;
  final String body;
  final SignType? sign;
  final String? signLabel;
}

class Question {
  const Question({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.sign,
    this.signLabel,
  });

  final String id;
  final String categoryId;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final SignType? sign;
  final String? signLabel;

  String get correctAnswer => options[correctIndex];

  /// Isubiza ikibazo kimwe ariko ibisubizo bivanze, kugira ngo
  /// igisubizo nyacyo kitajya kiba ahantu hamwe buri gihe.
  Question shuffled(Random random) {
    final List<int> order = List<int>.generate(options.length, (int i) => i)
      ..shuffle(random);
    return Question(
      id: id,
      categoryId: categoryId,
      text: text,
      options: order.map((int i) => options[i]).toList(),
      correctIndex: order.indexOf(correctIndex),
      explanation: explanation,
      sign: sign,
      signLabel: signLabel,
    );
  }
}

class ExamResult {
  ExamResult({
    required this.date,
    required this.questions,
    required this.answers,
    required this.timeUsed,
    required this.passScore,
  });

  final DateTime date;
  final List<Question> questions;
  final List<int?> answers;
  final Duration timeUsed;
  final int passScore;

  int get total => questions.length;

  int get score {
    int s = 0;
    for (int i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i].correctIndex) s++;
    }
    return s;
  }

  bool get passed => score >= passScore;

  double get ratio => total == 0 ? 0 : score / total;

  bool isCorrect(int i) => answers[i] == questions[i].correctIndex;
}

class AppNotification {
  const AppNotification(this.title, this.body, this.when, this.icon);

  final String title;
  final String body;
  final String when;
  final IconData icon;
}
