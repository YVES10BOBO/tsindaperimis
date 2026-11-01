import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import '../data/content_repository.dart';
import '../data/models.dart';

/// Kode ihoraho y'ikibazo ("Kode: #57") n'akabuto "Tanga ikosa", bigaragara
/// nyuma yo gusubiza. Raporo ijya kuri dashboard ya admin (Raporo).
class QuestionCode extends StatefulWidget {
  const QuestionCode({super.key, required this.question});

  final Question question;

  @override
  State<QuestionCode> createState() => _QuestionCodeState();
}

class _QuestionCodeState extends State<QuestionCode> {
  Future<void> _openReport() async {
    final bool? sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (_) => _ReportSheet(question: widget.question),
    );
    if (sent == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
            SnackBar(content: Text('Murakoze! Raporo yawe yakiriwe.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final int? number = widget.question.number;
    // Only questions from the dashboard have a number and can be reported.
    if (number == null) return SizedBox.shrink();
    final bool sent =
        ContentRepository.instance.hasReported(widget.question.id);
    final TextStyle small = TextStyle(
        color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600);
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        children: <Widget>[
          Text('Kode: #$number', style: small),
          Spacer(),
          if (sent)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.check, size: 16, color: AppColors.muted),
                SizedBox(width: 4),
                Text('Raporo yoherejwe', style: small),
              ],
            )
          else
            TextButton.icon(
              onPressed: _openReport,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.muted,
                padding: EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size(0, 36),
              ),
              icon: Icon(Icons.flag_outlined, size: 16),
              label: Text('Tanga ikosa', style: small),
            ),
        ],
      ),
    );
  }
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.question});

  final Question question;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  // Keys must match the question_reports.reason check constraint.
  static const Map<String, String> _reasons = <String, String>{
    'wrong_answer': 'Igisubizo nyacyo si cyo',
    'typo': 'Amakosa mu nyandiko',
    'image': 'Ifoto cyangwa icyapa si cyo',
    'other': 'Ibindi',
  };

  final TextEditingController _comment = TextEditingController();
  String? _reason;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String? reason = _reason;
    if (reason == null || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ContentRepository.instance.reportQuestion(
          questionId: widget.question.id,
          reason: reason,
          comment: _comment.text);
      if (mounted) Navigator.of(context).pop(true);
    } on PostgrestException catch (error) {
      if (mounted) {
        setState(() => _error = error.code == '23503'
            ? 'Iki kibazo ntikikiriho. Ongera ufungure app.'
            : 'Ntibyakunze kohereza: ${error.message}');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Ntibyakunze kohereza. Reba internet.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Tanga ikosa',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text(
              'Kode: #${widget.question.number}. Raporo yawe igera ku bayobozi ba app kugira ngo bakosore ikibazo.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            SizedBox(height: 16),
            Text('Ni iki kitari cyo?',
                style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final MapEntry<String, String> r in _reasons.entries)
                  ChoiceChip(
                    label: Text(r.value),
                    selected: _reason == r.key,
                    onSelected: _sending
                        ? null
                        : (_) => setState(() => _reason = r.key),
                  ),
              ],
            ),
            SizedBox(height: 16),
            // Answer letters are shuffled per learner, so ask for words, not "B".
            TextField(
              controller: _comment,
              maxLength: 500,
              minLines: 2,
              maxLines: 4,
              enabled: !_sending,
              decoration: InputDecoration(
                labelText: 'Igitekerezo (si ngombwa)',
                hintText: 'Andika icyo ubona kitari cyo, n\'igisubizo ubona ari cyo',
              ),
            ),
            if (_error != null) ...<Widget>[
              SizedBox(height: 4),
              Text(_error!,
                  style: TextStyle(color: AppColors.error, fontSize: 13)),
            ],
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _reason == null || _sending ? null : _send,
              child: _sending
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text('Ohereza'),
            ),
          ],
        ),
      ),
    );
  }
}
