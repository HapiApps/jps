import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// -----------------------------------------------------------------------
/// LANGUAGE MANAGER  (English / Tamil / Hindi)
/// -----------------------------------------------------------------------
/// Default is English. User's choice is saved in SharedPreferences.
/// -----------------------------------------------------------------------
enum AppLang { english, tamil, hindi }

class LanguageManager extends ChangeNotifier {
  LanguageManager._internal();
  static final LanguageManager instance = LanguageManager._internal();

  static const String _prefKey = "app_lang";
  static const String _oldPrefKey = "is_tamil"; // migration for old users

  AppLang lang = AppLang.english;

  // Backward compatible getters (old code still works)
  bool get isTamil => lang == AppLang.tamil;
  bool get isHindi => lang == AppLang.hindi;
  bool get isEnglish => lang == AppLang.english;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  /// Call ONCE at app startup (main() before runApp or in splash screen)
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);

    if (saved != null) {
      lang = AppLang.values.firstWhere(
            (e) => e.name == saved,
        orElse: () => AppLang.english,
      );
    } else if (prefs.getBool(_oldPrefKey) == true) {
      lang = AppLang.tamil; // old users who had Tamil selected
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(AppLang newLang) async {
    lang = newLang;
    notifyListeners();
    _rebuildAllScreens(); // ✅ ella screens-um udane refresh aagum
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, newLang.name);
  }

  /// Ella open screens-um (stack-la irukkuradhu kooda) rebuild pannum,
  /// so `constValue.xxx` new language-la refresh aagum.
  void _rebuildAllScreens() {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(rebuild);
  }

  /// English -> Tamil -> Hindi -> English ...
  Future<void> toggle() async {
    final next = AppLang.values[(lang.index + 1) % AppLang.values.length];
    await setLanguage(next);
  }
}

/// Language picker popup. Call: showLanguagePicker(context);
void showLanguagePicker(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (ctx) => CupertinoActionSheet(
      title: const Text("Select Language"),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            LanguageManager.instance.setLanguage(AppLang.english);
            Navigator.pop(ctx);
          },
          child: const Text("English"),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            LanguageManager.instance.setLanguage(AppLang.tamil);
            Navigator.pop(ctx);
          },
          child: const Text("தமிழ்"),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            LanguageManager.instance.setLanguage(AppLang.hindi);
            Navigator.pop(ctx);
          },
          child: const Text("हिन्दी"),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDestructiveAction: true,
        onPressed: () => Navigator.pop(ctx),
        child: const Text("Cancel"),
      ),
    ),
  );
}

final ConstantValues constValue = ConstantValues._();

class ConstantValues {
  ConstantValues._();

  AppLang get _lang => LanguageManager.instance.lang;

  /// _t(English, Tamil, Hindi)
  String _t(String en, String ta, String hi) {
    switch (_lang) {
      case AppLang.tamil:
        return ta;
      case AppLang.hindi:
        return hi;
      case AppLang.english:
        return en;
    }
  }

  final String appName = "Aswin Fire System";
  final String checkPdf = "pdf";
  final String rupeeSign = "₹";

  String get comName => _t("by HapiApps Software Lab",
      "HapiApps மென்பொருள் ஆய்வகம் வழங்குகிறது", "HapiApps सॉफ़्टवेयर लैब द्वारा");

  String get appHeading => _t("Daily Activity Report",
      "தினசரி பணி அறிக்கை", "दैनिक गतिविधि रिपोर्ट");

  String get success => _t("Added Successfully",
      "வெற்றிகரமாக சேர்க்கப்பட்டது", "सफलतापूर्वक जोड़ा गया");

  String get visitSuccess => _t(
      "Daily Work Activity Report Added Successfully",
      "தினசரி பணி செயல்பாடு அறிக்கை வெற்றிகரமாக சேர்க்கப்பட்டது",
      "दैनिक कार्य गतिविधि रिपोर्ट सफलतापूर्वक जोड़ी गई");

  String get successTask => _t("Task Added Successfully",
      "பணி வெற்றிகரமாக சேர்க்கப்பட்டது", "कार्य सफलतापूर्वक जोड़ा गया");

  String get updated => _t("Updated Successfully",
      "வெற்றிகரமாக புதுப்பிக்கப்பட்டது", "सफलतापूर्वक अपडेट किया गया");

  String get deleted => _t("Deleted Successfully",
      "வெற்றிகரமாக நீக்கப்பட்டது", "सफलतापूर्वक हटाया गया");

  String get failed => _t("Failed", "தோல்வி", "विफल");

  String get receiveOtp => _t("Didn't receive OTP?",
      "OTP கிடைக்கவில்லையா?", "OTP नहीं मिला?");

  String get resend => _t("RESEND", "மீண்டும் அனுப்பு", "दोबारा भेजें");

  String get name => _t("Company Name", "நிறுவனத்தின் பெயர்", "कंपनी का नाम");

  String get empName => _t("Employee Name", "பணியாளர் பெயர்", "कर्मचारी का नाम");

  String get companyName =>
      _t("Company Name", "நிறுவனத்தின் பெயர்", "कंपनी का नाम");

  String get emgName =>
      _t("Emergency Name", "அவசர தொடர்பு பெயர்", "आपातकालीन संपर्क नाम");

  String get inTime => _t("In Time", "வருகை நேரம்", "आने का समय");

  String get outTime => _t("Out Time", "வெளியேறும் நேரம்", "जाने का समय");

  String get mobileNumber =>
      _t("WhatsApp Number", "வாட்ஸ்அப் எண்", "व्हाट्सएप नंबर");

  String get panNumber => _t("PAN Number", "பான் எண்", "पैन नंबर");

  String get dateOfBirth => _t("Date Of Birth", "பிறந்த தேதி", "जन्म तिथि");

  String get dateOfJoin =>
      _t("Date Of Joining", "சேர்ந்த தேதி", "जॉइनिंग की तारीख");

  String get bloodGroup => _t("Blood Group", "இரத்த வகை", "रक्त समूह");

  String get lastWrkDay =>
      _t("Last Working Day", "கடைசி பணி நாள்", "अंतिम कार्य दिवस");

  String get applyDate =>
      _t("Applied Date", "விண்ணப்பித்த தேதி", "आवेदन की तारीख");

  String get addGradeAmountFirst => _t(
      "Please go to Settings to add a grade and its amount before proceeding",
      "தொடர வேண்டுமெனில் அமைப்புகளுக்குச் சென்று ஒரு தரம் மற்றும் அதன் தொகையைச் சேர்க்கவும்",
      "आगे बढ़ने से पहले कृपया सेटिंग्स में जाकर एक ग्रेड और उसकी राशि जोड़ें");

  String get addVisit => _t(
      "Add Daily Work Activity Report",
      "தினசரி பணி செயல்பாடு அறிக்கை சேர்க்க",
      "दैनिक कार्य गतिविधि रिपोर्ट जोड़ें");

  String get visit => _t("Visits", "வருகைகள்", "विज़िट");

  String get visitRepo => _t("Daily Work Activity Report",
      "தினசரி பணி செயல்பாடு அறிக்கை", "दैनिक कार्य गतिविधि रिपोर्ट");

  String get planDay => _t("What is Your Plan For the Day?",
      "இன்றைய திட்டம் என்ன?", "आज की आपकी योजना क्या है?");

  String get login => _t("LOGIN", "உள்நுழைய", "लॉगिन");

  String get next => _t("Next", "அடுத்து", "अगला");

