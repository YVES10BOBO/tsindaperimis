import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../data/content_repository.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'exam_screens.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  String _advice(AppState state, ContentRepository repo) {
    if (state.totalAnswered == 0 && state.completedLessons.isEmpty) {
      return 'Tangira wiga isomo rya mbere, hanyuma ukore imyitozo.';
    }
    LearnCategory? weakest;
    double low = 2;
    for (final LearnCategory c in repo.categories) {
      final double lessons = c.lessons.isEmpty ? 0 : state.completedIn(c) / c.lessons.length;
      final double score = (lessons + state.categoryAccuracy(c.id)) / 2;
      if (score < low) {
        low = score;
        weakest = c;
      }
    }
    return weakest == null
        ? 'Komeza utyo!'
        : 'Subiramo "${weakest.title}" kugira ngo urusheho kwitegura.';
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final ContentRepository repo = ContentRepository.instance;
    final double readiness = state.readiness;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: <Widget>[
          Text('Iterambere ryawe',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          SizedBox(height: 16),
          AppCard(
            child: Row(
              children: <Widget>[
                ProgressRing(value: readiness, size: 104, stroke: 11, fontSize: 24),
                SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        readiness >= 0.8
                            ? 'Witeguye neza!'
                            : (readiness >= 0.5 ? 'Uri mu nzira nziza' : 'Komeza wige'),
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 6),
                      Text(_advice(state, repo),
                          style: TextStyle(color: AppColors.muted, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: <Widget>[
              StatTile(
                  value: '${state.completedLessons.length}/${repo.totalLessons}',
                  label: 'Amasomo warangije'),
              StatTile(value: '${state.totalAnswered}', label: 'Ibibazo wakoze'),
              StatTile(value: '${state.examResults.length}', label: 'Ibizamini wakoze'),
              StatTile(
                  value: '${(state.averageExamRatio * 100).round()}%',
                  label: 'Impuzandengo y\'ibizamini'),
            ],
          ),
          SizedBox(height: 20),
          SectionTitle('Uko uhagaze muri buri cyiciro'),
          SizedBox(height: 8),
          AppCard(
            child: Column(
              children: <Widget>[
                for (final LearnCategory c in repo.categories) ...<Widget>[
                  _CategoryProgress(category: c, state: state),
                  if (c != repo.categories.last) SizedBox(height: 14),
                ],
              ],
            ),
          ),
          SizedBox(height: 20),
          SectionTitle('Ibizamini biheruka'),
          SizedBox(height: 8),
          if (state.examResults.isEmpty)
            EmptyState(
              icon: Icons.assignment_outlined,
              title: 'Nta kizamini urakora',
              message: 'Kora ikizamini cy\'igerageza urebe uko witeguye.',
            )
          else
            for (final ExamResult r in state.examResults.take(5))
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: ExamHistoryTile(result: r),
              ),
        ],
      ),
    );
  }
}

class _CategoryProgress extends StatelessWidget {
  const _CategoryProgress({required this.category, required this.state});

  final LearnCategory category;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final int done = state.completedIn(category);
    final int total = category.lessons.length;
    final double acc = state.categoryAccuracy(category.id);
    final int answered = state.answeredByCategory[category.id] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(category.icon, color: category.color, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(category.title,
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            Text(answered == 0 ? '—' : '${(acc * 100).round()}%',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        SizedBox(height: 6),
        AppProgressBar(value: total == 0 ? 0 : done / total, color: category.color),
        SizedBox(height: 4),
        Text('Amasomo $done/$total · Ibibazo $answered',
            style: TextStyle(fontSize: 12, color: AppColors.muted)),
      ],
    );
  }
}
