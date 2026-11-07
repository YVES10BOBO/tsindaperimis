-- DRAFT lessons for the "Ubumenyi bw'inyongera" category (moto, ubutabazi, gutwara utekanye, kwita ku binyabiziga).
-- All are published = false: learners do NOT see them until you publish each one in the dashboard (Amasomo -> Draft).
-- Written from general knowledge plus facts that also appear in the two source PDFs (e.g. 112, no driving drunk, lights in fog).
-- Please have a mechanic or driving instructor read the safety advice before you publish it.
-- Run 202611070004_lessons_restructure.sql FIRST (it creates the category).
begin;

do $$
begin
  if not exists (select 1 from public.content_categories where id = 'inyongera') then
    raise exception 'Category inyongera is missing: run 202611070004_lessons_restructure.sql first. Nothing was changed.';
  end if;
end;
$$;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('extra-moto-1', 'inyongera', 'Moto: igenzura mbere yo gutangira', 4, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'inyongera'), true, false)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('extra-moto-1-0', 'extra-moto-1', 0, 'Kuki ari ngombwa', 'Moto ntirinda umuyobozi nk''uko imodoka imurinda. Ikibazo gito kuri moto gishobora gutera impanuka ikomeye, bityo igenzura rya buri munsi ni ngombwa mbere yo gutangira urugendo.'),
('extra-moto-1-1', 'extra-moto-1', 1, 'Ibyo ugenzura', 'Feri y''imbere n''iy''inyuma zikora neza. Amapine ntafite ibyangiritse kandi afite umuyaga ukwiye nk''uko uwakoze moto abigena. Amatara y''imbere, ay''inyuma n''ibimenyetso by''ibyerekezo birakora. Indorerwamo ziri mu mwanya kandi zigaragaza inyuma. Hari lisansi n''amavuta bihagije, kandi urunigi cyangwa umukandara uhuza moteri n''ipine bimeze neza.'),
('extra-moto-1-2', 'extra-moto-1', 2, 'Mbere yo kugenda', 'Ambara ingofero n''ibindi bikoresho, ushyire uko wicara neza, hanyuma ugerageze feri uri ahatekanye mbere yo kujya mu muhanda.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('extra-moto-2', 'inyongera', 'Moto: ingofero n''ibikoresho byo kwirinda', 4, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'inyongera'), true, false)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('extra-moto-2-0', 'extra-moto-2', 0, 'Ingofero', 'Ambara ingofero yemewe, ifite ingano ikubereye, kandi uyifunge neza buri gihe, no ku rugendo rugufi. Ingofero idafunze cyangwa ishaje ntirinda umutwe uko bikwiye. Uwo utwaye nawe agomba kuyambara.'),
('extra-moto-2-1', 'extra-moto-2', 1, 'Ibindi bikoresho', 'Ikirahure cyangwa ingofero ifite ikirahure irinda amaso umuyaga n''umukungugu. Gants, ikoti n''inkweto zifunze birinda uruhu iyo ugwa. Imyenda igaragara cyane cyangwa ifite ibigaragaza urumuri ituma abandi bakubona, cyane cyane nijoro.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('extra-moto-3', 'inyongera', 'Moto: gutwara utekanye', 5, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'inyongera'), true, false)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('extra-moto-3-0', 'extra-moto-3', 0, 'Gukoresha feri', 'Koresha feri zombi (iy''imbere n''iy''inyuma) hamwe, buhoro buhoro. Gufata feri ntikwihuse cyane ku muhanda unyerera bishobora gutuma moto igwa.'),
('extra-moto-3-1', 'extra-moto-3', 1, 'Amakoni n''umuhanda unyerera', 'Gabanya umuvuduko mbere yo kugera ku ikoni, aho kuwugabanya uri mu ikoni. Imvura, igihu n''umucanga bituma umuhanda unyerera, bityo ongera intera hagati yawe n''ikinyabiziga kiri imbere.'),
('extra-moto-3-2', 'extra-moto-3', 2, 'Kugaragara no gusiga intera', 'Gucana amatara no kwambara imyenda igaragara bituma abandi bayobozi bakubona. Ntukinjire hagati y''ibinyabiziga bigenda bifatanye, kandi ntukagende ahantu umuyobozi w''ikinyabiziga kinini atakureba mu ndorerwamo.'),
('extra-moto-3-3', 'extra-moto-3', 3, 'Abagenzi', 'Ntutware abagenzi barenze umubare wateganijwe n''uwakoze moto. Umugenzi nawe agomba kwambara ingofero, kandi yicare neza ku ntebe yagenewe.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('extra-butabazi-1', 'inyongera', 'Iyo habaye impanuka', 6, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'inyongera'), true, false)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('extra-butabazi-1-0', 'extra-butabazi-1', 0, 'Hagarara kandi wirinde ibindi byago', 'Guma utuje, uhagarare ahatekanye, kandi ucane amatara ndangacyerekezo yose icyarimwe kugira ngo uburire abandi bayobozi. Shyira ikimenyetso cy''impuguke kure ihagije y''aho ikinyabiziga gihagaze kugira ngo abaza babibone hakiri kare.'),
('extra-butabazi-1-1', 'extra-butabazi-1', 1, 'Hamagara ubutabazi', 'Hamagara ubutabazi kuri 112. Vuga aho uri neza, umubare w''abakomeretse, n''ibyo ubona.'),
('extra-butabazi-1-2', 'extra-butabazi-1', 2, 'Uwakomeretse', 'Ntukure uwakomeretse mu kinyabiziga keretse hari ibyago bikomeye, nko gufata umuriro cyangwa kugongwa n''ikindi kinyabiziga. Ntumuhe ikinyobwo, kandi ntumusabe kunyeganyeza ibice by''umubiri kugira ngo urebe ibikomere. Mumuhumurize uko ushoboye, utegereze ababishinzwe.'),
('extra-butabazi-1-3', 'extra-butabazi-1', 3, 'Impanuka nta wakomeretse', 'Iyo nta wakomeretse ariko ibinyabiziga bishobora guteza ibyago cyangwa bifunze umuhanda, shushanya aho byagonganiye cyangwa ufate amafoto, hanyuma ubishyire ku ruhande rw''umuhanda mbere yo kubivanamo.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('extra-butabazi-2', 'inyongera', 'Ikinyabiziga gipfuye mu nzira', 4, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'inyongera'), true, false)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('extra-butabazi-2-0', 'extra-butabazi-2', 0, 'Hitamo aho uhagarara', 'Hagarara ku nkombe y''umuhanda ahantu hagaragara neza. Ntuhagarare mu ikoni, hejuru y''umusozi cyangwa ahandi abayobozi batakubona hakiri kare.'),
('extra-butabazi-2-1', 'extra-butabazi-2', 1, 'Burira abandi', 'Cana amatara yo kuburira kandi ushyire ikimenyetso cy''impuguke kure y''ikinyabiziga, cyane nijoro cyangwa mu gihu. Abagenzi bagomba kuva mu muhanda bakajya ahatekanye.'),
('extra-butabazi-2-2', 'extra-butabazi-2', 2, 'Gusaba ubufasha', 'Niba udashobora gukemura ikibazo wenyine, hamagara mekanisiye cyangwa ushake ikinyabiziga gikurura, aho kugerageza gukomeza ikinyabiziga gifite ikibazo gikomeye.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('extra-butabazi-3', 'inyongera', 'Ipine ipfuye', 4, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'inyongera'), true, false)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('extra-butabazi-3-0', 'extra-butabazi-3', 0, 'Iyo ipine ipfuye uri mu muhanda', 'Fata uruziga neza, ntukate gutunguranye kandi ntufate feri cyane. Reka ikinyabiziga kigabanye umuvuduko buhoro, wegere inkombe, hanyuma uhagarare ahatekanye.'),
('extra-butabazi-3-1', 'extra-butabazi-3', 1, 'Gusimbuza ipine', 'Hagarara ahari ubutaka burambuye kandi butanyerera, ufunge feri yo guhagarara umwanya munini, ucane amatara yo kuburira. Rekura inzara z''ipine mbere yo kuzamura ikinyabiziga kuri jack, hanyuma usimbuze ipine, ufate inzara neza, wongere ubigenzure nyuma y''urugendo ruto.'),
('extra-butabazi-3-2', 'extra-butabazi-3', 2, 'Ibikoresho', 'Buri gihe ugire ipine y''ingoboka ikoze neza, jack, n''urufunguzo rw''inzara.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('extra-butabazi-4', 'inyongera', 'Moteri ishyushye cyane cyangwa izimye', 4, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'inyongera'), true, false)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('extra-butabazi-4-0', 'extra-butabazi-4', 0, 'Moteri ishyushye cyane', 'Iyo igipimo cy''ubushyuhe kijya hejuru cyangwa hasohoka umwotsi, hagarara ahatekanye, uzimye moteri. Ntukingure igifuniko cy''amazi akonjesha moteri ikiri ishyushye, kuko amazi ashobora kuguruka agakomeretsa.'),
('extra-butabazi-4-1', 'extra-butabazi-4', 1, 'Moteri izimye mu nzira', 'Cana amatara yo kuburira, wegere inkombe niba bishoboka. Gerageza kongera kuyiryosa nyuma yo kumenya impamvu, kandi niba bidakunze, saba ubufasha.'),
('extra-butabazi-4-2', 'extra-butabazi-4', 2, 'Kwirinda', 'Genzura amazi n''amavuta mbere y''urugendo, kandi wite ku matara yo kuburira kuri dashboard.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('extra-utekano-1', 'inyongera', 'Gutwara mu mvura n''igihu', 4, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'inyongera'), true, false)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('extra-utekano-1-0', 'extra-utekano-1', 0, 'Gabanya umuvuduko', 'Mu mvura nyinshi, igihu, umwuzure cyangwa umukungugu mwinshi, bigoranye kubona imbere no guhagarara vuba. Gabanya umuvuduko kandi ukoreshe amatara magufi.'),
('extra-utekano-1-1', 'extra-utekano-1', 1, 'Amatara', 'Mu gihe cy''igihu, koresha amatara kamenabihu. Amatara maremare mu gihu atuma urumuri rugaruka rukaguhuma amaso, bityo wirinde kuyakoresha.'),
('extra-utekano-1-2', 'extra-utekano-1', 2, 'Intera', 'Ongera intera hagati yawe n''ikinyabiziga kiri imbere, kuko feri ikora gahoro ku muhanda utose.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('extra-utekano-2', 'inyongera', 'Gutwara nijoro', 4, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'inyongera'), true, false)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('extra-utekano-2-0', 'extra-utekano-2', 0, 'Amatara', 'Cana amatara uko bwije kugira ngo abandi bakubone. Amatara maremare ayakoreshe gusa igihe umuhanda utamuritse kandi nta kinyabiziga kiri imbere cyangwa kiguturutse imbere.'),
('extra-utekano-2-1', 'extra-utekano-2', 1, 'Guhura n''ikinyabiziga', 'Iyo uhuye n''ikindi kinyabiziga, zimya amatara maremare kugeza gitambutse. Iyo ikinyabiziga kiguturutse imbere kigahumisha amaso, egera inkombe y''iburyo kandi ugabanye umuvuduko.'),
('extra-utekano-2-2', 'extra-utekano-2', 2, 'Guhagarara nijoro', 'Iyo uhagaze ku nkombe nijoro, amatara yo guhagarara aguma yaka, kugira ngo abandi bayobozi bakubone hakiri kare.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('extra-utekano-3', 'inyongera', 'Umunaniro, inzoga na telefone', 4, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'inyongera'), true, false)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('extra-utekano-3-0', 'extra-utekano-3', 0, 'Gutwara wasinze', 'Birabujijwe gutwara ikinyabiziga wasinze. Inzoga zigabanya ubushobozi bwo kubona no gufata ibyemezo vuba. Niba wanyoye, shaka undi utwara.'),
('extra-utekano-3-1', 'extra-utekano-3', 1, 'Umunaniro', 'Iyo wumva ugize umunaniro cyangwa ibitotsi, hagarara ahatekanye, wihe akaruhuko, ndetse ugende gato niba bishoboka. Gufungura ikirahure cyangwa gucuranga umuziki cyane ntibikuraho umunaniro.'),
('extra-utekano-3-2', 'extra-utekano-3', 2, 'Telefone', 'Iyo telefone yawe ihamagawe utwaye, shyira ikinyabiziga ahatekanye, hanyuma uyitabe. Kuvugira kuri telefone utwaye bituma utita ku muhanda.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('extra-utekano-4', 'inyongera', 'Gutwara ku misozi n''amakoni', 4, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'inyongera'), true, false)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('extra-utekano-4-0', 'extra-utekano-4', 0, 'Amakoni', 'Gabanya umuvuduko mbere yo kugera ku ikoni, ukoresheje feri y''urugendo mbere ya buri koni. Ntunyure ku kinyabiziga mu ikoni, kuko udashobora kubona imbere.'),
('extra-utekano-4-1', 'extra-utekano-4', 1, 'Akazamuko gashinze', 'Iyo ugeze ku kazamuko gashinze, gabanya umuvuduko, kandi uguma ku ruhande rw''iburyo wirinda ibyago.'),
('extra-utekano-4-2', 'extra-utekano-4', 2, 'Akamanuko', 'Mu kamanuko, koresha vitensi nto kugira ngo moteri ifashe kugabanya umuvuduko, aho kwishingikiriza feri gusa.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('extra-utekano-5', 'inyongera', 'Gusangira umuhanda n''abandi', 5, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'inyongera'), true, false)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('extra-utekano-5-0', 'extra-utekano-5', 0, 'Abanyamaguru', 'Iyo ugeze ku nzira y''abanyamaguru ugasanga bategereje kwambuka, gabanya umuvuduko witegure guhagarara, kandi wihangane utegereze nibatangira kwambuka.'),
('extra-utekano-5-1', 'extra-utekano-5', 1, 'Abana n''amashuri', 'Iyo ubonye icyapa kigaragaza ishuri, gabanya umuvuduko ukomeze witonze. Iyo za otobisi z''abanyeshuri zihagaze, komeza ugabanyije umuvuduko n''ubwitonzi, kuko abanyeshuri bashobora kwambuka bitunguranye.'),
('extra-utekano-5-2', 'extra-utekano-5', 2, 'Abanyamagare', 'Mu kunyura ku muyobozi w''igare, musige umwanya uhagije.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('extra-kwita-1', 'inyongera', 'Isuzumwa n''ubwishingizi', 4, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'inyongera'), true, false)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('extra-kwita-1-0', 'extra-kwita-1', 0, 'Isuzumwa ry''ikinyabiziga', 'Ikinyabiziga gishya gisuzumwa bwa mbere nyuma y''imyaka ibiri. Icyemezo cy''isuzuma kimara amezi 6 ku binyabiziga bikora ubucuruzi, n''amezi 12 ku bidakora ubucuruzi.'),
('extra-kwita-1-1', 'extra-kwita-1', 1, 'Ubwishingizi', 'Umubare w''abagenzi bemewe gutwarwa mu kinyabiziga wanditse mu bwishingizi. Rero ubwishingizi bugomba kuba bugifite agaciro igihe cyose utwaye.'),
('extra-kwita-1-2', 'extra-kwita-1', 2, 'Ibyangombwa', 'Buri gihe ugendane uruhushya rwo gutwara, icyemezo cy''iyandikwa ry''ikinyabiziga, n''ubwishingizi. Ibyo bishobora gusabwa na polisi igihe cyose.')
on conflict (id) do nothing;


commit;

-- Check: expect 13 draft lessons in 'inyongera' (plus the 7 published ones).
select count(*) filter (where published) as live, count(*) filter (where not published) as drafts
from public.lessons where category_id = 'inyongera';
