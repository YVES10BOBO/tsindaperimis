import 'dart:async';

import 'package:flutter/material.dart';

import '../data/content_repository.dart';
import '../data/models.dart';

/// Imiterere ya app (umukoresha, iterambere, ibyo yabitse).
class AppState extends ChangeNotifier {
  AppState() {
    _restoreSettings();
    _restoreAccount();
    _restoreProgress();
  }

  StreamSubscription<void>? _signedOutSubscription;

  void _restoreSettings() {
    final String? saved = ContentRepository.instance.setting('theme_mode');
    themeMode = ThemeMode.values.firstWhere((ThemeMode m) => m.name == saved,
        orElse: () => ThemeMode.light);
    _restoreDaily();
  }

  /// Ugarura konti yari yinjiye, kugira ngo umukoresha atongera kwinjira
  /// buri gihe afunguye app.
  void _restoreAccount() {
    final account = ContentRepository.instance.signedInAccount;
    if (account != null) {
      _userName = account.name;
      email = account.email;
      _isGuest = false;
      _applyProfile(account);
    }
    _signedOutSubscription =
        ContentRepository.instance.signedOutEvents.listen((_) {
      if (!_isGuest) continueAsGuest();
    });
  }

  @override
  void dispose() {
    _signedOutSubscription?.cancel();
    super.dispose();
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
    final account = ContentRepository.instance.signedInAccount;
    if (account != null) _applyProfile(account);
    unawaited(
        ContentRepository.instance.syncProgressWithSupabase().then((saved) {
      if (saved != null) {
        _applyProgress(saved);
        notifyListeners();
      }
    }));
    notifyListeners();
  }

  /// Umwirondoro ubitswe kuri konti (Supabase), ukurikira umukoresha
  /// kuri telefoni yose yinjiriyeho.
  void _applyProfile(SignedInAccount account) {
    if (account.phone.isNotEmpty) phone = account.phone;
    district = account.district;
    licenseCategory = account.licenseCategory;
    avatarColor = account.avatarColor;
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
    unawaited(ContentRepository.instance.saveSetting('theme_mode', mode.name));
    notifyListeners();
  }

  void continueAsGuest() {
    _userName = null;
    _isGuest = true;
    phone = '';
    email = '';
    district = '';
    licenseCategory = 'B';
    avatarColor = 0;
    notifyListeners();
  }

  void signOut() {
    unawaited(ContentRepository.instance.signOutRemote());
    continueAsGuest();
  }

  /// Clears everything this device knew about an account that was just deleted.
  Future<void> forgetDeletedAccount() async {
    completedLessons.clear();
    bookmarkedLessons.clear();
    bookmarkedQuestions.clear();
    wrongQuestions.clear();
    answeredByCategory.clear();
    correctByCategory.clear();
    examResults.clear();
    _dailyCounts.clear();
    _metDays.clear();
    _saveDaily();
    await ContentRepository.instance.clearLocalProgress();
    await ContentRepository.instance.signOutRemote();
    continueAsGuest();
  }

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
    _bumpDaily();
    if (persist) {
      _persist(ContentRepository.instance.saveQuestionAnswer(q, correct));
      _saveDaily();
    }
    if (notify) notifyListeners();
  }

  // ---------- Intego ya buri munsi ----------
  static const List<int> goalChoices = <int>[5, 10, 20, 30];

  /// Umubare w'ibibazo umukoresha ashaka gukora buri munsi.
  int dailyGoal = 10;
  final Map<String, int> _dailyCounts = <String, int>{};
  final Set<String> _metDays = <String>{};
  bool _goalJustReached = false;

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int get answeredToday => _dailyCounts[_dayKey(DateTime.now())] ?? 0;
  bool get goalReachedToday => answeredToday >= dailyGoal;
  double get goalProgress =>
      dailyGoal == 0 ? 0 : (answeredToday / dailyGoal).clamp(0.0, 1.0);

  /// Iminsi ikurikiranye intego yuzuye. Iyo intego y'uyu munsi itaruzura,
  /// umurongo ukomeza kubarwa kugeza ejo, ntiwangirika kugeza umunsi urangiye.
  int get streak {
    final DateTime now = DateTime.now();
    DateTime day = DateTime(now.year, now.month, now.day);
    if (!_metDays.contains(_dayKey(day))) {
      day = DateTime(day.year, day.month, day.day - 1);
    }
    int n = 0;
    while (_metDays.contains(_dayKey(day))) {
      n++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return n;
  }

  void _bumpDaily() {
    final String key = _dayKey(DateTime.now());
    final int count = (_dailyCounts[key] ?? 0) + 1;
    _dailyCounts[key] = count;
    if (count >= dailyGoal && _metDays.add(key)) _goalJustReached = true;
  }

  /// True once, right after the answer that completed today's goal.
  bool consumeGoalReached() {
    final bool v = _goalJustReached;
    _goalJustReached = false;
    return v;
  }

  void setDailyGoal(int goal) {
    dailyGoal = goal;
    // A lower goal may already be done today; that counts, without a fanfare.
    if (answeredToday >= goal) _metDays.add(_dayKey(DateTime.now()));
    unawaited(ContentRepository.instance.saveSetting('daily_goal', '$goal'));
    _saveDaily();
    notifyListeners();
  }

  void _restoreDaily() {
    final ContentRepository repo = ContentRepository.instance;
    dailyGoal = int.tryParse(repo.setting('daily_goal') ?? '') ?? 10;
    for (final String part in (repo.setting('daily_counts') ?? '').split(';')) {
      final List<String> kv = part.split(':');
      if (kv.length == 2) {
        final int? n = int.tryParse(kv[1]);
        if (n != null) _dailyCounts[kv[0]] = n;
      }
    }
    _metDays.addAll((repo.setting('daily_met') ?? '')
        .split(',')
        .where((String s) => s.isNotEmpty));
  }

  void _saveDaily() {
    // Keep only the recent days so the saved text stays small.
    final List<String> days = _dailyCounts.keys.toList()..sort();
    for (final String d
        in days.take((days.length - 14).clamp(0, days.length))) {
      _dailyCounts.remove(d);
    }
    final List<String> met = _metDays.toList()..sort();
    for (final String d in met.take((met.length - 120).clamp(0, met.length))) {
      _metDays.remove(d);
    }
    final ContentRepository repo = ContentRepository.instance;
    unawaited(repo.saveSetting(
        'daily_counts',
        _dailyCounts.entries
            .map((MapEntry<String, int> e) => '${e.key}:${e.value}')
            .join(';')));
    unawaited(repo.saveSetting('daily_met', _metDays.join(',')));
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
    _saveDaily();
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
