import 'dart:async';

import 'package:flutter/material.dart';

import '../data/content_repository.dart';
import '../data/models.dart';

/// Imiterere ya app (umukoresha, iterambere, ibyo yabitse).
class AppState extends ChangeNotifier {
  AppState() {
    _restoreProgress();
  }

  String? _userName;
  bool _isGuest = true;
  bool notificationsOn = true;
  bool isPremium = false;

  // ---------- Umwirondoro ----------
  String phone = '';
  String email = '';
  String district = '';
  String licenseCategory = 'B';
  int avatarColor = 0;

  // ---------- Imiterere y'amabara ----------
  ThemeMode themeMode =
      ThemeMode.light; // Light ni yo ibanza; umukoresha ashobora guhindura

  final Set<String> completedLessons = <String>{};
  final Set<String> bookmarkedLessons = <String>{};
  final Set<String> bookmarkedQuestions = <String>{};
  final Set<String> wrongQuestions = <String>{};
  final Map<String, int> answeredByCategory = <String, int>{};
  final Map<String, int> correctByCategory = <String, int>{};
  final List<ExamResult> examResults = <ExamResult>[];

  Future<void> _restoreProgress() async {
    try {
      final saved = await ContentRepository.instance.loadProgress();
      completedLessons
          .addAll((saved['completedLessons'] as List<String>?) ?? []);
      bookmarkedLessons
          .addAll((saved['bookmarkedLessons'] as List<String>?) ?? []);
      bookmarkedQuestions
          .addAll((saved['bookmarkedQuestions'] as List<String>?) ?? []);
      wrongQuestions.addAll((saved['wrongQuestions'] as List<String>?) ?? []);
      answeredByCategory
          .addAll((saved['answeredByCategory'] as Map<String, int>?) ?? {});
      correctByCategory
          .addAll((saved['correctByCategory'] as Map<String, int>?) ?? {});
      examResults.addAll((saved['examResults'] as List<ExamResult>?) ?? []);
      final cloud = await ContentRepository.instance.syncProgressWithSupabase();
      if (cloud != null) _applyProgress(cloud);
      if (saved.isNotEmpty) notifyListeners();
    } catch (error) {
      debugPrint('Could not restore local progress: $error');
    }
  }

  void _applyProgress(Map<String, dynamic> saved) {
    completedLessons
      ..clear()
      ..addAll((saved['completedLessons'] as List<String>?) ?? []);
    bookmarkedLessons
      ..clear()
      ..addAll((saved['bookmarkedLessons'] as List<String>?) ?? []);
    bookmarkedQuestions
      ..clear()
      ..addAll((saved['bookmarkedQuestions'] as List<String>?) ?? []);
    wrongQuestions
      ..clear()
      ..addAll((saved['wrongQuestions'] as List<String>?) ?? []);
    answeredByCategory
      ..clear()
      ..addAll((saved['answeredByCategory'] as Map<String, int>?) ?? {});
    correctByCategory
      ..clear()
      ..addAll((saved['correctByCategory'] as Map<String, int>?) ?? {});
    examResults
      ..clear()
      ..addAll((saved['examResults'] as List<ExamResult>?) ?? []);
  }

  void _persist(Future<void> operation) {
    unawaited(operation
        .then((_) => ContentRepository.instance.pushProgressSnapshot())
        .catchError((Object error) {
      debugPrint('Could not save local progress: $error');
    }));
  }

  bool get isGuest => _isGuest;
  String get displayName => _userName ?? 'Mushyitsi';