  String get addMore => _t("Add More", "மேலும் சேர்", "और जोड़ें");

  String get verify => _t("Verify", "சரிபார்", "सत्यापित करें");

  String get remember => _t("Remember Me", "என்னை நினைவில் கொள்", "मुझे याद रखें");

  String get forgot =>
      _t("Forgot Password?", "கடவுச்சொல் மறந்துவிட்டதா?", "पासवर्ड भूल गए?");

  String get account => _t("Don't have an account?",
      "கணக்கு இல்லையா?", "खाता नहीं है?");

  String get signUp => _t("Sign Up", "பதிவு செய்ய", "साइन अप करें");

  String get phoneNumber =>
      _t("Mobile Number", "கைபேசி எண்", "मोबाइल नंबर");

  String get phoneNumber2 => _t("Mobile No", "கைபேசி எண்", "मोबाइल नं.");

  String get whatsappNo =>
      _t("WhatsApp Number", "வாட்ஸ்அப் எண்", "व्हाट्सएप नंबर");

  String get password => _t("Password", "கடவுச்சொல்", "पासवर्ड");

  String get amount => _t("Amount", "தொகை", "राशि");

  String get expenses => _t("Expenses", "செலவுகள்", "खर्चे");

  String get bus => _t("Train/Bus Fare", "ரயில்/பேருந்து கட்டணம்",
      "ट्रेन/बस किराया");

  String get bus2 => _t("Train/Bus\nFare", "ரயில்/பேருந்து\nகட்டணம்",
      "ट्रेन/बस\nकिराया");

  String get auto => _t("Auto Fare", "ஆட்டோ கட்டணம்", "ऑटो किराया");

  String get auto2 => _t("Auto\nFare", "ஆட்டோ\nகட்டணம்", "ऑटो\nकिराया");

  String get rent => _t("Lodge/Room Rent", "லாட்ஜ்/அறை வாடகை",
      "लॉज/कमरे का किराया");

  String get rent2 => _t("Lodge/Room\nRent", "லாட்ஜ்/அறை\nவாடகை",
      "लॉज/कमरे का\nकिराया");

  String get food => _t("Food", "உணவு", "भोजन");

  String get purchase =>
      _t("Material Purchase", "பொருள் வாங்குதல்", "सामग्री खरीद");

  String get purchase2 =>
      _t("Material\nPurchase", "பொருள்\nவாங்குதல்", "सामग्री\nखरीद");

  String get total => _t("Total", "மொத்தம்", "कुल");

  String get lineName => _t("Line Name", "லைன் பெயர்", "लाइन का नाम");

  String get productName => _t("Name", "பெயர்", "नाम");

  String get brand => _t("Brand", "பிராண்ட்", "ब्रांड");

  String get batch => _t("Batch No", "பேட்ச் எண்", "बैच नंबर");

  String get mrp => _t("MRP", "எம்.ஆர்.பி", "एमआरपी");

  String get userName => _t("User Name", "பயனர் பெயர்", "उपयोगकर्ता नाम");

  String get startDate => _t("Start Date", "தொடக்க தேதி", "प्रारंभ तिथि");

  String get endDate => _t("End Date", "முடிவு தேதி", "समाप्ति तिथि");

  String get planWork =>
      _t("Today's Work Plan", "இன்றைய பணி திட்டம்", "आज की कार्य योजना");

  String get planDayWork =>
      _t("Day Work Plan", "நாள் வேலைத் திட்டம்", "दैनिक कार्य योजना");

  String get finishedWork => _t("Description Of Finished Work",
      "முடிக்கப்பட்ட பணி விவரம்", "पूर्ण कार्य का विवरण");

  String get pendingWork => _t("Description Of Pending Work",
      "நிலுவையில் உள்ள பணி விவரம்", "लंबित कार्य का विवरण");

  String get line => _t("Lines", "லைன்கள்", "लाइनें");

  String get track => _t("Track", "டிராக்", "ट्रैक");

  String get trackR => _t("Track Report", "டிராக் அறிக்கை", "ट्रैक रिपोर्ट");

  String get trackD =>
      _t("Track Details", "டிராக் விவரங்கள்", "ट्रैक विवरण");

  String get lineCus =>
      _t("Line Customers", "லைன் வாடிக்கையாளர்கள்", "लाइन ग्राहक");

  String get lineManagement =>
      _t("Line Management", "லைன் மேலாண்மை", "लाइन प्रबंधन");

  String get report => _t("Report", "அறிக்கை", "रिपोर्ट");

  String get tasks => _t("Tasks", "பணிகள்", "कार्य");

  String get users => _t("Employees", "பணியாளர்கள்", "कर्मचारी");

  String get addTask => _t("Add Task", "பணி சேர்க்க", "कार्य जोड़ें");

  String get createEmployee =>
      _t("Create Employee", "பணியாளர் உருவாக்க", "कर्मचारी बनाएं");

  String get attReport =>
      _t("Attendance Report", "வருகை அறிக்கை", "उपस्थिति रिपोर्ट");

  String get attendance => _t("Attendance", "வருகை", "उपस्थिति");

  String get projectAttendance => _t("    Project\nAttendance",
      "    திட்ட\nவருகை", "    प्रोजेक्ट\nउपस्थिति");

  String get attendanceReport => _t("Attendance\n    Report",
      "வருகை\n    அறிக்கை", "उपस्थिति\n    रिपोर्ट");

  String get employee => _t("Employees", "பணியாளர்கள்", "कर्मचारी");

  String get reportDash =>
      _t("Report DashBoard", "அறிக்கை டாஷ்போர்டு", "रिपोर्ट डैशबोर्ड");

  String get customers => _t("Customers", "வாடிக்கையாளர்கள்", "ग्राहक");

  String get customer => _t("Customer", "வாடிக்கையாளர்", "ग्राहक");

  String get customer1 =>
      _t("   Customer", "   வாடிக்கையாளர்", "   ग्राहक");

  String get customerName =>
      _t("Company Name", "நிறுவனத்தின் பெயர்", "कंपनी का नाम");

  String get updateCustomer => _t("Update Customer",
      "வாடிக்கையாளரை புதுப்பிக்க", "ग्राहक अपडेट करें");

  String get addCustomer =>
      _t("Add Customer", "வாடிக்கையாளரை சேர்க்க", "ग्राहक जोड़ें");

  String get addContact =>
      _t("Add Customer", "வாடிக்கையாளரை சேர்க்க", "ग्राहक जोड़ें");

  String get contactDetails => _t("Customer Details",
      "வாடிக்கையாளர் விவரங்கள்", "ग्राहक विवरण");

  String get contactName =>
      _t("Customer Name", "வாடிக்கையாளர் பெயர்", "ग्राहक का नाम");

  String get contact => _t("Customer", "வாடிக்கையாளர்", "ग्राहक");

  String get reportDashboard => _t("Reports Dashboard",
      "அறிக்கைகள் டாஷ்போர்டு", "रिपोर्ट डैशबोर्ड");

  String get customerDetails =>
      _t("Company Details", "நிறுவன விவரங்கள்", "कंपनी विवरण");

  String get address =>
      _t("Company Address", "நிறுவன முகவரி", "कंपनी का पता");

  String get observations =>
      _t("Observations", "கவனிப்புகள்", "अवलोकन");

  String get expenseType => _t("Expense Type", "செலவு வகை", "खर्च का प्रकार");

  String get add => _t("Add", "சேர்", "जोड़ें");

  String get addLine => _t("Create Line", "லைன் உருவாக்க", "लाइन बनाएं");

