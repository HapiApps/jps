import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:master_code/view_model/attendance_provider.dart';
import 'package:master_code/view_model/customer_provider.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:master_code/view_model/expense_provider.dart';
import 'package:master_code/view_model/task_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:master_code/component/custom_text.dart';
import 'package:master_code/screens/employee/view_all_employees.dart';
import 'package:master_code/screens/forgot_password.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../component/month_calendar.dart';
import '../local_database/sqlite.dart';
import '../repo/home_repo.dart';
import '../screens/attendance/attendance_report.dart';
import '../screens/common/dashboard.dart';
import '../screens/common/setting.dart';
import '../screens/common/home_page.dart';
import '../screens/customer/view_all_customer.dart';
import '../screens/expense/expense_page.dart';
import '../screens/log_in.dart';
import '../screens/report_dashboard/report_dashboard.dart';
import '../screens/track/live_location.dart';
import '../source/constant/api.dart';
import '../source/constant/colors_constant.dart';
import '../source/constant/local_data.dart';
import '../source/utilities/utils.dart';

class HomeProvider with ChangeNotifier{
final HomeRepository homeRepo = HomeRepository();
final sidebarController = SidebarXController(selectedIndex: 0, extended: true);

Future<void> deleteCacheDir() async {
  final cacheDir = await getTemporaryDirectory();

  if (cacheDir.existsSync()) {
    // Delete all files and directories in the cache directory
    for (final entity in cacheDir.listSync()) {
      // Exclude deletion of database and image files
      if (entity is File && !entity.path.endsWith('.db') && !entity.path.endsWith('.jpg')) {
        entity.deleteSync();
      } else if (entity is Directory) {
        entity.deleteSync(recursive: true);
      }
    }

    if (cacheDir.listSync().isEmpty) {
      // log('Cache directory cleared successfully.');
    } else {
      // log('Failed to clear cache directory completely.');
    }
  } else {
    // log('Cache directory does not exist.');
  }
}
Future<void> deleteAppDir() async {
  final appDir = await getApplicationSupportDirectory();

  if(appDir.existsSync()){
    appDir.deleteSync(recursive: true);
    if (!appDir.existsSync()) {
      // log('App directory cleared successfully.');
    } else {
      // log('Failed to clear app directory.');
    }
  } else {
    // log('App directory does not exist.');
  }
}
bool _isOpen = false;
bool get isOpen  => _isOpen;

void changeButton(){
  _isOpen=!_isOpen;
  notifyListeners();
}void panelClose(){
  _isOpen=false;
  notifyListeners();
}

void updateIndex(int index){
  _selectedIndex=index;
  notifyListeners();
}
int _empType=0;
int get empType =>_empType;
int _cusType=0;
int get cusType =>_cusType;
int _mainType=0;
int get mainType =>_mainType;
int _expType=0;
int get expType =>_expType;
int _taskType=0;
int get taskype =>_taskType;
final List<Widget> _mainContents = [
  const HomePage(),
  const ViewEmployees(),
  const ViewCustomer(),
  const TrackingLive(),
  // const AttendanceReport(),
  const ReportDashboard(),
  const Center(child: CustomText(text: "Notifications")),
  const Setting(),
  const Center(child: CustomText(text: "Help")),
  const ExpensePage(),
  // ViewTask(date1: _startDate, date2: _endDate),
];
List<Widget> get mainContents =>_mainContents;
// void showType(int type){
//   _empType=type;
//   notifyListeners();
// }
// void showTaskType(int type){
//   _taskType=type;
//   notifyListeners();
// }
// void showExpType(int type){
//   _expType=type;
//   notifyListeners();
// }void showCusType(int type){
//   _cusType=type;
//   notifyListeners();
// }
// void showSetType(int type){
//   _setType=type;
//   notifyListeners();
// }
// void showMainType(int type){
//   _mainType=type;
//   notifyListeners();
// }
// void changeList({String? id,String? name,String? active,String? role}){
//   _mainContents[1] =
//     _empType==0?const ViewEmployees():
//     _empType==1?const CreateEmployee():
//     _empType==2? UpdatedEmployee(id: id!,):
//     _empType==3?EmployeeDetails(id:id!, active: active!, role: role!):
//     _empType==4?ViewLog(id:id!):
//     _empType==5?UserAttendanceReport(id: id!, name: name!, active: active!, roleName: role!,):
//     _empType==6?ViewLog2(id:id!, active: active!, roleName: role!,):
//     EmployeeCustomers(id:id!, active: active!, roleName: role!,);
// }
// void changeCusList({String? id,String? companyId,String? taskId,
//   String? visitId,String? custId,String? companyName,List? customerList,bool? isDirect}){
//   _mainContents[2] =
//   _cusType==0?const ViewCustomer():
//   _cusType==1?const CreateCustomer():
//   _cusType==2?UpdateCustomer(customerId: id!):
//   _cusType==3?CustomerAttendance(companyId: companyId!, companyName: companyName!):
//   _cusType==4?CustomerVisits(companyId: companyId!, companyName: companyName!, customerList: customerList!, taskId: taskId!,):
//   _cusType==5?AddVisit(taskId:taskId!,companyId: companyId!, companyName: companyName!, numberList: customerList!, isDirect: isDirect!,):
//   _cusType==6?CustomerDetails(id: id!,):
//   _cusType==7?ViewInteractionHistory(companyId: companyId!, companyName: companyName!):
//   _cusType==8?CustomerComments(visitId: visitId!, companyName: companyName!,companyId: companyId!,numberList: customerList!, taskId: taskId!,):
//   _cusType==9?AddComment(visitId: visitId!, companyName: companyName!, companyId: companyId!,customerList: customerList!, taskId: taskId!,):
//   _cusType==10?const ViaMap():
//   ViewTasks(coId: companyId!, numberList: customerList!,);
// }
// void changesetList({String? id,String? companyId,String? companyName,List? customerList}){
//   _mainContents[7] =
//   _setType==0?const Setting():
//  const DeveloperScreen();
// }
// void changeExpList({ExpenseModel? data,required String taskId,required bool isExpense,String? coId,List? customerList}){
//   _mainContents[9] =
//   _expType==0?const ExpensePage():
//   _expType==1?CreateExpense(taskId: taskId,coId: coId!,numberList: customerList!,):
//   ExpenseDetails(data: data!,isExpense:isExpense, visitId: taskId, companyId: coId!,);
// }
// void changeTaskList({String? coId,TaskData? data,String? taskId,List? numberList,bool? isDirect}){
//   _mainContents[10] =
//   _taskType==0? const ViewAllTasks():
//   _taskType==1?const AddTask():
//   _taskType==2?TaskDetails(data: data!,isDirect:isDirect!,coId: coId!, numberList: numberList!,):
//   _taskType==3?CreateExpense(taskId: taskId,data: data, coId: coId!, numberList: numberList!,):
//   _taskType==4?EditTask(data: data!, isDirect: isDirect!,numberList: numberList!):
//   TaskReport(taskId: taskId!,coId: coId!, numberList: numberList!, isTask: isDirect!,);
// }
// void changeMainList({String? id,String? name}){
//   _mainContents[0] =
//   _mainType==0?const HomePage():
//   _mainType==1?const CorrectionReport():
//  NewEmpReport(id: id!, name: name!,);
// }

int _selectedIndex=0;
int get selectedIndex =>_selectedIndex;

int  platformId = 0;
void checkPlatform()  {
    if (kIsWeb) {
      log('Running on the web');
      platformId=3;
    } else if (Platform.isAndroid) {
      platformId=1;
      log('Running on Android');
    } else if (Platform.isIOS) {
      log('Running on iOS');
      platformId=2;
    } else if (Platform.isMacOS) {
      log('Running on macOS');
      platformId=4;
    } else if (Platform.isWindows) {
      log('Running on Windows');
      platformId=5;
    } else if (Platform.isLinux) {
      log('Running on Linux');
      platformId=6;
    } else {
      log('Unknown platform');
      platformId=7;
    }
    localData.storage.write("platform", platformId);
  }

String _usingVersion = "0";
String _currentVersion = "";
String _currentAPK = "";
String get usingVersion =>_usingVersion;
String get currentVersion =>_currentVersion;
String get currentAPK =>_currentAPK;
void updateLater(){
  _versionActive = true;
  _updateAvailable = false;
  notifyListeners();
}
checkForUpdates(bool login,context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _usingVersion= prefs.getString('appVersion') ?? "0";
    if (_usingVersion != localData.versionNumber) {
      prefs.setString('appVersion', localData.versionNumber);
    }else {
      prefs.setString('appVersion', localData.versionNumber);
    }
    log(prefs.getString('appVersion').toString());
    log(prefs.getBool('loginscreen').toString());
  }
/// Login
bool _isEyeOpen = true;
bool _rememberMe = false;
bool _versionCheck = false;
bool _versionActive = false;
bool _updateAvailable = false;
bool get isEyeOpen =>_isEyeOpen;
bool get rememberMe =>_rememberMe;
bool get versionCheck =>_versionCheck;
bool get versionActive =>_versionActive;
bool get updateAvailable =>_updateAvailable;
void manageEye(){
  _isEyeOpen=!_isEyeOpen;
  notifyListeners();
}
Future<void> remember(bool isClick) async {
  if(isClick==true){
    _rememberMe=!_rememberMe;
  }
  if(_rememberMe==true){
    final prefs =await SharedPreferences.getInstance();
    prefs.setString("mobileNumber", loginNumber.text);
    prefs.setString("password", loginPassword.text);
  }else{
    final prefs =await SharedPreferences.getInstance();
    prefs.setString("password", "");
    prefs.setString("mobileNumber", "");
  }
  notifyListeners();
}
TextEditingController loginNumber = TextEditingController();
TextEditingController loginPassword = TextEditingController();
TextEditingController forgotPassword1 = TextEditingController();
TextEditingController forgotPassword2 = TextEditingController();
final RoundedLoadingButtonController loginCtr =RoundedLoadingButtonController();
final RoundedLoadingButtonController forgotCtr =RoundedLoadingButtonController();
final RoundedLoadingButtonController checkCtr =RoundedLoadingButtonController();

