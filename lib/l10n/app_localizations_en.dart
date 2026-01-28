// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Life & Gym';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToContinue => 'Sign in to continue your fitness journey';

  @override
  String get email => 'Email';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get password => 'Password';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get or => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get redirectingToGoogle => 'Redirecting to Google sign in...';

  @override
  String get googleSignInFailed => 'Google sign in failed';

  @override
  String get appleSignInComingSoon => 'Apple sign in coming soon';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get guest => 'Guest';

  @override
  String get member => 'Member';

  @override
  String get checkedIn => 'CHECKED IN';

  @override
  String get tapToCheckIn => 'TAP TO CHECK IN';

  @override
  String get scanToCheckIn => 'Scan to Check In';

  @override
  String get close => 'Close';

  @override
  String get noActiveMembership => 'No active membership';

  @override
  String memberType(String type) {
    return '$type Member';
  }

  @override
  String get noGymAvailable => 'No gym available';

  @override
  String get notBusy => 'Not Busy';

  @override
  String get moderate => 'Moderate';

  @override
  String get busy => 'Busy';

  @override
  String occupancyStatus(String status, int current, int capacity) {
    return '$status • $current/$capacity people';
  }

  @override
  String get workoutInProgress => 'Workout in Progress';

  @override
  String get todaysWorkout => 'Today\'s Workout';

  @override
  String get continueYourSession => 'Continue your session';

  @override
  String get startQuickWorkout => 'Start a Quick Workout';

  @override
  String get tapToResume => 'Tap to resume';

  @override
  String get noPlannedWorkouts => 'No planned workouts';

  @override
  String get resumeWorkout => 'Resume Workout';

  @override
  String get startWorkout => 'Start Workout';

  @override
  String estimatedMinutes(int minutes) {
    return '~$minutes min';
  }

  @override
  String get upcomingClasses => 'Upcoming Classes';

  @override
  String get seeAll => 'See All';

  @override
  String get noClassesScheduledToday => 'No classes scheduled today';

  @override
  String get booked => 'BOOKED';

  @override
  String spotsRemaining(int count) {
    return '$count spots';
  }

  @override
  String get thisWeek => 'This Week';

  @override
  String dayStreak(int count) {
    return '$count day streak';
  }

  @override
  String workoutsCompleted(int completed, int total) {
    return '$completed/$total workouts completed';
  }

  @override
  String get home => 'Home';

  @override
  String get workouts => 'Workouts';

  @override
  String get classes => 'Classes';

  @override
  String get progress => 'Progress';

  @override
  String get profile => 'Profile';

  @override
  String get createAccount => 'Create account';

  @override
  String get startYourFitnessJourney => 'Start your fitness journey today';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterYourFullName => 'Enter your full name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get reEnterYourPassword => 'Re-enter your password';

  @override
  String get bySigningUp => 'By signing up, you agree to our ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get enterEmailForReset =>
      'Enter your email address and we\'ll send you instructions to reset your password.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get resetEmailSent =>
      'Password reset email sent. Please check your inbox.';

  @override
  String get exercises => 'Exercises';

  @override
  String get exerciseLibrary => 'Exercise Library';

  @override
  String get searchExercises => 'Search exercises...';

  @override
  String get allExercises => 'All Exercises';

  @override
  String get myWorkouts => 'My Workouts';

  @override
  String get templates => 'Templates';

  @override
  String get history => 'History';

  @override
  String get workoutHistory => 'Workout History';

  @override
  String get noWorkoutsYet => 'No workouts yet';

  @override
  String get startYourFirstWorkout =>
      'Start your first workout to see your history here.';

  @override
  String get activeWorkout => 'Active Workout';

  @override
  String get duration => 'Duration';

  @override
  String get sets => 'Sets';

  @override
  String get reps => 'Reps';

  @override
  String get weight => 'Weight';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get finishWorkout => 'Finish Workout';

  @override
  String get cancelWorkout => 'Cancel Workout';

  @override
  String get schedules => 'Schedules';

  @override
  String get myBookings => 'My Bookings';

  @override
  String get bookClass => 'Book Class';

  @override
  String get cancelBooking => 'Cancel Booking';

  @override
  String get classDetails => 'Class Details';

  @override
  String get instructor => 'Instructor';

  @override
  String get level => 'Level';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalWorkouts => 'Total Workouts';

  @override
  String get totalMinutes => 'Total Minutes';

  @override
  String get totalWeight => 'Total Weight';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get error => 'Error';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get loading => 'Loading...';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get guestMode => 'Guest Mode';

  @override
  String get guestModeMessage => 'Sign in to access all features';

  @override
  String get signInNow => 'Sign In Now';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get welcomeToLifeAndGym => 'Welcome to Life & Gym';

  @override
  String get fitnessJourneyStarts => 'Your fitness journey starts here';

  @override
  String get exploreAsGuest => 'Explore as Guest';

  @override
  String get kg => 'kg';

  @override
  String get lbs => 'lbs';

  @override
  String get min => 'min';

  @override
  String get sec => 'sec';

  @override
  String get validationEmailRequired => 'Email is required';

  @override
  String get validationEmailInvalid => 'Please enter a valid email';

  @override
  String get validationPasswordRequired => 'Password is required';

  @override
  String get validationPasswordTooShort =>
      'Password must be at least 6 characters';

  @override
  String get validationPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get validationNameRequired => 'Name is required';

  @override
  String validationFieldRequired(String field) {
    return '$field is required';
  }

  @override
  String get goals_title => 'Goals';

  @override
  String get goals_empty => 'No goals yet - Set your first goal!';

  @override
  String get create_goal => 'Create Goal';

  @override
  String get goal_name => 'Goal Name';

  @override
  String get goal_description => 'Description';

  @override
  String get goal_type => 'Goal Type';

  @override
  String get target_value => 'Target Value';

  @override
  String get current_value => 'Current Value';

  @override
  String get target_date => 'Target Date';

  @override
  String get days_remaining => 'days remaining';

  @override
  String get overdue => 'Overdue';

  @override
  String get update_progress => 'Update Progress';

  @override
  String get mark_complete => 'Mark as Complete';

  @override
  String get weight_loss => 'Weight Loss';

  @override
  String get muscle_gain => 'Muscle Gain';

  @override
  String get strength => 'Strength';

  @override
  String get endurance => 'Endurance';

  @override
  String get flexibility => 'Flexibility';

  @override
  String get body_fat => 'Body Fat';

  @override
  String get consistency => 'Consistency';

  @override
  String get filter_all => 'All';

  @override
  String get filter_active => 'Active';

  @override
  String get filter_completed => 'Completed';

  @override
  String get body_metrics => 'Body Metrics';

  @override
  String get body_metrics_empty =>
      'No metrics yet - Track your first measurement!';

  @override
  String get add_entry => 'Add Entry';

  @override
  String get latest_metrics => 'Latest Metrics';

  @override
  String get bmi => 'BMI';

  @override
  String get muscle_mass => 'Muscle Mass';

  @override
  String get measurements => 'Measurements';

  @override
  String get chest => 'Chest';

  @override
  String get waist => 'Waist';

  @override
  String get hips => 'Hips';

  @override
  String get arms => 'Arms';

  @override
  String get thighs => 'Thighs';

  @override
  String get trends => 'Trends';

  @override
  String get overview => 'Overview';

  @override
  String get total_entries => 'Total Entries';

  @override
  String get days_tracked => 'Days Tracked';

  @override
  String get recorded_at => 'Recorded At';

  @override
  String get bmi_underweight => 'Underweight';

  @override
  String get bmi_normal => 'Normal';

  @override
  String get bmi_overweight => 'Overweight';

  @override
  String get bmi_obese => 'Obese';

  @override
  String get find_gyms => 'Find Gyms';

  @override
  String get search_gyms => 'Search gyms...';

  @override
  String get no_gyms_found => 'No gyms found';

  @override
  String get open_now => 'Open Now';

  @override
  String get closed => 'Closed';

  @override
  String get capacity => 'capacity';

  @override
  String get amenities => 'Amenities';

  @override
  String get operating_hours => 'Operating Hours';

  @override
  String get open_in_maps => 'Open in Maps';

  @override
  String get apply_filters => 'Apply Filters';

  @override
  String get clear_filters => 'Clear Filters';

  @override
  String get create_workout => 'Create Workout';

  @override
  String get basic_info => 'Basic Info';

  @override
  String get exercise_selection => 'Exercise Selection';

  @override
  String get exercise_configuration => 'Configuration';

  @override
  String get review => 'Review & Save';

  @override
  String get workout_name => 'Workout Name';

  @override
  String get category => 'Category';

  @override
  String get estimated_duration => 'Estimated Duration';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get select_exercises => 'Select Exercises';

  @override
  String get selected_exercises => 'Selected Exercises';

  @override
  String get rest_time => 'Rest Time';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get chest_muscle => 'Chest';

  @override
  String get back => 'Back';

  @override
  String get shoulders => 'Shoulders';

  @override
  String get arms_muscle => 'Arms';

  @override
  String get legs => 'Legs';

  @override
  String get core => 'Core';

  @override
  String get glutes => 'Glutes';

  @override
  String get cardio => 'Cardio';

  @override
  String get membership_plans => 'Membership Plans';

  @override
  String get current_plan => 'CURRENT';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get downgrade => 'Downgrade';

  @override
  String get confirm_upgrade => 'Confirm Upgrade';

  @override
  String get pricing_breakdown => 'Pricing Breakdown';

  @override
  String get prorated_adjustment => 'Prorated Adjustment';

  @override
  String get total_due_today => 'Total Due Today';

  @override
  String get next_billing_date => 'Next Billing Date';

  @override
  String get payment_method => 'Payment Method';

  @override
  String get change_payment_method => 'Change Payment Method';

  @override
  String get agree_to_terms => 'I agree to the terms and conditions';

  @override
  String get plan_features => 'Plan Features';

  @override
  String get enable_notifications => 'Enable Notifications';

  @override
  String get notification_permission_denied => 'Notification Permission Denied';

  @override
  String get notification_permission_message =>
      'Please enable notifications in your device settings to receive workout reminders and updates.';

  @override
  String get open_settings => 'Open Settings';

  @override
  String get email_support => 'Email Support';

  @override
  String get phone_support => 'Phone Support';

  @override
  String get live_chat => 'Live Chat';
}
