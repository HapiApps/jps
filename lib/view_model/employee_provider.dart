import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:master_code/repo/employee_repo.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:master_code/screens/common/fullscreen_photo.dart';
import 'package:master_code/screens/log_in.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../component/custom_text.dart';
import '../local_database/sqlite.dart';
import '../model/user_model.dart';
import '../screens/common/camera.dart';
import '../screens/common/dashboard.dart';
import '../screens/employee/employee_details.dart';
import '../source/constant/api.dart';
import '../source/constant/assets_constant.dart';
import '../source/constant/colors_constant.dart';
import '../source/constant/default_constant.dart';
import '../source/constant/local_data.dart';
import '../source/utilities/utils.dart';

class EmployeeProvider with ChangeNotifier{
final EmployeeRepository empRepo = EmployeeRepository();


int _swipeIndex = 0;
int get swipeIndex =>_swipeIndex;
void addressCheck(dynamic value){
  _isPermanentAdd=value;
  notifyListeners();
  if(isPermanentAdd==true&&_houseType!="Rented"){
      permanentDoNo.text=doorNo.text;
      permanentStreet.text=streetName.text;
      permanentArea.text=comArea.text;
      permanentCity.text=city.text;
      _permanentState=state;
      permanentPin.text=pinCode.text;
      permanentCountry.text=country.text;
  }
  else{
      permanentDoNo.text="";
      permanentStreet.text="";
      permanentArea.text="";
      permanentCity.text="";
      permanentPin.text="";
      permanentCountry.text="";
      _permanentState=null;
  }
}

void isWhatsAppCheck({bool? isUpdate}){
  if(isUpdate==true){
    _isWhatsApp=!_isWhatsApp;
  }
  if(_isWhatsApp==true){
    signWhatsappNumber.text=signMobileNumber.text;
  }else{
    signWhatsappNumber.clear();
  }
  notifyListeners();
}
void updateIndex(int index){
  _swipeIndex=index;
  tabController?.index=index;
  notifyListeners();
}
bool _isPermanentAdd=false;
bool _isWhatsApp=false;
bool get isPermanentAdd=>_isPermanentAdd;
bool get isWhatsApp=>_isWhatsApp;

dynamic _signPrefix;
dynamic _houseType;
dynamic get signPrefix=>_signPrefix;
dynamic get houseType=>_houseType;
List relationList = ["Father", "Spouse"],maritalList = ["Single", "Married", "Separated"],houseTypeList = ["Rented", "Owned", "Parental"];
void changePrefix(dynamic value){
  _signPrefix=value;
  notifyListeners();
}void changePrefix2(dynamic value){
  _signSpousePrefix=value;
  notifyListeners();
}
void changeHouseType(dynamic value){
  _houseType=value;
  notifyListeners();
}
void changeMaritalStatus(dynamic value){
  _maritalStatus=value;
  notifyListeners();
}
void changeRelation(dynamic value){
  _relation=value;
  notifyListeners();
}
List prefix = ["Mr", "Mrs", "Dr", "Ms"];
TextEditingController gradeCtr = TextEditingController();
TextEditingController search = TextEditingController();
TextEditingController signFirstName = TextEditingController();
TextEditingController signLastName = TextEditingController();
TextEditingController department = TextEditingController();
TextEditingController signMobileNumber = TextEditingController();
TextEditingController signPassword = TextEditingController();
TextEditingController signEmailid = TextEditingController();
TextEditingController signReffered = TextEditingController();
TextEditingController userRole = TextEditingController(text: "Admin");
TextEditingController deleteReason = TextEditingController();
TextEditingController doorNo = TextEditingController();
TextEditingController streetName = TextEditingController();
TextEditingController comArea = TextEditingController();
TextEditingController city = TextEditingController();
TextEditingController country = TextEditingController();
TextEditingController pinCode = TextEditingController();
TextEditingController salary = TextEditingController();

TextEditingController signMiddleName = TextEditingController();
TextEditingController permanentDoNo = TextEditingController();
TextEditingController permanentStreet = TextEditingController();
TextEditingController permanentArea = TextEditingController();
TextEditingController permanentCity = TextEditingController();
TextEditingController permanentPin = TextEditingController();
TextEditingController permanentCountry = TextEditingController(text: "India");
TextEditingController signWhatsappNumber = TextEditingController();
TextEditingController signDob = TextEditingController();
TextEditingController signSpFirstname = TextEditingController();
TextEditingController signSpMiddlename = TextEditingController();
TextEditingController signSpLastname = TextEditingController();
TextEditingController signMarital = TextEditingController();
TextEditingController signAadhar = TextEditingController();
TextEditingController signPan = TextEditingController();
TextEditingController signEmFname = TextEditingController();
TextEditingController signEmLname = TextEditingController();
TextEditingController signEmPh = TextEditingController();
TextEditingController signEmRelation = TextEditingController();
TextEditingController signJoiningDate = TextEditingController(text: "${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}");
TextEditingController lastWorkingday= TextEditingController();
TextEditingController signLastOrganization = TextEditingController();
TextEditingController signReFname1 = TextEditingController();
TextEditingController signReFname2 = TextEditingController();
TextEditingController signReLname1 = TextEditingController();
TextEditingController signReLname2 = TextEditingController();
TextEditingController signRePh1 = TextEditingController();
TextEditingController signRePh2 = TextEditingController();
TextEditingController blood = TextEditingController();

  final RoundedLoadingButtonController signCtr =RoundedLoadingButtonController();
void datePick({required BuildContext context, required String date,required bool isStartDate}) {
  DateTime dateTime = DateTime.now();
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
    initialDate: initDate,
    context: context,
    firstDate: DateTime(1920),
    lastDate: DateTime.now(),
  ).then((value) {
    if (value != null) {
      String formattedDate = "${value.day.toString().padLeft(2, "0")}-"
          "${value.month.toString().padLeft(2, "0")}-"
          "${value.year.toString()}";

      if (isStartDate) {
        _startDate = formattedDate;
      } else {
        _endDate = formattedDate;
      }

      notifyListeners();
    }
  });
}


String _profile="";
String _aadharPhoto="";
String _aadharPhoto2="";
String _panPhoto="";
String _chequePhoto="";
String _licensePhoto="";
String _voterPhoto="";
String get profile=>_profile;
String get aadharPhoto=>_aadharPhoto;
String get aadharPhoto2=>_aadharPhoto2;
String get panPhoto=>_panPhoto;
String get chequePhoto=>_chequePhoto;
String get licensePhoto=>_licensePhoto;
String get voterPhoto=>_voterPhoto;

List<int> _profileList=[];
List<int> _aadharPhotoList=[];
List<int> _aadharPhotoList2=[];
List<int> _panPhotoList=[];
List<int> _chequePhotoList=[];
List<int> _licensePhotoList=[];
List<int> _voterPhotoList=[];
List<int> get profileList=>_profileList;
List<int> get aadharPhotoList=>_aadharPhotoList;
List<int> get aadharPhotoList2=>_aadharPhotoList2;
List<int> get panPhotoList=>_panPhotoList;
List<int> get chequePhotoList=>_chequePhotoList;
List<int> get licensePhotoList=>_licensePhotoList;
List<int> get voterPhotoList=>_voterPhotoList;

String _profileName="";
String _aadharPhotoName="";
String _aadharPhotoName2="";
String _panPhotoName="";
String _chequePhotoName="";
String _licensePhotoName="";
String _voterPhotoName="";
String get profileName=>_profileName;
String get aadharPhotoName=>_aadharPhotoName;
String get aadharPhotoName2=>_aadharPhotoName2;
String get panPhotoName=>_panPhotoName;
String get chequePhotoName=>_chequePhotoName;
String get licensePhotoName=>_licensePhotoName;
String get voterPhotoName=>_voterPhotoName;

String _lastCheck="";
String _commentCount="";
String get lastCheck=>_lastCheck;
String get commentCount=>_commentCount;

