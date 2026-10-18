import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/exam_config.dart';
import '../data/content_repository.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/road_sign.dart';

String formatDuration(Duration d) {
  final String m = d.inMinutes.toString().padLeft(2, '0');
  final String s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

void startExam(BuildContext context, {bool replace = false}) {
  final List<Question> questions =
      ContentRepository.instance.buildExam(ExamConfig.questionCount);
  if (questions.length < ExamConfig.questionCount) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ongeramo ibibazo byemejwe mbere yo gutangira ikizamini.')),
    );
    return;
  }
  final MaterialPageRoute<void> route =
      MaterialPageRoute<void>(builder: (_) => ExamScreen(questions: questions));
  if (replace) {
    Navigator.of(context).pushReplacement(route);
  } else {
    Navigator.of(context).push(route);
  }
}

// =====================================================================
// Intangiriro y'ikizamini (tab)
// =====================================================================
class ExamIntroScreen extends StatelessWidget {
  const ExamIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: <Widget>[
          Text('Ikizamini cy\'igerageza',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text(
            'Gisa n\'ikizamini nyirizina: usubiza ibibazo byose, amanota n\'ibisubizo ukabibona urangije.',
            style: TextStyle(color: AppColors.muted, fontSize: 14.5, height: 1.4),
          ),
          SizedBox(height: 18),
          AppCard(
            color: AppColors.purpleSoft,
            borderColor: AppColors.purpleBorder,
            child: Column(
              children: <Widget>[
                IconBadge(
                    icon: Icons.assignment, color: Colors.white, background: AppColors.purple, size: 56),
                SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(child: _ExamFact(value: '${ExamConfig.questionCount}', label: 'Ibibazo')),
                    Expanded(child: _ExamFact(value: '${ExamConfig.durationMinutes}', label: 'Iminota')),
                    Expanded(
                        child: _ExamFact(
                            value: '${ExamConfig.passScore}/${ExamConfig.questionCount}',
                            label: 'Gutsinda')),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                  onPressed: () => startExam(context),
                  icon: Icon(Icons.play_arrow),
                  label: Text('Tangira ikizamini'),
                ),
              ],
            ),
          ),
          SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Amabwiriza', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                SizedBox(height: 8),
                _Rule('Ibibazo bitoranywa mu bibazwa mu kizamini gusa (nta bumenyi bw\'inyongera bwa mekanike).'),
                _Rule('Ushobora gusimbuka ikibazo ukazakigarukaho.'),
                _Rule('Ikimenyetso "Uzagaruka" kigufasha kwibuka ibibazo ushidikanya.'),
                _Rule('Igihe nikirangira, ikizamini kirangira ubwacyo.'),
                _Rule('Imiterere y\'ikizamini ni iy\'urugero: igenzure n\'amabwiriza ya Polisi.'),
              ],
            ),
          ),
          SizedBox(height: 22),
          SectionTitle('Ibizamini biheruka'),
          SizedBox(height: 8),
          if (state.examResults.isEmpty)
            EmptyState(
              icon: Icons.history,
              title: 'Nta kizamini urakora',
              message: 'Ibisubizo by\'ibizamini byawe bizagaragara hano.',
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

class _ExamFact extends StatelessWidget {
  const _ExamFact({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppColors.muted, fontSize: 13)),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_outline, size: 18, color: AppColors.primary),
          ),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}

class ExamHistoryTile extends StatelessWidget {
  const ExamHistoryTile({super.key, required this.result});

  final ExamResult result;

