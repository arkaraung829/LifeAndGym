import { NextRequest, NextResponse } from 'next/server';
import { ApiError } from './errors';
import { getCorsHeaders } from '@/lib/middleware/cors';

// Standard success response
export interface SuccessResponse<T> {
  success: true;
  data: T;
  meta?: {
    page?: number;
    limit?: number;
    total?: number;
    hasMore?: boolean;
  };
}

// Standard error response
export interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: Record<string, unknown>;
  };
}

// Create a success response
export function successResponse<T>(
  data: T,
  request: NextRequest,
  options?: {
    status?: number;
    meta?: SuccessResponse<T>['meta'];
  }
): NextResponse<SuccessResponse<T>> {
  const body: SuccessResponse<T> = {
    success: true,
    data,
  };

  if (options?.meta) {
    body.meta = options.meta;
  }

  return NextResponse.json(body, {
    status: options?.status ?? 200,
    headers: getCorsHeaders(request),
  });
}

// Create an error response
export function errorResponse(
  error: ApiError | Error,
  request: NextRequest
): NextResponse<ErrorResponse> {
  const isApiError = error instanceof ApiError;

  const body: ErrorResponse = {
    success: false,
    error: {
      code: isApiError ? error.code : 'INTERNAL_ERROR',
      message: error.message,
      details: isApiError ? error.details : undefined,
    },
  };

  const status = isApiError ? error.statusCode : 500;

  // Log server errors
  if (status >= 500) {
    console.error('API Error:', error);
  }

  return NextResponse.json(body, {
    status,
    headers: getCorsHeaders(request),
  });
}

// Wrapper for API route handlers with error handling
export function withErrorHandler<T>(
  handler: (request: NextRequest, context?: { params: Record<string, string> }) => Promise<NextResponse<T>>
) {
  return async (
    request: NextRequest,
    context?: { params: Record<string, string> }
  ): Promise<NextResponse> => {
    try {
      return await handler(request, context);
    } catch (error) {
      return errorResponse(error instanceof Error ? error : new Error('Unknown error'), request);
    }
  };
}