  Future<void> checkLoginValues(String number) async {
    final prefs =await SharedPreferences.getInstance();
    final mobileNumber= number!="null"&&number!=""?number:prefs.getString("mobileNumber")??"";
    final password= prefs.getString("password")??"";
    loginNumber.text=mobileNumber.toString();
    loginPassword.text=password.toString();
    _isEyeOpen=true;
    if(mobileNumber!=""){
      _rememberMe=true;
    }
    notifyListeners();
  }


/// Version
Future<void> checkVersion() async {
  try {
    // notifyListeners();
    Map data = {
      "action": getAllData,
      "search_type":"version_check",
      "version":localData.versionNumber,
      "cos_id":localData.storage.read("cos_id"),
      "platform":localData.storage.read("platform")
    };
    final response = await homeRepo.selectDataList(data);
    // log("response.toString()");
    // log(response.toString());
    if (response.isNotEmpty){
      _currentVersion=response[0]["current_version"];
      _currentAPK=response[0]["current_url"];
      _versionCheck=true;
      if(localData.versionNumber==currentVersion){
        _versionActive=true;
      }else if(response[0]["active"]=="1"){
        _updateAvailable=true;
      }else{
        _versionActive=false;
        _updateAvailable=false;
      }
    }
    else {
      _versionCheck=true;
    }
  } catch (e) {
    _versionCheck=true;
  }
  notifyListeners();
}
bool _refresh=true;
bool get refresh =>_refresh;

String _date=DateFormat('MMM d, yyyy').format(DateTime.now());
String get date =>_date;
String _time=DateFormat('hh:mm a').format(DateTime.now());
String get time =>_time;


void check(){
  _date=DateFormat('MMM d, yyyy').format(DateTime.now());
  _time=DateFormat('hh:mm a').format(DateTime.now());
  notifyListeners();
}

List _roleEmp=[];
final List<Color> _roleEmpColor=[
const Color(0XFF01BED3),
const Color(0xffFFAE00),
const Color(0xff2B9EE5),
const Color(0xff2B9EE5),
const Color(0xff2B9EE5),
const Color(0xff2B9EE5),
const Color(0xff2B9EE5),
const Color(0xff2B9EE5),
const Color(0xff2B9EE5),
const Color(0xff2B9EE5),
const Color(0xff2B9EE5),
const Color(0xff2B9EE5),
const Color(0xff2B9EE5),
const Color(0xff2B9EE5),
];
List get roleEmp =>_roleEmp;
List<Color> get roleEmpColor =>_roleEmpColor;
// Future<void> roleEmployees() async {
//   try {
//     _roleEmp.clear();
//     _refresh=false;
//     notifyListeners();
//     Map data = {
//       "action": getAllData,
//       "search_type":"role_wise_details_users",
//       "cos_id":localData.storage.read("cos_id"),
//       "date1": _startDate,
//       "date2": _endDate
//     };
//     final response = await homeRepo.selectDataList(data);
//     log("response.toString()");
//     log(response.toString());
//     if (response.isNotEmpty){
//       _roleEmp=response;
//       _refresh=true;
//     }else {
//       _roleEmp=[];
//       _refresh=true;
//     }
//   } catch (e) {
//     _roleEmp=[];
//     _refresh=true;
//   }
//   notifyListeners();
// }
/// Login
Future<void> verifyUser(context) async {
    try {
      Map data = {
        "action": getAllData,
        "search_type": "verify_user",
        "mobile_number": loginNumber.text.trim(),
        "cos_id": localData.storage.read("cos_id"),
      };
      final response = await homeRepo.selectDataList(data);
      if(response.isNotEmpty){
        checkCtr.reset();
        utils.navigatePage(context,()=>const ForgotPassword());
      }else{
        utils.showWarningToast(context,text: "No user for this number");
        checkCtr.reset();
      }
    } catch (e) {
      utils.showWarningToast(context,text: "No user for this number");
      checkCtr.reset();
    }
    notifyListeners();
}
String _notificationToken="";
String get notificationToken =>_notificationToken;
  Future<void> getToken() async {
    try{
      String? token="";
      token=await FirebaseMessaging.instance.getToken();
      _notificationToken=token.toString();
      // print("token$token");
    }catch(e){
      // print("token error ....$e");
    }
  }
  PickerDateRange? selectedDate;
  List<DateTime> datesBetween = [];
  String betweenDates="";
  List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    List<DateTime> days = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(DateTime(start.year, start.month, start.day + i));
    }
    return days;
  }
  void showDatePickerDialog(BuildContext context) {
    DateTime today = DateTime.now();
    selectedDate = PickerDateRange(today, today);
    datesBetween = getDatesInRange(selectedDate!.startDate!, selectedDate!.endDate!);

    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    List<String> formattedDates = datesBetween.map((date) => dateFormat.format(date)).toList();
    betweenDates = formattedDates.join(' || ');

    _startDate = dateFormat.format(selectedDate!.startDate!);
    notifyListeners();
    notifyListeners();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(text: '   Select Date',colors: colorsConst.secondary,isBold: true,),
          content: SizedBox(
            height: 300, // Adjust height as needed
            width: 300, // Adjust width as needed
            child: SfDateRangePicker(
              minDate: DateTime(2025), // Disable past dates
              maxDate: DateTime.now(),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                selectedDate = args.value;
                _startDate="";
                _endDate="";
                if(selectedDate?.endDate!=null){
                  _startDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.year.toString()}";

                  _endDate="${selectedDate?.endDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate?.endDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate?.endDate?.year.toString()}";
                }else{
                  _startDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.year.toString()}";
                  _endDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.year.toString()}";
                }
                notifyListeners();
              },
              selectionMode: DateRangePickerSelectionMode.range,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(text: 'Click and drag to select multiple dates',colors: colorsConst.greyClr,),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const CustomText(text:'Cancel',colors: Colors.grey,isBold: true,),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: CustomText(text: 'OK',colors: colorsConst.primary,isBold: true,),
                  onPressed: () {
                    if (selectedDate != null) {
                      datesBetween = getDatesInRange(
                        selectedDate!.startDate!,
                        selectedDate!.endDate ?? selectedDate!.startDate!,
                      );
                    }
                    DateFormat dateFormat = DateFormat('dd-MM-yyyy');

                    List<String> formattedDates = datesBetween.map((date) => dateFormat.format(date)).toList();
                    betweenDates = formattedDates.join(' || ');
                    getMainReport(false);
                    getDashboardReport(false);
                    Provider.of<AttendanceProvider>(context, listen: false).getLateCount(_startDate,_endDate);
                    Provider.of<AttendanceProvider>(context, listen: false).getTotalHours(_startDate,_endDate);
                    notifyListeners();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
Future<void> login(context) async {
  // print("printttt");
  // log("logggg");
  //   try {
      checkPlatform();
      var id="",brand="",model="",version="";
      if(kIsWeb){
        final deviceInfoPlugin = DeviceInfoPlugin();
        final deviceInfo = await deviceInfoPlugin.deviceInfo;
        final allInfo = deviceInfo.data;
        id="";
        brand="";
        model=allInfo.toString();
        version="";
      }else{
        if (Platform.isIOS) {
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          id="";
          brand=iosInfo.name.toString();
          model=iosInfo.model.toString();
          version=iosInfo.systemVersion.toString();
        }else{
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          id=androidInfo.id.toString();
          brand=androidInfo.brand.toString();
          model=androidInfo.model.toString();
          version=androidInfo.version.release.toString();
        }
      }
      final prefs =await SharedPreferences.getInstance();
      Map data = {
        "action": loginUser,
        "mobile_number": loginNumber.text.trim(),
        "password": loginPassword.text.trim(),
        "cos_id":localData.storage.read("cos_id"),
        'app_version': localData.versionNumber,
        'device_id': id,
        'device_brand': brand,
        'device_model':model,
        'device_os': version,
        'token': _notificationToken,
        'platform': localData.storage.read("platform").toString()
      };
      final response = await homeRepo.loginApi(data);
      log(response.toString());
      if(response.toString().contains("No user found")){
        utils.showWarningToast(context,text: "No user found");
        loginCtr.reset();
      }else if(response.toString().contains("Incorrect password")){
        utils.showWarningToast(context,text: "Incorrect password");
        loginCtr.reset();
      }else if(response.toString().contains("Something went wrong")){
        utils.showWarningToast(context,text: "Something went wrong");
        loginCtr.reset();
      }else{
        if(response.isNotEmpty){
          localData.storage.write("f_name",response['firstname']);
          localData.storage.write("mobile_number",response['mobile_number']);
          localData.storage.write("id",response['id']);
          localData.storage.write("role_name",response['role_name']);
          localData.storage.write("role",response['role']);
          localData.storage.write("cos_id",response['cos_id']);
          localData.storage.write("conveyance_amount",response['conveyance_amount'].toString()=="null"||response['conveyance_amount'].toString()==""?"0":response['conveyance_amount'].toString());
          localData.storage.write("travel_amount",response['travel_amount'].toString()=="null"||response['travel_amount'].toString()==""?"0":response['travel_amount'].toString());
          localData.storage.write("da_amount",response['da_amount'].toString()=="null"||response['da_amount'].toString()==""?"0":response['da_amount'].toString());
          prefs.setBool("homescreen", true);
          prefs.setString("appVersion", localData.versionNumber);
          if(!kIsWeb){
            LocalDatabase.initDb();
            Provider.of<EmployeeProvider>(context, listen: false).getRoles();
            Provider.of<CustomerProvider>(context, listen: false).getLeadCategory();
            Provider.of<CustomerProvider>(context, listen: false).getVisitType();
            Provider.of<CustomerProvider>(context, listen: false).getCmtType();

            Provider.of<TaskProvider>(context, listen: false).getTaskType(false);
            Provider.of<TaskProvider>(context, listen: false).getTaskStatuses();
            Provider.of<ExpenseProvider>(context, listen: false).getExpenseType();
          }

          Provider.of<HomeProvider>(context, listen: false).updateIndex(0);
          Provider.of<HomeProvider>(context, listen: false).initValue();
          // Provider.of<HomeProvider>(context, listen: false).roleEmployees();
          Provider.of<AttendanceProvider>(context, listen: false).getMainAttendance();
          getMainReport(false);
          getDashboardReport(false);
          Future.microtask(() {
            utils.navigatePage(context,()=>const DashBoard(child: HomePage()));
          });
        }else{
          utils.showErrorToast(context: context);
          loginCtr.reset();
        }
      }
    // } catch (e) {
    //   // print(e.toString());
    //   utils.showErrorToast(context: context);
    //   loginCtr.reset();
    // }
    notifyListeners();
}
Future<void> loginOuts(context) async {
    try {
      Map data = {
        "action": logOut,
        'id': localData.storage.read("id"),
        'token':''
      };
      final response = await homeRepo.loginApi(data);
      log(response.toString());
      if(response.isNotEmpty){
        final prefs =await SharedPreferences.getInstance();
        prefs.setBool("homescreen", false);
        localData.storage.remove("firstname");
        loginNumber.clear();
        loginPassword.clear();

        LocalDatabase.deleteDb();
        if(localData.storage.read("Track")==true){
          FlutterForegroundTask.stopService();
          localData.storage.write("Track", false);
          localData.storage.write("TrackId", "0");
          localData.storage.write("TrackStatus", "2");
          localData.storage.write("T_Shift", "");
          localData.storage.write("TrackUnitName", "null");
        }
        utils.navigatePage(context,()=>const LoginPage());
        loginCtr.reset();
      }else{
        utils.showErrorToast(context: context);
        loginCtr.reset();
      }
    } catch (e) {
      utils.showErrorToast(context: context);
      loginCtr.reset();
    }
    notifyListeners();
}
Future<void> updateToken(context) async {
    try {
      String? token="";
      token=await FirebaseMessaging.instance.getToken();
      _notificationToken=token.toString();
      Map data = {
        "action": logOut,
        'id': localData.storage.read("id"),
        'token':_notificationToken
      };
      final response = await homeRepo.loginApi(data);
      log(data.toString());
      log(response.toString());
      if(response.isNotEmpty){
        debugPrint("Token updated successfully");
      }else{
      }
    } catch (e) {
      // utils.showErrorToast(context: context);
      // loginCtr.reset();
    }
    notifyListeners();
}
  List _mainReportList=[];
  List get mainReportList => _mainReportList;

  Future<void> getMainReport(bool isRefresh) async {
    if(isRefresh==true){
      _refresh=false;
      _mainReportList.clear();
      notifyListeners();
    }
    try {
      Map data = {
        "action": getAllData,
        "search_type": "main_report",
        "id": localData.storage.read("id"),
        "role": localData.storage.read("role"),
        "cos_id": localData.storage.read("cos_id"),
        "date1": _startDate,
        "date2": _endDate,
        "date3": _startDateM,
        "date4": _endDateM
      };
      final response =await homeRepo.getDashboardReport(data);
      print(data);
      print(response);
      if (response.isNotEmpty) {
        // _incompleteCount=response[0]["incomplete_count"];
        // _completeCount=response[0]["complete_count"];
        // _totalCount=response[0]["total_tasks"];
        // _totalAtt=response[0]["total_attendance"];
        _mainReportList=response;
        _mainReportList=response;
        localData.storage.write("conveyance_amount",response[0]['conveyance_amount'].toString()=="null"||response[0]['conveyance_amount'].toString()==""?"0":response[0]['conveyance_amount'].toString());
        localData.storage.write("travel_amount",response[0]['travel_amount'].toString()=="null"||response[0]['travel_amount'].toString()==""?"0":response[0]['travel_amount'].toString());
        localData.storage.write("da_amount",response[0]['da_amount'].toString()=="null"||response[0]['da_amount'].toString()==""?"0":response[0]['da_amount'].toString());
        _refresh=true;
      }else{
        _mainReportList=[];
        _refresh=true;
      }
    } catch (e) {
      _mainReportList=[];
      _refresh=true;
    }
    notifyListeners();
  }
  String _totalV="0";
  int activeVisit=0;
  int inActiveVisit=0;
  List _visitCount=[];
  List get visitCount => _visitCount;
  String get totalV => _totalV;
  bool _vRefresh = true;
  bool get vRefresh =>_vRefresh;

  Future<void> getDashboardReport(bool isRefresh) async {
    inActiveVisit=0;
    activeVisit=0;
    if(isRefresh==true){
      _totalV="0";
      _vRefresh=false;
      _visitCount.clear();
    }
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type": "dashboard_main_report",
        "id": localData.storage.read("id"),
        "role": localData.storage.read("role"),
        "cos_id": localData.storage.read("cos_id"),
        "date1": _startDate,
        "date2": _endDate
      };
      final response =await homeRepo.getDashboardReport(data);
      if (response.isNotEmpty) {
        print("response....${response}");
        _visitCount=response;
        var store=0;
        inActiveVisit=0;
        activeVisit=0;
        for(var i=0;i<response.length;i++){
          store+=int.parse(response[i]["total_count"]);
          if(response[i]["total_count"].toString()=="0"){
            inActiveVisit++;
          }else{
            activeVisit++;
          }
        }
        _totalV=store.toString();
        _vRefresh=true;
      }else{
        _visitCount=[];
        _vRefresh=true;
      }
      _vRefresh=true;
      notifyListeners();
    } catch (e) {
      _visitCount=[];
      _vRefresh=true;
      notifyListeners();
    }
    notifyListeners();
  }

