import { createClient } from '@supabase/supabase-js';
import { NextRequest, NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

async function getAdminContext(request: NextRequest) {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const publishableKey = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !publishableKey || !serviceRoleKey) {
    return { error: NextResponse.json({ error: 'Server setup missing. Add SUPABASE_SERVICE_ROLE_KEY to admin-dashboard/.env.local and restart the dashboard.' }, { status: 503 }) };
  }

  const token = request.headers.get('authorization')?.replace(/^Bearer\s+/i, '');
  if (!token) return { error: NextResponse.json({ error: 'Sign in required.' }, { status: 401 }) };

  const authClient = createClient(url, publishableKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: authData, error: authError } = await authClient.auth.getUser(token);
  if (authError || !authData.user) return { error: NextResponse.json({ error: 'Session expired. Sign in again.' }, { status: 401 }) };

  const membershipClient = createClient(url, publishableKey, {
    auth: { persistSession: false, autoRefreshToken: false },
    global: { headers: { Authorization: `Bearer ${token}` } },
  });
  const { data: membership, error: membershipError } = await membershipClient
    .from('admin_users').select('user_id').eq('user_id', authData.user.id).maybeSingle();
  if (membershipError || !membership) return { error: NextResponse.json({ error: 'Admin access required.' }, { status: 403 }) };

  const admin = createClient(url, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  return { admin, userId: authData.user.id };
}

export async function GET(request: NextRequest) {
  const context = await getAdminContext(request);
  if ('error' in context) return context.error;

  const page = Math.max(1, Number(request.nextUrl.searchParams.get('page')) || 1);
  const perPage = Math.min(100, Math.max(5, Number(request.nextUrl.searchParams.get('perPage')) || 10));
  const query = request.nextUrl.searchParams.get('q')?.trim().toLocaleLowerCase() ?? '';
  const status = request.nextUrl.searchParams.get('status') ?? 'all';
  let authUsers: Awaited<ReturnType<typeof context.admin.auth.admin.listUsers>>['data']['users'] = [];
  let total: number | null = null;
  let totalPages: number | null = null;
  if (!query && status === 'all') {
    const { data, error } = await context.admin.auth.admin.listUsers({ page, perPage });
    if (error) return NextResponse.json({ error: error.message }, { status: 502 });
    authUsers = data.users; total = data.total ?? null; totalPages = data.lastPage ?? null;
  } else {
    const first = await context.admin.auth.admin.listUsers({ page: 1, perPage: 100 });
    if (first.error) return NextResponse.json({ error: first.error.message }, { status: 502 });
    const allUsers = [...first.data.users];
    const last = Math.min(first.data.lastPage ?? 1, 50);
    for (let current = 2; current <= last; current += 1) {
      const next = await context.admin.auth.admin.listUsers({ page: current, perPage: 100 });
      if (next.error) return NextResponse.json({ error: next.error.message }, { status: 502 });
      allUsers.push(...next.data.users);
    }
    const filtered = allUsers.filter(user => {
      const matches = !query || `${user.email ?? ''} ${user.phone ?? ''} ${user.id}`.toLocaleLowerCase().includes(query);
      const suspended = Boolean(user.banned_until && new Date(user.banned_until) > new Date());
      return matches && (status === 'all' || (status === 'suspended' ? suspended : !suspended));
    });
    total = filtered.length;
    totalPages = Math.max(1, Math.ceil(filtered.length / perPage));
    authUsers = filtered.slice((page - 1) * perPage, page * perPage);
  }

  const userIds = authUsers.map(user => user.id);
  const { data: progressRows, error: progressError } = userIds.length
    ? await context.admin.from('user_progress').select('user_id, progress, updated_at').in('user_id', userIds)
    : { data: [], error: null };
  if (progressError) return NextResponse.json({ error: progressError.message }, { status: 502 });
  const progressByUser = new Map((progressRows ?? []).map(row => [row.user_id, row]));

  const users = authUsers.map(user => {
    const progress = progressByUser.get(user.id);
    const completed = progress?.progress && Array.isArray(progress.progress.completedLessons)
      ? progress.progress.completedLessons.length : 0;
    return {
      id: user.id,
      email: user.email ?? null,
      phone: user.phone ?? null,
      createdAt: user.created_at,
      lastSignInAt: user.last_sign_in_at ?? null,
      bannedUntil: user.banned_until ?? null,
      isAdmin: false,
      progressUpdatedAt: progress?.updated_at ?? null,
      completedLessons: completed,
      hasProgress: Boolean(progress),
    };
  });

  const { data: adminUsers, error: adminsError } = await context.admin.from('admin_users').select('user_id').in('user_id', userIds);
  if (adminsError) return NextResponse.json({ error: adminsError.message }, { status: 502 });
  const adminIds = new Set((adminUsers ?? []).map(row => row.user_id));
  for (const user of users) user.isAdmin = adminIds.has(user.id);

  return NextResponse.json({ users, page, perPage, total, totalPages });
}

export async function PATCH(request: NextRequest) {
  const context = await getAdminContext(request);
  if ('error' in context) return context.error;

  let body: { userId?: string; action?: string };
  try { body = await request.json(); }
  catch { return NextResponse.json({ error: 'Invalid request body.' }, { status: 400 }); }
  if (!body.userId || !['suspend', 'restore'].includes(body.action ?? '')) {
    return NextResponse.json({ error: 'A user ID and valid action are required.' }, { status: 400 });
  }
  if (body.userId === context.userId) return NextResponse.json({ error: 'You cannot change your own account here.' }, { status: 400 });

  const { data: targetAdmin, error: targetError } = await context.admin
    .from('admin_users').select('user_id').eq('user_id', body.userId).maybeSingle();
  if (targetError) return NextResponse.json({ error: targetError.message }, { status: 502 });
  if (targetAdmin) return NextResponse.json({ error: 'Admin accounts cannot be suspended from this screen.' }, { status: 403 });

  const { error } = await context.admin.auth.admin.updateUserById(body.userId, {
    ban_duration: body.action === 'suspend' ? '876000h' : 'none',
  });
  if (error) return NextResponse.json({ error: error.message }, { status: 502 });
  return NextResponse.json({ success: true });
}