  String get updateLine =>
      _t("Update Line", "லைன் புதுப்பிக்க", "लाइन अपडेट करें");

  String get createCustomer =>
      _t("Add Customer", "வாடிக்கையாளரை சேர்க்க", "ग्राहक जोड़ें");

  String get emergencyNumber =>
      _t("Emergency Number", "அவசர எண்", "आपातकालीन नंबर");

  String get addComment =>
      _t("Add Comment", "கருத்து சேர்க்க", "टिप्पणी जोड़ें");

  String get doorNo => _t("Door No", "கதவு எண்", "मकान नंबर");

  String get streetAddress => _t("Street Name", "தெரு பெயர்", "गली का नाम");

  String get area => _t("Area", "பகுதி", "क्षेत्र");

  String get city => _t("City", "நகரம்", "शहर");

  String get state => _t("State", "மாநிலம்", "राज्य");

  String get country => _t("Country", "நாடு", "देश");

  String get pinCode => _t("Pincode", "அஞ்சல் குறியீடு", "पिन कोड");

  String get firstName => _t("First  Name", "முதல் பெயர்", "पहला नाम");

  String get middleName => _t("Middle  Name", "நடுப் பெயர்", "मध्य नाम");

  String get lastName => _t("Last  Name", "கடைசி பெயர்", "उपनाम");

  String get emailId =>
      _t("Email  Id", "மின்னஞ்சல் முகவரி", "ईमेल आईडी");

  String get proDis =>
      _t("Product discussed", "பேசப்பட்ட தயாரிப்பு", "चर्चा किया गया उत्पाद");

  String get disPoints =>
      _t("Discussion Points", "விவாதப் புள்ளிகள்", "चर्चा के बिंदु");

  String get addPoints => _t("Actions to be taken",
      "எடுக்க வேண்டிய நடவடிக்கைகள்", "की जाने वाली कार्रवाई");

  String get addressNo => _t("Door No", "கதவு எண்", "मकान नंबर");

  String get comArea => _t("Street Name", "தெரு பெயர்", "गली का नाम");

  String get landmark => _t("Landmark", "அடையாளம்", "लैंडमार्क");

  String get referredBy =>
      _t("Referred  By", "பரிந்துரைத்தவர்", "संदर्भित करने वाला");

  String get type => _t(" Task type", " பணி வகை", " कार्य का प्रकार");

  String get cusType => _t(" Customer Category",
      " வாடிக்கையாளர் வகை", " ग्राहक श्रेणी");

  String get role => _t("Role", "பணி பதவி", "भूमिका");

  String get comment => _t("View Full History",
      "முழு வரலாற்றைக் காண", "पूरा इतिहास देखें");

  String get comments => _t("Comments", "கருத்துகள்", "टिप्पणियाँ");

  String get leadStatus =>
      _t("Lead Categories", "லீட் வகைகள்", "लीड श्रेणियाँ");

  String get visitType =>
      _t("Call Task type", "அழைப்பு பணி வகை", "कॉल कार्य का प्रकार");

  String get qStatus =>
      _t("Quotation Status", "மேற்கோள் நிலை", "कोटेशन की स्थिति");

  String get qRequired =>
      _t("Quotation Required", "மேற்கோள் தேவை", "कोटेशन आवश्यक");

  String get status => _t("Status", "நிலை", "स्थिति");

  String get selfProductPlacement => _t("Self Product Placement",
      "சொந்த தயாரிப்பு வைப்பு", "स्वयं के उत्पाद की प्लेसमेंट");

  String get competitorProductPlacement => _t(
      "Competitor Product Placement",
      "போட்டியாளர் தயாரிப்பு வைப்பு",
      "प्रतियोगी उत्पाद की प्लेसमेंट");

  String get noData => _t("No Data Found",
      "தரவு எதுவும் கிடைக்கவில்லை", "कोई डेटा नहीं मिला");

  String get noTask => _t("No Task Found",
      "பணி எதுவும் கிடைக்கவில்லை", "कोई कार्य नहीं मिला");

  String get noUser => _t("No User Found",
      "பயனர் எதுவும் கிடைக்கவில்லை", "कोई उपयोगकर्ता नहीं मिला");

  String get noCase => _t("No Case Found",
      "வழக்கு எதுவும் கிடைக்கவில்லை", "कोई केस नहीं मिला");

  String get noAttendance => _t("No Attendance Found",
      "வருகை பதிவு கிடைக்கவில்லை", "कोई उपस्थिति नहीं मिली");

  String get noAttendanceToday => _t("No Attendance Marked Today",
      "இன்று வருகை பதிவு செய்யப்படவில்லை", "आज कोई उपस्थिति दर्ज नहीं की गई");

  String get noProject => _t("No Project Found",
      "திட்டம் எதுவும் கிடைக்கவில்லை", "कोई प्रोजेक्ट नहीं मिला");

  String get noProduct => _t("No Products Found",
      "தயாரிப்புகள் எதுவும் கிடைக்கவில்லை", "कोई उत्पाद नहीं मिला");

  String get noCustomer => _t("No Customers Found",
      "வாடிக்கையாளர்கள் யாரும் கிடைக்கவில்லை", "कोई ग्राहक नहीं मिला");

  /// VALIDATE
  String get required => _t("This field is required",
      "இந்தப் புலம் அவசியம்", "यह फ़ील्ड आवश्यक है");

  String get numberRequired => _t("Check Your Phone Number",
      "உங்கள் கைபேசி எண்ணை சரிபார்க்கவும்", "अपना फ़ोन नंबर जांचें");

  String get pincodeRequired => _t("Please Check Your PinCode Number",
      "உங்கள் அஞ்சல் குறியீட்டை சரிபார்க்கவும்", "कृपया अपना पिन कोड जांचें");

  String get emailRequired => _t("Please Enter Your Valid Email",
      "சரியான மின்னஞ்சலை உள்ளிடவும்", "कृपया सही ईमेल दर्ज करें");

  String get aadhaarRequired => _t("Please Check Your Aadhaar Number",
      "உங்கள் ஆதார் எண்ணை சரிபார்க்கவும்", "कृपया अपना आधार नंबर जांचें");

  String get panRequired => _t("Please Check Your PAN Number",
      "உங்கள் பான் எண்ணை சரிபார்க்கவும்", "कृपया अपना पैन नंबर जांचें");

  /// Expense
  String get createExpense =>
      _t("Add Expense", "செலவு சேர்க்க", "खर्च जोड़ें");

  /// PROJECT
  String get project => _t("Projects", "திட்டங்கள்", "प्रोजेक्ट");

  String get addProject =>
      _t("Add Project", "திட்டம் சேர்க்க", "प्रोजेक्ट जोड़ें");

  String get updateProject =>
      _t("Update Project", "திட்டம் புதுப்பிக்க", "प्रोजेक्ट अपडेट करें");

  String get projectReport =>
      _t("Project Report", "திட்ட அறிக்கை", "प्रोजेक्ट रिपोर्ट");

  String get workReport => _t("Work Report", "பணி அறிக்கை", "कार्य रिपोर्ट");

  String get projectName =>
      _t("Project Name", "திட்டத்தின் பெயர்", "प्रोजेक्ट का नाम");

  String get engineerName =>
      _t("Engineer name", "பொறியாளர் பெயர்", "इंजीनियर का नाम");

  String get from => _t("Travelled From", "பயணித்த இடம்", "यात्रा प्रारंभ स्थान");

