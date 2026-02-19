import 'dart:async';
import 'dart:developer';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:master_code/model/user_model.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_code/component/custom_text.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../model/customer/customer_attendance_model.dart';
import '../model/project/project_model.dart';
import '../repo/project_repo.dart';
import '../screens/common/camera.dart';
import '../source/constant/api.dart';
import '../source/constant/colors_constant.dart';
import '../source/constant/default_constant.dart';
import '../source/constant/local_data.dart';
import '../source/utilities/utils.dart';


class ProjectProvider with ChangeNotifier{
final ProjectRepository prjRepo = ProjectRepository();
late TabController tabController;
late GoogleMapController googleMapController;
final List<Marker> _marker =[];
List<Marker> get marker =>_marker;
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
      presentStreet.text=place.street.toString();
      presentArea.text="${place.subLocality.toString()}${place.thoroughfare.toString()==""?"":",${place.thoroughfare}"==""?"":place.thoroughfare.toString()}";
      presentCity.text=place.locality.toString();
      presentCountry.text=place.country.toString();
      presentPin.text=place.postalCode.toString();
      _state=place.administrativeArea.toString();
    }catch(e){
      // utils.showWarningToast(context, text: "Search valid name", color: colorsConst.primary);
    }
  }
  notifyListeners();
}

void updateIndex(int index){
  tabController.index=index;
  notifyListeners();
}
void datePick({required BuildContext context,required TextEditingController textEditingController}){
  print("Date : ${textEditingController.text}");
  final parsedDate = DateFormat('dd-MM-yyyy').parse(textEditingController.text);
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
      textEditingController.text= ("${(value.day.toString().padLeft(2,"0"))}-"
          "${(value.month.toString().padLeft(2,"0"))}-"
          "${(value.year.toString())}");
      if(_selectProject!=null){
        changeProject(_selectProject);
      }
    }

    notifyListeners();
  });
}

List<CustomerAttendanceModel> _customerAttendanceReport = <CustomerAttendanceModel>[];
List<CustomerAttendanceModel> get customerAttendanceReport=>_customerAttendanceReport;
Future<void> getAttendance(String id) async {
  _refresh=false;
  _customerAttendanceReport.clear();
  notifyListeners();
  try {
    Map data = {
      "action": getProjectData,
      "search_type":"project_visits",
      "prj_id":id,
      "id":localData.storage.read("id"),
      "cos_id":localData.storage.read("cos_id"),
      "role":localData.storage.read("role"),
    };
    final response =await prjRepo.getAttendances(data);
    print(data.toString());
    print(response.toString());
    if (response.isNotEmpty) {
      _customerAttendanceReport=response;
      _refresh=true;
    } else {
      _refresh=true;
    }
  } catch (e) {
    _refresh=true;
  }
  notifyListeners();
}

bool _refresh=false;
bool _attRefresh=false;
bool _isSort=false;
dynamic _state;
bool get refresh => _refresh;
bool get attRefresh => _attRefresh;
bool get isSort => _isSort;
dynamic get state => _state;
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

void sortBy(dynamic value){
  _isSort = value;
  notifyListeners();
}

void changeState(dynamic value){
  _state= value;
  notifyListeners();
}

void initValues(){
  projectName.clear();
  presentDoNo.clear();
  presentStreet.clear();
  presentArea.clear();
  presentCity.clear();
  presentPin.clear();
  betweenMtr.clear();
  _state=null;
  presentCountry.text="India";
  date1.text="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
  date2.text="${(DateTime.now().add(const Duration(days: 1))).day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
  notifyListeners();
}
void setValue(ProjectModel data){
  projectName.text=data.name.toString();
  presentDoNo.text=data.addressLine1.toString();
  presentStreet.text=data.addressLine2.toString();
  presentArea.text=data.area.toString();
  presentCity.text=data.city.toString();
  presentPin.text=data.pincode.toString();
  presentCountry.text=data.country.toString();
  betweenMtr.text=data.betweenMtr.toString()=="null"?"":data.betweenMtr.toString();
  _state=data.state.toString()=="null"?null:data.state;
  date1.text=data.startDate.toString();
  date2.text=data.endDate.toString();
  notifyListeners();
}
Future<void> getAdd(double lat,double lng) async {
  List<Placemark> placeMark=await placemarkFromCoordinates(lat,lng);
  Placemark place = placeMark[0];
  presentDoNo.text=place.street.toString();
  presentStreet.text=place.subLocality.toString();
  presentArea.text=place.thoroughfare.toString()==""?"":",${place.thoroughfare}"==""?"":place.thoroughfare.toString();
  presentCity.text=place.locality.toString();
  presentCountry.text=place.country.toString();
  presentPin.text=place.postalCode.toString();
  _state=place.administrativeArea.toString();
  notifyListeners();
}
double latitude=0.0;
double longitude=0.0;

