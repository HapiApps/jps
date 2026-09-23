import 'package:flutter/cupertino.dart';

/// -----------------------------------------------------------------------
/// LANGUAGE TOGGLE
/// -----------------------------------------------------------------------
/// Set `LanguageManager.isTamil = true` to switch the whole app to Tamil.
/// Default is `false` -> English.
/// -----------------------------------------------------------------------
class LanguageManager extends ChangeNotifier {
  LanguageManager._internal();
  static final LanguageManager instance = LanguageManager._internal();

  /// true  -> Tamil
  /// false -> English
  bool isTamil = true;

  void setLanguage({required bool tamil}) {
    isTamil = tamil;
    notifyListeners();
  }

  void toggle() {
    isTamil = !isTamil;
    notifyListeners();
  }
}

final ConstantValues constValue = ConstantValues._();

class ConstantValues {
  ConstantValues._();

  bool get _ta => LanguageManager.instance.isTamil;   // ✅ Fixed


  final String appName = "Hapi Apps";

  String get comName =>
      _ta
          ? "HapiApps மென்பொருள் ஆய்வகம் வழங்குகிறது"
          : "by HapiApps Software Lab";

  String get appHeading =>
      _ta ? "தினசரி பணி அறிக்கை" : "Daily Activity Report ";

  String get success =>
      _ta ? "வெற்றிகரமாக சேர்க்கப்பட்டது" : "Added Successfully";

  String get visitSuccess =>
      _ta
          ? "தினசரி பணி செயல்பாடு அறிக்கை வெற்றிகரமாக சேர்க்கப்பட்டது"
          : "Daily Work Activity Report Added Successfully";

  String get successTask =>
      _ta ? "பணி வெற்றிகரமாக சேர்க்கப்பட்டது" : "Task Added Successfully";

  String get updated =>
      _ta ? "வெற்றிகரமாக புதுப்பிக்கப்பட்டது" : "Updated Successfully";

  String get deleted =>
      _ta ? "வெற்றிகரமாக நீக்கப்பட்டது" : "Deleted Successfully";

  String get failed => _ta ? "தோல்வி" : "Failed";

  String get receiveOtp => _ta ? "OTP கிடைக்கவில்லையா?" : "Didn't receive OTP?";

  String get resend => _ta ? "மீண்டும் அனுப்பு" : "RESEND";

  String get name => _ta ? "நிறுவனத்தின் பெயர்" : "Company Name";

  String get companyName => _ta ? "நிறுவனத்தின் பெயர்" : "Company Name";

  String get emgName => _ta ? "அவசர தொடர்பு பெயர்" : "Emergency Name";

  String get inTime => _ta ? "வருகை நேரம்" : "In Time";

  String get outTime => _ta ? "வெளியேறும் நேரம்" : "Out Time";

  String get mobileNumber => _ta ? "வாட்ஸ்அப் எண்" : "WhatsApp Number";

  String get panNumber => _ta ? "பான் எண்" : "PAN Number";

  String get dateOfBirth => _ta ? "பிறந்த தேதி" : "Date Of Birth";

  String get dateOfJoin => _ta ? "சேர்ந்த தேதி" : "Date Of Joining";

  String get bloodGroup => _ta ? "இரத்த வகை" : "Blood Group";

  String get lastWrkDay => _ta ? "கடைசி பணி நாள்" : "Last Working Day";

  String get applyDate => _ta ? "விண்ணப்பித்த தேதி" : "Applied Date";
  String get addGradeAmountFirst => _ta ? "தொடர வேண்டுமெனில் அமைப்புகளுக்குச் சென்று ஒரு தரம் மற்றும் அதன் தொகையைச் சேர்க்கவும்" : "Please go to Settings to add a grade and its amount before proceeding";
  String get addVisit =>
      _ta
          ? "தினசரி பணி செயல்பாடு அறிக்கை சேர்க்க"
          : "Add Daily Work Activity Report";

  String get visit => _ta ? "வருகைகள்" : "Visits";

  String get visitRepo =>
      _ta ? "தினசரி பணி செயல்பாடு அறிக்கை" : "Daily Work Activity Report";

  String get planDay =>
      _ta ? "இன்றைய திட்டம் என்ன?" : "What is Your Plan For the Day?";
  final String checkPdf = "pdf";

  String get login => _ta ? "உள்நுழைய" : "LOGIN";

  String get next => _ta ? "அடுத்து" : "Next";

  String get addMore => _ta ? "மேலும் சேர்" : "Add More";

  String get verify => _ta ? "சரிபார்" : "verify";

  String get remember => _ta ? "என்னை நினைவில் கொள்" : "Remember Me";

  String get forgot => _ta ? "கடவுச்சொல் மறந்துவிட்டதா?" : "Forgot Password?";

  String get account => _ta ? "கணக்கு இல்லையா?" : "Don't have an account?";

  String get signUp => _ta ? "பதிவு செய்ய" : "Sign Up";

  String get phoneNumber => _ta ? "கைபேசி எண்" : "Mobile Number";

  String get phoneNumber2 => _ta ? "கைபேசி எண்" : "Mobile No";

  String get whatsappNo => _ta ? "வாட்ஸ்அப் எண்" : "WhatsApp Number";

  String get password => _ta ? "கடவுச்சொல்" : "Password";

  String get amount => _ta ? "தொகை" : "Amount";

  String get expenses => _ta ? "செலவுகள்" : "Expenses";

  String get bus => _ta ? "ரயில்/பேருந்து கட்டணம்" : "Train/Bus Fare";

  String get bus2 => _ta ? "ரயில்/பேருந்து\nகட்டணம்" : "Train/Bus\nFare";