String _selectRole="0";
String get selectRole=>_selectRole;
void selectedRole(value){
  _selectRole=value;
  notifyListeners();
}
String _empStatus="0";
String get empStatus=>_empStatus;
bool _filter=false;
bool get filter=>_filter;
void selectStatus(value){
  _empStatus=value;
  notifyListeners();
}
// void filterList(){
// _filterUserData = _searchUserData.where((contact){
//   final empProviderDate1 = _startDate; // Start Date
//   final empProviderDate2 = _endDate; // End Date
//   final dateFormat = DateFormat('dd-MM-yyyy');
//
//   DateTime  createdTsDate = DateTime.parse(contact.createdTs.toString());
//   final parsedDate1 = dateFormat.tryParse(empProviderDate1);
//   final parsedDate2 = dateFormat.tryParse(empProviderDate2);
//   print("date1.text $_startDate");
//   print("date2.text $_endDate");
//   print("date2.text ${contact.createdTs.toString()}");
//   bool isWithinDateRange =
//       createdTsDate.isAfter(parsedDate1!.subtract(const Duration(days: 1))) &&
//           createdTsDate.isBefore(parsedDate2!.add(const Duration(days: 1)));
// return isWithinDateRange&&_selectRole == contact.role &&_empStatus == contact.active;
// }).toList();
// notifyListeners();
// }

  void filterList() {

    final dateFormat = DateFormat('dd-MM-yyyy');
    final parsedDate1 = dateFormat.parse(_startDate);
    final parsedDate2 = dateFormat.parse(_endDate);

    _filterUserData = _searchUserData.where((contact) {
      final createdTsDate = DateTime.parse(contact.createdTs.toString());
      final createdDateOnly = DateTime(createdTsDate.year, createdTsDate.month, createdTsDate.day);
      // print("Dates...... ${_startDate}-${_endDate}");
      // print("Created ts......${contact.createdTs.toString()}");
      final isWithinDateRange = !createdDateOnly.isBefore(parsedDate1) && !createdDateOnly.isAfter(parsedDate2);
      final isRoleMatch = _selectRole == contact.role;
      final isStatusMatch = _empStatus == contact.active;
      if (_selectRole == "0" && _empStatus == "0") {
        return isWithinDateRange;
      }else if (_selectRole == "0"&& _empStatus != "0") {
        return isWithinDateRange && isStatusMatch;
      }else if ( _empStatus == "0" && _selectRole != "0") {
        return isWithinDateRange && isRoleMatch;
      } else {
        return isWithinDateRange && isRoleMatch && isStatusMatch;
      }
    }).toList();
    _active=0;
    _inActive=0;
    for (var user in _filterUserData) {
      user.active == "1" ? _active++ : _inActive++;
    }
    notifyListeners();
  }

  void signDialog({
    required BuildContext context,
    required String img,
    required String imgName,
    required List<int> imgList,
    required String docType,
    required void Function(String docType, String img, String name, List<int> bytes) onPicked,
    required void Function(String docType) onRemove,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text("Pick Document From")),
          content: SizedBox(
            height: 120,
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!kIsWeb)
                      GestureDetector(
                        onTap: () async {
                          var imgData = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const CameraWidget(cameraPosition: CameraType.front),
                            ),
                          );
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          if (imgData != null) {
                            onPicked(docType, imgData, "", []);
                          }
                        },
                        child: Column(
                          children: [
                            SvgPicture.asset(assets.cam),
                            5.height,
                            const CustomText(text: "Camera")
                          ],
                        ),
                      ),
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowMultiple: false,
                          allowedExtensions: ['png', 'jpeg', 'jpg'],
                        );
                        if (result != null) {
                          if (kIsWeb) {
                            onPicked(
                              docType,
                              "",
                              result.files.single.name,
                              result.files.single.bytes!.toList(),
                            );
                          } else {
                            onPicked(docType, result.files.single.path!, "", []);
                          }
                        }
                      },
                      child: Column(
                        children: [
                          SvgPicture.asset(assets.gallery),
                          5.height,
                          const CustomText(text: "Gallery")
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (img.isNotEmpty)
                    // if (img.isNotEmpty && !img.contains("uUsSrR"))
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onRemove(docType);
                        },
                        child: CustomText(text: "Remove", colors: colorsConst.appRed),
                      ),
                    if (img.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreen(
                                image: img,
                                isNetwork: img.contains("uUsSrR"),
                              ),
                            ),
                          );
                        },
                        child: CustomText(text: "Full View", colors: colorsConst.blueClr),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void setDocument(String docType, String img, String name, List<int> bytes) {
    switch (docType) {
      case "profile":
        _profile = img;
        _profileName = name;
        _profileList = bytes;
        oldImage = img;
        break;
      case "aadhar":
        _aadharPhoto = img;
        _aadharPhotoName = name;
        _aadharPhotoList = bytes;
        oldImage2 = img;
        break;
      case "aadhar2":
        _aadharPhoto2 = img;
        _aadharPhotoName2 = name;
        _aadharPhotoList2 = bytes;
        oldImage3 = img;
        break;
      case "pan":
        _panPhoto = img;
        _panPhotoName = name;
        _panPhotoList = bytes;
        oldImage4 = img;
        break;
      case "cheque":
        _chequePhoto = img;
        _chequePhotoName = name;
        _chequePhotoList = bytes;
        oldImage5 = img;
        break;
      case "license":
        _licensePhoto = img;
        _licensePhotoName = name;
        _licensePhotoList = bytes;
        oldImage6 = img;
        break;
      case "voter":
        _voterPhoto = img;
        _voterPhotoName = name;
        _voterPhotoList = bytes;
        oldImage7 = img;
        break;
    }
    notifyListeners();
  }

  void removeDocument(String docType) {
    setDocument(docType, "", "", []);
  }

  void initFilterValue(bool isClear){
  if(isClear==false){
    _filter=true;
  }else{
    _filter=false;
    _selectRole="0";
    _empStatus="0";
    daily();
    _type="Today";
    _filterUserData=_userData;
  }
  search.clear();
  _active=0;
  _inActive=0;
  _userName="";
  searchName="";
  for (var user in _filterUserData) {
    user.active == "1" ? _active++ : _inActive++;
  }
  notifyListeners();
}
void profilePick(String imgData){
  _profile = imgData;
  // print(_profile);
  notifyListeners();
}
// String _latitude = "0.0";
// String _longitude = "0.0";
// String get latitude=>_latitude;
// String get longitude=>_longitude;
Future<void> getAdd(double lat,double lng) async {
  List<Placemark> placeMark=await placemarkFromCoordinates(lat,lng);
  Placemark place = placeMark[0];
  doorNo.text=place.street.toString();
  streetName.text=place.subLocality.toString();
  comArea.text=place.thoroughfare.toString()==""?"":",${place.thoroughfare}"==""?"":place.thoroughfare.toString();
  city.text=place.locality.toString();
  country.text=place.country.toString();
  pinCode.text=place.postalCode.toString();
  state=place.administrativeArea.toString();
  notifyListeners();
}
dynamic state,_type;
dynamic get type =>_type;
var stateList = [
  "Andaman and Nicobar Islands",
  "Andhra Pradesh",
  "Arunachal Pradesh",
  "Assam",
  "Bihar",
  "Chandigarh",
  "Chhattisgarh",
  "Dadra and Nagar Haveli and Daman",
  "Delhi NCT",
  "Goa",
  "Gujarat",
  "Haryana",
  "Himachal Pradesh",
  "Jammu & Kashmir",
  "Jharkhand",
  "Karnataka",
  "Kerala",
  "Ladakh",
  "Lakshadweep",
  "Madhya Pradesh",
  "Maharashtra",
  "Manipur",
  "Meghalaya",
  "Mizoram",
  "Nagaland",
  "Odisha",
  "Puducherry",
  "Punjab",
  "Rajasthan",
  "Sikkim",
  "Tamil Nadu",
  "Telangana",
  "Tripura",
  "Uttar Pradesh",
  "Uttarakhand",
  "West Bengal"
];
var typeList = ["Today","Yesterday","Last 7 Days","Last 30 Days","This Week","This Month","Last 3 months"];
void changeType(dynamic value){
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
  notifyListeners();
}
String _startDate = "";
String get startDate => _startDate;
String _endDate="";
String get endDate => _endDate;
DateTime stDt = DateTime.now();
DateTime enDt = DateTime.now().add(const Duration(days: 1));
void daily() {
  stDt=DateTime.now();
  enDt=DateTime.now().add(const Duration(days: 1));
  _startDate = DateFormat('dd-MM-yyyy').format(stDt);
  _endDate = DateFormat('dd-MM-yyyy').format(stDt);
  notifyListeners();
}
void yesterday() {
  stDt=DateTime.now().subtract(const Duration(days: 1));
  enDt = DateTime.now();
  _startDate = DateFormat('dd-MM-yyyy').format(stDt);
  _endDate = DateFormat('dd-MM-yyyy').format(stDt);
  notifyListeners();
}
void last7Days() {
  DateTime now = DateTime.now();
  DateTime lastWeekStart = now.subtract(const Duration(days: 6));
  DateTime lastWeekEnd = now;
  _startDate = DateFormat('dd-MM-yyyy').format(lastWeekStart);
  _endDate = DateFormat('dd-MM-yyyy').format(lastWeekEnd);
  notifyListeners();
}
void last30Days() {
  DateTime now = DateTime.now();
  DateTime lastMonthStart = now.subtract(const Duration(days: 29));
  DateTime lastMonthEnd = now;
  _startDate = DateFormat('dd-MM-yyyy').format(lastMonthStart);
  _endDate = DateFormat('dd-MM-yyyy').format(lastMonthEnd);
  notifyListeners();
}
void thisWeek() {
  DateTime now = DateTime.now();
  int currentWeekday = now.weekday;
  DateTime stDt = now.subtract(Duration(days: currentWeekday - 1));
  DateTime enDt = now.add(Duration(days: 7 - currentWeekday));
  _startDate = DateFormat('dd-MM-yyyy').format(stDt);
  _endDate = DateFormat('dd-MM-yyyy').format(enDt);
  notifyListeners();
}
void thisMonth() {
  DateTime now = DateTime.now();
  stDt = DateTime(now.year, now.month, 1);
  enDt = now; // Today’s date
  _startDate = DateFormat('dd-MM-yyyy').format(stDt);
  _endDate = DateFormat('dd-MM-yyyy').format(enDt);
  notifyListeners();
}
void last3Month() {
  DateTime now = DateTime.now();

// Subtract 3 months from today
  DateTime stDt = DateTime(now.year, now.month - 3, now.day);
  DateTime enDt = now;

  _startDate = DateFormat('dd-MM-yyyy').format(stDt);
  _endDate = DateFormat('dd-MM-yyyy').format(enDt);
  notifyListeners();
}
void lastMonth() {
  DateTime now = DateTime.now();
  stDt = DateTime(now.year, now.month, 1);
  enDt = DateTime(now.year, now.month + 1, 0);
  stDt = DateTime(stDt.year, stDt.month - 1, 1);
  enDt = DateTime(enDt.year, enDt.month - 1, 1);
  _startDate = DateFormat('dd-MM-yyyy').format(stDt);
  _endDate = DateFormat('dd-MM-yyyy').format(DateTime(enDt.year, enDt.month + 1, 0));
  notifyListeners();
}
void changeState(dynamic value){
  state = value;
  _update = true;
  notifyListeners();
}
void changeState2(dynamic value){
  _permanentState = value;
  _update = true;
  notifyListeners();
}
// bool _isVisible=false;
// int _visibleIndex=0;
// bool get isVisible =>_isVisible;
// int get visibleIndex =>_visibleIndex;
// void visible(int index){
//   if(_isVisible==true){
//
//   }else{
//     _isVisible=true;
//   }
//   _visibleIndex=index;
//   notifyListeners();
// }

