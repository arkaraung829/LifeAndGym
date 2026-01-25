# Testing Checklist - LifeAndGym App

## Build Status
Try building the app:
```bash
flutter clean
flutter pub get
flutter run
```

## ✅ Test Scenarios

### 1. Guest Mode Flow
- [ ] Open app for first time
- [ ] See welcome screen
- [ ] Tap "Continue as Guest"
- [ ] Land on home screen
- [ ] See "Guest" indicator in header
- [ ] See guest mode banner
- [ ] Tap on Profile tab
- [ ] See sign-up prompt
- [ ] Close and reopen app
- [ ] Should remain in guest mode
- [ ] Tap "Sign Up" from banner
- [ ] Navigate to registration

### 2. Authentication Flow
- [ ] Tap "Get Started" on welcome screen
- [ ] See registration screen
- [ ] Fill in registration form
- [ ] Create account
- [ ] See home screen (authenticated)
- [ ] Close and reopen app
- [ ] Still authenticated
- [ ] Sign out from profile
- [ ] Return to welcome screen

### 3. Navigation
- [ ] Bottom nav bar visible
- [ ] Tap Home - see home screen
- [ ] Tap Workouts - see workouts screen
- [ ] Tap Book - see classes screen
- [ ] Tap Progress - see progress screen
- [ ] Tap Profile - see profile screen
- [ ] All tabs working

### 4. Home Screen (Guest)
- [ ] See "Guest" in greeting
- [ ] Guest mode indicator visible
- [ ] Guest banner visible
- [ ] QR check-in card hidden
- [ ] Gym status card visible
- [ ] Today's workout card visible
- [ ] Upcoming classes visible
- [ ] Weekly progress visible

### 5. Home Screen (Authenticated)
- [ ] See user name in greeting
- [ ] User avatar visible
- [ ] No guest indicator
- [ ] No guest banner
- [ ] QR check-in card visible
- [ ] All other cards visible

### 6. Profile Screen (Guest)
- [ ] See full-screen sign-up prompt
- [ ] "Create Account" button works
- [ ] "I already have an account" works
- [ ] Settings icon hidden

### 7. Profile Screen (Authenticated)
- [ ] See profile header
- [ ] See user name and email
- [ ] See avatar with initials
- [ ] See membership card
- [ ] See menu items
- [ ] See sign out button
- [ ] Settings icon visible

## 🔧 Common Issues & Fixes

### Build Errors
**Issue**: Dependencies not found
```bash
flutter pub get
```

**Issue**: iOS build fails
```bash
cd ios
pod install
cd ..
flutter run
```

### Runtime Errors
**Issue**: "No Supabase instance found"
- Check `.env.local` exists
- Verify Supabase credentials

**Issue**: "Failed to connect to database"
- Check internet connection
- Verify Supabase project is active

**Issue**: Guest mode not persisting
- Check SharedPreferences initialization
- Verify cache service is working

## 📱 What to Expect

### Working Features
✅ App launches successfully
✅ Guest mode fully functional
✅ Authentication flow works
✅ Navigation between screens
✅ Profile management
✅ Sign out functionality

### Mock Data (Placeholders)
⚠️ Home screen shows sample data
⚠️ Workouts screen is placeholder
⚠️ Classes screen is placeholder
⚠️ Progress screen is placeholder

### Not Yet Connected
❌ Gym data not loading (service ready, UI not connected)
❌ Check-in flow not wired up
❌ Class booking not wired up
❌ Workout tracking not implemented

## 🎯 Next Testing Phase

After implementing workout tracking services:
- [ ] Load exercises from database
- [ ] Display workout library
- [ ] Create workout session
- [ ] Log exercises
- [ ] Complete workout

After connecting gym features:
- [ ] Load real gyms from database
- [ ] Search gyms
- [ ] View gym details
- [ ] Check-in with QR
- [ ] Check-out

## 📊 Performance Metrics to Check

- [ ] App starts in < 3 seconds
- [ ] Screen transitions smooth (60 FPS)
- [ ] No memory leaks
- [ ] Guest mode loads instantly
- [ ] Auth state check is fast

## 🐛 Report Issues

If you find issues, note:
1. What you were doing
2. Expected behavior
3. Actual behavior
4. Error messages (if any)
5. Steps to reproduce