  // ---------- Konti ----------
  void signIn(String name, {String phone = '', String email = ''}) {
    _userName = name.trim().isEmpty ? 'Umukoresha' : name.trim();
    if (phone.trim().isNotEmpty) this.phone = phone.trim();
    if (email.trim().isNotEmpty) this.email = email.trim();
    _isGuest = false;
    unawaited(
        ContentRepository.instance.syncProgressWithSupabase().then((saved) {
      if (saved != null) {
        _applyProgress(saved);
        notifyListeners();
      }
    }));
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String phone,
    required String email,
    required String district,
    required String licenseCategory,
    required int avatarColor,
  }) {
    _userName = name.trim().isEmpty ? displayName : name.trim();
    this.phone = phone.trim();
    this.email = email.trim();
    this.district = district;
    this.licenseCategory = licenseCategory;
    this.avatarColor = avatarColor;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  void continueAsGuest() {
    _userName = null;
    _isGuest = true;
    phone = '';
    email = '';
    district = '';
    notifyListeners();
  }

  void signOut() => continueAsGuest();

  void setNotifications(bool value) {
    notificationsOn = value;
    notifyListeners();
  }

  void activatePremium() {
    isPremium = true;
    notifyListeners();
  }

  // ---------- Amasomo ----------
  bool isLessonDone(String id) => completedLessons.contains(id);

  void completeLesson(String id) {
    completedLessons.add(id);
    _persist(ContentRepository.instance.saveCompletedLesson(id, true));
    notifyListeners();
  }

  int completedIn(LearnCategory c) =>
      c.lessons.where((Lesson l) => completedLessons.contains(l.id)).length;

  // ---------- Ibyabitswe ----------
  bool isLessonBookmarked(String id) => bookmarkedLessons.contains(id);
  bool isQuestionBookmarked(String id) => bookmarkedQuestions.contains(id);

  void toggleLessonBookmark(String id) {
    if (!bookmarkedLessons.remove(id)) bookmarkedLessons.add(id);
    _persist(ContentRepository.instance
        .saveBookmark('lesson', id, bookmarkedLessons.contains(id)));
    notifyListeners();
  }

  void toggleQuestionBookmark(String id) {
    if (!bookmarkedQuestions.remove(id)) bookmarkedQuestions.add(id);
    _persist(ContentRepository.instance
        .saveBookmark('question', id, bookmarkedQuestions.contains(id)));
    notifyListeners();
  }

  // ---------- Ibisubizo ----------
  void recordAnswer(Question q, bool correct,
      {bool notify = true, bool persist = true}) {
    answeredByCategory[q.categoryId] =
        (answeredByCategory[q.categoryId] ?? 0) + 1;
    if (correct) {
      correctByCategory[q.categoryId] =
          (correctByCategory[q.categoryId] ?? 0) + 1;
      wrongQuestions.remove(q.id);
    } else {
      wrongQuestions.add(q.id);
    }
    if (persist) {
      _persist(ContentRepository.instance.saveQuestionAnswer(q, correct));
    }
    if (notify) notifyListeners();
  }

  void addExamResult(ExamResult result) {
    for (int i = 0; i < result.questions.length; i++) {
      if (result.answers[i] != null) {
        recordAnswer(result.questions[i], result.isCorrect(i),
            notify: false, persist: false);
      }
    }
    examResults.insert(0, result);
    _persist(ContentRepository.instance.saveExamResult(result));
    notifyListeners();
  }

  int get totalAnswered =>
      answeredByCategory.values.fold(0, (int a, int b) => a + b);

  int get totalCorrect =>
      correctByCategory.values.fold(0, (int a, int b) => a + b);

  double get accuracy => totalAnswered == 0 ? 0 : totalCorrect / totalAnswered;

  double categoryAccuracy(String id) {
    final int answered = answeredByCategory[id] ?? 0;
    if (answered == 0) return 0;
    return (correctByCategory[id] ?? 0) / answered;
  }

  double get averageExamRatio {
    if (examResults.isEmpty) return 0;
    final double sum =
        examResults.fold(0.0, (double a, ExamResult r) => a + r.ratio);
    return sum / examResults.length;
  }

  /// Ijanisha ry'uko umuntu yiteguye: amasomo 40%, imyitozo 30%, ibizamini 30%.
  double get readiness {
    final int total = ContentRepository.instance.totalLessons;
    final double lessons = total == 0 ? 0 : completedLessons.length / total;
    final double exam = examResults.isEmpty ? 0 : examResults.first.ratio;
    return (lessons * 0.4 + accuracy * 0.3 + exam * 0.3)
        .clamp(0.0, 1.0)
        .toDouble();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required super.notifier, required super.child});

  static AppState of(BuildContext context) {
    final AppScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope ntiboneka');
    return scope!.notifier!;
  }
}