Future<void> checkProjectAddress(context,{bool? isUpdate = false,String? id}) async {
  try{
    List<Location> presentLocations = await locationFromAddress
      ("${presentDoNo.text.trim()},${presentStreet.text.trim()},${presentArea.text.trim()},${presentCity.text.trim()}");
    latitude=presentLocations[0].latitude;
    longitude=presentLocations[0].longitude;
    if(latitude==0.0||longitude==0.0){
      utils.showWarningToast(context,text: "Please  Check Your Address");
      addCtr.reset();
    }else{
      if(isUpdate==false){
        insertProject(context);
      }else{
        updateProject(context,id!);
      }
    }
  }catch(e){
    utils.showWarningToast(context,text: "Please  Check Your Address");
    addCtr.reset();
  }
}

TextEditingController searchController = TextEditingController();
TextEditingController date1 = TextEditingController();
TextEditingController date2 = TextEditingController();
TextEditingController projectName = TextEditingController();
TextEditingController presentDoNo = TextEditingController();
TextEditingController presentStreet = TextEditingController();
TextEditingController presentArea = TextEditingController();
TextEditingController presentCity = TextEditingController();
TextEditingController presentPin = TextEditingController();
TextEditingController presentCountry = TextEditingController(text: "India");
TextEditingController betweenMtr = TextEditingController();
TextEditingController search = TextEditingController();
final RoundedLoadingButtonController addCtr =RoundedLoadingButtonController();
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  double distanceInKm = distanceInMeters / 1000; // Convert to km

  log("Distance: ${distanceInKm.toStringAsFixed(2)} km (${distanceInMeters.toStringAsFixed(2)} meters)");
  return distanceInMeters;
}
List<ProjectModel> _projectData = <ProjectModel>[];
List<ProjectModel> get projectData => _projectData;

List<ProjectModel> _searchProjectData = <ProjectModel>[];
List<ProjectModel> get searchProjectData => _searchProjectData;
bool _distanceBlock=false;
bool get distanceBlock=>_distanceBlock;
void checkDistance(){
  _distanceBlock=true;
  notifyListeners();
}

String _profile="";
String get profile=>_profile;
Future<void> signDialog({required BuildContext context, required String img,required Function(String newImg) onTap}) async {
  _profile="";
  var imgData = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const CameraWidget(
            cameraPosition: CameraType.front,
            isSelfie: true,
          )));
  if (!context.mounted) return;
  // Navigator.pop(context);
  if (imgData != null) {
    onTap(imgData);
  }
}

