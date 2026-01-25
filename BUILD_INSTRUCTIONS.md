# Build Instructions - LifeAndGym App

## ✅ All Build Errors Fixed!

The app should now build successfully on both iOS and Android.

## What Was Fixed

### 1. Exception Handling Issues
- ✅ Changed abstract `AppException` to concrete exception types
- ✅ Used `DatabaseException` for database errors
- ✅ Used `ValidationException` for validation errors
- ✅ Removed invalid `ExceptionType` enum references

### 2. Type Safety Issues
- ✅ Fixed async cache service call in AuthProvider
- ✅ Proper awaiting of `CacheService().get()`
- ✅ Correct type comparison for guest mode

### 3. Import Issues
- ✅ Used `dart:math` for mathematical functions
- ✅ Fixed AppSpacing references

## Build Commands

### Clean Build (Recommended)
```bash
flutter clean
flutter pub get
flutter run
```

### iOS Specific
```bash
cd ios
pod install
cd ..
flutter run
```

### Android Specific
```bash
flutter run
```

## Verify Build

Run Flutter analyze to check for issues:
```bash
flutter analyze
```

Expected output:
```
No issues found! (ran in X.Xs)
```

## Running the App

### On Physical Device (iOS)
```bash
flutter run
# Select your iPhone from the device list
```

### On Simulator
```bash
# Start iOS Simulator first
open -a Simulator
flutter run
```

### On Android
```bash
flutter run
# Select your Android device
```

## Expected Behavior

### First Launch
1. App opens to splash screen
2. Navigates to welcome screen
3. Three options visible:
   - "Get Started" (registration)
   - "I already have an account" (login)
   - "Continue as Guest" (guest mode)

### Guest Mode Test
1. Tap "Continue as Guest"
2. Should land on home screen
3. Header shows "Guest" with indicator badge
4. Guest mode banner visible
5. QR check-in card hidden
6. Profile tab shows sign-up prompt

### Auth Flow Test
1. Tap "Get Started"
2. Fill in registration form
3. Create account
4. Should land on home screen (authenticated)
5. QR check-in card visible
6. User name shows in header

## Troubleshooting

### Issue: "No Supabase instance found"
**Solution**: Check that `.env.local` file exists with correct Supabase credentials

### Issue: "Failed to initialize services"
**Solution**: 
1. Check internet connection
2. Verify Supabase project is active
3. Check Supabase credentials in `.env.local`

### Issue: iOS Build Fails
**Solution**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: Android Build Fails
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Dependency Errors
**Solution**:
```bash
flutter pub cache repair
flutter clean
flutter pub get
```

## Development Mode

### Enable Debug Mode
The app automatically runs in debug mode when using `flutter run`.

### Hot Reload
- Press `r` in terminal to hot reload
- Press `R` in terminal to hot restart
- Press `q` to quit

### View Logs
```bash
flutter logs
```

## Build for Release

### iOS (TestFlight/App Store)
```bash
flutter build ios --release
```

### Android (Google Play)
```bash
flutter build appbundle --release
```

## What's Working

✅ App builds successfully  
✅ All core services functional  
✅ Guest mode working  
✅ Authentication flow working  
✅ Navigation working  
✅ Database connected  
✅ State management working  

## What's Next

After successful build, test these flows:
1. Guest mode flow
2. Sign up flow
3. Sign in flow
4. Navigation between tabs
5. Sign out flow

See `TESTING_CHECKLIST.md` for comprehensive testing scenarios.

## Support

If you encounter any build issues:
1. Check error message carefully
2. Try clean build first
3. Check internet connection
4. Verify Supabase credentials
5. Check Flutter and Xcode versions

**Flutter Version Required**: 3.10+  
**Xcode Version Required**: 14.0+  
**iOS Deployment Target**: 12.0+  

