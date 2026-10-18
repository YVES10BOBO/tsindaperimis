'use client';

import { ChangeEvent, FormEvent, useCallback, useEffect, useMemo, useState } from 'react';
import type { Session } from '@supabase/supabase-js';
import { configured, supabase } from '@/lib/supabase';

type Category = { id: string; title: string; subtitle: string; icon_code: number; icon_font_family: string | null; icon_font_package: string | null; color_value: number; soft_color_value: number; sort_order: number; published: boolean };
type Option = { id?: string; position: number; option_text: string; is_correct: boolean };
type Question = { id: string; category_id: string; prompt: string; explanation: string; sign_type: string | null; sign_label: string | null; image_path: string | null; is_exam_question: boolean; sort_order: number; published: boolean; question_options: Option[] };
type Section = { id?: string; position: number; heading: string; body: string; sign_type: string | null; sign_label: string | null; image_path: string | null };
type Lesson = { id: string; category_id: string; title: string; minutes: number; sort_order: number; is_extra: boolean; published: boolean; lesson_sections: Section[] };
type View = 'overview' | 'questions' | 'lessons' | 'categories';
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
  const [categories, setCategories] = useState<Category[]>([]);
  const [questions, setQuestions] = useState<Question[]>([]);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [search, setSearch] = useState('');
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
      supabase.from('lessons').select('*, lesson_sections(*)').order('sort_order'),
    ]);
    setBusy(false);
    const firstError = cats.error ?? qs.error ?? ls.error;
    if (firstError) { sayError(firstError); return; }
    setCategories((cats.data ?? []) as Category[]);
    setQuestions((qs.data ?? []) as Question[]);
    setLessons((ls.data ?? []) as Lesson[]);
  }, [isAdmin]);

  useEffect(() => { void loadData(); }, [loadData]);

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

  const imageUrl = (path: string | null | undefined) => path && supabase ? supabase.storage.from('road-signs').getPublicUrl(path).data.publicUrl : null;

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

  const filteredQuestions = useMemo(() => questions.filter(q => `${q.prompt} ${categories.find(c => c.id === q.category_id)?.title ?? ''}`.toLowerCase().includes(search.toLowerCase())), [questions, categories, search]);
  const filteredLessons = useMemo(() => lessons.filter(l => `${l.title} ${categories.find(c => c.id === l.category_id)?.title ?? ''}`.toLowerCase().includes(search.toLowerCase())), [lessons, categories, search]);

  if (!authReady) return <main className="center"><span className="spinner" /> Kugenzura konti...</main>;
  if (!configured || !supabase) return <main className="center"><section className="login-card"><Brand /><h1>Huza Supabase</h1><p>Copy admin-dashboard/.env.example to admin-dashboard/.env.local, then add your project URL and publishable key.</p></section></main>;
  if (!session || !isAdmin) return <main className="center"><form className="login-card" onSubmit={signIn}><Brand /><p className="eyebrow">AMATEGEKO Y’UMUHANDA</p><h1>Admin Dashboard</h1><p>Injira ukoresheje konti yemerewe gucunga ibikubiye muri app.</p>{notice && <div className={`notice ${notice.kind}`}>{notice.text}</div>}<label>Email<input type="email" autoComplete="username" required value={email} onChange={e => setEmail(e.target.value)} /></label><label>Ijambo ry’ibanga<input type="password" autoComplete="current-password" required value={password} onChange={e => setPassword(e.target.value)} /></label><button className="primary full" disabled={busy}>{busy ? 'Tegereza...' : 'Injira'}</button><small>Konti igomba kuba yanditswe muri <code>admin_users</code> ya Supabase.</small></form></main>;

  return <main className="shell">
    <aside className="sidebar"><Brand /><div className="side-label">IMICUNGIRE</div>{(['overview', 'questions', 'lessons', 'categories'] as View[]).map(item => <button key={item} className={`nav-item ${view === item ? 'active' : ''}`} onClick={() => { setView(item); setNotice(null); setSearch(''); }}><span className="nav-icon">{({ overview: 'H', questions: '?', lessons: 'L', categories: 'O' } as Record<View,string>)[item]}</span>{{ overview: 'Incamake', questions: 'Ibibazo', lessons: 'Amasomo', categories: 'Ibyiciro' }[item]}<span className="nav-count">{item === 'questions' ? questions.length : item === 'lessons' ? lessons.length : item === 'categories' ? categories.length : ''}</span></button>)}<div className="sidebar-bottom"><span className="avatar">{session.user.email?.slice(0, 1).toUpperCase() ?? 'A'}</span><span className="admin-email">{session.user.email}</span><button className="text-button" onClick={signOut}>Sohoka</button></div></aside>
    <section className="workspace"><header className="topbar"><div><span className="eyebrow">AMATEGEKO Y’UMUHANDA / ADMIN</span><h1>{{ overview: 'Incamake', questions: 'Gucunga ibibazo', lessons: 'Gucunga amasomo', categories: 'Gucunga ibyiciro' }[view]}</h1></div><div className="top-actions"><span className="secure"><i /> Konti ya admin</span><button className="refresh" onClick={() => void loadData()} title="Ongera uvugurure">R</button></div></header>
      {notice && <div className={`notice ${notice.kind}`}>{notice.text}<button onClick={() => setNotice(null)}>Ã—</button></div>}
      {view === 'overview' && <><div className="welcome"><div><p className="eyebrow">MURAKAZA NEZA</p><h2>Ibikubiye muri app, ahantu hamwe.</h2><p>Ongeramo ibibazo n’amasomo; usuzume mbere yo kubitangaza.</p></div><div className="welcome-mark">*</div></div><div className="stat-grid"><Stat label="Ibibazo byose" value={questions.length} detail={`${questions.filter(q => q.published).length} byatangajwe`} icon="?" /><Stat label="Amasomo yose" value={lessons.length} detail={`${lessons.filter(l => l.published).length} byatangajwe`} icon="L" /><Stat label="Ibyiciro" value={categories.length} detail="Ibibazo n’amasomo" icon="O" /></div><div className="section-heading"><div><p className="eyebrow">AKAZI K’UBWANDITSI</p><h2>Tangira gucunga content</h2></div></div><div className="quick-grid"><Quick title="Ongeramo ikibazo" text="Hitamo icyiciro, andika ibisubizo, ushyireho ifoto y’icyapa." onClick={() => { openQuestion(); setView('questions'); }} /><Quick title="Ongeramo isomo" text="Tegura isomo mu bice, ushyireho ibisobanuro n’amafoto." onClick={() => { openLesson(); setView('lessons'); }} /></div><p className="footnote">Content nshya ibanza kubikwa idatangajwe. Uyitangaze umaze kuyisuzuma.</p></>}

      {view === 'questions' && <><div className="toolbar"><input className="search" placeholder="Shakisha ikibazo cyangwa icyiciro..." value={search} onChange={e => setSearch(e.target.value)} /><button className="primary" onClick={() => openQuestion()}>+ Ikibazo gishya</button></div><div className="content-grid"><div className="list-card"><div className="list-head"><b>{filteredQuestions.length} bibazo</b><span>{busy ? 'Biravugururwa...' : 'Bivuye muri Supabase'}</span></div>{filteredQuestions.map(q => <article className="content-row" key={q.id}><div className="row-image">{imageUrl(q.image_path) ? <img src={imageUrl(q.image_path)!} alt="" /> : <span>?</span>}</div><div className="row-main"><b>{q.prompt}</b><small>{categories.find(c => c.id === q.category_id)?.title ?? q.category_id} - {q.question_options?.length ?? 0} ibisubizo</small><span className={`pill ${q.published ? 'published' : ''}`}>{q.published ? 'Byatangajwe' : 'Draft'}</span></div><div className="row-actions"><button onClick={() => void togglePublished('questions', q)}>{q.published ? 'Hisha' : 'Tangaza'}</button><button onClick={() => openQuestion(q)}>Hindura</button><button className="danger-text" onClick={() => void removeQuestion(q.id)}>Siba</button></div></article>)}{filteredQuestions.length === 0 && <Empty text="Nta kibazo kirimo. Kanda 'Ikibazo gishya' utangire." />}</div>
        <form className="editor-card" onSubmit={saveQuestion}><div className="editor-title"><div><p className="eyebrow">UMWANDITSI W’IBIBAZO</p><h2>{questionForm.id ? 'Hindura ikibazo' : 'Ikibazo gishya'}</h2></div>{questionForm.id && <button type="button" className="text-button" onClick={() => openQuestion()}>Gishya</button>}</div><label>Ikibazo<textarea required rows={3} value={questionForm.prompt} onChange={e => setQuestionForm({ ...questionForm, prompt: e.target.value })} /></label><label>Icyiciro<select required value={questionForm.category_id} onChange={e => setQuestionForm({ ...questionForm, category_id: e.target.value })}><option value="">Hitamo icyiciro</option>{categories.map(c => <option key={c.id} value={c.id}>{c.title}</option>)}</select></label><div className="field-title">Ibisubizo - hitamo igisubizo nyacyo</div>{questionForm.options.map((option, i) => <div className="option-field" key={i}><input aria-label={`Igisubizo ${i + 1}`} required value={option} onChange={e => { const options = [...questionForm.options]; options[i] = e.target.value; setQuestionForm({ ...questionForm, options }); }} /><label className="radio-label"><input type="radio" name="correct" checked={questionForm.correct === i} onChange={() => setQuestionForm({ ...questionForm, correct: i })} /> Nyacyo</label></div>)}<label>Ibisobanuro by’igisubizo<textarea rows={2} value={questionForm.explanation} onChange={e => setQuestionForm({ ...questionForm, explanation: e.target.value })} /></label><div className="two-fields"><label>Ubwoko bw’icyapa<input placeholder="urugero: danger" value={questionForm.sign_type} onChange={e => setQuestionForm({ ...questionForm, sign_type: e.target.value })} /></label><label>Agaciro/inyandiko<input placeholder="urugero: 10%" value={questionForm.sign_label} onChange={e => setQuestionForm({ ...questionForm, sign_label: e.target.value })} /></label></div><label>Ifoto y’icyapa<input type="file" accept="image/*" onChange={async e => { try { const path = await uploadImage(e); if (path) setQuestionForm(f => ({ ...f, image_path: path })); } catch (error) { sayError(error); } }} /></label>{questionForm.image_path && <div className="image-preview"><img src={imageUrl(questionForm.image_path)!} alt="Ifoto y’icyapa" /><button type="button" className="text-button" onClick={() => setQuestionForm({ ...questionForm, image_path: '' })}>Kuraho ifoto</button></div>}<label className="check-row"><input type="checkbox" checked={questionForm.is_exam_question} onChange={e => setQuestionForm({ ...questionForm, is_exam_question: e.target.checked })} /> Iki kibazo gishobora kujya mu kizamini</label><label className="check-row"><input type="checkbox" checked={questionForm.published} onChange={e => setQuestionForm({ ...questionForm, published: e.target.checked })} /> Tangaza ako kanya</label><button className="primary full" disabled={busy}>{busy ? 'Birabikwa...' : 'Bika ikibazo'}</button></form></div></>}

      {view === 'lessons' && <><div className="toolbar"><input className="search" placeholder="Shakisha isomo cyangwa icyiciro..." value={search} onChange={e => setSearch(e.target.value)} /><button className="primary" onClick={() => openLesson()}>+ Isomo rishya</button></div><div className="content-grid"><div className="list-card"><div className="list-head"><b>{filteredLessons.length} masomo</b><span>{busy ? 'Biravugururwa...' : 'Bivuye muri Supabase'}</span></div>{filteredLessons.map(l => <article className="content-row" key={l.id}><div className="row-image lesson-icon">L</div><div className="row-main"><b>{l.title}</b><small>{categories.find(c => c.id === l.category_id)?.title ?? l.category_id} - {l.lesson_sections?.length ?? 0} bice - {l.minutes} min</small><span className={`pill ${l.published ? 'published' : ''}`}>{l.published ? 'Byatangajwe' : 'Draft'}</span></div><div className="row-actions"><button onClick={() => void togglePublished('lessons', l)}>{l.published ? 'Hisha' : 'Tangaza'}</button><button onClick={() => openLesson(l)}>Hindura</button><button className="danger-text" onClick={() => void removeLesson(l.id)}>Siba</button></div></article>)}{filteredLessons.length === 0 && <Empty text="Nta somo ririmo. Kanda 'Isomo rishya' utangire." />}</div>
        <form className="editor-card" onSubmit={saveLesson}><div className="editor-title"><div><p className="eyebrow">UMWANDITSI W’AMASOMO</p><h2>{lessonForm.id ? 'Hindura isomo' : 'Isomo rishya'}</h2></div>{lessonForm.id && <button type="button" className="text-button" onClick={() => openLesson()}>Gishya</button>}</div><label>Umutwe w’isomo<input required value={lessonForm.title} onChange={e => setLessonForm({ ...lessonForm, title: e.target.value })} /></label><div className="two-fields"><label>Icyiciro<select required value={lessonForm.category_id} onChange={e => setLessonForm({ ...lessonForm, category_id: e.target.value })}><option value="">Hitamo icyiciro</option>{categories.map(c => <option key={c.id} value={c.id}>{c.title}</option>)}</select></label><label>Igihe (iminota)<input type="number" min={1} required value={lessonForm.minutes} onChange={e => setLessonForm({ ...lessonForm, minutes: Number(e.target.value) })} /></label></div>{lessonForm.sections.map((section, i) => <fieldset className="section-field" key={i}><legend>Igice {i + 1}</legend><label>Umutwe<input required value={section.heading} onChange={e => { const sections = [...lessonForm.sections]; sections[i] = { ...section, heading: e.target.value }; setLessonForm({ ...lessonForm, sections }); }} /></label><label>Ibisobanuro<textarea required rows={4} value={section.body} onChange={e => { const sections = [...lessonForm.sections]; sections[i] = { ...section, body: e.target.value }; setLessonForm({ ...lessonForm, sections }); }} /></label><div className="two-fields"><label>Ubwoko bw’icyapa<input placeholder="urugero: stop" value={section.sign_type ?? ''} onChange={e => { const sections = [...lessonForm.sections]; sections[i] = { ...section, sign_type: e.target.value }; setLessonForm({ ...lessonForm, sections }); }} /></label><label>Agaciro/inyandiko<input value={section.sign_label ?? ''} onChange={e => { const sections = [...lessonForm.sections]; sections[i] = { ...section, sign_label: e.target.value }; setLessonForm({ ...lessonForm, sections }); }} /></label></div><label>Ifoto y’icyapa<input type="file" accept="image/*" onChange={async e => { try { const path = await uploadImage(e); if (path) { const sections = [...lessonForm.sections]; sections[i] = { ...section, image_path: path }; setLessonForm({ ...lessonForm, sections }); } } catch (error) { sayError(error); } }} /></label>{section.image_path && <div className="image-preview"><img src={imageUrl(section.image_path)!} alt="Ifoto" /><button type="button" className="text-button" onClick={() => { const sections = [...lessonForm.sections]; sections[i] = { ...section, image_path: '' }; setLessonForm({ ...lessonForm, sections }); }}>Kuraho ifoto</button></div>}{lessonForm.sections.length > 1 && <button type="button" className="danger-text" onClick={() => setLessonForm({ ...lessonForm, sections: lessonForm.sections.filter((_, n) => n !== i) })}>Kuraho iki gice</button>}</fieldset>)}<button type="button" className="secondary full" onClick={() => setLessonForm({ ...lessonForm, sections: [...lessonForm.sections, { heading: '', body: '', sign_type: '', sign_label: '', image_path: '' }] })}>+ Ongeramo ikindi gice</button><label className="check-row"><input type="checkbox" checked={lessonForm.is_extra} onChange={e => setLessonForm({ ...lessonForm, is_extra: e.target.checked })} /> Isomo ry’inyongera</label><label className="check-row"><input type="checkbox" checked={lessonForm.published} onChange={e => setLessonForm({ ...lessonForm, published: e.target.checked })} /> Tangaza ako kanya</label><button className="primary full" disabled={busy}>{busy ? 'Birabikwa...' : 'Bika isomo'}</button></form></div></>}

      {view === 'categories' && <><div className="toolbar"><div className="toolbar-hint">Ibyiciro bihuzwa n'ibibazo n'amasomo. Icyiciro gishya kibanza kuba draft.</div></div><div className="category-layout"><form className="editor-card" onSubmit={saveCategory}><p className="eyebrow">{categories.some(c => c.id === categoryForm.id) ? 'HINDURA ICYICIRO' : 'ICYICIRO GISHYA'}</p><h2>{categories.some(c => c.id === categoryForm.id) ? 'Hindura icyiciro' : 'Ongeramo icyiciro'}</h2><label>Izina rigufi / ID<input required pattern="[A-Za-z0-9-]+" placeholder="urugero: ibimenyetso" value={categoryForm.id} readOnly={categories.some(c => c.id === categoryForm.id)} onChange={e => setCategoryForm({ ...categoryForm, id: e.target.value })} /></label><label>Izina rigaragara<input required value={categoryForm.title} onChange={e => setCategoryForm({ ...categoryForm, title: e.target.value })} /></label><label>Ibisobanuro bigufi<input value={categoryForm.subtitle} onChange={e => setCategoryForm({ ...categoryForm, subtitle: e.target.value })} /></label><button className="primary full" disabled={busy}>Bika icyiciro</button>{categoryForm.id && <button type="button" className="secondary full" onClick={() => setCategoryForm({ id: '', title: '', subtitle: '' })}>Reka guhindura</button>}</form><div className="category-grid">{categories.map(c => <article className="category-card" key={c.id}><div className="category-symbol">O</div><h3>{c.title}</h3><p>{c.subtitle}</p><small>{c.id}</small><div className="category-meta"><span className={`pill ${c.published ? 'published' : ''}`}>{c.published ? 'Byatangajwe' : 'Draft'}</span><button onClick={() => void togglePublished('content_categories', c)}>{c.published ? 'Hisha' : 'Tangaza'}</button></div><div className="category-meta"><button onClick={() => setCategoryForm({ id: c.id, title: c.title, subtitle: c.subtitle })}>Hindura</button></div><small>{questions.filter(q => q.category_id === c.id).length} bibazo - {lessons.filter(l => l.category_id === c.id).length} masomo</small></article>)}</div></div></>}
    </section>
  </main>;
}

function Brand() { return <div className="brand"><span className="brand-mark">A</span><span><b>AMATEGEKO</b><small>ADMIN CONSOLE</small></span></div>; }
function Stat({ label, value, detail, icon }: { label: string; value: number; detail: string; icon: string }) { return <article className="stat-card"><span className="stat-icon">{icon}</span><span className="stat-label">{label}</span><strong>{value}</strong><small>{detail}</small></article>; }
function Quick({ title, text, onClick }: { title: string; text: string; onClick: () => void }) { return <button className="quick-card" onClick={onClick}><span className="quick-arrow">+</span><h3>{title}</h3><p>{text}</p></button>; }
function Empty({ text }: { text: string }) { return <div className="empty"><span>+</span><p>{text}</p></div>; }