  String get auto => _ta ? "ஆட்டோ கட்டணம்" : "Auto Fare";

  String get auto2 => _ta ? "ஆட்டோ\nகட்டணம்" : "Auto\nFare";

  String get rent => _ta ? "லாட்ஜ்/அறை வாடகை" : "Lodge/Room Rent";

  String get rent2 => _ta ? "லாட்ஜ்/அறை\nவாடகை" : "Lodge/Room\nRent";

  String get food => _ta ? "உணவு" : "Food";

  String get purchase => _ta ? "பொருள் வாங்குதல்" : "Material Purchase";

  String get purchase2 => _ta ? "பொருள்\nவாங்குதல்" : "Material\nPurchase";

  String get total => _ta ? "மொத்தம்" : "Total";

  String get lineName => _ta ? "லைன் பெயர்" : "Line Name";

  String get productName => _ta ? "பெயர்" : "Name";

  String get brand => _ta ? "பிராண்ட்" : "Brand";

  String get batch => _ta ? "பேட்ச் எண்" : "Batch No";

  String get mrp => _ta ? "எம்.ஆர்.பி" : "MRP";

  String get userName => _ta ? "பயனர் பெயர்" : "User Name";

  String get startDate => _ta ? "தொடக்க தேதி" : "Start Date";

  String get endDate => _ta ? "முடிவு தேதி" : "End Date";

  String get planWork => _ta ? "இன்றைய பணி திட்டம்" : "Today's Work Plan";
  String get planDayWork => _ta ? "நாள் வேலைத் திட்டம்" : "Day Work Plan";
  String get finishedWork =>
      _ta ? "முடிக்கப்பட்ட பணி விவரம்" : "Description Of Finished Work";

  String get pendingWork =>
      _ta ? "நிலுவையில் உள்ள பணி விவரம்" : "Description Of Pending Work";

  String get line => _ta ? "லைன்கள்" : "Lines";

  String get track => _ta ? "டிராக்" : "Track";

  String get trackR => _ta ? "டிராக் அறிக்கை" : "Track Report";

  String get trackD => _ta ? "டிராக் விவரங்கள்" : "Track Details";

  String get lineCus => _ta ? "லைன் வாடிக்கையாளர்கள்" : "Line Customers";

  String get lineManagement => _ta ? "லைன் மேலாண்மை" : "Line Management";

  String get report => _ta ? "அறிக்கை" : "Report";

  String get tasks => _ta ? "பணிகள்" : "Tasks";

  String get users => _ta ? "பணியாளர்கள்" : "Employees";

  String get addTask => _ta ? "பணி சேர்க்க" : "Add Task";

  String get createEmployee => _ta ? "பணியாளர் உருவாக்க" : "Create Employee";

  String get attReport => _ta ? "வருகை அறிக்கை" : "Attendance Report";

  String get attendance => _ta ? "வருகை" : "Attendance";

  String get projectAttendance =>
      _ta ? "    திட்ட\nவருகை" : "    Project\nAttendance";

  String get attendanceReport =>
      _ta ? "வருகை\n    அறிக்கை" : "Attendance\n    Report";

  String get employee => _ta ? "பணியாளர்கள்" : "Employees";

  String get reportDash => _ta ? "அறிக்கை டாஷ்போர்டு" : "Report DashBoard";

  String get customers => _ta ? "வாடிக்கையாளர்கள்" : "Customers";

  String get customer => _ta ? "வாடிக்கையாளர்" : "Customer";

  String get customer1 => _ta ? "   வாடிக்கையாளர்" : "   Customer";

  String get customerName => _ta ? "நிறுவனத்தின் பெயர்" : "Company Name";

  String get updateCustomer =>
      _ta ? "வாடிக்கையாளரை புதுப்பிக்க" : "Update Customer";

  String get addCustomer => _ta ? "வாடிக்கையாளரை சேர்க்க" : "Add Customer";

  String get addContact => _ta ? "வாடிக்கையாளரை சேர்க்க" : "Add Customer";

  String get contactDetails =>
      _ta ? "வாடிக்கையாளர் விவரங்கள்" : "Customer Details";

  String get contactName => _ta ? "வாடிக்கையாளர் பெயர்" : "Customer Name";

  String get contact => _ta ? "வாடிக்கையாளர்" : "Customer";

  String get reportDashboard =>
      _ta ? "அறிக்கைகள் டாஷ்போர்டு" : "Reports Dashboard";

  String get customerDetails => _ta ? "நிறுவன விவரங்கள்" : "Company Details";

  String get address => _ta ? "நிறுவன முகவரி" : "Company Address";

  String get observations => _ta ? "கவனிப்புகள்" : "Observations";

  String get expenseType => _ta ? "செலவு வகை" : "Expense Type";

  String get add => _ta ? "சேர்" : "Add";

  String get addLine => _ta ? "லைன் உருவாக்க" : "Create Line";

  String get updateLine => _ta ? "லைன் புதுப்பிக்க" : "Update Line";

  String get createCustomer => _ta ? "வாடிக்கையாளரை சேர்க்க" : "Add Customer";
  String get emergencyNumber => _ta ? "அவசர எண்" : "Emergency Number";

  String get addComment => _ta ? "கருத்து சேர்க்க" : "Add Comment";

  String get doorNo => _ta ? "கதவு எண்" : "Door No";

  String get streetAddress => _ta ? "தெரு பெயர்" : "Street Name";

  String get area => _ta ? "பகுதி" : "Area";

  String get city => _ta ? "நகரம்" : "City";

  String get state => _ta ? "மாநிலம்" : "State";

  String get country => _ta ? "நாடு" : "Country";

  String get pinCode => _ta ? "அஞ்சல் குறியீடு" : "Pincode";

