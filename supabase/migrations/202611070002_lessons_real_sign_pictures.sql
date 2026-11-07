-- Replace the 16 lesson signs that the app used to draw with code by the real pictures from the PDFs.
-- Each update only applies while the section still has its old sign_type, so a section you edited by hand is left alone.
-- Pictures are bundled in the app (assets/images/road_signs/pdf and pdf2) and shown by the dashboard.
begin;

update public.lesson_sections set image_path = 'assets/images/road_signs/pdf/pdf-sign-31-06.jpeg', sign_type = null, sign_label = null where id = 'amategeko-2-0' and sign_type = 'speedLimit';
update public.lesson_sections set image_path = 'assets/images/road_signs/pdf/pdf-sign-31-04.jpeg', sign_type = null, sign_label = null where id = 'amategeko-4-1' and sign_type = 'noOvertaking';
update public.lesson_sections set image_path = 'assets/images/road_signs/pdf/pdf-sign-32-05.jpeg', sign_type = null, sign_label = null where id = 'amategeko-5-0' and sign_type = 'noParking';
update public.lesson_sections set image_path = 'assets/images/road_signs/pdf/pdf-sign-26-06.jpeg', sign_type = null, sign_label = null where id = 'ibimenyetso-1-0' and sign_type = 'stop';
update public.lesson_sections set image_path = 'assets/images/road_signs/pdf/pdf-sign-26-05.jpeg', sign_type = null, sign_label = null where id = 'ibimenyetso-1-1' and sign_type = 'giveWay';
update public.lesson_sections set image_path = 'assets/images/road_signs/pdf/pdf-sign-28-01.jpeg', sign_type = null, sign_label = null where id = 'ibimenyetso-2-0' and sign_type = 'noEntry';
update public.lesson_sections set image_path = 'assets/images/road_signs/pdf/pdf-sign-31-04.jpeg', sign_type = null, sign_label = null where id = 'ibimenyetso-2-1' and sign_type = 'noOvertaking';
update public.lesson_sections set image_path = 'assets/images/road_signs/pdf/pdf-sign-32-05.jpeg', sign_type = null, sign_label = null where id = 'ibimenyetso-2-2' and sign_type = 'noParking';
update public.lesson_sections set image_path = 'assets/images/road_signs/pdf/pdf-sign-26-03.jpeg', sign_type = null, sign_label = null where id = 'ibimenyetso-3-0' and sign_type = 'danger';
update public.lesson_sections set image_path = 'assets/images/road_signs/pdf/pdf-sign-23-02.jpeg', sign_type = null, sign_label = null where id = 'ibimenyetso-3-1' and sign_type = 'children';
update public.lesson_sections set image_path = 'assets/images/road_signs/pdf2/pdf2-q376-115.jpeg', sign_type = null, sign_label = null where id = 'ibimenyetso-4-0' and sign_type = 'aheadOnly';
update public.lesson_sections set image_path = 'assets/images/road_signs/pdf/pdf-sign-33-02.jpeg', sign_type = null, sign_label = null where id = 'ibimenyetso-4-1' and sign_type = 'turnRight';
update public.lesson_sections set image_path = 'assets/images/road_signs/pdf/pdf-sign-33-04.jpeg', sign_type = null, sign_label = null where id = 'ibimenyetso-4-2' and sign_type = 'roundabout';
update public.lesson_sections set image_path = 'assets/images/road_signs/pdf/pdf-sign-35-01.jpeg', sign_type = null, sign_label = null where id = 'ibimenyetso-5-0' and sign_type = 'pedestrianCrossing';
update public.lesson_sections set image_path = 'assets/images/road_signs/pdf/pdf-sign-33-04.jpeg', sign_type = null, sign_label = null where id = 'imyitwarire-4-0' and sign_type = 'roundabout';
update public.lesson_sections set image_path = 'assets/images/road_signs/pdf/pdf-sign-23-02.jpeg', sign_type = null, sign_label = null where id = 'umutekano-2-0' and sign_type = 'children';

commit;

-- Check: expect 0 sections still drawn by the app.
select count(*) as still_drawn from public.lesson_sections where sign_type is not null;
