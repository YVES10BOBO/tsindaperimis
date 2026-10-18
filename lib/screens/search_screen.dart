import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../data/content_repository.dart';
import '../data/models.dart';
import '../widgets/common.dart';
import 'category_screen.dart';
import 'lesson_screen.dart';

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
              hintText: 'Shakisha...',
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
              title: 'Shakisha ibyo ushaka kwiga',
              message: 'Urugero: "STOP", "umuvuduko", "rond-point", "amatara".',
            )
          : (cats.isEmpty && lessons.isEmpty)
              ? EmptyState(
                  icon: Icons.search_off,
                  title: 'Nta byabonetse',
                  message: 'Nta kintu kijyanye na "$_query". Gerageza irindi jambo.',
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: <Widget>[
                    if (cats.isNotEmpty) ...<Widget>[
                      SectionTitle('Ibyiciro'),
                      for (final LearnCategory c in cats)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: IconBadge(icon: c.icon, color: c.color, background: AppColors.tint(c.color, c.softColor), size: 40),
                          title: Text(c.title),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => CategoryScreen(category: c)),
                          ),
                        ),
                      SizedBox(height: 12),
                    ],
                    if (lessons.isNotEmpty) ...<Widget>[
                      SectionTitle('Amasomo'),
                      for (final Lesson l in lessons)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.article_outlined, color: AppColors.primary),
                          title: Text(l.title),
                          subtitle: Text(repo.categoryById(l.categoryId).title),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => LessonScreen(lesson: l)),
                          ),
                        ),
                    ],
                  ],
                ),
    );
  }
}