  String get firstName => _ta ? "முதல் பெயர்" : "First  Name";

  String get middleName => _ta ? "நடுப் பெயர்" : "Middle  Name";

  String get lastName => _ta ? "கடைசி பெயர்" : "Last  Name";

  String get emailId => _ta ? "மின்னஞ்சல் முகவரி" : "Email  Id";

  String get proDis => _ta ? "பேசப்பட்ட தயாரிப்பு" : "Product discussed";

  String get disPoints => _ta ? "விவாதப் புள்ளிகள்" : "Discussion Points";

  String get addPoints =>
      _ta ? "எடுக்க வேண்டிய நடவடிக்கைகள்" : "Actions to be taken";

  String get addressNo => _ta ? "கதவு எண்" : "Door No";

  String get comArea => _ta ? "தெரு பெயர்" : "Street Name";

  String get landmark => _ta ? "அடையாளம்" : "Landmark";

  String get referredBy => _ta ? "பரிந்துரைத்தவர்" : "Referred  By";

  String get type => _ta ? " பணி வகை" : " Task type";

  String get cusType => _ta ? " வாடிக்கையாளர் வகை" : " Customer Category";

  String get role => _ta ? "பொறுப்பு" : "Role";

  String get comment => _ta ? "முழு வரலாற்றைக் காண" : "View Full History";

  String get comments => _ta ? "கருத்துகள்" : "Comments";

  String get leadStatus => _ta ? "லீட் வகைகள்" : "Lead Categories";

  String get visitType => _ta ? "அழைப்பு பணி வகை" : "Call Task type";

  String get qStatus => _ta ? "மேற்கோள் நிலை" : "Quotation Status";

  String get qRequired => _ta ? "மேற்கோள் தேவை" : "Quotation Required";

  String get status => _ta ? "நிலை" : "Status";

  String get selfProductPlacement =>
      _ta ? "சொந்த தயாரிப்பு வைப்பு" : "Self Product Placement";

  String get competitorProductPlacement =>
      _ta ? "போட்டியாளர் தயாரிப்பு வைப்பு" : "Competitor Product Placement";

  String get noData => _ta ? "தரவு எதுவும் கிடைக்கவில்லை" : "No Data Found";

  String get noTask => _ta ? "பணி எதுவும் கிடைக்கவில்லை" : "No Task Found";

  String get noUser => _ta ? "பயனர் எதுவும் கிடைக்கவில்லை" : "No User Found";

  String get noCase => _ta ? "வழக்கு எதுவும் கிடைக்கவில்லை" : "No Case Found";

  String get noAttendance =>
      _ta ? "வருகை பதிவு கிடைக்கவில்லை" : "No Attendance Found";

  String get noAttendanceToday =>
      _ta ? "இன்று வருகை பதிவு செய்யப்படவில்லை" : "No Attendance Marked Today";

  String get noProject =>
      _ta ? "திட்டம் எதுவும் கிடைக்கவில்லை" : "No Project Found";

  String get noProduct =>
      _ta ? "தயாரிப்புகள் எதுவும் கிடைக்கவில்லை" : "No Products Found";

  String get noCustomer =>
      _ta ? "வாடிக்கையாளர்கள் யாரும் கிடைக்கவில்லை" : "No Customers Found";

  /// VALIDATE
  String get required =>
      _ta ? "இந்தப் புலம் அவசியம்" : "This field is required";

  String get numberRequired =>
      _ta ? "உங்கள் கைபேசி எண்ணை சரிபார்க்கவும்" : "Check Your Phone Number";

  String get pincodeRequired =>
      _ta
          ? "உங்கள் அஞ்சல் குறியீட்டை சரிபார்க்கவும்"
          : "Please Check Your PinCode Number";

  String get emailRequired =>
      _ta ? "சரியான மின்னஞ்சலை உள்ளிடவும்" : "Please Enter Your Valid Email";

  String get aadhaarRequired =>
      _ta
          ? "உங்கள் ஆதார் எண்ணை சரிபார்க்கவும்"
          : "Please Check Your Aadhaar Number";

  String get panRequired =>
      _ta ? "உங்கள் பான் எண்ணை சரிபார்க்கவும்" : "Please Check Your PAN Number";

  /// Expense
  String get createExpense => _ta ? "செலவு சேர்க்க" : "Add Expense";

  /// PROJECT
  String get project => _ta ? "திட்டங்கள்" : "Projects";

  String get addProject => _ta ? "திட்டம் சேர்க்க" : "Add Project";

  String get updateProject => _ta ? "திட்டம் புதுப்பிக்க" : "Update Project";

  String get projectReport => _ta ? "திட்ட அறிக்கை" : "Project Report";

  String get workReport => _ta ? "பணி அறிக்கை" : "Work Report";

  String get projectName => _ta ? "திட்டத்தின் பெயர்" : "Project Name";

  String get engineerName => _ta ? "பொறியாளர் பெயர்" : "Engineer name";

  String get from => _ta ? "பயணித்த இடம்" : "Travelled From";

  String get to => _ta ? "சென்ற இடம்" : "Travelled To";

  String get expense => _ta ? "செலவு" : "Expense";

  String get grpAtt => _ta ? "குழு வருகை" : "Group Attendance";

  String get addWorkReport => _ta ? "பணி அறிக்கை சேர்க்க" : "Add Work Report";

  String get addProjectReport =>
      _ta ? "திட்ட அறிக்கை சேர்க்க" : "Add Project Report";

  String get cmt => _ta ? "கருத்து" : "Comment";
  final String rupeeSign = "₹";

  String get reportG => _ta ? "அறிக்கை உருவாக்கம்" : "Report Generation";