dynamic _role;
dynamic get role =>_role;
void changeRole(dynamic value){
  _update=true;
  _role = value!;
  var list = [];
  list.add(value);
  localData.storage.write("roleId", list[0]["id"]);
  localData.storage.write("roleName", list[0]["role"]);
  notifyListeners();
}

dynamic _grade;
dynamic get grade =>_grade;
void changeGrade(dynamic value,bool isUpdate){
  if(isUpdate==true){
    _update = true;
  }
  _grade = value!;
  var list = [];
  list.add(value);
  localData.storage.write("g_id", list[0]["id"]);
  notifyListeners();
}
TabController? tabController;

void initValues(){
  if (tabController?.indexIsChanging != null) {
    tabController?.index = 0;
  }
  _swipeIndex=0;
  _profile = "";
  _profileList=[];
  _profileName="";
  _signPrefix="Mr";
  _signSpousePrefix="Mr";
  signFirstName.clear();
  signMiddleName.clear();
  signLastName.clear();
  signMobileNumber.clear();
  signPassword.clear();
  _isWhatsApp=false;
  signWhatsappNumber.clear();
  signDob.clear();
  signJoiningDate.text="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
  _role = null;
  _grade=null;
  blood.clear();
  salary.clear();

  signEmailid.clear();
  _aadharPhoto = "";
  _aadharPhoto2 = "";
  _panPhoto = "";
  _aadharPhotoList=[];
  _aadharPhotoList2=[];
  _panPhotoList=[];
  _aadharPhotoName="";
  _aadharPhotoName2="";
  _panPhotoName="";
  signAadhar.clear();
  signPan.clear();
  _houseType=null;
  _maritalStatus=null;
  _relation=null;
  signSpFirstname.clear();

  _isPermanentAdd=false;
  permanentDoNo.clear();
  permanentStreet.clear();
  permanentArea.clear();
  permanentCity.clear();
  permanentCountry.text="India";
  permanentPin.clear();
  _permanentState=null;

  signEmFname.clear();
  signEmPh.clear();
  signEmRelation.clear();

  signLastOrganization.clear();
  signReffered.clear();

  signReFname1.clear();
  signReFname2.clear();
  signRePh1.clear();
  signRePh2.clear();

  _chequePhoto = "";
  _licensePhoto = "";
  _voterPhoto = "";
  _chequePhotoList=[];
  _licensePhotoList=[];
  _voterPhotoList=[];
  _chequePhotoName="";
  _licensePhotoName="";
  _voterPhotoName="";
  notifyListeners();
}
void makeChanges(){
  _update = true;
  notifyListeners();
}
// void initEmpValues(UserModel data){
//
//   notifyListeners();
// }
/// Roles
List _roleValues = [];
List get roleValues => _roleValues;

List _gradeValues = [];
List get gradeValues => _gradeValues;
Future<void> getRoles() async {
    try {
      Map data = {
        "action": getAllData,
        "search_type":"allroles",
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role")
      };
      final response = await empRepo.getRole(data);
      print("response");
      print(response);
      if(response.isNotEmpty){
        List<Map<String, String>> callList = response.map((e) => {
          "id": e['id'].toString(),
          "role": e['role'].toString(),
        }).toList();
        if(!kIsWeb){
          await LocalDatabase.insertRole(callList);
        }else{
          _roleValues=callList;
        }
      }
      else{
      }
    } catch (e) {
      // _roleValues.clear();
    }
    notifyListeners();
  }
Future<void> getGrades(bool isRefresh) async {
    try {
      _gradeValues.clear();
      if(isRefresh==true){
        _refresh=false;
        notifyListeners();
      }
      Map data = {
        "action": getAllData,
        "search_type":"emp_grades",
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role")
      };
      final response = await empRepo.getRole(data);
      // print("nvf ${response}");
      if(response.isNotEmpty){
        List<Map<String, dynamic>> callList = response.map((e) => {
          "id": e['id'].toString(),
          "grade": e['grade'].toString(),
          "conv": TextEditingController(text: e['conveyance_amount'].toString()),
          "tra": TextEditingController(text: e['travel_amount'].toString()),
          "da": TextEditingController(text: e['da_amount'].toString()),
        }).toList();
        _gradeValues=callList;
        _refresh=true;
      }
      else{
        _refresh=true;
      }
    } catch (e) {
      _refresh=true;
    }
    notifyListeners();
  }
  bool _changed=false;
  bool get changed =>_changed;
  void initValue(){
    _changed=false;
    notifyListeners();
  }void changedValue(){
    _changed=true;
    notifyListeners();
  }
  List<Map<String, dynamic>> changesList=[];
  void insertGradeDetails(context) async {
    try {
      changesList.clear();
      for(var i=0;i<gradeValues.length;i++){
        changesList.add({
          "updated_by":localData.storage.read("id"),
          "cos_id":localData.storage.read("cos_id"),
          "grade_id":gradeValues[i]["id"],
          "conv":gradeValues[i]["conv"].text,
          "tra":gradeValues[i]["tra"].text,
          "da":gradeValues[i]["da"].text
        });
      }
      // print(changesList);
      notifyListeners();
      final Map<String, dynamic> data = {
        'action': addGradeAmount,
        'gradeList': changesList, // The list
      };
      final response = await empRepo.insertGradleDetails(data);
      if (response.toString().contains("ok")) {
        utils.showSuccessToast(context: context,text: constValue.updated);
        signCtr.reset();
        getGrades(true);
        Navigator.pop(context);
        notifyListeners();
      } else {
        utils.showErrorToast(context: context);
        signCtr.reset();
      }
    } catch (e) {
      utils.showErrorToast(context: context);
      signCtr.reset();
    }
    notifyListeners();
  }

  late GoogleMapController googleMapController;