  @override
  Widget build(BuildContext context) {
    final bool passed = result.passed;
    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 14,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ExamResultScreen(result: result, fromHistory: true)),
      ),
      child: Row(
        children: <Widget>[
          Text('${result.score}/${result.total}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          SizedBox(width: 14),
          Expanded(
            child: Text('${formatDate(result.date)} · ${formatDuration(result.timeUsed)}',
                style: TextStyle(color: AppColors.muted, fontSize: 13)),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: passed ? AppColors.successSoft : AppColors.errorSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(passed ? 'Watsinze' : 'Ntiwatsinze',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: passed ? AppColors.success : AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Ikizamini nyirizina
// =====================================================================
class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key, required this.questions});

  final List<Question> questions;

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  static Duration _limit = Duration(minutes: ExamConfig.durationMinutes);

  late final List<int?> _answers = List<int?>.filled(widget.questions.length, null);
  final Set<int> _flagged = <int>{};
  int _index = 0;
  Duration _left = _limit;
  Timer? _timer;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (!mounted) return;
      if (_left.inSeconds <= 1) {
        t.cancel();
        _submit();
      } else {
        setState(() => _left -= Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _answeredCount => _answers.where((int? a) => a != null).length;

  void _submit() {
    if (_submitted) return;
    _submitted = true;
    _timer?.cancel();
    final ExamResult result = ExamResult(
      date: DateTime.now(),
      questions: widget.questions,
      answers: List<int?>.of(_answers),
      timeUsed: _limit - _left,
      passScore: ExamConfig.passScore,
    );
    AppScope.of(context).addExamResult(result);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => ExamResultScreen(result: result)),
    );
  }

  Future<void> _confirmSubmit() async {
    final int missing = widget.questions.length - _answeredCount;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text('Soza ikizamini?'),
        content: Text(missing > 0
            ? 'Usigaje ibibazo $missing utasubije. Ushaka gusoza?'
            : 'Wasubije ibibazo byose. Ushaka gusoza?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Oya')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Soza')),
        ],
      ),
    );
    if (ok == true) _submit();
  }

  Future<void> _confirmExit() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text('Kuva mu kizamini?'),
        content: Text('Ibisubizo byawe ntibizabikwa.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Guma')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Va mo')),
        ],
      ),
    );
    if (ok == true && mounted) {
      _timer?.cancel();
      Navigator.of(context).pop();
    }
  }

  void _openNavigator() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (BuildContext ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Wasubije $_answeredCount kuri ${widget.questions.length}',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (int i = 0; i < widget.questions.length; i++)
                    _NavCell(
                      number: i + 1,
                      answered: _answers[i] != null,
                      flagged: _flagged.contains(i),
                      current: i == _index,
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() => _index = i);
                      },
                    ),
                ],
              ),
              SizedBox(height: 14),
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: <Widget>[
                  _Legend(color: AppColors.primary, label: 'Wasubije'),
                  _Legend(color: AppColors.warning, label: 'Uzagaruka'),
                  _Legend(color: AppColors.border, label: 'Ntiwasubije'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Question q = widget.questions[_index];
    final int total = widget.questions.length;
    final bool last = _index == total - 1;
    final bool lowTime = _left.inSeconds <= 120;
    final bool flagged = _flagged.contains(_index);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Va mu kizamini',
          icon: Icon(Icons.close),
          onPressed: _confirmExit,
        ),
        title: Text('Ikibazo ${_index + 1} / $total', style: TextStyle(fontSize: 17)),
        actions: <Widget>[
          Center(
            child: Container(
            margin: EdgeInsets.only(right: 12),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: lowTime ? AppColors.error : AppColors.primaryDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.timer_outlined, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(formatDuration(_left),
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontFeatures: <FontFeature>[FontFeature.tabularFigures()])),
              ],
            ),
          ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppProgressBar(value: _answeredCount / total, color: AppColors.purple),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: <Widget>[
                  if (q.sign != null) ...<Widget>[
                    AppCard(child: Center(child: RoadSign(type: q.sign!, size: 112, label: q.signLabel))),
                    SizedBox(height: 16),
                  ],
                  Text(q.text,
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, height: 1.4)),
                  SizedBox(height: 16),
                  for (int i = 0; i < q.options.length; i++)
                    OptionTile(
                      letter: optionLetter(i),
                      text: q.options[i],
                      state: _answers[_index] == i ? OptionState.selected : OptionState.neutral,
                      onTap: () => setState(() => _answers[_index] = i),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: <Widget>[
                  IconButton.outlined(
                    tooltip: 'Ibibazo byose',
                    onPressed: _openNavigator,
                    icon: Icon(Icons.grid_view),
                  ),
                  SizedBox(width: 8),
                  IconButton.outlined(
                    tooltip: flagged ? 'Kuraho "Uzagaruka"' : 'Uzagaruka',
                    style: IconButton.styleFrom(
                      backgroundColor: flagged ? AppColors.warningSoft : null,
                    ),
                    onPressed: () => setState(() {
                      if (!_flagged.remove(_index)) _flagged.add(_index);
                    }),
                    icon: Icon(flagged ? Icons.flag : Icons.outlined_flag,
                        color: flagged ? AppColors.warning : null),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _index == 0 ? null : () => setState(() => _index--),
                      child: Text('Ibanza'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: last
                          ? ElevatedButton.styleFrom(backgroundColor: AppColors.purple)
                          : null,
                      onPressed: last ? _confirmSubmit : () => setState(() => _index++),
                      child: Text(last ? 'Soza' : 'Ikurikira'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  const _NavCell({
    required this.number,
    required this.answered,
    required this.flagged,
    required this.current,
    required this.onTap,
  });

  final int number;
  final bool answered;
  final bool flagged;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.background;
    Color fg = AppColors.text;
    if (answered) {
      bg = AppColors.primary;
      fg = Colors.white;
    }
    if (flagged) {
      bg = AppColors.warning;
      fg = Colors.white;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 48,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: current ? AppColors.purple : AppColors.border, width: current ? 2 : 1),
        ),
        child: Text('$number', style: TextStyle(fontWeight: FontWeight.w700, color: fg)),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, color: AppColors.muted)),
      ],
    );
  }
}