  String get expenseLimit => _ta ? "செலவு வரம்பை அமை" : "Set Expense Limit";

  String get moreApps => _ta ? "மேலும் ஆப்ஸ்" : "More Apps";

  String get aboutUs => _ta ? "எங்களைப் பற்றி" : "About Us";

  String get deleteReq => _ta ? "நீக்க கோரிக்கை" : "Delete Request";

  String get logOut => _ta ? "வெளியேறு" : "Log Out";

  String get settings => _ta ? "அமைப்புகள்" : "Settings";

  String get dbScreen => _ta ? "உருவாக்கியவர்" : "Developed By";

  String get expDetails => _ta ? "செலவு விவரங்கள்" : "Expense Details";

  String get allExp => _ta ? "அனைத்து செலவுகள்" : "All Expense";

  String get addExp => _ta ? "செலவு சேர்க்க" : "Add Expense";

  String get updExp => _ta ? "செலவை புதுப்பிக்க" : "Update Expense";


  String get task => _ta ? "பணி" : "Task";

  String get leaveSum => _ta ? "விடுப்பு சுருக்கம்" : "Leave Summary";

  String get addWork => _ta ? "செலவை புதுப்பிக்க" : "Update Expense";

  String get permission => _ta ? "அனுமதி" : "Permission";

  String get total_Leave => _ta ? "மொத்த விடுப்பு" : "Total Leave";

  String get taken_Leave => _ta ? "எடுத்த விடுப்பு" : "Leave Taken";

  String get add_Task => _ta ? "பணி சேர்க்க" : "Add Task";

  String get assigned => _ta ? "ஒதுக்கப்பட்டது" : "Assigned";

  String get started => _ta ? "தொடங்கியது" : "Started";

  String get completed => _ta ? "முடிந்தது" : "Completed";

  String get overdue => _ta ? "தாமதமானது" : "Overdue";

  String get attendIn => _ta ? "வருகை உள்நுழைவு" : "Attendance In";
  String get attendMak => _ta ? "வருகை பதிவு செய்யப்பட்டது" : "Attendance Marked";
  String get attendOut => _ta ? "வருகை வெளியேற்றம்" : "Attendance Out";
  String get perIn => _ta ? "அனுமதி உள்நுழைவு" : "Permission In";
  String get perOut => _ta ? "அனுமதி வெளியேற்றம்" : "Permission Out";
  String get setting => _ta ? "அமைப்புகள்" : "Settings";
  String get leave => _ta ? "விடுப்பு" : "Leave";
  String get office => _ta ? "அலுவலக செலவு" : "Office Expense";
  String get employees => _ta ? "பணியாளர்" : "Employee";
  String get home => _ta ? "முகப்பு" : "Home";
  String get submit => _ta ? "சமர்ப்பிக்கப்பட்டது" : "Submitted";
  String get not_Submit => _ta ? "சமர்ப்பிக்கப்படவில்லை" : "Not Submitted";
  String get on_Leave => _ta ? "விடுப்பில்" : "On Leave";
  String get leave_Applided => _ta ? "விடுப்பு கோரிக்கை" : "Leave Applied";
  String get attendanceReports => _ta ? "விடுப்பு விண்ணப்பிக்கப்பட்டது" : "Attendance Report";
  String get attendLogEmp => _ta ? "ஊழியர் வருகைப் பதிவேடு" : "Employees Attendance Log";
  String get attendTotEmp => _ta ? "மொத்த ஊழியர்கள்" : "Total Employees";
  String get done => _ta ? "முடிந்தது" : "Done";
  String get pending => _ta ? "நிலுவை" : "Pending";
  String get immediate => _ta ? "உடனடி" : "Immediate";
  String get normal => _ta ? "சாதாரணம்" : "Normal";
  String get high => _ta ? "உயர்" : "High";

  String get morning => _ta ? "காலை வணக்கம்" : "Good Morning";
  String get afternoon => _ta ? "மதிய வணக்கம்" : "Good Afternoon";
  String get evening => _ta ? "மாலை வணக்கம்" : "Good Evening";
  String get night => _ta ? "இனிய இரவு" : "Good Night";
  String get daily => _ta ? "தினசரி வேலைத் திட்டம்" : "Daily Work Plan";
  String get presentEmployee => _ta ? "தற்போதைய ஊழியர் " : "Based on Present Employee";
  String get addWorkPlan => _ta ? "வேலைத் திட்டத்தைச் சேர்க்கவும்" : "Add Work Plan";

  //Employee Details
  String get employeeDetails => _ta ? "ஊழியர் விவரங்கள்" : "Employee Details";
  String get personalDetails => _ta ? "தனிப்பட்ட விவரங்கள்" : "personal Details";
  String get addressEmp => _ta ? "நிரந்தர முகவரி" : "Permanent Address";
  String get EmergencyContact => _ta ? "அவசரகாலத் தொடர்புத் தகவல்" : "Emergency Contact Information";
  String get jobInformation => _ta ? "பணி தகவல்" : "Job Information";
  String get Reference => _ta ? "பரிந்துரை" : "Reference";
  String get kyc => _ta ? "கேஒய்சி" : "KYC";

  String get lateAttendanceReport => _ta ? "தாமத வருகை அறிக்கை" : "Late Attendance Report";   // ✅ புதுசா சேர்த்தது

