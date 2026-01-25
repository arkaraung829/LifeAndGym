# Guest Mode Implementation

## Overview
Guest mode allows users to explore the LifeAndGym app without creating an account. Guests can browse gyms, view classes, and see workout content, but cannot access features that require authentication like check-ins, bookings, and progress tracking.

## Implementation Details

### 1. AuthProvider Updates
**File**: `lib/features/auth/providers/auth_provider.dart`

**New Features**:
- Added `AuthStatus.guest` enum value
- Added `_isGuest` state flag
- Added `isGuest` getter
- Added `hasAccess` getter (returns true for both authenticated and guest users)
- Guest mode persistence using CacheService

**New Methods**:
```dart
Future<void> continueAsGuest() // Enter guest mode
Future<void> exitGuestMode()    // Exit guest mode and return to auth flow
Future<void> upgradeFromGuest() // Convert guest to authenticated user
```

### 2. Router Updates
**File**: `lib/core/router/app_router.dart`

**Changes**:
- Updated redirect logic to allow guest access to main app screens
- Guest-accessible routes: home, workouts, book, progress, profile
- Guests are not forced to login when accessing these routes

### 3. Welcome Screen
**File**: `lib/features/auth/screens/welcome_screen.dart`

**New Feature**:
- Added "Continue as Guest" button below sign-in options
- Calls `continueAsGuest()` and navigates to home screen

### 4. Guest Mode UI Components
**File**: `lib/shared/widgets/guest_mode_banner.dart`

**Three new widgets created**:

#### GuestModeBanner
- Full-width banner shown at top of screens
- Displays "Guest Mode" with custom message
- "Sign Up" button to exit guest mode
- Automatically hidden for authenticated users

#### GuestModeIndicator
- Compact badge for app bars
- Shows "Guest" with eye icon
- Used in header areas

#### GuestModePrompt
- Full-screen prompt for restricted features
- Shows when guests try to access auth-required features
- Provides "Create Account" and "Sign In" options

### 5. Screen Updates

#### Profile Screen
**File**: `lib/features/profile/screens/profile_screen.dart`
- Shows GuestModePrompt instead of profile content for guests
- Hides settings icon for guest users
- Prompts guests to create account to access profile features

#### Home Screen
**File**: `lib/features/home/screens/home_screen.dart`
- Displays GuestModeIndicator in header for guests
- Shows GuestModeBanner below header
- Hides QR check-in card for guests (auth-required feature)
- Shows "Guest" instead of user name in greeting

## Guest Access Permissions

### ✅ Accessible to Guests
- Browse gyms and locations
- View gym details and operating hours
- Browse class schedules
- View workout library and exercises
- View training plans
- See app features and UI

### ❌ Requires Authentication
- QR code check-in
- Check-in/check-out from gyms
- Book fitness classes
- Join waitlists
- Track personal workouts
- Log exercises and sets
- View personal progress and statistics
- Save favorite workouts or exercises
- Set and track goals
- Upload profile photo
- Save preferences
- View workout history

## User Flow

### Entering Guest Mode
1. User opens app
2. Sees welcome screen
3. Taps "Continue as Guest"
4. Navigates to home screen
5. Guest preference saved in cache

### Guest Experience
- Banner appears on main screens encouraging sign-up
- Guest indicator shows in header
- Can explore all public content
- Prompted to sign up when accessing restricted features

### Converting to Authenticated User
1. Guest taps "Sign Up" on banner or prompt
2. Exits guest mode
3. Navigates to registration screen
4. After successful registration, guest preference cleared
5. Full access granted

### Persistent Guest Mode
- Guest preference saved in local cache
- App remembers guest status across sessions
- User remains in guest mode until they:
  - Create an account
  - Sign in
  - Manually exit guest mode

## Technical Implementation

### State Management
```dart
// Check if user has access (authenticated OR guest)
if (authProvider.hasAccess) {
  // Show content
}

// Check specifically for guest
if (authProvider.isGuest) {
  // Show guest-specific UI
}

// Check for full authentication
if (authProvider.isAuthenticated) {
  // Show auth-required features
}
```

### Conditional Rendering Pattern
```dart
// For features requiring authentication
if (authProvider.isGuest) {
  return GuestModePrompt(
    title: 'Feature Name',
    message: 'Sign up to access this feature',
  );
}
return AuthenticatedContent();

// For optional features
if (!authProvider.isGuest) {
  // Show auth-only widget
}
```

### Cache Keys
- `guest_mode`: Boolean flag stored in SharedPreferences

## Benefits

### For Users
- Try app before committing to sign-up
- Explore features and content
- Lower barrier to entry
- Can evaluate app value proposition

### For Business
- Increased user acquisition
- Lower drop-off rate
- Showcase app features
- Convert engaged guests to users

## Future Enhancements

### Potential Features
1. **Limited Guest Actions**
   - Allow 1-2 free class bookings
   - Save workouts locally (without sync)
   - Basic workout tracking (ephemeral)

2. **Guest Analytics**
   - Track which features guests explore
   - Identify conversion points
   - A/B test guest experience

3. **Personalized Conversion**
   - Show relevant sign-up prompts
   - Highlight features based on guest behavior
   - Time-based conversion nudges

4. **Guest Data Migration**
   - Offer to preserve guest data upon sign-up
   - Auto-import locally saved workouts
   - Maintain browsing preferences

## Testing Checklist

- [ ] Guest can access app from welcome screen
- [ ] Guest sees banner on main screens
- [ ] Guest indicator shows in header
- [ ] Profile shows sign-up prompt for guests
- [ ] QR check-in hidden for guests
- [ ] Guest mode persists across app restarts
- [ ] Guest can create account from any prompt
- [ ] Guest can sign in to existing account
- [ ] Guest preference cleared after authentication
- [ ] Router allows guest access to public screens
- [ ] Router redirects guests from auth-only features