final List<Marker> _marker =[];
List<Marker> get marker =>_marker;
// void manageLocation(context,bool openSetting) async {
//   try {
//     Map<Permission, PermissionStatus> status = await [
//       Permission.location,
//     ].request();
//     if (status[Permission.location] == PermissionStatus.granted) {
//       bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!isLocationServiceEnabled) {
//         utils.showWarningToast(context, text: "Location services are disabled. Please enable them.");
//       }else{
//         Position position= await Geolocator.getCurrentPosition();
//         _latitude="${position.latitude}";
//         _longitude="${position.longitude}";
//         log('Current location: $_latitude $_longitude');
//         if(_latitude=="0.0"&&_longitude=="0.0"){
//           utils.showWarningToast(context, text: "Check Your Location");
//         }
//       }
//     }else{
//       log("Location permissions are denied.");
//       if(openSetting==true){
//         await openAppSettings();
//       }
//     }
//   } on PlatformException catch (e) {
//     log('Failed to get location: ${e.message}');
//   }
// }

  Future<void> mapAddress() async {
  if(search.text!=""){
    try{
      List<Location> locations = await locationFromAddress(search.text);
      googleMapController.animateCamera
        (CameraUpdate.newCameraPosition(CameraPosition
        (target: LatLng(locations[0].latitude,locations[0].longitude),zoom: 20)));
      _marker.add(
        Marker(
          markerId: const MarkerId("1"),
          position:LatLng(locations[0].latitude,locations[0].longitude),
          infoWindow: InfoWindow(title: search.text),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet
          ),),);
      List<Placemark> placeMark=await placemarkFromCoordinates(locations[0].latitude,locations[0].longitude);
      Placemark place = placeMark[0];
      doorNo.text=place.street.toString();
      comArea.text="${place.subLocality.toString()}${place.thoroughfare.toString()==""?"":",${place.thoroughfare}"==""?"":place.thoroughfare.toString()}";
      city.text=place.locality.toString();
      country.text=place.country.toString();
      pinCode.text=place.postalCode.toString();
      state=place.administrativeArea.toString();
    }catch(e){
      // utils.showWarningToast(context, text: "Search valid name", color: colorsConst.primary);
    }
  }
  notifyListeners();
}
  Future<void> getAllRoles() async {
    _roleValues.clear();
    List storedLeads = await LocalDatabase.getRoles();
    _roleValues=storedLeads;
    notifyListeners();
  }
  Future<void> getAllGrades() async {
    _gradeValues.clear();
    List storedLeads = await LocalDatabase.getGrades();
    _gradeValues=storedLeads;
    notifyListeners();
  }
  Future<void> refreshRoles() async {
    _role=null;
    _roleValues.clear();
    List storedLeads = await LocalDatabase.getRoles();
    _roleValues=storedLeads;
    notifyListeners();
  }
  Future<void> refreshGrades() async {
    _grade=null;
    _gradeValues.clear();
    List storedLeads = await LocalDatabase.getGrades();
    _gradeValues=storedLeads;
    notifyListeners();
  }

dynamic _relation;
dynamic _house;
dynamic _signSpousePrefix;
dynamic _maritalStatus;
dynamic _permanentState;
dynamic get relation =>_relation;
dynamic get house =>_house;
dynamic get signSpousePrefix =>_signSpousePrefix;
dynamic get maritalStatus =>_maritalStatus;
dynamic get permanentState =>_permanentState;


/// add Employee
// Future<void> insertEmployee(context,String lat,String lng) async {
//   // try {
//     Map<String, String> data = {
//       "action": createEmp,
//       "log_file": localData.storage.read("mobile_number").toString(),
//       "firstname": signFirstName.text.trim(),
//       "password": signPassword.text.trim(),
//       "mobile_number":signMobileNumber.text.trim(),
//       "surname":signLastName.text.trim(),
//       "role": localData.storage.read("roleId"),
//       "created_by": localData.storage.read("id"),
//       "referred_by": signReffered.text.trim(),
//       "email_id": signEmailid.text.trim(),
//       "boss_id": "1",
//       "platform": localData.storage.read("platform").toString(),
//       "cos_id": localData.storage.read("cos_id"),
//       "grade_id": localData.storage.read("g_id"),
//       "door_no": doorNo.text.trim(),
//       "area": comArea.text.trim(),
//       "city": city.text.trim(),
//       "country": country.text.trim(),
//       "state": state.toString(),
//       "pincode": pinCode.text.trim(),
//       "lat": lat,
//       "lng": lng
//     };
//     final response =await empRepo.addEmployee(data,
//         _profile,_profileList,_profileName,
//         _aadharPhoto,_aadharPhotoList,_aadharPhotoName,
//         _aadharPhoto2,_aadharPhotoList2,_aadharPhotoName2,
//         _panPhoto,_panPhotoList,_panPhotoName,
//         _chequePhoto,_chequePhotoList,_chequePhotoName,
//         _licensePhoto,_licensePhotoList,_licensePhotoName,
//         _voterPhoto,_voterPhotoList,_voterPhotoName
//     );
//     print(response.toString());
//     if (response.toString().contains("Employee with this Phone Number already exits")){
//       utils.showWarningToast(context,text: "Employee with this Phone Number already exits");
//       signCtr.reset();
//     }else if (response["status_code"]==200){
//       utils.showSuccessToast(context: context,text: "User ${constValue.success}",);
//       getAllUsers();
//       Provider.of<HomeProvider>(context, listen: false).roleEmployees();
//       Provider.of<HomeProvider>(context, listen: false).getMainReport(false);
//       Provider.of<HomeProvider>(context, listen: false).getDashboardReport(false);
//       // Provider.of<HomeProvider>(context, listen: false).showType(0);
//       // Provider.of<HomeProvider>(context, listen: false).changeList();
//       Future.microtask(() => Navigator.pop(context));
//       signCtr.reset();
//     }else {
//       utils.showErrorToast(context: context);
//       signCtr.reset();
//     }
//   // } catch (e) {
//   //   // log(e.toString());
//   //   utils.showErrorToast(context: context);
//   //   signCtr.reset();
//   // }
//   notifyListeners();
// }

