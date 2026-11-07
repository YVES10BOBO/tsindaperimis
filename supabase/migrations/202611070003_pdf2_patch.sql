-- Patch for the PDF 2 drafts already in the database (run AFTER 202611070001 was run in its first form).
-- 1) Question #517 (pdf2-q-376) was missing its picture: add it (only if still empty, so your edits are kept).
-- 2) Adds the one question that was left out the first time (PDF row 375, "Iki cyapa gisobanura iki aho banyura bazengurutse ?") as draft #546.
begin;

do $$
begin
  if (select coalesce(max(number), 0) from public.questions) <> 545 or exists (select 1 from public.questions where id = 'pdf2-q-375') then
    raise exception 'Unexpected state (highest number must be 545 and pdf2-q-375 must not exist). Nothing was changed.';
  end if;
end;
$$;

update public.questions set image_path = 'assets/images/road_signs/pdf2/pdf2-q376-115.jpeg'
where id = 'pdf2-q-376' and image_path is null;

insert into public.questions
  (id, category_id, prompt, explanation, sign_type, sign_label, image_path, is_exam_question, sort_order, published, number)
values
('pdf2-q-375', 'ibimenyetso', 'Iki cyapa gisobanura iki aho banyura bazengurutse ?', '', null, null, 'assets/images/road_signs/pdf2/pdf2-q375-114.jpeg', true, 545, false, 546);

insert into public.question_options (id, question_id, position, option_text, is_correct)
values
('pdf2-q-375-0', 'pdf2-q-375', 0, 'Tanga inzira ku binyabiziga biri mu muhanda munini', false),
('pdf2-q-375-1', 'pdf2-q-375', 1, 'Tanga inzira ku binyabiziga biturutse i bumoso', true),
('pdf2-q-375-2', 'pdf2-q-375', 2, 'Tanga inzira ku ma kamyo na za otobisi', false),
('pdf2-q-375-3', 'pdf2-q-375', 3, 'Ibinyabiziga byose uretse amapikipiki bigomba gutanga inzira', false);

select setval('public.questions_number_seq', 546, true);

commit;

-- Check: expect 386 pdf2 drafts, highest number 546, and #517 with a picture.
select (select count(*) from public.questions where id like 'pdf2-q-%') as pdf2, (select max(number) from public.questions) as highest,
       (select image_path from public.questions where id = 'pdf2-q-376') as pic_517;
