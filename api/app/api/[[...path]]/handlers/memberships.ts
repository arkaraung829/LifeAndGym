import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseBody } from '@/lib/utils/validation';
import { NotFoundError, DatabaseError, ValidationError } from '@/lib/utils/errors';

const checkInSchema = z.object({
  gymId: z.string().uuid('Invalid gym ID'),
});

function getRoute(subpath: string[]): string {
  return subpath.join('/');
}

export async function handleGet(request: NextRequest, subpath: string[]) {
  try {
    const route = getRoute(subpath);

    switch (route) {
      case '':
        return await handleListMemberships(request);
      case 'active':
        return await handleGetActiveMembership(request);
      case 'current-check-in':
        return await handleGetCurrentCheckIn(request);
      case 'check-in-history':
        return await handleGetCheckInHistory(request);
      case 'check-in-stats':
        return await handleGetCheckInStats(request);
      default:
        return errorResponse(new NotFoundError('Endpoint'), request);
    }
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Handler failed'), request);
  }
}

export async function handlePost(request: NextRequest, subpath: string[]) {
  try {
    const route = getRoute(subpath);

    switch (route) {
      case 'check-in':
        return await handleCheckIn(request);
      case 'check-out':
        return await handleCheckOut(request);
      default:
        return errorResponse(new NotFoundError('Endpoint'), request);
    }
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Handler failed'), request);
  }
}

async function handleListMemberships(request: NextRequest) {
  const { user } = await verifyAuth(request);

  const { data: memberships, error } = await supabaseAdmin
    .from(Tables.memberships)
    .select(`*, gym:${Tables.gyms}(*)`)
    .eq('user_id', user.id)
    .order('created_at', { ascending: false });

  if (error) throw new DatabaseError('Failed to fetch memberships');
  return successResponse({ memberships }, request);
}

async function handleGetActiveMembership(request: NextRequest) {
  const { user } = await verifyAuth(request);

  const { data: membership, error } = await supabaseAdmin
    .from(Tables.memberships)
    .select(`*, gym:${Tables.gyms}(*)`)
    .eq('user_id', user.id)
    .eq('status', 'active')
    .single();

  if (error) {
    if (error.code === 'PGRST116') {
      return successResponse({ membership: null }, request);
    }
    throw new DatabaseError('Failed to fetch active membership');
  }

  return successResponse({ membership }, request);
}

async function handleCheckIn(request: NextRequest) {
  const { user } = await verifyAuth(request);
  const body = await parseBody(request, checkInSchema);

  const { data: membership, error: membershipError } = await supabaseAdmin
    .from(Tables.memberships)
    .select('*')
    .eq('user_id', user.id)
    .eq('status', 'active')
    .single();

  if (membershipError || !membership) {
    throw new ValidationError('No active membership found');
  }

  if (!membership.access_all_locations && membership.gym_id !== body.gymId) {
    throw new ValidationError('You do not have access to this gym');
  }

  const { data: existingCheckIn } = await supabaseAdmin
    .from(Tables.checkIns)
    .select('*')
    .eq('user_id', user.id)
    .is('checked_out_at', null)
    .single();

  if (existingCheckIn) {
    throw new ValidationError('You are already checked in');
  }

  const { data: checkIn, error } = await supabaseAdmin
    .from(Tables.checkIns)
    .insert({
      user_id: user.id,
      gym_id: body.gymId,
      membership_id: membership.id,
      checked_in_at: new Date().toISOString(),
    })
    .select(`*, gym:${Tables.gyms}(*)`)
    .single();

  if (error) throw new DatabaseError('Failed to check in');
  return successResponse({ checkIn }, request, { status: 201 });
}

async function handleCheckOut(request: NextRequest) {
  const { user } = await verifyAuth(request);

  const { data: checkIn, error: findError } = await supabaseAdmin
    .from(Tables.checkIns)
    .select('*')
    .eq('user_id', user.id)
    .is('checked_out_at', null)
    .single();

  if (findError || !checkIn) {
    throw new ValidationError('No active check-in found');
  }

  const checkedOutAt = new Date();
  const checkedInAt = new Date(checkIn.checked_in_at);
  const durationMinutes = Math.round((checkedOutAt.getTime() - checkedInAt.getTime()) / 60000);

  const { data: updatedCheckIn, error } = await supabaseAdmin
    .from(Tables.checkIns)
    .update({
      checked_out_at: checkedOutAt.toISOString(),
      duration_minutes: durationMinutes,
    })
    .eq('id', checkIn.id)
    .select(`*, gym:${Tables.gyms}(*)`)
    .single();

  if (error) throw new DatabaseError('Failed to check out');
  return successResponse({ checkIn: updatedCheckIn }, request);
}

async function handleGetCurrentCheckIn(request: NextRequest) {
  const { user } = await verifyAuth(request);

  const { data: checkIn, error } = await supabaseAdmin
    .from(Tables.checkIns)
    .select(`*, gym:${Tables.gyms}(*)`)
    .eq('user_id', user.id)
    .is('checked_out_at', null)
    .single();

  if (error) {
    if (error.code === 'PGRST116') {
      return successResponse({ checkIn: null }, request);
    }
    throw new DatabaseError('Failed to fetch current check-in');
  }

  return successResponse({ checkIn }, request);
}

async function handleGetCheckInHistory(request: NextRequest) {
  const { user } = await verifyAuth(request);
  const searchParams = request.nextUrl.searchParams;
  const limit = parseInt(searchParams.get('limit') || '20');
  const offset = parseInt(searchParams.get('offset') || '0');

  const { data: checkIns, error, count } = await supabaseAdmin
    .from(Tables.checkIns)
    .select(`*, gym:${Tables.gyms}(*)`, { count: 'exact' })
    .eq('user_id', user.id)
    .not('checked_out_at', 'is', null)
    .order('checked_in_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) throw new DatabaseError('Failed to fetch check-in history');
  return successResponse({ checkIns, total: count }, request);
}

async function handleGetCheckInStats(request: NextRequest) {
  const { user } = await verifyAuth(request);

  const { data: checkIns, error } = await supabaseAdmin
    .from(Tables.checkIns)
    .select('duration_minutes, checked_in_at')
    .eq('user_id', user.id)
    .not('checked_out_at', 'is', null);

  if (error) throw new DatabaseError('Failed to fetch check-in stats');

  const totalVisits = checkIns?.length || 0;
  const totalMinutes = checkIns?.reduce((sum, c) => sum + (c.duration_minutes || 0), 0) || 0;
  const avgDuration = totalVisits > 0 ? Math.round(totalMinutes / totalVisits) : 0;

  const weekAgo = new Date();
  weekAgo.setDate(weekAgo.getDate() - 7);
  const visitsThisWeek = checkIns?.filter(c => new Date(c.checked_in_at) >= weekAgo).length || 0;

  const monthAgo = new Date();
  monthAgo.setMonth(monthAgo.getMonth() - 1);
  const visitsThisMonth = checkIns?.filter(c => new Date(c.checked_in_at) >= monthAgo).length || 0;

  return successResponse({
    stats: {
      totalVisits,
      totalMinutes,
      averageDurationMinutes: avgDuration,
      visitsThisWeek,
      visitsThisMonth,
    },
  }, request);
}
