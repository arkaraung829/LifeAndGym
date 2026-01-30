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
  String get booked => 'မှာထားပြီး';

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

  @override
  String get goals_title => 'ရည်မှန်းချက်များ';

  @override
  String get goals_empty =>
      'ရည်မှန်းချက်မရှိသေးပါ - သင့်ပထမဆုံး ရည်မှန်းချက်ကို သတ်မှတ်ပါ!';

  @override
  String get create_goal => 'ရည်မှန်းချက် ဖန်တီးရန်';

  @override
  String get goal_name => 'ရည်မှန်းချက် အမည်';

  @override
  String get goal_description => 'ဖော်ပြချက်';

  @override
  String get goal_type => 'ရည်မှန်းချက် အမျိုးအစား';

  @override
  String get target_value => 'ပန်းတိုင်တန်ဖိုး';

  @override
  String get current_value => 'လက်ရှိတန်ဖိုး';

  @override
  String get target_date => 'ပန်းတိုင်ရက်စွဲ';

  @override
  String get days_remaining => 'ကျန်ရှိနေသော ရက်';

  @override
  String get overdue => 'သတ်မှတ်ရက်လွန်';

  @override
  String get update_progress => 'တိုးတက်မှု အပ်ဒိတ်လုပ်ရန်';

  @override
  String get mark_complete => 'ပြီးစီးကြောင်း အမှတ်အသားပြုရန်';

  @override
  String get weight_loss => 'ကိုယ်အလေးချိန် လျှော့ချခြင်း';

  @override
  String get muscle_gain => 'ကြွက်သား တိုးခြင်း';

  @override
  String get strength => 'ခွန်အား';

  @override
  String get endurance => 'ခံနိုင်ရည်';

  @override
  String get flexibility => 'ပျော့ပြောင်းမှု';

  @override
  String get body_fat => 'ကိုယ်တွင်းအဆီ';

  @override
  String get consistency => 'တည်ငြိမ်မှု';

  @override
  String get filter_all => 'အားလုံး';

  @override
  String get filter_active => 'လက်ရှိလုပ်ဆောင်နေဆဲ';

  @override
  String get filter_completed => 'ပြီးစီးပြီး';

  @override
  String get body_metrics => 'ခန္ဓာကိုယ် တိုင်းတာမှုများ';

  @override
  String get body_metrics_empty =>
      'တိုင်းတာမှုမရှိသေးပါ - သင့်ပထမဆုံး တိုင်းတာမှုကို မှတ်တမ်းတင်ပါ!';

  @override
  String get add_entry => 'မှတ်တမ်း ထည့်ရန်';

  @override
  String get latest_metrics => 'နောက်ဆုံး တိုင်းတာမှုများ';

  @override
  String get bmi => 'BMI';

  @override
  String get muscle_mass => 'ကြွက်သား ပမာណ';

  @override
  String get measurements => 'တိုင်းတာမှုများ';

  @override
  String get chest => 'ရင်ဘတ်';

  @override
  String get waist => 'ခါး';

  @override
  String get hips => 'တင်ပါး';

  @override
  String get arms => 'လက်မောင်း';

  @override
  String get thighs => 'ပေါင်';

  @override
  String get trends => 'လမ်းကြောင်းများ';

  @override
  String get overview => 'ခြုံငုံသုံးသပ်ချက်';

  @override
  String get total_entries => 'စုစုပေါင်း မှတ်တမ်းများ';

  @override
  String get days_tracked => 'မှတ်တမ်းတင်ထားသော ရက်';

  @override
  String get recorded_at => 'မှတ်တမ်းတင်ထားသည့် အချိန်';

  @override
  String get bmi_underweight => 'ကိုယ်အလေးချိန်နည်း';

  @override
  String get bmi_normal => 'ပုံမှန်';

  @override
  String get bmi_overweight => 'ကိုယ်အလေးချိန်လွန်';

  @override
  String get bmi_obese => 'အဝလွန်';

  @override
  String get find_gyms => 'ဂျင်များ ရှာဖွေရန်';

  @override
  String get search_gyms => 'ဂျင်များ ရှာဖွေရန်...';

  @override
  String get no_gyms_found => 'ဂျင်မတွေ့ပါ';

  @override
  String get open_now => 'ယခု ဖွင့်နေသည်';

  @override
  String get closed => 'ပိတ်သည်';

  @override
  String get capacity => 'ဆံ့နိုင်မှု';

  @override
  String get amenities => 'အဆင်ပြေစေသော အရာများ';

  @override
  String get operating_hours => 'ဖွင့်ချိန်များ';

  @override
  String get open_in_maps => 'မြေပုံတွင် ဖွင့်ရန်';

  @override
  String get apply_filters => 'စစ်ထုတ်မှုများ အသုံးပြုရန်';

  @override
  String get clear_filters => 'စစ်ထုတ်မှုများ ရှင်းလင်းရန်';

  @override
  String get create_workout => 'လေ့ကျင့်မှု ဖန်တီးရန်';

  @override
  String get basic_info => 'အခြေခံ အချက်အလက်';

  @override
  String get exercise_selection => 'လေ့ကျင့်ခန်း ရွေးချယ်မှု';

  @override
  String get exercise_configuration => 'စီမံဖွဲ့စည်းမှု';

  @override
  String get review => 'ပြန်လည်သုံးသပ်ပြီး သိမ်းဆည်းရန်';

  @override
  String get workout_name => 'လေ့ကျင့်မှု အမည်';

  @override
  String get category => 'အမျိုးအစား';

  @override
  String get estimated_duration => 'ခန့်မှန်းခြေ ကြာချိန်';

  @override
  String get difficulty => 'ခက်ခဲမှု အဆင့်';

  @override
  String get select_exercises => 'လေ့ကျင့်ခန်းများ ရွေးချယ်ရန်';

  @override
  String get selected_exercises => 'ရွေးချယ်ထားသော လေ့ကျင့်ခန်းများ';

  @override
  String get rest_time => 'အနားယူချိန်';

  @override
  String get beginner => 'အစပြုသူ';

  @override
  String get intermediate => 'အလယ်အလတ်';

  @override
  String get advanced => 'အဆင့်မြင့်';

  @override
  String get chest_muscle => 'ရင်ဘတ်';

  @override
  String get back => 'ကျောရိုး';

  @override
  String get shoulders => 'ပခုံး';

  @override
  String get arms_muscle => 'လက်မောင်း';

  @override
  String get legs => 'ခြေထောက်';

  @override
  String get core => 'ကိုယ်လတ်';

  @override
  String get glutes => 'တင်ပါးကြွက်သား';

  @override
  String get cardio => 'နှလုံးသွေးကြော';

  @override
  String get membership_plans => 'အသင်းဝင်အစီအစဉ်များ';

  @override
  String get current_plan => 'လက်ရှိ';

  @override
  String get upgrade => 'အဆင့်မြှင့်ရန်';

  @override
  String get downgrade => 'အဆင့်လျှော့ရန်';

  @override
  String get confirm_upgrade => 'အဆင့်မြှင့်မှု အတည်ပြုရန်';

  @override
  String get pricing_breakdown => 'စျေးနှုန်း အသေးစိတ်';

  @override
  String get prorated_adjustment => 'အချိန်အလိုက် ချိန်ညှိမှု';

  @override
  String get total_due_today => 'ယနေ့ စုစုပေါင်း ပေးရမည့်ပမာဏ';

  @override
  String get next_billing_date => 'နောက်ထပ် ငွေတောင်းခံမည့် ရက်စွဲ';

  @override
  String get payment_method => 'ငွေပေးချေမှု နည်းလမ်း';

  @override
  String get change_payment_method => 'ငွေပေးချေမှု နည်းလမ်း ပြောင်းရန်';

  @override
  String get agree_to_terms => 'စည်းမျဉ်းစည်းကမ်းများကို သဘောတူပါသည်';

  @override
  String get plan_features => 'အစီအစဉ် အင်္ဂါရပ်များ';

  @override
  String get enable_notifications => 'အသိပေးချက်များ ဖွင့်ရန်';

  @override
  String get notification_permission_denied =>
      'အသိပေးချက် ခွင့်ပြုချက် ငြင်းပယ်ထားသည်';

  @override
  String get notification_permission_message =>
      'လေ့ကျင့်မှု သတိပေးချက်များနှင့် အပ်ဒိတ်များ လက်ခံရရှိရန် သင့်ကိရိယာ ဆက်တင်များတွင် အသိပေးချက်များကို ဖွင့်ပေးပါ။';

  @override
  String get open_settings => 'ဆက်တင်များ ဖွင့်ရန်';

  @override
  String get email_support => 'အီးမေးလ် အကူအညီ';

  @override
  String get phone_support => 'ဖုန်း အကူအညီ';

  @override
  String get live_chat => 'တိုက်ရိုက် စကားပြောဆိုမှု';

  @override
  String get activeSession => 'လက်ရှိလုပ်ဆောင်မှု';

  @override
  String get showQrCode => 'QR ကုဒ် ပြရန်';

  @override
  String workoutPlansAvailable(int count) {
    return '$count လေ့ကျင့်မှု အစီအစဉ် ရရှိနိုင်သည်';
  }

  @override
  String get quickWorkout => 'အမြန် လေ့ကျင့်မှု';

  @override
  String get quickWorkoutDescription => 'အခမဲ့ပုံစံ လေ့ကျင့်မှု စတင်ပါ';

  @override
  String get yourWorkoutPlans => 'သင့် လေ့ကျင့်မှု အစီအစဉ်များ';

  @override
  String get viewAllWorkouts => 'လေ့ကျင့်မှုများ အားလုံးကြည့်ရန်';

  @override
  String get failedToStartWorkout => 'လေ့ကျင့်မှု စတင်မှု မအောင်မြင်ပါ';

  @override
  String get viewAllGyms => 'ဂျင်များ အားလုံးကြည့်ရန်';

  @override
  String get myProfile => 'ကျွန်ုပ်၏ ကိုယ်ရေးအချက်အလက်';

  @override
  String get membership => 'အသင်းဝင်အခြေအနေ';

  @override
  String get signOut => 'ထွက်ရန်';

  @override
  String get signOutConfirmation => 'ထွက်လိုသည်မှာ သေချာပါသလား?';

  @override
  String get settingsComingSoon => 'ဆက်တင် မကြာမီလာမည်';

  @override
  String get selectGym => 'ဂျင် ရွေးချယ်ရန်';

  @override
  String get workout => 'လေ့ကျင့်မှု';

  @override
  String get logAtLeastOneSet =>
      'အဆုံးသတ်ခြင်းမပြုမီ အနည်းဆုံး တစ်ကြိမ် မှတ်တမ်းတင်ပါ';

  @override
  String get completeWorkout => 'လေ့ကျင့်မှု ပြီးစီးပါပြီ';

  @override
  String completeWorkoutConfirmation(int count) {
    return 'သင်သည် $count ကြိမ် မှတ်တမ်းတင်ပြီးပါပြီ။ ဤလေ့ကျင့်မှုကို ပြီးစီးမည်လား?';
  }

  @override
  String get complete => 'ပြီးစီး';

  @override
  String get cancelWorkoutConfirmation =>
      'ပယ်ဖျက်လိုသည်မှာ သေချာပါသလား? တိုးတက်မှုအားလုံး ပျောက်သွားပါမည်။';

  @override
  String get keepGoing => 'ဆက်လုပ်မည်';

  @override
  String get failedToCancelWorkout => 'လေ့ကျင့်မှု ပယ်ဖျက်မှု မအောင်မြင်ပါ';

  @override
  String get noActiveWorkoutSession => 'လက်ရှိလေ့ကျင့်မှု မရှိပါ';

  @override
  String get addSet => 'အကြိမ် ထည့်ရန်';

  @override
  String get selectExercise => 'လေ့ကျင့်ခန်း ရွေးချယ်ရန်';

  @override
  String get restTimer => 'အနားယူချိန်တိုင်းကိရိယာ';

  @override
  String get skipRest => 'အနားမယူတော့ပါ';

  @override
  String get bookClasses => 'အတန်းများ ကြိုတင်မှာယူရန်';

  @override
  String get bookAClass => 'အတန်း ကြိုတင်မှာယူရန်';

  @override
  String get book => 'မှာယူမည်';

  @override
  String get joinWaitlist => 'စောင့်ဆိုင်းစာရင်းသို့ ဝင်ရန်';

  @override
  String get yesCancel => 'ဟုတ်ကဲ့၊ ပယ်ဖျက်မည်';

  @override
  String get classBookedSuccess =>
      'အတန်း ကြိုတင်မှာယူပြီးပါပြီ! အတန်းမတိုင်မီ ၃၀ မိနစ်က သတိပေးချက် ရရှိပါမည်။';

  @override
  String get cancelBookingConfirmation =>
      'ကြိုတင်မှာယူမှုကို ပယ်ဖျက်လိုသည်မှာ သေချာပါသလား?';

  @override
  String get bookingCancelled => 'ကြိုတင်မှာယူမှု ပယ်ဖျက်ပြီးပါပြီ';

  @override
  String get today => 'ယနေ့';

  @override
  String get tomorrow => 'မနက်ဖြန်';

  @override
  String get monday => 'တနင်္လာ';

  @override
  String get tuesday => 'အင်္ဂါ';

  @override
  String get wednesday => 'ဗုဒ္ဓဟူး';

  @override
  String get thursday => 'ကြာသပတေး';

  @override
  String get friday => 'သောကြာ';

  @override
  String get saturday => 'စနေ';

  @override
  String get sunday => 'တနင်္ဂနွေ';

  @override
  String get all => 'အားလုံး';

  @override
  String get yoga => 'ယောဂ';

  @override
  String get hiit => 'HIIT';

  @override
  String get spin => 'စပင်';

  @override
  String get pilates => 'ပိုင်လိတ်';

  @override
  String get full => 'ပြည့်ပြီ';

  @override
  String get noUpcomingBookings => 'လာမည့် ကြိုတင်မှာယူမှု မရှိပါ';

  @override
  String get noClassesScheduled => 'စီစဉ်ထားသော အတန်း မရှိပါ';

  @override
  String get notificationPermissionRequired =>
      'အသိပေးချက် ခွင့်ပြုချက် လိုအပ်သည်';

  @override
  String dailyReminderSet(String time) {
    return 'နေ့စဉ် သတိပေးချက်ကို $time အတွက် သတ်မှတ်ပြီးပါပြီ';
  }

  @override
  String get deleteAccount => 'အကောင့် ဖျက်ရန်';

  @override
  String get profileUpdated => 'ကိုယ်ရေးအချက်အလက် အပ်ဒိတ်လုပ်ပြီးပါပြီ';

  @override
  String get changePhoto => 'ဓာတ်ပုံ ပြောင်းရန်';

  @override
  String get uploading => 'တင်နေသည်...';

  @override
  String get takePhoto => 'ဓာတ်ပုံ ရိုက်ရန်';

  @override
  String get chooseFromGallery => 'ပုံစုမှ ရွေးချယ်ရန်';

  @override
  String get removePhoto => 'ဓာတ်ပုံ ဖယ်ရှားရန်';

  @override
  String get removePhotoConfirmation =>
      'သင့်ပရိုဖိုင်ဓာတ်ပုံကို ဖယ်ရှားလိုသည်မှာ သေချာပါသလား?';

  @override
  String get remove => 'ဖယ်ရှားရန်';

  @override
  String get cameraPermissionRequired => 'ကင်မရာ ခွင့်ပြုချက် လိုအပ်သည်';

  @override
  String get photoLibraryPermissionRequired =>
      'ဓာတ်ပုံစု ခွင့်ပြုချက် လိုအပ်သည်';

  @override
  String get openSettings => 'ဆက်တင်များ ဖွင့်ရန်';
}
