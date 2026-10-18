import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../data/content_repository.dart';
import '../data/exam_scope.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/road_sign.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final LearnCategory category =
        ContentRepository.instance.categoryById(lesson.categoryId);
    final bool bookmarked = state.isLessonBookmarked(lesson.id);
    final bool done = state.isLessonDone(lesson.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        actions: <Widget>[
          IconButton(
            tooltip: 'Umva isomo',
            icon: Icon(Icons.volume_up_outlined),
            onPressed: () => showComingSoon(
                context, 'Amajwi mu Kinyarwanda azongerwamo vuba.'),
          ),
          IconButton(
            tooltip: bookmarked ? 'Kuramo mu byabitswe' : 'Bika',
            icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: bookmarked ? AppColors.primary : null),
            onPressed: () => state.toggleLessonBookmark(lesson.id),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(category.icon, color: category.color, size: 18),
              SizedBox(width: 6),
              Text(category.title,
                  style: TextStyle(color: category.color, fontWeight: FontWeight.w600)),
              Spacer(),
              Text('Iminota ${lesson.minutes}',
                  style: TextStyle(color: AppColors.muted, fontSize: 13)),
            ],
          ),
          if (isExtraLesson(lesson)) ...<Widget>[
            SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: ExtraKnowledgeBadge()),
          ],
          SizedBox(height: 16),
          for (final LessonSection s in lesson.sections)
            Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (s.sign != null) ...<Widget>[
                      Center(child: RoadSign(type: s.sign!, size: 104, label: s.signLabel)),
                      SizedBox(height: 14),
                    ],
                    Text(s.heading,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    SizedBox(height: 6),
                    Text(s.body,
                        style: TextStyle(fontSize: 15.5, height: 1.55, color: AppColors.bodyText)),
                  ],
                ),
              ),
            ),
          SizedBox(height: 6),
          if (done)
            AppCard(
              color: AppColors.successSoft,
              borderColor: AppColors.successBorder,
              child: Row(
                children: <Widget>[
                  Icon(Icons.check_circle, color: AppColors.success),
                  SizedBox(width: 10),
                  Text('Warangije iri somo',
                      style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                state.completeLesson(lesson.id);
                Navigator.of(context).pop();
              },
              child: Text('Narangije iri somo'),
            ),
        ],
      ),
    );
  }
}
