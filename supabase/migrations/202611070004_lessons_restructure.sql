-- Lessons restructure:
--  1) removes the auto-generated one-paragraph filler lessons ("<category>-inyongera-N") from every category;
--  2) creates the category "Ubumenyi bw'inyongera" (lessons only: no questions, so it never appears in practice or in the exam)
--     and moves 7 general car-care lessons into it;
--  3) removes "Amatara y'imodoka" from "Ubumenyi ku Modoka" (the Amatara category already covers it);
--  4) rewrites "Feri" and adds 5 exam lessons written only from the facts in the two source PDFs.
-- Lessons are published = true; change them in the dashboard if you want to review first.
begin;

delete from public.lessons where id like '%-inyongera-%';

insert into public.content_categories
  (id, title, subtitle, icon_code, icon_font_family, icon_font_package, icon_match_text_direction, color_value, soft_color_value, sort_order, published)
select 'inyongera', 'Ubumenyi bw''inyongera',
       'Kwita ku binyabiziga no gutwara utekanye (ntibibazwa mu kizamini)',
       57623, 'MaterialIcons', null, false, 4279137424, 4292932856,
       coalesce((select max(sort_order) from public.content_categories), 0) + 1, true
on conflict (id) do nothing;

update public.lessons set category_id = 'inyongera', is_extra = true
where id in ('modoka-1', 'modoka-2', 'modoka-3', 'modoka-5', 'modoka-7', 'modoka-8', 'modoka-9');

delete from public.lessons where id = 'modoka-6';

delete from public.lesson_sections where lesson_id = 'modoka-4';

