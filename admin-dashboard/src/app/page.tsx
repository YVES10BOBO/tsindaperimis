'use client';

import { ChangeEvent, type CSSProperties, FormEvent, type ReactNode, useCallback, useEffect, useMemo, useState } from 'react';
import type { Session } from '@supabase/supabase-js';
import { configured, supabase } from '@/lib/supabase';

type Category = { id: string; title: string; subtitle: string; icon_code: number; icon_font_family: string | null; icon_font_package: string | null; color_value: number; soft_color_value: number; sort_order: number; published: boolean };
type Option = { id?: string; position: number; option_text: string; is_correct: boolean };
type Question = { id: string; category_id: string; prompt: string; explanation: string; sign_type: string | null; sign_label: string | null; image_path: string | null; is_exam_question: boolean; sort_order: number; published: boolean; question_options: Option[]; audio_path?: string | null; number?: number | null; created_at?: string; updated_at?: string | null };
type Section = { id?: string; position: number; heading: string; body: string; sign_type: string | null; sign_label: string | null; image_path: string | null };
type Lesson = { id: string; category_id: string; title: string; minutes: number; sort_order: number; created_at: string; updated_at?: string | null; audio_path?: string | null; is_extra: boolean; published: boolean; lesson_sections: Section[] };
type Learner = { id: string; email: string | null; phone: string | null; createdAt: string; lastSignInAt: string | null; bannedUntil: string | null; isAdmin: boolean; progressUpdatedAt: string | null; completedLessons: number; hasProgress: boolean };
type Announcement = { id: string; title: string; body: string; icon: string; published: boolean; published_at: string | null; expires_at: string | null; created_at: string; updated_at: string };
type QuestionReport = { id: string; question_id: string; reason: string; comment: string | null; reporter_id: string | null; status: 'new' | 'resolved'; created_at: string; resolved_at: string | null };
type View = 'overview' | 'questions' | 'reports' | 'lessons' | 'categories' | 'notifications' | 'users';
// Keys must match the question_reports.reason check constraint and the Flutter app.
const reportReasons: Record<string, string> = { wrong_answer: 'Igisubizo nyacyo si cyo', typo: 'Amakosa mu nyandiko', image: 'Ifoto cyangwa icyapa si cyo', other: 'Ibindi' };
type Notice = { kind: 'error' | 'success'; text: string };
type SearchTarget =
  | { kind: 'question'; item: Question } | { kind: 'lesson'; item: Lesson } | { kind: 'category'; item: Category }
  | { kind: 'announcement'; item: Announcement } | { kind: 'report'; search: string } | { kind: 'users'; search: string }
  | { kind: 'view'; view: View; search: string };
type ConfirmOptions = { title: string; message: ReactNode; confirmLabel: string; tone?: 'danger' | 'warning' | 'primary'; requireText?: string };

const emptyQuestion = () => ({ id: '', category_id: '', prompt: '', explanation: '', sign_type: '', sign_label: '', image_path: '', audio_path: '', is_exam_question: true, published: false, options: ['', '', '', ''], correct: 0 });
const emptyLesson = () => ({ id: '', category_id: '', title: '', minutes: 5, is_extra: false, published: false, audio_path: '', sections: [{ heading: '', body: '', sign_type: '', sign_label: '', image_path: '' }] });
const emptyCategory = () => ({ id: '', title: '', subtitle: '', color: '#315c72', soft: '#e7f0f3', icon: '' });
const emptyAnnouncement = () => ({ id: '', title: '', body: '', icon: 'info', published: false, expires_at: '' });
// Keys must match the notifications.icon check constraint and the Flutter app's icon map.
const announcementIcons = [
  { key: 'info', label: 'Amakuru', icon: 'info' },
  { key: 'new', label: 'Ibishya', icon: 'sparkle' },
  { key: 'tip', label: 'Inama', icon: 'bulb' },
  { key: 'reminder', label: 'Kwibutsa', icon: 'clock' },
  { key: 'warning', label: 'Iburira', icon: 'alert' },
  { key: 'exam', label: 'Ikizamini', icon: 'clipboard' },
] as const;
type QuestionForm = ReturnType<typeof emptyQuestion>;
type LessonForm = ReturnType<typeof emptyLesson>;
type LessonSectionForm = LessonForm['sections'][number];

