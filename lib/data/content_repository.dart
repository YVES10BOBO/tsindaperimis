import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'categories_data.dart';
import 'exam_scope.dart';
import 'extended_data.dart';
import 'models.dart';
import 'more_questions.dart';
import 'questions_data.dart';

/// Offline-first content store. Bundled content is written to SQLite once;
/// when Supabase is configured, published rows refresh that local cache.
class ContentRepository {
  ContentRepository._();

  static final ContentRepository instance = ContentRepository._();
  final Random _random = Random();
  Database? _db;
  Future<void> _progressQueue = Future<void>.value();
  List<LearnCategory> _categories = learnCategories;
  List<Question> _all = <Question>[
    ...questionBank,
    ...vehicleQuestions,
    ...drivingQuestions,
    ...moreQuestions,
  ];

  List<LearnCategory> get categories => _categories;
  List<Question> get allQuestions => _all;
  List<Question> get examQuestions => _all.where(isExamQuestion).toList();
  List<AppNotification> get notifications => sampleNotifications;
  List<Lesson> get allLessons => <Lesson>[
        for (final c in _categories) ...c.lessons,
      ];
  int get totalLessons => allLessons.length;

  /// Load local content before the UI starts. Network refresh is bounded and
  /// failures leave the bundled/SQLite copy available for offline use.
  Future<void> initialize() async {
    if (!kIsWeb) {
      try {
        final dir = await getDatabasesPath();
        _db = await openDatabase(
          p.join(dir, 'amategeko_content.db'),
          version: 2,
          onCreate: (db, _) async {
            await db.execute(
                'CREATE TABLE categories (id TEXT PRIMARY KEY, title TEXT, subtitle TEXT, icon_code INTEGER, icon_font TEXT, icon_package TEXT, color INTEGER, soft_color INTEGER, sort_order INTEGER)');
            await db.execute(
                'CREATE TABLE lessons (id TEXT PRIMARY KEY, category_id TEXT, title TEXT, minutes INTEGER, sort_order INTEGER, is_extra INTEGER)');
            await db.execute(
                'CREATE TABLE sections (id TEXT PRIMARY KEY, lesson_id TEXT, position INTEGER, heading TEXT, body TEXT, sign_type TEXT, sign_label TEXT)');
            await db.execute(
                'CREATE TABLE questions (id TEXT PRIMARY KEY, category_id TEXT, prompt TEXT, explanation TEXT, sign_type TEXT, sign_label TEXT, is_exam_question INTEGER, sort_order INTEGER)');
            await db.execute(
                'CREATE TABLE options (id TEXT PRIMARY KEY, question_id TEXT, position INTEGER, option_text TEXT, is_correct INTEGER)');
            await _createProgressTables(db);
          },
          onUpgrade: (db, oldVersion, _) async {
            if (oldVersion < 2) await _createProgressTables(db);
          },
        );
        await _seedSqliteIfEmpty();
        await _loadSqlite();
      } catch (_) {
        // Keep bundled content on unsupported devices or a corrupt old cache.
      }
    }
    await _refreshFromSupabase();
  }