/// add Employee
Future<void> insertEmployeeDetails(context,String lat,String lng) async {
    try {
    Map<String, String> data = {
      "action": insertUsers,
      "log_file": localData.storage.read("mobile_number").toString(),
      "firstname": signFirstName.text.trim(),
      "password": signPassword.text.trim(),
      "mobile_number":signMobileNumber.text.trim(),
      "surname":signLastName.text.trim(),
      "role": localData.storage.read("roleId"),
      "created_by": localData.storage.read("id"),
      "referred_by": signReffered.text.trim(),
      "email_id": signEmailid.text.trim(),
      "boss_id": "1",
      "platform": localData.storage.read("platform").toString(),
      "cos_id": localData.storage.read("cos_id"),
      "grade_id": localData.storage.read("g_id")??"0",
      "door_no": doorNo.text.trim(),
      "street_name": streetName.text.trim(),
      "area": comArea.text.trim(),
      "city": city.text.trim(),
      "country": country.text.trim(),
      "state": state.toString(),
      "pincode": pinCode.text.trim(),
      "lat": lat,
      "lng": lng,

      
      "prefixes": signPrefix.toString(),
      "blood_group": blood.text.trim(),
      "m_name":signMiddleName.text.trim(),
      "whatsapp_number":signWhatsappNumber.text.trim(),
      "date_of_birth":signDob.text.trim(),
      "date_of_joining":signJoiningDate.text.trim(),
      "house_type":_houseType.toString(),
      "adhaar":signAadhar.text.trim(),
      "pan":signPan.text.trim(),
      "relation":relation.toString(),
      "prefixes_2":signSpousePrefix.toString(),
      "relation_name":signSpFirstname.text.trim(),
      "marital_status":maritalStatus.toString(),
      "emg_name":signEmFname.text.trim(),
      "emg_no":signEmPh.text.trim(),
      "emg_relation": signEmRelation.text.trim(),
      "last_org": signLastOrganization.text.toString(),
      "ref1_name": signReFname1.text.toString(),
      "ref1_no": signRePh1.text.trim(),
      "ref2_name": signReFname2.text.trim(),
      "ref2_no": signRePh2.text.trim(),
      "door_no_perm":permanentDoNo.text.trim(),
      "street_name_perm":permanentStreet.text.trim(),
      "area_perm":permanentArea.text.trim(),
      "city_perm":permanentCity.text.trim(),
      "state_perm":permanentState??"Tamil Nadu",
      "country_perm":permanentCountry.text.trim(),
      "pincode_perm":permanentPin.text.trim(),
      "lat_perm":"0.0",
      "lng_perm":"0.0",
      "salary":salary.text,
    };
    final response =await empRepo.addEmployee(data,_profile,_profileList,_profileName,_aadharPhoto,_aadharPhotoList,_aadharPhotoName,
        _aadharPhoto2,_aadharPhotoList2,_aadharPhotoName2,
        _panPhoto,_panPhotoList,_panPhotoName,
        _chequePhoto,_chequePhotoList,_chequePhotoName,
        _licensePhoto,_licensePhotoList,_licensePhotoName,
        _voterPhoto,_voterPhotoList,_voterPhotoName);
    // print(response.toString());
    if (response.toString().contains("Employee with this Phone Number already exits")){
      utils.showWarningToast(context,text: "Employee with this Phone Number already exits");
      signCtr.reset();
    }else if (response["status_code"]==200){
      utils.showSuccessToast(context: context,text: "User ${constValue.success}",);
      getAllUsers();
      // Provider.of<HomeProvider>(context, listen: false).roleEmployees();
      Provider.of<HomeProvider>(context, listen: false).getMainReport(false);
      Provider.of<HomeProvider>(context, listen: false).getDashboardReport(false);
      // Provider.of<HomeProvider>(context, listen: false).showType(0);
      // Provider.of<HomeProvider>(context, listen: false).changeList();
      Future.microtask(() => Navigator.pop(context));
      signCtr.reset();
    }else {
      utils.showErrorToast(context: context);
      signCtr.reset();
    }
    } catch (e) {
      // log(e.toString());
      utils.showErrorToast(context: context);
      signCtr.reset();
    }
    notifyListeners();
  }
/// SignUp Employee
Future<void> signupEmployee(context,String lat,String lng) async {
  try {
    Provider.of<HomeProvider>(context, listen: false).checkPlatform();
    Map<String, String> data = {
      "action": signUp,
      "log_file": signMobileNumber.text.trim(),
      "firstname": signFirstName.text.trim(),
      "password": signPassword.text.trim(),
      "mobile_number":signMobileNumber.text.trim(),
      "surname":signLastName.text.trim(),
      "role": "1",
      "created_by": "Signup",
      "referred_by": signReffered.text.trim(),
      "email_id": signEmailid.text.trim(),
      "boss_id": "1",
      "platform": localData.storage.read("platform").toString(),
      "door_no": doorNo.text.trim(),
      "area": comArea.text.trim(),
      "city": city.text.trim(),
      "country": country.text.trim(),
      "state": state.toString(),
      "pincode": pinCode.text.trim(),
      "lat": lat,
      "lng": lng
    };
    final response =await empRepo.addEmployee(data,_profile,_profileList,_profileName,_aadharPhoto,_aadharPhotoList,_aadharPhotoName,
        _aadharPhoto2,_aadharPhotoList2,_aadharPhotoName2,
        _panPhoto,_panPhotoList,_panPhotoName,
        _chequePhoto,_chequePhotoList,_chequePhotoName,
        _licensePhoto,_licensePhotoList,_licensePhotoName,
        _voterPhoto,_voterPhotoList,_voterPhotoName);
    log(response.toString());
    if (response.toString().contains("already exists")){
      utils.showWarningToast(context,text: "Employee with this Phone Number already exits");
      signCtr.reset();
    }else if (response["status_code"]==200){
      // utils.showSuccessToast(context: context,text: "Signup completed successfully.",);
      // Future.microtask(() {
      //   utils.navigatePage(context,()=>const LoginPage());
      // });
      Provider.of<HomeProvider>(context, listen: false).loginPassword.text=signPassword.text.trim();
      Provider.of<HomeProvider>(context, listen: false).loginNumber.text=signMobileNumber.text.trim();
      Provider.of<HomeProvider>(context, listen: false).login(context);
      // signCtr.reset();
    }else if (response.toString().contains("Employee with this Phone Number already exits")){
      utils.showWarningToast(context,text: "Employee with this Phone Number already exits");
      signCtr.reset();
    }
    else {
      utils.showErrorToast(context: context);
      signCtr.reset();
    }
  } catch (e) {
    log(e.toString());
    utils.showErrorToast(context: context);
    signCtr.reset();
  }
  notifyListeners();
}
/// update Employee
Future<void> updatedEmployee(context,String userId,bool isDetailView) async {
  try {
    // print("mncxbm");
    Map<String, String> data = {
      "action": updateUsers,
      "log_file": localData.storage.read("mobile_number").toString(),
      "firstname": signFirstName.text.trim(),
      "mobile_number":signMobileNumber.text.trim(),
      "surname":signLastName.text.trim(),
      "role": localData.storage.read("roleId"),
      "updated_by": localData.storage.read("id"),
      "referred_by": signReffered.text.trim(),
      "email_id": signEmailid.text.trim(),
      "platform": localData.storage.read("platform").toString(),
      "grade_id": localData.storage.read("g_id")??"0",
      "user_id": userId,
      "door_no": doorNo.text.trim(),
      "street_name": streetName.text.trim(),
      "area": comArea.text.trim(),
      "city": city.text.trim(),
      "country": country.text.trim(),
      "state": state.toString(),
      "pincode": pinCode.text.trim(),
      "prefixes": signPrefix.toString(),
      "blood_group": blood.text.trim(),
      "m_name":signMiddleName.text.trim(),
      "whatsapp_number":signWhatsappNumber.text.trim(),
      "date_of_birth":signDob.text.trim(),
      "date_of_joining":signJoiningDate.text.trim(),
      "house_type":_houseType.toString(),
      "adhaar":signAadhar.text.trim(),
      "pan":signPan.text.trim(),
      "relation":relation.toString(),
      "prefixes_2":signSpousePrefix.toString(),
      "relation_name":signSpFirstname.text.trim(),
      "marital_status":maritalStatus.toString(),
      "emg_name":signEmFname.text.trim(),
      "emg_no":signEmPh.text.trim(),
      "emg_relation": signEmRelation.text.trim(),
      "last_org": signLastOrganization.text.toString(),
      "ref1_name": signReFname1.text.toString(),
      "ref1_no": signRePh1.text.trim(),
      "ref2_name": signReFname2.text.trim(),
      "ref2_no": signRePh2.text.trim(),
      "door_no_perm":permanentDoNo.text.trim(),
      "street_name_perm":permanentStreet.text.trim(),
      "area_perm":permanentArea.text.trim(),
      "city_perm":permanentCity.text.trim(),
      "state_perm":permanentState??"Tamil Nadu",
      "country_perm":permanentCountry.text.trim(),
      "pincode_perm":permanentPin.text.trim(),
      "salary":salary.text.trim(),
      "last_working_day":lastWorkingday.text.trim(),

      "img1":oldImage,
      "img2":oldImage2,
      "img3":oldImage3,
      "img4":oldImage4,
      "img5":oldImage5,
      "img6":oldImage6,
      "img7":oldImage7,
    };
    final response =await empRepo.addEmployee(data,_profile,_profileList,_profileName,_aadharPhoto,_aadharPhotoList,_aadharPhotoName,
    _aadharPhoto2,_aadharPhotoList2,_aadharPhotoName2,
    _panPhoto,_panPhotoList,_panPhotoName,
    _chequePhoto,_chequePhotoList,_chequePhotoName,
    _licensePhoto,_licensePhotoList,_licensePhotoName,
        _voterPhoto,_voterPhotoList,_voterPhotoName);
    log(data.toString());
    log(response.toString());
    if (response["status_code"]==200){
      utils.showSuccessToast(context: context,text: "User ${constValue.updated}",);
      signCtr.reset();

      if(userId==localData.storage.read("id")){
        utils.navigatePage(context, ()=>const LoginPage());
      }else if(isDetailView==true){
        utils.navigatePage(context, ()=> DashBoard(child: EmployeeDetails(id:userId,active:"1",role:localData.storage.read("roleName"))));
        getAllUsers();
        // Provider.of<HomeProvider>(context, listen: false).roleEmployees();
      }else{
        getAllUsers();
        // Provider.of<HomeProvider>(context, listen: false).roleEmployees();
        // Provider.of<HomeProvider>(context, listen: false).getMainReport(false);
        // Provider.of<HomeProvider>(context, listen: false).getDashboardReport(false);
        Future.microtask(() => Navigator.pop(context));
      }
    }else {
      utils.showErrorToast(context: context);
      signCtr.reset();
    }
  } catch (e) {
    log(e.toString());
    utils.showErrorToast(context: context);
    signCtr.reset();
  }
  notifyListeners();
}
/// update employee
Future<void> deletedEmployee(context,{required String userId}) async {
  try {
    Map<String, String> data = {
      "action":delete,
      "ops": "u",
      "user_id": userId,
      "deleted_reason":deleteReason.text.trim(),
      "updated_by": localData.storage.read("id"),
      "platform": localData.storage.read("platform").toString(),
    };
    final response =await empRepo.deleteEmployee(data);
    log(response.toString());
    if (response["status_code"]==200){
      utils.showSuccessToast(context: context,text: constValue.deleted,);
      getAllUsers(isRefresh: false);
      Navigator.pop(context);
      signCtr.reset();
    }else {
      utils.showErrorToast(context: context);
      signCtr.reset();
    }
  } catch (e) {
    log(e.toString());
    utils.showErrorToast(context: context);
    signCtr.reset();
  }
  notifyListeners();
}
Future<void> deletedGrade(context,{required String id}) async {
  try {
    Map<String, String> data = {
      "action":delete,
      "ops": "grade",
      "updated_by": localData.storage.read("id"),
      "id":id,
      "cos_id": localData.storage.read("cos_id"),
      "platform": localData.storage.read("platform").toString(),
    };
    final response =await empRepo.deleteEmployee(data);
    log(response.toString());
    if (response["status_code"]==200){
      utils.showSuccessToast(context: context,text: constValue.deleted,);
      getGrades(false);
      Navigator.pop(context);
      signCtr.reset();
    }else {
      utils.showErrorToast(context: context);
      signCtr.reset();
    }
  } catch (e) {
    log(e.toString());
    utils.showErrorToast(context: context);
    signCtr.reset();
  }
  notifyListeners();
}
Future<void> empActive(context,{required String userId,required String active}) async {
  try {
    Map<String, String> data = {
      "action": empActivity,
      "active": active,
      "user_id": userId,
      "reason":deleteReason.text.trim(),
      "created_by": localData.storage.read("id"),
      "platform": localData.storage.read("platform").toString(),
      "log_file": localData.storage.read("mobile_number").toString(),
    };
    final response =await empRepo.activityEmployee(data);
    log(response.toString());
    if (response["status_code"]==200){
      utils.showSuccessToast(context: context,text: active=="1"?"Activated successfully":"Inactivated successfully.",);
      getAllUsers(isRefresh: false);
      // Provider.of<HomeProvider>(context, listen: false).roleEmployees();
      Provider.of<HomeProvider>(context, listen: false).getMainReport(false);
      Provider.of<HomeProvider>(context, listen: false).getDashboardReport(false);
      Navigator.pop(context);
      signCtr.reset();
    }else {
      utils.showErrorToast(context: context);
      signCtr.reset();
    }
  } catch (e) {
    log(e.toString());
    utils.showErrorToast(context: context);
    signCtr.reset();
  }
  notifyListeners();
}
Future<void> addEmpGrade(context) async {
  try {
    Map<String, String> data = {
      "action": addGrade,
      "grade":gradeCtr.text.trim(),
      "created_by": localData.storage.read("id"),
      "platform": localData.storage.read("platform").toString(),
      "cos_id": localData.storage.read("cos_id").toString(),
      "log_file": localData.storage.read("mobile_number").toString(),
    };
    final response =await empRepo.activityEmployee(data);
    // print(data.toString());
    // print(response.toString());
    if (response.toString().contains("This grade already exits")){
      utils.showWarningToast(context,text: "This grade already exits");
      signCtr.reset();
    }else if (response["status_code"]==200){
      utils.showSuccessToast(context: context,text: constValue.success);
      getGrades(true);
      Navigator.pop(context);
      signCtr.reset();
    }else {
      utils.showErrorToast(context: context);
      signCtr.reset();
    }
  } catch (e) {
    log(e.toString());
    utils.showErrorToast(context: context);
    signCtr.reset();
  }
  notifyListeners();
}

