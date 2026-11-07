import 'package:flutter/material.dart';

import 'extended_data.dart';
import 'models.dart';
import 'pdf_reference_data.dart';

/// Ibirimo by'urugero. Nyuma bizava muri database (SQLite) no muri API.
/// ICYITONDERWA: Ibisobanuro byose bigomba kugenzurwa n'itegeko rigenga
/// imikoreshereze y'imihanda mu Rwanda mbere yo gusohora app.
final List<LearnCategory> _baseLearnCategories = <LearnCategory>[
  const LearnCategory(
    id: 'amategeko',
    title: "Amategeko y'Umuhanda",
    subtitle: 'Menya amategeko agenga imikoreshereze y\'umuhanda',
    icon: Icons.menu_book,
    color: Color(0xFF2563EB),
    softColor: Color(0xFFEAF1FF),
    lessons: <Lesson>[
      Lesson(
        id: 'amategeko-1',
        categoryId: 'amategeko',
        title: 'Amategeko rusange',
        minutes: 6,
        sections: <LessonSection>[
          LessonSection('Uruhushya rwo gutwara',
              'Umuntu utwara ikinyabiziga agomba kugira uruhushya rwemewe rujyanye n\'ubwoko bw\'ikinyabiziga atwaye, kandi akarugendana.'),
          LessonSection('Umukandara w\'umutekano',
              'Umushoferi n\'abagenzi bagomba kwambara umukandara w\'umutekano aho uri.'),
          LessonSection('Telefoni',
              'Birabujijwe kuvugira kuri telefoni utwaye. Niba ugomba kuvugana n\'umuntu, banza uhagarare ahantu hemewe kandi hizewe.'),
        ],
      ),
      Lesson(
        id: 'amategeko-2',
        categoryId: 'amategeko',
        title: 'Umuvuduko',
        minutes: 5,
        sections: <LessonSection>[
          LessonSection('Umuvuduko ntarengwa',
              'Kurikiza umuvuduko ntarengwa werekanwa n\'ibimenyetso byo ku muhanda.',
              imagePath: 'assets/images/road_signs/pdf/pdf-sign-31-06.jpeg'),
          LessonSection('Hindura umuvuduko ukurikije ibihe',
              'Iyo imvura iguye, hari igihu, cyangwa hari abanyamaguru benshi, gabanya umuvuduko kandi wongere intera hagati yawe n\'ikinyabiziga kiri imbere.'),
        ],
      ),
      Lesson(
        id: 'amategeko-3',
        categoryId: 'amategeko',
        title: 'Uburenganzira bwo gutambuka',
        minutes: 7,
        sections: <LessonSection>[
          LessonSection('Amasangano adafite ibimenyetso',
              'Ku masangano adafite ibimenyetso cyangwa amatara, ikinyabiziga kiva iburyo bwawe ni cyo gitambuka mbere.'),
          LessonSection('Ibimenyetso n\'amatara',
              'Iyo ku masangano hari ibimenyetso, amatara cyangwa umupolisi uyobora umuhanda, ni byo ukurikiza.'),
          LessonSection('Abanyamaguru',
              'Abanyamaguru bari ku nzira yabo bagomba guhabwa inzira.'),
        ],
      ),
      Lesson(
        id: 'amategeko-4',
        categoryId: 'amategeko',
        title: 'Kunyuranaho',
        minutes: 5,
        sections: <LessonSection>[
          LessonSection('Uruhande',
              'Kunyuranaho bisanzwe bikorerwa ibumoso bw\'ikinyabiziga unyuraho.'),
          LessonSection('Aho bibujijwe',
              'Ntunyuranaho mu ikorosi, hejuru y\'umusozi, ku nzira y\'abanyamaguru, cyangwa ahantu hose utabona imbere neza.',
              imagePath: 'assets/images/road_signs/pdf/pdf-sign-31-04.jpeg'),
        ],
      ),
      Lesson(
        id: 'amategeko-5',
        categoryId: 'amategeko',
        title: 'Guhagarara no guparika',
        minutes: 4,
        sections: <LessonSection>[
          LessonSection('Aho utemerewe guparika',
              'Ntuparike ku nzira y\'abanyamaguru, ku masangano, cyangwa aho ikimenyetso kibibuza.',
              imagePath: 'assets/images/road_signs/pdf/pdf-sign-32-05.jpeg'),
        ],
      ),
    ],
  ),
  const LearnCategory(
    id: 'ibimenyetso',
    title: "IBYAPA N’IBIMENYETSO BYO MU MUHANDA",
    subtitle: 'Ibyapa, ibimenyetso byo mu muhanda n’ibisobanuro byabyo',
    icon: Icons.report,
    color: Color(0xFFDC2626),
    softColor: Color(0xFFFDECEC),
    lessons: <Lesson>[
      Lesson(
        id: 'ibimenyetso-1',
        categoryId: 'ibimenyetso',
        title: 'Ibimenyetso by\'uburenganzira',
        minutes: 5,
        sections: <LessonSection>[
          LessonSection('STOP — Hagarara',
              'Hagarara burundu ku murongo wo guhagarara, utange inzira, hanyuma ukomeze igihe nta kaga.',
              imagePath: 'assets/images/road_signs/pdf/pdf-sign-26-06.jpeg'),
          LessonSection('Tanga inzira',
              'Gabanya umuvuduko kandi uhe inzira ibinyabiziga biri ku muhanda ugiye kwinjiramo.',
              imagePath: 'assets/images/road_signs/pdf/pdf-sign-26-05.jpeg'),
        ],
      ),
      Lesson(
        id: 'ibimenyetso-2',
        categoryId: 'ibimenyetso',
        title: 'Ibimenyetso bibuza',
        minutes: 6,
        sections: <LessonSection>[
          LessonSection('Kwinjira birabujijwe',
              'Nta kinyabiziga cyemerewe kwinjira muri uyu muhanda kiturutse kuri uru ruhande.',
              imagePath: 'assets/images/road_signs/pdf/pdf-sign-28-01.jpeg'),
          LessonSection('Kunyuranaho birabujijwe',
              'Ntiwemerewe kunyuranaho n\'ibindi binyabiziga bifite moteri.',
              imagePath: 'assets/images/road_signs/pdf/pdf-sign-31-04.jpeg'),
          LessonSection('Guparika birabujijwe',
              'Ntiwemerewe gusiga ikinyabiziga cyawe aha.',
              imagePath: 'assets/images/road_signs/pdf/pdf-sign-32-05.jpeg'),
        ],
      ),
      Lesson(
        id: 'ibimenyetso-3',
        categoryId: 'ibimenyetso',
        title: 'Ibimenyetso biburira',
        minutes: 5,
        sections: <LessonSection>[
          LessonSection('Akaga',
              'Iburira akaga katagaragazwa n\'ikindi kimenyetso. Gabanya umuvuduko kandi witonde.',
              imagePath: 'assets/images/road_signs/pdf/pdf-sign-26-03.jpeg'),
          LessonSection('Witondere abana',
              'Hafi aha hari ishuri cyangwa ahantu abana bakunze kwambukira.',
              imagePath: 'assets/images/road_signs/pdf/pdf-sign-23-02.jpeg'),
        ],
      ),
      Lesson(
        id: 'ibimenyetso-4',
        categoryId: 'ibimenyetso',
        title: 'Ibimenyetso bitegeka',
        minutes: 5,
        sections: <LessonSection>[
          LessonSection('Komeza imbere gusa',
              'Ugomba gukomeza imbere; ntiwemerewe gukata.',
              imagePath: 'assets/images/road_signs/pdf2/pdf2-q376-115.jpeg'),
          LessonSection('Kata iburyo', 'Ugomba gukata iburyo.',
              imagePath: 'assets/images/road_signs/pdf/pdf-sign-33-02.jpeg'),
          LessonSection('Rond-point',
              'Ugomba kuzenguruka ukurikije icyerekezo cy\'imyambi.',
              imagePath: 'assets/images/road_signs/pdf/pdf-sign-33-04.jpeg'),
        ],
      ),
      Lesson(
        id: 'ibimenyetso-5',
        categoryId: 'ibimenyetso',
        title: 'Ibimenyetso bimenyesha',
        minutes: 3,
        sections: <LessonSection>[
          LessonSection('Inzira y\'abanyamaguru',
              'Imbere hari inzira abanyamaguru bambukiramo. Itegure kubaha inzira.',
              imagePath: 'assets/images/road_signs/pdf/pdf-sign-35-01.jpeg'),
        ],
      ),
    ],
  ),
  const LearnCategory(
    id: 'amatara',
    title: 'Amatara yo mu Muhanda',
    subtitle: 'Menya amatara n\'amabwiriza yayo',
    icon: Icons.traffic,
    color: Color(0xFF16A34A),
    softColor: Color(0xFFEAF8EE),
    lessons: <Lesson>[
      Lesson(
        id: 'amatara-1',
        categoryId: 'amatara',
        title: 'Amatara atatu',
        minutes: 4,
        sections: <LessonSection>[
          LessonSection('Umutuku', 'Hagarara mbere y\'umurongo wo guhagarara.'),
          LessonSection('Umuhondo',
              'Itegure guhagarara. Hagarara, keretse niba utagishobora guhagarara mu mutekano.'),
          LessonSection('Icyatsi',
              'Ushobora gukomeza, ariko gusa niba amasangano arimo ubusa kandi nta kaga.'),
        ],
      ),
      Lesson(
        id: 'amatara-2',
        categoryId: 'amatara',
        title: 'Umupolisi uyobora umuhanda',
        minutes: 3,
        sections: <LessonSection>[
          LessonSection('Ni nde ukurikizwa?',
              'Amabwiriza y\'umupolisi uyobora umuhanda asumba amatara n\'ibimenyetso.'),
        ],
      ),
    ],
  ),
  const LearnCategory(
    id: 'imirongo',
    title: 'Imirongo yo ku Muhanda',
    subtitle: 'Sobanukirwa imirongo ishushanyije ku muhanda',
    icon: Icons.add_road,
    color: Color(0xFFD97706),
    softColor: Color(0xFFFFF4E0),
    lessons: <Lesson>[
      Lesson(
        id: 'imirongo-1',
        categoryId: 'imirongo',
        title: 'Imirongo yo hagati',
        minutes: 4,
        sections: <LessonSection>[
          LessonSection('Umurongo udacagaguye',
              'Ntiwemerewe kuwurenga cyangwa kuwugenderaho.'),
          LessonSection('Umurongo ucagaguye',
              'Ushobora kuwurenga iyo bikenewe, kandi gusa iyo nta kaga.'),
        ],
      ),
      Lesson(
        id: 'imirongo-2',
        categoryId: 'imirongo',
        title: 'Inzira y\'abanyamaguru (zebra)',
        minutes: 3,
        sections: <LessonSection>[
          LessonSection('Imirongo y\'umweru ibangikanye',
              'Yerekana aho abanyamaguru bambukira. Gabanya umuvuduko kandi ubahe inzira.'),
        ],
      ),
    ],
  ),
  LearnCategory(
    id: 'modoka',
    title: 'Ubumenyi ku Modoka',
    subtitle: 'Menya ibice by\'imodoka n\'imikoreshereze yabyo',
    icon: Icons.directions_car,
    color: Color(0xFF4F46E5),
    softColor: Color(0xFFEEF0FF),
    lessons: vehicleLessons,
  ),
  LearnCategory(
    id: 'inyongera',
    title: 'Ubumenyi bw\'inyongera',
    subtitle: 'Kwita ku binyabiziga no gutwara utekanye (ntibibazwa mu kizamini)',
    icon: Icons.build_circle,
    color: Color(0xFF0E7490),
    softColor: Color(0xFFE0F4F8),
    lessons: extraKnowledgeLessons,
  ),
  const LearnCategory(
    id: 'imyitwarire',
    title: 'Imyitwarire ku Muhanda',
    subtitle: 'Wige uko witwara mu bihe bitandukanye',
    icon: Icons.alt_route,
    color: Color(0xFFDB2777),
    softColor: Color(0xFFFDEEF5),
    lessons: drivingLessons,
  ),
  const LearnCategory(
    id: 'umutekano',
    title: 'Umutekano wo mu Muhanda',
    subtitle: 'Wige uburyo bwo kwirinda impanuka',
    icon: Icons.health_and_safety,
    color: Color(0xFF0F766E),
    softColor: Color(0xFFE6F6F3),
    lessons: <Lesson>[
      Lesson(
        id: 'umutekano-1',
        categoryId: 'umutekano',
        title: 'Inzoga n\'umunaniro',
        minutes: 4,
        sections: <LessonSection>[
          LessonSection('Inzoga',
              'Inzoga zigabanya ubushobozi bwo kubona no gufata ibyemezo vuba. Niba wanyoye, shaka undi utwara.'),
          LessonSection('Umunaniro',
              'Niba wumva usinziriye, hagarara ahantu hizewe uruhuke.'),
        ],
      ),
      Lesson(
        id: 'umutekano-2',
        categoryId: 'umutekano',
        title: 'Abanyamaguru n\'abana',
        minutes: 3,
        sections: <LessonSection>[
          LessonSection('Hafi y\'amashuri',
              'Gabanya umuvuduko kandi witegure guhagarara igihe icyo ari cyo cyose.',
              imagePath: 'assets/images/road_signs/pdf/pdf-sign-23-02.jpeg'),
        ],
      ),
    ],
  ),
];

final List<LearnCategory> learnCategories = <LearnCategory>[
  for (final LearnCategory category in _baseLearnCategories)
    LearnCategory(
      id: category.id,
      title: category.title,
      subtitle: category.subtitle,
      icon: category.icon,
      color: category.color,
      softColor: category.softColor,
      lessons: <Lesson>[
        ...category.lessons,
        if (category.id == 'ibimenyetso') ...pdfSignLessons,
      ],
    ),
];