Future<void> projectAttendance(context,
    {required String status, required String lat, required String lng, required String taskId}) async {
  try {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            actions: [
              Center(
                child: SizedBox(
                  // color: Colors.yellow,
                  width: kIsWeb?MediaQuery.of(context).size.width*0.3:MediaQuery.of(context).size.width*0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Center(child: CustomText(text: "\n\nProcessing\n",colors: colorsConst.greyClr)),
                        Center(child: CustomText(text: "Please Wait...\n",colors: colorsConst.greyClr)),20.height,
                        Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: colorsConst.primary,
                            size: 20,
                          ),
                        ),
                        20.height
                      ],
                  ),
                ),
              ),
            ],
          );
        }
    );
    Map<String, String> data = {
      "action": projectAtt,
      "log_file": localData.storage.read("mobile_number"),
      "line_id": "0",
      "line_customer_id": taskId,
      "salesman_id": localData.storage.read("id"),
      "self_img_count": "0",
      "comp_img_count": "0",
      "collection_amt": "0",
      "sales_amt": "0",
      "is_checked_out": status,
      "lat": lat,
      "lng": lng,
      "traveled_kms": "0.0",
      "id": localData.storage.read("tk_id").toString(),
      "cos_id": localData.storage.read("cos_id"),

    };
    final response =await prjRepo.addAttendance(data,_profile);
    print(response.toString());
    if (response.isNotEmpty){
      localData.storage.write("tk_id", response[0]["id"]);
      utils.showSuccessToast(text: status=="1"?"Check In Successful":"Check Out Successful",context: context);
      _distanceBlock=false;
      Navigator.pop(context);
      getAllProject(false);
    }else {
      _distanceBlock=false;
      Navigator.pop(context);
      utils.showErrorToast(context: context);
      notifyListeners();
    }
  } catch (e) {
    _distanceBlock=false;
    Navigator.pop(context);
    log(e.toString());
    utils.showErrorToast(context: context);
  }
}

void profilePick(String imgData){
  _profile = imgData;
  notifyListeners();
}
Future<void> getAllProject(bool isRefresh) async {
  if(isRefresh==true){
    _selectProject=null;
    _refresh=false;
    _distanceBlock=false;
    _projectData.clear();
    _searchProjectData.clear();
    notifyListeners();
  }
  try {
    Map data = {
      "action":getProjectData,
      "search_type":"all_projects",
      "cos_id":localData.storage.read("cos_id"),
      "role":localData.storage.read("role"),
      "id":localData.storage.read("id"),
    };
    final response =await prjRepo.getProjectDetails(data);
    log(response.toString());
    if (response.isNotEmpty) {
      _projectData.clear();
      _searchProjectData.clear();
      _searchProjectData=response;
      _projectData=response;
      _refresh=true;
    } else {
      _refresh=true;
      _projectData.clear();
      _searchProjectData.clear();
    }
  } catch (e) {
    _refresh=true;
    _projectData.clear();
    _searchProjectData.clear();
    log(e.toString());
  }
  notifyListeners();
}

Future<void> insertProject(context) async {
  try {
  Map<String, String> data = {
    "action":addProject,
    "company_name":projectName.text.trim(),
    "start_date":date1.text.trim(),
    "end_date":date2.text.trim(),
    "address_line1":presentDoNo.text.trim(),
    "address_line2":presentStreet.text.trim(),
    "area":presentArea.text.trim(),
    "city":presentCity.text.trim(),
    "pincode":presentPin.text.trim(),
    "country":presentCountry.text.trim(),
    "metre":betweenMtr.text.trim(),
    "state":state.toString(),
    "lat":latitude.toString(),
    "lng":longitude.toString(),
    "created_by":localData.storage.read("id"),
    "log_file":localData.storage.read("mobile_number"),
    "platform":localData.storage.read("platform").toString(),
    "cos_id": localData.storage.read("cos_id"),
    "fea_type": "2"
  };
  final response =await prjRepo.insert(data);
  // print(response.toString());
  if (response["status_code"]==200){
    utils.showSuccessToast(context: context,text: "${constValue.project} ${constValue.success}",);
    getAllProject(true);
    Future.microtask(() => Navigator.pop(context));
    addCtr.reset();
  }else {
    utils.showErrorToast(context: context);
    addCtr.reset();
  }
  } catch (e) {
    // log(e.toString());
    utils.showErrorToast(context: context);
    addCtr.reset();
  }
  notifyListeners();
}
Future<void> updateProject(context,String id) async {
  try {
  Map<String, String> data = {
    "action":editProject,
    "id":id,
    "company_name":projectName.text.trim(),
    "start_date":date1.text.trim(),
    "end_date":date2.text.trim(),
    "address_line1":presentDoNo.text.trim(),
    "address_line2":presentStreet.text.trim(),
    "area":presentArea.text.trim(),
    "city":presentCity.text.trim(),
    "pincode":presentPin.text.trim(),
    "country":presentCountry.text.trim(),
    "metre":betweenMtr.text.trim(),
    "state":state.toString(),
    "lat":latitude.toString(),
    "lng":longitude.toString(),
    "updated_by":localData.storage.read("id"),
    "log_file":localData.storage.read("mobile_number"),
    "platform":localData.storage.read("platform").toString(),
    "cos_id":localData.storage.read("cos_id")
  };
  final response =await prjRepo.insert(data);
  print(response.toString());
  if (response["status_code"]==200){
    utils.showSuccessToast(context: context,text: "${constValue.project} ${constValue.updated}",);
    getAllProject(true);
    Future.microtask(() => Navigator.pop(context));
    addCtr.reset();
  }else {
    utils.showErrorToast(context: context);
    addCtr.reset();
  }
  } catch (e) {
    // log(e.toString());
    utils.showErrorToast(context: context);
    addCtr.reset();
  }
  notifyListeners();
}