  String get to => _t("Travelled To", "சென்ற இடம்", "यात्रा गंतव्य");

  String get expense => _t("Expense", "செலவு", "खर्च");

  String get grpAtt =>
      _t("Group Attendance", "குழு வருகை", "समूह उपस्थिति");

  String get addWorkReport =>
      _t("Add Work Report", "பணி அறிக்கை சேர்க்க", "कार्य रिपोर्ट जोड़ें");

  String get addProjectReport => _t("Add Project Report",
      "திட்ட அறிக்கை சேர்க்க", "प्रोजेक्ट रिपोर्ट जोड़ें");

  String get cmt => _t("Comment", "கருத்து", "टिप्पणी");

  String get reportG => _t("Report Generation",
      "அறிக்கை உருவாக்கம்", "रिपोर्ट जनरेशन");

  String get expenseLimit =>
      _t("Set Expense Limit", "செலவு வரம்பை அமை", "खर्च सीमा निर्धारित करें");

  String get moreApps => _t("More Apps", "மேலும் ஆப்ஸ்", "और ऐप्स");

  String get aboutUs => _t("About Us", "எங்களைப் பற்றி", "हमारे बारे में");

  String get deleteReq =>
      _t("Delete Request", "நீக்க கோரிக்கை", "हटाने का अनुरोध");

  String get logOut => _t("Log Out", "வெளியேறு", "लॉग आउट");

  String get settings => _t("Settings", "அமைப்புகள்", "सेटिंग्स");

  String get dbScreen => _t("Developed By", "உருவாக்கியவர்", "विकसित करने वाले");

  String get expDetails =>
      _t("Expense Details", "செலவு விவரங்கள்", "खर्च विवरण");

  String get allExp =>
      _t("All Expense", "அனைத்து செலவுகள்", "सभी खर्चे");

  String get addExp => _t("Add Expense", "செலவு சேர்க்க", "खर्च जोड़ें");

  String get updExp =>
      _t("Update Expense", "செலவை புதுப்பிக்க", "खर्च अपडेट करें");

  String get task => _t("Task", "பணி", "कार्य");

  String get leaveSum =>
      _t("Leave Summary", "விடுப்பு சுருக்கம்", "छुट्टी सारांश");

  // ✅ FIXED: was "Update Expense" before
  String get addWork => _t("Add Work", "பணி சேர்க்க", "कार्य जोड़ें");

  String get permission => _t("Permission", "அனுமதி", "अनुमति");

  String get total_Leave =>
      _t("Total Leave", "மொத்த விடுப்பு", "कुल छुट्टी");

  String get taken_Leave =>
      _t("Leave Taken", "எடுத்த விடுப்பு", "ली गई छुट्टी");

  String get add_Task => _t("Add Task", "பணி சேர்க்க", "कार्य जोड़ें");

  String get assigned => _t("Assigned", "ஒதுக்கப்பட்டது", "सौंपा गया");

  String get started => _t("Started", "தொடங்கியது", "शुरू हुआ");

  String get completed => _t("Completed", "முடிந்தது", "पूर्ण हुआ");

  String get overdue => _t("Overdue", "தாமதமானது", "विलंबित");

  String get attendIn =>
      _t("Attendance In", "வருகை உள்நுழைவு", "उपस्थिति इन");

  String get attendMak => _t("Attendance Marked",
      "வருகை பதிவு செய்யப்பட்டது", "उपस्थिति दर्ज की गई");

  String get attendOut =>
      _t("Attendance Out", "வருகை வெளியேற்றம்", "उपस्थिति आउट");

  String get perIn =>
      _t("Permission In", "அனுமதி உள்நுழைவு", "अनुमति इन");

  String get perOut =>
      _t("Permission Out", "அனுமதி வெளியேற்றம்", "अनुमति आउट");

  String get setting => _t("Settings", "அமைப்புகள்", "सेटिंग्स");

  String get leave => _t("Leave", "விடுப்பு", "छुट्टी");

  String get office =>
      _t("Office Expense", "அலுவலக செலவு", "कार्यालय खर्च");

  String get employees => _t("Employee", "பணியாளர்", "कर्मचारी");

  String get home => _t("Home", "முகப்பு", "होम");

  String get submit => _t("Submitted", "சமர்ப்பிக்கப்பட்டது", "जमा किया गया");

  String get not_Submit => _t("Not Submitted",
      "சமர்ப்பிக்கப்படவில்லை", "जमा नहीं किया गया");

  String get on_Leave => _t("On Leave", "விடுப்பில்", "छुट्टी पर");

  String get leave_Applided =>
      _t("Leave Applied", "விடுப்பு கோரிக்கை", "छुट्टी का आवेदन");

  // ✅ FIXED: Tamil text was "Leave Applied" before
  String get attendanceReports => _t(
      "Attendance Report", "வருகை அறிக்கை", "उपस्थिति रिपोर्ट");

  String get attendLogEmp => _t("Employees Attendance Log",
      "ஊழியர் வருகைப் பதிவேடு", "कर्मचारी उपस्थिति रजिस्टर");

  String get attendTotEmp =>
      _t("Total Employees", "மொத்த ஊழியர்கள்", "कुल कर्मचारी");

  String get done => _t("Done", "முடிந்தது", "हो गया");

  String get pending => _t("Pending", "நிலுவை", "लंबित");

  String get immediate => _t("Immediate", "உடனடி", "तत्काल");

  String get normal => _t("Normal", "சாதாரணம்", "सामान्य");

  String get high => _t("High", "உயர்", "उच्च");

  String get morning => _t("Good Morning", "காலை வணக்கம்", "सुप्रभात");
  String get afternoon =>
      _t("Good Afternoon", "மதிய வணக்கம்", "शुभ अपराह्न");
  String get evening => _t("Good Evening", "மாலை வணக்கம்", "शुभ संध्या");
  String get night => _t("Good Night", "இனிய இரவு", "शुभ रात्रि");

  String get daily =>
      _t("Daily Work Plan", "தினசரி வேலைத் திட்டம்", "दैनिक कार्य योजना");

  String get presentEmployee => _t("Based on Present Employee",
      "தற்போதைய ஊழியர் ", "उपस्थित कर्मचारी के आधार पर");

  String get addWorkPlan => _t("Add Work Plan",
      "வேலைத் திட்டத்தைச் சேர்க்கவும்", "कार्य योजना जोड़ें");

  // ---------------- Employee Details ----------------
  String get employeeDetails =>
      _t("Employee Details", "ஊழியர் விவரங்கள்", "कर्मचारी विवरण");

  String get personalDetails =>
      _t("Personal Details", "தனிப்பட்ட விவரங்கள்", "व्यक्तिगत विवरण");

  String get addressEmp =>
      _t("Permanent Address", "நிரந்தர முகவரி", "स्थायी पता");

  String get EmergencyContact => _t("Emergency Contact Information",
      "அவசரகாலத் தொடர்புத் தகவல்", "आपातकालीन संपर्क जानकारी");

  String get jobInformation =>
      _t("Job Information", "பணி தகவல்", "नौकरी की जानकारी");

  String get Reference => _t("Reference", "பரிந்துரை", "संदर्भ");

  String get kyc => _t("KYC", "கேஒய்சி", "केवाईसी");

  String get lateAttendanceReport => _t("Late Attendance Report",
      "தாமத வருகை அறிக்கை", "देर से उपस्थिति रिपोर्ट");