bool _update = false;
bool get update =>_update;
bool _empRefresh = true;
bool _refresh = true;
bool _sortBy = false;
bool _sortByN = true;
int _active = 0;
int _inActive = 0;
bool get refresh =>_refresh;
bool get empRefresh =>_empRefresh;
bool get sortBy =>_sortBy;
bool get sortByN =>_sortByN;
int get active =>_active;
int get inActive =>_inActive;
void changeSort(){
  _sortBy=!_sortBy;
  _sortByN=!_sortByN;
  notifyListeners();
}
List<UserModel> _userData=[];
List<UserModel> _filterUserData=[];
List _userLogData=[];
List _notifyData=[];
List get notifyData => _notifyData;
List<UserModel> _searchUserData=[];
List<UserModel> assignEmployees=[];
List<UserModel> get userData => _userData;
List<UserModel> get filterUserData => _filterUserData;
List<UserModel> activeEmps=[];

void filterEmps(){
    assignEmployees.clear();
    activeEmps.clear();
    for (var i=0;i<_filterUserData.length;i++){
      if(_filterUserData[i].role!="1"&&_filterUserData[i].active=="1"){
        assignEmployees.add(_filterUserData[i]);
      }
      if(_filterUserData[i].active=="1"){
        activeEmps.add(_filterUserData[i]);
      }
    }
    assignEmployees.sort((a, b) =>a.firstname!.compareTo(b.firstname.toString()));
    activeEmps.sort((a, b) =>a.firstname!.compareTo(b.firstname.toString()));
    print("activeEmps ${activeEmps.length}");
    print("_filterUserData ${_filterUserData.length}");
  }
