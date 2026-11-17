import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_colors.dart';
import '../widgets/common.dart';

/// "Inkomoko z'amategeko": links to the official sources (Police, Official
/// Gazette) so learners can check the rules themselves.
class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  static const List<_Source> _sources = <_Source>[
    _Source(
      icon: Icons.gavel,
      title: "Itegeko n° 014/2026 rigenga ikoreshwa ry'umuhanda",
      description:
          "Itegeko rishya ry'umuhanda ryo ku wa 06/03/2026, ryasohotse mu Igazeti ya Leta Idasanzwe yo ku wa 10/03/2026. "
          "Rivanaho itegeko n° 34/87 ryo mu 1987. Ni PDF mu Kinyarwanda, Icyongereza n'Igifaransa.",
      host: 'police.gov.rw',
      url:
          'https://police.gov.rw/uploads/tx_download/OG_n___Special_of_10.03.2026__Ikoreshwa_ry_umuhanda.pdf',
    ),
    _Source(
      icon: Icons.local_police_outlined,
      title: "Polisi y'u Rwanda: ikizamini n'uruhushya",
      description:
          "Amakuru yemewe ku kizamini cy'agateganyo n'icya burundu, ibisabwa, n'uko wiyandikisha. "
          "Ni ho ugenzura ibigezweho ku bijyanye n'ikizamini.",
      host: 'police.gov.rw',
      url: 'https://police.gov.rw/services/testing-and-licencing/',
    ),
    _Source(
      icon: Icons.how_to_reg_outlined,
      title: 'Irembo: kwiyandikisha ku kizamini',
      description:
          "Uko wiyandikisha ku kizamini cy'agateganyo cyo gutwara (provisional driving test) kuri Irembo. "
          "Ikizamini kiboneka mu Kinyarwanda, Icyongereza n'Igifaransa.",
      host: 'support.irembo.gov.rw',
      url:
          'https://support.irembo.gov.rw/en/support/solutions/articles/47001234512-how-to-register-for-the-provisional-driving-test',
    ),
    _Source(
      icon: Icons.menu_book_outlined,
      title: 'Igazeti ya Leta (Minisiteri y\'Ubutabera)',
      description:
          "Urutonde rw'ibinyamakuru by'Igazeti ya Leta y'u Rwanda, rukurikiranye ku mwaka (2017 kugeza 2026). "
          "Ukoresha urwo rubuga ushobora gushaka amateka n'amategeko mashya agenga umuhanda.",
      host: 'minijust.gov.rw',
      url: 'https://www.minijust.gov.rw/official-gazette',
    ),
  ];

  Future<void> _open(BuildContext context, _Source s) async {
    bool ok = false;
    try {
      ok = await launchUrl(Uri.parse(s.url),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && context.mounted) {
      // No browser could open it: copy the link so the learner can paste it.
      await Clipboard.setData(ClipboardData(text: s.url));
      if (context.mounted) {
        showComingSoon(context,
            'Ntibishobotse gukingura umurongo. Wakoporowe, uwushyire muri browser.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inkomoko z'amategeko")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: <Widget>[
          AppCard(
            color: AppColors.warningSoft,
            borderColor: AppColors.warningBorder,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.info_outline, color: AppColors.warningIcon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Iyi app ni ubufasha bwo kwiga. Amategeko yemewe ni ayo kuri izi mbuga. "
                    "Ujye ugenzura ibigezweho mbere yo gukora ikizamini nyacyo.",
                    style: TextStyle(color: AppColors.warningText, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final _Source s in _sources)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () => _open(context, s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    IconBadge(
                        icon: s.icon,
                        color: Colors.white,
                        background: AppColors.primary,
                        size: 44),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(s.title,
                              style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text)),
                          const SizedBox(height: 4),
                          Text(s.description,
                              style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.4,
                                  color: AppColors.bodyText)),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              Icon(Icons.open_in_new,
                                  size: 15, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(s.host,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Source {
  const _Source({
    required this.icon,
    required this.title,
    required this.description,
    required this.host,
    required this.url,
  });

  final IconData icon;
  final String title;
  final String description;
  final String host;
  final String url;
}