export default function Home() {
  const [session, setSession] = useState<Session | null>(null);
  const [authReady, setAuthReady] = useState(false);
  const [isAdmin, setIsAdmin] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [notice, setNotice] = useState<Notice | null>(null);
  const [busy, setBusy] = useState(false);
  const [view, setView] = useState<View>('overview');
  const [menuOpen, setMenuOpen] = useState(true);
  const [categories, setCategories] = useState<Category[]>([]);
  const [questions, setQuestions] = useState<Question[]>([]);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [learners, setLearners] = useState<Learner[]>([]);
  const [learnerTotal, setLearnerTotal] = useState(0);
  const [learnerPage, setLearnerPage] = useState(1);
  const [learnerSearch, setLearnerSearch] = useState('');
  const [learnerStatus, setLearnerStatus] = useState<'all' | 'active' | 'suspended'>('all');
  const [learnerPageSize, setLearnerPageSize] = useState(10);
  const [learnersReady, setLearnersReady] = useState(false);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'published' | 'draft'>('all');
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [pageSize, setPageSize] = useState(10);
  const [page, setPage] = useState(1);
  const [lessonDateFilter, setLessonDateFilter] = useState<'all' | 'today' | 'yesterday'>('all');
  const [lessonSort, setLessonSort] = useState<'newest' | 'oldest' | 'manual'>('newest');
  const [questionSort, setQuestionSort] = useState<'number' | 'newest' | 'edited'>('number');
  const [questionForm, setQuestionForm] = useState(emptyQuestion);
  const [lessonForm, setLessonForm] = useState(emptyLesson);
  const [categoryForm, setCategoryForm] = useState(emptyCategory);
  const [uploadedPaths, setUploadedPaths] = useState<string[]>([]);
  const [announcements, setAnnouncements] = useState<Announcement[]>([]);
  const [announcementsError, setAnnouncementsError] = useState<string | null>(null);
  const [announcementForm, setAnnouncementForm] = useState(emptyAnnouncement);
  const [reports, setReports] = useState<QuestionReport[]>([]);
  const [reportsError, setReportsError] = useState<string | null>(null);
  const [reportStatus, setReportStatus] = useState<'new' | 'resolved' | 'all'>('new');
  const [paletteOpen, setPaletteOpen] = useState(false);
  const [drawer, setDrawer] = useState<'question' | 'lesson' | 'announcement' | null>(null);
  const [formSnapshot, setFormSnapshot] = useState('');
  const [openSections, setOpenSections] = useState<number[]>([0]);
  const [lessonLayout, setLessonLayout] = useState<'grouped' | 'list'>('grouped');
  const [expandedGroups, setExpandedGroups] = useState<Record<string, boolean>>({});
  const [needsExplanation, setNeedsExplanation] = useState(false);

  const sayError = (error: unknown) => setNotice({ kind: 'error', text: error instanceof Error ? error.message : String(error) });
  // Styled replacement for window.confirm/prompt: resolves true when the admin confirms.
  const [confirmState, setConfirmState] = useState<(ConfirmOptions & { resolve: (ok: boolean) => void }) | null>(null);
  const askConfirm = useCallback((options: ConfirmOptions) => new Promise<boolean>(resolve => setConfirmState({ ...options, resolve })), []);
  const answerConfirm = (ok: boolean) => { confirmState?.resolve(ok); setConfirmState(null); };
  const requireClient = () => { if (!supabase) throw new Error('Shyiramo URL na publishable key muri admin-dashboard/.env.local.'); return supabase; };

  const checkAdmin = useCallback(async (current: Session | null) => {
    setSession(current);
    if (!current || !supabase) { setIsAdmin(false); setAuthReady(true); return; }
    const { data, error } = await supabase.from('admin_users').select('user_id').eq('user_id', current.user.id).maybeSingle();
    setIsAdmin(!error && Boolean(data));
    if (error) setNotice({ kind: 'error', text: `Kugenzura uburenganzira byanze: ${error.message}` });
    else if (!data) setNotice({ kind: 'error', text: 'Konti yinjiye ntabwo yahawe uburenganzira bwa admin.' });
    setAuthReady(true);
  }, []);

  useEffect(() => {
    if (!supabase) { setAuthReady(true); return; }
    void supabase.auth.getSession().then(({ data }) => checkAdmin(data.session));
    const { data: listener } = supabase.auth.onAuthStateChange((_event, next) => { void checkAdmin(next); });
    return () => listener.subscription.unsubscribe();
  }, [checkAdmin]);

  const loadData = useCallback(async () => {
    if (!isAdmin || !supabase) return;
    setBusy(true);
    const [cats, qs, ls, ns, rs] = await Promise.all([
      supabase.from('content_categories').select('*').order('sort_order'),
      supabase.from('questions').select('*, question_options(*)').order('sort_order'),
      supabase.from('lessons').select('*, lesson_sections(*)').order('created_at', { ascending: false }),
      supabase.from('notifications').select('*').order('created_at', { ascending: false }),
      supabase.from('question_reports').select('*').order('created_at', { ascending: false }),
    ]);
    setBusy(false);
    // Kept apart from content errors so a missing notifications or reports migration never blocks lessons and questions.
    setAnnouncements(ns.error ? [] : (ns.data ?? []) as Announcement[]);
    setAnnouncementsError(ns.error ? ns.error.message : null);
    setReports(rs.error ? [] : (rs.data ?? []) as QuestionReport[]);
    setReportsError(rs.error ? rs.error.message : null);
    const firstError = cats.error ?? qs.error ?? ls.error;
    if (firstError) { sayError(firstError); return; }
    setCategories((cats.data ?? []) as Category[]);
    setQuestions((qs.data ?? []) as Question[]);
    setLessons((ls.data ?? []) as Lesson[]);
  }, [isAdmin]);

  useEffect(() => { void loadData(); }, [loadData]);

  const loadLearners = useCallback(async () => {
    if (!session?.access_token || view !== 'users') return;
    setBusy(true);
    try {
      const params = new URLSearchParams({ page: String(learnerPage), perPage: String(learnerPageSize), q: learnerSearch, status: learnerStatus });
      const response = await fetch(`/api/admin/users?${params}`, { headers: { Authorization: `Bearer ${session.access_token}` }, cache: 'no-store' });
      const result = await response.json();
      if (!response.ok) throw new Error(result.error ?? 'Ntibyashobotse kubona abakoresha.');
      setLearners(result.users as Learner[]);
      setLearnerTotal(result.total ?? result.users.length);
      setLearnersReady(true);
    } catch (error) { sayError(error); }
    finally { setBusy(false); }
  }, [session?.access_token, view, learnerPage, learnerPageSize, learnerSearch, learnerStatus]);

  useEffect(() => {
    if (view !== 'users') return;
    const timeout = window.setTimeout(() => { void loadLearners(); }, learnerSearch ? 250 : 0);
    return () => window.clearTimeout(timeout);
  }, [loadLearners, view, learnerSearch]);

  const changeLearnerStatus = async (learner: Learner) => {
    const action = learner.bannedUntil && new Date(learner.bannedUntil) > new Date() ? 'restore' : 'suspend';
    const label = learner.email ?? learner.phone ?? learner.id;
    const ok = await askConfirm(action === 'suspend'
      ? { title: 'Hagarika konti?', message: `${label} ntazongera kwinjira muri app kugeza wongeye gufungura konti ye.`, confirmLabel: 'Hagarika konti', tone: 'warning' }
      : { title: 'Ongera ufungure konti?', message: `${label} azongera kwinjira no gukoresha app.`, confirmLabel: 'Ongera ufungure', tone: 'primary' });
    if (!ok) return;
    setBusy(true);
    try {
      const response = await fetch('/api/admin/users', {
        method: 'PATCH',
        headers: { Authorization: `Bearer ${session?.access_token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId: learner.id, action }),
      });
      const result = await response.json();
      if (!response.ok) throw new Error(result.error ?? 'Guhindura konti ntibyashobotse.');
      setNotice({ kind: 'success', text: action === 'suspend' ? 'Konti yahagaritswe.' : 'Konti yongeye gufungurwa.' });
      await loadLearners();
    } catch (error) { sayError(error); }
    finally { setBusy(false); }
  };

  const uploadImage = async (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return null;
    if (!file.type.startsWith('image/')) throw new Error('Hitamo dosiye y’ishusho gusa.');
    if (file.size > 6 * 1024 * 1024) throw new Error('Ifoto igomba kutarenza 6 MB.');
    const ext = file.name.includes('.') ? file.name.split('.').pop()!.toLowerCase() : 'jpg';
    const path = `signs/${crypto.randomUUID()}.${ext}`;
    const { error } = await requireClient().storage.from('road-signs').upload(path, file, { contentType: file.type, upsert: false });
    if (error) throw error;
    setUploadedPaths(paths => [...paths, path]);
    return path;
  };

  // Deletes uploaded sign images that no question or lesson section uses any more.
  // Bundled app images (assets/...) are never touched.
  const removeUnusedFiles = async (paths: (string | null | undefined)[]) => {
    if (!supabase) return;
    const db = supabase;
    const candidates = [...new Set(paths.filter((path): path is string => typeof path === 'string' && path !== '' && !path.startsWith('assets/') && !/^https?:\/\//i.test(path)))];
    if (!candidates.length) return;
    try {
      const unusedImages: string[] = [];
      const unusedAudio: string[] = [];
      for (const path of candidates) {
        // Recordings live under "recordings/" in the audio bucket; everything else is a sign image.
        const isAudio = path.startsWith('recordings/');
        const [inQuestions, inOther] = await Promise.all(isAudio
          ? [db.from('questions').select('id', { count: 'exact', head: true }).eq('audio_path', path),
             db.from('lessons').select('id', { count: 'exact', head: true }).eq('audio_path', path)]
          : [db.from('questions').select('id', { count: 'exact', head: true }).eq('image_path', path),
             db.from('lesson_sections').select('id', { count: 'exact', head: true }).eq('image_path', path)]);
        if (!inQuestions.error && !inOther.error && !inQuestions.count && !inOther.count) (isAudio ? unusedAudio : unusedImages).push(path);
      }
      if (unusedImages.length) await db.storage.from('road-signs').remove(unusedImages);
      if (unusedAudio.length) await db.storage.from('audio').remove(unusedAudio);
    } catch {
      // Best effort: a file left behind is harmless, so never block the admin on cleanup.
    }
  };

  const uploadAudio = async (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return null;
    if (!file.type.startsWith('audio/')) throw new Error('Hitamo dosiye y’amajwi gusa (MP3, M4A, WAV…).');
    if (file.size > 20 * 1024 * 1024) throw new Error('Amajwi agomba kutarenza 20 MB.');
    const ext = file.name.includes('.') ? file.name.split('.').pop()!.toLowerCase() : 'mp3';
    const path = `recordings/${crypto.randomUUID()}.${ext}`;
    const { error } = await requireClient().storage.from('audio').upload(path, file, { contentType: file.type, upsert: false });
    if (error) throw error;
    setUploadedPaths(paths => [...paths, path]);
    return path;
  };
  const audioUrl = (path: string | null | undefined) => path && supabase ? supabase.storage.from('audio').getPublicUrl(path).data.publicUrl : null;

  const deleteLearner = async (learner: Learner) => {
    const label = learner.email ?? learner.phone ?? learner.id;
    const ok = await askConfirm({ title: 'Siba konti burundu?', message: `Konti ya ${label} n’iterambere rye ryose bizasibwa burundu. Ntibishobora gusubizwa.`, confirmLabel: 'Siba konti', requireText: 'SIBA' });
    if (!ok) return;
    setBusy(true);
    try {
      const response = await fetch('/api/admin/users', {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${session?.access_token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId: learner.id }),
      });
      const result = await response.json();
      if (!response.ok) throw new Error(result.error ?? 'Gusiba konti ntibyashobotse.');
      setNotice({ kind: 'success', text: 'Konti yasibwe burundu.' });
      await loadLearners();
    } catch (error) { sayError(error); }
    finally { setBusy(false); }
  };

  const imageUrl = (path: string | null | undefined) => {
    if (!path) return null;
    if (/^https?:\/\//i.test(path)) return path;
    // Pictures bundled in the app (assets/images/road_signs/pdf, pdf2, ...) are copied to public/road-signs/.
    const bundledPrefix = 'assets/images/road_signs/';
    if (path.startsWith(bundledPrefix)) {
      return path.replace(bundledPrefix, '/road-signs/');
    }
    return supabase ? supabase.storage.from('road-signs').getPublicUrl(path).data.publicUrl : null;
  };

  const signIn = async (event: FormEvent) => {
    event.preventDefault(); setBusy(true); setNotice(null);
    try { const { error } = await requireClient().auth.signInWithPassword({ email: email.trim(), password }); if (error) throw error; }
    catch (error) { sayError(error); }
    finally { setBusy(false); }
  };

  const signOut = async () => { await supabase?.auth.signOut(); setIsAdmin(false); setSession(null); };

  const showQuestion = (form: QuestionForm) => { setQuestionForm(form); setFormSnapshot(JSON.stringify(form)); setUploadedPaths([]); setDrawer('question'); };
  const addOption = () => setQuestionForm(form => form.options.length >= 4 ? form : { ...form, options: [...form.options, ''] });
  // The correct answer cannot be removed; choose another correct answer first.
  const removeOption = (index: number) => setQuestionForm(form => form.options.length <= 2 || index === form.correct ? form : { ...form, options: form.options.filter((_, i) => i !== index), correct: index < form.correct ? form.correct - 1 : form.correct });
  const openQuestion = (q?: Question) => {
    if (!q) { showQuestion({ ...emptyQuestion(), category_id: categoryFilter !== 'all' ? categoryFilter : categories[0]?.id ?? '' }); return; }
    const options = [...q.question_options].sort((a, b) => a.position - b.position);
    showQuestion({ id: q.id, category_id: q.category_id, prompt: q.prompt, explanation: q.explanation, sign_type: q.sign_type ?? '', sign_label: q.sign_label ?? '', image_path: q.image_path ?? '', audio_path: q.audio_path ?? '', is_exam_question: q.is_exam_question, published: q.published, options: options.map(o => o.option_text), correct: Math.max(0, options.findIndex(o => o.is_correct)) });
  };

  const saveQuestion = async (event: FormEvent) => {
    event.preventDefault(); setBusy(true); setNotice(null);
    const previousQuestion = questions.find(q => q.id === questionForm.id);
    const previousImage = previousQuestion?.image_path;
    try {
      const db = requireClient();
      const row = { id: questionForm.id || crypto.randomUUID(), category_id: questionForm.category_id, prompt: questionForm.prompt.trim(), explanation: questionForm.explanation.trim(), sign_type: questionForm.sign_type.trim() || null, sign_label: questionForm.sign_label.trim() || null, image_path: questionForm.image_path || null, ...(audioReady ? { audio_path: questionForm.audio_path || null } : {}), is_exam_question: questionForm.is_exam_question, sort_order: questionForm.id ? (questions.find(q => q.id === questionForm.id)?.sort_order ?? questions.length) : questions.length, published: questionForm.published,
        // Saving in the editor is an edit; publishing or hiding is not. New questions get their number and date from the database.
        ...(questionMetaReady && questionForm.id ? { updated_at: new Date().toISOString() } : {}) };
      const { error } = await db.from('questions').upsert(row); if (error) throw error;
      const remove = await db.from('question_options').delete().eq('question_id', row.id); if (remove.error) throw remove.error;
      const inserted = await db.from('question_options').insert(questionForm.options.map((option_text, position) => ({ id: `${row.id}-${position}-${crypto.randomUUID().slice(0, 8)}`, question_id: row.id, position, option_text: option_text.trim(), is_correct: position === questionForm.correct })));
      if (inserted.error) throw inserted.error;
      setQuestionForm(emptyQuestion()); setDrawer(null); setNotice({ kind: 'success', text: 'Ikibazo cyabitswe neza.' });
      void removeUnusedFiles([previousImage, previousQuestion?.audio_path, ...uploadedPaths]); setUploadedPaths([]);
      await loadData();
    } catch (error) { sayError(error); }
    finally { setBusy(false); }
  };

  const removeQuestion = async (id: string) => {
    const question = questions.find(q => q.id === id);
    if (!(await askConfirm({ title: 'Siba iki kibazo?', message: <>“{question?.prompt}” n’ibisubizo byacyo bizasibwa burundu, kandi abakoresha ntibazongera kukibona.</>, confirmLabel: 'Siba ikibazo' }))) return;
    const files = [question?.image_path, question?.audio_path];
    const { error } = await requireClient().from('questions').delete().eq('id', id);
    if (error) sayError(error); else { setNotice({ kind: 'success', text: 'Ikibazo cyasibwe neza.' }); void removeUnusedFiles(files); await loadData(); }
  };

  const showLesson = (form: LessonForm) => {
    setLessonForm(form); setFormSnapshot(JSON.stringify(form)); setUploadedPaths([]); setDrawer('lesson');
    setOpenSections(form.sections.length <= 3 ? form.sections.map((_, i) => i) : []);
  };
  const openLesson = (lesson?: Lesson, categoryId?: string) => {
    if (!lesson) { showLesson({ ...emptyLesson(), category_id: categoryId ?? (categoryFilter !== 'all' ? categoryFilter : categories[0]?.id ?? '') }); return; }
    const sections = [...lesson.lesson_sections].sort((a, b) => a.position - b.position);
    showLesson({ id: lesson.id, category_id: lesson.category_id, title: lesson.title, minutes: lesson.minutes, is_extra: lesson.is_extra, published: lesson.published, audio_path: lesson.audio_path ?? '', sections: sections.length ? sections.map(s => ({ ...s, sign_type: s.sign_type ?? '', sign_label: s.sign_label ?? '', image_path: s.image_path ?? '' })) : emptyLesson().sections });
  };

  const saveLesson = async (event: FormEvent) => {
    event.preventDefault(); setBusy(true); setNotice(null);
    const existingLesson = lessons.find(l => l.id === lessonForm.id);
    const previousFiles = [...(existingLesson?.lesson_sections.map(section => section.image_path) ?? []), existingLesson?.audio_path];
    // New lessons, and lessons moved to another category, go to the end of that category.
    const endOfCategory = Math.max(-1, ...lessons.filter(l => l.category_id === lessonForm.category_id && l.id !== lessonForm.id).map(l => l.sort_order)) + 1;
    try {
      const db = requireClient();
      const row = { id: lessonForm.id || `lesson-${crypto.randomUUID()}`, category_id: lessonForm.category_id, title: lessonForm.title.trim(), minutes: Number(lessonForm.minutes), sort_order: existingLesson && existingLesson.category_id === lessonForm.category_id ? existingLesson.sort_order : endOfCategory, is_extra: lessonForm.is_extra, published: lessonForm.published,
        ...(audioReady ? { audio_path: lessonForm.audio_path || null } : {}),
        ...(lessonMetaReady && existingLesson ? { updated_at: new Date().toISOString() } : {}) };
      const { error } = await db.from('lessons').upsert(row); if (error) throw error;
      const removed = await db.from('lesson_sections').delete().eq('lesson_id', row.id); if (removed.error) throw removed.error;
      const sections = await db.from('lesson_sections').insert(lessonForm.sections.filter(s => s.heading.trim() && s.body.trim()).map((s, position) => ({ id: `${row.id}-${position}`, lesson_id: row.id, position, heading: s.heading.trim(), body: s.body.trim(), sign_type: s.sign_type || null, sign_label: s.sign_label || null, image_path: s.image_path || null })));
      if (sections.error) throw sections.error;
      setLessonForm(emptyLesson()); setDrawer(null); setNotice({ kind: 'success', text: 'Isomo ryabitswe neza.' });
      void removeUnusedFiles([...previousFiles, ...uploadedPaths]); setUploadedPaths([]);
      await loadData();
    } catch (error) { sayError(error); }
    finally { setBusy(false); }
  };

  const removeLesson = async (id: string) => {
    const lesson = lessons.find(l => l.id === id);
    if (!(await askConfirm({ title: 'Siba iri somo?', message: <>“{lesson?.title}” n’ibice byaryo {lesson?.lesson_sections.length ?? 0} bizasibwa burundu.</>, confirmLabel: 'Siba isomo' }))) return;
    const files = [...(lesson?.lesson_sections.map(section => section.image_path) ?? []), lesson?.audio_path];
    const { error } = await requireClient().from('lessons').delete().eq('id', id);
    if (error) sayError(error); else { setNotice({ kind: 'success', text: 'Isomo ryasibwe neza.' }); void removeUnusedFiles(files); await loadData(); }
  };

  // Swaps an item with its neighbour, then renumbers the list and saves only the rows that moved.
  const saveOrder = async (table: 'lessons' | 'content_categories', ordered: { id: string; sort_order: number }[], id: string, direction: -1 | 1) => {
    const from = ordered.findIndex(item => item.id === id);
    const to = from + direction;
    if (from < 0 || to < 0 || to >= ordered.length) return;
    const next = [...ordered];
    [next[from], next[to]] = [next[to], next[from]];
    const changed = next.map((item, index) => ({ id: item.id, before: item.sort_order, sort_order: index })).filter(item => item.before !== item.sort_order);
    setBusy(true);
    try {
      const db = requireClient();
      const results = await Promise.all(changed.map(item => db.from(table).update({ sort_order: item.sort_order }).eq('id', item.id)));
      const failed = results.find(result => result.error);
      if (failed?.error) throw failed.error;
      await loadData();
    } catch (error) { sayError(error); }
    finally { setBusy(false); }
  };
  const moveLesson = (lesson: Lesson, direction: -1 | 1) => void saveOrder('lessons', lessons.filter(l => l.category_id === lesson.category_id).sort(byOrder), lesson.id, direction);
  const moveCategory = (category: Category, direction: -1 | 1) => void saveOrder('content_categories', [...categories].sort(byOrder), category.id, direction);

  const editCategory = (category: Category) => setCategoryForm({ id: category.id, title: category.title, subtitle: category.subtitle, color: argbToHex(category.color_value, '#315c72'), soft: argbToHex(category.soft_color_value, '#e7f0f3'), icon: category.icon_code ? category.id : '' });

  const saveCategory = async (event: FormEvent) => {
    event.preventDefault(); setBusy(true);
    try {
      const id = categoryForm.id.trim().toLowerCase().replace(/[^a-z0-9-]+/g, '-');
      const existing = categories.some(category => category.id === id);
      // The app draws the icon from a Flutter icon code, so new categories reuse an existing category's icon.
      const iconSource = categories.find(c => c.id === categoryForm.icon && c.icon_code) ?? categories.find(c => c.icon_code);
      const look = { color_value: hexToArgb(categoryForm.color), soft_color_value: hexToArgb(categoryForm.soft), icon_code: iconSource?.icon_code ?? 0, icon_font_family: iconSource?.icon_font_family ?? null, icon_font_package: iconSource?.icon_font_package ?? null };
      const db = requireClient();
      const result = existing
        ? await db.from('content_categories').update({ title: categoryForm.title.trim(), subtitle: categoryForm.subtitle.trim(), ...look }).eq('id', id)
        : await db.from('content_categories').insert({ id, title: categoryForm.title.trim(), subtitle: categoryForm.subtitle.trim(), ...look, icon_match_text_direction: false, sort_order: Math.max(-1, ...categories.map(c => c.sort_order)) + 1, published: false });
      if (result.error) throw result.error;
      setCategoryForm(emptyCategory()); setNotice({ kind: 'success', text: existing ? 'Icyiciro cyahinduwe.' : 'Icyiciro cyongeweho (ntikiratangazwa).'}); await loadData();
    } catch (error) { sayError(error); }
    finally { setBusy(false); }
  };

  const removeCategory = async (category: Category) => {
    const lessonCount = lessons.filter(l => l.category_id === category.id).length;
    const questionCount = questions.filter(q => q.category_id === category.id).length;
    if (lessonCount || questionCount) {
      setNotice({ kind: 'error', text: `Ntushobora gusiba “${category.title}”: kirimo amasomo ${lessonCount} n’ibibazo ${questionCount}. Banza ubyimurire mu kindi cyiciro cyangwa ubisibe.` });
      return;
    }
    if (!(await askConfirm({ title: 'Siba iki cyiciro?', message: <>Icyiciro “{category.title}” kizasibwa burundu. Nta masomo cyangwa ibibazo kirimo.</>, confirmLabel: 'Siba icyiciro' }))) return;
    const { error } = await requireClient().from('content_categories').delete().eq('id', category.id);
    if (error) { sayError(error); return; }
    if (categoryForm.id === category.id) setCategoryForm(emptyCategory());
    setNotice({ kind: 'success', text: 'Icyiciro cyasibwe neza.' });
    await loadData();
  };

  const showAnnouncement = (form: ReturnType<typeof emptyAnnouncement>) => { setAnnouncementForm(form); setFormSnapshot(JSON.stringify(form)); setUploadedPaths([]); setDrawer('announcement'); };
  const openAnnouncement = (item?: Announcement) => showAnnouncement(item
    ? { id: item.id, title: item.title, body: item.body, icon: item.icon, published: item.published, expires_at: item.expires_at ? toDateInput(item.expires_at) : '' }
    : emptyAnnouncement());

  const saveAnnouncement = async (event: FormEvent) => {
    event.preventDefault(); setBusy(true); setNotice(null);
    try {
      const db = requireClient();
      // A chosen end date stays visible until the end of that local day.
      const row = { title: announcementForm.title.trim(), body: announcementForm.body.trim(), icon: announcementForm.icon, published: announcementForm.published, expires_at: announcementForm.expires_at ? new Date(`${announcementForm.expires_at}T23:59:59`).toISOString() : null };
      const result = announcementForm.id
        ? await db.from('notifications').update(row).eq('id', announcementForm.id)
        : await db.from('notifications').insert(row);
      if (result.error) throw result.error;
      setAnnouncementForm(emptyAnnouncement()); setDrawer(null);
      setNotice({ kind: 'success', text: row.published ? 'Ubutumwa bwabitswe kandi bwatangajwe.' : 'Ubutumwa bwabitswe nka draft.' });
      await loadData();
    } catch (error) { sayError(error); }
    finally { setBusy(false); }
  };

  const setReportResolved = async (report: QuestionReport, resolved: boolean) => {
    const { error } = await requireClient().from('question_reports').update({ status: resolved ? 'resolved' : 'new', resolved_at: resolved ? new Date().toISOString() : null }).eq('id', report.id);
    if (error) sayError(error); else { setNotice({ kind: 'success', text: resolved ? 'Raporo yashyizwe mu byakemutse.' : 'Raporo yongeye gufungurwa.' }); await loadData(); }
  };

  const removeReport = async (report: QuestionReport) => {
    if (!(await askConfirm({ title: 'Siba iyi raporo?', message: 'Raporo izasibwa burundu. Ikibazo ubwacyo ntikizahinduka.', confirmLabel: 'Siba raporo' }))) return;
    const { error } = await requireClient().from('question_reports').delete().eq('id', report.id);
    if (error) sayError(error); else { setNotice({ kind: 'success', text: 'Raporo yasibwe neza.' }); await loadData(); }
  };

  const removeAnnouncement = async (item: Announcement) => {
    if (!(await askConfirm({ title: 'Siba ubu butumwa?', message: <>“{item.title}” buzasibwa burundu, kandi abakoresha ntibazongera kububona.</>, confirmLabel: 'Siba ubutumwa' }))) return;
    const { error } = await requireClient().from('notifications').delete().eq('id', item.id);
    if (error) sayError(error); else { setNotice({ kind: 'success', text: 'Ubutumwa bwasibwe neza.' }); await loadData(); }
  };

  const togglePublished = async (table: 'questions' | 'lessons' | 'content_categories' | 'notifications', row: { id: string; published: boolean }) => {
    const { error } = await requireClient().from(table).update({ published: !row.published }).eq('id', row.id);
    if (error) sayError(error); else { setNotice({ kind: 'success', text: row.published ? 'Byahishwe: ubu ni draft, abakoresha ntibabibona.' : 'Byatangajwe: abakoresha barabibona.' }); await loadData(); }
  };

  const filteredQuestions = useMemo(() => {
    const query = search.trim().toLocaleLowerCase();
    // "#57" finds exactly question 57; plain words search the text.
    const wantedNumber = /^#\d+$/.test(query) ? Number(query.slice(1)) : null;
    const time = (value?: string | null) => value ? Date.parse(value) : 0;
    return questions.filter(q => {
      const category = categories.find(c => c.id === q.category_id)?.title ?? '';
      const text = `#${q.number ?? ''} ${q.prompt} ${q.explanation} ${category} ${q.question_options?.map(option => option.option_text).join(' ') ?? ''}`.toLocaleLowerCase();
      const matches = wantedNumber !== null ? q.number === wantedNumber : text.includes(query);
      return matches && (categoryFilter === 'all' || q.category_id === categoryFilter) && (statusFilter === 'all' || q.published === (statusFilter === 'published')) && (!needsExplanation || !q.explanation?.trim());
    }).sort((a, b) => {
      const byNumber = (a.number ?? Number.MAX_SAFE_INTEGER) - (b.number ?? Number.MAX_SAFE_INTEGER) || a.sort_order - b.sort_order;
      if (questionSort === 'newest') return time(b.created_at) - time(a.created_at) || -byNumber;
      if (questionSort === 'edited') return time(b.updated_at) - time(a.updated_at) || byNumber;
      return byNumber;
    });
  }, [questions, categories, search, categoryFilter, statusFilter, needsExplanation, questionSort]);
  // Present once the numbers/dates migration has run; until then saves leave these columns out.
  const questionMetaReady = questions.some(q => q.created_at !== undefined);
  // Present once the audio migration has run; until then saves leave audio_path out.
  const audioReady = questions.some(q => q.audio_path !== undefined) || lessons.some(l => l.audio_path !== undefined);
  const editingNumber = questions.find(q => q.id === questionForm.id)?.number;
  const editingReports = questionForm.id ? reports.filter(r => r.status === 'new' && r.question_id === questionForm.id) : [];
  const lessonMetaReady = lessons.some(l => l.updated_at !== undefined);
  const filteredLessons = useMemo(() => lessons.filter(l => {
    const category = categories.find(c => c.id === l.category_id)?.title ?? '';
    const text = `${l.title} ${category} ${l.lesson_sections?.map(section => `${section.heading} ${section.body}`).join(' ') ?? ''}`.toLocaleLowerCase();
    const dayOffset = lessonDateFilter === 'today' ? 0 : lessonDateFilter === 'yesterday' ? 1 : null;
    return text.includes(search.trim().toLocaleLowerCase()) && (categoryFilter === 'all' || l.category_id === categoryFilter) && (statusFilter === 'all' || l.published === (statusFilter === 'published')) && (dayOffset === null || isOnLocalDay(l.created_at, dayOffset));
  }).sort((a, b) => lessonSort === 'manual'
    ? a.sort_order - b.sort_order
    : lessonSort === 'newest'
      ? Date.parse(b.created_at) - Date.parse(a.created_at)
      : Date.parse(a.created_at) - Date.parse(b.created_at)), [lessons, categories, search, categoryFilter, statusFilter, lessonDateFilter, lessonSort]);
  const filteredCategories = useMemo(() => categories.filter(category => `${category.title} ${category.subtitle} ${category.id}`.toLocaleLowerCase().includes(search.trim().toLocaleLowerCase()) && (statusFilter === 'all' || category.published === (statusFilter === 'published'))), [categories, search, statusFilter]);
  const questionPage = Math.min(page, Math.max(1, Math.ceil(filteredQuestions.length / pageSize)));
  const lessonPage = Math.min(page, Math.max(1, Math.ceil(filteredLessons.length / pageSize)));
  const categoryPage = Math.min(page, Math.max(1, Math.ceil(filteredCategories.length / pageSize)));
  const visibleQuestions = filteredQuestions.slice((questionPage - 1) * pageSize, questionPage * pageSize);
  const visibleLessons = filteredLessons.slice((lessonPage - 1) * pageSize, lessonPage * pageSize);
  const visibleCategories = filteredCategories.slice((categoryPage - 1) * pageSize, categoryPage * pageSize);
  const updateSearch = (value: string) => { setSearch(value); setPage(1); };
  const updateStatusFilter = (value: 'all' | 'published' | 'draft') => { setStatusFilter(value); setPage(1); };
  const updateCategoryFilter = (value: string) => { setCategoryFilter(value); setPage(1); };
  const updatePageSize = (value: number) => { setPageSize(value); setPage(1); };
  const missingExplanations = questions.filter(q => !q.explanation?.trim()).length;
  const newReports = reports.filter(r => r.status === 'new');
  const openReportsByQuestion = useMemo(() => {
    const counts = new Map<string, number>();
    for (const report of reports) if (report.status === 'new') counts.set(report.question_id, (counts.get(report.question_id) ?? 0) + 1);
    return counts;
  }, [reports]);
  const questionById = useMemo(() => new Map(questions.map(q => [q.id, q])), [questions]);
  const filteredReports = useMemo(() => {
    const query = search.trim().toLocaleLowerCase();
    const wantedNumber = /^#\d+$/.test(query) ? Number(query.slice(1)) : null;
    return reports.filter(report => {
      if (reportStatus !== 'all' && report.status !== reportStatus) return false;
      const question = questionById.get(report.question_id);
      if (wantedNumber !== null) return question?.number === wantedNumber;
      return `#${question?.number ?? ''} ${question?.prompt ?? ''} ${report.comment ?? ''} ${reportReasons[report.reason] ?? ''}`.toLocaleLowerCase().includes(query);
    });
  }, [reports, reportStatus, search, questionById]);
  const reportPage = Math.min(page, Math.max(1, Math.ceil(filteredReports.length / pageSize)));
  const visibleReports = filteredReports.slice((reportPage - 1) * pageSize, reportPage * pageSize);
  const filteredAnnouncements = useMemo(() => announcements.filter(item => `${item.title} ${item.body}`.toLocaleLowerCase().includes(search.trim().toLocaleLowerCase()) && (statusFilter === 'all' || item.published === (statusFilter === 'published'))), [announcements, search, statusFilter]);
  const announcementPage = Math.min(page, Math.max(1, Math.ceil(filteredAnnouncements.length / pageSize)));
  const visibleAnnouncements = filteredAnnouncements.slice((announcementPage - 1) * pageSize, announcementPage * pageSize);
  const categoryById = useMemo(() => new Map(categories.map(category => [category.id, category])), [categories]);
  const lessonFiltersActive = Boolean(search.trim()) || statusFilter !== 'all' || categoryFilter !== 'all' || lessonDateFilter !== 'all';
  // Course-builder view: each category is a module holding its lessons in their app order.
  const lessonGroups = useMemo(() => {
    const groups: { key: string; category: Category | null; lessons: Lesson[] }[] = categories.map(category => ({ key: category.id, category, lessons: filteredLessons.filter(l => l.category_id === category.id).sort(byOrder) }));
    const orphans = filteredLessons.filter(l => !categoryById.has(l.category_id)).sort(byOrder);
    if (orphans.length) groups.push({ key: '__none', category: null, lessons: orphans });
    return groups.filter(group => group.lessons.length || !lessonFiltersActive);
  }, [categories, categoryById, filteredLessons, lessonFiltersActive]);
  const setAllGroups = (open: boolean) => setExpandedGroups(Object.fromEntries(lessonGroups.map(group => [group.key, open])));

  const patchSection = (index: number, patch: Partial<LessonSectionForm>) => setLessonForm(form => ({ ...form, sections: form.sections.map((section, i) => i === index ? { ...section, ...patch } : section) }));
  const addSection = () => { setOpenSections(open => [...open, lessonForm.sections.length]); setLessonForm(form => ({ ...form, sections: [...form.sections, emptyLesson().sections[0]] })); };
  const removeSection = (index: number) => { setOpenSections(open => open.filter(i => i !== index).map(i => i > index ? i - 1 : i)); setLessonForm(form => ({ ...form, sections: form.sections.filter((_, i) => i !== index) })); };
  const toggleSection = (index: number) => setOpenSections(open => open.includes(index) ? open.filter(i => i !== index) : [...open, index]);
  const moveSection = (index: number, direction: -1 | 1) => {
    const to = index + direction;
    if (to < 0 || to >= lessonForm.sections.length) return;
    setLessonForm(form => { const sections = [...form.sections]; [sections[index], sections[to]] = [sections[to], sections[index]]; return { ...form, sections }; });
    setOpenSections(open => open.map(i => i === index ? to : i === to ? index : i));
  };

  const closeDrawer = useCallback(async () => {
    const current = drawer === 'question' ? questionForm : drawer === 'lesson' ? lessonForm : announcementForm;
    if (JSON.stringify(current) !== formSnapshot && !(await askConfirm({ title: 'Ufunge utabitse?', message: 'Hari impinduka utabitse. Nufunga ubu, zirasibama.', confirmLabel: 'Funga utabitse', tone: 'warning' }))) return;
    // Photos uploaded while editing but never saved are not used by anything.
    void removeUnusedFiles(uploadedPaths); setUploadedPaths([]);
    setDrawer(null);
  }, [drawer, questionForm, lessonForm, announcementForm, formSnapshot, uploadedPaths, askConfirm]);

  useEffect(() => {
    if (!drawer) return;
    // While a confirmation popup is open, Escape belongs to that popup.
    const onKey = (event: KeyboardEvent) => { if (event.key === 'Escape' && !confirmState) void closeDrawer(); };
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    window.addEventListener('keydown', onKey);
    return () => { window.removeEventListener('keydown', onKey); document.body.style.overflow = previousOverflow; };
  }, [drawer, closeDrawer, confirmState]);

  // Ctrl/Cmd+K opens the dashboard-wide search (not over an open editor, so no edit is lost).
  useEffect(() => {
    if (!session || !isAdmin) return;
    const onKey = (event: KeyboardEvent) => {
      if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k' && !drawer) {
        event.preventDefault();
        setPaletteOpen(open => !open);
      }
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [session, isAdmin, drawer]);

  const goToResult = (target: SearchTarget) => {
    setPaletteOpen(false);
    setNotice(null);
    setPage(1);
    if (target.kind === 'question') { setView('questions'); openQuestion(target.item); }
    else if (target.kind === 'lesson') { setView('lessons'); openLesson(target.item); }
    else if (target.kind === 'category') { setView('categories'); setSearch(''); editCategory(target.item); }
    else if (target.kind === 'announcement') { setView('notifications'); openAnnouncement(target.item); }
    else if (target.kind === 'report') { setView('reports'); setReportStatus('all'); setSearch(target.search); }
    else if (target.kind === 'users') { setView('users'); setLearnerSearch(target.search); setLearnerPage(1); }
    else { setView(target.view); setSearch(target.search); if (target.view === 'reports') setReportStatus('all'); if (target.view === 'questions' || target.view === 'notifications') setStatusFilter('all'); }
  };

  // Toasts close by themselves; errors stay longer so they can be read.
  useEffect(() => {
    if (!notice || !session || !isAdmin) return;
    const timeout = window.setTimeout(() => setNotice(null), notice.kind === 'success' ? 4000 : 9000);
    return () => window.clearTimeout(timeout);
  }, [notice, session, isAdmin]);

  if (!authReady) return <main className="center"><span className="spinner" /> Kugenzura konti...</main>;
  if (!configured || !supabase) return <main className="center"><section className="login-card"><Brand /><h1>Huza Supabase</h1><p>Copy admin-dashboard/.env.example to admin-dashboard/.env.local, then add your project URL and publishable key.</p></section></main>;
  if (!session || !isAdmin) return <main className="center"><form className="login-card" onSubmit={signIn}><Brand /><p className="eyebrow">AMATEGEKO Y’UMUHANDA</p><h1>Admin Dashboard</h1><p>Injira ukoresheje konti yemerewe gucunga ibikubiye muri app.</p>{notice && <div className={`notice ${notice.kind}`}>{notice.text}</div>}<label>Email<input type="email" autoComplete="username" required value={email} onChange={e => setEmail(e.target.value)} /></label><label>Ijambo ry’ibanga<input type="password" autoComplete="current-password" required value={password} onChange={e => setPassword(e.target.value)} /></label><button className="primary full" disabled={busy}>{busy ? 'Tegereza...' : 'Injira'}</button><small>Konti igomba kuba yanditswe muri <code>admin_users</code> ya Supabase.</small></form></main>;

  return <main className={`shell grid min-h-screen transition-[grid-template-columns] duration-300 ease-in-out ${menuOpen ? '' : 'sidebar-collapsed'}`}>
    <aside className="sidebar sticky top-0 flex h-screen flex-col overflow-hidden transition-all duration-300"><Brand /><div className="side-label">IMICUNGIRE</div><nav className="sidebar-nav flex flex-col">{(['overview', 'questions', 'reports', 'lessons', 'categories', 'notifications', 'users'] as View[]).map(item => <button key={item} className={`nav-item ${view === item ? 'active' : ''}`} onClick={() => { setView(item); setNotice(null); setSearch(''); setPage(1); }}><span className="nav-icon"><Icon name={item} /></span>{{ overview: 'Incamake', questions: 'Ibibazo', reports: 'Raporo', lessons: 'Amasomo', categories: 'Ibyiciro', notifications: 'Ubutumwa', users: 'Abakoresha' }[item]}<span className="nav-count">{item === 'questions' ? questions.length : item === 'lessons' ? lessons.length : item === 'categories' ? categories.length : item === 'notifications' ? announcements.length || '' : item === 'reports' ? newReports.length || '' : item === 'users' ? learnerTotal || '' : ''}</span></button>)}</nav><div className="sidebar-bottom"><span className="avatar">{session.user.email?.slice(0, 1).toUpperCase() ?? 'A'}</span><span className="admin-email">{session.user.email}</span><button className="text-button" onClick={signOut}>Sohoka</button></div></aside>
    <section className="workspace mx-auto w-full max-w-[1550px]"><header className="topbar"><div className="topbar-title"><button className="sidebar-toggle grid h-[42px] w-[42px] place-items-center rounded-xl border border-slate-300 bg-white text-xl text-brand-800 transition duration-200 hover:-translate-y-px hover:border-brand-100 hover:bg-brand-50" type="button" aria-label={menuOpen ? 'Funga sidebar' : 'Fungura sidebar'} aria-expanded={menuOpen} onClick={() => setMenuOpen(open => !open)}>{menuOpen ? '×' : '☰'}</button><div><span className="eyebrow">AMATEGEKO Y’UMUHANDA / ADMIN</span><h1>{{ overview: 'Incamake', questions: 'Gucunga ibibazo', lessons: 'Gucunga amasomo', categories: 'Gucunga ibyiciro', notifications: 'Gucunga ubutumwa', reports: 'Raporo z’abakoresha', users: 'Gucunga abakoresha' }[view]}</h1></div></div><div className="top-actions"><button type="button" className="global-search" onClick={() => setPaletteOpen(true)} disabled={Boolean(drawer)}><Icon name="search" /><span>Shakisha hose</span><kbd>Ctrl K</kbd></button><span className="secure"><i /> Konti ya admin</span><button className="refresh" onClick={() => view === 'users' ? void loadLearners() : void loadData()} title="Ongera uvugurure">↻</button></div></header>
      <div className="cm-toast-region" aria-live="polite">{notice && <Toast notice={notice} onClose={() => setNotice(null)} />}</div>
      {confirmState && <ConfirmDialog {...confirmState} onAnswer={answerConfirm} />}
      {paletteOpen && <GlobalSearch questions={questions} lessons={lessons} categories={categories} announcements={announcements} reports={reports} questionById={questionById} onPick={goToResult} onClose={() => setPaletteOpen(false)} />}
      {view === 'overview' && <><div className="dashboard-hero"><div><p className="eyebrow">AMATEGEKO Y’UMUHANDA · ADMIN</p><h2>Murakaza neza 👋</h2><p>Reba uko app ihagaze, ucunge abakoresha, kandi uvugurure ibikubiye muri app.</p></div><div className="hero-actions"><button className="primary" onClick={() => { openQuestion(); setView('questions'); }}>＋ Ikibazo gishya</button><button className="hero-secondary" onClick={() => { openLesson(); setView('lessons'); }}>＋ Isomo rishya</button></div><div className="hero-orb orb-one" /><div className="hero-orb orb-two" /></div><div className="section-heading dashboard-heading"><div><p className="eyebrow">INCAMAKE Y’IBIKUBIYE MURI APP</p><h2>Uko ibintu bihagaze</h2></div><span className="live-label"><i /> Bivuye muri Supabase</span></div><div className="stat-grid dashboard-stats"><Stat label="Ibibazo" value={questions.length} detail={`${questions.filter(q => q.published).length} byatangajwe · ${questions.filter(q => !q.published).length} draft`} icon="questions" onClick={() => setView('questions')} /><Stat label="Amasomo" value={lessons.length} detail={`${lessons.filter(l => l.published).length} yatangajwe · ${lessons.filter(l => !l.published).length} draft`} icon="lessons" onClick={() => setView('lessons')} /><Stat label="Ibyiciro" value={categories.length} detail={`${categories.filter(c => c.published).length} byatangajwe`} icon="categories" onClick={() => setView('categories')} /><Stat label="Abakoresha" value={learnersReady ? learnerTotal : '—'} detail={learnersReady ? 'Konti zose za Supabase Auth' : 'Fungura abakoresha urebe umubare'} icon="users" onClick={() => setView('users')} /></div><div className="dashboard-columns"><section className="manage-panel"><div className="section-heading"><div><p className="eyebrow">GUCUNGA</p><h2>Ibice bya dashboard</h2></div></div><div className="manage-grid"><ManageCard icon="questions" title="Ibibazo" detail={`${questions.length} byose · ${questions.filter(q => !q.published).length} draft`} onClick={() => setView('questions')} /><ManageCard icon="lessons" title="Amasomo" detail={`${lessons.length} yose · ${lessons.filter(l => !l.published).length} draft`} onClick={() => setView('lessons')} /><ManageCard icon="categories" title="Ibyiciro" detail={`${categories.length} byo gutondekamo`} onClick={() => setView('categories')} /><ManageCard icon="users" title="Abakoresha" detail="Reba konti, gushakisha no guhagarika konti" onClick={() => setView('users')} /></div></section><aside className="review-panel"><div><p className="eyebrow">IBIKENEYE KWITABWAHO</p><h2>Ibikorwa byo gukurikirana</h2></div><ReviewRow label="Ibibazo bitaratangazwa" count={questions.filter(q => !q.published).length} onClick={() => { setStatusFilter('draft'); setView('questions'); }} /><ReviewRow label="Amasomo ataratangazwa" count={lessons.filter(l => !l.published).length} onClick={() => { setStatusFilter('draft'); setView('lessons'); }} /><ReviewRow label="Ibyiciro bitaratangazwa" count={categories.filter(c => !c.published).length} onClick={() => { setStatusFilter('draft'); setView('categories'); }} /><ReviewRow label="Raporo nshya z’amakosa" count={newReports.length} onClick={() => { setReportStatus('new'); setView('reports'); }} /><ReviewRow label="Ubutumwa butaratangazwa" count={announcements.filter(a => !a.published).length} onClick={() => { setStatusFilter('draft'); setView('notifications'); }} /><ReviewRow label="Ibibazo bidafite ibisobanuro" count={missingExplanations} onClick={() => { setStatusFilter('all'); setNeedsExplanation(true); setPage(1); setView('questions'); }} /><p className="footnote">Suzuma ibiri muri draft mbere yo kubitangaza ku bakoresha app.</p></aside></div></>}

      {view === 'questions' && <>
        <div className="cm-toolbar">
          <SearchBox value={search} onChange={updateSearch} placeholder={questionMetaReady ? 'Shakisha ikibazo, igisubizo, cyangwa #nimero...' : 'Shakisha ikibazo, igisubizo cyangwa icyiciro...'} />
          <select className="cm-select" aria-label="Icyiciro" value={categoryFilter} onChange={event => updateCategoryFilter(event.target.value)}><option value="all">Ibyiciro byose</option>{categories.map(c => <option key={c.id} value={c.id}>{c.title}</option>)}</select>
          {questionMetaReady && <select className="cm-select" aria-label="Uko ibibazo bikurikirana" value={questionSort} onChange={event => { setQuestionSort(event.target.value as typeof questionSort); setPage(1); }}><option value="number">Nimero (#1, #2, …)</option><option value="newest">Ibyongewe vuba</option><option value="edited">Ibyahinduwe vuba</option></select>}
          <button className="primary" onClick={() => openQuestion()}>+ Ikibazo gishya</button>
        </div>
        <div className="cm-subbar">
          <StatusTabs value={statusFilter} onChange={updateStatusFilter} counts={{ all: questions.length, published: questions.filter(q => q.published).length, draft: questions.filter(q => !q.published).length }} />
          <button type="button" className={`cm-flag ${needsExplanation ? 'active' : ''}`} aria-pressed={needsExplanation} onClick={() => { setNeedsExplanation(on => !on); setPage(1); }}><Icon name="alert" />Nta bisobanuro<span>{missingExplanations}</span></button>
          <PageSizeSelect value={pageSize} onChange={updatePageSize} />
        </div>
        <div className="cm-list cm-cards">
          <div className="cm-list-head"><b>{filteredQuestions.length} bibazo</b><span>{busy ? 'Biravugururwa...' : 'Bivuye muri Supabase'}</span></div>
          {visibleQuestions.map(q => <QuestionRow key={q.id} question={q} category={categoryById.get(q.category_id)} image={imageUrl(q.image_path)} openReports={openReportsByQuestion.get(q.id) ?? 0} onOpen={() => openQuestion(q)} onToggle={() => void togglePublished('questions', q)} onDelete={() => void removeQuestion(q.id)} />)}
          {filteredQuestions.length === 0 && <Empty text="Nta kibazo gihuye n'ishakisha cyangwa filters." />}
          <Pagination total={filteredQuestions.length} page={questionPage} pageSize={pageSize} onPageChange={setPage} />
        </div>
      </>}

      {view === 'lessons' && <>
        <div className="cm-toolbar">
          <SearchBox value={search} onChange={updateSearch} placeholder="Shakisha isomo, igice cyangwa icyiciro..." />
          <select className="cm-select" aria-label="Icyiciro" value={categoryFilter} onChange={event => updateCategoryFilter(event.target.value)}><option value="all">Ibyiciro byose</option>{categories.map(c => <option key={c.id} value={c.id}>{c.title}</option>)}</select>
          <select className="cm-select" aria-label="Itariki yongeweho" value={lessonDateFilter} onChange={event => { setLessonDateFilter(event.target.value as typeof lessonDateFilter); setPage(1); }}><option value="all">Amatariki yose</option><option value="today">Yongewe uyu munsi</option><option value="yesterday">Yongewe ejo</option></select>
          <button className="primary" onClick={() => openLesson()}>+ Isomo rishya</button>
        </div>
        <div className="cm-subbar">
          <StatusTabs value={statusFilter} onChange={updateStatusFilter} counts={{ all: lessons.length, published: lessons.filter(l => l.published).length, draft: lessons.filter(l => !l.published).length }} />
          <div className="cm-segment" role="group" aria-label="Uko amasomo agaragara"><button type="button" aria-pressed={lessonLayout === 'grouped'} onClick={() => setLessonLayout('grouped')}>Ku byiciro</button><button type="button" aria-pressed={lessonLayout === 'list'} onClick={() => setLessonLayout('list')}>Urutonde</button></div>
          {lessonLayout === 'list' && <><label className="cm-rows-select">Uko akurikirana<select value={lessonSort} onChange={event => { setLessonSort(event.target.value as typeof lessonSort); setPage(1); }}><option value="newest">Ashya mbere</option><option value="oldest">Ashaje mbere</option><option value="manual">Uko yatondetswe</option></select></label><PageSizeSelect value={pageSize} onChange={updatePageSize} /></>}
        </div>
        {lessonLayout === 'grouped' ? <div className="cm-groups">
          <div className="cm-groups-head"><span>{filteredLessons.length} masomo mu byiciro {lessonGroups.filter(group => group.lessons.length).length}</span><span className="cm-groups-actions"><button type="button" className="text-button" onClick={() => setAllGroups(true)}>Fungura byose</button><button type="button" className="text-button" onClick={() => setAllGroups(false)}>Funga byose</button></span></div>
          {lessonGroups.map((group, index) => {
            const open = expandedGroups[group.key] ?? (lessonFiltersActive || index === 0);
            const published = group.lessons.filter(l => l.published).length;
            const drafts = group.lessons.length - published;
            const minutes = group.lessons.reduce((sum, l) => sum + (l.minutes || 0), 0);
            return <section className="cm-group" key={group.key} style={catStyle(group.category)}>
              <div className="cm-group-head">
                <button type="button" className="cm-group-toggle" aria-expanded={open} onClick={() => setExpandedGroups(groups => ({ ...groups, [group.key]: !open }))}>
                  <span className="cm-group-num">{String(index + 1).padStart(2, '0')}</span>
                  <span className="cm-group-copy"><strong>{group.category?.title ?? 'Nta cyiciro'}</strong><small>{group.lessons.length} amasomo · {published} yatangajwe{drafts ? ` · ${drafts} draft` : ''} · {minutes} min</small></span>
                  <Icon name="chevron" className={open ? 'cm-icon cm-chevron open' : 'cm-icon cm-chevron'} />
                </button>
                {group.category && <button type="button" className="cm-add" onClick={() => openLesson(undefined, group.key)}>+ Isomo</button>}
              </div>
              {open && <div className="cm-group-rows cm-cards">{group.lessons.length ? group.lessons.map((lesson, i) => <LessonRow key={lesson.id} lesson={lesson} index={i + 1} onMove={lessonFiltersActive ? undefined : direction => moveLesson(lesson, direction)} first={i === 0} last={i === group.lessons.length - 1} onOpen={() => openLesson(lesson)} onToggle={() => void togglePublished('lessons', lesson)} onDelete={() => void removeLesson(lesson.id)} />) : <p className="cm-group-empty">Nta somo riri muri iki cyiciro.</p>}</div>}
            </section>;
          })}
          {lessonGroups.length === 0 && <div className="cm-list"><Empty text="Nta somo rihuye n'ishakisha cyangwa filters." /></div>}
        </div> : <div className="cm-list cm-cards">
          <div className="cm-list-head"><b>{filteredLessons.length} masomo</b><span>{busy ? 'Biravugururwa...' : 'Bivuye muri Supabase'}</span></div>
          {visibleLessons.map(lesson => <LessonRow key={lesson.id} lesson={lesson} category={categoryById.get(lesson.category_id)} onOpen={() => openLesson(lesson)} onToggle={() => void togglePublished('lessons', lesson)} onDelete={() => void removeLesson(lesson.id)} />)}
          {filteredLessons.length === 0 && <Empty text="Nta somo rihuye n'ishakisha cyangwa filters." />}
          <Pagination total={filteredLessons.length} page={lessonPage} pageSize={pageSize} onPageChange={setPage} />
        </div>}
      </>}

      {view === 'categories' && <><div className="toolbar"><ListControls search={search} onSearchChange={updateSearch} status={statusFilter} onStatusChange={updateStatusFilter} pageSize={pageSize} onPageSizeChange={updatePageSize} categories={categories} placeholder="Shakisha icyiciro..." showCategory={false} /></div><div className="category-layout"><form className="editor-card" onSubmit={saveCategory}><p className="eyebrow">{categories.some(c => c.id === categoryForm.id) ? 'HINDURA ICYICIRO' : 'ICYICIRO GISHYA'}</p><h2>{categories.some(c => c.id === categoryForm.id) ? 'Hindura icyiciro' : 'Ongeramo icyiciro'}</h2><label>Izina rigufi / ID<input required pattern="[A-Za-z0-9-]+" placeholder="urugero: ibimenyetso" value={categoryForm.id} readOnly={categories.some(c => c.id === categoryForm.id)} onChange={e => setCategoryForm({ ...categoryForm, id: e.target.value })} /></label><label>Izina rigaragara<input required value={categoryForm.title} onChange={e => setCategoryForm({ ...categoryForm, title: e.target.value })} /></label><label>Ibisobanuro bigufi<input value={categoryForm.subtitle} onChange={e => setCategoryForm({ ...categoryForm, subtitle: e.target.value })} /></label><div className="two-fields"><label>Ibara nyamukuru<input className="color-input" type="color" value={categoryForm.color} onChange={e => setCategoryForm({ ...categoryForm, color: e.target.value })} /></label><label>Ibara ryoroheje<input className="color-input" type="color" value={categoryForm.soft} onChange={e => setCategoryForm({ ...categoryForm, soft: e.target.value })} /></label></div><label>Agashushanyo muri app<select value={categoryForm.icon} onChange={e => setCategoryForm({ ...categoryForm, icon: e.target.value })}><option value="">Bisanzwe (nk’icyiciro cya mbere)</option>{categories.filter(c => c.icon_code).map(c => <option key={c.id} value={c.id}>Nk’icya “{c.title}”</option>)}</select></label><div className="category-preview" style={{ '--cat': categoryForm.color, '--cat-soft': categoryForm.soft } as CSSProperties}><span className="category-symbol"><Icon name="categories" /></span><span>{categoryForm.title.trim() || 'Uko icyiciro kizagaragara'}</span></div><button className="primary full" disabled={busy}>Bika icyiciro</button>{categoryForm.id && <button type="button" className="secondary full" onClick={() => setCategoryForm(emptyCategory())}>Reka guhindura</button>}</form><div className="category-grid">{visibleCategories.map(c => <article className="category-card" key={c.id}><button type="button" className="category-open" onClick={() => editCategory(c)}><div className="category-symbol" style={catStyle(c)}><Icon name="categories" /></div><h3>{c.title}</h3><p>{c.subtitle}</p><small>{c.id}</small></button><div className="category-meta"><span className={`pill ${c.published ? 'published' : ''}`}>{c.published ? 'Byatangajwe' : 'Draft'}</span><button onClick={() => void togglePublished('content_categories', c)}>{c.published ? 'Hisha' : 'Tangaza'}</button></div><div className="category-meta"><MoveButtons label={c.title} first={categories[0]?.id === c.id} last={categories[categories.length - 1]?.id === c.id} onMove={direction => moveCategory(c, direction)} /><span className="category-actions"><ActionIcon kind="edit" label="Hindura icyiciro" onClick={() => editCategory(c)} /><ActionIcon kind="delete" label="Siba icyiciro" onClick={() => void removeCategory(c)} /></span></div><small>{questions.filter(q => q.category_id === c.id).length} bibazo - {lessons.filter(l => l.category_id === c.id).length} masomo</small></article>)}</div><Pagination total={filteredCategories.length} page={categoryPage} pageSize={pageSize} onPageChange={setPage} /></div></>}

      {view === 'reports' && (reportsError ? <div className="cm-setup"><Icon name="alert" /><div><strong>Imbonerahamwe ya raporo ntiraboneka muri Supabase.</strong><p>Kora migration <code>supabase/migrations/202611010002_question_reports.sql</code> muri Supabase SQL Editor, hanyuma ukande ↻ hejuru.</p><small>{reportsError}</small></div></div> : <>
        <div className="cm-toolbar">
          <SearchBox value={search} onChange={updateSearch} placeholder="Shakisha #nimero, ikibazo cyangwa igitekerezo..." />
        </div>
        <div className="cm-subbar">
          <div className="cm-tabs" role="group" aria-label="Imimerere ya raporo">{([['new', 'Nshya'], ['resolved', 'Byakemutse'], ['all', 'Zose']] as const).map(([key, label]) => <button key={key} type="button" aria-pressed={reportStatus === key} className={reportStatus === key ? 'active' : ''} onClick={() => { setReportStatus(key); setPage(1); }}>{label}<span>{key === 'all' ? reports.length : reports.filter(r => r.status === key).length}</span></button>)}</div>
          <PageSizeSelect value={pageSize} onChange={updatePageSize} />
        </div>
        <div className="cm-list cm-cards">
          <div className="cm-list-head"><b>{filteredReports.length} raporo</b><span>Zoherejwe n’abakoresha bakanze “Tanga ikosa” muri app.</span></div>
          {visibleReports.map(report => { const question = questionById.get(report.question_id); return <ReportRow key={report.id} report={report} question={question} category={question ? categoryById.get(question.category_id) : undefined} sameQuestion={openReportsByQuestion.get(report.question_id) ?? 0} onOpenQuestion={question ? () => openQuestion(question) : undefined} onResolve={() => void setReportResolved(report, report.status === 'new')} onDelete={() => void removeReport(report)} />; })}
          {filteredReports.length === 0 && <Empty text={reportStatus === 'new' && !search ? 'Nta raporo nshya. Byose bimeze neza!' : 'Nta raporo ihuye n’ishakisha.'} />}
          <Pagination total={filteredReports.length} page={reportPage} pageSize={pageSize} onPageChange={setPage} />
        </div>
      </>)}

      {view === 'notifications' && (announcementsError ? <div className="cm-setup"><Icon name="alert" /><div><strong>Imbonerahamwe y’ubutumwa ntiraboneka muri Supabase.</strong><p>Kora migration <code>supabase/migrations/202610310001_notifications.sql</code> muri Supabase SQL Editor, hanyuma ukande ↻ hejuru.</p><small>{announcementsError}</small></div></div> : <>
        <div className="cm-toolbar">
          <SearchBox value={search} onChange={updateSearch} placeholder="Shakisha ubutumwa..." />
          <button className="primary" onClick={() => openAnnouncement()}>+ Ubutumwa bushya</button>
        </div>
        <div className="cm-subbar">
          <StatusTabs value={statusFilter} onChange={updateStatusFilter} counts={{ all: announcements.length, published: announcements.filter(a => a.published).length, draft: announcements.filter(a => !a.published).length }} />
          <PageSizeSelect value={pageSize} onChange={updatePageSize} />
        </div>
        <div className="cm-list cm-cards">
          <div className="cm-list-head"><b>{filteredAnnouncements.length} butumwa</b><span>Abakoresha babona ubutumwa bwatangajwe kandi butararangira.</span></div>
          {visibleAnnouncements.map(item => <AnnouncementRow key={item.id} item={item} onOpen={() => openAnnouncement(item)} onToggle={() => void togglePublished('notifications', item)} onDelete={() => void removeAnnouncement(item)} />)}
          {filteredAnnouncements.length === 0 && <Empty text={announcements.length ? 'Nta butumwa buhuye n’ishakisha cyangwa filters.' : 'Nta butumwa buhari. Kanda “+ Ubutumwa bushya” wandike ubwa mbere.'} />}
          <Pagination total={filteredAnnouncements.length} page={announcementPage} pageSize={pageSize} onPageChange={setPage} />
        </div>
      </>)}

      {view === 'users' && <><div className="users-intro"><div className="users-intro-icon"><Icon name="users" /></div><div><h2>Konti z’abakoresha</h2><p>Genzura abakoresha biyandikishije, reba uko bakoresha app, uhagarike cyangwa wongere ufungure konti, kandi usibe konti iyo umukoresha abisabye.</p></div><div className="users-total"><strong>{learnerTotal}</strong><span>konti zose</span></div></div><div className="users-toolbar"><label className="user-search"><span>⌕</span><input type="search" placeholder="Shakisha email, telefone cyangwa ID..." value={learnerSearch} onChange={event => { setLearnerSearch(event.target.value); setLearnerPage(1); }} /><button type="button" disabled={!learnerSearch} onClick={() => { setLearnerSearch(''); setLearnerPage(1); }}>×</button></label><select value={learnerStatus} aria-label="Akayunguruzo ka konti" onChange={event => { setLearnerStatus(event.target.value as typeof learnerStatus); setLearnerPage(1); }}><option value="all">Konti zose</option><option value="active">Zikora</option><option value="suspended">Zahagaritswe</option></select><label className="page-size">Rows<select value={learnerPageSize} aria-label="Umubare w’abakoresha kuri page" onChange={event => { setLearnerPageSize(Number(event.target.value)); setLearnerPage(1); }}><option value={5}>5</option><option value={10}>10</option><option value={20}>20</option><option value={50}>50</option></select></label></div><div className="users-card"><div className="users-table-head"><div><strong>Abakoresha</strong><span>{busy ? 'Biravugururwa...' : `${learnerTotal} konti ziboneka`}</span></div><button className="secondary" onClick={() => void loadLearners()} disabled={busy}>↻ Ongera uvugurure</button></div>{learners.length ? <div className="users-table-wrap"><table className="users-table"><thead><tr><th>UMUKORESHA</th><th>YIYANDIKISHIJE</th><th>GUKORESHA APP</th><th>IMIMERERE</th><th>IBIKORWA</th></tr></thead><tbody>{learners.map(learner => { const suspended = Boolean(learner.bannedUntil && new Date(learner.bannedUntil) > new Date()); return <tr key={learner.id}><td><div className="user-cell"><span className="user-avatar">{(learner.email ?? learner.phone ?? 'U').slice(0,1).toUpperCase()}</span><span><strong>{learner.email ?? learner.phone ?? 'Konti idafite email/telefone'}</strong><small>{learner.phone && learner.email ? learner.phone : `ID: ${learner.id.slice(0,8)}…`}</small>{learner.isAdmin && <em>Admin</em>}</span></div></td><td>{formatDate(learner.createdAt)}</td><td><strong>{learner.completedLessons}</strong> amasomo{learner.progressUpdatedAt && <small className="table-subline">Yaherukaga: {formatDate(learner.progressUpdatedAt)}</small>}</td><td><span className={`user-status ${suspended ? 'suspended' : 'active'}`}><i />{suspended ? 'Yarahagaritswe' : 'Irakora'}</span></td><td>{learner.isAdmin ? <span className="protected-label">Admin irinzwe</span> : <span className="user-actions"><button className={`user-action ${suspended ? 'restore' : ''}`} disabled={busy} onClick={() => void changeLearnerStatus(learner)}>{suspended ? 'Ongera ufungure' : 'Hagarika konti'}</button><button className="user-action delete" disabled={busy} onClick={() => void deleteLearner(learner)}>Siba konti</button></span>}</td></tr>; })}</tbody></table></div> : <Empty text={learnersReady ? 'Nta konti zihuye n’ishakisha n’akayunguruzo.' : 'Shaka amakuru y’abakoresha...'} />}<Pagination total={learnerTotal} page={learnerPage} pageSize={learnerPageSize} onPageChange={setLearnerPage} /></div><p className="users-footnote">Abakoresha ni amakuru ava muri Supabase Auth. Ibyo bakora bibikwa kuri konti yabo; dashboard yerekana amasomo yarangiye gusa. Konti za admin ntizihagarikwa kandi ntizisibwa hano.</p></>}
      {drawer === 'question' && <Drawer eyebrow="UMWANDITSI W’IBIBAZO" title={questionForm.id ? `Hindura ikibazo${editingNumber != null ? ` #${editingNumber}` : ''}` : 'Ikibazo gishya'} onClose={closeDrawer} onSubmit={saveQuestion} footer={<><button type="button" className="secondary" onClick={closeDrawer}>Reka</button><button className="primary" disabled={busy}>{busy ? 'Birabikwa...' : 'Bika ikibazo'}</button></>}>
        {editingReports.length > 0 && <div className="cm-report-panel"><strong><Icon name="flag" />Raporo {editingReports.length} zitarakemuka kuri iki kibazo</strong>{editingReports.map(report => <div key={report.id} className="cm-report-item"><span><b>{reportReasons[report.reason] ?? report.reason}</b>{report.comment && <> — “{report.comment}”</>}</span><button type="button" className="text-button" onClick={() => void setReportResolved(report, true)}>Byakemutse</button></div>)}</div>}
        <label className="cm-field">Ikibazo<textarea autoFocus required rows={3} value={questionForm.prompt} onChange={e => setQuestionForm({ ...questionForm, prompt: e.target.value })} /></label>
        <label className="cm-field">Icyiciro<select required value={questionForm.category_id} onChange={e => setQuestionForm({ ...questionForm, category_id: e.target.value })}><option value="">Hitamo icyiciro</option>{categories.map(c => <option key={c.id} value={c.id}>{c.title}</option>)}</select></label>
        <fieldset className="cm-options"><legend>Ibisubizo<span className="cm-hint">Kanda inyuguti y’igisubizo nyacyo · ibisubizo 2 kugeza kuri 4</span></legend>
          {questionForm.options.map((option, i) => {
            const letter = String.fromCharCode(65 + i);
            const correct = questionForm.correct === i;
            return <div className={`cm-option ${correct ? 'correct' : ''}`} key={i}>
              <label className="cm-option-pick" title="Hitamo nk’igisubizo nyacyo"><input type="radio" name="correct" checked={correct} onChange={() => setQuestionForm({ ...questionForm, correct: i })} /><span aria-hidden="true">{letter}</span><span className="sr-only">Igisubizo {letter} ni cyo nyacyo</span></label>
              <input aria-label={`Igisubizo ${letter}`} required value={option} onChange={e => { const options = [...questionForm.options]; options[i] = e.target.value; setQuestionForm({ ...questionForm, options }); }} />
              {correct ? <span className="cm-correct-tag"><Icon name="check" />Nyacyo</span> : questionForm.options.length > 2 && <button type="button" className="cm-option-remove" aria-label={`Kuraho igisubizo ${letter}`} title="Kuraho iki gisubizo" onClick={() => removeOption(i)}>×</button>}
            </div>;
          })}
          {questionForm.options.length < 4 && <button type="button" className="cm-option-add" onClick={addOption}>+ Ongeramo igisubizo</button>}
        </fieldset>
        <label className="cm-field">Ibisobanuro by’igisubizo<textarea rows={3} placeholder="Sobanura impamvu iki gisubizo ari cyo nyacyo..." value={questionForm.explanation} onChange={e => setQuestionForm({ ...questionForm, explanation: e.target.value })} />{!questionForm.explanation.trim() && <span className="cm-warn-text">Nta bisobanuro: abiga bazabona igisubizo gusa, batamenye impamvu.</span>}</label>
        <div className="cm-two"><label className="cm-field">Ubwoko bw’icyapa<input placeholder="urugero: danger" value={questionForm.sign_type} onChange={e => setQuestionForm({ ...questionForm, sign_type: e.target.value })} /></label><label className="cm-field">Agaciro/inyandiko<input placeholder="urugero: 10%" value={questionForm.sign_label} onChange={e => setQuestionForm({ ...questionForm, sign_label: e.target.value })} /></label></div>
        <ImageField label="Ifoto y’icyapa" src={imageUrl(questionForm.image_path)} onPick={async e => { try { const path = await uploadImage(e); if (path) setQuestionForm(f => ({ ...f, image_path: path })); } catch (error) { sayError(error); } }} onRemove={() => setQuestionForm({ ...questionForm, image_path: '' })} />
        <AudioField ready={audioReady} label="Amajwi asoma ikibazo (si ngombwa)" src={audioUrl(questionForm.audio_path)} onPick={async e => { try { const path = await uploadAudio(e); if (path) setQuestionForm(f => ({ ...f, audio_path: path })); } catch (error) { sayError(error); } }} onRemove={() => setQuestionForm({ ...questionForm, audio_path: '' })} />
        <div className="cm-checks"><label className="cm-check"><input type="checkbox" checked={questionForm.is_exam_question} onChange={e => setQuestionForm({ ...questionForm, is_exam_question: e.target.checked })} /> Gishobora kujya mu kizamini cy’igerageza</label><label className="cm-check"><input type="checkbox" checked={questionForm.published} onChange={e => setQuestionForm({ ...questionForm, published: e.target.checked })} /> Tangaza: abakoresha ba app bakibone</label></div>
      </Drawer>}

      {drawer === 'announcement' && <Drawer eyebrow="UBUTUMWA KU BAKORESHA" title={announcementForm.id ? 'Hindura ubutumwa' : 'Ubutumwa bushya'} onClose={closeDrawer} onSubmit={saveAnnouncement} footer={<><button type="button" className="secondary" onClick={closeDrawer}>Reka</button><button className="primary" disabled={busy}>{busy ? 'Birabikwa...' : 'Bika ubutumwa'}</button></>}>
        <label className="cm-field">Umutwe<input autoFocus required maxLength={120} placeholder="urugero: Ibibazo bishya byongewemo" value={announcementForm.title} onChange={e => setAnnouncementForm({ ...announcementForm, title: e.target.value })} /><span className="cm-hint">{announcementForm.title.length}/120</span></label>
        <label className="cm-field">Ubutumwa<textarea required rows={4} maxLength={1000} placeholder="Andika ubutumwa abakoresha bazasoma muri app..." value={announcementForm.body} onChange={e => setAnnouncementForm({ ...announcementForm, body: e.target.value })} /><span className="cm-hint">{announcementForm.body.length}/1000</span></label>
        <fieldset className="cm-icon-picker"><legend>Ubwoko</legend>{announcementIcons.map(choice => <label key={choice.key} className={`cm-icon-choice ${announcementForm.icon === choice.key ? 'active' : ''}`}><input type="radio" name="announcement-icon" value={choice.key} checked={announcementForm.icon === choice.key} onChange={() => setAnnouncementForm({ ...announcementForm, icon: choice.key })} /><Icon name={choice.icon} /><span>{choice.label}</span></label>)}</fieldset>
        <label className="cm-field">Itariki birangiriraho (si ngombwa)<input type="date" value={announcementForm.expires_at} onChange={e => setAnnouncementForm({ ...announcementForm, expires_at: e.target.value })} /><span className="cm-hint">Nyuma y’iyi tariki, ubutumwa ntibuzongera kugaragara muri app.</span>{announcementForm.expires_at && announcementForm.expires_at < toDateInput(new Date().toISOString()) && <span className="cm-warn-text">Iyi tariki yararenze: ubu butumwa ntibuzagaragara.</span>}</label>
        <div className="cm-field"><span>Uko buzagaragara muri app</span><div className="cm-phone-preview"><span className="cm-preview-icon"><Icon name={announcementIcons.find(choice => choice.key === announcementForm.icon)?.icon ?? 'info'} /></span><div><strong>{announcementForm.title.trim() || 'Umutwe w’ubutumwa'}</strong><p>{announcementForm.body.trim() || 'Ubutumwa buzagaragara hano.'}</p><small>Uyu munsi</small></div></div></div>
        <div className="cm-checks"><label className="cm-check"><input type="checkbox" checked={announcementForm.published} onChange={e => setAnnouncementForm({ ...announcementForm, published: e.target.checked })} /> Tangaza: abakoresha ba app babubone</label></div>
      </Drawer>}

      {drawer === 'lesson' && <Drawer wide eyebrow="UMWANDITSI W’AMASOMO" title={lessonForm.id ? 'Hindura isomo' : 'Isomo rishya'} onClose={closeDrawer} onSubmit={saveLesson} footer={<><button type="button" className="secondary" onClick={closeDrawer}>Reka</button><button className="primary" disabled={busy}>{busy ? 'Birabikwa...' : 'Bika isomo'}</button></>}>
        <label className="cm-field">Umutwe w’isomo<input autoFocus required value={lessonForm.title} onChange={e => setLessonForm({ ...lessonForm, title: e.target.value })} /></label>
        <div className="cm-two"><label className="cm-field">Icyiciro<select required value={lessonForm.category_id} onChange={e => setLessonForm({ ...lessonForm, category_id: e.target.value })}><option value="">Hitamo icyiciro</option>{categories.map(c => <option key={c.id} value={c.id}>{c.title}</option>)}</select></label><label className="cm-field">Igihe (iminota)<input type="number" min={1} required value={lessonForm.minutes} onChange={e => setLessonForm({ ...lessonForm, minutes: Number(e.target.value) })} /></label></div>
        <AudioField ready={audioReady} label="Amajwi y’isomo (si ngombwa)" src={audioUrl(lessonForm.audio_path)} onPick={async e => { try { const path = await uploadAudio(e); if (path) setLessonForm(f => ({ ...f, audio_path: path })); } catch (error) { sayError(error); } }} onRemove={() => setLessonForm({ ...lessonForm, audio_path: '' })} />
        <div className="cm-sections-head"><strong>Ibice by’isomo<span>{lessonForm.sections.length}</span></strong>{lessonForm.sections.length > 1 && <span className="cm-groups-actions"><button type="button" className="text-button" onClick={() => setOpenSections(lessonForm.sections.map((_, i) => i))}>Fungura byose</button><button type="button" className="text-button" onClick={() => setOpenSections([])}>Funga byose</button></span>}</div>
        {lessonForm.sections.map((section, i) => {
          const open = openSections.includes(i);
          return <div className={`cm-section ${open ? 'open' : ''}`} key={i}>
            <div className="cm-section-bar"><button type="button" className="cm-section-head" aria-expanded={open} onClick={() => toggleSection(i)}><span className="cm-section-num">{i + 1}</span><span className="cm-section-title">{section.heading.trim() || 'Igice kitarandikwa'}</span>{section.image_path && <span className="cm-chip">Ifoto</span>}{section.sign_type && <span className="cm-chip">{section.sign_type}</span>}<Icon name="chevron" className={open ? 'cm-icon cm-chevron open' : 'cm-icon cm-chevron'} /></button><MoveButtons label={`Igice ${i + 1}`} first={i === 0} last={i === lessonForm.sections.length - 1} onMove={direction => moveSection(i, direction)} /></div>
            {open && <div className="cm-section-body">
              <label className="cm-field">Umutwe<input required value={section.heading} onChange={e => patchSection(i, { heading: e.target.value })} /></label>
              <label className="cm-field">Ibisobanuro<textarea required rows={4} value={section.body} onChange={e => patchSection(i, { body: e.target.value })} /></label>
              <div className="cm-two"><label className="cm-field">Ubwoko bw’icyapa<input placeholder="urugero: stop" value={section.sign_type ?? ''} onChange={e => patchSection(i, { sign_type: e.target.value })} /></label><label className="cm-field">Agaciro/inyandiko<input value={section.sign_label ?? ''} onChange={e => patchSection(i, { sign_label: e.target.value })} /></label></div>
              <ImageField label="Ifoto y’icyapa" src={imageUrl(section.image_path)} onPick={async e => { try { const path = await uploadImage(e); if (path) patchSection(i, { image_path: path }); } catch (error) { sayError(error); } }} onRemove={() => patchSection(i, { image_path: '' })} />
              {lessonForm.sections.length > 1 && <button type="button" className="cm-remove" onClick={() => removeSection(i)}>Kuraho iki gice</button>}
            </div>}
          </div>;
        })}
        <button type="button" className="secondary full" onClick={addSection}>+ Ongeramo igice</button>
        <div className="cm-checks"><label className="cm-check"><input type="checkbox" checked={lessonForm.is_extra} onChange={e => setLessonForm({ ...lessonForm, is_extra: e.target.checked })} /> Isomo ry’inyongera (ntirijya mu kizamini)</label><label className="cm-check"><input type="checkbox" checked={lessonForm.published} onChange={e => setLessonForm({ ...lessonForm, published: e.target.checked })} /> Tangaza: abakoresha ba app baribone</label></div>
      </Drawer>}
    </section>
  </main>;
}

function ActionIcon({ kind, label, onClick }: { kind: "edit" | "delete"; label: string; onClick: () => void }) { return <button type="button" className={`icon-action ${kind === "delete" ? "danger" : ""}`} title={label} aria-label={label} onClick={onClick}><svg viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">{kind === "edit" ? <><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4Z"/></> : <><path d="M3 6h18"/><path d="M8 6V4h8v2"/><path d="m19 6-1 14H6L5 6"/><path d="M10 11v5M14 11v5"/></>}</svg></button>; }
function ListControls({ search, onSearchChange, status, onStatusChange, pageSize, onPageSizeChange, categories, category, onCategoryChange, placeholder, showCategory = true }: { search: string; onSearchChange: (value: string) => void; status: 'all' | 'published' | 'draft'; onStatusChange: (value: 'all' | 'published' | 'draft') => void; pageSize: number; onPageSizeChange: (value: number) => void; categories: Category[]; category?: string; onCategoryChange?: (value: string) => void; placeholder: string; showCategory?: boolean }) {
  return <div className="filter-controls flex flex-1 flex-wrap items-center gap-2"><div className="search-wrap"><input className="search" type="search" placeholder={placeholder} value={search} onChange={event => onSearchChange(event.target.value)} /><button type="button" aria-label="Siba amagambo yo gushakisha" title="Siba ishakisha" disabled={!search} onClick={() => onSearchChange('')}>×</button></div><select aria-label="Filter by publish status" value={status} onChange={event => onStatusChange(event.target.value as 'all' | 'published' | 'draft')}><option value="all">Byose</option><option value="published">Byatangajwe</option><option value="draft">Draft</option></select>{showCategory && category !== undefined && onCategoryChange && <select aria-label="Filter by category" value={category} onChange={event => onCategoryChange(event.target.value)}><option value="all">Ibyiciro byose</option>{categories.map(item => <option key={item.id} value={item.id}>{item.title}</option>)}</select>}<label className="page-size">Rows<select aria-label="Rows per page" value={pageSize} onChange={event => onPageSizeChange(Number(event.target.value))}><option value={5}>5</option><option value={10}>10</option><option value={20}>20</option><option value={50}>50</option></select></label></div>;
}
function Pagination({ total, page, pageSize, onPageChange }: { total: number; page: number; pageSize: number; onPageChange: (page: number) => void }) {
  const pageCount = Math.max(1, Math.ceil(total / pageSize));
  const start = total ? (page - 1) * pageSize + 1 : 0;
  const end = Math.min(page * pageSize, total);
  return <div className="pagination"><span className="pagination-count">{start}–{end} kuri {total}</span><div className="pagination-buttons"><button type="button" disabled={page <= 1} onClick={() => onPageChange(page - 1)}>Mbere</button><span>{page} / {pageCount}</span><button type="button" disabled={page >= pageCount} onClick={() => onPageChange(page + 1)}>Ibikurikira</button></div></div>;
}
function Brand() { return <div className="brand"><span className="brand-mark">A</span><span><b>AMATEGEKO</b><small>ADMIN CONSOLE</small></span></div>; }
function Stat({ label, value, detail, icon, onClick }: { label: string; value: number | string; detail: string; icon: IconName; onClick: () => void }) { return <button type="button" className="stat-card" onClick={onClick}><span className="stat-icon"><Icon name={icon} /></span><span className="stat-label">{label}</span><strong>{value}</strong><small>{detail}</small></button>; }
function ManageCard({ icon, title, detail, onClick }: { icon: IconName; title: string; detail: string; onClick: () => void }) { return <button className="manage-card" onClick={onClick}><span className="manage-icon"><Icon name={icon} /></span><span className="manage-copy"><strong>{title}</strong><small>{detail}</small></span><span className="manage-arrow">→</span></button>; }
function ReviewRow({ label, count, onClick }: { label: string; count: number; onClick: () => void }) { return <button className="review-row" onClick={onClick}><span>{label}</span><strong className={count ? 'needs-review' : 'all-clear'}>{count}</strong><span className="review-arrow">→</span></button>; }
function Empty({ text }: { text: string }) { return <div className="empty"><span>+</span><p>{text}</p></div>; }
function formatDate(value: string) { return new Date(value).toLocaleDateString('rw-RW', { day: 'numeric', month: 'short', year: 'numeric' }); }
function isOnLocalDay(value: string, daysAgo: number) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return false;
  const start = new Date();
  start.setHours(0, 0, 0, 0);
  start.setDate(start.getDate() - daysAgo);
  const end = new Date(start);
  end.setDate(end.getDate() + 1);
  return date >= start && date < end;
}

type IconName = View | 'search' | 'chevron' | 'check' | 'alert' | 'image' | 'up' | 'down' | 'info' | 'sparkle' | 'bulb' | 'clock' | 'clipboard' | 'trash' | 'flag' | 'volume';
const iconPaths: Record<IconName, ReactNode> = {
  overview: <><rect x="3" y="3" width="7" height="9" rx="1.5" /><rect x="14" y="3" width="7" height="5" rx="1.5" /><rect x="14" y="12" width="7" height="9" rx="1.5" /><rect x="3" y="16" width="7" height="5" rx="1.5" /></>,
  questions: <><circle cx="12" cy="12" r="9" /><path d="M9.1 9a3 3 0 0 1 5.8 1c0 2-3 2.5-3 4.5" /><path d="M12 17.5h.01" /></>,
  lessons: <><path d="M2 4h6a4 4 0 0 1 4 4v13a3 3 0 0 0-3-3H2z" /><path d="M22 4h-6a4 4 0 0 0-4 4v13a3 3 0 0 1 3-3h7z" /></>,
  categories: <path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />,
  users: <><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" /><circle cx="9" cy="7" r="4" /><path d="M22 21v-2a4 4 0 0 0-3-3.87" /><path d="M16 3.13a4 4 0 0 1 0 7.75" /></>,
  search: <><circle cx="11" cy="11" r="7" /><path d="m20 20-3.5-3.5" /></>,
  chevron: <path d="m6 9 6 6 6-6" />,
  check: <path d="M20 6 9 17l-5-5" />,
  alert: <><path d="M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z" /><path d="M12 9v4" /><path d="M12 17h.01" /></>,
  image: <><rect x="3" y="3" width="18" height="18" rx="2" /><circle cx="9" cy="9" r="2" /><path d="m21 15-3.1-3.1a2 2 0 0 0-2.8 0L6 21" /></>,
  up: <><path d="M12 19V5" /><path d="m5 12 7-7 7 7" /></>,
  down: <><path d="M12 5v14" /><path d="m19 12-7 7-7-7" /></>,
  notifications: <><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9" /><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0" /></>,
  info: <><circle cx="12" cy="12" r="9" /><path d="M12 16v-4" /><path d="M12 8h.01" /></>,
  sparkle: <path d="m12 3 1.9 5.1L19 10l-5.1 1.9L12 17l-1.9-5.1L5 10l5.1-1.9z" />,
  bulb: <><path d="M9 18h6" /><path d="M10 22h4" /><path d="M12 2a7 7 0 0 0-4 12.7c.6.5 1 1.3 1 2.1V18h6v-1.2c0-.8.4-1.6 1-2.1A7 7 0 0 0 12 2z" /></>,
  clock: <><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 3" /></>,
  clipboard: <><rect x="8" y="2" width="8" height="4" rx="1" /><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2" /></>,
  flag: <><path d="M4 22V4" /><path d="M4 4h12l-2 4 2 4H4" /></>,
  volume: <><path d="M11 5 6 9H2v6h4l5 4z" /><path d="M15.5 8.5a5 5 0 0 1 0 7" /><path d="M19 5a10 10 0 0 1 0 14" /></>,
  reports: <><path d="M4 22V4" /><path d="M4 4h12l-2 4 2 4H4" /></>,
  trash: <><path d="M3 6h18" /><path d="M8 6V4h8v2" /><path d="m19 6-1 14H6L5 6" /><path d="M10 11v5M14 11v5" /></>,
};
function ConfirmDialog({ title, message, confirmLabel, tone = 'danger', requireText, onAnswer }: ConfirmOptions & { onAnswer: (ok: boolean) => void }) {
  const [typed, setTyped] = useState('');
  const ready = !requireText || typed.trim().toUpperCase() === requireText;
  useEffect(() => {
    const onKey = (event: KeyboardEvent) => { if (event.key === 'Escape') onAnswer(false); };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [onAnswer]);
  return <div className="cm-dialog-root"><div className="cm-backdrop" onClick={() => onAnswer(false)} />
    <form className={`cm-dialog ${tone}`} role="alertdialog" aria-modal="true" aria-labelledby="cm-dialog-title" aria-describedby="cm-dialog-message" onSubmit={event => { event.preventDefault(); if (ready) onAnswer(true); }}>
      <span className="cm-dialog-icon"><Icon name={tone === 'danger' ? 'trash' : tone === 'warning' ? 'alert' : 'info'} /></span>
      <h2 id="cm-dialog-title">{title}</h2>
      <div id="cm-dialog-message" className="cm-dialog-message">{message}</div>
      {requireText && <label className="cm-field">Andika {requireText} kugira ngo wemeze<input autoFocus autoComplete="off" value={typed} onChange={event => setTyped(event.target.value)} /></label>}
      {/* Cancel gets focus so pressing Enter by habit never deletes anything. */}
      <div className="cm-dialog-actions"><button type="button" className="secondary" autoFocus={!requireText} onClick={() => onAnswer(false)}>Reka</button><button type="submit" className={`cm-dialog-confirm ${tone}`} disabled={!ready}>{confirmLabel}</button></div>
    </form>
  </div>;
}
// Dashboard-wide search: up to 5 matches per kind, plus "see all" links that open the page with the search filled in.
function GlobalSearch({ questions, lessons, categories, announcements, reports, questionById, onPick, onClose }: { questions: Question[]; lessons: Lesson[]; categories: Category[]; announcements: Announcement[]; reports: QuestionReport[]; questionById: Map<string, Question>; onPick: (target: SearchTarget) => void; onClose: () => void }) {
  const [query, setQuery] = useState('');
  useEffect(() => {
    const onKey = (event: KeyboardEvent) => { if (event.key === 'Escape') onClose(); };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [onClose]);
  const q = query.trim().toLocaleLowerCase();
  const wantedNumber = /^#\d+$/.test(q) ? Number(q.slice(1)) : null;
  const has = (text: string) => text.toLocaleLowerCase().includes(q);
  const groups = useMemo(() => {
    if (!q) return [];
    const matchQuestions = wantedNumber !== null ? questions.filter(x => x.number === wantedNumber) : questions.filter(x => has(`#${x.number ?? ''} ${x.prompt} ${x.explanation} ${x.question_options?.map(o => o.option_text).join(' ') ?? ''}`));
    const matchLessons = wantedNumber !== null ? [] : lessons.filter(x => has(`${x.title} ${x.lesson_sections?.map(s => `${s.heading} ${s.body}`).join(' ') ?? ''}`));
    const matchCategories = wantedNumber !== null ? [] : categories.filter(x => has(`${x.title} ${x.subtitle} ${x.id}`));
    const matchAnnouncements = wantedNumber !== null ? [] : announcements.filter(x => has(`${x.title} ${x.body}`));
    const matchReports = reports.filter(x => { const question = questionById.get(x.question_id); return wantedNumber !== null ? question?.number === wantedNumber : has(`${x.comment ?? ''} ${reportReasons[x.reason] ?? ''} ${question?.prompt ?? ''}`); });
    return [
      { title: 'Ibibazo', view: 'questions' as View, total: matchQuestions.length, items: matchQuestions.slice(0, 5).map(x => ({ key: `q-${x.id}`, label: `${x.number != null ? `#${x.number} · ` : ''}${x.prompt}`, detail: x.question_options?.find(o => o.is_correct)?.option_text ?? '', target: { kind: 'question', item: x } as SearchTarget })) },
      { title: 'Amasomo', view: 'lessons' as View, total: matchLessons.length, items: matchLessons.slice(0, 5).map(x => ({ key: `l-${x.id}`, label: x.title, detail: `${x.lesson_sections?.length ?? 0} bice · ${x.minutes} min`, target: { kind: 'lesson', item: x } as SearchTarget })) },
      { title: 'Ibyiciro', view: 'categories' as View, total: matchCategories.length, items: matchCategories.slice(0, 5).map(x => ({ key: `c-${x.id}`, label: x.title, detail: x.subtitle, target: { kind: 'category', item: x } as SearchTarget })) },
      { title: 'Ubutumwa', view: 'notifications' as View, total: matchAnnouncements.length, items: matchAnnouncements.slice(0, 5).map(x => ({ key: `n-${x.id}`, label: x.title, detail: x.body, target: { kind: 'announcement', item: x } as SearchTarget })) },
      { title: 'Raporo', view: 'reports' as View, total: matchReports.length, items: matchReports.slice(0, 5).map(x => { const question = questionById.get(x.question_id); return { key: `r-${x.id}`, label: `${question?.number != null ? `#${question.number} · ` : ''}${reportReasons[x.reason] ?? x.reason}`, detail: x.comment ?? question?.prompt ?? '', target: { kind: 'report', search: question?.number != null ? `#${question.number}` : q } as SearchTarget }; }) },
    ].filter(group => group.total > 0);
  }, [q, wantedNumber, questions, lessons, categories, announcements, reports, questionById]);
  const first = groups[0]?.items[0]?.target;
  return <div className="cm-dialog-root cm-palette-root"><div className="cm-backdrop" onClick={onClose} />
    <div className="cm-palette" role="dialog" aria-modal="true" aria-label="Shakisha muri dashboard yose">
      <label className="cm-palette-input"><Icon name="search" /><span className="sr-only">Shakisha</span><input autoFocus type="search" placeholder="Shakisha ibibazo, #nimero, amasomo, ibyiciro, ubutumwa..." value={query} onChange={event => setQuery(event.target.value)} onKeyDown={event => { if (event.key === 'Enter' && first) onPick(first); }} /><kbd>Esc</kbd></label>
      <div className="cm-palette-results">
        {!q && <p className="cm-palette-hint">Andika ijambo, cyangwa <b>#57</b> ushake ikibazo cyihariye. Enter ifungura igisubizo cya mbere.</p>}
        {q && groups.length === 0 && <p className="cm-palette-hint">Nta kintu kibonetse kuri “{query.trim()}”.</p>}
        {groups.map(group => <section key={group.title}>
          <h3>{group.title}<span>{group.total}</span></h3>
          {group.items.map(item => <button key={item.key} type="button" className="cm-palette-item" onClick={() => onPick(item.target)}><strong>{item.label}</strong>{item.detail && <small>{item.detail}</small>}</button>)}
          {group.total > group.items.length && <button type="button" className="cm-palette-more" onClick={() => onPick({ kind: 'view', view: group.view, search: query.trim() })}>Reba byose ({group.total}) →</button>}
        </section>)}
        {q && <button type="button" className="cm-palette-more" onClick={() => onPick({ kind: 'users', search: query.trim() })}>Shakisha “{query.trim()}” mu bakoresha →</button>}
      </div>
    </div>
  </div>;
}
function Toast({ notice, onClose }: { notice: Notice; onClose: () => void }) {
  return <div className={`cm-toast ${notice.kind}`} role={notice.kind === 'error' ? 'alert' : 'status'}><span className="cm-toast-icon"><Icon name={notice.kind === 'error' ? 'alert' : 'check'} /></span><p>{notice.text}</p><button type="button" aria-label="Funga ubutumwa" onClick={onClose}>×</button></div>;
}
function AnnouncementRow({ item, onOpen, onToggle, onDelete }: { item: Announcement; onOpen: () => void; onToggle: () => void; onDelete: () => void }) {
  const kind = announcementIcons.find(choice => choice.key === item.icon) ?? announcementIcons[0];
  const expired = Boolean(item.expires_at && new Date(item.expires_at) < new Date());
  return <article className="cm-row cm-qrow">
    <span className="cm-thumb"><Icon name={kind.icon} /></span>
    <button type="button" className="cm-row-main" onClick={onOpen}>
      <strong>{item.title}</strong>
      <span className="cm-body">{item.body}</span>
      <span className="cm-meta"><span className="cm-chip">{kind.label}</span><span>{item.published_at ? `Byatangajwe ${formatDate(item.published_at)}` : `Byanditswe ${formatDate(item.created_at)}`}</span>{item.expires_at && <span className={`cm-chip ${expired ? 'warn' : ''}`}>{expired ? 'Byarangiye' : `Birangira ${formatDate(item.expires_at)}`}</span>}</span>
    </button>
    <StatusSwitch published={item.published} label={item.title} onToggle={onToggle} />
    <div className="cm-row-actions"><ActionIcon kind="edit" label="Hindura ubutumwa" onClick={onOpen} /><ActionIcon kind="delete" label="Siba ubutumwa" onClick={onDelete} /></div>
  </article>;
}
function toDateInput(iso: string) { const d = new Date(iso); return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`; }
function MoveButtons({ label, first, last, onMove }: { label: string; first: boolean; last: boolean; onMove: (direction: -1 | 1) => void }) {
  return <span className="cm-move"><button type="button" aria-label={`Zamura: ${label}`} title="Zamura" disabled={first} onClick={() => onMove(-1)}><Icon name="up" /></button><button type="button" aria-label={`Manura: ${label}`} title="Manura" disabled={last} onClick={() => onMove(1)}><Icon name="down" /></button></span>;
}
function byOrder(a: { id: string; sort_order: number }, b: { id: string; sort_order: number }) { return a.sort_order - b.sort_order || a.id.localeCompare(b.id); }
function hexToArgb(hex: string) { const rgb = parseInt(hex.replace('#', '').slice(0, 6), 16); return 0xff000000 + (Number.isFinite(rgb) ? rgb : 0); }
function Icon({ name, className = 'cm-icon' }: { name: IconName; className?: string }) { return <svg className={className} viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">{iconPaths[name]}</svg>; }
function argbToHex(value: number | null | undefined, fallback: string) { const n = Number(value); return Number.isFinite(n) && n ? `#${(n & 0xffffff).toString(16).padStart(6, '0')}` : fallback; }
function catStyle(category?: Category | null): CSSProperties | undefined { return category ? { '--cat': argbToHex(category.color_value, '#2563eb'), '--cat-soft': argbToHex(category.soft_color_value, '#eaf1ff') } as CSSProperties : undefined; }
function SearchBox({ value, onChange, placeholder }: { value: string; onChange: (value: string) => void; placeholder: string }) {
  return <label className="cm-search"><Icon name="search" /><span className="sr-only">Shakisha</span><input type="search" placeholder={placeholder} value={value} onChange={event => onChange(event.target.value)} />{value && <button type="button" aria-label="Siba ishakisha" onClick={() => onChange('')}>×</button>}</label>;
}
function StatusTabs({ value, onChange, counts }: { value: 'all' | 'published' | 'draft'; onChange: (value: 'all' | 'published' | 'draft') => void; counts: Record<'all' | 'published' | 'draft', number> }) {
  const tabs = [['all', 'Byose'], ['published', 'Byatangajwe'], ['draft', 'Draft']] as const;
  return <div className="cm-tabs" role="group" aria-label="Imimerere">{tabs.map(([key, label]) => <button key={key} type="button" aria-pressed={value === key} className={value === key ? 'active' : ''} onClick={() => onChange(key)}>{label}<span>{counts[key]}</span></button>)}</div>;
}
function PageSizeSelect({ value, onChange }: { value: number; onChange: (value: number) => void }) {
  return <label className="cm-rows-select cm-push">Kuri page<select value={value} onChange={event => onChange(Number(event.target.value))}><option value={5}>5</option><option value={10}>10</option><option value={20}>20</option><option value={50}>50</option></select></label>;
}
// One click publishes or hides; the visible label always states the current status.
function StatusSwitch({ published, label, onToggle }: { published: boolean; label: string; onToggle: () => void }) {
  return <button type="button" role="switch" aria-checked={published} className={`cm-switch ${published ? 'on' : ''}`} title={published ? 'Kanda uhishe' : 'Kanda utangaze'} onClick={onToggle}><span className="cm-switch-track"><span className="cm-switch-thumb" /></span><span className="sr-only">{label}: </span><span className="cm-switch-label">{published ? 'Byatangajwe' : 'Draft'}</span></button>;
}
function ReportRow({ report, question, category, sameQuestion, onOpenQuestion, onResolve, onDelete }: { report: QuestionReport; question?: Question; category?: Category; sameQuestion: number; onOpenQuestion?: () => void; onResolve: () => void; onDelete: () => void }) {
  const resolved = report.status === 'resolved';
  return <article className="cm-row cm-qrow" style={catStyle(category)}>
    <span className={`cm-thumb cm-report-icon ${resolved ? 'resolved' : ''}`}><Icon name={resolved ? 'check' : 'flag'} /></span>
    <div className="cm-report-main">
      <strong>{question?.number != null ? `#${question.number} · ` : ''}{reportReasons[report.reason] ?? report.reason}</strong>
      <span className="cm-body">{question ? question.prompt : 'Ikibazo ntikikiriho.'}</span>
      {report.comment && <span className="cm-report-comment">“{report.comment}”</span>}
      <span className="cm-meta"><span>{formatDate(report.created_at)}</span><span>{report.reporter_id ? 'Umukoresha winjiye' : 'Mushyitsi'}</span>{!resolved && sameQuestion > 1 && <span className="cm-chip danger">Raporo {sameQuestion} kuri iki kibazo</span>}{resolved && report.resolved_at && <span className="cm-chip">Byakemutse {formatDate(report.resolved_at)}</span>}</span>
    </div>
    <div className="cm-report-actions">
      {onOpenQuestion && <button type="button" className="secondary" onClick={onOpenQuestion}>Fungura ikibazo</button>}
      <button type="button" className={resolved ? 'secondary' : 'primary'} onClick={onResolve}>{resolved ? 'Ongera ufungure' : 'Byakemutse'}</button>
      <ActionIcon kind="delete" label="Siba raporo" onClick={onDelete} />
    </div>
  </article>;
}
function QuestionRow({ question, category, image, openReports = 0, onOpen, onToggle, onDelete }: { question: Question; category?: Category; image: string | null; openReports?: number; onOpen: () => void; onToggle: () => void; onDelete: () => void }) {
  const answer = question.question_options?.find(option => option.is_correct)?.option_text;
  return <article className="cm-row cm-qrow" style={catStyle(category)}>
    <span className="cm-thumb">{image ? <img src={image} alt="" /> : <Icon name="questions" />}</span>
    <button type="button" className="cm-row-main" onClick={onOpen}>
      <strong>{question.prompt}</strong>
      {answer && <span className="cm-answer"><Icon name="check" /><span>{answer}</span></span>}
      <span className="cm-meta">{question.number != null && <span className="cm-chip cm-num">#{question.number}</span>}<span className="cm-cat"><i /><span>{category?.title ?? question.category_id}</span></span><span className="cm-chip">{question.is_exam_question ? 'Ikizamini' : 'Inyongera'}</span>{!question.explanation?.trim() && <span className="cm-chip warn">Nta bisobanuro</span>}{openReports > 0 && <span className="cm-chip danger">⚑ Raporo {openReports}</span>}{question.created_at && <span>Yongewe {formatDate(question.created_at)}</span>}{question.updated_at && <span>Byahinduwe {formatDate(question.updated_at)}</span>}{question.audio_path && <span className="cm-chip">Amajwi</span>}</span>
    </button>
    <StatusSwitch published={question.published} label={question.prompt} onToggle={onToggle} />
    <div className="cm-row-actions"><ActionIcon kind="edit" label="Hindura ikibazo" onClick={onOpen} /><ActionIcon kind="delete" label="Siba ikibazo" onClick={onDelete} /></div>
  </article>;
}
function LessonRow({ lesson, index, category, onMove, first = false, last = false, onOpen, onToggle, onDelete }: { lesson: Lesson; index?: number; category?: Category; onMove?: (direction: -1 | 1) => void; first?: boolean; last?: boolean; onOpen: () => void; onToggle: () => void; onDelete: () => void }) {
  return <article className="cm-row" style={catStyle(category)}>
    <span className="cm-index">{index ?? <Icon name="lessons" />}</span>
    <button type="button" className="cm-row-main" onClick={onOpen}>
      <strong>{lesson.title}</strong>
      <span className="cm-meta">{category && <span className="cm-cat"><i /><span>{category.title}</span></span>}<span>{lesson.lesson_sections?.length ?? 0} bice</span><span>{lesson.minutes} min</span>{lesson.is_extra && <span className="cm-chip">Inyongera</span>}{category && <span>Yongewe {formatDate(lesson.created_at)}</span>}{lesson.updated_at && <span>Byahinduwe {formatDate(lesson.updated_at)}</span>}{lesson.audio_path && <span className="cm-chip">Amajwi</span>}</span>
    </button>
    {onMove && <MoveButtons label={lesson.title} first={first} last={last} onMove={onMove} />}
    <StatusSwitch published={lesson.published} label={lesson.title} onToggle={onToggle} />
    <div className="cm-row-actions"><ActionIcon kind="edit" label="Hindura isomo" onClick={onOpen} /><ActionIcon kind="delete" label="Siba isomo" onClick={onDelete} /></div>
  </article>;
}
function Drawer({ eyebrow, title, wide = false, onClose, onSubmit, footer, children }: { eyebrow: string; title: string; wide?: boolean; onClose: () => void; onSubmit: (event: FormEvent) => void; footer: ReactNode; children: ReactNode }) {
  return <div className="cm-drawer-root"><div className="cm-backdrop" onClick={onClose} /><form className={`cm-drawer ${wide ? 'wide' : ''}`} role="dialog" aria-modal="true" aria-labelledby="cm-drawer-title" onSubmit={onSubmit}><header className="cm-drawer-head"><div><p className="eyebrow">{eyebrow}</p><h2 id="cm-drawer-title">{title}</h2></div><button type="button" className="cm-close" aria-label="Funga" onClick={onClose}>×</button></header><div className="cm-drawer-body">{children}</div><footer className="cm-drawer-foot">{footer}</footer></form></div>;
}
// Recording learners hear from the app's listen button; the player lets the admin check it before saving.
function AudioField({ ready, label, src, onPick, onRemove }: { ready: boolean; label: string; src: string | null; onPick: (event: ChangeEvent<HTMLInputElement>) => void; onRemove: () => void }) {
  if (!ready) return <div className="cm-field"><span>{label}</span><span className="cm-hint">Kora migration <code>202611010003_audio.sql</code> muri Supabase kugira ngo ushyireho amajwi.</span></div>;
  return <div className="cm-field"><span>{label}</span>{src
    ? <div className="cm-image cm-audio"><audio controls preload="none" src={src} /><div><label className="cm-upload">Hindura amajwi<input type="file" accept="audio/*" onChange={onPick} /></label><button type="button" className="cm-remove" onClick={onRemove}>Kuraho amajwi</button></div></div>
    : <label className="cm-upload cm-dropzone"><Icon name="volume" /><span>Hitamo amajwi (MP3 cyangwa M4A, ≤ 20 MB)</span><input type="file" accept="audio/*" onChange={onPick} /></label>}</div>;
}
function ImageField({ label, src, onPick, onRemove }: { label: string; src: string | null; onPick: (event: ChangeEvent<HTMLInputElement>) => void; onRemove: () => void }) {
  return <div className="cm-field"><span>{label}</span>{src
    ? <div className="cm-image"><img src={src} alt={label} /><div><label className="cm-upload">Hindura ifoto<input type="file" accept="image/*" onChange={onPick} /></label><button type="button" className="cm-remove" onClick={onRemove}>Kuraho ifoto</button></div></div>
    : <label className="cm-upload cm-dropzone"><Icon name="image" /><span>Hitamo ifoto (PNG cyangwa JPG, ≤ 6 MB)</span><input type="file" accept="image/*" onChange={onPick} /></label>}</div>;
}