  // ---------------- Customer details ----------------
  String get totalCustomer =>
      _t("Total Customer", "மொத்த வாடிக்கையாளர்கள்", "कुल ग्राहक");

  String get company => _t("Company", "நிறுவனம்", "कंपनी");

  String get customerNames =>
      _t("Customer Name", "வாடிக்கையாளர் பெயர்", "ग्राहक का नाम");

  String get department => _t("Department", "துறை", "विभाग");

  String get designation => _t("Designation", "பதவி", "पदनाम");

  String get roles => _t("Role", "பணி பதவி", "भूमिका");

  String get selectType =>
      _t("Select Type", "வகையைத் தேர்ந்தெடுக்கவும்", "प्रकार चुनें");

  // ---------------- Task details ----------------
  String get viewTask => _t("View Task", "பணியைப் பார்க்க", "कार्य देखें");

  String get editTask => _t("Edit Task", "பணியைத் திருத்து", "कार्य संपादित करें");

  String get taskCompany => _t("company", "நிறுவனம்", "कंपनी");

  String get taskCustomer => _t("customer", "வாடிக்கையாளர்", "ग्राहक");

  String get taskType => _t("Task Type", "பணி வகை", "कार्य का प्रकार");

  String get taskDate => _t("Task Date", "பணி தேதி", "कार्य की तारीख");

  String get taskAssign => _t("Assign To", "ஒதுக்கப்பட்டவர்", "किसे सौंपा गया");

  String get taskStatus => _t("Status", "நிலை", "स्थिति");

  String get taskStDate =>
      _t("Task Start Date", "பணி தொடக்க தேதி", "कार्य प्रारंभ तिथि");

  String get taskEdDate =>
      _t("Task End Date", "பணி முடிவு தேதி", "कार्य समाप्ति तिथि");

  String get priority =>
      _t("Priority Level", "முன்னுரிமை நிலை", "प्राथमिकता स्तर");

  String get taskTitle => _t("Task Title / Description",
      "பணி தலைப்பு / விளக்கம்", "कार्य शीर्षक / विवरण");

  String get notes => _t("Notes Attachments",
      "குறிப்புகள் மற்றும் இணைப்புகள்", "नोट्स और संलग्नक");

  String get updateEmployee => _t("Update Employee",
      "ஊழியர் விவரங்களை புதுப்பிக்க", "कर्मचारी अपडेट करें");

  String get selectTypeTask => _t("Please select a type",
      "வகையை தேர்ந்தெடுக்கவும்", "कृपया प्रकार चुनें");

  String get fillDescription => _t("Please fill description",
      "விளக்கத்தை நிரப்பவும்", "कृपया विवरण भरें");

  String get selectAssignedTo => _t("Please select assigned to",
      "நியமிக்கப்பட்டவரை தேர்ந்தெடுக்கவும்", "कृपया सौंपे जाने वाले व्यक्ति को चुनें");

  String get addVisitReport => _t("Please add visit report",
      "வருகை அறிக்கையைச் சேர்க்கவும்", "कृपया विज़िट रिपोर्ट जोड़ें");

  String get noVisitReportFound => _t("No visit report found",
      "வருகை அறிக்கை எதுவும் இல்லை", "कोई विज़िट रिपोर्ट नहीं मिली");

  String get addExpenseReport => _t("Please add expense report",
      "செலவு அறிக்கையைச் சேர்க்கவும்", "कृपया खर्च रिपोर्ट जोड़ें");

  String get noExpenseReportFound => _t("No expense report found",
      "செலவு அறிக்கை எதுவும் இல்லை", "कोई खर्च रिपोर्ट नहीं मिली");

  String get selectAssignTo => _t("Please select assign to",
      "நியமிக்கப்படுபவரைத் தேர்ந்தெடுக்கவும்", "कृपया सौंपे जाने वाले व्यक्ति को चुनें");

  String get selectDate =>
      _t("Please select date", "தேதியைத் தேர்ந்தெடுக்கவும்", "कृपया तारीख चुनें");

  // ---------------- Leave ----------------
  String get leaveReport =>
      _t("Leave report", "விடுப்பு அறிக்கை", "छुट्टी रिपोर्ट");

  String get Myleave => _t("My Leave", "எனது விடுப்பு", "मेरी छुट्टी");

  String get addAnnualLeaves => _t("Add Annual Leaves",
      "ஆண்டு விடுப்புகளைச் சேர்க்க", "वार्षिक छुट्टियाँ जोड़ें");

  String get leaveYear => _t("Year", "ஆண்டு", "वर्ष");

  String get leaveType => _t("Leave Type", "விடுப்பு வகை", "छुट्टी का प्रकार");

  String get addLeaveType => _t("Add Leave Type",
      "விடுப்பு வகையைச் சேர்க்க", "छुट्टी का प्रकार जोड़ें");

  String get types => _t("Type", "விடுப்பு வகை", "प्रकार");

  String get leaveManagementTitle =>
      _t("Leave Management", "விடுப்பு மேலாண்மை", "छुट्टी प्रबंधन");

  String get leavesLabel => _t("Leaves", "விடுப்புகள்", "छुट्टियाँ");

  String get typeLabel => _t("Type", "வகை", "प्रकार");

  String get reportLabel => _t("Report", "அறிக்கை", "रिपोर्ट");

  String get applyLabel => _t("Apply", "விண்ணப்பி", "आवेदन करें");

  String get rulesLabel => _t("Rules", "விதிகள்", "नियम");

  // Apply Leave screen
  String get editLeaveTitle =>
      _t("Edit Leave", "விடுப்பு திருத்தம்", "छुट्टी संपादित करें");

  String get leaveApplicationTitle =>
      _t("Leave Application", "விடுப்பு விண்ணப்பம்", "छुट्टी आवेदन");

  String get leaveApplyFor => _t("Leave Apply For",
      "விடுப்பு விண்ணப்பிப்பவர்", "किसके लिए छुट्टी आवेदन");

  String get fullDay => _t("Full Day", "முழு நாள்", "पूरा दिन");

  String get halfDay => _t("Half Day", "அரை நாள்", "आधा दिन");

  String get leaveDate => _t("Leave Date", "விடுப்பு தேதி", "छुट्टी की तारीख");

  String get toWord => _t(" To ", " முதல் ", " से ");

  String get reason => _t("Reason", "காரணம்", "कारण");

  String get cancel => _t("Cancel", "ரத்து செய்", "रद्द करें");

  String get update => _t("Update", "புதுப்பி", "अपडेट करें");

  String get apply => _t("Apply", "விண்ணப்பி", "आवेदन करें");

  String get selectDayType => _t("Select Day Type",
      "நாள் வகையை தேர்ந்தெடுக்கவும்", "दिन का प्रकार चुनें");

  String get selectLeaveDate => _t("Select Leave Date",
      "விடுப்பு தேதியை தேர்ந்தெடுக்கவும்", "छुट्टी की तारीख चुनें");

  String get selectLeaveType => _t("Select Leave Type",
      "விடுப்பு வகையை தேர்ந்தெடுக்கவும்", "छुट्टी का प्रकार चुनें");

  String get fillReason => _t("Please Fill Reason",
      "காரணத்தை நிரப்பவும்", "कृपया कारण भरें");

  String get selectUserName => _t("Please Select User Name",
      "பயனர் பெயரை தேர்ந்தெடுக்கவும்", "कृपया उपयोगकर्ता नाम चुनें");

  // ---------------- Settings ----------------
  String get grades => _t("Grades", "தரங்கள்", "ग्रेड");

