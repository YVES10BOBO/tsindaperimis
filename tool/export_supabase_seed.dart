import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';

import 'package:amategeko_app/data/categories_data.dart';
import 'package:amategeko_app/data/extended_data.dart';
import 'package:amategeko_app/data/models.dart';
import 'package:amategeko_app/data/more_questions.dart';
import 'package:amategeko_app/data/pdf_reference_data.dart';
import 'package:amategeko_app/data/questions_data.dart';

String sql(String value) => "'${value.replaceAll("'", "''")}'";
String nullable(String? value) => value == null ? 'NULL' : sql(value);
String boolSql(bool value) => value ? 'true' : 'false';

String buildSeedSql() {
  final out = StringBuffer(
    '-- Generated from the bundled Flutter content. Re-run with:\n'
    '-- flutter run -d windows -t tool/export_supabase_seed.dart\n'
    'begin;\n',
  );
  final questions = <Question>[
    ...questionBank,
    ...vehicleQuestions,
    ...drivingQuestions,
    ...moreQuestions,
    ...pdfQuestionBank,
  ];

  for (var ci = 0; ci < learnCategories.length; ci++) {
    final category = learnCategories[ci];
    out.writeln(
      'insert into public.content_categories '
      '(id,title,subtitle,icon_code,icon_font_family,icon_font_package,'
      'color_value,soft_color_value,sort_order,published) values '
      '(${sql(category.id)},${sql(category.title)},${sql(category.subtitle)},'
      '${category.icon.codePoint},${nullable(category.icon.fontFamily)},'
      '${nullable(category.icon.fontPackage)},${category.color.toARGB32()},'
      '${category.softColor.toARGB32()},$ci,true) on conflict (id) do update set '
      'title=excluded.title,subtitle=excluded.subtitle,icon_code=excluded.icon_code,'
      'icon_font_family=excluded.icon_font_family,'
      'icon_font_package=excluded.icon_font_package,color_value=excluded.color_value,'
      'soft_color_value=excluded.soft_color_value,sort_order=excluded.sort_order,'
      'published=true;',
    );
    for (var li = 0; li < category.lessons.length; li++) {
      final lesson = category.lessons[li];
      out.writeln(
        'insert into public.lessons '
        '(id,category_id,title,minutes,sort_order,is_extra,published) values '
        '(${sql(lesson.id)},${sql(category.id)},${sql(lesson.title)},'
        '${lesson.minutes},$li,${boolSql(lesson.isExtra)},true) '
        'on conflict (id) do update set category_id=excluded.category_id,'
        'title=excluded.title,minutes=excluded.minutes,sort_order=excluded.sort_order,'
        'is_extra=excluded.is_extra,published=true;',
      );
      for (var si = 0; si < lesson.sections.length; si++) {
        final section = lesson.sections[si];
        out.writeln(
          'insert into public.lesson_sections '
          '(id,lesson_id,position,heading,body,sign_type,sign_label,image_path) values '
          '(${sql('${lesson.id}-$si')},${sql(lesson.id)},$si,'
          '${sql(section.heading)},${sql(section.body)},'
          '${nullable(section.sign?.name)},${nullable(section.signLabel)},'
          '${nullable(section.imagePath)}) '
          'on conflict (id) do update set lesson_id=excluded.lesson_id,'
          'position=excluded.position,heading=excluded.heading,body=excluded.body,'
          'sign_type=excluded.sign_type,sign_label=excluded.sign_label,'
          'image_path=excluded.image_path;',
        );
      }
    }
  }

  for (var qi = 0; qi < questions.length; qi++) {
    final question = questions[qi];
    out.writeln(
      'insert into public.questions '
      '(id,category_id,prompt,explanation,sign_type,sign_label,'
      'is_exam_question,sort_order,published) values '
      '(${sql(question.id)},${sql(question.categoryId)},${sql(question.text)},'
      '${sql(question.explanation)},${nullable(question.sign?.name)},'
      '${nullable(question.signLabel)},${boolSql(question.isExamQuestion)},$qi,true) '
      'on conflict (id) do update set category_id=excluded.category_id,'
      'prompt=excluded.prompt,explanation=excluded.explanation,'
      'sign_type=excluded.sign_type,sign_label=excluded.sign_label,'
      'is_exam_question=excluded.is_exam_question,sort_order=excluded.sort_order,'
      'published=true;',
    );
    for (var oi = 0; oi < question.options.length; oi++) {
      out.writeln(
        'insert into public.question_options '
        '(id,question_id,position,option_text,is_correct) values '
        '(${sql('${question.id}-$oi')},${sql(question.id)},$oi,'
        '${sql(question.options[oi])},${boolSql(oi == question.correctIndex)}) '
        'on conflict (id) do update set question_id=excluded.question_id,'
        'position=excluded.position,option_text=excluded.option_text,'
        'is_correct=excluded.is_correct;',
      );
    }
  }
  out.writeln('commit;');

  return out.toString();
}

void main() => runApp(const SeedExporterApp());

class SeedExporterApp extends StatelessWidget {
  const SeedExporterApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Export Supabase content')),
          body: Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download seed.sql'),
              onPressed: () {
                final blob = html.Blob(
                    <Object>[utf8.encode(buildSeedSql())], 'text/sql');
                final url = html.Url.createObjectUrlFromBlob(blob);
                html.AnchorElement(href: url)
                  ..download = 'seed.sql'
                  ..click();
                html.Url.revokeObjectUrl(url);
              },
            ),
          ),
        ),
      );
}
