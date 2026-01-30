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

  /// Booked status label
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

  /// Goals screen title
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals_title;

  /// Empty goals state message
  ///
  /// In en, this message translates to:
  /// **'No goals yet - Set your first goal!'**
  String get goals_empty;

  /// Create goal button
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get create_goal;

  /// Goal name field label
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goal_name;

  /// Goal description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get goal_description;

  /// Goal type field label
  ///
  /// In en, this message translates to:
  /// **'Goal Type'**
  String get goal_type;

  /// Target value field label
  ///
  /// In en, this message translates to:
  /// **'Target Value'**
  String get target_value;

  /// Current value field label
  ///
  /// In en, this message translates to:
  /// **'Current Value'**
  String get current_value;

  /// Target date field label
  ///
  /// In en, this message translates to:
  /// **'Target Date'**
  String get target_date;

  /// Days remaining label
  ///
  /// In en, this message translates to:
  /// **'days remaining'**
  String get days_remaining;

  /// Overdue status
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// Update progress button
  ///
  /// In en, this message translates to:
  /// **'Update Progress'**
  String get update_progress;

  /// Mark complete button
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get mark_complete;

  /// Weight loss goal type
  ///
  /// In en, this message translates to:
  /// **'Weight Loss'**
  String get weight_loss;

  /// Muscle gain goal type
  ///
  /// In en, this message translates to:
  /// **'Muscle Gain'**
  String get muscle_gain;

  /// Strength goal type
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strength;

  /// Endurance goal type
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get endurance;

  /// Flexibility goal type
  ///
  /// In en, this message translates to:
  /// **'Flexibility'**
  String get flexibility;

  /// Body fat goal type/metric
  ///
  /// In en, this message translates to:
  /// **'Body Fat'**
  String get body_fat;

  /// Consistency goal type
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistency;

  /// All filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filter_all;

  /// Active filter option
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get filter_active;

  /// Completed filter option
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filter_completed;

  /// Body metrics screen title
  ///
  /// In en, this message translates to:
  /// **'Body Metrics'**
  String get body_metrics;

  /// Empty body metrics state message
  ///
  /// In en, this message translates to:
  /// **'No metrics yet - Track your first measurement!'**
  String get body_metrics_empty;

  /// Add entry button
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get add_entry;

  /// Latest metrics section title
  ///
  /// In en, this message translates to:
  /// **'Latest Metrics'**
  String get latest_metrics;

  /// BMI (Body Mass Index) label
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// Muscle mass label
  ///
  /// In en, this message translates to:
  /// **'Muscle Mass'**
  String get muscle_mass;

  /// Measurements section title
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurements;

  /// Chest measurement label
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chest;

  /// Waist measurement label
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get waist;

  /// Hips measurement label
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get hips;

  /// Arms measurement label
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get arms;

  /// Thighs measurement label
  ///
  /// In en, this message translates to:
  /// **'Thighs'**
  String get thighs;

  /// Trends section title
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trends;

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Total entries stat label
  ///
  /// In en, this message translates to:
  /// **'Total Entries'**
  String get total_entries;

  /// Days tracked stat label
  ///
  /// In en, this message translates to:
  /// **'Days Tracked'**
  String get days_tracked;

  /// Recorded at label
  ///
  /// In en, this message translates to:
  /// **'Recorded At'**
  String get recorded_at;

  /// BMI category: Underweight
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmi_underweight;

  /// BMI category: Normal
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get bmi_normal;

  /// BMI category: Overweight
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmi_overweight;

  /// BMI category: Obese
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bmi_obese;

  /// Find gyms screen title
  ///
  /// In en, this message translates to:
  /// **'Find Gyms'**
  String get find_gyms;

  /// Search gyms hint text
  ///
  /// In en, this message translates to:
  /// **'Search gyms...'**
  String get search_gyms;

  /// No gyms found message
  ///
  /// In en, this message translates to:
  /// **'No gyms found'**
  String get no_gyms_found;

  /// Open now status
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get open_now;

  /// Closed status
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// Capacity label
  ///
  /// In en, this message translates to:
  /// **'capacity'**
  String get capacity;

  /// Amenities section title
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// Operating hours section title
  ///
  /// In en, this message translates to:
  /// **'Operating Hours'**
  String get operating_hours;

  /// Open in maps button
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get open_in_maps;

  /// Apply filters button
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get apply_filters;

  /// Clear filters button
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clear_filters;

  /// Create workout title
  ///
  /// In en, this message translates to:
  /// **'Create Workout'**
  String get create_workout;

  /// Basic info section title
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basic_info;

  /// Exercise selection section title
  ///
  /// In en, this message translates to:
  /// **'Exercise Selection'**
  String get exercise_selection;

  /// Exercise configuration section title
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get exercise_configuration;

  /// Review and save section title
  ///
  /// In en, this message translates to:
  /// **'Review & Save'**
  String get review;

  /// Workout name field label
  ///
  /// In en, this message translates to:
  /// **'Workout Name'**
  String get workout_name;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Estimated duration field label
  ///
  /// In en, this message translates to:
  /// **'Estimated Duration'**
  String get estimated_duration;

  /// Difficulty field label
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// Select exercises title
  ///
  /// In en, this message translates to:
  /// **'Select Exercises'**
  String get select_exercises;

  /// Selected exercises label
  ///
  /// In en, this message translates to:
  /// **'Selected Exercises'**
  String get selected_exercises;

  /// Rest time field label
  ///
  /// In en, this message translates to:
  /// **'Rest Time'**
  String get rest_time;

  /// Beginner difficulty level
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// Intermediate difficulty level
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// Advanced difficulty level
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// Chest muscle group
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chest_muscle;

  /// Back muscle group
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Shoulders muscle group
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get shoulders;

  /// Arms muscle group
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get arms_muscle;

  /// Legs muscle group
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get legs;

  /// Core muscle group
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get core;

  /// Glutes muscle group
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get glutes;

  /// Cardio muscle group
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get cardio;

  /// Membership plans screen title
  ///
  /// In en, this message translates to:
  /// **'Membership Plans'**
  String get membership_plans;

  /// Current plan badge
  ///
  /// In en, this message translates to:
  /// **'CURRENT'**
  String get current_plan;

  /// Upgrade button
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// Downgrade button
  ///
  /// In en, this message translates to:
  /// **'Downgrade'**
  String get downgrade;

  /// Confirm upgrade title
  ///
  /// In en, this message translates to:
  /// **'Confirm Upgrade'**
  String get confirm_upgrade;

  /// Pricing breakdown section title
  ///
  /// In en, this message translates to:
  /// **'Pricing Breakdown'**
  String get pricing_breakdown;

  /// Prorated adjustment label
  ///
  /// In en, this message translates to:
  /// **'Prorated Adjustment'**
  String get prorated_adjustment;

  /// Total due today label
  ///
  /// In en, this message translates to:
  /// **'Total Due Today'**
  String get total_due_today;

  /// Next billing date label
  ///
  /// In en, this message translates to:
  /// **'Next Billing Date'**
  String get next_billing_date;

  /// Payment method label
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get payment_method;

  /// Change payment method button
  ///
  /// In en, this message translates to:
  /// **'Change Payment Method'**
  String get change_payment_method;

  /// Agree to terms checkbox label
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms and conditions'**
  String get agree_to_terms;

  /// Plan features section title
  ///
  /// In en, this message translates to:
  /// **'Plan Features'**
  String get plan_features;

  /// Enable notifications setting
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enable_notifications;

  /// Notification permission denied title
  ///
  /// In en, this message translates to:
  /// **'Notification Permission Denied'**
  String get notification_permission_denied;

  /// Notification permission denied message
  ///
  /// In en, this message translates to:
  /// **'Please enable notifications in your device settings to receive workout reminders and updates.'**
  String get notification_permission_message;

  /// Open settings button
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get open_settings;

  /// Email support label
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get email_support;

  /// Phone support label
  ///
  /// In en, this message translates to:
  /// **'Phone Support'**
  String get phone_support;

  /// Live chat label
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get live_chat;

  /// Active session status
  ///
  /// In en, this message translates to:
  /// **'Active session'**
  String get activeSession;

  /// Show QR code prompt
  ///
  /// In en, this message translates to:
  /// **'Show QR code'**
  String get showQrCode;

  /// Number of workout plans available
  ///
  /// In en, this message translates to:
  /// **'{count} workout plans available'**
  String workoutPlansAvailable(int count);

  /// Quick workout option
  ///
  /// In en, this message translates to:
  /// **'Quick Workout'**
  String get quickWorkout;

  /// Quick workout description
  ///
  /// In en, this message translates to:
  /// **'Start a free-form workout'**
  String get quickWorkoutDescription;

  /// User's workout plans section title
  ///
  /// In en, this message translates to:
  /// **'Your Workout Plans'**
  String get yourWorkoutPlans;

  /// View all workouts button
  ///
  /// In en, this message translates to:
  /// **'View All Workouts'**
  String get viewAllWorkouts;

  /// Workout start failure message
  ///
  /// In en, this message translates to:
  /// **'Failed to start workout'**
  String get failedToStartWorkout;

  /// View all gyms button
  ///
  /// In en, this message translates to:
  /// **'View All Gyms'**
  String get viewAllGyms;

  /// My profile menu item
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Membership menu item
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get membership;

  /// Sign out menu item
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Sign out confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// Settings coming soon message
  ///
  /// In en, this message translates to:
  /// **'Settings screen coming soon'**
  String get settingsComingSoon;

  /// Select gym dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Gym'**
  String get selectGym;

  /// Workout screen title
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// Warning message when trying to complete workout without sets
  ///
  /// In en, this message translates to:
  /// **'Log at least one set before finishing'**
  String get logAtLeastOneSet;

  /// Complete workout dialog title
  ///
  /// In en, this message translates to:
  /// **'Complete Workout'**
  String get completeWorkout;

  /// Complete workout confirmation message
  ///
  /// In en, this message translates to:
  /// **'You logged {count} sets. Complete this workout?'**
  String completeWorkoutConfirmation(int count);

  /// Complete button
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Cancel workout warning message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel? All progress will be lost.'**
  String get cancelWorkoutConfirmation;

  /// Keep going button
  ///
  /// In en, this message translates to:
  /// **'Keep Going'**
  String get keepGoing;

  /// Cancel workout failure message
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel workout'**
  String get failedToCancelWorkout;

  /// No active workout message
  ///
  /// In en, this message translates to:
  /// **'No active workout session'**
  String get noActiveWorkoutSession;

  /// Add set button
  ///
  /// In en, this message translates to:
  /// **'Add Set'**
  String get addSet;

  /// Select exercise dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Exercise'**
  String get selectExercise;

  /// Rest timer label
  ///
  /// In en, this message translates to:
  /// **'Rest Timer'**
  String get restTimer;

  /// Skip rest button
  ///
  /// In en, this message translates to:
  /// **'Skip Rest'**
  String get skipRest;

  /// Book classes screen title
  ///
  /// In en, this message translates to:
  /// **'Book Classes'**
  String get bookClasses;

  /// Book a class button
  ///
  /// In en, this message translates to:
  /// **'Book a Class'**
  String get bookAClass;

  /// Book button
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// Join waitlist button
  ///
  /// In en, this message translates to:
  /// **'Join Waitlist'**
  String get joinWaitlist;

  /// Confirm cancellation button
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// Class booking success message
  ///
  /// In en, this message translates to:
  /// **'Class booked! You\'ll receive a reminder 30 minutes before.'**
  String get classBookedSuccess;

  /// Cancel booking confirmation question
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking?'**
  String get cancelBookingConfirmation;

  /// Booking cancelled confirmation
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled'**
  String get bookingCancelled;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Tomorrow label
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Monday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// Tuesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// Wednesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// Thursday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// Friday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// Saturday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// Sunday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// All filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Yoga class type
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get yoga;

  /// HIIT class type
  ///
  /// In en, this message translates to:
  /// **'HIIT'**
  String get hiit;

  /// Spin class type
  ///
  /// In en, this message translates to:
  /// **'Spin'**
  String get spin;

  /// Pilates class type
  ///
  /// In en, this message translates to:
  /// **'Pilates'**
  String get pilates;

  /// Full capacity status label
  ///
  /// In en, this message translates to:
  /// **'FULL'**
  String get full;

  /// Empty bookings state message
  ///
  /// In en, this message translates to:
  /// **'No upcoming bookings'**
  String get noUpcomingBookings;

  /// Empty schedule state message
  ///
  /// In en, this message translates to:
  /// **'No classes scheduled'**
  String get noClassesScheduled;

  /// Notification permission dialog title
  ///
  /// In en, this message translates to:
  /// **'Notification Permission Required'**
  String get notificationPermissionRequired;

  /// Daily reminder confirmation message
  ///
  /// In en, this message translates to:
  /// **'Daily reminder set for {time}'**
  String dailyReminderSet(String time);

  /// Delete account option
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Profile update success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// Change photo button
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// Upload in progress message
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// Take photo option
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Choose from gallery option
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Remove photo option/dialog title
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// Remove photo confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove your profile photo?'**
  String get removePhotoConfirmation;

  /// Remove button
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Camera permission dialog title
  ///
  /// In en, this message translates to:
  /// **'Camera Permission Required'**
  String get cameraPermissionRequired;

  /// Photo library permission dialog title
  ///
  /// In en, this message translates to:
  /// **'Photo Library Permission Required'**
  String get photoLibraryPermissionRequired;

  /// Button text to open device settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;
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
