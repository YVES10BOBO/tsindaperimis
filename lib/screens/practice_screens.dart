import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../data/content_repository.dart';
import '../data/exam_scope.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/road_sign.dart';

/// Tab y'Imyitozo: guhitamo ibibazo umuntu ashaka kwitoza.
class PracticeHomeScreen extends StatelessWidget {
  const PracticeHomeScreen({super.key});

  void _start(BuildContext context, String title, List<Question> source) {
    if (source.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PracticeQuizScreen(title: title, source: source),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final ContentRepository repo = ContentRepository.instance;
    final List<Question> wrong = <Question>[
      for (final String id in state.wrongQuestions)
        if (repo.questionById(id) != null) repo.questionById(id)!,
    ];

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: <Widget>[
          Text('Imyitozo',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text(
            'Ibibazo 20 bivanze kuri buri nshuro. Uhita ubona niba ari cyo n\'impamvu yacyo.',
            style:
                TextStyle(color: AppColors.muted, fontSize: 14.5, height: 1.4),
          ),
          SizedBox(height: 18),
          AppCard(
            color: AppColors.primary,
            borderColor: AppColors.primary,
            onTap: () => _start(context, 'Ibibazo bivanze', repo.allQuestions),
            child: Row(
              children: <Widget>[
                IconBadge(
                    icon: Icons.shuffle,
                    color: AppColors.primary,
                    background: Colors.white),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Ibibazo bivanze',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                      Text(
                          'Ibibazo ${repo.allQuestions.length} byo mu byiciro byose',
                          style: TextStyle(
                              color: Color(0xFFDBEAFE), fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
              ],
            ),
          ),
          SizedBox(height: 12),
          AppCard(
            color: AppColors.purpleSoft,
            borderColor: AppColors.purpleBorder,
            onTap: () =>
                _start(context, 'Ibibazo byo mu kizamini', repo.examQuestions),
            child: Row(
              children: <Widget>[
                IconBadge(
                    icon: Icons.assignment_turned_in,
                    color: Colors.white,
                    background: AppColors.purple),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Ibibazo byo mu kizamini gusa',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      Text(
                          'Ibibazo ${repo.examQuestions.length}, hatarimo ubumenyi bw\'inyongera',
                          style:
                              TextStyle(color: AppColors.muted, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
          SizedBox(height: 12),
          AppCard(
            color: AppColors.errorSoft,
            borderColor: AppColors.errorBorder,
            onTap: wrong.isEmpty
                ? () => showComingSoon(
                    context, 'Nta kibazo wakoze nabi kugeza ubu.')
                : () => _start(context, 'Amakosa yawe', wrong),
            child: Row(
              children: <Widget>[
                IconBadge(
                    icon: Icons.replay,
                    color: Colors.white,
                    background: AppColors.error),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Subiramo amakosa yawe',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      Text('Ibibazo ${wrong.length} wakoze nabi',
                          style:
                              TextStyle(color: AppColors.muted, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
          SizedBox(height: 22),
          SectionTitle('Hitamo icyiciro'),
          SizedBox(height: 8),
          for (final LearnCategory c in repo.categories)
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                radius: 14,
                onTap: () => _start(context, c.title, repo.questionsFor(c.id)),
                child: Row(
                  children: <Widget>[
                    IconBadge(
                        icon: c.icon,
                        color: c.color,
                        background: AppColors.tint(c.color, c.softColor),
                        size: 40),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(c.title,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                          SizedBox(height: 2),
                          Text('Ibibazo ${repo.questionsFor(c.id).length}',
                              style: TextStyle(
                                  fontSize: 12.5, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.muted),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Umubare w'ibibazo muri buri cyiciro cy'imyitozo.
const int practiceSessionSize = 20;

/// Umurongo w'uduce tugaragaza iterambere (amabara 3 gusa):
/// icyatsi = byo, umutuku = si byo, ikijuju = ibitarakorwa.
class SegmentedProgress extends StatelessWidget {
  const SegmentedProgress(
      {super.key, required this.results, required this.current});

  /// true = byo, false = si byo, null = ntikirasubizwa
  final List<bool?> results;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < results.length; i++) ...<Widget>[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 6,
              decoration: BoxDecoration(
                color: results[i] == true
                    ? AppColors.success
                    : results[i] == false
                        ? AppColors.error
                        : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          if (i < results.length - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }
}

/// Imyitozo: ibibazo 20 (cyangwa ibihari iyo bitageze kuri 20).
class PracticeQuizScreen extends StatefulWidget {
  const PracticeQuizScreen({
    super.key,
    required this.title,
    required this.source,
    this.count = practiceSessionSize,
  });

  final String title;
  final List<Question> source;
  final int count;

  @override
  State<PracticeQuizScreen> createState() => _PracticeQuizScreenState();
}

class _PracticeQuizScreenState extends State<PracticeQuizScreen> {
  late List<Question> _questions;
  late List<int?> _answers;
  int _index = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _newSession();
  }

  void _newSession() {
    _questions = ContentRepository.instance
        .shuffledQuestions(widget.source, limit: widget.count);
    _answers = List<int?>.filled(_questions.length, null);
    _index = 0;
    _finished = false;
  }

  Question get _q => _questions[_index];
  int? get _selected => _answers[_index];
  int get _answeredCount => _answers.where((int? a) => a != null).length;
  int get _correctCount {
    int c = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctIndex) c++;
    }
    return c;
  }

  List<bool?> get _results => <bool?>[
        for (int i = 0; i < _questions.length; i++)
          _answers[i] == null
              ? null
              : _answers[i] == _questions[i].correctIndex,
      ];

  void _choose(int i) {
    if (_selected != null) return;
    final bool ok = i == _q.correctIndex;
    setState(() => _answers[_index] = i);
    AppScope.of(context).recordAnswer(_q, ok);
  }

  void _next() {
    if (_index + 1 >= _questions.length) {
      setState(() => _finished = true);
      return;
    }
    setState(() => _index++);
  }

  Future<void> _confirmClose() async {
    if (_answeredCount == 0 || _finished) {
      Navigator.of(context).pop();
      return;
    }
    final bool? leave = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Kuva mu myitozo?'),
        content: Text(
            'Umaze gusubiza ibibazo $_answeredCount kuri ${_questions.length}.'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Komeza')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Va mo')),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).pop();
  }

  OptionState _stateFor(int i) {
    if (_selected == null) return OptionState.neutral;
    if (i == _q.correctIndex) return OptionState.correct;
    if (i == _selected) return OptionState.wrong;
    return OptionState.dimmed;
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const EmptyState(
          icon: Icons.quiz_outlined,
          title: 'Nta bibazo bihari',
          message: 'Ibibazo by\'iki cyiciro bizongerwamo vuba.',
        ),
      );
    }
    if (_finished) return _buildSummary();

    final AppState state = AppScope.of(context);
    final int total = _questions.length;
    final bool answered = _selected != null;
    final bool isRight = answered && _selected == _q.correctIndex;
    final bool bookmarked = state.isQuestionBookmarked(_q.id);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          tooltip: 'Subira inyuma',
          icon: const Icon(Icons.arrow_back),
          onPressed: _confirmClose,
        ),
        title: SegmentedProgress(results: _results, current: _index),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 16),
            child: Center(
              child: Text('$_answeredCount/$total',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Ikibazo ${_index + 1} kuri $total',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                        if (!isExamQuestion(_q)) ...<Widget>[
                          const SizedBox(height: 4),
                          const ExtraKnowledgeBadge(compact: true),
                        ],
                        const SizedBox(height: 2),
                        Text(widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: AppColors.muted, fontSize: 12.5)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Umva ikibazo',
                    icon: const Icon(Icons.volume_up_outlined),
                    onPressed: () =>
                        showComingSoon(context, 'Amajwi azongerwamo vuba.'),
                  ),
                  IconButton(
                    tooltip: 'Bika ikibazo',
                    icon: Icon(
                        bookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: bookmarked ? AppColors.primary : null),
                    onPressed: () => state.toggleQuestionBookmark(_q.id),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: <Widget>[
                  if (_q.sign != null || _q.imagePath != null) ...<Widget>[
                    AppCard(
                      child: Center(
                          child: RoadSignVisual(
                              type: _q.sign,
                              imagePath: _q.imagePath,
                              size: 120,
                              label: _q.signLabel)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(_q.text,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          height: 1.4)),
                  const SizedBox(height: 16),
                  for (int i = 0; i < _q.options.length; i++)
                    OptionTile(
                      letter: optionLetter(i),
                      text: _q.options[i],
                      state: _stateFor(i),
                      onTap: answered ? null : () => _choose(i),
                    ),
                  if (answered) ...<Widget>[
                    const SizedBox(height: 6),
                    _FeedbackCard(question: _q, isRight: isRight),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: ElevatedButton(
                onPressed: answered ? _next : null,
                child: Text(!answered
                    ? 'Hitamo igisubizo'
                    : (_index + 1 >= total
                        ? 'Reba uko wakoze'
                        : 'Ikibazo gikurikira')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final int total = _questions.length;
    final int correct = _correctCount;
    final int wrong = total - correct;
    final double ratio = correct / total;
    final bool good = ratio >= 0.6;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Subira inyuma',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title, style: const TextStyle(fontSize: 17)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: <Widget>[
            SegmentedProgress(results: _results, current: -1),
            const SizedBox(height: 28),
            Center(
              child: ProgressRing(
                value: ratio,
                size: 150,
                stroke: 12,
                fontSize: 30,
                color: good ? AppColors.success : AppColors.warning,
                label: '$correct/$total',
              ),
            ),
            const SizedBox(height: 18),
            Text(good ? 'Wakoze neza!' : 'Komeza witoze!',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: StatTile(
                      value: '$correct',
                      label: 'Wasubije neza',
                      color: AppColors.success),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                      value: '$wrong',
                      label: 'Wakoze nabi',
                      color: AppColors.error),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PracticeReviewScreen(
                    title: widget.title,
                    questions: _questions,
                    answers: _answers,
                  ),
                ),
              ),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Reba ibisubizo byose'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => setState(_newSession),
              icon: const Icon(Icons.refresh),
              label: Text(
                  'Ibindi bibazo ${widget.count < widget.source.length ? widget.count : widget.source.length}'),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Subira inyuma'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.question, required this.isRight});

  final Question question;
  final bool isRight;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: isRight ? AppColors.successSoft : AppColors.errorSoft,
      borderColor: isRight ? AppColors.successBorder : AppColors.errorBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(isRight ? Icons.check_circle : Icons.cancel,
                  color: isRight ? AppColors.success : AppColors.error,
                  size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isRight
                      ? 'Ni byo!'
                      : 'Si byo. Igisubizo nyacyo ni ${optionLetter(question.correctIndex)}.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color:
                        isRight ? AppColors.successText : AppColors.errorText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(question.explanation,
              style: TextStyle(height: 1.5, color: AppColors.bodyText)),
        ],
      ),
    );
  }
}

// =====================================================================
// Reba ibisubizo byose (nyuma y'imyitozo)
// =====================================================================
enum _ReviewFilter { all, wrong, right }

class PracticeReviewScreen extends StatefulWidget {
  const PracticeReviewScreen({
    super.key,
    required this.title,
    required this.questions,
    required this.answers,
  });

  final String title;
  final List<Question> questions;
  final List<int?> answers;

  @override
  State<PracticeReviewScreen> createState() => _PracticeReviewScreenState();
}

class _PracticeReviewScreenState extends State<PracticeReviewScreen> {
  _ReviewFilter _filter = _ReviewFilter.all;

  bool _isRight(int i) => widget.answers[i] == widget.questions[i].correctIndex;

  OptionState _stateFor(int q, int option) {
    final Question question = widget.questions[q];
    if (option == question.correctIndex) return OptionState.correct;
    if (option == widget.answers[q]) return OptionState.wrong;
    return OptionState.dimmed;
  }

  @override
  Widget build(BuildContext context) {
    final int total = widget.questions.length;
    final int right = <int>[
      for (int i = 0; i < total; i++)
        if (_isRight(i)) i
    ].length;
    final List<int> shown = <int>[
      for (int i = 0; i < total; i++)
        if (_filter == _ReviewFilter.all ||
            (_filter == _ReviewFilter.right && _isRight(i)) ||
            (_filter == _ReviewFilter.wrong && !_isRight(i)))
          i,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Ibisubizo byose')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Wrap(
              spacing: 8,
              children: <Widget>[
                ChoiceChip(
                  label: Text('Byose ($total)'),
                  selected: _filter == _ReviewFilter.all,
                  onSelected: (_) =>
                      setState(() => _filter = _ReviewFilter.all),
                ),
                ChoiceChip(
                  label: Text('Wakoze nabi (${total - right})'),
                  selected: _filter == _ReviewFilter.wrong,
                  onSelected: (_) =>
                      setState(() => _filter = _ReviewFilter.wrong),
                ),
                ChoiceChip(
                  label: Text('Wasubije neza ($right)'),
                  selected: _filter == _ReviewFilter.right,
                  onSelected: (_) =>
                      setState(() => _filter = _ReviewFilter.right),
                ),
              ],
            ),
          ),
          Expanded(
            child: shown.isEmpty
                ? const EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'Nta kibazo kiri hano',
                    message: 'Hitamo ikindi gice hejuru.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: shown.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (BuildContext context, int n) {
                      final int i = shown[n];
                      final Question q = widget.questions[i];
                      final bool ok = _isRight(i);
                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text('Ikibazo ${i + 1}',
                                    style: TextStyle(
                                        color: AppColors.muted, fontSize: 13)),
                                if (!isExamQuestion(q)) ...<Widget>[
                                  const SizedBox(width: 8),
                                  const Flexible(
                                      child:
                                          ExtraKnowledgeBadge(compact: true)),
                                ],
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ok
                                        ? AppColors.successSoft
                                        : AppColors.errorSoft,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(ok ? 'Byo' : 'Si byo',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: ok
                                              ? AppColors.success
                                              : AppColors.error)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (q.sign != null ||
                                q.imagePath != null) ...<Widget>[
                              Center(
                                  child: RoadSignVisual(
                                      type: q.sign,
                                      imagePath: q.imagePath,
                                      size: 80,
                                      label: q.signLabel)),
                              const SizedBox(height: 10),
                            ],
                            Text(q.text,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    height: 1.4)),
                            const SizedBox(height: 12),
                            for (int o = 0; o < q.options.length; o++)
                              OptionTile(
                                letter: optionLetter(o),
                                text: q.options[o],
                                state: _stateFor(i, o),
                              ),
                            const SizedBox(height: 2),
                            Text(q.explanation,
                                style: TextStyle(
                                    color: AppColors.bodyText, height: 1.5)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