  // String get attendance => _ta ? "வருகை" : "Attendance";

//customer details
  String get totalCustomer => _ta ? "மொத்த வாடிக்கையாளர்கள்" : "Total Customer";
  String get company => _ta ? "நிறுவனம்" : "Company";
  String get customerNames => _ta ? "வாடிக்கையாளர் பெயர்" : "Customer Name";
  String get department => _ta ? "துறை" : "Department";
  String get designation => _ta ? "பதவி" : "Designation";
  String get roles => _ta ? "பொறுப்பு" : "Role";
  String get selectType => _ta ? "வகையைத் தேர்ந்தெடுக்கவும்" : "Select Type";

// task details
  String get viewTask => _ta ? "பணியைப் பார்க்க" : "View Task";
  String get editTask => _ta ? "பணியைத் திருத்து" : "Edit Task";
  String get taskCompany => _ta ? "நிறுவனம்" : "company";
  String get taskCustomer => _ta ? "வாடிக்கையாளர்" : "customer";
  String get taskType => _ta ? "பணி வகை" : "Task Type";
  String get taskDate => _ta ? "பணி தேதி" : "Task Date";
  String get taskAssign => _ta ? "ஒதுக்கப்பட்டவர்" : "Assign To";
  String get taskStatus => _ta ? "நிலை" : "Status";
  String get taskStDate => _ta ? "பணி தொடக்க தேதி" : "Task Start Date";
  String get taskEdDate => _ta ? "பணி முடிவு தேதி" : "Task End Date";
  String get priority => _ta ? "முன்னுரிமை நிலை" : "Priority Level";
  String get taskTitle => _ta ? "பணி தலைப்பு / விளக்கம்" : "Task Title / Description";
  String get notes => _ta ? "குறிப்புகள் மற்றும் இணைப்புகள்" : "Notes Attachments";
  String get updateEmployee => _ta ? "ஊழியர் விவரங்களை புதுப்பிக்க" : "Update Employee";
  String get selectTypeTask => _ta ? "வகையை தேர்ந்தெடுக்கவும்" : "Please select a type";
  String get fillDescription => _ta ? "விளக்கத்தை நிரப்பவும்" : "Please fill description";
  String get selectAssignedTo => _ta ? "நியமிக்கப்பட்டவரை தேர்ந்தெடுக்கவும்" : "Please select assigned to";
  String get addVisitReport => _ta ? "வருகை அறிக்கையைச் சேர்க்கவும்" : "Please add visit report";
  String get noVisitReportFound => _ta ? "வருகை அறிக்கை எதுவும் இல்லை" : "No visit report found";
  String get addExpenseReport => _ta ? "செலவு அறிக்கையைச் சேர்க்கவும்" : "Please add expense report";
  String get noExpenseReportFound => _ta ? "செலவு அறிக்கை எதுவும் இல்லை" : "No expense report found";
  String get selectAssignTo => _ta ? "நியமிக்கப்படுபவரைத் தேர்ந்தெடுக்கவும்" : "Please select assign to";
  String get selectDate => _ta ? "தேதியைத் தேர்ந்தெடுக்கவும்" : "Please select date";

//leave
  String get leaveReport => _ta ? "விடுப்பு அறிக்கை" : "Leave report";
  String get Myleave => _ta ? "எனது விடுப்பு" : "My Leave";
  String get addAnnualLeaves => _ta ? "ஆண்டு விடுப்புகளைச் சேர்க்க" : "Add Annual Leaves";
  String get leaveYear => _ta ? "ஆண்டு" : "Year";
  String get leaveType => _ta ? "விடுப்பு வகை" : "Leave Type";
  String get addLeaveType => _ta ? "விடுப்பு வகையைச் சேர்க்க" : "Add Leave Type";
  String get types => _ta ? "விடுப்பு வகை" : "Type";
  String get leaveManagementTitle => _ta ? "விடுப்பு மேலாண்மை" : "Leave Management";
  String get leavesLabel => _ta ? "விடுப்புகள்" : "Leaves";
  String get typeLabel => _ta ? "வகை" : "Type";
  String get reportLabel => _ta ? "அறிக்கை" : "Report";
  String get applyLabel => _ta ? "விண்ணப்பி" : "Apply";
  String get rulesLabel => _ta ? "விதிகள்" : "Rules";

  // Apply Leave screen
  String get editLeaveTitle => _ta ? "விடுப்பு திருத்தம்" : "Edit Leave";
  String get leaveApplicationTitle => _ta ? "விடுப்பு விண்ணப்பம்" : "Leave Application";
  String get leaveApplyFor => _ta ? "விடுப்பு விண்ணப்பிப்பவர்" : "Leave Apply For";
  String get fullDay => _ta ? "முழு நாள்" : "Full Day";
  String get halfDay => _ta ? "அரை நாள்" : "Half Day";
  String get leaveDate => _ta ? "விடுப்பு தேதி" : "Leave Date";
  String get toWord => _ta ? " முதல் " : " To ";
  String get reason => _ta ? "காரணம்" : "Reason";
  String get cancel => _ta ? "ரத்து செய்" : "Cancel";
  String get update => _ta ? "புதுப்பி" : "Update";
  String get apply => _ta ? "விண்ணப்பி" : "Apply";
  String get selectDayType => _ta ? "நாள் வகையை தேர்ந்தெடுக்கவும்" : "Select Day Type";
  String get selectLeaveDate => _ta ? "விடுப்பு தேதியை தேர்ந்தெடுக்கவும்" : "Select Leave Date";
  String get selectLeaveType => _ta ? "விடுப்பு வகையை தேர்ந்தெடுக்கவும்" : "Select Leave Type";
  String get fillReason => _ta ? "காரணத்தை நிரப்பவும்" : "Please Fill Reason";
  String get selectUserName => _ta ? "பயனர் பெயரை தேர்ந்தெடுக்கவும்" : "Please Select User Name";


//settings
  String get grades => _ta ? "தரங்கள்" : "Grades";
  String get salary => _ta ? "சம்பளம்" : "Salary";
  String get taskTypes => _ta ? "பணி வகைகள்" : "Task Types";
  String get taskSta => _ta ? "பணி நிலை" : "Task Status";
  String get appValues => _ta ? "செயலி மதிப்புகள்" : "App Values";
  String get deleteAccount => _ta ? "கணக்கை நீக்கு" : "Delete Account";

