'use client';

import { ChangeEvent, FormEvent, useCallback, useEffect, useMemo, useState } from 'react';
import type { Session } from '@supabase/supabase-js';
import { configured, supabase } from '@/lib/supabase';

type Category = { id: string; title: string; subtitle: string; icon_code: number; icon_font_family: string | null; icon_font_package: string | null; color_value: number; soft_color_value: number; sort_order: number; published: boolean };
type Option = { id?: string; position: number; option_text: string; is_correct: boolean };
type Question = { id: string; category_id: string; prompt: string; explanation: string; sign_type: string | null; sign_label: string | null; image_path: string | null; is_exam_question: boolean; sort_order: number; published: boolean; question_options: Option[] };
type Section = { id?: string; position: number; heading: string; body: string; sign_type: string | null; sign_label: string | null; image_path: string | null };
type Lesson = { id: string; category_id: string; title: string; minutes: number; sort_order: number; created_at: string; is_extra: boolean; published: boolean; lesson_sections: Section[] };
type Learner = { id: string; email: string | null; phone: string | null; createdAt: string; lastSignInAt: string | null; bannedUntil: string | null; isAdmin: boolean; progressUpdatedAt: string | null; completedLessons: number; hasProgress: boolean };
type View = 'overview' | 'questions' | 'lessons' | 'categories' | 'users';
type Notice = { kind: 'error' | 'success'; text: string };

