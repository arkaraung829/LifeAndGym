import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_my.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('my'),
  ];

  /// The app name
  ///
  /// In en, this message translates to:
  /// **'Life & Gym'**
  String get appName;

  /// Login screen header
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your fitness journey'**
  String get signInToContinue;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Divider text between login options
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Google sign in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Apple sign in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// Sign up prompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Sign in prompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Login error message
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// Google sign in loading message
  ///
  /// In en, this message translates to:
  /// **'Redirecting to Google sign in...'**
  String get redirectingToGoogle;

  /// Google sign in error
  ///
  /// In en, this message translates to:
  /// **'Google sign in failed'**
  String get googleSignInFailed;

  /// Apple sign in not available message
  ///
  /// In en, this message translates to:
  /// **'Apple sign in coming soon'**
  String get appleSignInComingSoon;

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// Guest user label
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// Member label
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// Checked in status
  ///
  /// In en, this message translates to:
  /// **'CHECKED IN'**
  String get checkedIn;

  /// Check in prompt
  ///
  /// In en, this message translates to:
  /// **'TAP TO CHECK IN'**
  String get tapToCheckIn;

  /// QR dialog title
  ///
  /// In en, this message translates to:
  /// **'Scan to Check In'**
  String get scanToCheckIn;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No membership status
  ///
  /// In en, this message translates to:
  /// **'No active membership'**
  String get noActiveMembership;

  /// Member type display
  ///
  /// In en, this message translates to:
  /// **'{type} Member'**
  String memberType(String type);

  /// No gym status
  ///
  /// In en, this message translates to:
  /// **'No gym available'**
  String get noGymAvailable;

  /// Low occupancy status
  ///
  /// In en, this message translates to:
  /// **'Not Busy'**
  String get notBusy;

  /// Medium occupancy status
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// High occupancy status
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get busy;

  /// Gym occupancy display
  ///
  /// In en, this message translates to:
  /// **'{status} • {current}/{capacity} people'**
  String occupancyStatus(String status, int current, int capacity);

  /// Active workout status
  ///
  /// In en, this message translates to:
  /// **'Workout in Progress'**
  String get workoutInProgress;

  /// Workout section title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout'**
  String get todaysWorkout;

  /// Resume workout prompt
  ///
  /// In en, this message translates to:
  /// **'Continue your session'**
  String get continueYourSession;

  /// Quick workout button
  ///
  /// In en, this message translates to:
  /// **'Start a Quick Workout'**
  String get startQuickWorkout;

  /// Resume hint
  ///
  /// In en, this message translates to:
  /// **'Tap to resume'**
  String get tapToResume;

  /// Empty workout state
  ///
  /// In en, this message translates to:
  /// **'No planned workouts'**
  String get noPlannedWorkouts;

  /// Resume workout button
  ///
  /// In en, this message translates to:
  /// **'Resume Workout'**
  String get resumeWorkout;

  /// Start workout button
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// Estimated duration
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min'**
  String estimatedMinutes(int minutes);

  /// Classes section title
  ///
  /// In en, this message translates to:
  /// **'Upcoming Classes'**
  String get upcomingClasses;

  /// See all link
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// Empty classes state
  ///
  /// In en, this message translates to:
  /// **'No classes scheduled today'**
  String get noClassesScheduledToday;

  /// Booked status
  ///
  /// In en, this message translates to:
  /// **'BOOKED'**
  String get booked;

  /// Available spots
  ///
  /// In en, this message translates to:
  /// **'{count} spots'**
  String spotsRemaining(int count);

  /// Weekly progress title
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Streak count
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String dayStreak(int count);

  /// Weekly progress
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} workouts completed'**
  String workoutsCompleted(int completed, int total);

  /// Home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Workouts tab
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// Classes tab
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// Progress tab
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Profile tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Register screen header
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// Register screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Start your fitness journey today'**
  String get startYourFitnessJourney;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Confirm password field hint
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reEnterYourPassword;

  /// Terms agreement prefix
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our '**
  String get bySigningUp;

  /// Terms link
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Conjunction
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// Privacy link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Registration error
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// Reset password screen header
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Reset password instructions
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you instructions to reset your password.'**
  String get enterEmailForReset;

  /// Reset button
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// Back to login link
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// Reset success message
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Please check your inbox.'**
  String get resetEmailSent;

  /// Exercises section
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// Exercise library title
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get exerciseLibrary;

  /// Exercise search hint
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get searchExercises;

  /// All exercises filter
  ///
  /// In en, this message translates to:
  /// **'All Exercises'**
  String get allExercises;

  /// User workouts section
  ///
  /// In en, this message translates to:
  /// **'My Workouts'**
  String get myWorkouts;

  /// Workout templates
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templates;

  /// History section
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Workout history title
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get workoutHistory;

  /// Empty workout history
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get noWorkoutsYet;

  /// Empty workout history message
  ///
  /// In en, this message translates to:
  /// **'Start your first workout to see your history here.'**
  String get startYourFirstWorkout;

  /// Active workout title
  ///
  /// In en, this message translates to:
  /// **'Active Workout'**
  String get activeWorkout;

  /// Duration label
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Sets label
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// Reps label
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// Weight label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// Add exercise button
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExercise;

  /// Finish workout button
  ///
  /// In en, this message translates to:
  /// **'Finish Workout'**
  String get finishWorkout;

  /// Cancel workout button
  ///
  /// In en, this message translates to:
  /// **'Cancel Workout'**
  String get cancelWorkout;

  /// Schedules section
  ///
  /// In en, this message translates to:
  /// **'Schedules'**
  String get schedules;

  /// User bookings
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// Book class button
  ///
  /// In en, this message translates to:
  /// **'Book Class'**
  String get bookClass;

  /// Cancel booking button
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// Class details title
  ///
  /// In en, this message translates to:
  /// **'Class Details'**
  String get classDetails;

  /// Instructor label
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get instructor;

  /// Level label
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// Statistics section
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Total workouts stat
  ///
  /// In en, this message translates to:
  /// **'Total Workouts'**
  String get totalWorkouts;

  /// Total minutes stat
  ///
  /// In en, this message translates to:
  /// **'Total Minutes'**
  String get totalMinutes;

  /// Total weight stat
  ///
  /// In en, this message translates to:
  /// **'Total Weight'**
  String get totalWeight;

  /// Current streak stat
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// Edit profile title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Settings title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Notifications setting
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Logout confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// Yes button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No internet error
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// Generic error
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Guest mode label
  ///
  /// In en, this message translates to:
  /// **'Guest Mode'**
  String get guestMode;

  /// Guest mode banner message
  ///
  /// In en, this message translates to:
  /// **'Sign in to access all features'**
  String get guestModeMessage;

  /// Sign in prompt button
  ///
  /// In en, this message translates to:
  /// **'Sign In Now'**
  String get signInNow;

  /// Get started button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Welcome screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome to Life & Gym'**
  String get welcomeToLifeAndGym;

  /// Welcome screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Your fitness journey starts here'**
  String get fitnessJourneyStarts;

  /// Guest mode button
  ///
  /// In en, this message translates to:
  /// **'Explore as Guest'**
  String get exploreAsGuest;

  /// Kilogram unit
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// Pounds unit
  ///
  /// In en, this message translates to:
  /// **'lbs'**
  String get lbs;

  /// Minutes abbreviation
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// Seconds abbreviation
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get sec;

  /// Email validation
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// Invalid email validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validationEmailInvalid;

  /// Password validation
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validationPasswordRequired;

  /// Password length validation
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPasswordTooShort;

  /// Password match validation
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsDoNotMatch;

  /// Name validation
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get validationNameRequired;

  /// Generic required field validation
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String validationFieldRequired(String field);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'my'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'my':
      return AppLocalizationsMy();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