  //Employee form labels
  String get aadhaarFront => _ta ? "ஆதார் அட்டை\n( முன்புறம் )" : "Aadhaar Card\n( Front )";
  String get aadhaarBack => _ta ? "ஆதார் அட்டை\n( பின்புறம் விருப்பம் )" : "Aadhaar Card\n( Back Optional )";
  String get panCard => _ta ? "பான் \nகார்டு" : "PAN \nCard";
  String get aadhaarNumber => _ta ? "ஆதார் எண்" : "Aadhaar Number";
  String get panNumberEmp => _ta ? "பான் எண்" : "PAN Number";
  String get houseType => _ta ? "வீட்டு வகை" : "House Type";
  String get maritalStatus => _ta ? "திருமண நிலை" : "Marital Status";
  String get relationship => _ta ? "உறவுமுறை" : "Relationship";
  String get fullName => _ta ? "முழு பெயர்" : "Full Name";

//Address
  String get copyPresentAddress => _ta ? "தற்போதைய முகவரியிலிருந்து நகலெடு?" : "Copy From Present Address?";
  String get doorNoEmp => _ta ? "வீட்டு எண்" : "Door No";
  String get streetName => _ta ? "தெரு பெயர்" : "Street Name";
  String get areaEmp => _ta ? "பகுதி" : "Area";
  String get cityEmp => _ta ? "நகரம்" : "City";
  String get stateEmp => _ta ? "மாநிலம்" : "State";
  String get countryEmp => _ta ? "நாடு" : "Country";
  String get pincode => _ta ? "அஞ்சல் குறியீடு" : "Pincode";

//Emergency contact
  String get phoneNumberEmp => _ta ? "தொலைபேசி எண்" : "Phone Number";
  String get relation => _ta ? "உறவு" : "Relation";

//Job information
  String get lastOrganization => _ta ? "கடைசி நிறுவனம்" : "Last Organization";
  String get referredByEmp => _ta ? "பரிந்துரைத்தவர்" : "Referred By";

//Reference
  String get reference1Name => _ta ? "பரிந்துரை 1 முழு பெயர்" : "Reference 1 Full Name";
  String get reference1Phone => _ta ? "பரிந்துரை 1 தொலைபேசி எண்" : "Reference 1 Phone Number";
  String get reference2Name => _ta ? "பரிந்துரை 2 முழு பெயர்" : "Reference 2 Full Name";
  String get reference2Phone => _ta ? "பரிந்துரை 2 தொலைபேசி எண்" : "Reference 2 Phone Number";

//KYC documents
  String get cheque => _ta ? "காசோலை" : "Cheque";
  String get voter => _ta ? "வாக்காளர் அட்டை" : "Voter";
  String get license => _ta ? "ஓட்டுநர் உரிமம்" : "License";
  String get optional => _ta ? "விருப்பம்" : "Optional";

  // Paste these inside your constValue class.
// If a getter with the same name already exists, skip it (don't duplicate).
// Already in your file, so NOT repeated here: updateEmployee, firstName, middleName,
// lastName, phoneNumber2, whatsappNo, dateOfBirth, dateOfJoin, bloodGroup, lastWrkDay,
// addressNo, streetAddress, area, city, country, pinCode, emailId, salary, roles.



// ---------- Personal tab ----------
  String get grade => _ta ? "தரம்" : "Grade";

  String get pleaseFillFirstName => _ta ? "முதல் பெயரை உள்ளிடவும்" : "Please fill first name";
  String get pleaseFillMobile => _ta ? "மொபைல் எண்ணை உள்ளிடவும்" : "Please fill mobile number";

  String get personalInformationE1 => _ta ? "தனிப்பட்ட தகவல்" : "Personal Information";
  String get addressEmpE1 => _ta ? "நிரந்தர முகவரி" : "Permanent Address";
  String get EmergencyContactE1 => _ta ? "அவசரகாலத் தொடர்புத் தகவல்" : "Emergency Contact Information";
  String get jobInformationE1 => _ta ? "பணி தகவல்" : "Job Information";
  String get ReferenceE1 => _ta ? "பரிந்துரை" : "Reference";
  String get kycE1 => _ta ? "கேஒய்சி" : "KYC";

  String get selectCustomerMsg => _ta ? "வாடிக்கையாளரைத் தேர்ந்தெடுக்கவும்" : "Please select customer";
  String get enterDescriptionMsg => _ta ? "விளக்கத்தை உள்ளிடவும்" : "Please enter description";