// =====================================================================
// Ibisubizo
// =====================================================================
class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({super.key, required this.result, this.fromHistory = false});

  final ExamResult result;
  final bool fromHistory;

  @override
  Widget build(BuildContext context) {
    final ContentRepository repo = ContentRepository.instance;
    final bool passed = result.passed;
    final int wrong = result.total - result.score;

    // Uko yitwaye muri buri cyiciro
    final Map<String, List<int>> byCat = <String, List<int>>{};
    for (int i = 0; i < result.questions.length; i++) {
      final List<int> v =
          byCat.putIfAbsent(result.questions[i].categoryId, () => <int>[0, 0]);
      v[1]++;
      if (result.isCorrect(i)) v[0]++;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: fromHistory,
        title: Text('Ibisubizo'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: <Widget>[
          Center(
            child: ProgressRing(
              value: result.ratio,
              size: 150,
              stroke: 12,
              fontSize: 30,
              color: passed ? AppColors.success : AppColors.error,
              label: '${result.score}/${result.total}',
            ),
          ),
          SizedBox(height: 16),
          Text(passed ? 'Watsinze!' : 'Ntiwatsinze',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: passed ? AppColors.success : AppColors.error)),
          SizedBox(height: 6),
          Text(
            '${(result.ratio * 100).round()}% · Igihe wakoresheje: ${formatDuration(result.timeUsed)}',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
          SizedBox(height: 20),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Uko witwaye mu byiciro',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                SizedBox(height: 12),
                for (final MapEntry<String, List<int>> e in byCat.entries) ...<Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: Text(repo.categoryById(e.key).title)),
                      Text('${e.value[0]}/${e.value[1]}',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  SizedBox(height: 6),
                  AppProgressBar(
                    value: e.value[0] / e.value[1],
                    color: e.value[0] / e.value[1] >= 0.6 ? AppColors.success : AppColors.warning,
                  ),
                  SizedBox(height: 12),
                ],
              ],
            ),
          ),
          SizedBox(height: 20),
          if (wrong > 0)
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => ExamReviewScreen(result: result)),
              ),
              icon: Icon(Icons.fact_check_outlined),
              label: Text('Reba amakosa yawe ($wrong)'),
            ),
          SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => startExam(context, replace: true),
            child: Text('Ongera ugerageze'),
          ),
          SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Subira inyuma'),
          ),
        ],
      ),
    );
  }
}

class ExamReviewScreen extends StatelessWidget {
  const ExamReviewScreen({super.key, required this.result});

  final ExamResult result;

  @override
  Widget build(BuildContext context) {
    final List<int> wrong = <int>[
      for (int i = 0; i < result.questions.length; i++)
        if (!result.isCorrect(i)) i,
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Amakosa yawe')),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: wrong.length,
        separatorBuilder: (_, __) => SizedBox(height: 12),
        itemBuilder: (BuildContext context, int n) {
          final int i = wrong[n];
          final Question q = result.questions[i];
          final int? given = result.answers[i];
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Ikibazo ${i + 1}',
                    style: TextStyle(color: AppColors.muted, fontSize: 13)),
                SizedBox(height: 6),
                if (q.sign != null) ...<Widget>[
                  RoadSign(type: q.sign!, size: 72, label: q.signLabel),
                  SizedBox(height: 8),
                ],
                Text(q.text,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, height: 1.4)),
                SizedBox(height: 10),
                _AnswerLine(
                  icon: Icons.cancel,
                  color: AppColors.error,
                  text: given == null ? 'Ntiwasubije' : 'Wasubije: ${q.options[given]}',
                ),
                SizedBox(height: 6),
                _AnswerLine(
                  icon: Icons.check_circle,
                  color: AppColors.success,
                  text: 'Igisubizo nyacyo: ${q.correctAnswer}',
                ),
                SizedBox(height: 10),
                Text(q.explanation,
                    style: TextStyle(color: AppColors.bodyText, height: 1.5)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnswerLine extends StatelessWidget {
  const _AnswerLine({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: color, size: 20),
        SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
      ],
    );
  }
}
