import 'dart:math';

import 'categories_data.dart';
import 'exam_scope.dart';
import 'extended_data.dart';
import 'models.dart';
import 'more_questions.dart';
import 'questions_data.dart';

/// Aho app ikura ibirimo byose.
/// Ubu ikoresha amakuru ari muri code; nyuma uzayisimbuza SQLite (offline)
/// + REST API utahinduye screens.
class ContentRepository {
  ContentRepository._();

  static final ContentRepository instance = ContentRepository._();

  final Random _random = Random();

  List<LearnCategory> get categories => learnCategories;

  /// Ibibazo byose: iby'ibanze + iby'inyongera (ubumenyi ku modoka, imyitwarire).
  final List<Question> _all = <Question>[
    ...questionBank,
    ...vehicleQuestions,
    ...drivingQuestions,
    ...moreQuestions,
  ];

  List<Question> get allQuestions => _all;

  /// Ibibazo bibazwa mu kizamini (hatarimo ubumenyi bw'inyongera).
  List<Question> get examQuestions => _all.where(isExamQuestion).toList();

  List<AppNotification> get notifications => sampleNotifications;

  LearnCategory categoryById(String id) =>
      learnCategories.firstWhere((LearnCategory c) => c.id == id);

  List<Lesson> get allLessons => <Lesson>[
        for (final LearnCategory c in learnCategories) ...c.lessons,
      ];

  int get totalLessons => allLessons.length;

  Lesson? lessonById(String id) {
    for (final Lesson l in allLessons) {
      if (l.id == id) return l;
    }
    return null;
  }

  Question? questionById(String id) {
    for (final Question q in _all) {
      if (q.id == id) return q;
    }
    return null;
  }

  List<Question> questionsFor(String categoryId) =>
      _all.where((Question q) => q.categoryId == categoryId).toList();

  /// Ibibazo bivanze (ibisubizo nabyo bivanze).
  List<Question> shuffledQuestions(List<Question> source, {int? limit}) {
    final List<Question> list = List<Question>.of(source)..shuffle(_random);
    final List<Question> picked =
        limit == null ? list : list.take(min(limit, list.length)).toList();
    return picked.map((Question q) => q.shuffled(_random)).toList();
  }

  List<Question> buildExam(int count) =>
      shuffledQuestions(examQuestions, limit: count);

  List<Lesson> searchLessons(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return <Lesson>[];
    return allLessons.where((Lesson l) {
      if (l.title.toLowerCase().contains(q)) return true;
      return l.sections.any((LessonSection s) =>
          s.heading.toLowerCase().contains(q) ||
          s.body.toLowerCase().contains(q));
    }).toList();
  }

  List<LearnCategory> searchCategories(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return <LearnCategory>[];
    return learnCategories
        .where((LearnCategory c) =>
            c.title.toLowerCase().contains(q) ||
            c.subtitle.toLowerCase().contains(q))
        .toList();
  }
}