  // Buttons
 // String get addMore => _ta ? "மேலும் சேர்க்க" : "Add More";
  String get save => _ta ? "சேமி" : "Save";
  String get back => _ta ? "பின் செல்" : "Back";
  // String get next => _ta ? "அடுத்து" : "Next";
  // String get cancel => _ta ? "ரத்து செய்" : "Cancel";

// Validation messages
  String get fillFirstName => _ta ? "பெயரை நிரப்பவும்" : "Please fill first name";
  String get fillMobileNumber => _ta ? "மொபைல் எண்ணை நிரப்பவும்" : "Please fill mobile number";
  String get checkMobileNumber => _ta ? "மொபைல் எண்ணை சரிபார்க்கவும்" : "Please check mobile number";
  String get fillPassword => _ta ? "கடவுச்சொல்லை நிரப்பவும்" : "Please fill password";
  String get passwordMinLength => _ta ? "கடவுச்சொல் குறைந்தது 8 எழுத்துகள் இருக்க வேண்டும்" : "Password must be at least 8 characters";
  String get selectRole => _ta ? "பணி பதவியை தேர்ந்தெடுக்கவும்" : "Please select role";
  String get checkPincode => _ta ? "பின்கோடை சரிபார்க்கவும்" : "Please check pincode";
  String get checkWhatsappNumber => _ta ? "வாட்ஸ்அப் எண்ணை சரிபார்க்கவும்" : "Please check whatsapp number";
  String get checkEmail => _ta ? "மின்னஞ்சலை சரிபார்க்கவும்" : "Please check email id";
  String get checkAadhaar => _ta ? "ஆதார் எண்ணை சரிபார்க்கவும்" : "Please check aadhaar number";
  String get checkPan => _ta ? "பான் எண்ணை சரிபார்க்கவும்" : "Please check pan number";
  String get checkPermanentPincode => _ta ? "நிரந்தர முகவரி பின்கோடை சரிபார்க்கவும்" : "Please check permanent address pincode";
  String get checkPhoneNumber => _ta ? "தொலைபேசி எண்ணை சரிபார்க்கவும்" : "Please check phone number";
  String get checkRef1Phone => _ta ? "பரிந்துரையாளர் 1 தொலைபேசி எண்ணை சரிபார்க்கவும்" : "Please check reference 1 phone number";
  String get checkRef2Phone => _ta ? "பரிந்துரையாளர் 2 தொலைபேசி எண்ணை சரிபார்க்கவும்" : "Please check reference 2 phone number";
  String get fillName => _ta ? "பெயரை நிரப்பவும்" : "Please Fill";
  String get makeMainQuestion => _ta ? "இதை முக்கியமானதாக்கவா" : "Make this main";
  String get checkEmailId => _ta ? "மின்னஞ்சலை சரிபார்க்கவும்" : "Please Check Email Id";
  String get checkEmergencyNumber => _ta ? "அவசர எண்ணை சரிபார்க்கவும்" : "Please check emergency number";
  String get roleDecisionMaker => _ta ? "முடிவெடுப்பவர்" : "Decision Maker";
  String get roleSupporter => _ta ? "ஆதரவாளர்" : "Supporter";
  String get roleInfluencer => _ta ? "தாக்கம் செலுத்துபவர்" : "Influencer";
  String get roleOther => _ta ? "மற்றவை" : "Other";
  String get noChangesMade => _ta ? "இதுவரை எந்த மாற்றமும் செய்யப்படவில்லை." : "No changes have been made yet.";
  String get noDataFound => _ta ? "தரவு எதுவும் கிடைக்கவில்லை" : "No Data Found";

  String get addCompanyCustomerTitle => _ta ? "நிறுவனம் & வாடிக்கையாளரைச் சேர்க்கவும்" : "Add Company & Customer";
  String get companyNameLabel => _ta ? "நிறுவனத்தின் பெயர்" : "Company Name";
  String get customerNameLabel => _ta ? "வாடிக்கையாளர் பெயர்" : "Customer Name";
  String get mobileNumberLabel => _ta ? "மொபைல் எண்" : "Mobile Number";
  String get enterCompanyName => _ta ? "நிறுவனத்தின் பெயரை உள்ளிடவும்" : "Enter Company Name";
  String get enterCustomerName => _ta ? "வாடிக்கையாளர் பெயரை உள்ளிடவும்" : "Enter Customer Name";
  String get enterMobileNumber => _ta ? "மொபைல் எண்ணை உள்ளிடவும்" : "Enter Mobile Number";
  String get enterValidMobileNumber => _ta ? "சரியான மொபைல் எண்ணை உள்ளிடவும்" : "Enter valid mobile number";
  String get companyCustomerAdded => _ta ? "நிறுவனம் & வாடிக்கையாளர் சேர்க்கப்பட்டது" : "Company & Customer Added";
  String get companyAddedNotFound => _ta ? "நிறுவனம் சேர்க்கப்பட்டது ஆனால் கிடைக்கவில்லை" : "Company added but not found";
  String get alreadyExistsOrFailed => _ta ? "ஏற்கனவே உள்ளது / தோல்வியடைந்தது" : "Already Exists / Failed";

  String get addCustomerTitle => _ta ? "வாடிக்கையாளரைச் சேர்க்கவும்" : "Add Customer";
  String get companyIdEmpty => _ta ? "நிறுவன ஐடி காலியாக உள்ளது" : "Company ID is empty";
  String get customerAddedSuccessfully => _ta ? "வாடிக்கையாளர் வெற்றிகரமாக சேர்க்கப்பட்டார்" : "Customer Added Successfully";
  String get customerAddedIdNotFound => _ta ? "வாடிக்கையாளர் சேர்க்கப்பட்டார் ஆனால் ஐடி கிடைக்கவில்லை" : "Customer added but ID not found in list";
  String get customerAlreadyExistsOrFailed => _ta ? "வாடிக்கையாளர் ஏற்கனவே உள்ளார் / தோல்வியடைந்தது" : "Customer Already Exists / Failed";

  String get leaveSummary => _ta ? "விடுப்பு சுருக்கம்" : "Leave Summary";
  String get totalLeaveLabel => _ta ? "மொத்த விடுப்பு : " : "Total Leave : ";
  String get leaveTakenLabel => _ta ? "எடுத்த விடுப்பு : " : "Leave Taken : ";
  String get noLeavesAllocated => _ta ? "உங்களுக்கு இதுவரை விடுப்புகள் ஒதுக்கப்படவில்லை." : "No leaves have been allocated to you yet.";
  String get daysLeftPlanSmart => _ta ? "நாட்கள் மீதமுள்ளன. திட்டமிடுங்கள்!" : "days left. Plan smart!";
  String get allLeavesUsed => _ta ? "அனைத்து விடுப்புகளும் பயன்படுத்தப்பட்டன. அதற்கேற்ப திட்டமிடுங்கள்." : "All leaves used. Plan accordingly.";

