import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseQuery } from '@/lib/utils/validation';
import { DatabaseError } from '@/lib/utils/errors';
import type { Gym } from '@/lib/supabase/types';

const nearbySchema = z.object({
  lat: z.coerce.number().min(-90).max(90),
  lng: z.coerce.number().min(-180).max(180),
  radius: z.coerce.number().positive().default(10), // km
});

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const query = parseQuery(searchParams, nearbySchema);

    // Fetch all active gyms (for now - in production use PostGIS)
    const { data: allGyms, error } = await supabaseAdmin
      .from(Tables.gyms)
      .select('*')
      .eq('is_active', true);

    if (error) {
      throw new DatabaseError('Failed to fetch gyms');
    }

    // Filter and sort by distance
    const gymsWithDistance = (allGyms as Gym[])
      .filter((gym) => gym.latitude !== null && gym.longitude !== null)
      .map((gym) => ({
        ...gym,
        distance: calculateDistance(
          query.lat,
          query.lng,
          gym.latitude!,
          gym.longitude!
        ),
      }))
      .filter((gym) => gym.distance <= query.radius)
      .sort((a, b) => a.distance - b.distance);

    return successResponse(
      {
        gyms: gymsWithDistance,
        center: { lat: query.lat, lng: query.lng },
        radiusKm: query.radius,
      },
      request
    );
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to find nearby gyms'), request);
  }
}

// Haversine formula for distance calculation
function calculateDistance(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const earthRadiusKm = 6371;

  const dLat = degreesToRadians(lat2 - lat1);
  const dLon = degreesToRadians(lon2 - lon1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(degreesToRadians(lat1)) *
      Math.cos(degreesToRadians(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return Math.round(earthRadiusKm * c * 100) / 100; // Round to 2 decimal places
}

function degreesToRadians(degrees: number): number {
  return degrees * (Math.PI / 180);
}