Future<void> deleteProject(context,String id) async {
  try {
  Map<String, String> data = {
    "action":removeProject,
    "id":id,
    "updated_by":localData.storage.read("id"),
    "log_file":localData.storage.read("mobile_number"),
    "cos_id":localData.storage.read("cos_id"),
    "up_platform":localData.storage.read("platform").toString()

  };
  final response =await prjRepo.insert(data);
  print(response.toString());
  if (response["status_code"]==200){
    utils.showSuccessToast(context: context,text: "${constValue.project} ${constValue.deleted}",);
    getAllProject(false);
    Future.microtask(() => Navigator.pop(context));
    addCtr.reset();
  }else {
    utils.showErrorToast(context: context);
    addCtr.reset();
  }
  } catch (e) {
    // log(e.toString());
    utils.showErrorToast(context: context);
    addCtr.reset();
  }
  notifyListeners();
}

void searchProject(String value){
  final suggestions=_projectData.where(
          (user){
        final name=user.name.toString().toLowerCase();
        final city = user.city.toString().toLowerCase();
        final input=value.toString().toLowerCase();
        return name.contains(input) || city.contains(input);
      }).toList();
  _searchProjectData=suggestions;
  notifyListeners();
}
void searchProjectUsers(String value){
  final suggestions=_prjUserEdit.where(
          (user){
        final userFName = user["f_name"].toString().toLowerCase();
        final userNumber = user["mobile_number"].toString().toLowerCase();
        final input = value.toString().toLowerCase().trim();
        return userFName.contains(input) || userNumber.contains(input);
      }).toList();
  _searchPrjUserEdit=suggestions;
  notifyListeners();
}
List _prjGroupAttendanceList= [];
List get prjGroupAttendanceList => _prjGroupAttendanceList;
List _prjUserEdit= [];
List _searchPrjUserEdit= [];
List get searchPrjUserEdit => _searchPrjUserEdit;
List get prjUserEdit => _prjUserEdit;
List<CustomerAttendanceModel> _projectReport = <CustomerAttendanceModel>[];
List<CustomerAttendanceModel> get projectReport => _projectReport;