  String get salary => _t("Salary", "சம்பளம்", "वेतन");

  String get taskTypes => _t("Task Types", "பணி வகைகள்", "कार्य के प्रकार");

  String get taskSta => _t("Task Status", "பணி நிலை", "कार्य की स्थिति");

  String get appValues => _t("App Values", "செயலி மதிப்புகள்", "ऐप मान");

  String get deleteAccount =>
      _t("Delete Account", "கணக்கை நீக்கு", "खाता हटाएं");

  // ---------------- Employee form labels ----------------
  String get aadhaarFront => _t("Aadhaar Card\n( Front )",
      "ஆதார் அட்டை\n( முன்புறம் )", "आधार कार्ड\n( आगे )");

  String get aadhaarBack => _t("Aadhaar Card\n( Back Optional )",
      "ஆதார் அட்டை\n( பின்புறம் விருப்பம் )", "आधार कार्ड\n( पीछे वैकल्पिक )");

  String get panCard => _t("PAN \nCard", "பான் \nகார்டு", "पैन \nकार्ड");

  String get aadhaarNumber => _t("Aadhaar Number", "ஆதார் எண்", "आधार नंबर");

  String get panNumberEmp => _t("PAN Number", "பான் எண்", "पैन नंबर");

  String get houseType => _t("House Type", "வீட்டு வகை", "मकान का प्रकार");

  String get maritalStatus =>
      _t("Marital Status", "திருமண நிலை", "वैवाहिक स्थिति");

  String get relationship => _t("Relationship", "உறவுமுறை", "रिश्ता");

  String get fullName => _t("Full Name", "முழு பெயர்", "पूरा नाम");

  // ---------------- Address ----------------
  String get copyPresentAddress => _t("Copy From Present Address?",
      "தற்போதைய முகவரியிலிருந்து நகலெடு?", "वर्तमान पते से कॉपी करें?");

  String get doorNoEmp => _t("Door No", "வீட்டு எண்", "मकान नंबर");

  String get streetName => _t("Street Name", "தெரு பெயர்", "गली का नाम");

  String get areaEmp => _t("Area", "பகுதி", "क्षेत्र");

  String get cityEmp => _t("City", "நகரம்", "शहर");

  String get stateEmp => _t("State", "மாநிலம்", "राज्य");

  String get countryEmp => _t("Country", "நாடு", "देश");

  String get pincode => _t("Pincode", "அஞ்சல் குறியீடு", "पिन कोड");

  // ---------------- Emergency contact ----------------
  String get phoneNumberEmp =>
      _t("Phone Number", "தொலைபேசி எண்", "फ़ोन नंबर");

  String get relation => _t("Relation", "உறவு", "संबंध");

  // ---------------- Job information ----------------
  String get lastOrganization =>
      _t("Last Organization", "கடைசி நிறுவனம்", "पिछला संगठन");

  String get referredByEmp =>
      _t("Referred By", "பரிந்துரைத்தவர்", "संदर्भित करने वाला");

  // ---------------- Reference ----------------
  String get reference1Name => _t("Reference 1 Full Name",
      "பரிந்துரை 1 முழு பெயர்", "संदर्भ 1 का पूरा नाम");

  String get reference1Phone => _t("Reference 1 Phone Number",
      "பரிந்துரை 1 தொலைபேசி எண்", "संदर्भ 1 का फ़ोन नंबर");

  String get reference2Name => _t("Reference 2 Full Name",
      "பரிந்துரை 2 முழு பெயர்", "संदर्भ 2 का पूरा नाम");

  String get reference2Phone => _t("Reference 2 Phone Number",
      "பரிந்துரை 2 தொலைபேசி எண்", "संदर्भ 2 का फ़ोन नंबर");

  // ---------------- KYC documents ----------------
  String get cheque => _t("Cheque", "காசோலை", "चेक");

  String get voter => _t("Voter", "வாக்காளர் அட்டை", "मतदाता पत्र");

  String get license => _t("License", "ஓட்டுநர் உரிமம்", "ड्राइविंग लाइसेंस");

  String get optional => _t("Optional", "விருப்பம்", "वैकल्पिक");

  // ---------------- Personal tab ----------------
  String get grade => _t("Grade", "தரம்", "ग्रेड");

  String get pleaseFillFirstName => _t("Please fill first name",
      "முதல் பெயரை உள்ளிடவும்", "कृपया पहला नाम भरें");

  String get pleaseFillMobile => _t("Please fill mobile number",
      "மொபைல் எண்ணை உள்ளிடவும்", "कृपया मोबाइल नंबर भरें");

  String get personalInformationE1 => _t("Personal Information",
      "தனிப்பட்ட தகவல்", "व्यक्तिगत जानकारी");

  String get addressEmpE1 =>
      _t("Permanent Address", "நிரந்தர முகவரி", "स्थायी पता");

  String get EmergencyContactE1 => _t("Emergency Contact Information",
      "அவசரகாலத் தொடர்புத் தகவல்", "आपातकालीन संपर्क जानकारी");

  String get jobInformationE1 =>
      _t("Job Information", "பணி தகவல்", "नौकरी की जानकारी");

  String get ReferenceE1 => _t("Reference", "பரிந்துரை", "संदर्भ");

  String get kycE1 => _t("KYC", "கேஒய்சி", "केवाईसी");

  String get selectCustomerMsg => _t("Please select customer",
      "வாடிக்கையாளரைத் தேர்ந்தெடுக்கவும்", "कृपया ग्राहक चुनें");

  String get enterDescriptionMsg => _t("Please enter description",
      "விளக்கத்தை உள்ளிடவும்", "कृपया विवरण दर्ज करें");

  // ---------------- Buttons ----------------
  String get save => _t("Save", "சேமி", "सहेजें");

  String get back => _t("Back", "பின் செல்", "वापस");

  // ---------------- Validation messages ----------------
  String get fillFirstName => _t("Please fill first name",
      "பெயரை நிரப்பவும்", "कृपया पहला नाम भरें");

  String get fillMobileNumber => _t("Please fill mobile number",
      "மொபைல் எண்ணை நிரப்பவும்", "कृपया मोबाइल नंबर भरें");

  String get checkMobileNumber => _t("Please check mobile number",
      "மொபைல் எண்ணை சரிபார்க்கவும்", "कृपया मोबाइल नंबर जांचें");

  String get fillPassword => _t("Please fill password",
      "கடவுச்சொல்லை நிரப்பவும்", "कृपया पासवर्ड भरें");

  String get passwordMinLength => _t("Password must be at least 8 characters",
      "கடவுச்சொல் குறைந்தது 8 எழுத்துகள் இருக்க வேண்டும்",
      "पासवर्ड कम से कम 8 अक्षरों का होना चाहिए");

  String get selectRole => _t("Please select role",
      "பணி பதவியை தேர்ந்தெடுக்கவும்", "कृपया भूमिका चुनें");

  String get checkPincode => _t("Please check pincode",
      "பின்கோடை சரிபார்க்கவும்", "कृपया पिन कोड जांचें");

  String get checkWhatsappNumber => _t("Please check whatsapp number",
      "வாட்ஸ்அப் எண்ணை சரிபார்க்கவும்", "कृपया व्हाट्सएप नंबर जांचें");

  String get checkEmail => _t("Please check email id",
      "மின்னஞ்சலை சரிபார்க்கவும்", "कृपया ईमेल आईडी जांचें");

  String get checkAadhaar => _t("Please check aadhaar number",
      "ஆதார் எண்ணை சரிபார்க்கவும்", "कृपया आधार नंबर जांचें");

