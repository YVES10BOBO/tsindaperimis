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
    this.isExtra = false,
    this.audioPath,
  });

  /// Amajwi y'isomo yafashwe (Supabase Storage, bucket "audio"), niba ahari.
  final String? audioPath;

  final String id;
  final String categoryId;
  final String title;
  final int minutes;
  final List<LessonSection> sections;
  final bool isExtra;
}

class LessonSection {
  const LessonSection(this.heading, this.body,
      {this.sign, this.signLabel, this.imagePath});

  final String heading;
  final String body;
  final SignType? sign;
  final String? signLabel;
  final String? imagePath;
}

/// An option that starts with letters, e.g. "a na b ni ibisubizo by'ukuri".
final RegExp _comboOption =
    RegExp(r'^\s*([A-Da-d](?:\s*(?:,|na|&)\s*[A-Da-d])+)(?![A-Za-z])');

/// "All of the above" / "none of the above" options.
final RegExp _positionOption = RegExp(
  r"(ibisubizo byose|ibyo byose|byose (?:nibyo|ni byo|ni ukuri)|nta gisubizo|nta ?na ?kimwe|nta kimwe)",
  caseSensitive: false,
);

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
    this.imagePath,
    this.isExamQuestion = true,
    this.number,
    this.audioPath,
  });

  /// Amajwi asoma ikibazo (Supabase Storage, bucket "audio"), niba ahari.
  final String? audioPath;

  final String id;

  /// Nimero ihoraho (#57) iva muri dashboard. Ntihinduka n'iyo ibibazo bivanze;
  /// ifasha umukoresha kuvuga ikibazo kirimo ikosa. Null ku bibazo biri muri app.
  final int? number;
  final String categoryId;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final SignType? sign;
  final String? signLabel;
  final String? imagePath;
  final bool isExamQuestion;

  String get correctAnswer => options[correctIndex];

  /// Isubiza ikibazo kimwe ariko ibisubizo bivanze, kugira ngo
  /// igisubizo nyacyo kitajya kiba ahantu hamwe buri gihe.
  Question shuffled(Random random) {
    // Options that depend on their position ("A na B ni ibisubizo by'ukuri",
    // "Ibisubizo byose nibyo", "Nta gisubizo cy'ukuri") stay at the end, in
    // their original order, so they still make sense after shuffling.
    bool anchored(String text) =>
        _comboOption.hasMatch(text) || _positionOption.hasMatch(text);
    final List<int> movable = <int>[
      for (int i = 0; i < options.length; i++)
        if (!anchored(options[i])) i
    ]..shuffle(random);
    final List<int> order = <int>[
      ...movable,
      for (int i = 0; i < options.length; i++)
        if (anchored(options[i])) i,
    ];
    const List<String> letters = <String>['A', 'B', 'C', 'D'];

    // "a na b ni ibisubizo by'ukuri": point at the options' NEW letters.
    // Only options that start with the letters are changed, so "uruhushya
    // rwa A na B" inside a sentence is never touched.
    String remapReferences(String text) {
      final Match? m = _comboOption.firstMatch(text);
      if (m == null) return text;
      final String group = m.group(1)!;
      final bool lower = group.trim().toLowerCase() == group.trim();
      // A letter that points at a missing option is left as it was, instead
      // of crashing the whole question (the app must never show a blank page).
      final List<String> named = RegExp(r'\b[A-Da-d]\b')
          .allMatches(group)
          .map((Match l) => l.group(0)!.toUpperCase())
          .toList();
      if (named.any((String l) => !order.contains(letters.indexOf(l)))) {
        return text;
      }
      final List<String> mapped = named
          .map((String l) => letters[order.indexOf(letters.indexOf(l))])
          .toList()
        ..sort();
      final List<String> shown =
          mapped.map((String l) => lower ? l.toLowerCase() : l).toList();
      final String joined = shown.length <= 2
          ? shown.join(' na ')
          : '${shown.sublist(0, shown.length - 1).join(', ')} na ${shown.last}';
      return text.replaceRange(m.start, m.start + group.length, joined);
    }

    final RegExp answerLetter = RegExp(
      r'(\b(?:igisubizo(?:\s+nyacyo)?|answer(?:\s+is)?)\s+(?:ni\s*:?[ ]*)?)([A-D])\b',
      caseSensitive: false,
    );
    String remappedExplanation = remapReferences(explanation).replaceAllMapped(
      answerLetter,
      (Match match) {
        final int oldIndex = letters.indexOf(match.group(2)!.toUpperCase());
        final int newIndex = order.indexOf(oldIndex);
        if (newIndex < 0) return match.group(0)!;
        return '${match.group(1)}${letters[newIndex]}';
      },
    );
    return Question(
      id: id,
      categoryId: categoryId,
      text: text,
      options: order.map((int i) => remapReferences(options[i])).toList(),
      correctIndex: order.indexOf(correctIndex),
      explanation: remappedExplanation,
      sign: sign,
      signLabel: signLabel,
      imagePath: imagePath,
      isExamQuestion: isExamQuestion,
      number: number,
      audioPath: audioPath,
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

/// Ubutumwa admin yanditse muri dashboard (imbonerahamwe `notifications`).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.iconKey = 'info',
    this.date,
    this.expiresAt,
  });

  final String id;
  final String title;
  final String body;

  /// Igomba guhura n'urutonde ruri muri migration `notifications.icon`.
  final String iconKey;
  final DateTime? date;
  final DateTime? expiresAt;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  IconData get icon => switch (iconKey) {
        'new' => Icons.fiber_new,
        'tip' => Icons.lightbulb_outline,
        'reminder' => Icons.alarm,
        'warning' => Icons.warning_amber_rounded,
        'exam' => Icons.assignment_outlined,
        _ => Icons.info_outline,
      };

  /// Igihe bwatangarijwe, mu magambo: "Uyu munsi", "Ejo hashize", ...
  String get when {
    final DateTime? d = date;
    if (d == null) return '';
    final DateTime now = DateTime.now();
    final int days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(d.year, d.month, d.day))
        .inDays;
    if (days <= 0) return 'Uyu munsi';
    if (days == 1) return 'Ejo hashize';
    if (days < 7) return 'Hashize iminsi $days';
    return '${d.day}/${d.month}/${d.year}';
  }
}