List get userLogData => _userLogData;
// void filters(){
//   // final empProviderDate1 = date1.text; // Start Date
//   // final empProviderDate2 = date2.text; // End Date
//   // final dateFormat = DateFormat('dd-MM-yyyy');
//
//   DateTime  createdTsDate = DateTime.parse(employeeData.createdTs.toString());
//   final parsedDate1 = dateFormat.tryParse(empProviderDate1);
//   final parsedDate2 = dateFormat.tryParse(empProviderDate2);
//   bool isWithinDateRange =
//       createdTsDate.isAfter(parsedDate1!.subtract(const Duration(days: 1))) &&
//           createdTsDate.isBefore(parsedDate2!.add(const Duration(days: 1)));
//   _filterUserData = _filterUserData.where((contact) {
//     DateTime contactDate = DateFormat('yyyy-MM-dd').parse(
//         contact.updatedTs.toString().split(' ')[0]);
//     return contactDate.isAfter(startDate) && contactDate.isBefore(currentDate);
//   });
// }
Future<void> getAllUsers({bool? isRefresh=true}) async {
  if(isRefresh==true){
    _empRefresh=false;
    _userData.clear();
    _searchUserData.clear();
    _filterUserData.clear();
  }
  search.clear();
  _sortBy=false;
  _sortByN=true;
  notifyListeners();
  try {
    Map data = {
      "action": getAllData,
      "search_type": "allusers",
      "cos_id":localData.storage.read("cos_id"),
      "role":localData.storage.read("role"),
    };
    final response =await empRepo.getUsers(data);
    // print("response.toString()");
    // print(response.toString());
    if (response.isNotEmpty) {
      _userData=response;
      _searchUserData=response;
      _filterUserData=response;
      _active=0;
      _inActive=0;
      for (var user in _filterUserData) {
        user.active == "1" ? _active++ : _inActive++;
      }
      filterEmps();
      _empRefresh=true;
    } else {
      _empRefresh=true;
    }
  } catch (e) {
    _empRefresh=true;
    log(e.toString());
  }
  notifyListeners();
}
Future<void> getUserLogs(String id) async {
  _refresh=false;
  _userLogData.clear();
  notifyListeners();
  try {
    Map data = {
      "action": getAllData,
      "search_type": "user_log",
      "cos_id":localData.storage.read("cos_id"),
      "id":id,
    };
    final response =await empRepo.getUserLogs(data);
    if (response.isNotEmpty) {
      _userLogData=response;
      _refresh=true;
    } else {
      _userLogData=[];
      _refresh=true;
    }
  } catch (e) {
    _userLogData=[];
    _refresh=true;
    log(e.toString());
  }
  notifyListeners();
}
  int unreadCount = 0;
  Future<void> calculateUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastSeen = prefs.getString("last_notification_seen");

    debugPrint("LAST SEEN => $lastSeen");

    if (lastSeen == null) {
      unreadCount = notifyData.length;
      debugPrint("FIRST TIME → $unreadCount");
      return;
    }

    final lastSeenTime = DateTime.parse(lastSeen);

    unreadCount = notifyData.where((n) {
      final created = DateTime.parse(
        n["created_ts"].toString().replaceFirst(' ', 'T'),
      );

      debugPrint("CREATED => $created | AFTER? ${created.isAfter(lastSeenTime)}");

      return created.isAfter(lastSeenTime);
    }).length;

    debugPrint("FINAL UNREAD => $unreadCount");
  }



  Future<void> markNotificationsAsSeen() async {
    if (notifyData.isEmpty) return;

    final latest = notifyData
        .map((n) => DateTime.parse(
      n["created_ts"].toString().replaceFirst(' ', 'T'),
    ))
        .reduce((a, b) => a.isAfter(b) ? a : b);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      "last_notification_seen",
      latest.toIso8601String(),
    );

    debugPrint("✅ MARKED SEEN AT => $latest");

    unreadCount = 0;
    notifyListeners();
  }
  String _userName="";
  String get userName=>_userName;
  void selectUser(UserModel value){
    _userName=value.firstname.toString();
    searchName=_userName;
    notifyListeners();
  }
  String searchName = "";
  DateTime? selectedDate;
  // List<dynamic> get filteredNotifyData {
  //   return _notifyData.where((item) {
  //     final createdBy = item["firstname"]?.toString().toLowerCase() ?? "";
  //     final createdTs = DateTime.parse(item["created_ts"]);
  //
  //     /// Name filter
  //     final matchName = searchName.isEmpty ||
  //         createdBy.contains(searchName.toLowerCase());
  //
  //     /// Date filter
  //     final matchDate = selectedDate == null ||
  //         (createdTs.year == selectedDate!.year &&
  //             createdTs.month == selectedDate!.month &&
  //             createdTs.day == selectedDate!.day);
  //
  //     return matchName && matchDate;
  //   }).toList();
  // }
  List<dynamic> get filteredNotifyData {
    return notifyData.where((item) {
      final createdTs = DateTime.parse(item["created_ts"]);
      final createdBy = item["firstname"]?.toString().toLowerCase() ?? "";

      /// name filter
      final matchName = searchName.isEmpty ||
          createdBy.contains(searchName.toLowerCase());

      /// start & end date parse
      DateTime? start = startDate != ""
          ? DateFormat("dd-MM-yyyy").parse(startDate)
          : null;

      DateTime? end = endDate != ""
          ? DateFormat("dd-MM-yyyy").parse(endDate)
          : null;

      if (end != null) {
        end = DateTime(end.year, end.month, end.day, 23, 59, 59);
      }

      /// date range filter
      final matchDate =
          (start == null || !createdTs.isBefore(start)) &&
              (end == null || !createdTs.isAfter(end));

      return matchName || matchDate; // 👈 rendu filter combine
    }).toList();
  }
Future<void> getNotifications({bool markSeen = false}) async {
  _refresh=false;
  filteredNotifyData.clear();
  _notifyData.clear();
  notifyListeners();
  try {
    Map data = {
      "action": getAllData,
      "search_type": "notifications",
      "cos_id":localData.storage.read("cos_id"),
      "id":localData.storage.read("id"),
    };
    final response =await empRepo.getUserLogs(data);
    if (response.isNotEmpty) {
      _notifyData=response;
      notifyListeners();
      await calculateUnreadCount();
      if (markSeen) {
        await markNotificationsAsSeen();
      }
      _refresh=true;
    } else {
      _notifyData=[];
      _refresh=true;
    }
  } catch (e) {
    _notifyData=[];
    _refresh=true;
    log(e.toString());
  }
  notifyListeners();
}
  Future<void> sendRoleNotification(String msgTittle,String msgBody,String role) async {
    Map data = {
      "action":roleNotification,
      "msgTittle":msgTittle,
      "msgBody":msgBody,
      "role":role,
      "send_by":localData.storage.read("id")??"0",
      "type":"1",
      "platform": localData.storage.read("platform"),
      "cos_id": localData.storage.read("cos_id")
    };
    final response = await empRepo.notification(data);
    print(response);
    if(response.isNotEmpty){
      // utils.showSuccessToast(context: context,text: "Account deleted successfully",);
      // LocalDatabase.deleteDb();
      // utils.navigatePage(context,()=>const LoginPage());
      // loginCtr.reset();
    }else{
      // utils.showErrorToast(context: context);
      // loginCtr.reset();
    }
    notifyListeners();
  }
  Future<void> sendSomeUserNotification(String msgTittle,String msgBody,String id,String purposeId) async {
    try {
      Map data = {
        "action": someUserNotification,
        "msgTittle": msgTittle,
        "msgBody": msgBody,
        "send_by": localData.storage.read("id"),
        "id": id,
        "platform": localData.storage.read("platform").toString(),
        "purpose_id": purposeId
      };
      final response = await empRepo.notification(data);
      if (response.isNotEmpty) {
        // utils.showSuccessToast(context: context,text: "Account deleted successfully",);
        // LocalDatabase.deleteDb();
        // utils.navigatePage(context,()=>const LoginPage());
        // loginCtr.reset();
      } else {
        // utils.showErrorToast(context: context);
        // loginCtr.reset();
      }
    }catch(e){
      // utils.showErrorToast(context: context);
      // loginCtr.reset();
    }
    notifyListeners();
  }
  Future<void> sendUserNotification(String msgTittle,String msgBody,String id) async {
    try {
      Map data = {
        "action": userNotification,
        "msgTittle": msgTittle,
        "msgBody": msgBody,
        "send_by": localData.storage.read("id"),
        "id": id,
        "platform": localData.storage.read("platform").toString(),
      };
      final response = await empRepo.notification(data);
      if (response.isNotEmpty) {
        // utils.showSuccessToast(context: context,text: "Account deleted successfully",);
        // LocalDatabase.deleteDb();
        // utils.navigatePage(context,()=>const LoginPage());
        // loginCtr.reset();
      } else {
        // utils.showErrorToast(context: context);
        // loginCtr.reset();
      }
    }catch(e){
      // utils.showErrorToast(context: context);
      // loginCtr.reset();
    }
    notifyListeners();
  }
  Future<void> sendAdminNotification(String msgTittle,String msgBody,String role,String purposeId) async {
    Map data = {
      "action":adminNotification,
      "msgTittle":msgTittle,
      "msgBody":msgBody,
      "role":role,
      "send_by":localData.storage.read("id")??"0",
      "id":localData.storage.read("id"),
      "type":"1",
      "platform": localData.storage.read("platform"),
      "cos_id": localData.storage.read("cos_id"),
      "purpose_id": purposeId
    };
    final response = await empRepo.notification(data);
    print(response);
    if(response.isNotEmpty){
      // utils.showSuccessToast(context: context,text: "Account deleted successfully",);
      // LocalDatabase.deleteDb();
      // utils.navigatePage(context,()=>const LoginPage());
      // loginCtr.reset();
    }else{
      // utils.showErrorToast(context: context);
      // loginCtr.reset();
    }
    notifyListeners();
  }

