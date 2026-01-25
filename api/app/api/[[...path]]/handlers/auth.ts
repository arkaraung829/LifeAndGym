import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseBody } from '@/lib/utils/validation';
import { ValidationError, ConflictError, DatabaseError, NotFoundError } from '@/lib/utils/errors';

const signupSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  fullName: z.string().min(2, 'Full name is required'),
});

const updateProfileSchema = z.object({
  fullName: z.string().min(2).optional(),
  phone: z.string().optional(),
  gender: z.enum(['male', 'female', 'other']).optional(),
  dateOfBirth: z.string().optional(),
  heightCm: z.number().positive().optional(),
  avatarUrl: z.string().url().optional(),
}).partial();

const onboardingSchema = z.object({
  fitnessLevel: z.enum(['beginner', 'intermediate', 'advanced']),
  fitnessGoals: z.array(z.string()).min(1, 'Select at least one goal'),
  gender: z.enum(['male', 'female', 'other']).optional(),
  heightCm: z.number().positive().optional(),
  dateOfBirth: z.string().optional(),
});

function getRoute(subpath: string[]): string {
  return subpath.join('/');
}

export async function handleGet(request: NextRequest, subpath: string[]) {
  const route = getRoute(subpath);

  switch (route) {
    case 'me':
    case 'profile':
      return handleGetProfile(request);
    default:
      return errorResponse(new NotFoundError('Endpoint'), request);
  }
}

export async function handlePost(request: NextRequest, subpath: string[]) {
  const route = getRoute(subpath);

  switch (route) {
    case 'signup':
      return handleSignup(request);
    case 'onboarding':
      return handleOnboarding(request);
    default:
      return errorResponse(new NotFoundError('Endpoint'), request);
  }
}

export async function handlePatch(request: NextRequest, subpath: string[]) {
  const route = getRoute(subpath);

  switch (route) {
    case 'profile':
      return handleUpdateProfile(request);
    default:
      return errorResponse(new NotFoundError('Endpoint'), request);
  }
}

async function handleSignup(request: NextRequest) {
  const body = await parseBody(request, signupSchema);

  const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
    email: body.email,
    password: body.password,
    email_confirm: true,
    user_metadata: { full_name: body.fullName },
  });

  if (authError) {
    if (authError.message.includes('already') || authError.message.includes('exists')) {
      throw new ConflictError('Email already in use');
    }
    throw new ValidationError(authError.message);
  }

  if (!authData.user) {
    throw new DatabaseError('Failed to create user');
  }

  const userId = authData.user.id;
  const now = new Date().toISOString();

  const { data: profile, error: profileError } = await supabaseAdmin
    .from(Tables.users)
    .insert({
      id: userId,
      email: body.email,
      full_name: body.fullName,
      created_at: now,
      updated_at: now,
    })
    .select()
    .single();

  if (profileError) {
    await supabaseAdmin.auth.admin.deleteUser(userId);
    throw new DatabaseError('Failed to create user profile');
  }

  return successResponse({ user: profile, message: 'Account created successfully' }, request, { status: 201 });
}

async function handleGetProfile(request: NextRequest) {
  const { user } = await verifyAuth(request);

  const { data: profile, error } = await supabaseAdmin
    .from(Tables.users)
    .select('*')
    .eq('id', user.id)
    .single();

  if (error) {
    if (error.code === 'PGRST116') {
      const { data: authData } = await supabaseAdmin.auth.admin.getUserById(user.id);
      const fullName = authData?.user?.user_metadata?.full_name || authData?.user?.user_metadata?.name || user.email.split('@')[0];
      const avatarUrl = authData?.user?.user_metadata?.avatar_url || authData?.user?.user_metadata?.picture;
      const now = new Date().toISOString();

      const { data: newProfile, error: createError } = await supabaseAdmin
        .from(Tables.users)
        .insert({ id: user.id, email: user.email, full_name: fullName, avatar_url: avatarUrl, created_at: now, updated_at: now })
        .select()
        .single();

      if (createError) throw new DatabaseError('Failed to create user profile');
      return successResponse({ user: newProfile }, request, { status: 201 });
    }
    throw new DatabaseError('Failed to fetch user profile');
  }

  return successResponse({ user: profile }, request);
}

async function handleUpdateProfile(request: NextRequest) {
  const { user } = await verifyAuth(request);
  const body = await parseBody(request, updateProfileSchema);

  const updates: Record<string, unknown> = { updated_at: new Date().toISOString() };
  if (body.fullName !== undefined) updates.full_name = body.fullName;
  if (body.phone !== undefined) updates.phone = body.phone;
  if (body.gender !== undefined) updates.gender = body.gender;
  if (body.dateOfBirth !== undefined) updates.date_of_birth = body.dateOfBirth;
  if (body.heightCm !== undefined) updates.height_cm = body.heightCm;
  if (body.avatarUrl !== undefined) updates.avatar_url = body.avatarUrl;

  const { data: profile, error } = await supabaseAdmin
    .from(Tables.users)
    .update(updates)
    .eq('id', user.id)
    .select()
    .single();

  if (error) throw new DatabaseError('Failed to update profile');
  return successResponse({ user: profile }, request);
}

async function handleOnboarding(request: NextRequest) {
  const { user } = await verifyAuth(request);
  const body = await parseBody(request, onboardingSchema);

  const updates = {
    fitness_level: body.fitnessLevel,
    fitness_goals: body.fitnessGoals,
    gender: body.gender,
    height_cm: body.heightCm,
    date_of_birth: body.dateOfBirth,
    onboarding_completed: true,
    updated_at: new Date().toISOString(),
  };

  const { data: profile, error } = await supabaseAdmin
    .from(Tables.users)
    .update(updates)
    .eq('id', user.id)
    .select()
    .single();

  if (error) throw new DatabaseError('Failed to complete onboarding');
  return successResponse({ user: profile, message: 'Onboarding completed successfully' }, request);
}
