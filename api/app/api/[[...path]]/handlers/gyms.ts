import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseQuery } from '@/lib/utils/validation';
import { NotFoundError, DatabaseError } from '@/lib/utils/errors';
import type { Gym } from '@/lib/supabase/types';

const searchSchema = z.object({
  q: z.string().min(1, 'Search query is required'),
  city: z.string().optional(),
});

const nearbySchema = z.object({
  lat: z.coerce.number().min(-90).max(90),
  lng: z.coerce.number().min(-180).max(180),
  radius: z.coerce.number().positive().default(10),
});

function getRoute(subpath: string[]): string {
  return subpath.join('/');
}

export async function handleGet(request: NextRequest, subpath: string[]) {
  try {
    const route = getRoute(subpath);

    if (route === 'search') {
      return await handleSearch(request);
    }
    if (route === 'nearby') {
      return await handleNearby(request);
    }
    if (route === '') {
      return await handleListGyms(request);
    }
    // Assume it's a gym ID
    return await handleGetGym(request, route);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Handler failed'), request);
  }
}

async function handleListGyms(request: NextRequest) {
  const { data: gyms, error } = await supabaseAdmin
    .from(Tables.gyms)
    .select('*')
    .eq('is_active', true)
    .order('name');

  if (error) throw new DatabaseError('Failed to fetch gyms');
  return successResponse({ gyms }, request);
}

async function handleGetGym(request: NextRequest, gymId: string) {
  const { data: gym, error } = await supabaseAdmin
    .from(Tables.gyms)
    .select('*')
    .eq('id', gymId)
    .single();

  if (error) {
    if (error.code === 'PGRST116') throw new NotFoundError('Gym');
    throw new DatabaseError('Failed to fetch gym');
  }

  return successResponse({ gym }, request);
}

async function handleSearch(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const query = parseQuery(searchParams, searchSchema);

  let dbQuery = supabaseAdmin
    .from(Tables.gyms)
    .select('*')
    .eq('is_active', true)
    .or(`name.ilike.%${query.q}%,city.ilike.%${query.q}%,address.ilike.%${query.q}%`);

  if (query.city) {
    dbQuery = dbQuery.eq('city', query.city);
  }

  const { data: gyms, error } = await dbQuery.order('name');

  if (error) throw new DatabaseError('Failed to search gyms');
  return successResponse({ gyms, query: query.q }, request);
}

async function handleNearby(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const query = parseQuery(searchParams, nearbySchema);

  const { data: allGyms, error } = await supabaseAdmin
    .from(Tables.gyms)
    .select('*')
    .eq('is_active', true);

  if (error) throw new DatabaseError('Failed to fetch gyms');

  const gymsWithDistance = (allGyms as Gym[])
    .filter((gym) => gym.latitude !== null && gym.longitude !== null)
    .map((gym) => ({
      ...gym,
      distance: calculateDistance(query.lat, query.lng, gym.latitude!, gym.longitude!),
    }))
    .filter((gym) => gym.distance <= query.radius)
    .sort((a, b) => a.distance - b.distance);

  return successResponse({ gyms: gymsWithDistance, center: { lat: query.lat, lng: query.lng }, radiusKm: query.radius }, request);
}

function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const earthRadiusKm = 6371;
  const dLat = (lat2 - lat1) * (Math.PI / 180);
  const dLon = (lon2 - lon1) * (Math.PI / 180);
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * (Math.PI / 180)) * Math.cos(lat2 * (Math.PI / 180)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return Math.round(earthRadiusKm * c * 100) / 100;
}