const emptyQuestion = () => ({ id: '', category_id: '', prompt: '', explanation: '', sign_type: '', sign_label: '', image_path: '', is_exam_question: true, published: false, options: ['', '', '', ''], correct: 0 });
const emptyLesson = () => ({ id: '', category_id: '', title: '', minutes: 5, is_extra: false, published: false, sections: [{ heading: '', body: '', sign_type: '', sign_label: '', image_path: '' }] });

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
  const [questionForm, setQuestionForm] = useState(emptyQuestion);
  const [lessonForm, setLessonForm] = useState(emptyLesson);
  const [categoryForm, setCategoryForm] = useState({ id: '', title: '', subtitle: '' });

  const sayError = (error: unknown) => setNotice({ kind: 'error', text: error instanceof Error ? error.message : String(error) });
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
    const [cats, qs, ls] = await Promise.all([
      supabase.from('content_categories').select('*').order('sort_order'),
      supabase.from('questions').select('*, question_options(*)').order('sort_order'),
      supabase.from('lessons').select('*, lesson_sections(*)').order('created_at', { ascending: false }),
    ]);
    setBusy(false);
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
    const prompt = action === 'suspend' ? `Uhagarike konti ya ${learner.email ?? learner.phone ?? learner.id}?` : `Wongere ufungure konti ya ${learner.email ?? learner.phone ?? learner.id}?`;
    if (!confirm(prompt)) return;
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
    return path;
  };

  const imageUrl = (path: string | null | undefined) => {
    if (!path) return null;
    const bundledPrefix = 'assets/images/road_signs/pdf/';
    if (path.startsWith(bundledPrefix)) {
      return path.replace(bundledPrefix, '/road-signs/pdf/');
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

  const openQuestion = (q?: Question) => {
    if (!q) { setQuestionForm({ ...emptyQuestion(), category_id: categories[0]?.id ?? '' }); return; }
    const options = [...q.question_options].sort((a, b) => a.position - b.position);
    setQuestionForm({ id: q.id, category_id: q.category_id, prompt: q.prompt, explanation: q.explanation, sign_type: q.sign_type ?? '', sign_label: q.sign_label ?? '', image_path: q.image_path ?? '', is_exam_question: q.is_exam_question, published: q.published, options: options.map(o => o.option_text), correct: Math.max(0, options.findIndex(o => o.is_correct)) });
  };

  const saveQuestion = async (event: FormEvent) => {
    event.preventDefault(); setBusy(true); setNotice(null);
    try {
      const db = requireClient();
      const row = { id: questionForm.id || crypto.randomUUID(), category_id: questionForm.category_id, prompt: questionForm.prompt.trim(), explanation: questionForm.explanation.trim(), sign_type: questionForm.sign_type.trim() || null, sign_label: questionForm.sign_label.trim() || null, image_path: questionForm.image_path || null, is_exam_question: questionForm.is_exam_question, sort_order: questionForm.id ? (questions.find(q => q.id === questionForm.id)?.sort_order ?? questions.length) : questions.length, published: questionForm.published };
      const { error } = await db.from('questions').upsert(row); if (error) throw error;
      const remove = await db.from('question_options').delete().eq('question_id', row.id); if (remove.error) throw remove.error;
      const inserted = await db.from('question_options').insert(questionForm.options.map((option_text, position) => ({ id: `${row.id}-${position}-${crypto.randomUUID().slice(0, 8)}`, question_id: row.id, position, option_text: option_text.trim(), is_correct: position === questionForm.correct })));
      if (inserted.error) throw inserted.error;
      setQuestionForm(emptyQuestion()); setNotice({ kind: 'success', text: 'Ikibazo cyabitswe neza.' }); await loadData();
    } catch (error) { sayError(error); }
    finally { setBusy(false); }
  };

  const removeQuestion = async (id: string) => {
    if (!confirm('Urashaka gusiba iki kibazo?')) return;
    const { error } = await requireClient().from('questions').delete().eq('id', id);
    if (error) sayError(error); else { setNotice({ kind: 'success', text: 'Ikibazo cyasibwe.' }); await loadData(); }
  };

  const openLesson = (lesson?: Lesson) => {
    if (!lesson) { setLessonForm({ ...emptyLesson(), category_id: categories[0]?.id ?? '' }); return; }
    const sections = [...lesson.lesson_sections].sort((a, b) => a.position - b.position);
    setLessonForm({ id: lesson.id, category_id: lesson.category_id, title: lesson.title, minutes: lesson.minutes, is_extra: lesson.is_extra, published: lesson.published, sections: sections.length ? sections.map(s => ({ ...s, sign_type: s.sign_type ?? '', sign_label: s.sign_label ?? '', image_path: s.image_path ?? '' })) : emptyLesson().sections });
  };

  const saveLesson = async (event: FormEvent) => {
    event.preventDefault(); setBusy(true); setNotice(null);
    try {
      const db = requireClient();
      const row = { id: lessonForm.id || `lesson-${crypto.randomUUID()}`, category_id: lessonForm.category_id, title: lessonForm.title.trim(), minutes: Number(lessonForm.minutes), sort_order: lessonForm.id ? (lessons.find(l => l.id === lessonForm.id)?.sort_order ?? lessons.length) : lessons.length, is_extra: lessonForm.is_extra, published: lessonForm.published };
      const { error } = await db.from('lessons').upsert(row); if (error) throw error;
      const removed = await db.from('lesson_sections').delete().eq('lesson_id', row.id); if (removed.error) throw removed.error;
      const sections = await db.from('lesson_sections').insert(lessonForm.sections.filter(s => s.heading.trim() && s.body.trim()).map((s, position) => ({ id: `${row.id}-${position}`, lesson_id: row.id, position, heading: s.heading.trim(), body: s.body.trim(), sign_type: s.sign_type || null, sign_label: s.sign_label || null, image_path: s.image_path || null })));
      if (sections.error) throw sections.error;
      setLessonForm(emptyLesson()); setNotice({ kind: 'success', text: 'Isomo ryabitswe neza.' }); await loadData();
    } catch (error) { sayError(error); }
    finally { setBusy(false); }
  };

  const removeLesson = async (id: string) => {
    if (!confirm('Urashaka gusiba iri somo?')) return;
    const { error } = await requireClient().from('lessons').delete().eq('id', id);
    if (error) sayError(error); else { setNotice({ kind: 'success', text: 'Isomo ryasibwe.' }); await loadData(); }
  };

  const saveCategory = async (event: FormEvent) => {
    event.preventDefault(); setBusy(true);
    try {
      const id = categoryForm.id.trim().toLowerCase().replace(/[^a-z0-9-]+/g, '-');
      const existing = categories.some(category => category.id === id);
      const db = requireClient();
      const result = existing
        ? await db.from('content_categories').update({ title: categoryForm.title.trim(), subtitle: categoryForm.subtitle.trim() }).eq('id', id)
        : await db.from('content_categories').insert({ id, title: categoryForm.title.trim(), subtitle: categoryForm.subtitle.trim(), icon_code: 0, icon_font_family: null, icon_font_package: null, icon_match_text_direction: false, color_value: 0xff315c72, soft_color_value: 0xffe7f0f3, sort_order: categories.length, published: false });
      if (result.error) throw result.error;
      setCategoryForm({ id: '', title: '', subtitle: '' }); setNotice({ kind: 'success', text: existing ? 'Icyiciro cyahinduwe.' : 'Icyiciro cyongeweho (ntikiratangazwa).'}); await loadData();
    } catch (error) { sayError(error); }
    finally { setBusy(false); }
  };

  const togglePublished = async (table: 'questions' | 'lessons' | 'content_categories', row: { id: string; published: boolean }) => {
    const { error } = await requireClient().from(table).update({ published: !row.published }).eq('id', row.id);
    if (error) sayError(error); else await loadData();
  };

  const filteredQuestions = useMemo(() => questions.filter(q => {
    const category = categories.find(c => c.id === q.category_id)?.title ?? '';
    const text = `${q.prompt} ${q.explanation} ${category} ${q.question_options?.map(option => option.option_text).join(' ') ?? ''}`.toLocaleLowerCase();
    return text.includes(search.trim().toLocaleLowerCase()) && (categoryFilter === 'all' || q.category_id === categoryFilter) && (statusFilter === 'all' || q.published === (statusFilter === 'published'));
  }), [questions, categories, search, categoryFilter, statusFilter]);
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

  if (!authReady) return <main className="center"><span className="spinner" /> Kugenzura konti...</main>;
  if (!configured || !supabase) return <main className="center"><section className="login-card"><Brand /><h1>Huza Supabase</h1><p>Copy admin-dashboard/.env.example to admin-dashboard/.env.local, then add your project URL and publishable key.</p></section></main>;
  if (!session || !isAdmin) return <main className="center"><form className="login-card" onSubmit={signIn}><Brand /><p className="eyebrow">AMATEGEKO Y’UMUHANDA</p><h1>Admin Dashboard</h1><p>Injira ukoresheje konti yemerewe gucunga ibikubiye muri app.</p>{notice && <div className={`notice ${notice.kind}`}>{notice.text}</div>}<label>Email<input type="email" autoComplete="username" required value={email} onChange={e => setEmail(e.target.value)} /></label><label>Ijambo ry’ibanga<input type="password" autoComplete="current-password" required value={password} onChange={e => setPassword(e.target.value)} /></label><button className="primary full" disabled={busy}>{busy ? 'Tegereza...' : 'Injira'}</button><small>Konti igomba kuba yanditswe muri <code>admin_users</code> ya Supabase.</small></form></main>;

  return <main className={`shell grid min-h-screen transition-[grid-template-columns] duration-300 ease-in-out ${menuOpen ? '' : 'sidebar-collapsed'}`}>
    <aside className="sidebar sticky top-0 flex h-screen flex-col overflow-hidden transition-all duration-300"><Brand /><div className="side-label">IMICUNGIRE</div><nav className="sidebar-nav flex flex-col">{(['overview', 'questions', 'lessons', 'categories', 'users'] as View[]).map(item => <button key={item} className={`nav-item ${view === item ? 'active' : ''}`} onClick={() => { setView(item); setNotice(null); setSearch(''); }}><span className="nav-icon">{({ overview: 'H', questions: '?', lessons: 'L', categories: 'O', users: 'U' } as Record<View,string>)[item]}</span>{{ overview: 'Incamake', questions: 'Ibibazo', lessons: 'Amasomo', categories: 'Ibyiciro', users: 'Abakoresha' }[item]}<span className="nav-count">{item === 'questions' ? questions.length : item === 'lessons' ? lessons.length : item === 'categories' ? categories.length : item === 'users' ? learnerTotal || '' : ''}</span></button>)}</nav><div className="sidebar-bottom"><span className="avatar">{session.user.email?.slice(0, 1).toUpperCase() ?? 'A'}</span><span className="admin-email">{session.user.email}</span><button className="text-button" onClick={signOut}>Sohoka</button></div></aside>
    <section className="workspace mx-auto w-full max-w-[1550px]"><header className="topbar"><div className="topbar-title"><button className="sidebar-toggle grid h-[42px] w-[42px] place-items-center rounded-xl border border-slate-300 bg-white text-xl text-brand-800 transition duration-200 hover:-translate-y-px hover:border-brand-100 hover:bg-brand-50" type="button" aria-label={menuOpen ? 'Funga sidebar' : 'Fungura sidebar'} aria-expanded={menuOpen} onClick={() => setMenuOpen(open => !open)}>{menuOpen ? '×' : '☰'}</button><div><span className="eyebrow">AMATEGEKO Y’UMUHANDA / ADMIN</span><h1>{{ overview: 'Incamake', questions: 'Gucunga ibibazo', lessons: 'Gucunga amasomo', categories: 'Gucunga ibyiciro', users: 'Gucunga abakoresha' }[view]}</h1></div></div><div className="top-actions"><span className="secure"><i /> Konti ya admin</span><button className="refresh" onClick={() => view === 'users' ? void loadLearners() : void loadData()} title="Ongera uvugurure">↻</button></div></header>
      {notice && <div className={`notice ${notice.kind}`}>{notice.text}<button onClick={() => setNotice(null)}>Ã—</button></div>}
      {view === 'overview' && <><div className="dashboard-hero"><div><p className="eyebrow">AMATEGEKO Y’UMUHANDA · ADMIN</p><h2>Murakaza neza 👋</h2><p>Reba uko app ihagaze, ucunge abakoresha, kandi uvugurure ibikubiye muri app.</p></div><div className="hero-actions"><button className="primary" onClick={() => { openQuestion(); setView('questions'); }}>＋ Ikibazo gishya</button><button className="hero-secondary" onClick={() => { openLesson(); setView('lessons'); }}>＋ Isomo rishya</button></div><div className="hero-orb orb-one" /><div className="hero-orb orb-two" /></div><div className="section-heading dashboard-heading"><div><p className="eyebrow">INCAMAKE Y’IBIKUBIYE MURI APP</p><h2>Uko ibintu bihagaze</h2></div><span className="live-label"><i /> Bivuye muri Supabase</span></div><div className="stat-grid dashboard-stats"><Stat label="Ibibazo" value={questions.length} detail={`${questions.filter(q => q.published).length} byatangajwe · ${questions.filter(q => !q.published).length} draft`} icon="?" /><Stat label="Amasomo" value={lessons.length} detail={`${lessons.filter(l => l.published).length} yatangajwe · ${lessons.filter(l => !l.published).length} draft`} icon="L" /><Stat label="Ibyiciro" value={categories.length} detail={`${categories.filter(c => c.published).length} byatangajwe`} icon="O" /><Stat label="Abakoresha" value={learnersReady ? learnerTotal : '—'} detail={learnersReady ? 'Konti zose za Supabase Auth' : 'Fungura abakoresha urebe umubare'} icon="U" /></div><div className="dashboard-columns"><section className="manage-panel"><div className="section-heading"><div><p className="eyebrow">GUCUNGA</p><h2>Ibice bya dashboard</h2></div></div><div className="manage-grid"><ManageCard icon="?" title="Ibibazo" detail={`${questions.length} byose · ${questions.filter(q => !q.published).length} draft`} onClick={() => setView('questions')} /><ManageCard icon="L" title="Amasomo" detail={`${lessons.length} yose · ${lessons.filter(l => !l.published).length} draft`} onClick={() => setView('lessons')} /><ManageCard icon="O" title="Ibyiciro" detail={`${categories.length} byo gutondekamo`} onClick={() => setView('categories')} /><ManageCard icon="U" title="Abakoresha" detail="Reba konti, gushakisha no guhagarika konti" onClick={() => setView('users')} /></div></section><aside className="review-panel"><div><p className="eyebrow">IBIKENEYE KWITABWAHO</p><h2>Ibikorwa byo gukurikirana</h2></div><ReviewRow label="Ibibazo bitaratangazwa" count={questions.filter(q => !q.published).length} onClick={() => { setStatusFilter('draft'); setView('questions'); }} /><ReviewRow label="Amasomo ataratangazwa" count={lessons.filter(l => !l.published).length} onClick={() => { setStatusFilter('draft'); setView('lessons'); }} /><ReviewRow label="Ibyiciro bitaratangazwa" count={categories.filter(c => !c.published).length} onClick={() => { setStatusFilter('draft'); setView('categories'); }} /><p className="footnote">Suzuma ibiri muri draft mbere yo kubitangaza ku bakoresha app.</p></aside></div></>}

      {view === 'questions' && <><div className="toolbar"><ListControls search={search} onSearchChange={updateSearch} status={statusFilter} onStatusChange={updateStatusFilter} pageSize={pageSize} onPageSizeChange={updatePageSize} categories={categories} category={categoryFilter} onCategoryChange={updateCategoryFilter} placeholder="Shakisha ikibazo, ibisobanuro cyangwa icyiciro..." /><button className="primary" onClick={() => openQuestion()}>+ Ikibazo gishya</button></div><div className="content-grid"><div className="list-card"><div className="list-head"><b>{filteredQuestions.length} bibazo</b><span>{busy ? 'Biravugururwa...' : 'Bivuye muri Supabase'}</span></div>{visibleQuestions.map(q => <article className="content-row" key={q.id}><div className="row-image">{imageUrl(q.image_path) ? <img src={imageUrl(q.image_path)!} alt="" /> : <span>?</span>}</div><div className="row-main"><b>{q.prompt}</b><small>{categories.find(c => c.id === q.category_id)?.title ?? q.category_id} - {q.question_options?.length ?? 0} ibisubizo</small><span className={`pill ${q.published ? 'published' : ''}`}>{q.published ? 'Byatangajwe' : 'Draft'}</span></div><div className="row-actions"><button onClick={() => void togglePublished('questions', q)}>{q.published ? 'Hisha' : 'Tangaza'}</button><ActionIcon kind="edit" label="Hindura ikibazo" onClick={() => openQuestion(q)} /><ActionIcon kind="delete" label="Siba ikibazo" onClick={() => void removeQuestion(q.id)} /></div></article>)}{filteredQuestions.length === 0 && <Empty text="Nta kibazo gihuye n'ishakisha cyangwa filters." />}{<Pagination total={filteredQuestions.length} page={questionPage} pageSize={pageSize} onPageChange={setPage} />}</div>
        <form className="editor-card" onSubmit={saveQuestion}><div className="editor-title"><div><p className="eyebrow">UMWANDITSI W’IBIBAZO</p><h2>{questionForm.id ? 'Hindura ikibazo' : 'Ikibazo gishya'}</h2></div>{questionForm.id && <button type="button" className="text-button" onClick={() => openQuestion()}>Gishya</button>}</div><label>Ikibazo<textarea required rows={3} value={questionForm.prompt} onChange={e => setQuestionForm({ ...questionForm, prompt: e.target.value })} /></label><label>Icyiciro<select required value={questionForm.category_id} onChange={e => setQuestionForm({ ...questionForm, category_id: e.target.value })}><option value="">Hitamo icyiciro</option>{categories.map(c => <option key={c.id} value={c.id}>{c.title}</option>)}</select></label><div className="field-title">Ibisubizo - hitamo igisubizo nyacyo</div>{questionForm.options.map((option, i) => <div className="option-field" key={i}><input aria-label={`Igisubizo ${i + 1}`} required value={option} onChange={e => { const options = [...questionForm.options]; options[i] = e.target.value; setQuestionForm({ ...questionForm, options }); }} /><label className="radio-label"><input type="radio" name="correct" checked={questionForm.correct === i} onChange={() => setQuestionForm({ ...questionForm, correct: i })} /> Nyacyo</label></div>)}<label>Ibisobanuro by’igisubizo<textarea rows={2} value={questionForm.explanation} onChange={e => setQuestionForm({ ...questionForm, explanation: e.target.value })} /></label><div className="two-fields"><label>Ubwoko bw’icyapa<input placeholder="urugero: danger" value={questionForm.sign_type} onChange={e => setQuestionForm({ ...questionForm, sign_type: e.target.value })} /></label><label>Agaciro/inyandiko<input placeholder="urugero: 10%" value={questionForm.sign_label} onChange={e => setQuestionForm({ ...questionForm, sign_label: e.target.value })} /></label></div><label>Ifoto y’icyapa<input type="file" accept="image/*" onChange={async e => { try { const path = await uploadImage(e); if (path) setQuestionForm(f => ({ ...f, image_path: path })); } catch (error) { sayError(error); } }} /></label>{questionForm.image_path && <div className="image-preview"><img src={imageUrl(questionForm.image_path)!} alt="Ifoto y’icyapa" /><button type="button" className="text-button" onClick={() => setQuestionForm({ ...questionForm, image_path: '' })}>Kuraho ifoto</button></div>}<label className="check-row"><input type="checkbox" checked={questionForm.is_exam_question} onChange={e => setQuestionForm({ ...questionForm, is_exam_question: e.target.checked })} /> Iki kibazo gishobora kujya mu kizamini</label><label className="check-row"><input type="checkbox" checked={questionForm.published} onChange={e => setQuestionForm({ ...questionForm, published: e.target.checked })} /> Tangaza ako kanya</label><button className="primary full" disabled={busy}>{busy ? 'Birabikwa...' : 'Bika ikibazo'}</button></form></div></>}

      {view === 'lessons' && <><div className="toolbar"><ListControls search={search} onSearchChange={updateSearch} status={statusFilter} onStatusChange={updateStatusFilter} pageSize={pageSize} onPageSizeChange={updatePageSize} categories={categories} category={categoryFilter} onCategoryChange={updateCategoryFilter} placeholder="Shakisha isomo, ibisobanuro cyangwa icyiciro..." /><button className="primary" onClick={() => openLesson()}>+ Isomo rishya</button></div><div className="lesson-sort-controls"><label>Itariki<select value={lessonDateFilter} onChange={event => { setLessonDateFilter(event.target.value as typeof lessonDateFilter); setPage(1); }}><option value="all">Amatariki yose</option><option value="today">Uyu munsi</option><option value="yesterday">Ejo</option></select></label><label>Uko akurikirana<select value={lessonSort} onChange={event => { setLessonSort(event.target.value as typeof lessonSort); setPage(1); }}><option value="newest">Ashya mbere</option><option value="oldest">Ahashaje mbere</option><option value="manual">Uko yatondetswe</option></select></label></div><div className="content-grid"><div className="list-card"><div className="list-head"><b>{filteredLessons.length} masomo</b><span>{busy ? 'Biravugururwa...' : 'Bivuye muri Supabase'}</span></div>{visibleLessons.map(l => <article className="content-row" key={l.id}><div className="row-image lesson-icon">L</div><div className="row-main"><b>{l.title}</b><small>{categories.find(c => c.id === l.category_id)?.title ?? l.category_id} - {l.lesson_sections?.length ?? 0} bice - {l.minutes} min - Yashyizwemo: {formatDateTime(l.created_at)}</small><span className={`pill ${l.published ? 'published' : ''}`}>{l.published ? 'Byatangajwe' : 'Draft'}</span></div><div className="row-actions"><button onClick={() => void togglePublished('lessons', l)}>{l.published ? 'Hisha' : 'Tangaza'}</button><ActionIcon kind="edit" label="Hindura isomo" onClick={() => openLesson(l)} /><ActionIcon kind="delete" label="Siba isomo" onClick={() => void removeLesson(l.id)} /></div></article>)}{filteredLessons.length === 0 && <Empty text="Nta somo rihuye n'ishakisha cyangwa filters." />}{<Pagination total={filteredLessons.length} page={lessonPage} pageSize={pageSize} onPageChange={setPage} />}</div>
        <form className="editor-card" onSubmit={saveLesson}><div className="editor-title"><div><p className="eyebrow">UMWANDITSI W’AMASOMO</p><h2>{lessonForm.id ? 'Hindura isomo' : 'Isomo rishya'}</h2></div>{lessonForm.id && <button type="button" className="text-button" onClick={() => openLesson()}>Gishya</button>}</div><label>Umutwe w’isomo<input required value={lessonForm.title} onChange={e => setLessonForm({ ...lessonForm, title: e.target.value })} /></label><div className="two-fields"><label>Icyiciro<select required value={lessonForm.category_id} onChange={e => setLessonForm({ ...lessonForm, category_id: e.target.value })}><option value="">Hitamo icyiciro</option>{categories.map(c => <option key={c.id} value={c.id}>{c.title}</option>)}</select></label><label>Igihe (iminota)<input type="number" min={1} required value={lessonForm.minutes} onChange={e => setLessonForm({ ...lessonForm, minutes: Number(e.target.value) })} /></label></div>{lessonForm.sections.map((section, i) => <fieldset className="section-field" key={i}><legend>Igice {i + 1}</legend><label>Umutwe<input required value={section.heading} onChange={e => { const sections = [...lessonForm.sections]; sections[i] = { ...section, heading: e.target.value }; setLessonForm({ ...lessonForm, sections }); }} /></label><label>Ibisobanuro<textarea required rows={4} value={section.body} onChange={e => { const sections = [...lessonForm.sections]; sections[i] = { ...section, body: e.target.value }; setLessonForm({ ...lessonForm, sections }); }} /></label><div className="two-fields"><label>Ubwoko bw’icyapa<input placeholder="urugero: stop" value={section.sign_type ?? ''} onChange={e => { const sections = [...lessonForm.sections]; sections[i] = { ...section, sign_type: e.target.value }; setLessonForm({ ...lessonForm, sections }); }} /></label><label>Agaciro/inyandiko<input value={section.sign_label ?? ''} onChange={e => { const sections = [...lessonForm.sections]; sections[i] = { ...section, sign_label: e.target.value }; setLessonForm({ ...lessonForm, sections }); }} /></label></div><label>Ifoto y’icyapa<input type="file" accept="image/*" onChange={async e => { try { const path = await uploadImage(e); if (path) { const sections = [...lessonForm.sections]; sections[i] = { ...section, image_path: path }; setLessonForm({ ...lessonForm, sections }); } } catch (error) { sayError(error); } }} /></label>{section.image_path && <div className="image-preview"><img src={imageUrl(section.image_path)!} alt="Ifoto" /><button type="button" className="text-button" onClick={() => { const sections = [...lessonForm.sections]; sections[i] = { ...section, image_path: '' }; setLessonForm({ ...lessonForm, sections }); }}>Kuraho ifoto</button></div>}{lessonForm.sections.length > 1 && <button type="button" className="danger-text" onClick={() => setLessonForm({ ...lessonForm, sections: lessonForm.sections.filter((_, n) => n !== i) })}>Kuraho iki gice</button>}</fieldset>)}<button type="button" className="secondary full" onClick={() => setLessonForm({ ...lessonForm, sections: [...lessonForm.sections, { heading: '', body: '', sign_type: '', sign_label: '', image_path: '' }] })}>+ Ongeramo ikindi gice</button><label className="check-row"><input type="checkbox" checked={lessonForm.is_extra} onChange={e => setLessonForm({ ...lessonForm, is_extra: e.target.checked })} /> Isomo ry’inyongera</label><label className="check-row"><input type="checkbox" checked={lessonForm.published} onChange={e => setLessonForm({ ...lessonForm, published: e.target.checked })} /> Tangaza ako kanya</label><button className="primary full" disabled={busy}>{busy ? 'Birabikwa...' : 'Bika isomo'}</button></form></div></>}

      {view === 'categories' && <><div className="toolbar"><ListControls search={search} onSearchChange={updateSearch} status={statusFilter} onStatusChange={updateStatusFilter} pageSize={pageSize} onPageSizeChange={updatePageSize} categories={categories} placeholder="Shakisha icyiciro..." showCategory={false} /></div><div className="category-layout"><form className="editor-card" onSubmit={saveCategory}><p className="eyebrow">{categories.some(c => c.id === categoryForm.id) ? 'HINDURA ICYICIRO' : 'ICYICIRO GISHYA'}</p><h2>{categories.some(c => c.id === categoryForm.id) ? 'Hindura icyiciro' : 'Ongeramo icyiciro'}</h2><label>Izina rigufi / ID<input required pattern="[A-Za-z0-9-]+" placeholder="urugero: ibimenyetso" value={categoryForm.id} readOnly={categories.some(c => c.id === categoryForm.id)} onChange={e => setCategoryForm({ ...categoryForm, id: e.target.value })} /></label><label>Izina rigaragara<input required value={categoryForm.title} onChange={e => setCategoryForm({ ...categoryForm, title: e.target.value })} /></label><label>Ibisobanuro bigufi<input value={categoryForm.subtitle} onChange={e => setCategoryForm({ ...categoryForm, subtitle: e.target.value })} /></label><button className="primary full" disabled={busy}>Bika icyiciro</button>{categoryForm.id && <button type="button" className="secondary full" onClick={() => setCategoryForm({ id: '', title: '', subtitle: '' })}>Reka guhindura</button>}</form><div className="category-grid">{visibleCategories.map(c => <article className="category-card" key={c.id}><div className="category-symbol">O</div><h3>{c.title}</h3><p>{c.subtitle}</p><small>{c.id}</small><div className="category-meta"><span className={`pill ${c.published ? 'published' : ''}`}>{c.published ? 'Byatangajwe' : 'Draft'}</span><button onClick={() => void togglePublished('content_categories', c)}>{c.published ? 'Hisha' : 'Tangaza'}</button></div><div className="category-meta"><ActionIcon kind="edit" label="Hindura icyiciro" onClick={() => setCategoryForm({ id: c.id, title: c.title, subtitle: c.subtitle })} /></div><small>{questions.filter(q => q.category_id === c.id).length} bibazo - {lessons.filter(l => l.category_id === c.id).length} masomo</small></article>)}</div><Pagination total={filteredCategories.length} page={categoryPage} pageSize={pageSize} onPageChange={setPage} /></div></>}

      {view === 'users' && <><div className="users-intro"><div className="users-intro-icon">U</div><div><h2>Konti z’abakoresha</h2><p>Genzura abakoresha biyandikishije, reba uko bakoresha app, kandi uhagarike cyangwa wongere ufungure konti.</p></div><div className="users-total"><strong>{learnerTotal}</strong><span>konti zose</span></div></div><div className="users-toolbar"><label className="user-search"><span>⌕</span><input type="search" placeholder="Shakisha email, telefone cyangwa ID..." value={learnerSearch} onChange={event => { setLearnerSearch(event.target.value); setLearnerPage(1); }} /><button type="button" disabled={!learnerSearch} onClick={() => { setLearnerSearch(''); setLearnerPage(1); }}>×</button></label><select value={learnerStatus} aria-label="Akayunguruzo ka konti" onChange={event => { setLearnerStatus(event.target.value as typeof learnerStatus); setLearnerPage(1); }}><option value="all">Konti zose</option><option value="active">Zikora</option><option value="suspended">Zahagaritswe</option></select><label className="page-size">Rows<select value={learnerPageSize} aria-label="Umubare w’abakoresha kuri page" onChange={event => { setLearnerPageSize(Number(event.target.value)); setLearnerPage(1); }}><option value={5}>5</option><option value={10}>10</option><option value={20}>20</option><option value={50}>50</option></select></label></div><div className="users-card"><div className="users-table-head"><div><strong>Abakoresha</strong><span>{busy ? 'Biravugururwa...' : `${learnerTotal} konti ziboneka`}</span></div><button className="secondary" onClick={() => void loadLearners()} disabled={busy}>↻ Ongera uvugurure</button></div>{learners.length ? <div className="users-table-wrap"><table className="users-table"><thead><tr><th>UMUKORESHA</th><th>YIYANDIKISHIJE</th><th>GUKORESHA APP</th><th>IMIMERERE</th><th>IBIKORWA</th></tr></thead><tbody>{learners.map(learner => { const suspended = Boolean(learner.bannedUntil && new Date(learner.bannedUntil) > new Date()); return <tr key={learner.id}><td><div className="user-cell"><span className="user-avatar">{(learner.email ?? learner.phone ?? 'U').slice(0,1).toUpperCase()}</span><span><strong>{learner.email ?? learner.phone ?? 'Konti idafite email/telefone'}</strong><small>{learner.phone && learner.email ? learner.phone : `ID: ${learner.id.slice(0,8)}…`}</small>{learner.isAdmin && <em>Admin</em>}</span></div></td><td>{formatDate(learner.createdAt)}</td><td><strong>{learner.completedLessons}</strong> amasomo{learner.progressUpdatedAt && <small className="table-subline">Yaherukaga: {formatDate(learner.progressUpdatedAt)}</small>}</td><td><span className={`user-status ${suspended ? 'suspended' : 'active'}`}><i />{suspended ? 'Yarahagaritswe' : 'Irakora'}</span></td><td>{learner.isAdmin ? <span className="protected-label">Admin irinzwe</span> : <button className={`user-action ${suspended ? 'restore' : ''}`} disabled={busy} onClick={() => void changeLearnerStatus(learner)}>{suspended ? 'Ongera ufungure' : 'Hagarika konti'}</button>}</td></tr>; })}</tbody></table></div> : <Empty text={learnersReady ? 'Nta konti zihuye n’ishakisha n’akayunguruzo.' : 'Shaka amakuru y’abakoresha...'} />}<Pagination total={learnerTotal} page={learnerPage} pageSize={learnerPageSize} onPageChange={setLearnerPage} /></div><p className="users-footnote">Abakoresha ni amakuru ava muri Supabase Auth. Ibyo bakora bibikwa kuri konti yabo; dashboard yerekana amasomo yarangiye gusa. Konti za admin ntizihagarikwa hano.</p></>}
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
function Stat({ label, value, detail, icon }: { label: string; value: number | string; detail: string; icon: string }) { return <article className="stat-card"><span className="stat-icon">{icon}</span><span className="stat-label">{label}</span><strong>{value}</strong><small>{detail}</small></article>; }
function ManageCard({ icon, title, detail, onClick }: { icon: string; title: string; detail: string; onClick: () => void }) { return <button className="manage-card" onClick={onClick}><span className="manage-icon">{icon}</span><span className="manage-copy"><strong>{title}</strong><small>{detail}</small></span><span className="manage-arrow">→</span></button>; }
function ReviewRow({ label, count, onClick }: { label: string; count: number; onClick: () => void }) { return <button className="review-row" onClick={onClick}><span>{label}</span><strong className={count ? 'needs-review' : 'all-clear'}>{count}</strong><span className="review-arrow">→</span></button>; }
function Empty({ text }: { text: string }) { return <div className="empty"><span>+</span><p>{text}</p></div>; }
function formatDate(value: string) { return new Date(value).toLocaleDateString('rw-RW', { day: 'numeric', month: 'short', year: 'numeric' }); }
function formatDateTime(value: string) { return new Date(value).toLocaleString('rw-RW', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' }); }
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
