// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get appName => 'Life & Gym';

  @override
  String get welcomeBack => 'ပြန်လည်ကြိုဆိုပါတယ်';

  @override
  String get signInToContinue =>
      'သင့်ကျန်းမာရေးခရီးကို ဆက်လက်လုပ်ဆောင်ရန် ဝင်ရောက်ပါ';

  @override
  String get email => 'အီးမေးလ်';

  @override
  String get enterYourEmail => 'သင့်အီးမေးလ်ကို ထည့်သွင်းပါ';

  @override
  String get password => 'စကားဝှက်';

  @override
  String get enterYourPassword => 'သင့်စကားဝှက်ကို ထည့်သွင်းပါ';

  @override
  String get forgotPassword => 'စကားဝှက်မေ့သွားပါသလား?';

  @override
  String get signIn => 'ဝင်ရောက်ရန်';

  @override
  String get signUp => 'အကောင့်ဖွင့်ရန်';

  @override
  String get or => 'သို့မဟုတ်';

  @override
  String get continueWithGoogle => 'Google ဖြင့်ဆက်လက်လုပ်ဆောင်ပါ';

  @override
  String get continueWithApple => 'Apple ဖြင့်ဆက်လက်လုပ်ဆောင်ပါ';

  @override
  String get dontHaveAccount => 'အကောင့်မရှိသေးဘူးလား? ';

  @override
  String get alreadyHaveAccount => 'အကောင့်ရှိပြီးသားလား? ';

  @override
  String get loginFailed => 'ဝင်ရောက်မှုမအောင်မြင်ပါ';

  @override
  String get redirectingToGoogle => 'Google သို့ ပြောင်းလဲနေသည်...';

  @override
  String get googleSignInFailed => 'Google ဝင်ရောက်မှု မအောင်မြင်ပါ';

  @override
  String get appleSignInComingSoon => 'Apple ဝင်ရောက်မှု မကြာမီလာပါမည်';

  @override
  String get goodMorning => 'မင်္ဂလာနံနက်ခင်းပါ';

  @override
  String get goodAfternoon => 'မင်္ဂလာနေ့လည်ခင်းပါ';

  @override
  String get goodEvening => 'မင်္ဂလာညနေခင်းပါ';

  @override
  String get guest => 'ဧည့်သည်';

  @override
  String get member => 'အသင်းဝင်';

  @override
  String get checkedIn => 'ဝင်ရောက်ပြီး';

  @override
  String get tapToCheckIn => 'ဝင်ရောက်ရန် နှိပ်ပါ';

  @override
  String get scanToCheckIn => 'ဝင်ရောက်ရန် စကင်ဖတ်ပါ';

  @override
  String get close => 'ပိတ်ရန်';

  @override
  String get noActiveMembership => 'အသင်းဝင်မှုမရှိပါ';

  @override
  String memberType(String type) {
    return '$type အသင်းဝင်';
  }

  @override
  String get noGymAvailable => 'ဂျင်မရှိပါ';

  @override
  String get notBusy => 'လူနည်း';

  @override
  String get moderate => 'အသင့်အတင့်';

  @override
  String get busy => 'လူများ';

  @override
  String occupancyStatus(String status, int current, int capacity) {
    return '$status • $current/$capacity ဦး';
  }

  @override
  String get workoutInProgress => 'လေ့ကျင့်နေဆဲ';

  @override
  String get todaysWorkout => 'ယနေ့လေ့ကျင့်မှု';

  @override
  String get continueYourSession => 'သင့်လေ့ကျင့်မှုကို ဆက်လက်လုပ်ဆောင်ပါ';

  @override
  String get startQuickWorkout => 'အမြန်လေ့ကျင့်မှု စတင်ပါ';

  @override
  String get tapToResume => 'ဆက်လက်လုပ်ဆောင်ရန် နှိပ်ပါ';

  @override
  String get noPlannedWorkouts => 'စီစဉ်ထားသော လေ့ကျင့်မှုမရှိပါ';

  @override
  String get resumeWorkout => 'လေ့ကျင့်မှု ဆက်လုပ်ရန်';

  @override
  String get startWorkout => 'လေ့ကျင့်မှု စတင်ရန်';

  @override
  String estimatedMinutes(int minutes) {
    return '~$minutes မိနစ်';
  }

  @override
  String get upcomingClasses => 'လာမည့်အတန်းများ';

  @override
  String get seeAll => 'အားလုံးကြည့်ရန်';

  @override
  String get noClassesScheduledToday => 'ယနေ့အတန်းမရှိပါ';

  @override
  String get booked => 'ကြိုတင်မှာထားပြီး';

  @override
  String spotsRemaining(int count) {
    return 'နေရာ $count ခု';
  }

  @override
  String get thisWeek => 'ဤအပတ်';

  @override
  String dayStreak(int count) {
    return '$count ရက်ဆက်တိုက်';
  }

  @override
  String workoutsCompleted(int completed, int total) {
    return '$completed/$total လေ့ကျင့်မှု ပြီးစီးပြီ';
  }

  @override
  String get home => 'ပင်မ';

  @override
  String get workouts => 'လေ့ကျင့်မှုများ';

  @override
  String get classes => 'အတန်းများ';

  @override
  String get progress => 'တိုးတက်မှု';

  @override
  String get profile => 'ကိုယ်ရေးအချက်အလက်';

  @override
  String get createAccount => 'အကောင့်ဖန်တီးရန်';

  @override
  String get startYourFitnessJourney => 'သင့်ကျန်းမာရေးခရီးကို ယနေ့စတင်ပါ';

  @override
  String get fullName => 'အမည်အပြည့်အစုံ';

  @override
  String get enterYourFullName => 'သင့်အမည်အပြည့်အစုံကို ထည့်သွင်းပါ';

  @override
  String get confirmPassword => 'စကားဝှက် အတည်ပြုပါ';

  @override
  String get reEnterYourPassword => 'သင့်စကားဝှက်ကို ပြန်ထည့်ပါ';

  @override
  String get bySigningUp => 'အကောင့်ဖွင့်ခြင်းဖြင့် ';

  @override
  String get termsOfService => 'ဝန်ဆောင်မှုစည်းမျဉ်းများ';

  @override
  String get and => ' နှင့် ';

  @override
  String get privacyPolicy => 'ကိုယ်ရေးအချက်အလက်မူဝါဒ';

  @override
  String get registrationFailed => 'အကောင့်ဖွင့်မှု မအောင်မြင်ပါ';

  @override
  String get resetPassword => 'စကားဝှက် ပြန်လည်သတ်မှတ်ရန်';

  @override
  String get enterEmailForReset =>
      'သင့်အီးမေးလ်လိပ်စာကို ထည့်သွင်းပါ။ စကားဝှက်ပြန်လည်သတ်မှတ်ရန် လမ်းညွှန်ချက်များ ပေးပို့ပါမည်။';

  @override
  String get sendResetLink => 'ပြန်လည်သတ်မှတ်ရန် လင့်ခ် ပေးပို့ပါ';

  @override
  String get backToLogin => 'ဝင်ရောက်မှုသို့ ပြန်သွားရန်';

  @override
  String get resetEmailSent =>
      'စကားဝှက်ပြန်လည်သတ်မှတ်ရန် အီးမေးလ် ပေးပို့ပြီးပါပြီ။ သင့် inbox ကို စစ်ဆေးပါ။';

  @override
  String get exercises => 'လေ့ကျင့်ခန်းများ';

  @override
  String get exerciseLibrary => 'လေ့ကျင့်ခန်း စာကြည့်တိုက်';

  @override
  String get searchExercises => 'လေ့ကျင့်ခန်းများ ရှာဖွေရန်...';

  @override
  String get allExercises => 'လေ့ကျင့်ခန်းအားလုံး';

  @override
  String get myWorkouts => 'ကျွန်ုပ်၏ လေ့ကျင့်မှုများ';

  @override
  String get templates => 'ပုံစံများ';

  @override
  String get history => 'မှတ်တမ်း';

  @override
  String get workoutHistory => 'လေ့ကျင့်မှု မှတ်တမ်း';

  @override
  String get noWorkoutsYet => 'လေ့ကျင့်မှု မရှိသေးပါ';

  @override
  String get startYourFirstWorkout =>
      'သင့်ပထမဆုံးလေ့ကျင့်မှုကို စတင်ပါ၊ မှတ်တမ်းကို ဤနေရာတွင် မြင်တွေ့ရပါမည်။';

  @override
  String get activeWorkout => 'လက်ရှိလေ့ကျင့်မှု';

  @override
  String get duration => 'ကြာချိန်';

  @override
  String get sets => 'အကြိမ်';

  @override
  String get reps => 'ပြန်လုပ်';

  @override
  String get weight => 'အလေးချိန်';

  @override
  String get addExercise => 'လေ့ကျင့်ခန်း ထည့်ရန်';

  @override
  String get finishWorkout => 'လေ့ကျင့်မှု အဆုံးသတ်ရန်';

  @override
  String get cancelWorkout => 'လေ့ကျင့်မှု ပယ်ဖျက်ရန်';

  @override
  String get schedules => 'အချိန်ဇယားများ';

  @override
  String get myBookings => 'ကျွန်ုပ်၏ ကြိုတင်မှာယူမှုများ';

  @override
  String get bookClass => 'အတန်း ကြိုတင်မှာယူရန်';

  @override
  String get cancelBooking => 'ကြိုတင်မှာယူမှု ပယ်ဖျက်ရန်';

  @override
  String get classDetails => 'အတန်း အသေးစိတ်';

  @override
  String get instructor => 'နည်းပြ';

  @override
  String get level => 'အဆင့်';

  @override
  String get statistics => 'စာရင်းအင်း';

  @override
  String get totalWorkouts => 'စုစုပေါင်း လေ့ကျင့်မှု';

  @override
  String get totalMinutes => 'စုစုပေါင်း မိနစ်';

  @override
  String get totalWeight => 'စုစုပေါင်း အလေးချိန်';

  @override
  String get currentStreak => 'လက်ရှိ ဆက်တိုက်';

  @override
  String get editProfile => 'ကိုယ်ရေးအချက်အလက် တည်းဖြတ်ရန်';

  @override
  String get save => 'သိမ်းဆည်းရန်';

  @override
  String get cancel => 'ပယ်ဖျက်ရန်';

  @override
  String get settings => 'ဆက်တင်များ';

  @override
  String get notifications => 'အသိပေးချက်များ';

  @override
  String get darkMode => 'အမှောင်မုဒ်';

  @override
  String get language => 'ဘာသာစကား';

  @override
  String get about => 'အကြောင်း';

  @override
  String get version => 'ဗားရှင်း';

  @override
  String get logout => 'ထွက်ရန်';

  @override
  String get logoutConfirmation => 'ထွက်လိုသည်မှာ သေချာပါသလား?';

  @override
  String get yes => 'ဟုတ်ကဲ့';

  @override
  String get no => 'မဟုတ်ပါ';

  @override
  String get error => 'အမှား';

  @override
  String get tryAgain => 'ထပ်ကြိုးစားပါ';

  @override
  String get loading => 'ဖွင့်နေသည်...';

  @override
  String get noInternetConnection => 'အင်တာနက်ချိတ်ဆက်မှု မရှိပါ';

  @override
  String get somethingWentWrong => 'တစ်ခုခုမှားသွားပါသည်';

  @override
  String get guestMode => 'ဧည့်သည်မုဒ်';

  @override
  String get guestModeMessage =>
      'အင်္ဂါရပ်များအားလုံးကို ဝင်ရောက်ရန် ဝင်ရောက်ပါ';

  @override
  String get signInNow => 'ယခု ဝင်ရောက်ပါ';

  @override
  String get getStarted => 'စတင်ရန်';

  @override
  String get skip => 'ကျော်ရန်';

  @override
  String get next => 'ရှေ့သို့';

  @override
  String get done => 'ပြီးပါပြီ';

  @override
  String get welcomeToLifeAndGym => 'Life & Gym မှ ကြိုဆိုပါတယ်';

  @override
  String get fitnessJourneyStarts => 'သင့်ကျန်းမာရေးခရီး ဤနေရာမှ စတင်သည်';

  @override
  String get exploreAsGuest => 'ဧည့်သည်အဖြစ် လေ့လာရန်';

  @override
  String get kg => 'ကီလို';

  @override
  String get lbs => 'ပေါင်';

  @override
  String get min => 'မိနစ်';

  @override
  String get sec => 'စက္ကန့်';

  @override
  String get validationEmailRequired => 'အီးမေးလ် လိုအပ်ပါသည်';

  @override
  String get validationEmailInvalid => 'မှန်ကန်သော အီးမေးလ် ထည့်သွင်းပါ';

  @override
  String get validationPasswordRequired => 'စကားဝှက် လိုအပ်ပါသည်';

  @override
  String get validationPasswordTooShort =>
      'စကားဝှက်သည် အနည်းဆုံး စာလုံး ၆ လုံး ရှိရမည်';

  @override
  String get validationPasswordsDoNotMatch => 'စကားဝှက်များ မတူညီပါ';

  @override
  String get validationNameRequired => 'အမည် လိုအပ်ပါသည်';

  @override
  String validationFieldRequired(String field) {
    return '$field လိုအပ်ပါသည်';
  }
}