  String get checkPan => _t("Please check pan number",
      "பான் எண்ணை சரிபார்க்கவும்", "कृपया पैन नंबर जांचें");

  String get checkPermanentPincode => _t(
      "Please check permanent address pincode",
      "நிரந்தர முகவரி பின்கோடை சரிபார்க்கவும்",
      "कृपया स्थायी पते का पिन कोड जांचें");

  String get checkPhoneNumber => _t("Please check phone number",
      "தொலைபேசி எண்ணை சரிபார்க்கவும்", "कृपया फ़ोन नंबर जांचें");

  String get checkRef1Phone => _t("Please check reference 1 phone number",
      "பரிந்துரையாளர் 1 தொலைபேசி எண்ணை சரிபார்க்கவும்",
      "कृपया संदर्भ 1 का फ़ोन नंबर जांचें");

  String get checkRef2Phone => _t("Please check reference 2 phone number",
      "பரிந்துரையாளர் 2 தொலைபேசி எண்ணை சரிபார்க்கவும்",
      "कृपया संदर्भ 2 का फ़ोन नंबर जांचें");

  String get fillName =>
      _t("Please Fill", "பெயரை நிரப்பவும்", "कृपया भरें");

  String get makeMainQuestion =>
      _t("Make this main", "இதை முக்கியமானதாக்கவா", "इसे मुख्य बनाएं");

  String get checkEmailId => _t("Please Check Email Id",
      "மின்னஞ்சலை சரிபார்க்கவும்", "कृपया ईमेल आईडी जांचें");

  String get checkEmergencyNumber => _t("Please check emergency number",
      "அவசர எண்ணை சரிபார்க்கவும்", "कृपया आपातकालीन नंबर जांचें");

  String get roleDecisionMaker =>
      _t("Decision Maker", "முடிவெடுப்பவர்", "निर्णयकर्ता");

  String get roleSupporter => _t("Supporter", "ஆதரவாளர்", "समर्थक");

  String get roleInfluencer =>
      _t("Influencer", "தாக்கம் செலுத்துபவர்", "प्रभावक");

  String get roleOther => _t("Other", "மற்றவை", "अन्य");

  String get noChangesMade => _t("No changes have been made yet.",
      "இதுவரை எந்த மாற்றமும் செய்யப்படவில்லை.", "अभी तक कोई बदलाव नहीं किया गया है।");

  String get noDataFound => _t("No Data Found",
      "தரவு எதுவும் கிடைக்கவில்லை", "कोई डेटा नहीं मिला");

  String get pleaseSelectLeadStatus => _t("Please select lead status",
      "லீட் நிலையைத் தேர்ந்தெடுக்கவும்", "कृपया लीड स्थिति चुनें");

  // ---------------- Company & Customer ----------------
  String get addCompanyCustomerTitle => _t("Add Company & Customer",
      "நிறுவனம் & வாடிக்கையாளரைச் சேர்க்கவும்", "कंपनी और ग्राहक जोड़ें");

  String get companyNameLabel =>
      _t("Company Name", "நிறுவனத்தின் பெயர்", "कंपनी का नाम");

  String get customerNameLabel =>
      _t("Customer Name", "வாடிக்கையாளர் பெயர்", "ग्राहक का नाम");

  String get mobileNumberLabel =>
      _t("Mobile Number", "மொபைல் எண்", "मोबाइल नंबर");

  String get enterCompanyName => _t("Enter Company Name",
      "நிறுவனத்தின் பெயரை உள்ளிடவும்", "कंपनी का नाम दर्ज करें");

  String get enterCustomerName => _t("Enter Customer Name",
      "வாடிக்கையாளர் பெயரை உள்ளிடவும்", "ग्राहक का नाम दर्ज करें");

  String get enterMobileNumber => _t("Enter Mobile Number",
      "மொபைல் எண்ணை உள்ளிடவும்", "मोबाइल नंबर दर्ज करें");

  String get enterValidMobileNumber => _t("Enter valid mobile number",
      "சரியான மொபைல் எண்ணை உள்ளிடவும்", "सही मोबाइल नंबर दर्ज करें");

  String get companyCustomerAdded => _t("Company & Customer Added",
      "நிறுவனம் & வாடிக்கையாளர் சேர்க்கப்பட்டது", "कंपनी और ग्राहक जोड़े गए");

  String get companyAddedNotFound => _t("Company added but not found",
      "நிறுவனம் சேர்க்கப்பட்டது ஆனால் கிடைக்கவில்லை",
      "कंपनी जोड़ी गई लेकिन नहीं मिली");

  String get alreadyExistsOrFailed => _t("Already Exists / Failed",
      "ஏற்கனவே உள்ளது / தோல்வியடைந்தது", "पहले से मौजूद है / विफल");

  String get addCustomerTitle =>
      _t("Add Customer", "வாடிக்கையாளரைச் சேர்க்கவும்", "ग्राहक जोड़ें");

  String get companyIdEmpty => _t("Company ID is empty",
      "நிறுவன ஐடி காலியாக உள்ளது", "कंपनी आईडी खाली है");

  String get customerAddedSuccessfully => _t("Customer Added Successfully",
      "வாடிக்கையாளர் வெற்றிகரமாக சேர்க்கப்பட்டார்", "ग्राहक सफलतापूर्वक जोड़ा गया");

  String get customerAddedIdNotFound => _t(
      "Customer added but ID not found in list",
      "வாடிக்கையாளர் சேர்க்கப்பட்டார் ஆனால் ஐடி கிடைக்கவில்லை",
      "ग्राहक जोड़ा गया लेकिन सूची में आईडी नहीं मिली");

  String get customerAlreadyExistsOrFailed => _t(
      "Customer Already Exists / Failed",
      "வாடிக்கையாளர் ஏற்கனவே உள்ளார் / தோல்வியடைந்தது",
      "ग्राहक पहले से मौजूद है / विफल");

  // ---------------- Leave summary ----------------
  String get leaveSummary =>
      _t("Leave Summary", "விடுப்பு சுருக்கம்", "छुट्टी सारांश");

  String get totalLeaveLabel =>
      _t("Total Leave : ", "மொத்த விடுப்பு : ", "कुल छुट्टी : ");

  String get leaveTakenLabel =>
      _t("Leave Taken : ", "எடுத்த விடுப்பு : ", "ली गई छुट्टी : ");

  String get noLeavesAllocated => _t("No leaves have been allocated to you yet.",
      "உங்களுக்கு இதுவரை விடுப்புகள் ஒதுக்கப்படவில்லை.",
      "आपको अभी तक कोई छुट्टी आवंटित नहीं की गई है।");

  String get daysLeftPlanSmart => _t("days left. Plan smart!",
      "நாட்கள் மீதமுள்ளன. திட்டமிடுங்கள்!", "दिन शेष हैं। समझदारी से योजना बनाएं!");

  String get allLeavesUsed => _t("All leaves used. Plan accordingly.",
      "அனைத்து விடுப்புகளும் பயன்படுத்தப்பட்டன. அதற்கேற்ப திட்டமிடுங்கள்.",
      "सभी छुट्टियाँ उपयोग हो चुकी हैं। उसी के अनुसार योजना बनाएं।");

  // ---------------- Grades ----------------
  String get gradesExpensePolicy => _t("Grades & Expense Policy",
      "தரங்கள் & செலவு கொள்கை", "ग्रेड और खर्च नीति");

  String get amountTab => _t("Amount", "தொகை", "राशि");

