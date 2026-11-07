import 'models.dart';

// =====================================================================
// AMAKURU Y'URUGERO (mock data) — Ubumenyi ku Modoka & Imyitwarire ku Muhanda
// Azasimbuzwa amakuru nyayo yemejwe n'inzobere. Ubumenyi rusange ku modoka
// n'umutekano wo mu muhanda, nta mubare cyangwa itegeko ryihariye ryavuzwe.
// =====================================================================

// ---------------------------------------------------------------------
// AMASOMO: Ubumenyi ku Modoka
// ---------------------------------------------------------------------
const List<Lesson> _allVehicleLessons = <Lesson>[
  Lesson(
    id: 'modoka-1',
    categoryId: 'inyongera',
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
    categoryId: 'inyongera',
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
    categoryId: 'inyongera',
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
      LessonSection('Ubwoko butatu bwa feri',
          'Ikinyabiziga kigira feri y\'urugendo, feri yo guhagarara umwanya munini, na feri yo gutabara. Buri bwoko bufite icyo bukora, kandi ibibazo byo mu kizamini bibaza ayo mazina.'),
      LessonSection('Feri y\'urugendo',
          'Ni yo ituma imodoka igenda buhoro kandi igahagarara neza kandi vuba, uko yaba yikoreye kose, yaba iri ahacuramye cyangwa ahaterera. Mu muhanda ufite uruhererekane rw\'amakoni, feri y\'urugendo ikoreshwa mbere ya buri koni.'),
      LessonSection('Feri yo guhagarara umwanya munini',
          'Ituma imodoka iguma aho iri uko yaba yikoreye kose, ku muzamuko cyangwa ku gacuri bya 16%. Imyanya ya feri igomba gufata igakomeza kwegera mu buryo bw\'ibyuma, nubwo umuyobozi yaba adahari.'),
      LessonSection('Feri yo gutabara',
          'Ikoreshwa kugira ngo ikinyabiziga kigende gahoro igihe feri y\'urugendo idakora neza.'),
      LessonSection('Kurekura feri',
          'Nta mwanya n\'umwe feri ifungirwaho ushobora kurekurana n\'ibiziga, keretse iyo kurekurana ari iby\'akanya gato, nk\'igihe cyo guhinduranya vitensi. Ikinyabiziga ntigishobora kugenda mu muhanda moteri itaka cyangwa vitensi idakora, keretse iyo gikuruwe n\'ikindi kinyabiziga.'),
      LessonSection('Romoruki idafite feri y\'urugendo',
          'Uburemere ntarengwa bwa romoruki idafite feri y\'urugendo ntibushobora kurenga kimwe cya kabiri cy\'uburemere bw\'ikinyabiziga gikurura n\'umuyobozi wacyo. Romoruki ntoya ni iyo ifite uburemere butarenga ibiro 750.'),
    ],
  ),
  Lesson(
    id: 'modoka-5',
    categoryId: 'inyongera',
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
    id: 'modoka-7',
    categoryId: 'inyongera',
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
    categoryId: 'inyongera',
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
    categoryId: 'inyongera',
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
  Lesson(
    id: 'modoka-10',
    categoryId: 'modoka',
    title: 'Ibipimo by\'ibinyabiziga',
    minutes: 6,
    sections: <LessonSection>[
      LessonSection('Uburebure',
          'Ikinyabiziga gifite umutambiko umwe uhuza imipira: uburebure ntiburenza metero 7. Ikinyabiziga gifite imitambiko ibiri cyangwa irenga hadashyizweho icyuma gifata, kikaba gikuruwe n\'ikindi cyangwa n\'inyamaswa: uburebure bugarukira kuri metero 11. Makuzungu: uburebure ntiburenza metero 17.40. Ibinyabiziga bikururana, icya mbere gikururwa n\'inyamaswa: metero 18.'),
      LessonSection('Ibinyabiziga bikururana',
          'Ikinyabiziga kigendeshwa na moteri n\'ikinyabiziga gikururwa n\'inyamaswa ntibishobora gukurura ibinyabiziga birenze bibiri. Gushyira mu muhanda ibinyabiziga bikururana birenze bitatu bisaba uruhushya rutangwa na Minisitiri ushinzwe gutwara abantu n\'ibintu, kandi igiteranyo cy\'uburebure bwabyo ntikigomba kurenga metero 25.'),
      LessonSection('Ibizirikisho',
          'Ibizirikisho (iminyururu cyangwa insinga) bigaragazwa n\'icyapa cyera cya mpande enye zingana, gifite nibura santimetero 30 kuri buri ruhande, kiri ku ruhande rw\'imbere rw\'ikinyabiziga gikurura.'),
      LessonSection('Aho umuyobozi yicara',
          'Umuyobozi w\'ikinyabiziga, cyangwa w\'ikinyamitende gifite moteri gifite ibiziga bitatu cyangwa bine, agomba kugira aho yicara hafite ubugari butari munsi ya santimetero 55.'),
      LessonSection('Impombo y\'ibyotsi',
          'Isonga y\'impombo yohereza ibyotsi ntishobora kwerekezwa iburyo bw\'ikinyabiziga.'),
      LessonSection('Ubuhagarike',
          'Ubuhagarike bw\'ikinyabiziga ni metero 4.20. Nta muyobozi wemerewe kugenza cyangwa gukomeza kugenza ikinyabiziga gifite ubuhagarike burengeje metero 4 habariwemo ibyo cyikoreye, keretse byatangiwe uruhushya.'),
    ],
  ),
  Lesson(
    id: 'modoka-11',
    categoryId: 'modoka',
    title: 'Uburemere ntarengwa',
    minutes: 5,
    sections: <LessonSection>[
      LessonSection('Ubwikorezi ntarengwa',
          'Ubwikorezi ntarengwa ku binyabiziga bikururana ni toni 16. Kuri buri mutambiko ufungirwaho ibiziga bine ku mitambiko ibiri ikurikiranye, ubwikorezi ntarengwa ni toni 16.'),
      LessonSection('Imitambiko itatu cyangwa irenga',
          'Uretse mu mijyi no ku yindi mihanda igenwa na Minisitiri ushinzwe gutwara abantu n\'ibintu, uburemere ntarengwa ku binyabiziga bifite imitambiko itatu cyangwa irenga (hatarimo makuzungu) ni toni 16. Ku binyabiziga bifatanye bifite imitambiko itatu, ni toni 12. Mu mijyi no ku mihanda y\'igihugu igenwa na Minisitiri, ku mitambiko itatu ifungwaho ibiziga bine, ni toni 24.'),
      LessonSection('Amateme n\'ibyome',
          'Uretse igihe icyapa kibyerekana ukundi, uburemere ntarengwa ku mateme akozwe mu ngiga z\'ibiti cyangwa imbaho ni toni 8. Uburemere ntarengwa bwemewe kujya ku cyome bwerekanwa n\'ibyapa biri kuri buri nkombe.'),
      LessonSection('Uburemere bwanditse ku ikarita',
          'Ntibyemewe gushyira no gukomeza kugendesha imodoka cyangwa romoruki mu muhanda iyo uburemere bw\'ibyikorewe burenze uburemere ntarengwa bwemewe n\'ikarita iranga ikinyabiziga, keretse byatangiwe uruhushya. Birabujijwe gutwara ku ntebe z\'ikinyabiziga abantu barenze umubare wateganijwe n\'uwayikoze.'),
    ],
  ),
  Lesson(
    id: 'modoka-12',
    categoryId: 'modoka',
    title: 'Imizigo n\'abagenzi',
    minutes: 6,
    sections: <LessonSection>[
      LessonSection('Ubugari bw\'imizigo ku binyabiziga bito',
          'Amagare na velomoteri (hamwe na remoroki zikuruwe nabyo): ubugari bw\'imizigo ntiburenza santimetero 75. Ipikipiki idafite akanyabiziga ko ku ruhande: metero 1.25. Ipikipiki ifite akanyabiziga ko ku ruhande: santimetero 30 ku bugari bw\'icyo kinyabiziga kidapakiye.'),
      LessonSection('Ubugari bw\'imizigo ku bindi binyabiziga',
          'Ibinyamitende bitatu n\'ibinyamitende bine bifite cyangwa bidafite moteri: ubugari bw\'imizigo ntibushobora kurenga santimetero 30 ku bugari bw\'icyo kinyabiziga kidapakiye, kandi ubugari bwose budakuka ni metero 2 na santimetero 50.'),
      LessonSection('Imizigo y\'ibinyampeke n\'ubwatsi',
          'Imizigo igizwe n\'ibinyampeke, ikawa, ipamba idatonoye, ibishara, ibyatsi, ibishami cyangwa ubwatsi bw\'amatungo bidahambiriye (uretse amapaki afunze): ubugari bushobora kugera kuri metero 2.75. Iyo imizigo ijyanwa mu karere katarenga km 25 uvuye aho yapakiriwe, ubugari bushobora kugera kuri metero 3. Ibinyabiziga bijya mu mirima cyangwa bitahuka, bitarengeje km 20 mu isaha, bishobora kugera ku bugari bwa metero 3.'),
      LessonSection('Imizigo irenga inyuma',
          'Amagare, velomoteri, amapikipiki n\'ibinyamitende bitatu n\'ibine ntibishobora gutwara imizigo irenga santimetero 50 inyuma. Ikinyabiziga gitwaye ibintu birebire bidashobora kugabanywa: imizigo ntishobora kurenga santimetero 300 (metero 3) mu mpera y\'inyuma.'),
      LessonSection('Ibimenyetso by\'impera y\'imizigo',
          'Ibimenyetso berekana impera y\'inyuma y\'imizigo ntibishobora gushyirwa ku buhagarike burenze metero 1 na santimetero 55 uhereye ku butaka. Iyo uburebure bw\'imizigo iri ku kanyamizigo gakururwa burenga metero 12, hagomba umuherekeza ukurikiye ako kanyamizigo ku maguru. Iyo akanyamizigo gasunikwa cyangwa ibyo gatwaye bidatuma umuyobozi abona imbere neza, agomba gukurura ikinyabiziga cye.'),
      LessonSection('Abana ku ntebe y\'imbere',
          'Igihe harimo indi myanya, birabujijwe gutwara ku ntebe y\'imbere y\'imodoka abana badafite imyaka 12.'),
    ],
  ),
  Lesson(
    id: 'modoka-13',
    categoryId: 'modoka',
    title: 'Umuvuduko ku bwoko bw\'ikinyabiziga',
    minutes: 4,
    sections: <LessonSection>[
      LessonSection('Imodoka n\'amapikipiki',
          'Amapikipiki n\'imodoka bifite uburemere ntarengwa bwemewe butarenga ibiro 3500 (uretse amavatiri, amatagisi n\'ibitwara abantu hamwe): umuvuduko ntarengwa ni 80 km/h.'),
      LessonSection('Amavatiri n\'amatagisi',
          'Imodoka zikoreshwa nk\'amavatiri y\'ifasi cyangwa amatagisi zifite uburemere bwemewe butarenga ibiro 3500: umuvuduko ntarengwa ni 70 km/h.'),
      LessonSection('Ibinyabiziga biremereye na velomoteri',
          'Imodoka cyangwa ibinyabiziga bikomatanye bifite uburemere ntarengwa bwemewe cyangwa uburemere bugendanwa burenga ibiro 12500, kimwe na velomoteri: umuvuduko ntarengwa ni 50 km/h. Ahatari mu nsisiro, velomoteri ntishobora kurenza 50 km/h.'),
      LessonSection('Ibinyabiziga by\'ubuhinzi',
          'Ibinyabiziga by\'ubuhinzi, bifite imipira irambuka cyangwa itarambuka, ntibigomba kurenza 25 km/h.'),
    ],
  ),
  Lesson(
    id: 'modoka-14',
    categoryId: 'modoka',
    title: 'Ihoni, amapine n\'igihe ikinyabiziga gihagaze',
    minutes: 5,
    sections: <LessonSection>[
      LessonSection('Ihoni',
          'Ibinyabiziga bishobora kurenga 50 km/h ahategamye bidapakiye bigomba kugira ihoni ryumvikanira mu ntera ya metero 50. Velomoteri igomba kugira ihoni ryumvikanira mu ntera ya metero 20. Ihoni ntirivugirizwa hafi y\'ibitaro.'),
      LessonSection('Ihoni ku binyabiziga bidapakiye',
          'Ibinyabiziga bigendeshwa na moteri (hatarimo velomoteri) n\'ibidapakiye, umuvuduko wabyo udashobora kurenga km 50 mu isaha ahateganye, bigomba kugira ihoni ryumvikanira mu ntera ya metero 100.'),
      LessonSection('Inziga n\'amapine',
          'Birabujijwe kugenza ikinyabiziga gifite inziga zidahagwa cyangwa zikururuka zifite umubyimba uri hasi ya santimetero 4, keretse ibinyabiziga bihinga iyo bigendeshwa mu karere katarenga km 25 uvuye aho biba. Ibiziga bigomba kugira inziga zihagwa zifite amano n\'ubujyakuzimu butari munsi ya milimetero imwe.'),
      LessonSection('Ahanyerera',
          'Aho hari urwondo cyangwa hanyerera bidasanzwe, ikinyabiziga gishobora gukoresha iminyururu irwanya ubunyerere ku nziga zacyo.'),
      LessonSection('Ikinyabiziga gihagaze nijoro',
          'Iyo ikinyabiziga gihagaritswe nijoro ku buryo abayobozi bakigana badashobora kumenya ko kibabereye imbogamizi, kigomba kurangirwa kure n\'ikimenyetso cyabigenewe kiri ahantu hagaragara, kugira ngo kiburire hakiri kare abandi bayobozi.'),
    ],
  ),
  Lesson(
    id: 'modoka-15',
    categoryId: 'modoka',
    title: 'Inyamaswa n\'ibinyabiziga bikururwa nazo',
    minutes: 5,
    sections: <LessonSection>[
      LessonSection('Inyamaswa zikurura',
          'Umubare w\'inyamaswa zikurura ikinyabiziga ntushobora kurenga enye zikurikiranye n\'eshatu zibangikanye. Hashyirwaho umuherekeza wunganira umuyobozi iyo umubare w\'inyamaswa zikurura urenze 5. Iyo ikinyabiziga gikururwa n\'inyamaswa nacyo gikuruye ikindi, uburebure bukaba burenga metero 18 (hatabariwemo icyo kinyabiziga cya mbere), hagomba umuherekeza w\'ikinyabiziga cya kabiri.'),
      LessonSection('Imikumbi',
          'Iyo igenda mu nzira nyabagendwa, imikumbi igomba kugabanywamo udutsiko tugizwe n\'inyamaswa zitarenze 10, kandi dutandukanijwe n\'intera ya metero 20.'),
      LessonSection('Ibinyabiziga biherekeranyije mu butumwa',
          'Ibinyabiziga bikururwa n\'inyamaswa biherekeranyije mu butumwa bigomba kugabanywamo amatsinda afite uburebure butarengeje metero 500, kandi hagati yayo hakaba nibura metero 30. Amagambo "ATTENTION CONVOI" yanditse ku cyapa cy\'umuhondo mu nyuguti zitukura, ashyirwa ku kinyabiziga cya mbere, agomba gusomeka neza ku manywa mu ntera ya metero 100. Ku mateme, hagati y\'ibinyabiziga bifite ibimenyetso byerekana umuvuduko hagomba kuba nibura metero 10.'),
      LessonSection('Inyamaswa idatuje',
          'Igihe umuyobozi w\'inyamaswa, ifite inyamaswa idatuje, asaba ko ibinyabiziga bihagarara, umuyobozi w\'ikinyabiziga agomba guhagarara.'),
    ],
  ),
];

/// Amasomo y'ikizamini y'icyiciro cya "Ubumenyi ku Modoka".
final List<Lesson> vehicleLessons = <Lesson>[
  for (final Lesson l in _allVehicleLessons)
    if (l.categoryId == 'modoka') l,
];

/// Amasomo y'icyiciro cy'"Ubumenyi bw'inyongera" (nta bibazo, ntibijya mu myitozo cyangwa mu kizamini).
final List<Lesson> extraKnowledgeLessons = <Lesson>[
  for (final Lesson l in _allVehicleLessons)
    if (l.categoryId == 'inyongera') l,
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
          imagePath: 'assets/images/road_signs/pdf/pdf-sign-33-04.jpeg'),
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
