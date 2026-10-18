import 'models.dart';

// =====================================================================
// AMAKURU Y'URUGERO (mock data) — Ubumenyi ku Modoka & Imyitwarire ku Muhanda
// Azasimbuzwa amakuru nyayo yemejwe n'inzobere. Ubumenyi rusange ku modoka
// n'umutekano wo mu muhanda, nta mubare cyangwa itegeko ryihariye ryavuzwe.
// =====================================================================

// ---------------------------------------------------------------------
// AMASOMO: Ubumenyi ku Modoka
// ---------------------------------------------------------------------
const List<Lesson> vehicleLessons = <Lesson>[
  Lesson(
    id: 'modoka-1',
    categoryId: 'modoka',
    title: 'Igenzura rya buri munsi',
    minutes: 5,
    sections: <LessonSection>[
      LessonSection('Kuki ari ngombwa?',
          'Ibibazo byinshi by\'imodoka bishobora kumenyekana mbere y\'urugendo. Igenzura rito rya buri munsi ririnda impanuka n\'amafaranga menshi yo gusana.'),
      LessonSection('Ibyo ugenzura mbere yo kugenda',
          'Amavuta ya moteri, amazi akonjesha moteri, amavuta ya feri, umwuka n\'imiterere y\'amapine, amatara yose, essuie-glace n\'amazi yo koza ikirahuri, n\'indorerwamo.'),
      LessonSection('Iyo umaze kwicara',
          'Tunganya intebe n\'indorerwamo, wambare umukandara, urebe ko nta tara ryo kuburira risigaye ryaka kuri dashboard nyuma yo gutangiza moteri.'),
    ],
  ),
  Lesson(
    id: 'modoka-2',
    categoryId: 'modoka',
    title: 'Amavuta ya moteri',
    minutes: 6,
    sections: <LessonSection>[
      LessonSection('Akamaro kayo',
          'Amavuta agabanya ubushyamirane hagati y\'ibice bya moteri, akayirinda gushya no kwangirika vuba.'),
      LessonSection('Uko uyagenzura',
          'Hagarika imodoka ahantu harambuye, uzimye moteri, utegereze iminota mike. Kuramo agati gapima amavuta (dipstick), ugahanagure, ukagasubizamo, hanyuma ukakongera ukakakuramo urebe urwego.'),
      LessonSection('Urwego rukwiye',
          'Amavuta agomba kuba hagati y\'akamenyetso ka MIN na MAX. Make cyane yangiza moteri; menshi cyane nabyo si byiza.'),
      LessonSection('Itara ry\'amavuta',
          'Iyo itara ritukura ry\'amavuta ryaka utwaye, hagarara vuba ahantu hizewe uzimye moteri. Gukomeza gutwara bishobora kwangiza moteri burundu.'),
      LessonSection('Ibimenyetso by\'ikibazo',
          'Umwotsi w\'ubururu uva mu muyoboro w\'imyotsi, amavuta atonyanga munsi y\'imodoka, cyangwa amavuta yirabura cyane kandi akomeye bisaba kujya kwa mekanisiye.'),
    ],
  ),
  Lesson(
    id: 'modoka-3',
    categoryId: 'modoka',
    title: 'Amazi akonjesha moteri',
    minutes: 5,
    sections: <LessonSection>[
      LessonSection('Akamaro kayo',
          'Amazi akonjesha (coolant) atuma moteri itagira ubushyuhe burenze urugero.'),
      LessonSection('Uko uyagenzura',
          'Reba urwego rw\'amazi mu kabindi kayo moteri ikonje. Agomba kuba hagati ya MIN na MAX.'),
      LessonSection('Akaga',
          'Ntuzigere ufungura umupfundikizo w\'amazi moteri ishyushye: amazi ashyushye cyane ashobora kuguturikiraho akakotsa.'),
      LessonSection('Ubushyuhe burenze',
          'Iyo urushinge rw\'ubushyuhe rugeze mu gice gitukura cyangwa hakava umwuka mu gice cy\'imbere, hagarara ahantu hizewe, uzimye moteri, ureke ikonje mbere yo kugira icyo ukora.'),
    ],
  ),
  Lesson(
    id: 'modoka-4',
    categoryId: 'modoka',
    title: 'Feri',
    minutes: 5,
    sections: <LessonSection>[
      LessonSection('Feri y\'ikirenge',
          'Ni yo uhagarikisha imodoka. Iyo pedale yoroshye cyane cyangwa igera hasi, cyangwa imodoka ikururira ku ruhande rumwe ufashe feri, ntukagende utabanje kuyisuzumisha.'),
      LessonSection('Amavuta ya feri',
          'Urwego rwayo rugenzurwa mu kabindi kayo. Iyo agabanutse cyane bishobora kuba ikimenyetso cy\'uko hari aho ava.'),
      LessonSection('Feri y\'intoki',
          'Ikoreshwa iyo uparitse, cyane cyane ku musozi, kugira ngo imodoka itamanuka.'),
      LessonSection('Amatara ya feri',
          'Yaka inyuma iyo ukandagiye feri, akamenyesha abari inyuma ko ugabanya umuvuduko. Agomba guhora akora.'),
    ],
  ),
  Lesson(
    id: 'modoka-5',
    categoryId: 'modoka',
    title: 'Amapine',
    minutes: 5,
    sections: <LessonSection>[
      LessonSection('Umwuka',
          'Genzura umwuka amapine akonje, ukurikije ibipimo byanditswe n\'uruganda. Umwuka muke cyangwa mwinshi utuma imodoka itayoboka neza kandi ipine rigasaza vuba.'),
      LessonSection('Imirongo y\'ipine',
          'Ipine rishaje, ritagifite imirongo ihagije, rinyerera cyane cyane mu mvura kandi feri zitinda gufata.'),
      LessonSection('Ibyangiritse',
          'Reba niba nta bubyimbe, imisatuko cyangwa ibintu byinjiye mu ipine. Ipine ryangiritse rishobora guturika utwaye.'),
      LessonSection('Ipine ry\'ingoboka',
          'Rigomba guhora rifite umwuka uhagije, kandi ugomba kugira ibikoresho byo guhindura ipine.'),
    ],
  ),
  Lesson(
    id: 'modoka-6',
    categoryId: 'modoka',
    title: 'Amatara y\'imodoka',
    minutes: 6,
    sections: <LessonSection>[
      LessonSection('Amatara magufi n\'amaremare',
          'Nijoro, iyo uhuye n\'ikinyabiziga kiza imbere cyangwa ukurikiye ikindi hafi, koresha amatara magufi kugira ngo udahuma abandi.'),
      LessonSection('Ibimenyetso byo gukata (indicators)',
          'Bicane mbere y\'igihe kugira ngo abandi bamenye ko ugiye gukata cyangwa guhindura inzira.'),
      LessonSection('Amatara y\'akaga (hazard)',
          'Akoreshwa iyo imodoka yapfuye cyangwa ihagaze ahantu hateje akaga.'),
      LessonSection('Igenzura',
          'Genzura kenshi ko amatara yose akora: imbere, inyuma, aya feri n\'ibimenyetso byo gukata. Itara rimwe rizimye nijoro rituma abandi bakwibeshyaho.'),
    ],
  ),
  Lesson(
    id: 'modoka-7',
    categoryId: 'modoka',
    title: 'Dashboard n\'amatara yo kuburira',
    minutes: 6,
    sections: <LessonSection>[
      LessonSection('Amabara y\'amatara',
          'Muri rusange: itara ritukura risaba guhagarara vuba ahantu hizewe; iry\'umuhondo cyangwa iroranji rivuga ko hari ikibazo kigomba gusuzumwa vuba; iry\'icyatsi cyangwa ubururu ryerekana ko igikoresho kiri gukora.'),
      LessonSection('Amatara akomeye',
          'Itara ry\'amavuta ya moteri, iry\'ubushyuhe bwa moteri n\'irya feri: niba ryaka utwaye, hagarara vuba ahantu hizewe.'),
      LessonSection('Itara rya bateri',
          'Rivuga ko bateri itari kwishyurwa neza. Imodoka ishobora kuzima mu kanya gato.'),
      LessonSection('Itara rya moteri (check engine)',
          'Rivuga ko hari ikibazo muri moteri cyangwa mu buryo bwayo bw\'imikorere. Jyana imodoka kwa mekanisiye vuba.'),
      LessonSection('Igitabo cy\'imodoka',
          'Buri modoka igira amatara yayo. Soma igitabo cy\'uruganda (manuel) umenye icyo buri tara risobanura.'),
    ],
  ),
  Lesson(
    id: 'modoka-8',
    categoryId: 'modoka',
    title: 'Bateri, lisansi n\'ibindi',
    minutes: 5,
    sections: <LessonSection>[
      LessonSection('Bateri',
          'Imodoka itinda kwaka cyangwa amatara akaba make bishobora kuba ikimenyetso cya bateri ishaje. Imitwe ya bateri igomba kuba isukuye kandi ifashe neza.'),
      LessonSection('Kuzuza lisansi',
          'Zimya moteri mbere yo kuzuza lisansi. Ntunywe itabi kandi ntukoreshe umuriro hafi ya lisansi.'),
      LessonSection('Essuie-glace n\'amazi yo koza ikirahuri',
          'Essuie-glace zishaje zisiga imirongo ku kirahuri. Amazi yo koza ikirahuri agomba guhora ahari kugira ngo ubone neza.'),
      LessonSection('Steering',
          'Iyo kuzunguruka steering bigoye cyane cyangwa bivuga urusaku, sohoka mu muhanda ujyane imodoka kwa mekanisiye.'),
    ],
  ),
  Lesson(
    id: 'modoka-9',
    categoryId: 'modoka',
    title: 'Ibikoresho by\'ubutabazi mu modoka',
    minutes: 4,
    sections: <LessonSection>[
      LessonSection('Mpandeshatu yo kuburira',
          'Iyo imodoka yapfiriye mu muhanda, ishyirwa inyuma yayo ku ntera ihagije kugira ngo iburire abaje inyuma.'),
      LessonSection('Kizimyamwoto',
          'Kizimyamwoto ntoya ifasha kuzimya inkongi itangiye. Menya aho iri n\'uko ikoreshwa.'),
      LessonSection('Agasanduku k\'ubutabazi bw\'ibanze',
          'Kagomba kubamo ibikoresho by\'ibanze byo gupfuka ibikomere.'),
      LessonSection('Icyitonderwa',
          'Genzura amabwiriza agezweho y\'ibikoresho bisabwa mu modoka mu Rwanda.'),
    ],
  ),
];