final RoundedLoadingButtonController projectCtr =RoundedLoadingButtonController();
dynamic _selectProject;
dynamic get selectProject => _selectProject;
void changeProject(dynamic value){
  _attRefresh=false;
  var list = [];
  list.add(value);
  _selectProject = value;
  _prjGroupAttendanceList.clear();
  localData.storage.write("g_prj_id", list[0].id);
  getProjectDailyAtt(localData.storage.read("g_prj_id"));
}
Future<void> getAllUsers() async {
  _attRefresh=false;
  _prjUserEdit.clear();
  _searchPrjUserEdit.clear();
  search.clear();
  date1.text="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
  notifyListeners();
  try {
    Map data = {
      "action": getAllData,
      "search_type": "allusers",
      "cos_id":localData.storage.read("cos_id"),
      "role":localData.storage.read("role"),
    };
    final response =await prjRepo.getUsers(data);
    // log(response.toString());
    if (response.isNotEmpty) {
      Map<String, dynamic> createEntry(UserModel data) {
        return {
          "user_id": data.id,
          "f_name": data.firstname,
          "mobile_number": data.mobileNumber,
          "role": data.roleName,
          "check_in": false,
          "check_out": false,
          "in": "",
          "out": "",
          "att_id": "",
        };
      }
      for(var i=0;i<response.length;i++){
        var userEntry = createEntry(response[i]);
        _searchPrjUserEdit.add(userEntry);
        _searchPrjUserEdit.sort((a, b) => a["f_name"].compareTo(b["f_name"]));
        _prjUserEdit.add(userEntry);
        _prjUserEdit.sort((a, b) => a["f_name"].compareTo(b["f_name"]));
      }
      _attRefresh=true;
    } else {
      _attRefresh=true;
    }
  } catch (e) {
    _attRefresh=true;
    log(e.toString());
  }
  notifyListeners();
}
Future getProjectDailyAtt(String projectId) async {
  _attRefresh=false;
  _projectReport=[];
  notifyListeners();
  try {
    Map data = {
      "action":getProjectData,
      "cos_id":localData.storage.read("cos_id"),
      "role":localData.storage.read("role"),
      "search_type": "group_project_attendance",
      "id": projectId,
      "date": date1.text,
    };
    final response =await prjRepo.getAttendances(data);
    print(response.toString());
    if (response.isNotEmpty) {
      _projectReport=response;
      checkProjectAttendance();
    } else {
      _projectReport=[];
      resetProjectAttendance();
    }
  } catch (e) {
    _projectReport=[];
    resetProjectAttendance();
  }
  notifyListeners();
}
Future getProjectGroupAtt(context,String projectId) async {
  try {
    final Map<String, dynamic> data = {
      'action': projectGroupAttendance,
      'attendanceList': _prjGroupAttendanceList, // The list
    };
    final response =await prjRepo.grpAttendances(data);
    print(response.toString());
    if (response.isNotEmpty) {
      utils.showSuccessToast(context:context,text: constValue.updated);
      _prjGroupAttendanceList.clear();
      getProjectDailyAtt(projectId);
      projectCtr.reset();
    } else {
      utils.showErrorToast(context: context);
      projectCtr.reset();
    }
  } catch (e) {
    utils.showErrorToast(context: context);
    projectCtr.reset();
  }
  notifyListeners();
}

void checkProjectAttendance(){
  for(var i=0;i<_projectReport.length;i++){
    for(var j=0;j<_searchPrjUserEdit.length;j++){
      if(_projectReport[i].salesmanId==_searchPrjUserEdit[j]['user_id']&&
          _projectReport[i].projectId==localData.storage.read("g_prj_id")){
        if(_projectReport[i].checkInTs.toString().contains(":")){
          _searchPrjUserEdit[j]['check_in']=true;
          _prjUserEdit[j]['check_in']=true;
          _searchPrjUserEdit[j]['in']=_projectReport[i].checkInTs.toString();
          _prjUserEdit[j]['in']=_projectReport[i].checkInTs.toString();
        }
        if(_projectReport[i].isCheckedOut.toString().contains("2")){
          _searchPrjUserEdit[j]['check_out']=true;
          _prjUserEdit[j]['check_out']=true;
          _searchPrjUserEdit[j]['out']=_projectReport[i].checkOutTs.toString();
          _prjUserEdit[j]['out']=_projectReport[i].checkOutTs.toString();
        }
        _searchPrjUserEdit[j]['att_id']=_projectReport[i].id.toString();
        _prjUserEdit[j]['att_id']=_projectReport[i].id.toString();
      }
    }
  }
  _attRefresh=true;
  notifyListeners();
}
void resetProjectAttendance() {
  for (var j = 0; j < _searchPrjUserEdit.length; j++) {
    _searchPrjUserEdit[j]['check_in'] = false;
    _prjUserEdit[j]['check_in'] = false;
    _searchPrjUserEdit[j]['in'] = "";
    _prjUserEdit[j]['in'] = "";
    _searchPrjUserEdit[j]['check_out'] = false;
    _prjUserEdit[j]['check_out'] = false;
    _searchPrjUserEdit[j]['out'] = "";
    _prjUserEdit[j]['out'] = "";
    _attRefresh = true;
    notifyListeners();
  }
}

}