  String get noGradesFound => _t("No Grades Found",
      "தரங்கள் எதுவும் கிடைக்கவில்லை", "कोई ग्रेड नहीं मिला");

  String get doYouWantTo =>
      _t("Do you want to", "நீங்கள் விரும்புகிறீர்களா", "क्या आप");

  String get deleteGradeQ =>
      _t("Delete the grade?", "தரத்தை நீக்க?", "ग्रेड हटाना चाहते हैं?");

  String get addGrades =>
      _t("Add Grades", "தரங்களைச் சேர்க்க", "ग्रेड जोड़ें");

  String get pleaseFillGrade =>
      _t("Please fill grade", "தரத்தை நிரப்பவும்", "कृपया ग्रेड भरें");

  // ---------------- Task type ----------------
  String get taskTypesTitle =>
      _t("Task types", "பணி வகைகள்", "कार्य के प्रकार");

  String get noTaskTypesFound => _t("No Task types Found",
      "பணி வகைகள் எதுவும் கிடைக்கவில்லை", "कोई कार्य प्रकार नहीं मिला");

  String get createdByLabel =>
      _t("Created By: ", "உருவாக்கியவர்: ", "बनाने वाला: ");

  String get timeLabel => _t("Time: ", "நேரம்: ", "समय: ");

  String get sureDeleteMsg => _t("Are you sure you want to delete",
      "நீக்க விரும்புகிறீர்களா", "क्या आप वाकई हटाना चाहते हैं");

  String get addTaskTypes =>
      _t("Add Task types", "பணி வகைகளைச் சேர்க்க", "कार्य प्रकार जोड़ें");

  String get pleaseFillType =>
      _t("Please fill type", "வகையை நிரப்பவும்", "कृपया प्रकार भरें");

  String get noTaskStatusFound => _t("No Task Status Found",
      "பணி நிலைகள் எதுவும் கிடைக்கவில்லை", "कोई कार्य स्थिति नहीं मिली");

  String get addTaskStatusTitle => _t("Add Task Status",
      "பணி நிலையைச் சேர்க்க", "कार्य स्थिति जोड़ें");

  String get editTaskStatusTitle => _t("Edit Task Status",
      "பணி நிலையைத் திருத்து", "कार्य स्थिति संपादित करें");

  String get pleaseFillStatus =>
      _t("Please fill status", "நிலையை நிரப்பவும்", "कृपया स्थिति भरें");

  String get noValuesFound => _t("No Values Found",
      "மதிப்புகள் எதுவும் கிடைக்கவில்லை", "कोई मान नहीं मिला");

  String get viewMode => _t("View Mode", "பார்வை பயன்முறை", "व्यू मोड");

  String get editMode => _t("Edit Mode", "திருத்து பயன்முறை", "एडिट मोड");

  String get requiredLabel => _t("Required", "அவசியம்", "आवश्यक");

  String get optionalLabel => _t("Optional", "விருப்பம்", "वैकल्पिक");

  String get deleteLabel => _t("Delete", "நீக்கு", "हटाएं");

  String get manageSettingTitle =>
      _t("Manage Setting", "அமைப்பை நிர்வகி", "सेटिंग प्रबंधित करें");

  String get noActivitiesFound => _t("No Activities Found",
      "செயல்பாடுகள் எதுவும் கிடைக்கவில்லை", "कोई गतिविधि नहीं मिली");

  String get sureWantTo => _t("Are you sure you want",
      "நீங்கள் விரும்புகிறீர்களா", "क्या आप वाकई चाहते हैं");

  String get endSessionQ =>
      _t("to end the session?", "அமர்வை முடிக்க?", "सत्र समाप्त करना?");

  String get deleteAccountQ => _t("to delete your account?",
      "உங்கள் கணக்கை நீக்க?", "अपना खाता हटाना?");

  // ---------------- OTP / Password ----------------
  String get otpTitle => _t("OTP", "OTP", "OTP");

  String get otpVerification =>
      _t("OTP Verification", "OTP சரிபார்ப்பு", "OTP सत्यापन");

  String get enterOtpSentTo => _t("Enter the OTP sent to ........",
      "இதற்கு அனுப்பப்பட்ட OTP-ஐ உள்ளிடவும் ........",
      "इस पर भेजा गया OTP दर्ज करें ........");

  String get otpSent => _t("OTP Sent", "OTP அனுப்பப்பட்டது", "OTP भेजा गया");

  String get forgotPasswordTitle => _t("Forgot Password",
      "கடவுச்சொல் மறந்துவிட்டதா", "पासवर्ड भूल गए");

  String get confirmPassword => _t("Confirm Password",
      "கடவுச்சொல்லை உறுதிப்படுத்து", "पासवर्ड की पुष्टि करें");

  String get pleaseFillConfirmPassword => _t("Please fill confirm password",
      "உறுதிப்படுத்தும் கடவுச்சொல்லை நிரப்பவும்",
      "कृपया पासवर्ड की पुष्टि भरें");

  String get pleaseCheckPassword => _t("Please check password",
      "கடவுச்சொல்லை சரிபார்க்கவும்", "कृपया पासवर्ड जांचें");

  String get resetPassword => _t("RESET PASSWORD",
      "கடவுச்சொல்லை மீட்டமை", "पासवर्ड रीसेट करें");

  String get phoneNumberField =>
      _t("Phone Number", "தொலைபேசி எண்", "फ़ोन नंबर");

  String get pleaseFillPhoneNumber => _t("Please fill phone number",
      "தொலைபேசி எண்ணை நிரப்பவும்", "कृपया फ़ोन नंबर भरें");

  String get pleaseCheckPhoneNumber2 => _t("Please check phone number",
      "தொலைபேசி எண்ணை சரிபார்க்கவும்", "कृपया फ़ोन नंबर जांचें");

  String get passwordMinLength6 => _t("Password must be 6 characters",
      "கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்",
      "पासवर्ड कम से कम 6 अक्षरों का होना चाहिए");

  String get enterMobileNumberMsg => _t("Enter Your Mobile Number",
      "உங்கள் மொபைல் எண்ணை உள்ளிடவும்", "अपना मोबाइल नंबर दर्ज करें");

  String get checkMobileNumberMsg => _t("Check Your Mobile Number",
      "உங்கள் மொபைல் எண்ணை சரிபார்க்கவும்", "अपना मोबाइल नंबर जांचें");

  String get exitAppQ => _t("Do you want to Exit the App?",
      "செயலியிலிருந்து வெளியேற விரும்புகிறீர்களா?",
      "क्या आप ऐप से बाहर निकलना चाहते हैं?");

  String get viewNotifications => _t("View Notifications",
      "அறிவிப்புகளைக் காண", "सूचनाएं देखें");

  String get noUserFound => _t("No user found",
      "பயனர் கிடைக்கவில்லை", "कोई उपयोगकर्ता नहीं मिला");

  String get incorrectPassword =>
      _t("Incorrect password", "தவறான கடவுச்சொல்", "गलत पासवर्ड");

  String get somethingWentWrong => _t("Something went wrong",
      "ஏதோ தவறு நடந்தது", "कुछ गलत हो गया");

  // ---------------- Language ----------------
  // String get selectLanguage =>
  //     _t("Select Language", "மொழியைத் தேர்ந்தெடுக்கவும்", "भाषा चुनें");

  String get selectLanguage =>
      _t("Select Language", "Select Language", "Select Language");


  String get language => _t("Language", "மொழி", "भाषा");
}