// ---------------------------------------------------------------------
// AMASOMO: Imyitwarire ku Muhanda
// ---------------------------------------------------------------------
const List<Lesson> drivingLessons = <Lesson>[
  Lesson(
    id: 'imyitwarire-1',
    categoryId: 'imyitwarire',
    title: 'Telefoni n\'ibindi birangaza',
    minutes: 5,
    sections: <LessonSection>[
      LessonSection('Telefoni',
          'Birabujijwe kuvugira kuri telefoni utwaye, kwandika cyangwa gusoma ubutumwa. Bikurangaza cyane. Niba ugomba guhamagara, banza uhagarare ahantu hemewe kandi hizewe.'),
      LessonSection('Ibindi birangaza',
          'Kurya, kunywa, kwisiga, gushakisha ibintu mu modoka cyangwa guhindura umuziki kenshi bikura amaso yawe ku muhanda.'),
      LessonSection('Amasegonda make ni byinshi',
          'Iyo ukuye amaso ku muhanda amasegonda abiri gusa, imodoka iba yagenze metero nyinshi utabona ibiri imbere.'),
    ],
  ),
  Lesson(
    id: 'imyitwarire-2',
    categoryId: 'imyitwarire',
    title: 'Intera n\'ikinyabiziga kiri imbere',
    minutes: 4,
    sections: <LessonSection>[
      LessonSection('Kuki intera ari ngombwa',
          'Intera ihagije iguha igihe cyo kubona akaga no gufata feri utagonze ikinyabiziga kiri imbere.'),
      LessonSection('Uburyo bworoshye bwo kuyipima',
          'Hitamo ikimenyetso ku ruhande rw\'umuhanda. Iyo imodoka iri imbere ikirenze, bara amasegonda. Ugomba kukigeraho nyuma y\'amasegonda nibura abiri mu bihe bisanzwe.'),
      LessonSection('Mu bihe bibi',
          'Mu mvura, igihu cyangwa nijoro, ongera intera kuko feri zitinda gufata kandi ukabona nabi.'),
    ],
  ),
  Lesson(
    id: 'imyitwarire-3',
    categoryId: 'imyitwarire',
    title: 'Gukata no guhindura inzira',
    minutes: 4,
    sections: <LessonSection>[
      LessonSection('Mbere yo gukata',
          'Reba mu ndorerwamo, cana ikimenyetso cyo gukata mbere y\'igihe, hanyuma ukate witonze.'),
      LessonSection('Gukatira ibumoso',
          'Iyo ukatira ibumoso ku masangano, tanga inzira ku binyabiziga biza imbere yawe bikomeza imbere cyangwa bikatira iburyo.'),
      LessonSection('Gusubira inyuma',
          'Reba neza inyuma no ku mpande, ugende gahoro. Niba utabona neza, saba umuntu akuyobore.'),
    ],
  ),
  Lesson(
    id: 'imyitwarire-4',
    categoryId: 'imyitwarire',
    title: 'Rond-point n\'amasangano',
    minutes: 4,
    sections: <LessonSection>[
      LessonSection('Kwinjira muri rond-point',
          'Gabanya umuvuduko, kurikiza ibimenyetso biri aho, kandi ukoreshe ikimenyetso cyo gukata usohoka.',
          sign: SignType.roundabout),
      LessonSection('Amasangano',
          'Egera amasangano ugabanya umuvuduko, witegure guhagarara, kandi ntiwinjire niba utazashobora kuyavamo.'),
    ],
  ),
  Lesson(
    id: 'imyitwarire-5',
    categoryId: 'imyitwarire',
    title: 'Mvura, igihu n\'ijoro',
    minutes: 5,
    sections: <LessonSection>[
      LessonSection('Mu mvura',
          'Gabanya umuvuduko, ongera intera, fata feri buhoro kandi wirinde gukata vuba. Cana amatara kugira ngo abandi bakubone.'),
      LessonSection('Mu gihu',
          'Koresha amatara magufi (cyangwa ay\'igihu niba imodoka iyafite). Amatara maremare agaruka mu maso mu gihu, ntakubonesha neza.'),
      LessonSection('Nijoro',
          'Genda ku muvuduko ugushoboza guhagarara mu ntera ubona n\'amatara yawe. Witondere abanyamaguru n\'amagare atagira amatara.'),
    ],
  ),
  Lesson(
    id: 'imyitwarire-6',
    categoryId: 'imyitwarire',
    title: 'Abanyamaguru, moto n\'amagare',
    minutes: 4,
    sections: <LessonSection>[
      LessonSection('Abanyamaguru',
          'Ku nzira y\'abanyamaguru, hagarara ubahe inzira. Witondere cyane abana, abasaza n\'abafite ubumuga.'),
      LessonSection('Bisi ihagaze',
          'Iyo bisi ihagaze yururutsa abagenzi, genda gahoro: abantu bashobora kwambuka umuhanda batunguranye.'),
      LessonSection('Moto n\'amagare',
          'Iyo ubinyuraho, siga intera ihagije ku ruhande. Witondere kuko bishobora guhindura inzira gitunguranye.'),
    ],
  ),
  Lesson(
    id: 'imyitwarire-7',
    categoryId: 'imyitwarire',
    title: 'Iyo imodoka ipfuye cyangwa habaye impanuka',
    minutes: 5,
    sections: <LessonSection>[
      LessonSection('Imodoka ipfuye',
          'Yikure mu muhanda niba bishoboka, cana amatara y\'akaga, shyira mpandeshatu yo kuburira inyuma, kandi abagenzi bajye ahantu hizewe kure y\'umuhanda.'),
      LessonSection('Habaye impanuka',
          'Hagarara, cana amatara y\'akaga, ubanze urebe umutekano wawe, hamagara inzego z\'ubutabazi na polisi, kandi ntukure umukomeretse aho ari keretse ari mu kaga gakomeye.'),
      LessonSection('Ibinyabiziga byihutirwa',
          'Iyo wumvise cyangwa ubonye ambulance, kizimyamwoto cyangwa polisi bifite ibimenyetso byihutirwa, biha inzira mu buryo bwizewe.'),
    ],
  ),
  Lesson(
    id: 'imyitwarire-8',
    categoryId: 'imyitwarire',
    title: 'Umutuzo n\'ikinyabupfura',
    minutes: 3,
    sections: <LessonSection>[
      LessonSection('Irinde uburakari',
          'Niba undi mushoferi akwiciriye amategeko, komeza utuze. Guhangana bitera impanuka.'),
      LessonSection('Umupolisi uguhagaritse',
          'Hagarara ahantu hizewe, uzimye moteri niba ubisabwe, kandi ukurikize amabwiriza ye witonze.'),
      LessonSection('Ihoni',
          'Rikoreshwa kuburira abandi akaga, si ukwerekana uburakari.'),
    ],
  ),
];

// ---------------------------------------------------------------------
// IBIBAZO: Ubumenyi ku Modoka
// ---------------------------------------------------------------------
const List<Question> vehicleQuestions = <Question>[];

// ---------------------------------------------------------------------
// IBIBAZO: Imyitwarire ku Muhanda
// ---------------------------------------------------------------------
const List<Question> drivingQuestions = <Question>[];
