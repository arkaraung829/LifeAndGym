# Life and Gym - Architecture & Security Review

**Review Date:** January 27, 2026
**Reviewer:** Architecture & Security Audit
**Application:** Life and Gym Mobile App (Flutter + Next.js API)

---

## Executive Summary

This document provides a comprehensive architecture and security review of the Life and Gym application. The review identifies current strengths, security vulnerabilities, and recommended improvements based on industry best practices.

**Overall Assessment:** The application has a solid architectural foundation with good separation of concerns, but has **CRITICAL** and **HIGH** severity security issues that should be addressed before production deployment.

---

## Table of Contents

1. [Current Architecture Overview](#current-architecture-overview)
2. [Architecture Strengths](#architecture-strengths)
3. [Security Vulnerabilities](#security-vulnerabilities)
4. [Recommended Improvements](#recommended-improvements)
5. [Implementation Priority](#implementation-priority)

---

## Current Architecture Overview

### Tech Stack
- **Mobile Frontend:** Flutter (Dart) with Provider state management
- **Backend API:** Next.js (TypeScript) deployed on Vercel
- **Database/Auth:** Supabase (PostgreSQL + Auth)
- **Navigation:** GoRouter for declarative routing

### Project Structure
```
lib/
├── core/                    # Cross-cutting concerns
│   ├── config/              # Configuration (Supabase, API, App, Theme)
│   ├── exceptions/          # Custom exception hierarchy
│   ├── services/            # Base services (API, Cache, Logger)
│   ├── router/              # Navigation configuration
│   └── utils/               # Validation utilities
├── features/                # Feature modules (auth, workouts, classes, etc.)
├── shared/widgets/          # Reusable UI components
└── l10n/                    # Localization

api/
├── app/api/[[...path]]/     # Dynamic API routes
│   └── handlers/            # Domain handlers
└── lib/
    ├── middleware/          # Auth, CORS
    └── utils/               # Validation, errors
```

---

## Architecture Strengths

### 1. Clean Separation of Concerns
- Feature-based architecture with self-contained modules
- Clear layered structure: Presentation → State → Services → Data

### 2. Type Safety
- Strongly typed throughout (Dart + TypeScript)
- Models use proper JSON parsing with type safety

### 3. Error Handling
- Comprehensive exception hierarchy (`AppException` → `NetworkException`, `AuthException`, etc.)
- User-friendly error messages via `ErrorHandlerService`
- Backend structured error responses with Zod validation

### 4. Authentication Architecture
- PKCE flow for OAuth (secure)
- Automatic token refresh with 5-minute expiry threshold
- JWT verification via Supabase admin client

### 5. Retry Logic
- Exponential backoff for transient failures
- Non-retryable error detection (4xx vs 5xx)

### 6. Caching Strategy
- TTL-based caching with automatic expiry
- Cache key namespacing for user/resource isolation

---

## Security Vulnerabilities

### CRITICAL Severity

#### 1. Hardcoded Credentials in Source Code
**File:** `lib/core/config/supabase_config.dart:30-35`

```dart
// VULNERABILITY: API keys committed to source control
return switch (AppConfig.environment) {
  'production' => 'eyJhbGciOiJIUzI1NiIs...',  // EXPOSED
  'staging' => 'eyJhbGciOiJIUzI1NiIs...',     // EXPOSED
  _ => 'eyJhbGciOiJIUzI1NiIs...',             // EXPOSED
};
```

**Risk:** API keys in source code can be extracted from compiled apps, committed to version control, and exposed in data breaches.

**Recommendation:**
- Use environment variables exclusively
- Implement key rotation procedures
- Consider using a secrets management service
- For mobile: use native secure storage for runtime configuration

---

### HIGH Severity

#### 2. Insecure CORS Configuration
**File:** `api/lib/middleware/cors.ts:20-23`

```typescript
// VULNERABILITY: Allows any origin when no Origin header present
const isAllowed = !origin || allowedOrigins.includes(origin) || origin === '*';

return {
  'Access-Control-Allow-Origin': isAllowed ? (origin || '*') : '',
  // ...
};
```

**Risk:** Mobile apps don't send Origin headers, but this also allows any web-based attacker to make authenticated requests.

**Recommendation:**
```typescript
// Recommended fix
const isAllowed = !origin || allowedOrigins.includes(origin);
return {
  'Access-Control-Allow-Origin': origin && isAllowed ? origin : allowedOrigins[0],
  'Access-Control-Allow-Credentials': 'true',
};
```

#### 3. No Rate Limiting
**Impact:** API endpoints have no rate limiting protection.

**Risk:**
- Brute force attacks on authentication
- Denial of service through resource exhaustion
- Abuse of booking/membership operations

**Recommendation:**
- Implement rate limiting at API gateway level (Vercel edge functions)
- Add per-user and per-IP rate limits
- Use exponential backoff for failed auth attempts

```typescript
// Example: Vercel Edge rate limiting
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(100, '1 m'),
});
```

#### 4. Sensitive Data in Unencrypted Cache
**File:** `lib/core/services/cache_service.dart`

```dart
// SharedPreferences stores data unencrypted
await _prefs!.setString(key, jsonEncode(data));
```

**Risk:** User profile data, tokens, and other sensitive information stored in plain text on device.

**Recommendation:**
- Use `flutter_secure_storage` for sensitive data
- Encrypt cache contents with device-bound keys
- Implement secure storage abstraction:

```dart
class SecureStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
}
```

#### 5. PII Logging
**File:** `lib/features/auth/services/auth_service.dart:21,49,79`

```dart
AppLogger.auth('Signing up user: $email');
AppLogger.auth('User signed up successfully: $userId');
AppLogger.auth('Signing in user: $email');
```

**Risk:** User emails and IDs logged in debug mode could leak to crash reporters or be exposed in device logs.

**Recommendation:**
- Mask PII in all log statements
- Remove email logging entirely
- Use anonymized identifiers for debugging

```dart
AppLogger.auth('Signing up user: ${_maskEmail(email)}');

String _maskEmail(String email) {
  final parts = email.split('@');
  if (parts.length != 2) return '***';
  return '${parts[0].substring(0, min(2, parts[0].length))}***@${parts[1]}';
}
```

---

### MEDIUM Severity

#### 6. No SSL/Certificate Pinning
**Impact:** No certificate pinning implementation for mobile app.

**Risk:** Man-in-the-middle attacks on compromised networks.

**Recommendation:**
```dart
// Add certificate pinning in api_client.dart
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

final secureClient = SecureHttpClient.build([
  'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
]);
```

#### 7. Missing Input Sanitization
**Impact:** Some user inputs not sanitized before storage/display.

**Risk:** XSS via stored content (e.g., workout names, user bio).

**Recommendation:**
- Sanitize all user text inputs before storage
- Encode HTML entities when displaying user-generated content
- Add server-side content sanitization:

```typescript
import sanitizeHtml from 'sanitize-html';

const sanitized = sanitizeHtml(userInput, {
  allowedTags: [],
  allowedAttributes: {},
});
```

#### 8. No API Versioning
**Impact:** API endpoints have no version prefix.

**Risk:** Breaking changes affect all clients immediately; no migration path.

**Recommendation:**
```
Current:  /api/auth/signup
Improved: /api/v1/auth/signup
```

#### 9. Authorization Gaps in API Handlers
**Impact:** Some endpoints may not properly verify resource ownership.

**Risk:** Users could potentially access/modify other users' data.

**Recommendation:**
- Implement consistent authorization middleware
- Always verify `resource.userId === authenticatedUser.id`
- Add authorization helper:

```typescript
export function requireOwnership(resource: { userId: string }, authUser: AuthUser) {
  if (resource.userId !== authUser.id) {
    throw new ForbiddenError('You do not own this resource');
  }
}
```

---

### LOW Severity

#### 10. Debug Information in Production Builds
**File:** `lib/core/services/logger_service.dart:66`

```dart
if (!kDebugMode) return;  // Good - disabled in release
```

**Status:** ✅ Properly implemented - logs disabled in production

#### 11. Session Refresh Threshold
**File:** `lib/core/config/app_config.dart`

5-minute refresh threshold is reasonable but could be configurable.

#### 12. Error Message Exposure
Some error messages may reveal implementation details to clients.

**Recommendation:**
- Ensure production errors are generic
- Log detailed errors server-side only
- Return user-friendly messages to client

---

## Recommended Improvements

### Architecture Improvements

#### 1. Implement Repository Pattern
Add a repository layer between services and data sources for better testability and abstraction.

```dart
// Current: Service → Supabase Direct
// Improved: Service → Repository → DataSource (Supabase/Cache)

abstract class WorkoutRepository {
  Future<List<Workout>> getWorkouts(String userId);
  Future<void> saveWorkout(Workout workout);
}

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDataSource _remote;
  final WorkoutLocalDataSource _local;

  @override
  Future<List<Workout>> getWorkouts(String userId) async {
    try {
      final remote = await _remote.getWorkouts(userId);
      await _local.cacheWorkouts(remote);
      return remote;
    } catch (e) {
      return await _local.getCachedWorkouts(userId);
    }
  }
}
```

#### 2. Add Dependency Injection Container
Replace manual DI with a proper container for better testability.

```dart
// Using get_it
final getIt = GetIt.instance;

void setupDependencies() {
  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthServiceImpl());
  getIt.registerLazySingleton<CacheService>(() => CacheServiceImpl());

  // Repositories
  getIt.registerLazySingleton<WorkoutRepository>(
    () => WorkoutRepositoryImpl(getIt(), getIt()),
  );

  // Providers
  getIt.registerFactory<AuthProvider>(() => AuthProvider(getIt()));
}
```

#### 3. Implement Offline-First Architecture
Add proper offline support with sync queue.

```dart
class SyncQueue {
  Future<void> enqueue(SyncOperation operation);
  Future<void> processQueue();
  Stream<SyncStatus> get syncStatus;
}

class SyncOperation {
  final String id;
  final String endpoint;
  final String method;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
}
```

#### 4. Add API Versioning
```
/api/v1/auth/*
/api/v1/workouts/*
/api/v1/classes/*
```

#### 5. Implement Feature Flags Service
```dart
class FeatureFlagsService {
  Future<bool> isEnabled(String feature, {String? userId});
  Future<Map<String, bool>> getAllFlags({String? userId});
}
```

### Security Improvements

#### 1. Secrets Management
```dart
// Use environment-only configuration
class SecureConfig {
  static String get supabaseUrl =>
    const String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  static String get supabaseAnonKey =>
    const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static void validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw ConfigurationError('Missing required environment variables');
    }
  }
}
```

#### 2. Implement Secure Storage
```dart
abstract class SecureStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

class SecureStorageImpl implements SecureStorage {
  final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'life_and_gym_secure',
      preferencesKeyPrefix: 'lag_',
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'life_and_gym',
    ),
  );

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}
```

#### 3. Add Rate Limiting
```typescript
// api/lib/middleware/rateLimit.ts
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const redis = Redis.fromEnv();

const rateLimiters = {
  auth: new Ratelimit({
    redis,
    limiter: Ratelimit.slidingWindow(5, '1 m'),
    prefix: 'rl:auth',
  }),
  api: new Ratelimit({
    redis,
    limiter: Ratelimit.slidingWindow(100, '1 m'),
    prefix: 'rl:api',
  }),
};

export async function checkRateLimit(
  type: 'auth' | 'api',
  identifier: string
): Promise<{ success: boolean; remaining: number }> {
  const { success, remaining } = await rateLimiters[type].limit(identifier);
  return { success, remaining };
}
```

#### 4. Add Certificate Pinning
```dart
// lib/core/services/secure_http_client.dart
import 'dart:io';

class SecureHttpClient {
  static HttpClient create() {
    final client = HttpClient();

    client.badCertificateCallback = (cert, host, port) {
      // Verify certificate against pinned certificates
      final validHashes = [
        'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
        'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
      ];

      final certHash = _computeCertHash(cert);
      return validHashes.contains(certHash);
    };

    return client;
  }
}
```

#### 5. Add Request Signing for Sensitive Operations
```dart
class RequestSigner {
  static String sign(String method, String path, String body, String timestamp) {
    final message = '$method\n$path\n$body\n$timestamp';
    final hmac = Hmac(sha256, utf8.encode(_signingKey));
    return base64Encode(hmac.convert(utf8.encode(message)).bytes);
  }
}
```

---

## Implementation Priority

### Phase 1: Critical (Immediate - Week 1)
| Item | Severity | Effort | Impact |
|------|----------|--------|--------|
| Remove hardcoded credentials | CRITICAL | Low | High |
| Fix CORS configuration | HIGH | Low | High |
| Add rate limiting | HIGH | Medium | High |

### Phase 2: High Priority (Week 2-3)
| Item | Severity | Effort | Impact |
|------|----------|--------|--------|
| Implement secure storage | HIGH | Medium | High |
| Remove PII from logs | HIGH | Low | Medium |
| Add SSL pinning | MEDIUM | Medium | High |
| Add input sanitization | MEDIUM | Medium | Medium |

### Phase 3: Architecture Improvements (Week 4-6)
| Item | Severity | Effort | Impact |
|------|----------|--------|--------|
| API versioning | MEDIUM | Medium | Medium |
| Repository pattern | LOW | High | High |
| Dependency injection | LOW | Medium | High |
| Offline-first sync | LOW | High | High |

### Phase 4: Enhancements (Week 7+)
| Item | Severity | Effort | Impact |
|------|----------|--------|--------|
| Feature flags service | LOW | Medium | Medium |
| Request signing | LOW | High | Medium |
| Enhanced monitoring | LOW | Medium | Medium |

---

## Conclusion

The Life and Gym application has a solid architectural foundation with proper separation of concerns and good error handling. However, several **critical** and **high** severity security issues must be addressed before production deployment:

1. **Immediately** remove hardcoded credentials from source code
2. **Immediately** fix CORS configuration to prevent unauthorized access
3. **Before launch** implement rate limiting and secure storage

The recommended improvements will enhance the application's security posture, maintainability, and scalability while following industry best practices.

---

*This review was conducted based on code analysis. A full security audit including penetration testing is recommended before production deployment.*