  //grade

  String get gradesExpensePolicy => _ta ? "தரங்கள் & செலவு கொள்கை" : "Grades & Expense Policy";
  String get amountTab => _ta ? "தொகை" : "Amount";
  String get noGradesFound => _ta ? "தரங்கள் எதுவும் கிடைக்கவில்லை" : "No Grades Found";
  String get doYouWantTo => _ta ? "நீங்கள் விரும்புகிறீர்களா" : "Do you want to";
  String get deleteGradeQ => _ta ? "தரத்தை நீக்க?" : "Delete the grade?";
  String get addGrades => _ta ? "தரங்களைச் சேர்க்க" : "Add Grades";
  String get pleaseFillGrade => _ta ? "தரத்தை நிரப்பவும்" : "Please fill grade";

  //task type add

  String get taskTypesTitle => _ta ? "பணி வகைகள்" : "Task types";
  String get noTaskTypesFound => _ta ? "பணி வகைகள் எதுவும் கிடைக்கவில்லை" : "No Task types Found";
  String get createdByLabel => _ta ? "உருவாக்கியவர்: " : "Created By: ";
  String get timeLabel => _ta ? "நேரம்: " : "Time: ";
  String get sureDeleteMsg => _ta ? "நீக்க விரும்புகிறீர்களா" : "Are you sure you want to delete";
  String get addTaskTypes => _ta ? "பணி வகைகளைச் சேர்க்க" : "Add Task types";
  String get pleaseFillType => _ta ? "வகையை நிரப்பவும்" : "Please fill type";

  String get noTaskStatusFound => _ta ? "பணி நிலைகள் எதுவும் கிடைக்கவில்லை" : "No Task Status Found";
  String get addTaskStatusTitle => _ta ? "பணி நிலையைச் சேர்க்க" : "Add Task Status";
  String get editTaskStatusTitle => _ta ? "பணி நிலையைத் திருத்து" : "Edit Task Status";
  String get pleaseFillStatus => _ta ? "நிலையை நிரப்பவும்" : "Please fill status";

  String get noValuesFound => _ta ? "மதிப்புகள் எதுவும் கிடைக்கவில்லை" : "No Values Found";
  String get viewMode => _ta ? "பார்வை பயன்முறை" : "View Mode";
  String get editMode => _ta ? "திருத்து பயன்முறை" : "Edit Mode";
  String get requiredLabel => _ta ? "அவசியம்" : "Required";
  String get optionalLabel => _ta ? "விருப்பம்" : "Optional";
  String get deleteLabel => _ta ? "நீக்கு" : "Delete";

  String get manageSettingTitle => _ta ? "அமைப்பை நிர்வகி" : "Manage Setting";
  String get noActivitiesFound => _ta ? "செயல்பாடுகள் எதுவும் கிடைக்கவில்லை" : "No Activities Found";

  String get sureWantTo => _ta ? "நீங்கள் விரும்புகிறீர்களா" : "Are you sure you want";
  String get endSessionQ => _ta ? "அமர்வை முடிக்க?" : "to end the session?";
  String get deleteAccountQ => _ta ? "உங்கள் கணக்கை நீக்க?" : "to delete your account?";

  String get otpTitle => _ta ? "OTP" : "OTP";
  String get otpVerification => _ta ? "OTP சரிபார்ப்பு" : "OTP Verification";
  String get enterOtpSentTo => _ta ? "இதற்கு அனுப்பப்பட்ட OTP-ஐ உள்ளிடவும் ........" : "Enter the OTP sent to ........";
  String get otpSent => _ta ? "OTP அனுப்பப்பட்டது" : "OTP Sent";
  String get forgotPasswordTitle => _ta ? "கடவுச்சொல் மறந்துவிட்டதா" : "Forgot Password";
  String get confirmPassword => _ta ? "கடவுச்சொல்லை உறுதிப்படுத்து" : "Confirm Password";
  String get pleaseFillConfirmPassword => _ta ? "உறுதிப்படுத்தும் கடவுச்சொல்லை நிரப்பவும்" : "Please fill confirm password";
  String get pleaseCheckPassword => _ta ? "கடவுச்சொல்லை சரிபார்க்கவும்" : "Please check password";
  String get resetPassword => _ta ? "கடவுச்சொல்லை மீட்டமை" : "RESET PASSWORD";

  String get phoneNumberField => _ta ? "தொலைபேசி எண்" : "Phone Number";
  String get pleaseFillPhoneNumber => _ta ? "தொலைபேசி எண்ணை நிரப்பவும்" : "Please fill phone number";
  String get pleaseCheckPhoneNumber2 => _ta ? "தொலைபேசி எண்ணை சரிபார்க்கவும்" : "Please check phone number";
  String get passwordMinLength6 => _ta ? "கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்" : "Password must be 6 characters";
  String get enterMobileNumberMsg => _ta ? "உங்கள் மொபைல் எண்ணை உள்ளிடவும்" : "Enter Your Mobile Number";
  String get checkMobileNumberMsg => _ta ? "உங்கள் மொபைல் எண்ணை சரிபார்க்கவும்" : "Check Your Mobile Number";
  String get exitAppQ => _ta ? "செயலியிலிருந்து வெளியேற விரும்புகிறீர்களா?" : "Do you want to Exit the App?";
  String get viewNotifications => _ta ? "அறிவிப்புகளைக் காண" : "View Notifications";
}