String addressId="";
String oldImage="";
String oldImage2="";
String oldImage3="";
String oldImage4="";
String oldImage5="";
String oldImage6="";
String oldImage7="";
String gradeName="";
Future<void> getUserDetails({required String id}) async {
  _swipeIndex=0;
  _refresh=false;
  addressId="";
  gradeName="";
  _grade=null;
  _profile="";
  _aadharPhoto="";
  _aadharPhoto2="";
  _panPhoto="";
  _chequePhoto="";
  _licensePhoto="";
  _voterPhoto="";
  oldImage="";
  oldImage2="";
  oldImage3="";
  oldImage4="";
  oldImage5="";
  oldImage6="";
  oldImage7="";
  notifyListeners();
  // try {
    Map data = {
      "action": getAllData,
      "search_type": "employee_details",
      "cos_id":localData.storage.read("cos_id"),
      "id":id,
    };
    final response =await empRepo.getUserDetails(data);
    log(response.toString());
    if (response.isNotEmpty) {
      _update = false;
      UserDetail data=response[0];
      _role = _roleValues.firstWhere(
            (item) =>
        item["id"] == data.role.toString(),
        // orElse: () => {"id": "", "role": ""}, // Provide a valid default map
      );
      localData.storage.write("roleId", data.role.toString());
      localData.storage.write("roleName", data.roleName.toString());

      gradeName=data.grade.toString();
      signFirstName.text=data.firstname.toString();
      signLastName.text=data.surname.toString()=="null"?"":data.surname.toString();
      signMiddleName.text=data.middleName.toString()=="null"?"":data.middleName.toString();
      signMobileNumber.text=data.mobileNumber.toString();
      signWhatsappNumber.text=data.whatsappNumber.toString()=="null"?"":data.whatsappNumber.toString();
      if(signMobileNumber.text==signWhatsappNumber.text){
        _isWhatsApp=true;
      }
      signDob.text=data.dateOfBirth.toString()=="null"?"":data.dateOfBirth.toString();
      signJoiningDate.text=data.dateOfJoining.toString()=="null"?"":data.dateOfJoining.toString();
      blood.text=data.blood.toString()=="null"?"":data.blood.toString();
      salary.text=data.salary.toString()=="null"?"":data.salary.toString();
      signEmailid.text=data.emailId.toString()=="null"?"":data.emailId.toString();
      signReffered.text=data.referredBy.toString()=="null"?"":data.referredBy.toString();
      doorNo.text=data.addressLine1.toString()=="null"?"":data.addressLine1.toString();
      streetName.text=data.addressLine2.toString()=="null"?"":data.addressLine2.toString();
      comArea.text=data.presentArea.toString()=="null"?"":data.presentArea.toString();
      city.text=data.city.toString()=="null"?"":data.city.toString();
      country.text=data.country.toString()=="null"?"India":data.country.toString();
      pinCode.text=data.pincode.toString()=="null"?"":data.pincode.toString();

      signAadhar.text=data.adhaar.toString()=="null"?"":data.adhaar.toString();
      signPan.text=data.pan.toString()=="null"?"":data.pan.toString();
      signSpFirstname.text=data.relationName.toString()=="null"?"":data.relationName.toString();
      print("data.houseType : ${data.houseType}");
      _signPrefix = prefix.firstWhere(
            (item) =>
        item == data.prefixes.toString(),
        orElse: () => "Mr",
      );_signSpousePrefix = prefix.firstWhere(
            (item) =>
        item == data.prefixes_2.toString(),
        orElse: () => "Mr",
      );
      print(" data.houseType.toString() ${ data.houseType.toString()}");
      _houseType = houseTypeList.firstWhere(
            (item) =>
        item == data.houseType.toString(),
        orElse: () => null,
      );
      print("_houseType ${_houseType}");
      _maritalStatus = maritalList.firstWhere(
            (item) =>
        item == data.maritalStatus.toString(),
        orElse: () => null,
      );_relation = relationList.firstWhere(
            (item) =>
        item == data.relation.toString(),
        orElse: () => null,
      );

      state=data.state.toString()=="null"||data.state.toString()==""&&data.state==null?null:data.state.toString();
      _profile="";
      oldImage=data.image.toString();
      oldImage2=data.aadharUrl.toString();
      oldImage3=data.aadharBack.toString();
      oldImage4=data.panUrl.toString();
      oldImage5=data.chequeUrl.toString();
      oldImage6=data.licenseUrl.toString();
      oldImage7=data.voterUrl.toString();
      addressId=data.addressId.toString();
      _lastCheck=data.lastCheckin.toString();
      _commentCount=data.commentCount.toString();
      print("data.gradeId.toString() : ${data.gradeId.toString()}");
      if(data.gradeId.toString()!="null"&&data.gradeId.toString()!=""){
        for(var i=0;i<_gradeValues.length;i++){
          if(_gradeValues[i]["id"] == data.gradeId.toString()){
            _grade=_gradeValues[i];
            break;
          }
        }
        // _grade = _gradeValues.firstWhere(
        //       (item) => item["id"] == data.gradeId.toString(),
        //   orElse: () => <String, dynamic>{},
        // );
      }else{
        _grade=null;
      }

      localData.storage.write("g_id", data.gradeId.toString());


      permanentDoNo.text=data.permanentAddressLine1.toString()=="null"?"":data.permanentAddressLine1.toString();
      permanentStreet.text=data.permanentAddressLine2.toString()=="null"?"":data.permanentAddressLine2.toString();
      permanentArea.text=data.permanentArea.toString()=="null"?"":data.permanentArea.toString();
      permanentCity.text=data.permanentCity.toString()=="null"?"":data.permanentCity.toString();
      permanentCountry.text=data.permanentCountry.toString()=="null"?"India":data.permanentCountry.toString();
      permanentPin.text=data.permanentPincode.toString()=="null"?"":data.permanentPincode.toString();
      _permanentState=data.permanentState.toString()=="null"||data.permanentState.toString()==""&&data.permanentState==null?null:data.permanentState.toString();

      signEmFname.text=data.emgName.toString()=="null"?"":data.emgName.toString();
      signEmPh.text=data.emgNo.toString()=="null"?"":data.emgNo.toString();
      signEmRelation.text=data.emgRelation.toString()=="null"?"":data.emgRelation.toString();

      signLastOrganization.text=data.lastOrganization.toString()=="null"?"":data.lastOrganization.toString();
      lastWorkingday.text=data.lastWorkingDay.toString()=="null"?"":data.lastWorkingDay.toString();

      signReFname1.text=data.ref1Name.toString()=="null"?"":data.ref1Name.toString();
      signReFname2.text=data.ref2Name.toString()=="null"?"":data.ref2Name.toString();
      signRePh1.text=data.ref1No.toString()=="null"?"":data.ref1No.toString();
      signRePh2.text=data.ref2No.toString()=="null"?"":data.ref2No.toString();

      _refresh=true;
    } else {
      _refresh=true;
    }
  // } catch (e) {
  //   _refresh=true;
  //   log(e.toString());
  // }
  notifyListeners();
}
void searchUser(String value){
  if(_filter==false){
    final suggestions=_searchUserData.where(
            (user){
          final userFName=user.firstname.toString().toLowerCase();
          final userNumber = user.mobileNumber.toString().toLowerCase();
          final input=value.toString().toLowerCase();
          return userFName.contains(input) || userNumber.contains(input);
        }).toList();
    _filterUserData=suggestions;
  }else{
    final suggestions=_filterUserData.where(
            (user){
          final userFName=user.firstname.toString().toLowerCase();
          final userNumber = user.mobileNumber.toString().toLowerCase();
          final input=value.toString().toLowerCase();
          return userFName.contains(input) || userNumber.contains(input);
        }).toList();
    _filterUserData=suggestions;
    if(value.isEmpty){
      filterList();
    }
  }
  // _userData=suggestions;
  _active=0;
  _inActive=0;
  for (var user in _filterUserData) {
    user.active == "1" ? _active++ : _inActive++;
  }
  notifyListeners();
}
}