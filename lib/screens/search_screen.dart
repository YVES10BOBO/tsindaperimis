import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../data/content_repository.dart';
import '../data/models.dart';
import '../widgets/common.dart';
import '../widgets/question_report.dart';
import 'category_screen.dart';
import 'lesson_screen.dart';

/// Gushakisha muri app yose: ibyiciro, amasomo n'ibibazo ("#57" ku kibazo kimwe).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ContentRepository repo = ContentRepository.instance;
    final List<LearnCategory> cats = repo.searchCategories(_query);
    final List<Lesson> lessons = repo.searchLessons(_query);
    final List<Question> questions = repo.searchQuestions(_query);

    // One flat list of headers and results, built lazily as the learner scrolls.
    final List<Widget Function()> rows = <Widget Function()>[
      if (cats.isNotEmpty) () => SectionTitle('Ibyiciro (${cats.length})'),
      for (final LearnCategory c in cats)
        () => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: IconBadge(
                  icon: c.icon,
                  color: c.color,
                  background: AppColors.tint(c.color, c.softColor),
                  size: 40),
              title: Text(c.title),
              trailing: Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => CategoryScreen(category: c)),
              ),
            ),
      if (lessons.isNotEmpty)
        () => Padding(
              padding: EdgeInsets.only(top: cats.isEmpty ? 0 : 12),
              child: SectionTitle('Amasomo (${lessons.length})'),
            ),
      for (final Lesson l in lessons)
        () => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.article_outlined, color: AppColors.primary),
              title: Text(l.title),
              subtitle: Text(repo.categoryById(l.categoryId).title),
              trailing: Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => LessonScreen(lesson: l)),
              ),
            ),
      if (questions.isNotEmpty)
        () => Padding(
              padding: EdgeInsets.only(
                  top: cats.isEmpty && lessons.isEmpty ? 0 : 12),
              child: SectionTitle('Ibibazo (${questions.length})'),
            ),
      for (final Question q in questions)
        () => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.quiz_outlined, color: AppColors.primary),
              title: Text(q.text, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                q.number != null
                    ? '#${q.number} · ${q.correctAnswer}'
                    : q.correctAnswer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () => showQuestionPreview(context, q),
            ),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (String v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Shakisha amasomo, ibibazo...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Siba',
                      icon: Icon(Icons.close),
                      onPressed: () => setState(() {
                        _controller.clear();
                        _query = '';
                      }),
                    ),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: _query.trim().isEmpty
          ? EmptyState(
              icon: Icons.manage_search,
              title: 'Shakisha muri app yose',
              message:
                  'Amasomo, ibyiciro n\'ibibazo. Urugero: "STOP", "umuvuduko", "rond-point", cyangwa kode y\'ikibazo nka "#57".',
            )
          : rows.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  title: 'Nta byabonetse',
                  message:
                      'Nta kintu kijyanye na "$_query". Gerageza irindi jambo.',
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: rows.length,
                  itemBuilder: (BuildContext context, int i) => rows[i](),
                ),
    );
  }
}
