import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../data/content_repository.dart';
import '../data/exam_scope.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'lesson_screen.dart';
import 'practice_screens.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, required this.category});

  final LearnCategory category;

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final int done = state.completedIn(category);
    final int total = category.lessons.length;
    final List<Question> questions =
        ContentRepository.instance.questionsFor(category.id);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: <Widget>[
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(color: AppColors.tint(category.color, category.softColor), shape: BoxShape.circle),
              child: Icon(category.icon, color: category.color, size: 44),
            ),
          ),
          SizedBox(height: 14),
          Text(category.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text(category.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 14.5)),
          SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: Text('Amasomo $done kuri $total',
                    style: TextStyle(color: AppColors.muted, fontSize: 13.5)),
              ),
              Text('${total == 0 ? 0 : (done * 100 / total).round()}%',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 8),
          AppProgressBar(value: total == 0 ? 0 : done / total, color: category.color),
          SizedBox(height: 20),
          SectionTitle('Amasomo'),
          SizedBox(height: 8),
          for (int i = 0; i < category.lessons.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: _LessonRow(
                index: i,
                lesson: category.lessons[i],
                done: state.isLessonDone(category.lessons[i].id),
                color: category.color,
              ),
            ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: questions.isEmpty
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PracticeQuizScreen(
                          title: category.title,
                          source: questions,
                        ),
                      ),
                    ),
            icon: Icon(Icons.edit_note),
            label: Text('Kora imyitozo kuri iki cyiciro (${questions.length})'),
          ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.index,
    required this.lesson,
    required this.done,
    required this.color,
  });

  final int index;
  final Lesson lesson;
  final bool done;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 14,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => LessonScreen(lesson: lesson)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? AppColors.successSoft : AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: done
                ? Icon(Icons.check, color: AppColors.success, size: 20)
                : Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(lesson.title,
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                if (isExtraLesson(lesson)) ...<Widget>[
                  SizedBox(height: 4),
                  ExtraKnowledgeBadge(compact: true),
                  SizedBox(height: 2),
                ],
                Text(done ? 'Byarangiye' : 'Iminota ${lesson.minutes}',
                    style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}