  Future<void> _createProgressTables(DatabaseExecutor db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS completed_lessons (lesson_id TEXT PRIMARY KEY)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS bookmarks (kind TEXT NOT NULL, item_id TEXT NOT NULL, PRIMARY KEY(kind, item_id))');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS question_stats (category_id TEXT PRIMARY KEY, answered INTEGER NOT NULL, correct INTEGER NOT NULL)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS wrong_questions (question_id TEXT PRIMARY KEY)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS exam_history (id INTEGER PRIMARY KEY AUTOINCREMENT, date_ms INTEGER NOT NULL, payload TEXT NOT NULL)');
  }

  Future<Map<String, dynamic>> loadProgress() async {
    final db = _db;
    if (db == null) return <String, dynamic>{};
    final completed = await db.query('completed_lessons');
    final bookmarks = await db.query('bookmarks');
    final stats = await db.query('question_stats');
    final wrong = await db.query('wrong_questions');
    final history = await db.query('exam_history', orderBy: 'date_ms DESC');
    return <String, dynamic>{
      'completedLessons':
          completed.map((r) => r['lesson_id'] as String).toList(),
      'bookmarkedLessons': bookmarks
          .where((r) => r['kind'] == 'lesson')
          .map((r) => r['item_id'] as String)
          .toList(),
      'bookmarkedQuestions': bookmarks
          .where((r) => r['kind'] == 'question')
          .map((r) => r['item_id'] as String)
          .toList(),
      'answeredByCategory': <String, int>{
        for (final row in stats)
          row['category_id'] as String: row['answered'] as int,
      },
      'correctByCategory': <String, int>{
        for (final row in stats)
          row['category_id'] as String: row['correct'] as int,
      },
      'wrongQuestions': wrong.map((r) => r['question_id'] as String).toList(),
      'examResults': history
          .map((r) => _examResultFromJson(
              jsonDecode(r['payload'] as String) as Map<String, dynamic>))
          .toList(),
    };
  }

  /// Pull a user's cloud snapshot and merge additive progress into this device.
  /// Bookmark state follows the cloud snapshot so removals sync as well.
  Future<Map<String, dynamic>?> syncProgressWithSupabase() async {
    final db = _db;
    if (db == null) return null;
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return null;
      final row = await client
          .from('user_progress')
          .select('progress')
          .eq('user_id', user.id)
          .maybeSingle();
      final local = await loadProgress();
      final cloud = row?['progress'];
      if (cloud is Map) {
        final remote = Map<String, dynamic>.from(cloud);
        final merged = _mergeProgress(local, remote);
        await _storeProgressSnapshot(merged);
        await client.from('user_progress').upsert({
          'user_id': user.id,
          'progress': _progressJson(merged),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
        return merged;
      }
      await client.from('user_progress').upsert({
        'user_id': user.id,
        'progress': _progressJson(local),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      return local;
    } catch (error) {
      debugPrint(
          'Progress cloud sync failed; keeping offline progress ($error).');
      return null;
    }
  }

  Future<void> pushProgressSnapshot() {
    _progressQueue = _progressQueue.then((_) async {
      try {
        final client = Supabase.instance.client;
        final user = client.auth.currentUser;
        if (user == null) return;
        final progress = await loadProgress();
        await client.from('user_progress').upsert({
          'user_id': user.id,
          'progress': _progressJson(progress),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (error) {
        debugPrint(
            'Progress upload failed; it will remain on this device ($error).');
      }
    });
    return _progressQueue;
  }

  Map<String, dynamic> _progressJson(Map<String, dynamic> progress) =>
      <String, dynamic>{
        'completedLessons': progress['completedLessons'] ?? <String>[],
        'bookmarkedLessons': progress['bookmarkedLessons'] ?? <String>[],
        'bookmarkedQuestions': progress['bookmarkedQuestions'] ?? <String>[],
        'answeredByCategory': progress['answeredByCategory'] ?? <String, int>{},
        'correctByCategory': progress['correctByCategory'] ?? <String, int>{},
        'wrongQuestions': progress['wrongQuestions'] ?? <String>[],
        'examResults': (progress['examResults'] as List<ExamResult>? ?? [])
            .map(_examResultToJson)
            .toList(),
      };

  Map<String, dynamic> _mergeProgress(
      Map<String, dynamic> local, Map<String, dynamic> remote) {
    List<String> union(String key) => <String>{
          ...((local[key] as List<dynamic>?)?.cast<String>() ?? []),
          ...((remote[key] as List<dynamic>?)?.cast<String>() ?? []),
        }.toList();
    Map<String, int> maxCounts(String key) {
      final a = Map<String, dynamic>.from(local[key] as Map? ?? {});
      final b = Map<String, dynamic>.from(remote[key] as Map? ?? {});
      return <String, int>{
        for (final id in <String>{...a.keys, ...b.keys})
          id: ((a[id] as num?)?.toInt() ?? 0)
              .clamp((b[id] as num?)?.toInt() ?? 0, 0x7fffffff),
      };
    }

    final exams = <String, Map<String, dynamic>>{};
    for (final raw in <dynamic>[
      ...((local['examResults'] as List<dynamic>?) ?? []),
      ...((remote['examResults'] as List<dynamic>?) ?? []),
    ]) {
      final json = raw is ExamResult
          ? _examResultToJson(raw)
          : Map<String, dynamic>.from(raw as Map);
      exams[json['date'] as String] = json;
    }
    return <String, dynamic>{
      'completedLessons': union('completedLessons'),
      'bookmarkedLessons': remote.containsKey('bookmarkedLessons')
          ? (remote['bookmarkedLessons'] as List<dynamic>).cast<String>()
          : union('bookmarkedLessons'),
      'bookmarkedQuestions': remote.containsKey('bookmarkedQuestions')
          ? (remote['bookmarkedQuestions'] as List<dynamic>).cast<String>()
          : union('bookmarkedQuestions'),
      'answeredByCategory': maxCounts('answeredByCategory'),
      'correctByCategory': maxCounts('correctByCategory'),
      'wrongQuestions': union('wrongQuestions'),
      'examResults': exams.values.map(_examResultFromJson).toList()
        ..sort((a, b) => b.date.compareTo(a.date)),
    };
  }

  Future<void> _storeProgressSnapshot(Map<String, dynamic> snapshot) async {
    final db = _db;
    if (db == null) return;
    await db.transaction((tx) async {
      await tx.delete('completed_lessons');
      await tx.delete('bookmarks');
      await tx.delete('question_stats');
      await tx.delete('wrong_questions');
      await tx.delete('exam_history');
      for (final id
          in (snapshot['completedLessons'] as List<dynamic>).cast<String>()) {
        await tx.insert('completed_lessons', {'lesson_id': id});
      }
      for (final kind in ['lesson', 'question']) {
        final key =
            kind == 'lesson' ? 'bookmarkedLessons' : 'bookmarkedQuestions';
        for (final id in (snapshot[key] as List<dynamic>).cast<String>()) {
          await tx.insert('bookmarks', {'kind': kind, 'item_id': id});
        }
      }
      final answered =
          Map<String, int>.from(snapshot['answeredByCategory'] as Map);
      final correct =
          Map<String, int>.from(snapshot['correctByCategory'] as Map);
      for (final id in <String>{...answered.keys, ...correct.keys}) {
        await tx.insert('question_stats', {
          'category_id': id,
          'answered': answered[id] ?? 0,
          'correct': correct[id] ?? 0,
        });
      }
      for (final id
          in (snapshot['wrongQuestions'] as List<dynamic>).cast<String>()) {
        await tx.insert('wrong_questions', {'question_id': id});
      }
      for (final result in (snapshot['examResults'] as List<ExamResult>)) {
        await tx.insert('exam_history', {
          'date_ms': result.date.millisecondsSinceEpoch,
          'payload': jsonEncode(_examResultToJson(result)),
        });
      }
    });
  }

  Future<void> saveCompletedLesson(String id, bool completed) async {
    final db = _db;
    if (db == null) return;
    if (completed) {
      await db.insert('completed_lessons', {'lesson_id': id},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    } else {
      await db
          .delete('completed_lessons', where: 'lesson_id = ?', whereArgs: [id]);
    }
  }

  Future<void> saveBookmark(String kind, String id, bool bookmarked) async {
    final db = _db;
    if (db == null) return;
    if (bookmarked) {
      await db.insert('bookmarks', {'kind': kind, 'item_id': id},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    } else {
      await db.delete('bookmarks',
          where: 'kind = ? AND item_id = ?', whereArgs: [kind, id]);
    }
  }

  Future<void> saveQuestionAnswer(Question question, bool correct) async {
    final db = _db;
    if (db == null) return;
    await db.transaction((tx) async {
      await tx.rawInsert(
        'INSERT INTO question_stats(category_id, answered, correct) VALUES(?, 1, ?) '
        'ON CONFLICT(category_id) DO UPDATE SET answered = answered + 1, correct = correct + excluded.correct',
        [question.categoryId, correct ? 1 : 0],
      );
      if (correct) {
        await tx.delete('wrong_questions',
            where: 'question_id = ?', whereArgs: [question.id]);
      } else {
        await tx.insert('wrong_questions', {'question_id': question.id},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  Future<void> saveExamResult(ExamResult result) async {
    final db = _db;
    if (db == null) return;
    final payload = jsonEncode(_examResultToJson(result));
    await db.transaction((tx) async {
      await tx.insert('exam_history', {
        'date_ms': result.date.millisecondsSinceEpoch,
        'payload': payload,
      });
      for (var i = 0; i < result.questions.length; i++) {
        final answer = result.answers[i];
        if (answer == null) continue;
        final question = result.questions[i];
        final correct = result.isCorrect(i);
        await tx.rawInsert(
          'INSERT INTO question_stats(category_id, answered, correct) VALUES(?, 1, ?) '
          'ON CONFLICT(category_id) DO UPDATE SET answered = answered + 1, correct = correct + excluded.correct',
          [question.categoryId, correct ? 1 : 0],
        );
        if (correct) {
          await tx.delete('wrong_questions',
              where: 'question_id = ?', whereArgs: [question.id]);
        } else {
          await tx.insert('wrong_questions', {'question_id': question.id},
              conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    });
  }

  Map<String, dynamic> _examResultToJson(ExamResult result) =>
      <String, dynamic>{
        'date': result.date.toIso8601String(),
        'timeUsedMs': result.timeUsed.inMilliseconds,
        'passScore': result.passScore,
        'answers': result.answers,
        'questions': result.questions
            .map((q) => <String, dynamic>{
                  'id': q.id,
                  'categoryId': q.categoryId,
                  'text': q.text,
                  'options': q.options,
                  'correctIndex': q.correctIndex,
                  'explanation': q.explanation,
                  'sign': q.sign?.name,
                  'signLabel': q.signLabel,
                  'isExamQuestion': q.isExamQuestion,
                })
            .toList(),
      };

  ExamResult _examResultFromJson(Map<String, dynamic> json) => ExamResult(
        date: DateTime.parse(json['date'] as String),
        timeUsed: Duration(milliseconds: json['timeUsedMs'] as int),
        passScore: json['passScore'] as int,
        answers: (json['answers'] as List<dynamic>).cast<int?>(),
        questions: (json['questions'] as List<dynamic>).map((raw) {
          final q = raw as Map<String, dynamic>;
          return Question(
            id: q['id'] as String,
            categoryId: q['categoryId'] as String,
            text: q['text'] as String,
            options: (q['options'] as List<dynamic>).cast<String>(),
            correctIndex: q['correctIndex'] as int,
            explanation: q['explanation'] as String,
            sign: _sign(q['sign'] as String?),
            signLabel: q['signLabel'] as String?,
            isExamQuestion: q['isExamQuestion'] as bool,
          );
        }).toList(),
      );

  Future<void> _seedSqliteIfEmpty() async {
    final db = _db;
    if (db == null ||
        Sqflite.firstIntValue(
                await db.rawQuery('SELECT COUNT(*) FROM categories')) !=
            0) return;
    await db.transaction((tx) async {
      for (var ci = 0; ci < _categories.length; ci++) {
        final c = _categories[ci];
        await tx.insert('categories', {
          'id': c.id,
          'title': c.title,
          'subtitle': c.subtitle,
          'icon_code': c.icon.codePoint,
          'icon_font': c.icon.fontFamily,
          'icon_package': c.icon.fontPackage,
          'color': c.color.toARGB32(),
          'soft_color': c.softColor.toARGB32(),
          'sort_order': ci
        });
        for (var li = 0; li < c.lessons.length; li++) {
          final l = c.lessons[li];
          await tx.insert('lessons', {
            'id': l.id,
            'category_id': c.id,
            'title': l.title,
            'minutes': l.minutes,
            'sort_order': li,
            'is_extra': l.isExtra ? 1 : 0
          });
          for (var si = 0; si < l.sections.length; si++) {
            final s = l.sections[si];
            await tx.insert('sections', {
              'id': '${l.id}-$si',
              'lesson_id': l.id,
              'position': si,
              'heading': s.heading,
              'body': s.body,
              'sign_type': s.sign?.name,
              'sign_label': s.signLabel
            });
          }
        }
      }
      for (var qi = 0; qi < _all.length; qi++) {
        final q = _all[qi];
        await tx.insert('questions', {
          'id': q.id,
          'category_id': q.categoryId,
          'prompt': q.text,
          'explanation': q.explanation,
          'sign_type': q.sign?.name,
          'sign_label': q.signLabel,
          'is_exam_question': q.isExamQuestion ? 1 : 0,
          'sort_order': qi
        });
        for (var oi = 0; oi < q.options.length; oi++) {
          await tx.insert('options', {
            'id': '${q.id}-$oi',
            'question_id': q.id,
            'position': oi,
            'option_text': q.options[oi],
            'is_correct': oi == q.correctIndex ? 1 : 0
          });
        }
      }
    });
  }

  Future<void> _loadSqlite() async {
    final db = _db;
    if (db == null) return;
    final cats = await db.query('categories', orderBy: 'sort_order');
    final lessons = await db.query('lessons', orderBy: 'sort_order');
    final sections = await db.query('sections', orderBy: 'position');
    final questions = await db.query('questions', orderBy: 'sort_order');
    final options = await db.query('options', orderBy: 'position');
    _categories = cats.map((c) {
      final childLessons =
          lessons.where((l) => l['category_id'] == c['id']).map((l) {
        final childSections = sections
            .where((s) => s['lesson_id'] == l['id'])
            .map((s) => LessonSection(
                s['heading'] as String, s['body'] as String,
                sign: _sign(s['sign_type'] as String?),
                signLabel: s['sign_label'] as String?))
            .toList();
        return Lesson(
            id: l['id'] as String,
            categoryId: l['category_id'] as String,
            title: l['title'] as String,
            minutes: l['minutes'] as int,
            isExtra: l['is_extra'] == 1,
            sections: childSections);
      }).toList();
      return LearnCategory(
          id: c['id'] as String,
          title: c['title'] as String,
          subtitle: c['subtitle'] as String,
          icon: IconData(c['icon_code'] as int,
              fontFamily: c['icon_font'] as String?,
              fontPackage: c['icon_package'] as String?),
          color: Color(c['color'] as int),
          softColor: Color(c['soft_color'] as int),
          lessons: childLessons);
    }).toList();
    _all = questions.map((q) {
      final opts = options.where((o) => o['question_id'] == q['id']).toList();
      final correct = opts.indexWhere((o) => o['is_correct'] == 1);
      return Question(
          id: q['id'] as String,
          categoryId: q['category_id'] as String,
          text: q['prompt'] as String,
          explanation: q['explanation'] as String,
          options: opts.map((o) => o['option_text'] as String).toList(),
          correctIndex: correct < 0 ? 0 : correct,
          sign: _sign(q['sign_type'] as String?),
          signLabel: q['sign_label'] as String?,
          isExamQuestion: q['is_exam_question'] == 1);
    }).toList();
  }

  Future<void> _refreshFromSupabase() async {
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (url.isEmpty || key.isEmpty) return;
    try {
      final client = Supabase.instance.client;
      final remote = await Future.wait<dynamic>(<Future<dynamic>>[
        client
            .from('content_categories')
            .select()
            .eq('published', true)
            .order('sort_order'),
        client
            .from('lessons')
            .select()
            .eq('published', true)
            .order('sort_order'),
        client.from('lesson_sections').select().order('position'),
        client
            .from('questions')
            .select()
            .eq('published', true)
            .order('sort_order'),
        client.from('question_options').select().order('position'),
      ]).timeout(const Duration(seconds: 8));
      final remoteCategories = remote[0];
      final remoteLessons = remote[1];
      final remoteSections = remote[2];
      final remoteQuestions = remote[3];
      final remoteOptions = remote[4];
      final catList = remoteCategories.cast<Map<String, dynamic>>();
      final lessonList = remoteLessons.cast<Map<String, dynamic>>();
      final sectionList = remoteSections.cast<Map<String, dynamic>>();
      final optionList = remoteOptions.cast<Map<String, dynamic>>();
      final questionsList = remoteQuestions.cast<Map<String, dynamic>>();
      final hydratedCategories = catList
          .map<LearnCategory>((c) => LearnCategory(
                id: c['id'] as String,
                title: c['title'] as String,
                subtitle: c['subtitle'] as String,
                icon: IconData(c['icon_code'] as int,
                    fontFamily: c['icon_font_family'] as String?,
                    fontPackage: c['icon_font_package'] as String?),
                color: Color((c['color_value'] as num).toInt()),
                softColor: Color((c['soft_color_value'] as num).toInt()),
                lessons: lessonList
                    .where((l) => l['category_id'] == c['id'])
                    .map<Lesson>((l) => Lesson(
                          id: l['id'] as String,
                          categoryId: l['category_id'] as String,
                          title: l['title'] as String,
                          minutes: l['minutes'] as int,
                          isExtra: l['is_extra'] == true,
                          sections: sectionList
                              .where((s) => s['lesson_id'] == l['id'])
                              .map<LessonSection>((s) => LessonSection(
                                  s['heading'] as String, s['body'] as String,
                                  sign: _sign(s['sign_type'] as String?),
                                  signLabel: s['sign_label'] as String?))
                              .toList(),
                        ))
                    .toList(),
              ))
          .toList();
      final hydratedQuestions = questionsList.map<Question>((q) {
        final List<Map<String, dynamic>> opts =
            optionList.where((o) => o['question_id'] == q['id']).toList();
        final correct = opts.indexWhere((o) => o['is_correct'] == true);
        return Question(
            id: q['id'] as String,
            categoryId: q['category_id'] as String,
            text: q['prompt'] as String,
            explanation: q['explanation'] as String? ?? '',
            options: opts.map((o) => o['option_text'] as String).toList(),
            correctIndex: correct < 0 ? 0 : correct,
            sign: _sign(q['sign_type'] as String?),
            signLabel: q['sign_label'] as String?,
            isExamQuestion: q['is_exam_question'] as bool? ?? true);
      }).toList();
      if (hydratedCategories.isNotEmpty && hydratedQuestions.isNotEmpty) {
        _categories = hydratedCategories;
        _all = hydratedQuestions;
        await _replaceSqlite(hydratedCategories, hydratedQuestions);
        debugPrint(
          'Supabase content loaded: ${hydratedCategories.length} categories, '
          '${lessonList.length} lessons, ${hydratedQuestions.length} questions.',
        );
      } else {
        debugPrint(
          'Supabase returned no published categories or questions; '
          'keeping bundled/SQLite content.',
        );
      }
    } catch (error) {
      // Supabase is optional; cached data remains usable when offline.
      debugPrint('Supabase content sync failed; using local content ($error).');
    }
  }

  Future<void> _replaceSqlite(
      List<LearnCategory> categories, List<Question> questions) async {
    final db = _db;
    if (db == null) return;
    await db.transaction((tx) async {
      for (final table in [
        'options',
        'questions',
        'sections',
        'lessons',
        'categories'
      ]) {
        await tx.delete(table);
      }
      for (var ci = 0; ci < categories.length; ci++) {
        final c = categories[ci];
        await tx.insert('categories', {
          'id': c.id,
          'title': c.title,
          'subtitle': c.subtitle,
          'icon_code': c.icon.codePoint,
          'icon_font': c.icon.fontFamily,
          'icon_package': c.icon.fontPackage,
          'color': c.color.toARGB32(),
          'soft_color': c.softColor.toARGB32(),
          'sort_order': ci
        });
        for (var li = 0; li < c.lessons.length; li++) {
          final l = c.lessons[li];
          await tx.insert('lessons', {
            'id': l.id,
            'category_id': c.id,
            'title': l.title,
            'minutes': l.minutes,
            'sort_order': li,
            'is_extra': l.isExtra ? 1 : 0
          });
          for (var si = 0; si < l.sections.length; si++) {
            final s = l.sections[si];
            await tx.insert('sections', {
              'id': '${l.id}-$si',
              'lesson_id': l.id,
              'position': si,
              'heading': s.heading,
              'body': s.body,
              'sign_type': s.sign?.name,
              'sign_label': s.signLabel
            });
          }
        }
      }
      for (var qi = 0; qi < questions.length; qi++) {
        final q = questions[qi];
        await tx.insert('questions', {
          'id': q.id,
          'category_id': q.categoryId,
          'prompt': q.text,
          'explanation': q.explanation,
          'sign_type': q.sign?.name,
          'sign_label': q.signLabel,
          'is_exam_question': q.isExamQuestion ? 1 : 0,
          'sort_order': qi
        });
        for (var oi = 0; oi < q.options.length; oi++) {
          await tx.insert('options', {
            'id': '${q.id}-$oi',
            'question_id': q.id,
            'position': oi,
            'option_text': q.options[oi],
            'is_correct': oi == q.correctIndex ? 1 : 0
          });
        }
      }
    });
  }

  SignType? _sign(String? value) => value == null
      ? null
      : SignType.values.where((e) => e.name == value).firstOrNull;

  LearnCategory categoryById(String id) =>
      _categories.firstWhere((c) => c.id == id);
  Lesson? lessonById(String id) {
    for (final l in allLessons) {
      if (l.id == id) return l;
    }
    return null;
  }

  Question? questionById(String id) {
    for (final q in _all) {
      if (q.id == id) return q;
    }
    return null;
  }

  List<Question> questionsFor(String categoryId) =>
      _all.where((q) => q.categoryId == categoryId).toList();

  List<Question> shuffledQuestions(List<Question> source, {int? limit}) {
    final list = List<Question>.of(source)..shuffle(_random);
    final picked =
        limit == null ? list : list.take(min(limit, list.length)).toList();
    return picked.map((q) => q.shuffled(_random)).toList();
  }

  List<Question> buildExam(int count) =>
      shuffledQuestions(examQuestions, limit: count);
  List<Lesson> searchLessons(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return <Lesson>[];
    return allLessons
        .where((l) =>
            l.title.toLowerCase().contains(q) ||
            l.sections.any((s) =>
                s.heading.toLowerCase().contains(q) ||
                s.body.toLowerCase().contains(q)))
        .toList();
  }

  List<LearnCategory> searchCategories(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return <LearnCategory>[];
    return _categories
        .where((c) =>
            c.title.toLowerCase().contains(q) ||
            c.subtitle.toLowerCase().contains(q))
        .toList();
  }
}