update public.lessons set title = 'Feri', minutes = 5 where id = 'modoka-4';

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('modoka-4-0', 'modoka-4', 0, 'Ubwoko butatu bwa feri', 'Ikinyabiziga kigira feri y''urugendo, feri yo guhagarara umwanya munini, na feri yo gutabara. Buri bwoko bufite icyo bukora, kandi ibibazo byo mu kizamini bibaza ayo mazina.'),
('modoka-4-1', 'modoka-4', 1, 'Feri y''urugendo', 'Ni yo ituma imodoka igenda buhoro kandi igahagarara neza kandi vuba, uko yaba yikoreye kose, yaba iri ahacuramye cyangwa ahaterera. Mu muhanda ufite uruhererekane rw''amakoni, feri y''urugendo ikoreshwa mbere ya buri koni.'),
('modoka-4-2', 'modoka-4', 2, 'Feri yo guhagarara umwanya munini', 'Ituma imodoka iguma aho iri uko yaba yikoreye kose, ku muzamuko cyangwa ku gacuri bya 16%. Imyanya ya feri igomba gufata igakomeza kwegera mu buryo bw''ibyuma, nubwo umuyobozi yaba adahari.'),
('modoka-4-3', 'modoka-4', 3, 'Feri yo gutabara', 'Ikoreshwa kugira ngo ikinyabiziga kigende gahoro igihe feri y''urugendo idakora neza.'),
('modoka-4-4', 'modoka-4', 4, 'Kurekura feri', 'Nta mwanya n''umwe feri ifungirwaho ushobora kurekurana n''ibiziga, keretse iyo kurekurana ari iby''akanya gato, nk''igihe cyo guhinduranya vitensi. Ikinyabiziga ntigishobora kugenda mu muhanda moteri itaka cyangwa vitensi idakora, keretse iyo gikuruwe n''ikindi kinyabiziga.'),
('modoka-4-5', 'modoka-4', 5, 'Romoruki idafite feri y''urugendo', 'Uburemere ntarengwa bwa romoruki idafite feri y''urugendo ntibushobora kurenga kimwe cya kabiri cy''uburemere bw''ikinyabiziga gikurura n''umuyobozi wacyo. Romoruki ntoya ni iyo ifite uburemere butarenga ibiro 750.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('modoka-10', 'modoka', 'Ibipimo by''ibinyabiziga', 6, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'modoka'), false, true)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('modoka-10-0', 'modoka-10', 0, 'Uburebure', 'Ikinyabiziga gifite umutambiko umwe uhuza imipira: uburebure ntiburenza metero 7. Ikinyabiziga gifite imitambiko ibiri cyangwa irenga hadashyizweho icyuma gifata, kikaba gikuruwe n''ikindi cyangwa n''inyamaswa: uburebure bugarukira kuri metero 11. Makuzungu: uburebure ntiburenza metero 17.40. Ibinyabiziga bikururana, icya mbere gikururwa n''inyamaswa: metero 18.'),
('modoka-10-1', 'modoka-10', 1, 'Ibinyabiziga bikururana', 'Ikinyabiziga kigendeshwa na moteri n''ikinyabiziga gikururwa n''inyamaswa ntibishobora gukurura ibinyabiziga birenze bibiri. Gushyira mu muhanda ibinyabiziga bikururana birenze bitatu bisaba uruhushya rutangwa na Minisitiri ushinzwe gutwara abantu n''ibintu, kandi igiteranyo cy''uburebure bwabyo ntikigomba kurenga metero 25.'),
('modoka-10-2', 'modoka-10', 2, 'Ibizirikisho', 'Ibizirikisho (iminyururu cyangwa insinga) bigaragazwa n''icyapa cyera cya mpande enye zingana, gifite nibura santimetero 30 kuri buri ruhande, kiri ku ruhande rw''imbere rw''ikinyabiziga gikurura.'),
('modoka-10-3', 'modoka-10', 3, 'Aho umuyobozi yicara', 'Umuyobozi w''ikinyabiziga, cyangwa w''ikinyamitende gifite moteri gifite ibiziga bitatu cyangwa bine, agomba kugira aho yicara hafite ubugari butari munsi ya santimetero 55.'),
('modoka-10-4', 'modoka-10', 4, 'Impombo y''ibyotsi', 'Isonga y''impombo yohereza ibyotsi ntishobora kwerekezwa iburyo bw''ikinyabiziga.'),
('modoka-10-5', 'modoka-10', 5, 'Ubuhagarike', 'Ubuhagarike bw''ikinyabiziga ni metero 4.20. Nta muyobozi wemerewe kugenza cyangwa gukomeza kugenza ikinyabiziga gifite ubuhagarike burengeje metero 4 habariwemo ibyo cyikoreye, keretse byatangiwe uruhushya.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('modoka-11', 'modoka', 'Uburemere ntarengwa', 5, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'modoka'), false, true)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('modoka-11-0', 'modoka-11', 0, 'Ubwikorezi ntarengwa', 'Ubwikorezi ntarengwa ku binyabiziga bikururana ni toni 16. Kuri buri mutambiko ufungirwaho ibiziga bine ku mitambiko ibiri ikurikiranye, ubwikorezi ntarengwa ni toni 16.'),
('modoka-11-1', 'modoka-11', 1, 'Imitambiko itatu cyangwa irenga', 'Uretse mu mijyi no ku yindi mihanda igenwa na Minisitiri ushinzwe gutwara abantu n''ibintu, uburemere ntarengwa ku binyabiziga bifite imitambiko itatu cyangwa irenga (hatarimo makuzungu) ni toni 16. Ku binyabiziga bifatanye bifite imitambiko itatu, ni toni 12. Mu mijyi no ku mihanda y''igihugu igenwa na Minisitiri, ku mitambiko itatu ifungwaho ibiziga bine, ni toni 24.'),
('modoka-11-2', 'modoka-11', 2, 'Amateme n''ibyome', 'Uretse igihe icyapa kibyerekana ukundi, uburemere ntarengwa ku mateme akozwe mu ngiga z''ibiti cyangwa imbaho ni toni 8. Uburemere ntarengwa bwemewe kujya ku cyome bwerekanwa n''ibyapa biri kuri buri nkombe.'),
('modoka-11-3', 'modoka-11', 3, 'Uburemere bwanditse ku ikarita', 'Ntibyemewe gushyira no gukomeza kugendesha imodoka cyangwa romoruki mu muhanda iyo uburemere bw''ibyikorewe burenze uburemere ntarengwa bwemewe n''ikarita iranga ikinyabiziga, keretse byatangiwe uruhushya. Birabujijwe gutwara ku ntebe z''ikinyabiziga abantu barenze umubare wateganijwe n''uwayikoze.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('modoka-12', 'modoka', 'Imizigo n''abagenzi', 6, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'modoka'), false, true)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('modoka-12-0', 'modoka-12', 0, 'Ubugari bw''imizigo ku binyabiziga bito', 'Amagare na velomoteri (hamwe na remoroki zikuruwe nabyo): ubugari bw''imizigo ntiburenza santimetero 75. Ipikipiki idafite akanyabiziga ko ku ruhande: metero 1.25. Ipikipiki ifite akanyabiziga ko ku ruhande: santimetero 30 ku bugari bw''icyo kinyabiziga kidapakiye.'),
('modoka-12-1', 'modoka-12', 1, 'Ubugari bw''imizigo ku bindi binyabiziga', 'Ibinyamitende bitatu n''ibinyamitende bine bifite cyangwa bidafite moteri: ubugari bw''imizigo ntibushobora kurenga santimetero 30 ku bugari bw''icyo kinyabiziga kidapakiye, kandi ubugari bwose budakuka ni metero 2 na santimetero 50.'),
('modoka-12-2', 'modoka-12', 2, 'Imizigo y''ibinyampeke n''ubwatsi', 'Imizigo igizwe n''ibinyampeke, ikawa, ipamba idatonoye, ibishara, ibyatsi, ibishami cyangwa ubwatsi bw''amatungo bidahambiriye (uretse amapaki afunze): ubugari bushobora kugera kuri metero 2.75. Iyo imizigo ijyanwa mu karere katarenga km 25 uvuye aho yapakiriwe, ubugari bushobora kugera kuri metero 3. Ibinyabiziga bijya mu mirima cyangwa bitahuka, bitarengeje km 20 mu isaha, bishobora kugera ku bugari bwa metero 3.'),
('modoka-12-3', 'modoka-12', 3, 'Imizigo irenga inyuma', 'Amagare, velomoteri, amapikipiki n''ibinyamitende bitatu n''ibine ntibishobora gutwara imizigo irenga santimetero 50 inyuma. Ikinyabiziga gitwaye ibintu birebire bidashobora kugabanywa: imizigo ntishobora kurenga santimetero 300 (metero 3) mu mpera y''inyuma.'),
('modoka-12-4', 'modoka-12', 4, 'Ibimenyetso by''impera y''imizigo', 'Ibimenyetso berekana impera y''inyuma y''imizigo ntibishobora gushyirwa ku buhagarike burenze metero 1 na santimetero 55 uhereye ku butaka. Iyo uburebure bw''imizigo iri ku kanyamizigo gakururwa burenga metero 12, hagomba umuherekeza ukurikiye ako kanyamizigo ku maguru. Iyo akanyamizigo gasunikwa cyangwa ibyo gatwaye bidatuma umuyobozi abona imbere neza, agomba gukurura ikinyabiziga cye.'),
('modoka-12-5', 'modoka-12', 5, 'Abana ku ntebe y''imbere', 'Igihe harimo indi myanya, birabujijwe gutwara ku ntebe y''imbere y''imodoka abana badafite imyaka 12.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('modoka-13', 'modoka', 'Umuvuduko ku bwoko bw''ikinyabiziga', 4, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'modoka'), false, true)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('modoka-13-0', 'modoka-13', 0, 'Imodoka n''amapikipiki', 'Amapikipiki n''imodoka bifite uburemere ntarengwa bwemewe butarenga ibiro 3500 (uretse amavatiri, amatagisi n''ibitwara abantu hamwe): umuvuduko ntarengwa ni 80 km/h.'),
('modoka-13-1', 'modoka-13', 1, 'Amavatiri n''amatagisi', 'Imodoka zikoreshwa nk''amavatiri y''ifasi cyangwa amatagisi zifite uburemere bwemewe butarenga ibiro 3500: umuvuduko ntarengwa ni 70 km/h.'),
('modoka-13-2', 'modoka-13', 2, 'Ibinyabiziga biremereye na velomoteri', 'Imodoka cyangwa ibinyabiziga bikomatanye bifite uburemere ntarengwa bwemewe cyangwa uburemere bugendanwa burenga ibiro 12500, kimwe na velomoteri: umuvuduko ntarengwa ni 50 km/h. Ahatari mu nsisiro, velomoteri ntishobora kurenza 50 km/h.'),
('modoka-13-3', 'modoka-13', 3, 'Ibinyabiziga by''ubuhinzi', 'Ibinyabiziga by''ubuhinzi, bifite imipira irambuka cyangwa itarambuka, ntibigomba kurenza 25 km/h.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('modoka-14', 'modoka', 'Ihoni, amapine n''igihe ikinyabiziga gihagaze', 5, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'modoka'), false, true)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('modoka-14-0', 'modoka-14', 0, 'Ihoni', 'Ibinyabiziga bishobora kurenga 50 km/h ahategamye bidapakiye bigomba kugira ihoni ryumvikanira mu ntera ya metero 50. Velomoteri igomba kugira ihoni ryumvikanira mu ntera ya metero 20. Ihoni ntirivugirizwa hafi y''ibitaro.'),
('modoka-14-1', 'modoka-14', 1, 'Ihoni ku binyabiziga bidapakiye', 'Ibinyabiziga bigendeshwa na moteri (hatarimo velomoteri) n''ibidapakiye, umuvuduko wabyo udashobora kurenga km 50 mu isaha ahateganye, bigomba kugira ihoni ryumvikanira mu ntera ya metero 100.'),
('modoka-14-2', 'modoka-14', 2, 'Inziga n''amapine', 'Birabujijwe kugenza ikinyabiziga gifite inziga zidahagwa cyangwa zikururuka zifite umubyimba uri hasi ya santimetero 4, keretse ibinyabiziga bihinga iyo bigendeshwa mu karere katarenga km 25 uvuye aho biba. Ibiziga bigomba kugira inziga zihagwa zifite amano n''ubujyakuzimu butari munsi ya milimetero imwe.'),
('modoka-14-3', 'modoka-14', 3, 'Ahanyerera', 'Aho hari urwondo cyangwa hanyerera bidasanzwe, ikinyabiziga gishobora gukoresha iminyururu irwanya ubunyerere ku nziga zacyo.'),
('modoka-14-4', 'modoka-14', 4, 'Ikinyabiziga gihagaze nijoro', 'Iyo ikinyabiziga gihagaritswe nijoro ku buryo abayobozi bakigana badashobora kumenya ko kibabereye imbogamizi, kigomba kurangirwa kure n''ikimenyetso cyabigenewe kiri ahantu hagaragara, kugira ngo kiburire hakiri kare abandi bayobozi.')
on conflict (id) do nothing;

insert into public.lessons (id, category_id, title, minutes, sort_order, is_extra, published)
values ('modoka-15', 'modoka', 'Inyamaswa n''ibinyabiziga bikururwa nazo', 5, (select coalesce(max(sort_order), 0) + 1 from public.lessons where category_id = 'modoka'), false, true)
on conflict (id) do nothing;

insert into public.lesson_sections (id, lesson_id, position, heading, body) values
('modoka-15-0', 'modoka-15', 0, 'Inyamaswa zikurura', 'Umubare w''inyamaswa zikurura ikinyabiziga ntushobora kurenga enye zikurikiranye n''eshatu zibangikanye. Hashyirwaho umuherekeza wunganira umuyobozi iyo umubare w''inyamaswa zikurura urenze 5. Iyo ikinyabiziga gikururwa n''inyamaswa nacyo gikuruye ikindi, uburebure bukaba burenga metero 18 (hatabariwemo icyo kinyabiziga cya mbere), hagomba umuherekeza w''ikinyabiziga cya kabiri.'),
('modoka-15-1', 'modoka-15', 1, 'Imikumbi', 'Iyo igenda mu nzira nyabagendwa, imikumbi igomba kugabanywamo udutsiko tugizwe n''inyamaswa zitarenze 10, kandi dutandukanijwe n''intera ya metero 20.'),
('modoka-15-2', 'modoka-15', 2, 'Ibinyabiziga biherekeranyije mu butumwa', 'Ibinyabiziga bikururwa n''inyamaswa biherekeranyije mu butumwa bigomba kugabanywamo amatsinda afite uburebure butarengeje metero 500, kandi hagati yayo hakaba nibura metero 30. Amagambo "ATTENTION CONVOI" yanditse ku cyapa cy''umuhondo mu nyuguti zitukura, ashyirwa ku kinyabiziga cya mbere, agomba gusomeka neza ku manywa mu ntera ya metero 100. Ku mateme, hagati y''ibinyabiziga bifite ibimenyetso byerekana umuvuduko hagomba kuba nibura metero 10.'),
('modoka-15-3', 'modoka-15', 3, 'Inyamaswa idatuje', 'Igihe umuyobozi w''inyamaswa, ifite inyamaswa idatuje, asaba ko ibinyabiziga bihagarara, umuyobozi w''ikinyabiziga agomba guhagarara.')
on conflict (id) do nothing;


commit;

-- Check: expect 0 filler lessons left, the new category with 7 lessons, and 'modoka' with 6 lessons.
select (select count(*) from public.lessons where id like '%-inyongera-%') as filler_left,
       (select count(*) from public.lessons where category_id = 'inyongera') as extra_lessons,
       (select count(*) from public.lessons where category_id = 'modoka') as modoka_lessons;