Future<void> forgotPassword(context) async {
  try{
      Map data = {
        "action":forgotPsd,
        "mobile_number":loginNumber.text.trim(),
        "password":forgotPassword1.text.trim(),
        "updated_by":localData.storage.read("id")??"0",
        "cos_id":localData.storage.read("cos_id")
      };
      final response = await homeRepo.forgotPwd(data);
      if(response.toString().contains("No user for this number")){
        utils.showWarningToast(context,text: "No user for this number",);
        forgotCtr.reset();
      }else if(response.isNotEmpty){
        utils.showSuccessToast(context: context,text: "Password Updated Successfully",);
        utils.navigatePage(context,()=> LoginPage(number: loginNumber.text.trim()));
        forgotCtr.reset();
      }else{
        utils.showErrorToast(context: context);
        forgotCtr.reset();
      }
  }catch(e){
    utils.showErrorToast(context: context);
    forgotCtr.reset();
  }
      notifyListeners();
}
Future<void> deleteUseAccount(context) async {
      Map data = {
        "action":deleteAccount,
        "log_file":localData.storage.read("mobile_number"),
        "user_id":localData.storage.read("id")??"0",
        "mobile_number":localData.storage.read("mobile_number"),
        "cos_id":localData.storage.read("cos_id"),
        "platform":localData.storage.read("platform"),
      };
      final response = await homeRepo.forgotPwd(data);
      if(response.isNotEmpty){
        utils.showSuccessToast(context: context,text: "Account deleted successfully",);
        LocalDatabase.deleteDb();
        utils.navigatePage(context,()=>const LoginPage());
        loginCtr.reset();
      }else{
        utils.showErrorToast(context: context);
        loginCtr.reset();
      }
      notifyListeners();
}




  String _startDate = "";
  String get startDate => _startDate;
  String _startDateM = "";
  String get startDateM => _startDateM;
  String _endDate="";
  String get endDate => _endDate;
  String _endDateM="";
  String get endDateM => _endDateM;
  void datePick({required BuildContext context, required String date, required bool isStartDate,required void Function() function}) {
    print("Date : $date");
    final parsedDate = DateFormat('dd-MM-yyyy').parse(date);
    final now = DateTime.now();
    DateTime initDate = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      now.hour,
      now.minute,
      now.second,
    );
    showDatePicker(
      context: context,
      initialDate: initDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    ).then((value) {
      if (value != null) {
        String formattedDate = "${value.day.toString().padLeft(2, "0")}-"
            "${value.month.toString().padLeft(2, "0")}-"
            "${value.year.toString()}";
        _startDate = formattedDate;
        _startDateM = formattedDate;
        _endDate = formattedDate;
        _endDateM = formattedDate;
        function();
        notifyListeners();
      }
    });
  }
  dynamic _type;
  dynamic get type =>_type;
  String _month="";
  String get month => _month;
  var typeList = ["Today","Yesterday","Last 7 Days","Last 30 Days","This Week","This Month","Last 3 months"];

  void changeType(context,dynamic value){
    _type = value;
    if(_type=="Today"){
      daily();
    }else if(_type=="Yesterday"){
      yesterday();
    }else if(_type=="Last 7 Days"){
      last7Days();
    }else if(_type=="Last 30 Days"){
      last30Days();
    }else if(_type=="This Week"){
      thisWeek();
    }else if(_type=="This Month"){
      thisMonth();
    }else if(_type=="Last 3 months"){
      last3Month();
    }
    getMainReport(false);
    getDashboardReport(false);Provider.of<AttendanceProvider>(context, listen: false).getLateCount(_startDate,_endDate);
    Provider.of<AttendanceProvider>(context, listen: false).getTotalHours(_startDate,_endDate);

    notifyListeners();
  }
  DateTime stDt = DateTime.now();
  DateTime enDt = DateTime.now().add(const Duration(days: 1));
  void daily() {
    stDt=DateTime.now();
    enDt=DateTime.now().add(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _startDateM = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDateM = DateFormat('dd-MM-yyyy').format(stDt);
    notifyListeners();
  }
  void yesterday() {
    stDt=DateTime.now().subtract(const Duration(days: 1));
    enDt = DateTime.now();
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _startDateM = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDateM = DateFormat('dd-MM-yyyy').format(stDt);
    notifyListeners();
  }
  void last7Days() {
    DateTime now = DateTime.now();
    DateTime lastWeekStart = now.subtract(const Duration(days: 6));
    DateTime lastWeekEnd = now;
    _startDate = DateFormat('dd-MM-yyyy').format(lastWeekStart);
    _startDateM = DateFormat('dd-MM-yyyy').format(lastWeekStart);
    _endDate = DateFormat('dd-MM-yyyy').format(lastWeekEnd);
    _endDateM = DateFormat('dd-MM-yyyy').format(lastWeekEnd);
    notifyListeners();
  }
  void last30Days() {
    DateTime now = DateTime.now();
    DateTime lastMonthStart = now.subtract(const Duration(days: 29));
    DateTime lastMonthEnd = now;
    _startDate = DateFormat('dd-MM-yyyy').format(lastMonthStart);
    _startDateM = DateFormat('dd-MM-yyyy').format(lastMonthStart);
    _endDate = DateFormat('dd-MM-yyyy').format(lastMonthEnd);
    _endDateM = DateFormat('dd-MM-yyyy').format(lastMonthEnd);
    notifyListeners();
  }
  void thisWeek() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime stDt = now.subtract(Duration(days: currentWeekday - 1));
    DateTime enDt = now.add(Duration(days: 7 - currentWeekday));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _startDateM = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    _endDateM = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }
  void thisMonth() {
    DateTime now = DateTime.now();
    stDt = DateTime(now.year, now.month, 1);
    enDt = now; // Today’s date
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _startDateM = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    _endDateM = DateFormat('dd-MM-yyyy').format(enDt);
    _month=DateFormat("MMM yyyy").format(stDt);
    notifyListeners();
  }
  void checkThisMonth() {
    _startDateM = DateFormat('dd-MM-yyyy').format(DateTime(DateTime.now().year, DateTime.now().month, 1));
    _endDateM = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _month=DateFormat("MMM yyyy").format(stDt);
    notifyListeners();
  }
  void last3Month() {
    DateTime now = DateTime.now();
    DateTime stDt = DateTime(now.year, now.month - 2, now.day);
    DateTime enDt = now;

    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _startDateM = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    _endDateM = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }
  void lastMonth() {
    DateTime now = DateTime.now();
    stDt = DateTime(now.year, now.month, 1);
    enDt = DateTime(now.year, now.month + 1, 0);
    stDt = DateTime(stDt.year, stDt.month - 1, 1);
    enDt = DateTime(enDt.year, enDt.month - 1, 1);
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _startDateM = DateFormat('dd-MM-yyyy').format(stDt);
    _endDateM = DateFormat('dd-MM-yyyy').format(DateTime(enDt.year, enDt.month + 1, 0));
    notifyListeners();
  }
  void showCustomMonthPicker({
    required BuildContext context,
    required void Function() function,
  }) {
    // If _month already has a value like "Nov 2025", parse it
    DateTime now = DateTime.now();
    DateTime initialDate;

    try {
      initialDate = _month.isNotEmpty
          ? DateFormat("MMM yyyy").parse(_month)
          : now;
    } catch (e) {
      initialDate = now;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SizedBox(
            width: 300,
            height: 400,
            child: CustomMonthPicker(
              initialMonth: initialDate.month,
              initialYear: initialDate.year,
              firstYear: 2024,
              lastYear: DateTime.now().year,
              onSelected: (value) {
                int selectedMonth = value.month;
                int selectedYear = value.year;

                String startDate = DateFormat("dd-MM-yyyy")
                    .format(DateTime(selectedYear, selectedMonth, 1));
                String endDate = DateFormat("dd-MM-yyyy")
                    .format(DateTime(selectedYear, selectedMonth + 1, 0));

                _month = DateFormat("MMM yyyy").format(value);
                _startDate = startDate;
                _startDateM = startDate;
                _endDate = endDate;
                _endDateM = endDate;

                function();
                notifyListeners();
              },
            ),
          ),
        );
      },
    );
  }

  void initValue(){
    _type="Today";
    daily();
    _month=DateFormat("MMM yyyy").format(DateTime.now());
    notifyListeners();
  }
}