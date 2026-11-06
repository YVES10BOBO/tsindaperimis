-- Make the question bank match the source PDF
-- (questions_sources/AMATEGEKO_YUMUHANDA_IBIBAZO_IBISUBIZO_IB.pdf, Igice cya mbere).
--
-- 1. Deletes the 71 questions that are NOT in the PDF (ids not starting "pdf-q-").
--    Their answers, and any learner reports about them, are deleted with them.
-- 2. Renumbers the remaining 160 so a question's #number equals its number in
--    the PDF (#57 here is question 57 in the book) and orders them like the PDF.
-- 3. Moves 10 questions to the category matching their topic.
-- 4. Removes the second copy of an answer the PDF prints twice (Q10, Q78).
--
-- Runs as one transaction and stops without changing anything unless exactly
-- 160 "pdf-q-" questions exist. Run it once in the Supabase SQL Editor.
begin;

do $$
begin
  if (select count(*) from public.questions where id like 'pdf-q-%') <> 160 then
    raise exception 'Expected 160 pdf-q-* questions, found %. Nothing was changed.',
      (select count(*) from public.questions where id like 'pdf-q-%');
  end if;
end;
$$;

-- 1. Remove the questions that are not in the PDF.
delete from public.questions where id not like 'pdf-q-%';

-- 2. #number = the PDF's question number. Go through negative numbers first so
--    the unique index never sees two equal numbers mid-update.
update public.questions set number = -number;
update public.questions
set number = right(id, 3)::integer,
    sort_order = right(id, 3)::integer - 1;
select setval('public.questions_number_seq', 160, true);

-- 3. Categories (PDF question number -> topic it asks about).
update public.questions set category_id = 'amategeko'
  where id in ('pdf-q-005', 'pdf-q-020', 'pdf-q-021', 'pdf-q-022', 'pdf-q-023', 'pdf-q-024');
update public.questions set category_id = 'amatara'
  where id in ('pdf-q-126', 'pdf-q-127', 'pdf-q-144');
update public.questions set category_id = 'ibimenyetso'
  where id = 'pdf-q-154';

-- 4. Remove a repeated (never the correct) answer, keeping its first copy.
delete from public.question_options o
where not o.is_correct
  and exists (
    select 1 from public.question_options earlier
    where earlier.question_id = o.question_id
      and earlier.position < o.position
      and lower(btrim(earlier.option_text)) = lower(btrim(o.option_text))
  );

commit;

-- Check: expect 160 rows, numbers 1..160, and these category counts:
-- amategeko 27, modoka 45, amatara 34, imirongo 23, imyitwarire 11, umutekano 7, ibimenyetso 13.
select category_id, count(*) as questions, min(number) as first_no, max(number) as last_no
from public.questions
group by category_id
order by category_id;
