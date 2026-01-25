import { z } from 'zod';
import { ValidationError } from './errors';

// Parse and validate request body with Zod schema
export async function parseBody<T extends z.ZodSchema>(
  request: Request,
  schema: T
): Promise<z.infer<T>> {
  let body: unknown;

  try {
    body = await request.json();
  } catch {
    throw new ValidationError('Invalid JSON body');
  }

  const result = schema.safeParse(body);

  if (!result.success) {
    const errors = result.error.flatten();
    throw new ValidationError('Validation failed', {
      fieldErrors: errors.fieldErrors,
      formErrors: errors.formErrors,
    });
  }

  return result.data;
}

// Parse query parameters
export function parseQuery<T extends z.ZodSchema>(
  searchParams: URLSearchParams,
  schema: T
): z.infer<T> {
  const params: Record<string, string | string[]> = {};

  searchParams.forEach((value, key) => {
    if (params[key]) {
      // Handle multiple values for same key
      if (Array.isArray(params[key])) {
        (params[key] as string[]).push(value);
      } else {
        params[key] = [params[key] as string, value];
      }
    } else {
      params[key] = value;
    }
  });

  const result = schema.safeParse(params);

  if (!result.success) {
    const errors = result.error.flatten();
    throw new ValidationError('Invalid query parameters', {
      fieldErrors: errors.fieldErrors,
    });
  }

  return result.data;
}

// Common validation schemas
export const paginationSchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

export const uuidSchema = z.string().uuid();

export const dateRangeSchema = z.object({
  startDate: z.coerce.date(),
  endDate: z.coerce.date(),
});
