import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_info.dart';
import '../widgets/common.dart';

// =====================================================================
// FAQ, Amategeko n'Amabwiriza (Terms), Politiki y'Ibanga (Privacy)
//
// ICYITONDERWA: Izi ni inyandiko z'icyitegererezo (templates), si inama
// z'amategeko. Mbere yo gushyira app kuri Play Store:
//  - uzuza ibiri hagati ya [ ] (izina ry'ikigo, email, aderesi...);
//  - zisuzumishe n'umunyamategeko, cyane cyane uko zihuye n'Itegeko
//    No 058/2021 ryo ku wa 13/10/2021 rirengera amakuru bwite n'ubuzima bwite
//    mu Rwanda;
//  - shyira Politiki y'Ibanga ku rubuga (URL) kuko Play Store iyisaba.
// =====================================================================

const String kContactEmail = '[EMAIL Y\'UBUFASHA]';
const String kCompanyName = '[IZINA RY\'IKIGO / NYIRI APP]';
const String kLastUpdated = '[ITARIKI]';

class _DocSection {
  const _DocSection(this.title, this.body);
  final String title;
  final String body;
}

/// Ipaji isanzwe yo gusoma inyandiko ndende.
class _DocumentScreen extends StatelessWidget {
  const _DocumentScreen({
    required this.title,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String intro;
  final List<_DocSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: <Widget>[
          Text('Byavuguruwe: $kLastUpdated',
              style: TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 12),
          Text(intro, style: TextStyle(height: 1.55, color: AppColors.bodyText)),
          const SizedBox(height: 16),
          for (int i = 0; i < sections.length; i++) ...<Widget>[
            Text('${i + 1}. ${sections[i].title}',
                style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(sections[i].body,
                style: TextStyle(height: 1.55, color: AppColors.bodyText)),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// FAQ
// ---------------------------------------------------------------------
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const List<_DocSection> _faqs = <_DocSection>[
    _DocSection('Iyi app ni iy\'iki?',
        'Igufasha kwiga amategeko y\'umuhanda, ibimenyetso, amatara n\'imirongo yo ku muhanda, no kwitoza ibibazo kugira ngo witegure ikizamini cy\'uruhushya rwo gutwara rw\'agateganyo.'),
    _DocSection('Ese iyi app ni iya Polisi y\'u Rwanda?',
        'Oya. Ni app yigenga yo kwigiraho. Ntisimbura amasomo y\'ishuri ryigisha gutwara cyangwa amabwiriza yemewe ya Polisi y\'u Rwanda.'),
    _DocSection('Ese ibibazo biri muri app ni byo bibazwa mu kizamini nyirizina?',
        'Ibibazo biri muri app ni iby\'imyitozo bishingiye ku mategeko y\'umuhanda. Ntitwemeza ko ari byo bizabazwa mu kizamini nyirizina.'),
    _DocSection('Imyitozo n\'ikizamini cy\'igerageza bitandukaniye he?',
        'Mu myitozo, uhita ubona niba igisubizo ari cyo n\'impamvu yacyo. Mu kizamini cy\'igerageza, usubiza ibibazo byose mu gihe kigenwe, hanyuma ukabona amanota n\'amakosa yawe urangije.'),
    _DocSection('"Ubumenyi bw\'inyongera" bisobanura iki?',
        'Ni amasomo n\'ibibazo bijyanye no kwita ku modoka (amavuta, amapine, bateri...). Ni byiza kubimenya ariko ntibikunze kubazwa mu kizamini, bityo ntibijya mu kizamini cy\'igerageza.'),
    _DocSection('Ese nshobora gukoresha app ntiyandikishije?',
        'Yego. Kanda "Komeza nka Mushyitsi". Gusa, kwiyandikisha bizagufasha kubika iterambere ryawe igihe ubu buryo buzaba bwatangiye gukora.'),
    _DocSection('Ese app ikora nta interineti?',
        'Amasomo n\'ibibazo biri muri app ubwayo, bityo ushobora kwiga nta interineti. Interineti izakenerwa gusa mu bindi nko kwinjira muri konti cyangwa kwishyura.'),
    _DocSection('Nahindura nte amabara (Light / Dark)?',
        'Jya muri Ibindi → Imiterere y\'amabara, uhitemo Urumuri, Umwijima cyangwa Nk\'iya telefoni.'),
    _DocSection('Nibagiwe ijambo ry\'ibanga. Nkora iki?',
        'Ku ipaji yo kwinjira, kanda "Wibagiwe ijambo ry\'ibanga?", wandike nimero yawe ya telefoni, hanyuma ukurikize amabwiriza.'),
    _DocSection('Premium ni iki kandi nishyura nte?',
        'Premium izaguha ibindi bikoresho nk\'ibizamini by\'igerageza bitagira umubare. Kwishyura bizakorwa hakoreshejwe MTN Mobile Money cyangwa Airtel Money.'),
    _DocSection('Nabona ikosa mu kibazo cyangwa mu isomo. Nkora iki?',
        'Twandikire kuri $kContactEmail, utubwire ikibazo n\'icyiciro kirimo. Tuzabikosora vuba.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ibibazo bikunze kubazwa')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: <Widget>[
          for (final _DocSection f in _faqs)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: EdgeInsets.zero,
                radius: 14,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    iconColor: AppColors.primary,
                    title: Text(f.title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(f.body, style: TextStyle(height: 1.55, color: AppColors.bodyText)),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          AppCard(
            color: AppColors.primarySoft,
            borderColor: AppColors.primarySoft,
            child: Row(
              children: <Widget>[
                const Icon(Icons.mail_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Ntiwabonye igisubizo? Twandikire kuri $kContactEmail',
                      style: TextStyle(color: AppColors.text, height: 1.4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Amategeko n'Amabwiriza (Terms of Use)
// ---------------------------------------------------------------------
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DocumentScreen(
      title: 'Amategeko n\'Amabwiriza',
      intro:
          'Aya mategeko n\'amabwiriza agenga ikoreshwa rya app "${AppInfo.name}" itangwa na $kCompanyName. Iyo ukoresheje app, uba wemeye aya mabwiriza. Niba utayemera, ntukoreshe app.',
      sections: <_DocSection>[
        _DocSection('Intego ya app',
            'App ni igikoresho cyo kwiga no kwitoza amategeko y\'umuhanda. Ntisimbura amasomo y\'ishuri ryigisha gutwara, amategeko yemewe, cyangwa amabwiriza ya Polisi y\'u Rwanda.'),
        _DocSection('Ukuri kw\'amakuru',
            'Dukora uko dushoboye ngo amakuru abe ukuri kandi agezweho, ariko ntitwemeza ko nta kosa na rimwe rihari cyangwa ko ibibazo biri muri app ari byo bizabazwa mu kizamini. Ni wowe ufite inshingano yo kugenzura amategeko agezweho.'),
        _DocSection('Konti yawe',
            'Ugomba gutanga amakuru y\'ukuri igihe wiyandikisha, no kurinda ijambo ry\'ibanga ryawe. Uri wowe ubazwa ibikorwa byose bikorerwa kuri konti yawe.'),
        _DocSection('Imikoreshereze yemewe',
            'Ntiwemerewe gukoporora, kugurisha cyangwa gukwirakwiza ibirimo muri app utabiherewe uburenganzira, kugerageza kwinjira mu buryo butemewe, cyangwa gukoresha app mu buryo bunyuranyije n\'amategeko.'),
        _DocSection('Premium no kwishyura',
            'Bimwe mu bikoresho bishobora gusaba kwishyura. Igiciro, igihe ifatabuguzi rimara n\'uko ryongerwa bizagaragazwa mbere yo kwishyura. Kwishyura bikorwa binyuze kuri MTN Mobile Money cyangwa Airtel Money. [Andika hano amabwiriza yo gusubizwa amafaranga.]'),
        _DocSection('Uburenganzira ku bihangano',
            'Ibirimo byose muri app (inyandiko, amashusho, ibibazo, ikirango) ni umutungo wa $kCompanyName cyangwa ab\'abatanze uburenganzira bwo kubikoresha.'),
        _DocSection('Aho inshingano zacu zigarukira',
            'Ntituryozwa ingaruka zituruka ku gukoresha app, harimo gutsindwa ikizamini cyangwa impanuka. Gutwara neza no kubahiriza amategeko ni inshingano za buri mushoferi.'),
        _DocSection('Guhagarika konti',
            'Dushobora guhagarika cyangwa gufunga konti ikoreshwa nabi cyangwa inyuranyije n\'aya mabwiriza.'),
        _DocSection('Impinduka',
            'Dushobora guhindura aya mabwiriza. Impinduka zikomeye tuzazimenyesha muri app. Gukomeza gukoresha app nyuma y\'impinduka bivuze ko uzemeye.'),
        _DocSection('Amategeko akurikizwa',
            'Aya mabwiriza agengwa n\'amategeko ya Repubulika y\'u Rwanda.'),
        _DocSection('Twandikire',
            'Ku bibazo bijyanye n\'aya mabwiriza: $kContactEmail.'),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Politiki y'Ibanga (Privacy Policy)
// ---------------------------------------------------------------------
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DocumentScreen(
      title: 'Politiki y\'Ibanga',
      intro:
          '$kCompanyName yubaha ubuzima bwite bwawe. Iyi politiki isobanura amakuru dukusanya muri app "${AppInfo.name}", impamvu tuyakusanya, uko tuyarinda n\'uburenganzira ufite.',
      sections: <_DocSection>[
        _DocSection('Amakuru dukusanya',
            'Amakuru utanga: amazina, nimero ya telefoni, email (si ngombwa), akarere n\'ubwoko bw\'uruhushya witegura.\n\nAmakuru y\'imyigire: amasomo warangije, ibisubizo by\'imyitozo n\'ibizamini, n\'ibyo wabitse.\n\nAmakuru yo kwishyura: nimero ya Mobile Money n\'aho ubwishyu bugeze. Ntitubika umubare w\'ibanga (PIN) wa Mobile Money.\n\nAmakuru ya tekiniki: ubwoko bwa telefoni, verisiyo ya app na raporo z\'amakosa, kugira ngo tunoze app.'),
        _DocSection('Impamvu tuyakusanya',
            'Kugufungurira konti no kuyirinda, kubika iterambere ryawe, kukwereka ibyo ugomba gusubiramo, gutunganya ubwishyu, kukoherereza ubutumwa wemeye (nk\'inzibutso zo kwiga), no kunoza app.'),
        _DocSection('Aho amakuru abikwa',
            'Amakuru amwe abikwa kuri telefoni yawe, andi akabikwa kuri seriveri zacu. [Andika aho seriveri ziri n\'ingamba z\'umutekano zikoreshwa.]'),
        _DocSection('Abo dusangiza amakuru',
            'Ntitugurisha amakuru yawe. Tuyasangiza gusa ababidufashamo mu kazi (nk\'abatanga serivisi zo kwishyura MTN MoMo / Airtel Money, serivisi zo kohereza ubutumwa, cyangwa iz\'isesengura), cyangwa inzego za Leta iyo amategeko abisaba.'),
        _DocSection('Igihe tubika amakuru',
            'Tubika amakuru igihe cyose konti yawe ikiriho cyangwa igihe amategeko abidusaba. Iyo usibye konti, amakuru yawe arasibwa cyangwa agahindurwa ntamenyekane. [Andika igihe nyacyo.]'),
        _DocSection('Uburenganzira bwawe',
            'Ufite uburenganzira bwo kumenya amakuru tugufiteho, kuyakosora, gusaba ko asibwa, no kwanga ko akoreshwa mu bikorwa bimwe na bimwe, nk\'uko biteganywa n\'Itegeko rirengera amakuru bwite n\'ubuzima bwite mu Rwanda. Wandikire $kContactEmail.'),
        _DocSection('Umutekano',
            'Dukoresha ingamba zikwiye zo kurinda amakuru yawe, harimo kuyohereza mu buryo bwizewe (HTTPS). Nta buryo na bumwe bufite umutekano ijana ku ijana, ariko dukora ibishoboka byose.'),
        _DocSection('Abana',
            'Abatarageza ku myaka y\'ubukure bagomba gukoresha app babyemerewe n\'ababyeyi cyangwa ababarera.'),
        _DocSection('Impinduka kuri iyi politiki',
            'Tuzakumenyesha muri app impinduka zikomeye kuri iyi politiki.'),
        _DocSection('Twandikire',
            'Ku bibazo bijyanye n\'ibanga ry\'amakuru yawe: $kContactEmail. [Andika aderesi y\'ikigo.]'),
      ],
    );
  }
}
