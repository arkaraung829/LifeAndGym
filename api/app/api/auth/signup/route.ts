import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseBody } from '@/lib/utils/validation';
import { ValidationError, ConflictError, DatabaseError } from '@/lib/utils/errors';

const signupSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  fullName: z.string().min(2, 'Full name is required'),
});

export async function POST(request: NextRequest) {
  try {
    const body = await parseBody(request, signupSchema);

    // Create auth user with Supabase
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email: body.email,
      password: body.password,
      email_confirm: true, // Auto-confirm for API signups
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

    // Create user profile in users table
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
      // Cleanup: delete auth user if profile creation fails
      await supabaseAdmin.auth.admin.deleteUser(userId);
      throw new DatabaseError('Failed to create user profile');
    }

    return successResponse(
      {
        user: profile,
        message: 'Account created successfully',
      },
      request,
      { status: 201 }
    );
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Signup failed'), request);
  }
}
