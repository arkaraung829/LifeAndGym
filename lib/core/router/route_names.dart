/// Route names used throughout the application.
///
/// Using constants prevents typos and makes refactoring easier.
class RouteNames {
  RouteNames._();

  // Auth
  static const String splash = 'splash';
  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String onboarding = 'onboarding';

  // Main tabs
  static const String home = 'home';
  static const String workouts = 'workouts';
  static const String book = 'book';
  static const String progress = 'progress';
  static const String profile = 'profile';

  // Gym
  static const String gymFinder = 'gym-finder';
  static const String gymDetail = 'gym-detail';

  // Classes
  static const String classDetail = 'class-detail';
  static const String myBookings = 'my-bookings';

  // Workouts
  static const String workoutDetail = 'workout-detail';
  static const String activeWorkout = 'active-workout';
  static const String workoutSummary = 'workout-summary';
  static const String exerciseLibrary = 'exercise-library';
  static const String exerciseDetail = 'exercise-detail';
  static const String createWorkout = 'create-workout';

  // Training Plans
  static const String trainingPlans = 'training-plans';
  static const String trainingPlanDetail = 'training-plan-detail';

  // Progress
  static const String bodyMetrics = 'body-metrics';
  static const String personalRecords = 'personal-records';
  static const String goals = 'goals';

  // Profile
  static const String editProfile = 'edit-profile';
  static const String settings = 'settings';
  static const String notifications = 'notifications';
  static const String membership = 'membership';
}

/// Route paths used for navigation.
class RoutePaths {
  RoutePaths._();

  // Auth
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';

  // Main tabs (using shell route)
  static const String home = '/home';
  static const String workouts = '/workouts';
  static const String book = '/book';
  static const String progress = '/progress';
  static const String profile = '/profile';

  // Gym
  static const String gymFinder = '/gym-finder';
  static const String gymDetail = '/gym/:id';

  // Classes
  static const String classDetail = '/class/:id';
  static const String myBookings = '/my-bookings';

  // Workouts
  static const String workoutDetail = '/workout/:id';
  static const String activeWorkout = '/active-workout';
  static const String workoutSummary = '/workout-summary/:id';
  static const String exerciseLibrary = '/exercises';
  static const String exerciseDetail = '/exercise/:id';
  static const String createWorkout = '/create-workout';

  // Training Plans
  static const String trainingPlans = '/training-plans';
  static const String trainingPlanDetail = '/training-plan/:id';

  // Progress
  static const String bodyMetrics = '/body-metrics';
  static const String personalRecords = '/personal-records';
  static const String goals = '/goals';

  // Profile
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String membership = '/membership';
}
