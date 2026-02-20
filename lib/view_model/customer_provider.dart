import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:master_code/component/maxline_textfield.dart';
import 'package:master_code/source/styles/decoration.dart';
import 'package:master_code/view_model/task_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:master_code/model/customer/customer_attendance_model.dart';
import 'package:master_code/repo/customer_repo.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../component/custom_loading_button.dart';
import '../component/custom_text.dart';
import '../component/custom_textfield.dart';
import '../local_database/sqlite.dart';
import '../model/add_customer_model.dart';
import '../model/audio_model.dart';
import '../model/customer/customer_model.dart';
import '../model/customer/customer_report_model.dart';
import '../model/customer/template_model.dart';
import '../model/track/track_model.dart';
import '../model/user_model.dart';
import '../screens/common/camera.dart';
import '../screens/common/fullscreen_photo.dart';
import '../source/constant/api.dart';
import '../source/constant/assets_constant.dart';
import '../source/constant/colors_constant.dart';
import '../source/constant/default_constant.dart';
import '../source/constant/local_data.dart';
import '../source/utilities/utils.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart'as http;

import 'employee_provider.dart';

import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, CellStyle;
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
class CustomerProvider with ChangeNotifier{
  final CustomerRepository custRepo = CustomerRepository();
  TextEditingController search = TextEditingController();
  TextEditingController search2 = TextEditingController();
  Future<void> getTaskComments(String id) async {
    _refresh=false;
    _customerReport.clear();
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type":"task_comments",
        "cos_id": localData.storage.read("cos_id"),
        "id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "cus_id": id
      };
      // print(data.toString());
      final response =await custRepo.getComments(data);
      if (response.isNotEmpty) {
        _customerReport=response;
        _refresh=true;
      } else {
        _refresh=true;
      }
    } catch (e) {
      _refresh=true;
    }
    notifyListeners();
  }

  Future<void> tComment({context,required String taskId,required String assignedId}) async {
    final tempMessage = CustomerReportModel(
      comments: disPoint.text.trim(),
      createdBy: localData.storage.read("id"),
      firstname: localData.storage.read("f_name"),
      role: localData.storage.read("role"),
      createdTs: DateTime.now(),
      documents: _recordedAudioPaths.isNotEmpty
          ? _recordedAudioPaths[0].audioPath
          : null,
      isLocal: true,
    );

    _customerReport.add(tempMessage);
    notifyListeners();
    try {
    List<Map<String, String>> customersList = [];

    // Loop for selected files
    for (int i = 0; i < _selectedFiles.length; i++) {
      // print("////$i");
      customersList.add({
        "image_$i": _selectedFiles[i]['path'],
      });
    }

// Loop for recorded audio paths
    for (int i = _selectedFiles.length; i < _selectedFiles.length + _recordedAudioPaths.length; i++) {
      // print("----$i");
      customersList.add({
        "image_$i": _recordedAudioPaths[i - _selectedFiles.length].audioPath, // Adjust index
      });
    }

// Loop for selected photos
    for (int i = _selectedFiles.length + _recordedAudioPaths.length; i < _selectedFiles.length + _recordedAudioPaths.length + selectedPhotos.length; i++) {
      // print("]]]]$i");
      customersList.add({
        "image_$i": selectedPhotos[i - (_selectedFiles.length + _recordedAudioPaths.length)], // Adjust index
      });
    }
    String jsonString = json.encode(customersList);
    Map<String,String> data = {
      "action":taskComments,
      "cos_id":localData.storage.read("cos_id"),
      "task_id":taskId,
      "log_file":localData.storage.read("mobile_number"),
      "created_by":localData.storage.read("id")??"0",
      "comment":disPoint.text.trim(),
      "data": jsonString,
    };
    final response =await custRepo.taskComments(data,customersList);
    log(response.toString());
    if (response.toString().contains("200")){
      _recordedAudioPaths.clear();
      if(localData.storage.read("role")=="1"){
        try {
          await Provider.of<EmployeeProvider>(context, listen: false).sendSomeUserNotification(
            "Feedback added to task.Added By ${localData.storage.read("f_name")}",
            disPoint.text.trim(),
            assignedId.toString(),taskId
          );
        } catch (e) {
          print("User notification error: $e");
        }

        // admin notification (always run)
        try {
          await Provider.of<EmployeeProvider>(context, listen: false).sendAdminNotification(
            "Feedback added to task.Added By ${localData.storage.read("f_name")}",
            disPoint.text.trim(),
            localData.storage.read("role"),taskId
          );
        } catch (e) {
          print("Admin notification error: $e");
        }
      }else{
        // admin notification (always run)
        try {
          await Provider.of<EmployeeProvider>(context, listen: false).sendAdminNotification(
            "${localData.storage.read("f_name")} replied to task feedback.",
            disPoint.text.trim(),
            "1",taskId
          );
        } catch (e) {
          print("Admin notification error: $e");
        }
      }

      // utils.showSuccessToast(context: context,text: constValue.success,);
      disPoint.clear();
      addCtr.reset();
      // getTaskComments(taskId);
      // Future.microtask(() => Navigator.pop(context));
      addCtr.reset();
    }else {
      utils.showErrorToast(context: context);
      addCtr.reset();
    }
    } catch (e) {
      _customerReport.remove(tempMessage);
      notifyListeners();
      // utils.showWarningToast(context,text: "Failed",);
      addCtr.reset();
    }
    notifyListeners();
  }

bool _isVisible=false;
int _visibleIndex=0;
bool get isVisible =>_isVisible;
int get visibleIndex =>_visibleIndex;
void visible(int index){
  if(_isVisible==true){
    _isVisible=false;
    _isVisible=true;
  }else if(_isVisible==true){
    _isVisible=false;
  }else{
    _isVisible=true;
  }
  _visibleIndex=index;
  notifyListeners();
}
void closeVisible(){
  _isVisible=false;
  notifyListeners();
}
  var sendList=[];

  void setValue(String id){
    // print("id");
    // print(id);
    sendList.clear();
    for(var i=0;i<customer.length;i++){
      if(customer[i].userId==id){
        var idList=customer[i].customerId.toString().split('||');
        var usersList=customer[i].firstName.toString().split('||');
        var phoneList=customer[i].phoneNumber.toString().split('||');
        for(var i=0;i<usersList.length;i++){
          sendList.add({"id": idList[i], "name": usersList[i], "no": phoneList[i]});
        }
        selectCustomer=sendList[0];
        localData.storage.write("c_id",sendList[0]["id"]);
        localData.storage.write("c_no",sendList[0]["no"]);
        localData.storage.write("c_name",sendList[0]["name"]);
        // print("selectCustomer");
        // print(selectCustomer);
      }
    }
    notifyListeners();
  }
  void setCustomer(List list){

    notifyListeners();
  }
  bool _update = false;
  bool get update =>_update;
  void makeChanges(){
    _update = true;
    notifyListeners();
  }
  List cusList =["Home","Shop","Office","Factory","Hotel","Others"];
  var typeList = ["Today","Yesterday","Last 7 Days","Last 30 Days","This Week","This Month","Last 3 months"];
  String _reportType="All";
  String get reportType =>_reportType;
  void changeReportType(dynamic value){
    _reportType=value;
    notifyListeners();
  }

  int _showIndex = 0;
  int get showIndex =>_showIndex;
  void changeIndex(int index) {
    _showIndex=index;
    notifyListeners();
  }


  String _sortBy = "1";
  String get sortBy =>_sortBy;
  void changeSort(String type) {
    _sortBy=type;
    notifyListeners();
  }

  // String _latitude = "0.0";
  // String _longitude = "0.0";
  // String get latitude=>_latitude;
  // String get longitude=>_longitude;
  /// Gets the current position once, with a timeout and error handling
  // void getCurrentLocation() async {
  //   const platform = MethodChannel('location');
  //     final String location = await platform.invokeMethod('getCurrentLocation');
  //     _latitude=location.toString().split(",")[0];
  //     _longitude=location.toString().split(",")[1];
  //     log('Current location: $location');
  // }
  // void getLocation() async {
  //   const platform = MethodChannel('location');
  //   try {
  //   Map<Permission, PermissionStatus> status = await [
  //     Permission.location,
  //   ].request();
  //   if (status[Permission.location] == PermissionStatus.granted) {
  //     final String location = await platform.invokeMethod('getCurrentLocation');
  //     _latitude=location.toString().split(",")[0];
  //     _longitude=location.toString().split(",")[1];
  //     log('Current location: $location');
  //   }else{
  //     var permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.deniedForever) {
  //       log("Location permissions are permanently denied.");
  //     }
  //   }
  //   } on PlatformException catch (e) {
  //     log('Failed to get location: ${e.message}');
  //   }
  // }
  ///


  // void getTrackPermission(context) async {
  //   try {
  //   Map<Permission, PermissionStatus> status = await [
  //     Permission.location,
  //     Permission.notification,
  //   ].request();
  //   if (status[Permission.location] == PermissionStatus.granted&&status[Permission.notification] == PermissionStatus.granted) {
  //     bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!isLocationServiceEnabled) {
  //       utils.showWarningToast(context, text: "Location services are disabled. Please enable them.");
  //     }else {
  //       Position position = await Geolocator.getCurrentPosition();
  //       _latitude = "${position.latitude}";
  //       _longitude = "${position.longitude}";
  //       log('Current location: $_latitude $_longitude');
  //       if (_latitude == "0.0" && _longitude == "0.0") {
  //         utils.showWarningToast(context, text: "Check Your Location");
  //       }
  //     }
  //   }else{
  //     await openAppSettings();
  //   }
  //   } on PlatformException catch (e) {
  //     log('Failed to get location: ${e.message}');
  //   }
  // }
  // void getTrackPermission(context) async {
  //   try {
  //     // Request location permission
  //     PermissionStatus status = await Permission.location.request();
  //
  //     if (status == PermissionStatus.granted) {
  //       // Check if Location Service is enabled
  //       bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
  //       if (!isLocationServiceEnabled) {
  //         utils.showWarningToast(context, text: "Location services are disabled. Please enable them from settings.");
  //         return;
  //       }
  //
  //       // Get current location
  //       Position position = await Geolocator.getCurrentPosition();
  //       _latitude = "${position.latitude}";
  //       _longitude = "${position.longitude}";
  //       log('Current location: $_latitude $_longitude');
  //
  //       if (_latitude == "0.0" && _longitude == "0.0") {
  //         utils.showWarningToast(context, text: "Check your location accuracy.");
  //       }
  //
  //     } else if (status == PermissionStatus.denied) {
  //       utils.showWarningToast(context, text: "Location permission is required to continue.");
  //
  //     } else if (status == PermissionStatus.permanentlyDenied) {
  //       // iOS compliance: Show info dialog, don't auto-redirect to settings
  //       showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: Text("Permission Required"),
  //           content: Text("This feature requires location permission. Please enable it from Settings."),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: Text("Not Now"),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                   openAppSettings(); // Only if user agrees
  //               },
  //               child: Text("Go to Settings"),
  //             ),
  //           ],
  //         ),
  //       );
  //     }
  //
  //   } on PlatformException catch (e) {
  //     log('Failed to get location: ${e.message}');
  //   }
  // }


  bool _refresh = true;
  bool _cusRefresh = true;
  bool _clear = true;
  bool get refresh =>_refresh;
  bool get clear =>_clear;
  bool _cmtRefresh = true;
  bool get cusRefresh =>_cusRefresh;
  bool get cmtRefresh =>_cmtRefresh;
  bool _visitRefresh = true;
  bool get visitRefresh =>_visitRefresh;
  List<CustomerModel> _customerData=[];
  List<CustomerModel> _customerDetailData=[];
  List<CustomerModel> _filterCustomerData=[];
  List<CustomerModel> _searchCustomerDate=[];
  List<CustomerModel> get customer => _customerData;
  List<CustomerModel> get filterCustomerData => _filterCustomerData;
  List<CustomerModel> get customerDetailData => _customerDetailData;
  Future<void> getAllCustomers(bool isRefresh) async {
    if(isRefresh==true){
      _cusRefresh=false;
      search.clear();
      _customerData.clear();
      _searchCustomerDate.clear();
      _filterCustomerData.clear();
    }
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type":"allCustomers",
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "id": localData.storage.read("id"),
        "st_dt": date1,
        "en_dt": date2,
      };
      final response =await custRepo.getCustomers(data);
      // log(data.toString());
      // log(response.toString());
      if (response.isNotEmpty) {
        _customerData=response;
        _filterCustomerData=response;
        _searchCustomerDate=response;
        // getCustomerAtt();
        _cusRefresh=true;
      } else {
        _cusRefresh=true;
      }
    } catch (e) {
      _cusRefresh=true;
    }
    notifyListeners();
  }
  String date1="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
  String date2="${DateTime.now().add(const Duration(days: 1)).day.toString().padLeft(2,"0")}-${DateTime.now().add(const Duration(days: 1)).month.toString().padLeft(2,"0")}-${DateTime.now().add(const Duration(days: 1)).year}";
List lineAtt=[];
// Future<void> getCustomerAtt() async {
//   _refresh=false;
//   notifyListeners();
//   try {
//     Map data = {
//       "search_type": "daily_attendance",
//       "id": localData.storage.read("id"),
//       "st_dt": date1,
//       "en_dt": date2,
//       "cos_id": localData.storage.read("cos_id")
//     };
//     final response =await custRepo.getCustomerAttendance(data);
//     // log(response.toString());
//     if (response.isNotEmpty) {
//      lineAtt=response;
//       if(lineAtt.isNotEmpty){
//         for(var i=0;i<_customerData.length;i++){
//           CustomerModel data = _customerData[i];
//           String check="0";
//           var foundItem = lineAtt.firstWhere(
//                 (item) => item['line_customer_id'] == data.userId ,
//             orElse: () => null,
//           );
//           if (foundItem != null) {
//             var isCheckedOut = foundItem['is_checked_out'];
//             check=isCheckedOut;
//           } else {
//           }
//           _customerData[i].check=check;
//         }
//       }
//       _refresh=true;
//     } else {
//       _refresh=true;
//     }
//   } catch (e) {
//     _refresh=true;
//   }
//   notifyListeners();
// }
late GoogleMapController googleMapController;
final List<Marker> _marker =[];
List<Marker> get marker =>_marker;
Future<void> mapAddress() async {
  if(search2.text!=""){
    try{
      List<Location> locations = await locationFromAddress(search2.text);
      googleMapController.animateCamera
        (CameraUpdate.newCameraPosition(CameraPosition
        (target: LatLng(locations[0].latitude,locations[0].longitude),zoom: 20)));
        _marker.add(
          Marker(
            markerId: const MarkerId("1"),
            position:LatLng(locations[0].latitude,locations[0].longitude),
            infoWindow: InfoWindow(title: search2.text),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet
            ),),);
      List<Placemark> placeMark=await placemarkFromCoordinates(locations[0].latitude,locations[0].longitude);
      Placemark place = placeMark[0];
      address.text=place.street.toString();
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

void clearAddress(context,String lat,String lng){
  _clear=!_clear;
if(_clear==true){
  getAdd(double.parse(lat),double.parse(lng));
}else{
  address.clear();
  comArea.clear();
  city.clear();
  country.clear();
  pinCode.clear();
  state = null;
}
  notifyListeners();
}
void changeState(dynamic value){
  state = value;
  _update = true;
  notifyListeners();
}
void changeCusType(dynamic value){
    _type = value;
  _update = true;
  notifyListeners();
}
void changeLeadType(dynamic value){
  leadType = value!;
  var list = [];
  list.add(value);
  // print(value);
  // print(leadCategoryList);
  // print(localData.storage.read("lead_id"));
  localData.storage.write("lead_id", list[0]["id"]);
  // print(localData.storage.read("lead_id"));

  notifyListeners();
}
void changeCallType(dynamic value){
  callType = value!;
  var list = [];
  list.add(value);
  localData.storage.write("visit_id", list[0]["id"]);
  notifyListeners();
}
Future<void> getCustomerDetail(String id,bool isUpdate,bool isRefresh) async {
  if(isRefresh==true){
    _refresh=false;
  }
  _update=false;
  _showIndex=0;
  _listItem=0;
  _customerDetailData.clear();
  notifyListeners();
  // try {
    Map data = {
      "action": getAllData,
      "search_type":"customers_full_details",
      "cus_id":id,
      "cos_id": localData.storage.read("cos_id")
    };
    final response =await custRepo.getCustomers(data);
    // log(data.toString());
    log(response.toString());
    if (response.isNotEmpty) {
    _customerDetailData=response;
    if(isUpdate==true){
      CustomerModel data = _customerDetailData[0];
      localData.storage.write("lead_id",data.leadId.toString());
      localData.storage.write("visit_id",data.visitId.toString());
      print("leadId : ${data.leadId.toString()}");
      print("visitId : ${data.visitId.toString()}");
      if(data.visitId.toString()!="0"){
        callType= callList.firstWhere(
              (item) =>
          item["categories"] == "Call Visit Type" &&
              item["id"] == data.visitId.toString() &&
              item["value"] == data.visitType.toString(),
          // orElse: () => null,  // returns empty map
        );
      }
      if(data.leadId.toString()!="0"){
        leadType = leadCategoryList.firstWhere(
              (item) =>
          item["categories"] == "Lead Categories" &&
              item["id"].toString() == data.leadId.toString() &&
              item["value"] == data.leadStatus.toString(),
          // orElse: () => null, // returns empty map
        );
      }
      _type=data.type.toString()=="2"?"Shop":data.type.toString()=="3"?"Office":data.type.toString()=="4"?"Factory":data.type.toString()=="5"?"Hotel":data.type.toString()=="6"?"Others":"1";
      companyName.text=data.companyName.toString();
      productDis.text=data.productDiscussion.toString()=="null"?"":data.productDiscussion.toString();
      disPoint.text=data.discussionPoint.toString()=="null"?"":data.discussionPoint.toString();
      points.text=data.points.toString()=="null"?"":data.points.toString();
      address.text=data.doorNo.toString();
      comArea.text=data.area.toString();
      city.text=data.city.toString();
      country.text=data.country.toString();
      pinCode.text=data.pincode.toString();
      emgName.text=data.emergencyName.toString();
      emgNo.text=data.emergencyNumber.toString();
      landmark.text=data.landmark.toString();
      _type=data.type.toString()=="2"?"Shop":data.type.toString()=="3"?"Office":data.type.toString()=="4"?"Factory":data.type.toString()=="5"?"Hotel":data.type.toString()=="6"?"Others":"Home";
      state=data.state.toString()=="null"||data.state.toString()==""?null:data.state.toString();
      // print(data.customerId.toString());
      var idList=data.customerId.toString().split('||');
      var usersList=data.firstName.toString().split('||');
      var phoneList=data.phoneNumber.toString().split('||');
      var phoneList2=data.mobileNumber.toString().split('||');
      var emailList=data.emailId.toString().split('||');
      var designationList=data.designation.toString().split('||');
      var departmentList=data.department.toString().split('||');
      var mainPersonList=data.mainPerson.toString().split('||');
      var roleList=data.roles.toString().split('||');
      addCustomer.clear();
      for(var i=0;i<usersList.length;i++){
        addCustomer.add(AddCustomerModel(
            newE:"0",
            name: TextEditingController(text: usersList[i]=="null"?"":usersList[i]),
            whatsApp: TextEditingController(text: phoneList2[i]=="null"?"":phoneList2[i]),
            phone: TextEditingController(text: phoneList[i]=="null"?"":phoneList[i]),
            email: TextEditingController(text: emailList[i]=="null"?"":emailList[i]), id: idList[i],
            designation: TextEditingController(text: designationList[i]=="null"?"":designationList[i]),
            department: TextEditingController(text: departmentList[i]=="null"?"":departmentList[i]),
            isMain: mainPersonList[i]=="1"?true:mainPersonList.length==1?true:false,
            isWhatsapp: phoneList2[i].trim().isNotEmpty&&phoneList[i].trim().isNotEmpty&&
                phoneList2[i]==phoneList[i]?true:false,
            role: roleList[i], roleC: roleList[i]));
      }
      _listItem=addCustomer.length;
    }
      _refresh=true;
    } else {
      _listItem=0;
      _refresh=true;
    }
  // } catch (e) {
  //   _refresh=true;
  // }
  notifyListeners();
}
  void searchCustomer(String value){
    if(_filter==false){
      final suggestions=_searchCustomerDate.where(
              (user){
            final comFName=user.companyName.toString().toLowerCase();
            final userFName=user.firstName.toString().toLowerCase();
            final userNumber = user.phoneNumber.toString().toLowerCase();
            final input=value.toString().toLowerCase();
            return comFName.contains(input) || userFName.contains(input) || userNumber.contains(input);
          }).toList();
      _filterCustomerData=suggestions;
    }else{
      final suggestions=_filterCustomerData.where(
              (user){
            final comFName=user.companyName.toString().toLowerCase();
            final userFName=user.firstName.toString().toLowerCase();
            final userNumber = user.phoneNumber.toString().toLowerCase();
            final input=value.toString().toLowerCase();
            return comFName.contains(input) || userFName.contains(input) || userNumber.contains(input);
          }).toList();
      _filterCustomerData=suggestions;
      if(value.isEmpty){
        filterList();
      }
    }
    // _customerData=suggestions;
    notifyListeners();
  }
void searchCustomerReport(String value){
    final suggestions=_searchCustomerReport.where(
            (user){
          final comFName=user.companyName.toString().toLowerCase();
          final userFName=user.firstname.toString().toLowerCase();
          final name=user.name.toString().toLowerCase();
          final userNumber = user.phoneNo.toString().toLowerCase();
          final input=value.toString().toLowerCase();
          return comFName.contains(input) || name.contains(input) ||userFName.contains(input) || userNumber.contains(input);
        }).toList();
    _customerReport=suggestions;
    notifyListeners();
  }
  // bool _isCheckOut=false;
  // bool _isCheckIn=false;
  // void checked(BuildContext context,String cusId,String cusName) async {
  //   _isCheckOut = false;
  //   for (var i = 0; i < lineAtt.length; i++) {
  //     if (
  //     lineAtt[i]["line_customer_id"].toString() ==cusId &&
  //         lineAtt[i]["is_checked_out"].toString()=="2"
  //     ) {
  //       _isCheckOut = true;
  //       break;
  //     }else if (
  //    lineAtt[i]["line_customer_id"].toString() ==cusId &&lineAtt[i]["is_checked_out"].toString()=="1") {
  //       _isCheckIn = true;
  //       break;
  //     }else{
  //       _isCheckIn = false;
  //       _isCheckOut = false;
  //     }
  //   }
  //   if(_isCheckOut == true){
  //     utils.showWarningToast(context, text: "Already attendance marked", color: colorsConst.appRed);
  //   }else if(_isCheckIn==true){
  //     customerDailyAtt(context,"2",cusName);
  //   }else{
  //     customerDailyAtt(context,"1",cusName);
  //   }
  // }
  Future<void> customerDailyAtt(context,String status,String cusName,String companyName,String lat,String lng) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                child: Column(
                  children: [
                    const CustomText(text: "Marking Visit",
                      colors: Colors.grey,
                      size: 15,
                      isBold: true,),
                    10.height,
                    const CustomText(text: "Please Wait",
                      colors: Colors.grey,
                      size: 15,
                      isBold: true,),
                    20.height,
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: colorsConst.primary,
                      size: 25,
                    ),
                  ],
                ),
              ),
            );
          }
      );
      Map data = {
        "action": custAttendance,
        "log_file": localData.storage.read("mobile_number"),
        "line_id": "0",
        "line_customer_id": localData.storage.read("cus_id"),
        "salesman_id": localData.storage.read("id"),
        "self_img_count": "0",
        "comp_img_count": "0",
        "collection_amt": "0",
        "sales_amt": "0",
        "is_checked_out": status,
        "lat": lat,
        "lng": lng,
        "traveled_kms": 0.0,
        "id": localData.storage.read("chk_id"),
        "cos_id": localData.storage.read("cos_id"),

      };
      final response =await custRepo.addAttendance(data);
      log(response.toString());
      if (response.isNotEmpty){
        localData.storage.write("chk_id", response[0]["id"]);
        utils.showSuccessToast(text: status=="1"?"Check In Successful":"Check Out Successful",context: context);
        if(localData.storage.read("Track")==true){
          if(status=="1"){
            localData.storage.write("TrackId",localData.storage.read("cus_id"));
            localData.storage.write("TrackStatus",status);
            localData.storage.write("T_Shift","");
            localData.storage.write("TrackUnitName",companyName);
            trackingInsert(localData.storage.read("TrackId"),false,lat,lng);
          }else{
            localData.storage.write("TrackId", "0");
            localData.storage.write("TrackStatus", "1");
            localData.storage.write("T_Shift", "");
            localData.storage.write("TrackUnitName", "null");
          }
        }
        getAllCustomers(false);
        Navigator.of(context, rootNavigator: true).pop();
      }else {
        Navigator.of(context, rootNavigator: true).pop();
        utils.showErrorToast(context: context);
      }
    } catch (e) {
      log(e.toString());
      Navigator.of(context, rootNavigator: true).pop();
      utils.showErrorToast(context: context);
    }
    notifyListeners();
  }


  List<AddCustomerModel> _addCustomer = <AddCustomerModel>[];
  List<AddCustomerModel> get addCustomer =>_addCustomer;

  List<AddCmtImg> _addImg = <AddCmtImg>[];
  List<AddCmtImg> get addImg =>_addImg;

int _listItem=0;
int get listItem=>_listItem;
  dynamic state,_type,leadType,leadStatus,callType,selectCustomer;
 dynamic get type=> _type;
  var leadCategoryList=[],callList=[],cmtTypeList=[];
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
  TextEditingController companyName = TextEditingController();
  TextEditingController productDis = TextEditingController();
  TextEditingController disPoint = TextEditingController();
  TextEditingController points = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController comArea = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController commentDate = TextEditingController();

  TextEditingController landmark = TextEditingController();
  TextEditingController emgName = TextEditingController();
  TextEditingController emgNo = TextEditingController();
  final RoundedLoadingButtonController addCtr =RoundedLoadingButtonController();

 bool required = false,status1 = false,status2 = false,status3 = false;
 var statusType = "1";
 void changeRole(String role,int index){
   _update = true;
   addCustomer[index].roleC=role;
   notifyListeners();
 }
  void initValues(){
    _showIndex=0;
    _type=null;
    callType=null;
    leadType=null;
    if(callList.isEmpty){
    }else{
      callType=callList[0];
      localData.storage.write("visit_id",callList[0]["id"]);
    }
    if(leadCategoryList.isEmpty){
    }else{
      leadType=leadCategoryList[0];
      localData.storage.write("lead_id",leadCategoryList[0]["id"]);
    }
    companyName.clear();
    emgName.clear();
    emgNo.clear();
    productDis.clear();
    disPoint.clear();
    points.clear();
    required=false;
    status1=true;
    status2=false;
    status3=false;
    statusType="1";
    _img1="";
    _imgName1="";
    _imgList1=[];
    _img2="";
    _imgName2="";
    _imgList2=[];
    _type="Office";
    _addCustomer.clear();
    _addCustomer.add(AddCustomerModel(
        newE:"1",
        name: TextEditingController(),
        whatsApp: TextEditingController(),
        phone: TextEditingController(),
        email: TextEditingController(),
        id: '', designation: TextEditingController(),department: TextEditingController(),
        isMain: true,isWhatsapp: false, role: 'Decision Maker', roleC: 'Decision Maker'));
    notifyListeners();
  }
  Future<void> deleteCustomer(context, {required String cusId, required String id}) async {
    try {
      Map<String, String> data = {
        "action":delete,
        "ops": "customer",
        "id": id,
        "cus_id": cusId,
        "cos_id": localData.storage.read("cos_id"),
        "updated_by": localData.storage.read("id"),
        "platform": localData.storage.read("platform").toString(),
      };
      final response =await custRepo.deleteCustomer(data);
      // print(data.toString());
      // print(response.toString());
      if (response.toString().contains("ok")) {
        Navigator.pop(context);
        utils.showSuccessToast(context: context, text: "Deleted Successfully",);
        getCustomerDetail(cusId,false,true);
        getAllCustomers(false);
        addCtr.reset();
      }
    } catch (e) {
      utils.showErrorToast(context: context);
      addCtr.reset();
    }
    notifyListeners();
  }
  Future<void> getLeadCategory() async {
    try {
      Map data = {
        "action": getAllData,
        "search_type":"category",
        "cat_id":"1",
        "cos_id": localData.storage.read("cos_id")
      };
      final response =await custRepo.getCustomerAttendance(data);
      // log(response.toString());
      leadCategoryList.clear();
      if (response.isNotEmpty) {
        List<Map<String, String>> leadList = response.map((e) => {
          "id": e['id'].toString(),
          "value": e['value'].toString().trim(),
          "categories": e['categories'].toString()
        }).toList();
        if(!kIsWeb){
          await LocalDatabase.insertLeadCategory(leadList);
        }else{
          leadCategoryList.clear();
          leadCategoryList=leadList;
          notifyListeners();
        }
      }
    } catch (e) {
      // _refresh=true;
    }
    notifyListeners();
  }
  Future<void> getLead() async {
   // print("getLead");
    leadCategoryList.clear();
    List storedLeads = await LocalDatabase.getLeadCategories();
    leadCategoryList=storedLeads;
    notifyListeners();
  }
  Future<void> refreshLead() async {
    leadType=null;
    leadCategoryList.clear();
    List storedLeads = await LocalDatabase.getLeadCategories();
    leadCategoryList=storedLeads;
    if(leadCategoryList.isNotEmpty){
      leadType=leadCategoryList[0];
  }
    notifyListeners();
  }
  Future<void> getVisit() async {
    // print("getVisit");
    callList.clear();
    List storedLeads = await LocalDatabase.getVisitTypes();
    callList=storedLeads;
    notifyListeners();
  }
  Future<void> refreshVisit() async {
    callType=null;
    callList.clear();
    List storedLeads = await LocalDatabase.getVisitTypes();
    callList=storedLeads;
    if(callList.isNotEmpty){
      callType=callList[0];
    }
    notifyListeners();
  }
  Future<void> getCommentType() async {
    _dailyType=null;
    cmtTypeList.clear();
    List storedLeads = await LocalDatabase.getCmtTypes();
    cmtTypeList=storedLeads;
    notifyListeners();
  }
  Future<void> refreshCommentType() async {
    _selectType=null;
    cmtTypeList.clear();
    List storedLeads = await LocalDatabase.getCmtTypes();
    cmtTypeList=storedLeads;
    if(cmtTypeList.isNotEmpty){
      _selectType=cmtTypeList[0];
    }
    notifyListeners();
  }
  Future<void> getVisitType() async {
    try {
      Map data = {
        "action": getAllData,
        "search_type":"category",
        "cat_id":"2",
        "cos_id": localData.storage.read("cos_id")
      };
      final response =await custRepo.getCustomerAttendance(data);
      // print(data.toString());
      // print(response.toString());
      if (response.isNotEmpty) {
        List<Map<String, String>> visitList = response.map((e) => {
          "id": e['id'].toString(),
          "value": e['value'].toString().trim(),
          "categories": e['categories'].toString()
        }).toList();
        if(!kIsWeb){
          await LocalDatabase.insertVisitType(visitList);
        }else{
          callList.clear();
          callList=visitList;
          notifyListeners();
        }
      }
    } catch (e) {
      // _refresh=true;
    }
    notifyListeners();
  }
  Future<void> getCmtType() async {
    try {
      Map data = {
        "action": getAllData,
        "search_type":"cmt_type",
        "cat_id":"7",
        "cos_id": localData.storage.read("cos_id")
      };
      final response =await custRepo.getCustomerAttendance(data);
      // log(data.toString());
      // log(response.toString());
      if (response.isNotEmpty) {
        List<Map<String, String>> typeList = response.map((e) => {
          "id": e['id'].toString(),
          "value": e['value'].toString().trim(),
          "categories": e['categories'].toString()
        }).toList();
        if(!kIsWeb){
          await LocalDatabase.insertCmtType(typeList);
        }else{
          cmtTypeList.clear();
          cmtTypeList=typeList;
          notifyListeners();
        }
      }
    } catch (e) {
      // _refresh=true;
    }
    notifyListeners();
  }
  void getAdd(double lat,double lng) async {
    List<Placemark> placeMark=await placemarkFromCoordinates(lat,lng);
    Placemark place = placeMark[0];
    address.text=place.street.toString();
    comArea.text="${place.subLocality.toString()}${place.thoroughfare.toString()==""?"":",${place.thoroughfare}"==""?"":place.thoroughfare.toString()}";
    city.text=place.locality.toString();
    landmark.clear();
    country.text=place.country.toString();
    pinCode.text=place.postalCode.toString();
    state=place.administrativeArea.toString();
    notifyListeners();
  }
  void addImgList(context){
     if(_addImg.last.img==""){
       utils.showWarningToast(context,text: "Please upload file");
     }else{
       _addImg.add(AddCmtImg(
          img: ''));
    }
    notifyListeners();
  }
  void addCustomerList(context){
    final customer =_addCustomer.last;

    if (customer.name.text.trim().isEmpty) {
      utils.showWarningToast(context, text: "Please Fill ${constValue.contact} Name");
    } else if (customer.phone.text.trim().isEmpty) {
      utils.showWarningToast(context, text: "Please Fill ${constValue.contact} ${constValue.phoneNumber}");
    } else if (customer.phone.text.trim().length != 10) {
      utils.showWarningToast(context, text: "Please Check ${constValue.contact} ${constValue.phoneNumber}");
    } else if (customer.whatsApp.text.trim().isNotEmpty && customer.whatsApp.text.trim().length != 10) {
      utils.showWarningToast(context, text: "Please Check ${constValue.contact} ${constValue.mobileNumber}");
    } else {
      if(customer.email.text.trim().isEmpty) {
        _addCustomer.add(AddCustomerModel(
            newE:"1",
            name: TextEditingController(),
            whatsApp: TextEditingController(),
            phone: TextEditingController(),
            email: TextEditingController(), id: '', designation: TextEditingController(),
            department: TextEditingController(),isMain: false,isWhatsapp: false, role: 'Decision Maker', roleC: 'Decision Maker'));
      }else{
        final bool isValid =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(customer.email.text.trim());
        if(isValid){
          _addCustomer.add(AddCustomerModel(
              newE:"1",
              name: TextEditingController(),
              whatsApp: TextEditingController(),
              phone: TextEditingController(),
              email: TextEditingController(), id: '', designation: TextEditingController(),
              department: TextEditingController(),isMain: false,isWhatsapp: false, role: 'Decision Maker', roleC: 'Decision Maker'));
        }else{
          utils.showWarningToast(context,text: "Please Check Email Id");
        }
      }
    }

    notifyListeners();
  }
  void customerList(context,String ops,String lat,String lng,{String? id, String? addressId}){
    if(companyName.text.trim().isEmpty){
      utils.showWarningToast(context,text: "Please fill company name",);
      addCtr.reset();
    }else if(_addCustomer.last.name.text.trim().isEmpty){
      utils.showWarningToast(context,text: "Please fill customer name",);
      addCtr.reset();
    }else if(_addCustomer.last.phone.text.trim().isEmpty){
      utils.showWarningToast(context,text: "Please fill customer phone number");
      addCtr.reset();
    }else if(_addCustomer.last.phone.text.trim().length!=10){
      utils.showWarningToast(context,text: "Please check customer phone number",);
      addCtr.reset();
    }else if(_addCustomer.last.whatsApp.text.trim().isNotEmpty&&_addCustomer.last.whatsApp.text.trim().length!=10){
      utils.showWarningToast(context,text: "Please check customer whatsApp number",);
      addCtr.reset();
    }else if(_addCustomer.last.email.text.trim().isNotEmpty){
      final email = _addCustomer.last.email.text.trim();
      // final isValid = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
      final bool isValid =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(email);

      if(isValid){
        if(ops=="1"){
          insertCustomer(context,lat,lng);
        }else{
          updatedCustomer(context,id.toString(),addressId.toString(),lat,lng);
        }
      }else{
        utils.showWarningToast(context,text: "Please check customer email");
        addCtr.reset();
      }
    }else{
      if(ops=="1"){
        insertCustomer(context,lat,lng);
      }else{
        updatedCustomer(context,id.toString(),addressId.toString(),lat,lng);
      }
    }
    notifyListeners();
  }
  void removeList(context,int index){
    if(_addCustomer.length==1){
      utils.showWarningToast(context,text: "Please add one customer");
      addCtr.reset();
    }else{
      if(_addCustomer[index].newE=="1"){
        _addCustomer.removeAt(index);
      }else{
        _addCustomer[index].active="0";
        _listItem--;
        if(_addCustomer.length==1){
          _addCustomer[0].isMain=true;
        }
      }
    }
    notifyListeners();
  }
void mainCustomer(int index){
    _update=true;
  if(_addCustomer.length==1){

  }else{
    if(_addCustomer[index].isMain==false){
      for (int i = 0; i < _addCustomer.length; i++) {
        _addCustomer[i].isMain=false;
      }
      _addCustomer[index].isMain=true;
    }else{
      _addCustomer[index].isMain=false;
    }
  }
  notifyListeners();
}
void copyNumber(int index){
  _update=true;
  _addCustomer[index].isWhatsapp=!_addCustomer[index].isWhatsapp;
  if(_addCustomer[index].isWhatsapp==true){
    _addCustomer[index].whatsApp.text=_addCustomer[index].phone.text;
  }else{
    _addCustomer[index].whatsApp.text="";
  }
    notifyListeners();
}
void changeNumber(int index){
  _update=true;
  if(_addCustomer[index].isWhatsapp==true){
    _addCustomer[index].whatsApp.text=_addCustomer[index].phone.text;
  }
    notifyListeners();
}
void removeCheck(int index){
  _update=true;
  if(_addCustomer[index].phone.text!=_addCustomer[index].whatsApp.text){
    _addCustomer[index].isWhatsapp=false;
  }
    notifyListeners();
}
  String _img1="";
  String _imgName1="";
  List<int> _imgList1=[];
  String _img2="";
  String _imgName2="";
  List<int> _imgList2=[];
  String get img1=>_img1;
  String get img2=>_img2;

  void signDialog({BuildContext? context, required String img,required Function(String newImg) onTap,required String count}) {
    showDialog(
        context: context!,
        builder: (context){
          return AlertDialog(
              title: const Center(
                child: Column(
                  children: [
                    Text(
                      "Pick Document From",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              content: SizedBox(
                height: 120,
                width: 300,
                // color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if(!kIsWeb)
                        GestureDetector(
                          onTap: ()async{
                            var imgData = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const CameraWidget(
                                      cameraPosition: CameraType.front,
                                    )));
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            if (imgData != null) {
                              onTap(imgData);
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
                            // final ImagePicker picker = ImagePicker();
                            // XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery,imageQuality: 100,maxHeight: 1000,maxWidth: 1000);
                            // var imgData = pickedFile!.path;
                            // if (imgData.isNotEmpty){
                            //   onTap(imgData);
                            // }
                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['png','jpeg','jpg'],
                            );
                            if (result != null) {
                              if(count=="1"){
                                _imgName1=result.files.single.name;
                                _imgList1=result.files.single.bytes!.toList();
                              }else{
                                _imgName2=result.files.single.name;
                                _imgList2=result.files.single.bytes!.toList();
                              }
                              onTap(!kIsWeb?result.files.single.name:base64.encode(result.files.single.bytes!.toList()));
                              notifyListeners();
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
                        if(img.isNotEmpty&&!img.contains("http"))
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onTap("");
                              },
                              child: CustomText(text: "Remove",colors: colorsConst.appRed,)
                          ),
                        if(img.isNotEmpty)
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>FullScreen(
                                    image: img, isNetwork: img.contains("http")?true:false)));
                              },
                              child: CustomText(text: "Full View",colors: colorsConst.blueClr,)
                          ),
                      ],
                    ),
                  ],
                ),
              ));
        });
  }
  void imgPick(String imgData){
    _img1 = imgData;
    notifyListeners();
  }
  void img2Pick(String imgData){
    _img2 = imgData;
    notifyListeners();
  }
Future<void> insertCustomer(context,String lat,String lng) async {
    try {
      List<Map<String, String>> customersList = [];
      for (int i = 0; i < _addCustomer.length; i++) {
        customersList.add({
          "cos_id": localData.storage.read("cos_id"),
          "name": _addCustomer[i].name.text.trim(),
          "email": _addCustomer[i].email.text.trim(),
          "phone_no": _addCustomer[i].phone.text.trim(),
          "whatsapp_no": _addCustomer[i].whatsApp.text.trim(),
          "created_by":localData.storage.read("id"),
          "platform":localData.storage.read("platform").toString(),
          "department":_addCustomer[i].department.text.trim(),
          "designation":_addCustomer[i].designation.text.trim(),
          "main_person":_addCustomer[i].isMain==true?"1":"0",
          "role_name":_addCustomer[i].roleC
        });
      }
      String jsonString = json.encode(customersList);
      Map<String, dynamic> data = {
        "action": createCustomer,
        "log_file": localData.storage.read("mobile_number").toString(),
        "user_id": localData.storage.read("id"),
        "company_name": companyName.text.trim(),
        "emergency_name": emgName.text.trim(),
        "emergency_number": emgNo.text.trim(),
        "product_discussion": productDis.text.trim(),
        "discussion_point": disPoint.text.trim(),
        "points": points.text.trim(),
        "quotation_status": statusType,
        "door_no": address.text.trim(),
        "landmark_1": landmark.text.trim(),
        "area": comArea.text.trim(),
        "city": city.text.trim(),
        "country": country.text.trim(),
        "state": state.toString(),
        "pincode": pinCode.text.trim(),
        "type": type=="Shop"?"2":type=="Office"?"3":type=="Factory"?"4":type=="Hotel"?"5":type=="Others"?"6":"1",
        "lat": lat,
        "lng": lng,
        "platform": localData.storage.read("platform").toString(),
        "cos_id": localData.storage.read("cos_id"),
        "lead_status": localData.storage.read("lead_id").toString(),
        "status": leadStatus.toString(),
        "quotation_required": required==false?"0":"1",
        "visit_type": localData.storage.read("visit_id").toString(),
        "data": jsonString
      };
      final response =await custRepo.addCustomer(data,_img1,_img2,_imgList1,_imgList2,_imgName1,_imgName2);
      log(response.toString());
      log(data.toString());
      if(response.toString().contains("200")){
        log("Success");
        utils.showSuccessToast(context: context,text: "Customer ${constValue.success}",);
        if(_addCustomer.length!=1){
          Navigator.of(context).pop();
        }
        getAllCustomers(true);
        Navigator.of(context).pop();
        addCtr.reset();
      }else if(response.toString().contains("already exists")){
        utils.showWarningToast(context,text: "Phone number already exits",);
        if(_addCustomer.length!=1){
          Navigator.of(context).pop();
        }
        addCtr.reset();
      }else{
        log("Failed");
        if(_addCustomer.length!=1){
          Navigator.of(context).pop();
        }
        utils.showErrorToast(context: context);
        addCtr.reset();
      }
    } catch (e) {
      log(e.toString());
      if(_addCustomer.length!=1){
        Navigator.of(context).pop();
      }
      utils.showErrorToast(context: context);
    }
    notifyListeners();
  }
Future<void> updatedCustomer(context,String id,String addressId,String lat,String lng) async {
    try {
      List<Map<String, String>> customersList = [];
      List<Map<String, String>> addCustomersList = [];
      for (int i = 0; i < _addCustomer.length; i++) {
        customersList.add({
          "id": _addCustomer[i].id,
          "name": _addCustomer[i].name.text,
          "email": _addCustomer[i].email.text,
          "phone_no": _addCustomer[i].phone.text,
          "whatsapp_no": _addCustomer[i].whatsApp.text,
          "department":_addCustomer[i].department.text,
          "designation":_addCustomer[i].designation.text,
          "main_person":_addCustomer[i].isMain==true?"1":"0",
          "role_name":_addCustomer[i].roleC,
          "active":_addCustomer[i].active
        });
      }
      String jsonString = json.encode(customersList);
      json.encode(addCustomersList);
      Map<String, dynamic> data = {
        "action": updateCustomer,
        "log_file": localData.storage.read("mobile_number").toString(),
        "id": id,
        "address_id": addressId,
        "user_id": localData.storage.read("id"),
        "data": jsonString,
        "company_name": companyName.text.trim(),
        "product_discussion": productDis.text.trim(),
        "emergency_name": emgName.text.trim(),
        "emergency_number": emgNo.text.trim(),
        "discussion_point": disPoint.text.trim(),
        "points": points.text.trim(),
        "quotation_status": statusType,
        "door_no": address.text.trim(),
        "area": comArea.text.trim(),
        "city": city.text.trim(),
        "country": country.text.trim(),
        "state": state.toString(),
        "pincode": pinCode.text.trim(),
        "type": type=="Shop"?"2":type=="Office"?"3":type=="Factory"?"4":type=="Hotel"?"5":type=="Others"?"6":"1",
        "lat": lat,
        "lng": lat,
        "landmark_1": landmark.text.trim(),
        "platform": localData.storage.read("platform").toString(),
        "cos_id": localData.storage.read("cos_id"),
        "lead_status": localData.storage.read("lead_id"),
        "status": leadStatus.toString(),
        "quotation_required": required==false?"0":"1",
        "visit_type": localData.storage.read("visit_id"),
      };
      final response =await custRepo.editCustomer(data);
      // print(customersList.toString());
      print(data.toString());
      print(response.toString());
      if(response.toString().contains("200")){
        log("Success");
        utils.showSuccessToast(context: context,text: "Customer ${constValue.updated}",);
        getAllCustomers(true);
        if(_listItem!=1){
          Navigator.of(context).pop();
        }
        Navigator.of(context).pop();
        addCtr.reset();
      }else{
        log("Failed");
        utils.showErrorToast(context: context);
        if(_listItem!=1){
          Navigator.of(context).pop();
        }
        addCtr.reset();
      }
    } catch (e) {
      log(e.toString());
      if(_listItem!=1){
        Navigator.of(context).pop();
      }
      utils.showErrorToast(context: context);
    }
    notifyListeners();
  }
dynamic _selectType;
dynamic get selectType=>_selectType;

String _selectReview="Complete";
String get selectReview=>_selectReview;
List<CustomerReportModel> _customerReport = <CustomerReportModel>[];
List<CustomerAttendanceModel> _customerAttendanceReport = <CustomerAttendanceModel>[];
List<CustomerReportModel> _searchCustomerReport = <CustomerReportModel>[];
List<CustomerReportModel> get customerReport=>_customerReport;
List<CustomerAttendanceModel> get customerAttendanceReport=>_customerAttendanceReport;
void changeType(dynamic value){
  _selectType=null;
  _selectType=value;
  var list=[];
  list.add(value);
  localData.storage.write("type_id",list[0]["id"]);

  notifyListeners();
}
void changeReview(dynamic value){
  _selectReview=value.toString();
  notifyListeners();
}
void initComment(List coList,String type){
  disPoint.clear();
  points.clear();
  _selectType=null;
  notifyListeners();
  if(cmtTypeList.isEmpty){
    _selectType=null;
  }else{
    // _selectType=null;
    // _selectType=cmtTypeList[0];
    // localData.storage.write("type_id",cmtTypeList[0]["id"]);
    // 👉 type match aagura item find pannum
    print("valueee $type");
    print("valueee ${cmtTypeList}");
    var matchedType = cmtTypeList.firstWhere(
          (item) =>
      item["value"]
          .toString()
          .trim()
          .toLowerCase() ==
          type.toString().trim().toLowerCase(),
      orElse: () => cmtTypeList[0] as Map<String, String>,
    );

    _selectType = matchedType;

    localData.storage.write("type_id", matchedType["id"]);
  }

  if(callList.isEmpty){
    callType=null;
  }else{
    callType=null;
    callType=callList[0];
    localData.storage.write("visit_id",callList[0]["id"]);
    notifyListeners();
  }
  if(leadCategoryList.isEmpty){
    leadType=null;
  }else{
    leadType=null;
    leadType=leadCategoryList[0];
    localData.storage.write("lead_id",leadCategoryList[0]["id"]);

    selectCustomer=null;
    if(coList.isNotEmpty){
      selectCustomer=coList[0];
      localData.storage.write("c_id",coList[0]["id"]);
      localData.storage.write("c_no",coList[0]["no"]);
      localData.storage.write("c_name",coList[0]["name"]);
    }
    notifyListeners();
  }

  commentDate.text="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
  notifyListeners();
  // _addImg.add(AddCmtImg(img: ''));
}
void initCmtValues(){
  disPoint.clear();
  _selectedFiles.clear();
  _recordedAudioPaths.clear();
  _selectedPhotos.clear();
  _isRecording = false;
  notifyListeners();
}
Future<void> addComment({context,required String createdBy,required String taskId,required String visitId,required String companyName,required String companyId,required List numberList}) async {
    // try {
  List<Map<String, String>> customersList = [];

// Loop for selected files
  for (int i = 0; i < _selectedFiles.length; i++) {
    // print("////$i");
    customersList.add({
      "image_$i": _selectedFiles[i]['path'],
    });
  }

// Loop for recorded audio paths
  for (int i = _selectedFiles.length; i < _selectedFiles.length + _recordedAudioPaths.length; i++) {
    // print("----$i");
    customersList.add({
      "image_$i": _recordedAudioPaths[i - _selectedFiles.length].audioPath, // Adjust index
    });
  }

// Loop for selected photos
  for (int i = _selectedFiles.length + _recordedAudioPaths.length; i < _selectedFiles.length + _recordedAudioPaths.length + selectedPhotos.length; i++) {
    // print("]]]]$i");
    customersList.add({
      "image_$i": selectedPhotos[i - (_selectedFiles.length + _recordedAudioPaths.length)], // Adjust index
    });
  }

  String jsonString = json.encode(customersList);
      Map<String,String> data = {
        "action":addCmt,
        "cos_id":localData.storage.read("cos_id"),
        "visit_id":visitId,
        "log_file":localData.storage.read("mobile_number"),
        "created_by":localData.storage.read("id")??"0",
        "comments":disPoint.text.trim(),
        "date":commentDate.text.trim(),
        "data": jsonString,
      };
      final response =await custRepo.addComments(data,customersList);
      log(response.toString());
      if (response.toString().contains("200")){
        if(localData.storage.read("role")=="1"){
          Provider.of<EmployeeProvider>(context, listen: false).sendAdminNotification(
            "Comments added to visit report.Added By ${localData.storage.read("f_name")}",
            disPoint.text.trim(),
            "1",visitId
          );        }
        else{Provider.of<EmployeeProvider>(context, listen: false).sendUserNotification(
            "${localData.storage.read("f_name")} replied to visit report.",
            disPoint.text.trim(),createdBy);
        }
        utils.showSuccessToast(context: context,text: constValue.success,);
        addCtr.reset();
        disPoint.clear();
        getComments(visitId);
        // Future.microtask(() => Navigator.pop(context));
        addCtr.reset();
      }else {
        utils.showErrorToast(context: context);
        addCtr.reset();
      }
    // } catch (e) {
    //   utils.showWarningToast(context,text: "Failed",);
    //   addCtr.reset();
    // }
    notifyListeners();
  }
Future<void> getAllComments(String id,String contId) async {
  _cmtRefresh=false;
    _customerReport.clear();
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type":"customer_interaction_history",
        "id":id,
        "con_id":contId,
        "role": localData.storage.read("role"),
        "user_id": localData.storage.read("id"),
        "cos_id": localData.storage.read("cos_id")
      };
      final response =await custRepo.getComments(data);
      log(data.toString());
      if (response.isNotEmpty) {
        _customerReport=response;
        _cmtRefresh=true;
      } else {
        _cmtRefresh=true;
      }
    } catch (e) {
      _cmtRefresh=true;
    }
    notifyListeners();
  }
Future<void> getEmployeeHistory(String id) async {
  _cmtRefresh=false;
    _customerReport.clear();
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type":"employee_interaction_history",
        "role": localData.storage.read("role"),
        "user_id": id,
        "cos_id": localData.storage.read("cos_id")
      };
      final response =await custRepo.getComments(data);
      print(data.toString());
      print(response.toString());
      if (response.isNotEmpty) {
        _customerReport=response;
        _cmtRefresh=true;
      } else {
        _cmtRefresh=true;
      }
    } catch (e) {
      _cmtRefresh=true;
    }
    notifyListeners();
  }
Future<void> getEmpComments() async {
    _refresh=false;
    _customerReport.clear();
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type":"employee_comments",
        "id":localData.storage.read("id"),
        "cos_id": localData.storage.read("cos_id")
      };
      final response =await custRepo.getComments(data);
      // log(response.toString());
      if (response.isNotEmpty) {
        _customerReport=response;
        _refresh=true;
      } else {
        _refresh=true;
      }
    } catch (e) {
      _refresh=true;
    }
    notifyListeners();
  }
Future<void> getComments(String id) async {
    _refresh=false;
    _customerReport.clear();
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type":"customer_comments",
        "id":id,
        "cos_id": localData.storage.read("cos_id"),
        "cus_id": "0"
      };
      // print(data.toString());
      final response =await custRepo.getComments(data);
      if (response.isNotEmpty) {
        _customerReport=response;
        _refresh=true;
      } else {
        _refresh=true;
      }
    } catch (e) {
      _refresh=true;
    }
    notifyListeners();
  }
Future<void> getAttendance(String id) async {
    _refresh=false;
    _customerAttendanceReport.clear();
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type":"customer_visits",
        "cus_id":id,
        "id":localData.storage.read("id"),
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role")
      };
      final response =await custRepo.getAttendances(data);
      log(data.toString());
      log(response.toString());
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
// String _incompleteCount="0";
// String _completeCount="0";
// String _totalCount="0";
// String _totalAtt="0";

// String get incompleteCount => _incompleteCount;
// String get completeCount => _completeCount;
// String get totalCount => _totalCount;
// String get totalAtt => _totalAtt;
TextEditingController date= TextEditingController(text: "${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year.toString()}");


  List _countReport = [];
  List get countReport => _countReport;
  String _startDate = "";
  String get startDate => _startDate;
  String _endDate="";
  String get endDate => _endDate;
  DateTime stDt = DateTime.now();
  DateTime enDt = DateTime.now().add(const Duration(days: 1));
  void initDate(){
    search.clear();
    stDt = DateTime.now();
    enDt = DateTime.now().add(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(stDt);
    _repType="Today";
    notifyListeners();
  }
  Future<void> getCountWiseReport(String id) async {
    _refresh=false;
    _countReport.clear();
    notifyListeners();
    // DateTime nextDay = stDt.add(const Duration(days: 1));
    // String formattedNextDay = DateFormat('dd-MM-yyyy').format(nextDay);
    try {
      Map data = {
        "action": getAllData,
        "search_type":"count_report",
        "id":id,
        "role":localData.storage.read("role"),
        "cos_id": localData.storage.read("cos_id"),
        "date1": _startDate,
        "date2": _endDate
      };
      final response =await custRepo.getDashboardReport(data);
      // log(response.toString());
      if (response.isNotEmpty) {
        _countReport=response;
        _refresh=true;
      }
    } catch (e) {
      _refresh=true;
    }
    notifyListeners();
  }

  Future<void> getReport(String id) async {
    search.clear();
    _refresh=false;
    _customerReport.clear();
    _searchCustomerReport.clear();
    notifyListeners();
    // DateTime nextDay = stDt.add(const Duration(days: 1));
    // String formattedNextDay = DateFormat('dd-MM-yyyy').format(nextDay);
    try {
      Map data = {
        "action": getAllData,
        "search_type":"customer_report",
        "id":id,
        "role":localData.storage.read("role"),
        "cos_id": localData.storage.read("cos_id"),
        "date1": _startDate,
        "date2": _endDate
      };
      final response =await custRepo.getComments(data);
      log(data.toString());
      if (response.isNotEmpty) {
        _customerReport=response;
        _searchCustomerReport=response;
        _refresh=true;
      }
    } catch (e) {
      _refresh=true;
    }
    notifyListeners();
  }
  List<CustomerReportModel> _customerVisitReport = <CustomerReportModel>[];
  List<CustomerReportModel> get customerVisitReport=>_customerVisitReport;
  Future<void> getVisits(String id,String taskId) async {
    _visitRefresh=false;
    _customerVisitReport.clear();
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type":"customer_daily_visits",
        "id":id,
        "task_id":taskId,
        "role":localData.storage.read("role"),
        "user_id":localData.storage.read("id"),
        "cos_id": localData.storage.read("cos_id")
      };
      // print(data);
      final response =await custRepo.getComments(data);
      // log(response.toString());
      if (response.isNotEmpty) {
        _customerVisitReport=response;
        _visitRefresh=true;
      } else {
        _visitRefresh=true;
      }
    } catch (e) {
      _visitRefresh=true;
    }
    notifyListeners();
  }
  Future<void> getCusVisits(String id) async {
    _visitRefresh=false;
    _customerVisitReport.clear();
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type":"cus_daily_visits",
        "id":id,
        "role":localData.storage.read("role"),
        "user_id":localData.storage.read("id"),
        "cos_id": localData.storage.read("cos_id")
      };
      // print(data);
      final response =await custRepo.getComments(data);
      // log(response.toString());
      if (response.isNotEmpty) {
        _customerVisitReport=response;
        _visitRefresh=true;
      } else {
        _visitRefresh=true;
      }
    } catch (e) {
      _visitRefresh=true;
    }
    notifyListeners();
  }
  Future<void> addVisit({required  context,required String companyId, required String taskId, required String companyName,required String tType, required String desc,
    required List sendList,required String lat,required String lng,required VoidCallback callBack}) async {
    try {
      Map data = {
        "action":addVst,
        "task_id":taskId,
        "log_file":localData.storage.read("mobile_number"),
        "cos_id":localData.storage.read("cos_id"),
        "company_id":companyId,
        "customer_id":localData.storage.read("c_id"),
        "mobile_number":localData.storage.read("c_no"),
        "customer_name":localData.storage.read("c_name"),
        "type":localData.storage.read("type_id"),
        "created_by":localData.storage.read("id")??"0",
        "discussion_points":disPoint.text.trim(),
        "action_taken":points.text.trim(),
        "lead":localData.storage.read("lead_id"),
        "call_visit_type":localData.storage.read("visit_id"),
        "date":commentDate.text.trim(),
        "review":selectReview,
        "door_no": address.text.trim(),
        "area": comArea.text.trim(),
        "city": city.text.trim(),
        "country": country.text.trim(),
        "state": state.toString(),
        "pincode": pinCode.text.trim(),
        "lat": lat,
        "lng": lng,
      };
      final response =await custRepo.addVisit(data);
      log(response.toString());
      if (response.toString().contains('ok')){
        utils.showSuccessToast(context: context,text: constValue.success);
        Provider.of<EmployeeProvider>(context, listen: false).sendAdminNotification(
          "Visit report added to task ${localData.storage.read("typeName")??""}",
          "Added By ${localData.storage.read("f_name")}",
          "1",taskId
        );
        await FirebaseFirestore.instance.collection('attendance').add({
          'emp_id': localData.storage.read("id"),
          'time': DateTime.now(),
          'status': "",
        });
        getAllCustomers(false);
        Provider.of<TaskProvider>(context, listen: false).getAllTask(false);
        callBack();
        notifyListeners();
        addCtr.reset();
      }else {
        utils.showErrorToast(context: context);
        addCtr.reset();
      }
    } catch (e) {
      utils.showErrorToast(context: context);
      addCtr.reset();
    }
    notifyListeners();
  }

  // PickerDateRange? selectedDate;
  List<DateTime> datesBetween = [];
  String betweenDates="";
  // void showDatePickerDialog(BuildContext context,String type,String id) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: CustomText(text: '   Select Date',colors: colorsConst.secondary,isBold: true,),
  //         content: SizedBox(
  //           height: 300, // Adjust height as needed
  //           width: 300, // Adjust width as needed
  //           child: SfDateRangePicker(
  //             minDate: DateTime.now().subtract(const Duration(days: 365)),
  //             maxDate: DateTime.now(),
  //             onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
  //               selectedDate = args.value;
  //               _startDate="";
  //               _endDate="";
  //               if(selectedDate?.endDate!=null){
  //                 _startDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
  //                     "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
  //                     "-${selectedDate?.startDate?.year.toString()}";
  //
  //                 _endDate="${selectedDate?.endDate?.day.toString().padLeft(2,"0")}"
  //                     "-${selectedDate?.endDate?.month.toString().padLeft(2,"0")}"
  //                     "-${selectedDate?.endDate?.year.toString()}";
  //               }else{
  //                 _startDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
  //                     "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
  //                     "-${selectedDate?.startDate?.year.toString()}";
  //               }
  //             },
  //             selectionMode: DateRangePickerSelectionMode.range,
  //           ),
  //         ),
  //         actions: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               CustomText(text: 'Click and drag to select multiple dates',colors: colorsConst.primary,),
  //             ],
  //           ),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               TextButton(
  //                 child: const CustomText(text:'Cancel',colors: Colors.grey,isBold: true,),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //               TextButton(
  //                 child: CustomText(text: 'OK',colors: colorsConst.primary,isBold: true,),
  //                 onPressed: () {
  //                   if (selectedDate != null) {
  //                     datesBetween = getDatesInRange(
  //                       selectedDate!.startDate!,
  //                       selectedDate!.endDate ?? selectedDate!.startDate!,
  //                     );
  //                   }
  //                   DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  //
  //                   List<String> formattedDates = datesBetween.map((date) => dateFormat.format(date)).toList();
  //                   betweenDates = formattedDates.join(' || ');
  //                   if(type=="1"){
  //                     getCountWiseReport(id);
  //                   }else{
  //                     getReport(id);
  //                   }
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //             ],
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //   notifyListeners();
  // }
  void showDatePickerDialog(BuildContext context,String type,String id) {
    DateTime dateTime=DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(1920),
      lastDate: DateTime(3000),
    ).then((value) {
      dateTime=value!;
      _startDate= ("${(dateTime.day.toString().padLeft(2,"0"))}-"
          "${(dateTime.month.toString().padLeft(2,"0"))}-"
          "${(dateTime.year.toString())}");
      _endDate= ("${(dateTime.day.toString().padLeft(2,"0"))}-"
          "${(dateTime.month.toString().padLeft(2,"0"))}-"
          "${(dateTime.year.toString())}");
      // DateTime endDateTime = dateTime.add(const Duration(days: 1));
      // _endDate = "${endDateTime.day.toString().padLeft(2, "0")}-"
      //     "${endDateTime.month.toString().padLeft(2, "0")}-"
      //     "${endDateTime.year.toString()}";
      if(_startDate=="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}"){
        _decrease=true;
        _increase=false;
      }
      if(type=="1"){
        getCountWiseReport(id);
      }else if(type=="visit"){
        getVisitReport();
      }else{
        getReport(id);
      }
      notifyListeners();
    });
  }
  void initVisitReport(String date1,String date2,String type,){
    search.clear();
    stDt = DateTime.now();
    enDt = DateTime.now().add(const Duration(days: 1));
    _startDate = date1;
    _endDate = date2;
    _repType=type;
    _dailyType=null;
    typeValue="";
    _userName="";
    _user="";
    notifyListeners();
  }
void manageFilter(value){
    _filter=value;
    notifyListeners();
}
  bool _filter=false;
  bool get filter=>_filter;
  dynamic _filterType;
  String get filterType =>_filterType;
  void initFilterValue(bool isClear){
    _filter=false;
    search.clear();
    if(isClear==false){
      _filter=true;
    }else{
      _filter=false;
      daily();
      _filterType="Today";
      _filterCustomerData=_customerData;
    }
    initDate();
    notifyListeners();
  }
  void changeFilterType(dynamic value){
    _filterType = value;
    if(_filterType=="Today"){
      daily();
    }else if(_filterType=="Yesterday"){
      yesterday();
    }else if(_filterType=="Last 7 Days"){
      last7Days();
    }else if(_filterType=="Last 30 Days"){
      last30Days();
    }else if(_filterType=="This Week"){
      thisWeek();
    }else if(_filterType=="This Month"){
      thisMonth();
    }else if(_filterType=="Last 3 months"){
      last3Month();
    }
    notifyListeners();
  }
  // void filterList(){
  //   _filter=true;
  //   _filterCustomerData = _searchCustomerDate.where((contact){
  //     final empProviderDate1 = _startDate; // Start Date
  //     final empProviderDate2 = _endDate; // End Date
  //     final dateFormat = DateFormat('dd-MM-yyyy');
  //
  //     DateTime  createdTsDate = DateTime.parse(contact.createdTs.toString());
  //     final parsedDate1 = dateFormat.tryParse(empProviderDate1);
  //     final parsedDate2 = dateFormat.tryParse(empProviderDate2);
  //     print("Dates...... ${_startDate}-${_endDate}");
  //     print("Created ts......${contact.createdTs.toString()}");
  //     bool isWithinDateRange =
  //         createdTsDate.isAfter(parsedDate1!.subtract(const Duration(days: 1))) &&
  //             createdTsDate.isBefore(parsedDate2!.add(const Duration(days: 1)));
  //     return isWithinDateRange;
  //   }).toList();
  //   // print("//// ${_startDate}");
  //   // print("//// ${_endDate}");
  //   // print("//// ${_filterCustomerData.length}");
  //   notifyListeners();
  // }

  void filterList() {
    _filter = true;
    final dateFormat = DateFormat('dd-MM-yyyy');
    final parsedDate1 = dateFormat.parse(_startDate);
    final parsedDate2 = dateFormat.parse(_endDate);

    _filterCustomerData = _searchCustomerDate.where((contact) {
      final createdTsDate = DateTime.parse(contact.createdTs.toString());
      final createdDateOnly = DateTime(createdTsDate.year, createdTsDate.month, createdTsDate.day);
      // print("Dates...... ${_startDate}-${_endDate}");
      // print("Created ts......${contact.createdTs.toString()}");
      return !createdDateOnly.isBefore(parsedDate1) && !createdDateOnly.isAfter(parsedDate2);
    }).toList();

    notifyListeners();
  }



  void datePick({required BuildContext context, required String date, required bool isStartDate}) {
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
      context: context,
      initialDate: initDate,
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
  var filterTypeList = ["Today","Yesterday","Last 7 Days","Last 30 Days","This Week","This Month","Last 3 months"];
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
  // void last3Month() {
  //   DateTime now = DateTime.now();
  //   DateTime stDt = DateTime(now.year, now.month - 3, 1);
  //   DateTime enDt = DateTime(now.year, now.month, 0);
  //   _startDate = DateFormat('dd-MM-yyyy').format(stDt);
  //   _endDate = DateFormat('dd-MM-yyyy').format(enDt);
  //   notifyListeners();
  // }
  void last3Month() {
    DateTime now = DateTime.now(); // Today: e.g. 13 June 2025
    DateTime stDt = DateTime(now.year, now.month - 2, now.day); // 13 April 2025
    DateTime enDt = now; // 13 June 2025

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
  List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    List<DateTime> days = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(DateTime(start.year, start.month, start.day + i));
    }
    return days;
  }

  bool _decrease=false;
  bool _increase=false;
  bool get increase=>_increase;
  bool get decrease=>_decrease;

  void incrementDates(String id,String type) {
    if(startDate=="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}"){

    }else{
      stDt = stDt.add(const Duration(days: 1));
      enDt = enDt.add(const Duration(days: 1));
      _startDate = DateFormat('dd-MM-yyyy').format(stDt);
      _endDate = DateFormat('dd-MM-yyyy').format(enDt);
      _increase=true;
      _decrease=false;
      if(_startDate=="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}"){
        _decrease=true;
        _increase=false;
      }
      if(type=="1"){
        getReport(id);
      }else{
        if({"1"}.contains(localData.storage.read("role"))){
          getAllTrack();
        }else{
          getTrackReport(localData.storage.read("id"),false);
        }
      }
    }
    notifyListeners();
  }

  void decrementDates(String id,String type) {
    stDt = stDt.subtract(const Duration(days: 1));
    enDt = enDt.subtract(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    _decrease=true;
    _increase=false;
    if(type=="1"){
      getReport(id);
    }else{
      if({"1"}.contains(localData.storage.read("role"))){
        getAllTrack();
      }else{
        getTrackReport(localData.storage.read("id"),false);
      }
    }
    notifyListeners();
  }
  Future<void> trackingInsert(String unitId,bool isToast,String lat,String lng) async {
    Map data = {
      "action":insertTrack,
      "emp_id":localData.storage.read("id"),
      "date":"${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}",
      "unit_id":unitId,
      "unit_name":localData.storage.read("TrackUnitName"),
      "status":localData.storage.read("TrackStatus"),
      "shift":localData.storage.read("T_Shift"),
      "lat":lat,
      "lng":lng
    };
    final response =await custRepo.insertTracking(data);
    log(response.toString());
    if (response.isNotEmpty){
      if(localData.storage.read("TrackStatus").toString()=="2"){
        localData.storage.write("TrackStatus","1");
        localData.storage.write("TrackId","0");
        localData.storage.write("TrackUnitName", "null");
        localData.storage.write("TrackUnitShift", "null");
      }
    }else {
    }
    notifyListeners();
  }
  Future<void> actionTracking(context,String action) async {
    Map data = {
      "action":trackingStatus,
      "user_id":localData.storage.read("id"),
      "log_file":localData.storage.read("mobile_number"),
      "track_on":action
    };
    final response =await custRepo.manageTracking(data);
    log(response.toString());
    if (response.isNotEmpty){
    }else {
      utils.showWarningToast(text: "Failed",Get.context);
    }
    notifyListeners();
  }
  Future<void> insertTrackList(RxList dataList) async {

    // try {
    // print("dataList.length");
    // print(dataList.length);
    final Map<String, dynamic> sendData = {
      'action': trackListInsert,
      'empList': dataList
    };
    final response = await http.post(
      Uri.parse(phpFile),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(sendData),
    );
    // print("response.body");
    // print(response.body);
    // print(dataList);
    if (response.statusCode == 200) {
      // utils.toast(context: context,text:"Attendance Marked Successful",color: Colors.green);
      // groupRefresh();
      // fieldRefresh();
      // Get.back();
    } else {
      // utils.toast(context: context,text:"Failed",color: Colors.red);
    }
    // } catch (e) {
    //   // utils.toast(context: context,text:"Failed",color: Colors.red);
    //   // controller.ispresent.reset();
    // }
  }
  List _allData = [];
  List get allData => _allData;
  Future<void> getAllTrack() async {
    try {
      _allData.clear();
      _refresh=false;
      notifyListeners();
      DateTime nextDay = stDt.add(const Duration(days: 1));
      String formattedNextDay = DateFormat('dd-MM-yyyy').format(nextDay);
      Map data = {
        "action": getAllData,
        "search_type":"all_track",
        "st":_startDate,
        "en":formattedNextDay,
        "cos_id":localData.storage.read("cos_id")
      };
      final response =await custRepo.getDashboardReport(data);
      // print(data.toString());
      // print(response);
      if (response.isNotEmpty) {
        _allData=response;
        _refresh=true;
      }else{
        _refresh=true;
      }
    } catch (e) {
      _refresh=true;
    }
    notifyListeners();
  }
List<TrackingModel> _reportData = <TrackingModel>[];
List<TrackingModel> get reportData => _reportData;
Future<void> getTrackReport(String id,bool isMonthly) async {
    _reportData.clear();
    _refresh=false;
    notifyListeners();
    DateTime nextDay = stDt.add(const Duration(days: 1));
    String formattedNextDay = DateFormat('dd-MM-yyyy').format(nextDay);
    try {
      Map data = {
        "action": getAllData,
        "search_type":"easy_track",
        "id":id,
        "st":_startDate,
        "en":formattedNextDay,
        "cos_id":localData.storage.read("cos_id")
      };
      final response =await custRepo.trackList(data);
      log(data.toString());
      if (response.isNotEmpty) {
        _reportData=response;
        _refresh=true;
      } else {
        _refresh=true;
      }
    } catch (e) {
      _refresh=true;
    }
    notifyListeners();
}

final List<Marker> _liveMarker =[];
List<Marker> get liveMarker =>_liveMarker;
  Future<BitmapDescriptor> createCustomMarkerFromNetwork(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      // Load default asset image if URL is null or empty
      ByteData data = await rootBundle.load('assets/images/map_track.png'); // Ensure asset exists
      Uint8List defaultImage = data.buffer.asUint8List();
      return BitmapDescriptor.fromBytes(defaultImage);
    }

    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception("Invalid response code: ${response.statusCode}");
      }

      final Uint8List imageBytes = response.bodyBytes;
      final ui.Codec codec = await ui.instantiateImageCodec(imageBytes, targetWidth: 100);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      final Paint pinPaint = Paint()..color = Colors.green;
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 100, 120), const Radius.circular(50)),
        pinPaint,
      );

      final Path circlePath = Path()
        ..addOval(Rect.fromCircle(center: const Offset(50, 40), radius: 30));
      canvas.clipPath(circlePath);
      canvas.drawImage(image, const Offset(20, 10), Paint()..isAntiAlias = true);

      final ui.Picture picture = recorder.endRecording();
      final ui.Image finalImage = await picture.toImage(100, 120);
      final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    } catch (e) {
      // print("Error loading network image: $e");
      // Load the default asset image if network fails
      ByteData data = await rootBundle.load("assets/images/map_track.png");
      Uint8List defaultImage = data.buffer.asUint8List();
      return BitmapDescriptor.fromBytes(defaultImage);
    }
  }

  Future<void> getLiveTrack() async {
    _liveMarker.clear();
    _refresh=false;
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type":"live_track",
        "cos_id":localData.storage.read("cos_id")
      };
      final response =await custRepo.liveTrack(data);
      log(data.toString());
      log(response.toString());
      final  List dataList= response;
      if (response.isNotEmpty) {
        for (var i = 0; i < dataList.length; i++) {
          DateTime dateTime = DateTime.parse(dataList[i]["created_ts"]);
          List<Placemark> placeMark = await placemarkFromCoordinates(
            double.parse(dataList[i]["lat"]),
            double.parse(dataList[i]["lng"]),
          );
          Placemark area = placeMark[0];

          BitmapDescriptor markerIcon = await createCustomMarkerFromNetwork(dataList[i]["image"] ?? "");
          // print(dataList);
          _liveMarker.add(
            Marker(
              markerId: MarkerId(dataList[i]["id"].toString()),
              position: LatLng(
                double.parse(dataList[i]["lat"]),
                double.parse(dataList[i]["lng"]),
              ),
              icon: markerIcon,
              infoWindow: InfoWindow(
                title: dataList[i]["firstname"],
                snippet:
                "${dataList[i]["unit_name"] == "null" ? "" : "( ${dataList[i]["unit_name"]} ) "}${area.subLocality}-${DateFormat('HH:mm:ss').format(dateTime)}",
              ),
            ),
          );
        }
        log("_liveMarker");
        log(_liveMarker.toString());
        _refresh=true;
        notifyListeners();
      } else {
        _refresh=true;
      }
    } catch (e) {
      _refresh=true;
    }
    notifyListeners();
}


  String crtDate(String dateTimeString, String type) {
    var parts = dateTimeString.split(' ');
    var dateParts = parts[0].split('-'); // Split the date into year, month, and day
    var formattedDate = "${dateParts[2]}/${dateParts[1]}/${dateParts[0]}"; // Reorder to dd-MM-yyyy

    var timeParts = parts[1].split(':');
    int hour = int.parse(timeParts[0]);
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12 == 0 ? 12 : hour % 12;

    if (type == "1") {
      return formattedDate;
    } else {
      return "$hour:${timeParts[1]} $period";
    }
  }
  String timeDifference (String dateTimeString1,String dateTimeString2) {
    DateTime startTime = DateTime.parse(dateTimeString1);
    DateTime endTime = DateTime.parse(dateTimeString2);

    Duration difference = endTime.difference(startTime);

    return "${difference.inHours} Hrs ${difference.inMinutes} Mins";
  }
  List<Map<String, dynamic>> _selectedFiles = [];

  List<Map<String, dynamic>> get selectedFiles => _selectedFiles;

  List<String> _selectedPhotos = [];

  List<String> get selectedPhotos => _selectedPhotos;

  final ImagePicker picker = ImagePicker();

  Future<void> pickFile() async {

    final List<XFile> files = await picker.pickMultiImage();

    if (files.isNotEmpty) {
      for (XFile file in files) {
        final int fileSizeBytes = File(file.path).lengthSync();
        final String formattedSize = formatFileSize(fileSizeBytes);

        _selectedFiles.add({
          'name': file.name,
          'size': formattedSize,
          'path': file.path,
        });
      }

      notifyListeners();
    }
  }
  Future<void> pickCamera(BuildContext context) async {
      var imgData = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const CameraWidget(
                cameraPosition: CameraType.back,
              )));
      _selectedPhotos.add(imgData);
      notifyListeners();
  }
  String formatFileSize(int bytes) {
    double kb = bytes / 1024;
    if (kb < 1024) {
      return "${kb.toStringAsFixed(2)} KB";
    } else {
      double mb = kb / 1024;
      return "${mb.toStringAsFixed(2)} MB";
    }
  }
  void removePhotos(int index) {
    _selectedPhotos.removeAt(index);
    notifyListeners();
  }
  void removeFile(int index) {
    _selectedFiles.removeAt(index);
    notifyListeners();
  }
  void removeAudio(int index) {
    _recordedAudioPaths.removeAt(index);
    notifyListeners();
  }

  List<AddAudioModel> _recordedAudioPaths = [];

  List<AddAudioModel> get recordedAudioPaths => _recordedAudioPaths;
  final AudioRecorder record = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();

  double _recordingDuration  = 0.0;
  double get recordingDuration =>_recordingDuration;
  bool _isRecording  = false;
  bool _isPlaying  = false;
  bool get isRecording =>_isRecording;
  bool get isPlaying =>_isPlaying;

  Duration _position = Duration.zero;
  Duration? _duration;

  Duration get position => _position;
  Duration? get duration => _duration;

  Timer? timer;
  late DateTime _startTime;
  final AudioRecorder _record = AudioRecorder();

  // Future<void> startRecording() async {
  //   HapticFeedback.heavyImpact();
  //   // if (await Vibration.hasVibrator()) {
  //   //   Vibration.vibrate(duration: 500);  // Vibrates for 500ms
  //   // }
  //   try {
  //     if (await record.hasPermission()) {
  //       final dir = await getApplicationDocumentsDirectory();
  //       String path = "${dir.path}/recorded_audio_${DateTime.now().millisecondsSinceEpoch}.m4a";
  //       await record.start(const RecordConfig(), path: path);
  //
  //       _isRecording = true;
  //       _startTime = DateTime.now(); // Capture start time
  //       _recordingDuration = 0.0;
  //
  //       timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
  //         final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
  //         _recordingDuration = elapsed / 1000; // Convert to seconds
  //       });
  //       loadAudioDuration(path);
  //     }
  //   } catch (e) {
  //     log("Error in startRecording: $e");
  //   }
  // }
  String _recordingTime = "";
  String formatDurationTime(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    return formatTime(hours: hours,minutes: minutes,seconds: secs);
  }
  String formatTime({
    required int hours,
    required int minutes,
    required int seconds,
  }) {
    if (hours > 0) {
      // hours irundha → h.m.s
      return "$hours.$minutes.$seconds";
    } else if (minutes > 0) {
      // minutes irundha → m.s
      return "$minutes.$seconds";
    } else {
      // only seconds → 0.s
      return "0.$seconds";
    }
  }
  Future<void> startRecording() async {
    if (_isRecording) return; // Prevent duplicate starts

    HapticFeedback.heavyImpact();

    try {
      if (await _record.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        String path =
            "${dir.path}/recorded_audio_${DateTime.now().millisecondsSinceEpoch}.m4a";

        await _record.start(const RecordConfig(), path: path);

        _isRecording = true;
        _startTime = DateTime.now();
        _recordingDuration = 0.0;
        _recordingTime ="";

        timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
          _recordingTime = formatDurationTime(elapsed);
          _recordingDuration = elapsed / 1000;
          notifyListeners();
        });

        notifyListeners();
      }
    } catch (e) {
      log("Error in startRecording: $e");
    }
  }

  /// Stop Recording
  // Future<void> stopRecording() async {
  //   try {
  //     final path = await record.stop();
  //     if (path != null) {
  //       _recordedAudioPaths.add(
  //           AddAudioModel(audioPath: path, second: _recordingDuration));
  //     }
  //     _isRecording = false;
  //     timer?.cancel();
  //     // print("_recordedAudioPaths: ${_recordedAudioPaths.last.second}");
  //   } catch (e) {
  //     // print("Error in stopRecording: $e");
  //   }
  // }
  Future<void> stopRecording() async {
    if (!_isRecording) return; // Prevent stop if not recording

    try {
      final path = await _record.stop();

      if (path != null) {
        _isRecording = false;
        timer?.cancel();
        if(_recordedAudioPaths.isEmpty){
          _recordedAudioPaths.add(
            AddAudioModel(audioPath: path, second: _recordingDuration, time: _recordingTime),
          );
        }else{
          _recordedAudioPaths[0]=
              AddAudioModel(audioPath: path, second: _recordingDuration, time: _recordingTime);
        }

print("_recordedAudioPaths");
print(_recordedAudioPaths);
        await Future.delayed(Duration(seconds: 1)); // Optional delay
        loadAudioDuration(path);
      }
    } catch (e) {
      log("Error in stopRecording: $e");
    }

    notifyListeners();
  }

  Future<void> loadAudioDuration(String url) async {
    try {
      await audioPlayer.setSourceUrl(url);
      Duration? fetchedDuration = await audioPlayer.getDuration();
      if (fetchedDuration != null) {
        _duration = fetchedDuration;
        // print("Duration $duration");
      }
    } catch (e) {
      // print("Error fetching duration: $e");
    }
  }

  Future<void> playPauseAudio(String path,int index) async {
    try {
      if (_isPlaying) {
        // print("Pausing audio");
        stopAudio();
      } else {
        playAudio(path,index);
      }

      _isPlaying = !_isPlaying;
    } catch (e) {
      // print("Error in playPauseAudio: $e");
    }
  }

  Future<void> playAudio(String audioPath, int index) async {
    if (audioPath.isNotEmpty) {
      // Reset all to false
      for (var i = 0; i < _recordedAudioPaths.length; i++) {
        _recordedAudioPaths[i].play = false;
      }

      _isPlaying = true;
      _recordedAudioPaths[index].play = true;
      notifyListeners();

      // Remove old subscriptions
      audioPlayer.onDurationChanged.listen(null);
      audioPlayer.onPositionChanged.listen(null);
      audioPlayer.onPlayerComplete.listen(null);

      audioPlayer.onDurationChanged.listen((durationV) {
        _recordedAudioPaths[index].duration = durationV;
        notifyListeners();
      });

      audioPlayer.onPositionChanged.listen((positionV) {
        _recordedAudioPaths[index].position = positionV;
        notifyListeners();
      });

      audioPlayer.onPlayerComplete.listen((event) {
        _isPlaying = false;
        _recordedAudioPaths[index].position = Duration.zero;
        _recordedAudioPaths[index].play = false;
        notifyListeners();
      });

      try {
        await audioPlayer.play(DeviceFileSource(audioPath));
      } catch (e) {
        _isPlaying = false;
        _recordedAudioPaths[index].play = false;
        notifyListeners();
      }
    }
  }

  bool isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && (uri.hasScheme && uri.hasAuthority);
  }

  String formatDuration(Duration d) {
    String minutes = d.inMinutes.toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  /// Stop Audio Playback
  Future<void> stopAudio() async {
    await audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }
  void shareCustomerDetails(CustomerModel datas) {
    // Function to handle "null" and empty values
    String sanitize(String? value) {
      return (value == null || value.trim().toLowerCase() == "null") ? "" : value.trim();
    }

    // Build company details dynamically
    String companyDetails = "Company Details\n\nCompany Name: ${sanitize(datas.companyName)}";

    // Build address only if there are non-empty values
    List<String> addressParts = [
      sanitize(datas.doorNo),
      sanitize(datas.area),
      sanitize(datas.city),
      sanitize(datas.state),
      sanitize(datas.country),
      sanitize(datas.pincode)
    ];
    String address = addressParts.where((part) => part.isNotEmpty).join(", ");
    if (address.isNotEmpty) companyDetails += "\nAddress: $address";

    // Process multiple customers
    List<String> customerNames = sanitize(datas.firstName).split("||");
    List<String> phoneNumbers = sanitize(datas.phoneNumber).split("||");
    List<String> mobileNumbers = sanitize(datas.mobileNumber).split("||");
    List<String> emails = sanitize(datas.emailId).split("||");
    List<String> designations = sanitize(datas.designation).split("||");
    List<String> departments = sanitize(datas.department).split("||");

    List<String> customerDetailsList = [];
    for (int i = 0; i < customerNames.length; i++) {
      List<String> customerInfo = [];

      if (sanitize(customerNames[i]).isNotEmpty) customerInfo.add("Customer Name: ${sanitize(customerNames[i])}");
      if (i < phoneNumbers.length && sanitize(phoneNumbers[i]).isNotEmpty) customerInfo.add("Phone: ${sanitize(phoneNumbers[i])}");
      if (i < mobileNumbers.length && sanitize(mobileNumbers[i]).isNotEmpty) customerInfo.add("Mobile: ${sanitize(mobileNumbers[i])}");
      if (i < emails.length && sanitize(emails[i]).isNotEmpty) customerInfo.add("Email: ${sanitize(emails[i])}");
      if (i < designations.length && sanitize(designations[i]).isNotEmpty) customerInfo.add("Designation: ${sanitize(designations[i])}");
      if (i < departments.length && sanitize(departments[i]).isNotEmpty) customerInfo.add("Department: ${sanitize(departments[i])}");

      if (customerInfo.isNotEmpty) {
        customerDetailsList.add("Customer ${i + 1} Details\n\n${customerInfo.join("\n")}");
      }
    }

    // Build observations only if they have values
    List<String> observationInfo = [];
    if (sanitize(datas.leadStatus).isNotEmpty) observationInfo.add("Lead Status: ${sanitize(datas.leadStatus)}");
    if (sanitize(datas.visitType).isNotEmpty) observationInfo.add("Visit Type: ${sanitize(datas.visitType)}");
    if (sanitize(datas.discussionPoint).isNotEmpty) observationInfo.add("Discussion Points: ${sanitize(datas.discussionPoint)}");
    if (sanitize(datas.points).isNotEmpty) observationInfo.add("Additional Points: ${sanitize(datas.points)}");

    String addedBy = sanitize(datas.addedBy);
    String role = sanitize(datas.role);
    if (addedBy.isNotEmpty || role.isNotEmpty) {
      observationInfo.add("Added By: ${addedBy.isNotEmpty ? addedBy : ''} ${role.isNotEmpty ? '($role)' : ''}".trim());
    }

    String createdAt = sanitize(datas.createdTs.toString());
    if (createdAt.isNotEmpty) {
      observationInfo.add("Created At: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(createdAt))}");
    }

    String finalMessage = companyDetails;
    if (customerDetailsList.isNotEmpty) {
      finalMessage += "\n\n--------------------\n\n${customerDetailsList.join("\n\n--------------------\n\n")}";
    }
    if (observationInfo.isNotEmpty) {
      finalMessage += "\n\n--------------------\n\nObservations\n\n${observationInfo.join("\n")}";
    }

    Share.share(finalMessage);
  }

  dynamic _repType;
  dynamic get repType=>_repType;
  dynamic _dailyType="";
  dynamic typeValue="";
  dynamic get dailyType=>_dailyType;

  List<CustomerReportModel> _dailyVisitReport = <CustomerReportModel>[];
  List<CustomerReportModel> _searchDailyVisitReport = <CustomerReportModel>[];
  List<CustomerReportModel> get dailyVisitReport=>_dailyVisitReport;
  List<CustomerReportModel> get searchDailyVisitReport=>_searchDailyVisitReport;

  void changeDailyVisitType(value){
    _repType=value;
    if(_repType=="Today"){
      dailyVisit();
    }else if(_repType=="Yesterday"){
      yesterdayVisit();
    }else if(_repType=="Last 7 Days"){
      last7DaysVisit();
    }else if(_repType=="Last 30 Days"){
      last30DaysVisit();
    }else if(_repType=="This Week"){
      thisWeekVisit();
    }else if(_repType=="This Month"){
      thisMonthVisit();
    }else if(_repType=="Last 3 months"){
      last3MonthVisit();
    }else{

    }
    notifyListeners();
  }
  dynamic _user;
  dynamic get user=>_user;
  String _userName="";
  String get userName=>_userName;
  void selectUser(UserModel value){
    _user=value.id;
    _userName=value.firstname.toString();
    // filterList(true);
    notifyListeners();
  }
  void dailyVisit() {
    stDt=DateTime.now();
    enDt=DateTime.now();
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    getVisitReport();
    getEmpWiseReport();
    notifyListeners();
  }
  void yesterdayVisit() {
    stDt=DateTime.now().subtract(const Duration(days: 1));
    enDt=DateTime.now().subtract(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    getVisitReport();
    getEmpWiseReport();
    notifyListeners();
  }
  void last7DaysVisit() {
    DateTime now = DateTime.now();
    DateTime lastWeekStart = now.subtract(const Duration(days: 6));
    DateTime lastWeekEnd = now.add(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(lastWeekStart);
    _endDate = DateFormat('dd-MM-yyyy').format(lastWeekEnd);
    getVisitReport();
    getEmpWiseReport();
    notifyListeners();
  }
  void last30DaysVisit() {
    DateTime now = DateTime.now();
    DateTime lastMonthStart = now.subtract(const Duration(days: 30));
    DateTime lastMonthEnd = now.add(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(lastMonthStart);
    _endDate = DateFormat('dd-MM-yyyy').format(lastMonthEnd);
    getVisitReport();
    getEmpWiseReport();
    notifyListeners();
  }
  void thisWeekVisit() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime stDt = now.subtract(Duration(days: currentWeekday - 1));
    DateTime enDt = now.add(Duration(days: 7 - currentWeekday));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    getVisitReport();
    getEmpWiseReport();
    notifyListeners();
  }
  void thisMonthVisit() {
    DateTime now = DateTime.now();
    stDt = DateTime(now.year, now.month, 1);
    enDt = DateTime(now.year, now.month + 1, 0);
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    getVisitReport();
    getEmpWiseReport();
    notifyListeners();
  }
  void last3MonthVisit() {
    DateTime now = DateTime.now();
    DateTime stDt = DateTime(now.year, now.month - 3, 1);
    DateTime enDt = DateTime(now.year, now.month, 0);
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    getVisitReport();
    getEmpWiseReport();
    notifyListeners();
  }
  void lastMonthVisit() {
    DateTime now = DateTime.now();
    stDt = DateTime(now.year, now.month, 1);
    enDt = DateTime(now.year, now.month + 1, 0);
    stDt = DateTime(stDt.year, stDt.month - 1, 1);
    enDt = DateTime(enDt.year, enDt.month - 1, 1);
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(DateTime(enDt.year, enDt.month + 1, 0));
    getVisitReport();
    getEmpWiseReport();
    notifyListeners();
  }

  // Future<void> getVisitReport() async {
  //   _refresh=false;
  //   _dailyVisitReport.clear();
  //   _searchDailyVisitReport.clear();
  //   notifyListeners();
  //   // try {
  //     Map data = {
  //       "action": getAllData,
  //       "search_type":"Today_visits",
  //       "id":localData.storage.read("id"),
  //       "role":localData.storage.read("role"),
  //       "cos_id": localData.storage.read("cos_id"),
  //       "date1": _startDate,
  //       "date2": _endDate
  //     };
  //     final response =await custRepo.getComments(data);
  //     log(data.toString());
  //     log(response.toString());
  //     if (response.isNotEmpty) {
  //       List<CustomerReportModel> filteredList = response;
  //
  //       // ✅ Type Filter
  //       if (_dailyType != null && _dailyType.toString().isNotEmpty) {
  //         filteredList = filteredList.where((item) {
  //           return item.typeNo.toString() == typeValue.toString();
  //         }).toList();
  //       }
  //
  //       // ✅ User Filter
  //       if (_userName != "" && _userName.toString().isNotEmpty) {
  //         filteredList = filteredList.where((item) {
  //           return item.createdBy.toString() == _user.toString();
  //         }).toList();
  //       }
  //
  //       // ✅ Final assign
  //       _dailyVisitReport = filteredList;
  //       _searchDailyVisitReport = filteredList;
  //       _refresh=true;
  //     } else {
  //       _refresh=true;
  //     }
  //   // } catch (e) {
  //   //   _refresh=true;
  //   // }
  //   notifyListeners();
  // }
  Future<void> getVisitReport() async {
    try {
      _refresh = false;
      _dailyVisitReport.clear();
      _searchDailyVisitReport.clear();
      notifyListeners();

      Map data = {
        "action": getAllData,
        "search_type": "Today_visits",
        "id": localData.storage.read("id"),
        "role": localData.storage.read("role"),
        "cos_id": localData.storage.read("cos_id"),
        "date1": _startDate,
        "date2": _endDate
      };

      log("REQUEST DATA => $data");

      final response = await custRepo.getComments(data);

      log("API RESPONSE COUNT => ${response.length}");

      if (response.isNotEmpty) {
        List<CustomerReportModel> filteredList = response;

        log("SELECTED TYPE => $_dailyType");
        log("TYPE VALUE => $typeValue");

        log("SELECTED USERNAME => $_userName");
        log("SELECTED USER ID => $_user");

        // ✅ TYPE FILTER
        if (_dailyType != null) {
          filteredList = filteredList.where((item) {
            log("CHECK TYPE => API:${item.typeNo}  DROPDOWN:$typeValue");

            return item.typeNo.toString() == typeValue.toString();
          }).toList();

          log("AFTER TYPE FILTER COUNT => ${filteredList.length}");
        }

        // ✅ USER FILTER
        if (_userName != "") {
          filteredList = filteredList.where((item) {
            log("CHECK USER => API:${item.createdBy}  DROPDOWN:$_user");

            return item.firstname.toString() == _userName.toString();
          }).toList();

          log("AFTER USER FILTER COUNT => ${filteredList.length}");
        }

        // ✅ FINAL RESULT
        _dailyVisitReport = filteredList;
        _searchDailyVisitReport = filteredList;

        log("FINAL LIST COUNT => ${_dailyVisitReport.length}");

        _refresh = true;
      } else {
        log("API RESPONSE EMPTY");
        _refresh = true;
      }
    }catch(e){
      log("API RESPONSE EMPTY");
      _refresh = true;
    }
    notifyListeners();
  }
  List _empWiseCount=[];
  List get empWiseCount => _empWiseCount;
  Future<void> getEmpWiseReport() async {
    _refresh=false;
    _empWiseCount.clear();
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type": "emp_visit_report",
        "id": localData.storage.read("id"),
        "role": localData.storage.read("role"),
        "cos_id": localData.storage.read("cos_id"),
        "date1": _startDate,
        "date2": _endDate
      };
      final response =await custRepo.getDashboardReport(data);
      if (response.isNotEmpty) {
        _empWiseCount=response;
        _refresh=true;
      }else{
        _refresh=true;
      }
    } catch (e) {
      _refresh=true;
    }
    notifyListeners();
  }
  Future<void> getVisitHoursReport(context) async {
    try {
      Map data = {
        "action": getAllData,
        "search_type": "visit_hours_report",
        "id": localData.storage.read("id"),
        "role": localData.storage.read("role"),
        "cos_id": localData.storage.read("cos_id"),
        "date1": _startDate,
        "date2": _endDate
      };
      final response =await custRepo.getDashboardReport(data);
      if (response.isNotEmpty) {
        reportExport(context,response);
      }else{
        utils.showWarningToast(context,text: "No data found");
        addCtr.reset();
      }
    } catch (e) {
      utils.showWarningToast(context,text: "No data found");
      addCtr.reset();
    }
    notifyListeners();
  }
  Future<void> reportExport(BuildContext context,List list)async{
    try{
      addCtr.reset();
      final Workbook workbook =Workbook();
      final Worksheet worksheet=workbook.worksheets[0];
      worksheet.getRangeByName('A1:D1').merge();
      worksheet.getRangeByName('A1:D1').cellStyle.hAlign= HAlignType.center;
      worksheet.getRangeByName('A2:D2').cellStyle.hAlign= HAlignType.center;
      worksheet.getRangeByName('A1').cellStyle.bold = true;worksheet.getRangeByName('A1').cellStyle.fontSize = 10;
      worksheet.getRangeByName('A2:D2').cellStyle.bold = true;worksheet.getRangeByName('A2:D2').cellStyle.fontSize = 10;
      worksheet.getRangeByName('A2:D2').columnWidth =10;
      worksheet.getRangeByName('A2:D2').cellStyle.backColor='#CA1617';
      worksheet.getRangeByName('A2:D2').cellStyle.fontColor='#ffffff';
      worksheet.getRangeByName("A1").setText("Visit Report - $_startDate ${_startDate==_endDate?"":" To $_endDate"}");
      worksheet.getRangeByName("A2").setText("Name");
      worksheet.getRangeByName("B2").setText("Working Hours");
      worksheet.getRangeByName("C2").setText("Leaving Hours");
      worksheet.getRangeByName("D2").setText("Visit Count");
      for(var i=0;i<list.length;i++){
        worksheet.getRangeByIndex(i+3,1).setText(list[i]["firstname"]);
        // worksheet.getRangeByIndex(i+3,2).setText(list[i]["total_working_hours"]);
        worksheet.getRangeByIndex(i+3, 2)
            .setText("${double.parse(list[i]["total_working_hours"]).round()} Hours");
        // worksheet.getRangeByIndex(i+3,2).setText("${int.parse(list[i]["total_working_hours"].toString()}"));
        worksheet.getRangeByIndex(i+3,3).setText(list[i]["leave_hours"]);
        worksheet.getRangeByIndex(i+3,4).setText(list[i]["visit_count"]);
      }
      final List<int> bytes =workbook.saveAsStream();
      if(kIsWeb){
        AnchorElement(href: 'data:application/octet-stream;charset-utf-161e;base64,${base64.encode(bytes)}')
          ..setAttribute('download', '${constValue.appName} report.xlsx')
          ..click();
      }else{
        final String path=(await getApplicationSupportDirectory()).path;
        final String filename='$path/Visit Report - $_startDate ${_startDate==_endDate?"":" To $_endDate"}.xlsx';
        final File file=File(filename);
        await file.writeAsBytes(bytes,flush: true);
        OpenFile.open(filename);
      }
    }catch(e){
      utils.showWarningToast(context,text: "No data found");
      addCtr.reset();
    }
  }

  // Future<void> downloadExcelReport(List dataList) async {
  //
  //   var excel = Excel.createExcel();
  //   Sheet sheet = excel['Report'];
  //
  //   /// --------- COLLECT HEADERS ----------
  //
  //   Set<String> typeSet = {};
  //   Set<String> empSet = {};
  //
  //   for (var item in dataList) {
  //     typeSet.add(item['value']);
  //     empSet.add(item['firstname']);
  //   }
  //
  //   List<String> types = typeSet.toList();
  //   List<String> employees = empSet.toList();
  //
  //   /// --------- HEADER ROW ----------
  //
  //   sheet
  //       .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
  //       .value = 'Employee Name';
  //
  //   for (int i = 0; i < types.length; i++) {
  //     sheet
  //         .cell(CellIndex.indexByColumnRow(columnIndex: i + 1, rowIndex: 0))
  //         .value = types[i];
  //   }
  //
  //   /// -------- DATA ----------
  //
  //   for (int i = 0; i < employees.length; i++) {
  //
  //     sheet
  //         .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
  //         .value = employees[i];
  //
  //     for (int j = 0; j < types.length; j++) {
  //
  //       String count = "0";
  //
  //       for (var item in dataList) {
  //         if (item['firstname'] == employees[i] &&
  //             item['value'] == types[j]) {
  //           count = item['total_count'];
  //         }
  //       }
  //
  //       sheet
  //           .cell(CellIndex.indexByColumnRow(columnIndex: j + 1, rowIndex: i + 1))
  //           .value = count;
  //     }
  //   }
  //
  //   final fileBytes = excel.encode()!;
  //
  //   /// ---------- PLATFORM CHECK ----------
  //
  //   if (kIsWeb) {
  //
  //     // /// 🌐 WEB DOWNLOAD
  //     //
  //     // final blob = html.Blob([fileBytes]);
  //     // final url = html.Url.createObjectUrlFromBlob(blob);
  //     //
  //     // html.AnchorElement(href: url)
  //     //   ..setAttribute("download", "activity_report.xlsx")
  //     //   ..click();
  //     //
  //     // html.Url.revokeObjectUrl(url);
  //
  //   } else {
  //
  //     /// 📱 MOBILE DOWNLOAD
  //
  //     final directory = await getExternalStorageDirectory();
  //
  //     String filePath = "${directory!.path}/activity_report.xlsx";
  //
  //     File(filePath)
  //       ..createSync(recursive: true)
  //       ..writeAsBytesSync(fileBytes);
  //
  //     /// Open Automatically
  //     OpenFile.open(filePath);
  //
  //     print("Saved Path => $filePath");
  //   }
  // }
  Future<void> downloadExcelReport(List dataList) async {

    if (dataList.isEmpty) {
      print("No Data Found");
      return;
    }

    var excel = Excel.createExcel();

    /// REMOVE DEFAULT SHEET
    excel.delete('Sheet1');

    /// CREATE REPORT SHEET
    String sheetName = "Report";
    Sheet sheet = excel[sheetName];

    /// SET FIRST TAB
    excel.setDefaultSheet(sheetName);

    /// ---------------- GET UNIQUE HEADERS ----------------

    Set<String> typeSet = {};
    Set<String> empSet = {};

    for (var item in dataList) {
      typeSet.add(item['value'].toString());
      empSet.add(item['firstname'].toString());
    }

    List<String> types = typeSet.toList();
    List<String> employees = empSet.toList();

    int totalColumns = types.length + 1;

    /// ---------------- TITLE ROW ----------------

    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: totalColumns - 1, rowIndex: 0),
    );

    var titleCell =
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));

    titleCell.value = "Visit Report - $_startDate${_startDate==_endDate?"":" To $_endDate"}";

    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Center,
    );

    /// ---------------- HEADER STYLE ----------------

    CellStyle headerStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: "#E0E0E0",
      horizontalAlign: HorizontalAlign.Center,
    );

    CellStyle typeStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: "#A7C7E7",
      horizontalAlign: HorizontalAlign.Center,
    );

    /// ---------------- HEADER ROW ----------------

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
        .value = "Employee Name";

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
        .cellStyle = headerStyle;

    for (int i = 0; i < types.length; i++) {

      var cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i + 1, rowIndex: 1));

      cell.value = types[i];
      cell.cellStyle = typeStyle;
    }

    /// ---------------- DATA ----------------

    for (int row = 0; row < employees.length; row++) {

      /// Employee Name Column

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row + 2))
          .value = employees[row];

      for (int col = 0; col < types.length; col++) {

        String count = "0";

        for (var item in dataList) {
          if (item['firstname'].toString() == employees[row] &&
              item['value'].toString() == types[col]) {

            count = item['total_count'].toString();
          }
        }

        sheet
            .cell(CellIndex.indexByColumnRow(
            columnIndex: col + 1, rowIndex: row + 2))
            .value = count;
      }
    }

    /// ---------------- SAVE ----------------

    final fileBytes = excel.encode()!;

    if (kIsWeb) {

      // final blob = html.Blob([fileBytes]);
      // final url = html.Url.createObjectUrlFromBlob(blob);
      //
      // html.AnchorElement(href: url)
      //   ..setAttribute("download", "activity_report.xlsx")
      //   ..click();
      //
      // html.Url.revokeObjectUrl(url);

    } else {

      final directory = await getExternalStorageDirectory();

      String filePath = "${directory!.path}/Visit Report.xlsx";

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      OpenFile.open(filePath);
    }
  }

  void searchVisitReport(String value){
    final suggestions=_searchDailyVisitReport.where(
            (user){
          final comFName=user.companyName.toString().toLowerCase();
          final userFName=user.name.toString().toLowerCase();
          final empName=user.firstname.toString().toLowerCase();
          final userNumber = user.phoneNo.toString().toLowerCase();
          final input=value.toString().toLowerCase();
          return comFName.contains(input) || userFName.contains(input) || userNumber.contains(input) || empName.contains(input);
        }).toList();
    _dailyVisitReport=suggestions;
    notifyListeners();
  }
  void changeSelect(dynamic value) {
    _dailyType=value;
    var list = [];
    list.add(value);
    typeValue = list[0]["id"];
    notifyListeners();
  }
  void clearType() {
    _dailyType=null;
    notifyListeners();
  }
  void removeFilter() {
    _sortBy="";
    _dailyType="";
    notifyListeners();
  }
  var empMediaData = <int>[];
  var empFileName = "";
  var photo1 = "";
  var isTemplate=false;
  TextEditingController emailSubjectCtr=TextEditingController();
  TextEditingController emailToCtr=TextEditingController();
  TextEditingController emailMessageCtr=TextEditingController();
  TextEditingController emailQuotationCtr=TextEditingController();

  TextEditingController addNameController=TextEditingController();
  TextEditingController addSubjectController=TextEditingController();
  TextEditingController addMessageController=TextEditingController();
  var templateList = <TemplateModel>[];
  var templateCount = 0;

  void sendEmailDialog({
    required BuildContext context,
    required String id,
    required String name,
    required String mobile,
    required String coName,
  }) {

    var webWidth = MediaQuery.of(context).size.width * 0.5;
    var phoneWidth = MediaQuery.of(context).size.width * 0.9;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {

        return StatefulBuilder(
          builder: (context, setState) {

            return AlertDialog(

              actions: [
                Column(
                  children: [

                    Divider(color: Colors.grey.shade300),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Row(
                          children: [

                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                showAddTemplateDialog(context);
                              },
                              child: CustomText(
                                text: "Add Template",
                                colors: colorsConst.blueClr,
                                isBold: true,
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                chooseFile();
                              },
                              icon: SvgPicture.asset(
                                assets.file,
                                width: 25,
                                height: 25,
                              ),
                            ),
                          ],
                        ),

                        CustomLoadingButton(
                          callback: () {
                            if(emailToCtr.text.isEmpty){
                              utils.showWarningToast(context,text: "Please enter to address");
                              addCtr.reset();
                            }else if(!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailToCtr.text.trim())){
                              utils.showWarningToast(context,text: "Please enter valid email address");
                              addCtr.reset();
                            }else if(emailSubjectCtr.text.isEmpty){
                              utils.showWarningToast(context,text: "Please enter subject");
                              addCtr.reset();
                            }else if(emailMessageCtr.text.isEmpty){
                              utils.showWarningToast(context,text: "Please enter message");
                              addCtr.reset();
                            }else{
                              insertEmailAPI(context, id, photo1);
                            }
                          },
                          controller: addCtr,
                          isLoading: true,
                          backgroundColor: colorsConst.primary,
                          radius: 5,
                          width: 90,
                          height: 50,
                          text: "Send",
                          textColor: Colors.white,
                        )

                      ],
                    )
                  ],
                ),
              ],

              content: SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      /// CLOSE BUTTON
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.clear,
                            size: 18,
                            color: colorsConst.greyClr,
                          ),
                        ),
                      ),

                      /// TEMPLATE TOGGLE BUTTON
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              isTemplate = !isTemplate;
                            });
                          },
                          child: CustomText(
                            text: isTemplate==true?"Remove Template":"Get Form Template",
                            colors: colorsConst.blueClr,
                            isBold: true,
                          ),
                        ),
                      ),

                      /// TO FIELD
                      Row(
                        children: [

                          CustomText(text: "To", colors: colorsConst.greyClr),

                          50.width,

                          SizedBox(
                            width: kIsWeb ? webWidth : phoneWidth / 3,
                            child: TextField(
                              controller: emailToCtr,
                              style: TextStyle(
                                fontSize: 15,
                                color: colorsConst.greyClr,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          )

                        ],
                      ),

                      Divider(color: Colors.grey.shade300),

                      /// SUBJECT FIELD
                      Row(
                        children: [

                          CustomText(text: "Subject", colors: colorsConst.greyClr),

                          20.width,

                          SizedBox(
                            width: kIsWeb ? webWidth : phoneWidth / 3,
                            height: 50,
                            child: TextField(
                              controller: emailSubjectCtr,
                              style: TextStyle(color: colorsConst.greyClr),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          )

                        ],
                      ),

                      Divider(color: Colors.grey.shade300),

                      /// MAIN CONTENT SWITCH
                      isTemplate == false

                      /// NORMAL MAIL VIEW
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          photo1.isEmpty
                              ? SizedBox()
                              : Container(
                            height: 40,
                            padding:
                            EdgeInsets.fromLTRB(8, 5, 8, 5),
                            child: Row(
                              children: [
                                CustomText(text: empFileName),
                              ],
                            ),
                          ),

                          SizedBox(
                            width: kIsWeb ? webWidth : phoneWidth,
                            height: 223,
                            child: TextField(
                              controller: emailMessageCtr,
                              keyboardType: TextInputType.multiline,
                              maxLines: 21,
                              style: TextStyle(
                                color: colorsConst.greyClr,
                              ),
                              decoration: InputDecoration(
                                hintText: "Message",
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                        ],
                      )

                      /// TEMPLATE VIEW
                          : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),

                        child: SizedBox(
                          height: 210,
                          child: SingleChildScrollView(
                            child: Table(
                              border: TableBorder.all(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              children: [

                                /// HEADER
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomText(
                                        text: "\nTemplate Name\n",
                                        isBold: true,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomText(
                                        text: "\nSubject\n",
                                        isBold: true,
                                      ),
                                    ),
                                  ],
                                ),

                                /// DATA ROWS
                                for (var item in templateList)
                                  emailRow(
                                    context,
                                    templateName: item.templateName,
                                    msg: item.message,
                                    subject: item.subject,
                                    id: item.id,
                                    onChanged: (value){
                                      setState((){
                                        isTemplate = false;
                                        emailSubjectCtr.text = item.subject.toString().replaceAll('\n', ' ');
                                        emailMessageCtr.text = item.message.toString();
                                        emailQuotationCtr.text = item.templateName.toString();
                                      });
                                    }
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  void showAddTemplateDialog(BuildContext context, {bool isEdit = false,String id = ""}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
          var webWidth=MediaQuery.of(context).size.width * 0.5;
          var phoneWidth=MediaQuery.of(context).size.width * 0.9;
          return
            AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Text(
                "${isEdit?"Update":"Add"} New Template",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      hintText: "Template Name",isRequired: true,
                      text: "Template Name",
                      controller: addNameController,
                      width: kIsWeb?webWidth:phoneWidth,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        if (value.toString().isNotEmpty) {
                        }
                      },
                    ),
                    CustomTextField(isRequired: true,
                      hintText: "Subject",
                      text: "Subject",
                      controller: addSubjectController,
                      width: 480,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        if (value.toString().isNotEmpty) {
                        }
                      },
                    ),
                    MaxLineTextField(text: "Message", isRequired:true,controller: addMessageController, maxLine: 5)
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: customDecoration.baseBackgroundDecoration(
                          color: Colors.white,radius: 5
                      ),
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: CustomText(
                            text: "Cancel",
                            colors: colorsConst.primary,
                            size: 14,
                          )),
                    ),
                    10.width,
                    CustomLoadingButton(
                      callback: (){
                        if(addNameController.text.isEmpty){
                          utils.showWarningToast(context,text: "Please enter template name");
                          addCtr.reset();
                        }else if(addSubjectController.text.isEmpty){
                          utils.showWarningToast(context,text: "Please enter subject");
                          addCtr.reset();
                        }else if(addMessageController.text.isEmpty){
                          utils.showWarningToast(context,text: "Please enter message");
                          addCtr.reset();
                        }else if(isEdit){
                          updateTemplateAPI(context, id);
                        }else{
                          insertTemplateAPI(context);
                        }
                      },
                      height: 35,
                      isLoading: true,
                      backgroundColor: colorsConst.primary,
                      radius: 5,
                      width: 80,
                      controller: addCtr,
                      text: "Save",
                      textColor: Colors.white,
                    ),
                    5.width
                  ],
                ),
              ],
            );
        }
    );
  }

  Future<void> chooseFile() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: [
        'pdf','png','jpeg','jpg','ppt','pptx','doc','docx','xls','xlsx'
      ],
    );

    if (result != null) {

      final file = result.files.single;

      empFileName = file.name;

      if (file.bytes != null) {

        empMediaData = file.bytes!.toList();
        photo1 = base64Encode(file.bytes!);

      } else if (file.path != null) {

        final bytes = await File(file.path!).readAsBytes();
        empMediaData = bytes.toList();
        photo1 = base64Encode(bytes);

      }

      notifyListeners();

    }
  }
  DateTime dateTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  Future insertEmailAPI(BuildContext context, String id, String image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(phpFile));

      // Body values
      request.fields['clientMail'] = emailToCtr.text;
      request.fields['subject'] = emailSubjectCtr.text;
      request.fields['cos_id'] = localData.storage.read("cos_id").toString();
      request.fields['count'] = '${1}';
      request.fields['quotation_name'] = emailQuotationCtr.text;
      request.fields['body'] = emailMessageCtr.text;
      request.fields['user_id'] = localData.storage.read("id").toString();
      request.fields['id'] = id;
      request.fields['date'] = "${dateTime.day.toString().padLeft(2, "0")}-${dateTime.month.toString().padLeft(2, "0")}-${dateTime.year.toString()} ${DateFormat('hh:mm a').format(DateTime.now())}";
      request.fields['action'] =sendMail;

      if (empFileName.isNotEmpty) {
        var picture1 = http.MultipartFile.fromBytes(
          "attachment",
          empMediaData,
          filename: empFileName,
          //contentType: http.MediaType('image', 'jpeg'),
        );
        request.files.add(picture1);
      }
      var response = await request.send();
      var body = await response.stream.bytesToString();
      print(body);
      if (body.toString() == "Message has been sent") {
        utils.showWarningToast(context,
            text: "Mail has been sent");
        emailMessageCtr.clear();
        emailToCtr.clear();
        emailSubjectCtr.clear();
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.pop(Get.context!);
        addCtr.reset();
      } else {
        addCtr.reset();
        utils.showErrorToast(context:context);
      }
    } catch (e) {
      utils.showErrorToast(context:context);
      addCtr.reset();
    }
  }

  TableRow emailRow(BuildContext context,
      {bool? isCheck, String? templateName, String? subject, String? msg, String? id,
        required Function(bool?) onChanged,
      }) {
    return TableRow(
        decoration: BoxDecoration(color: Colors.white),
        children: [
          InkWell(
            onTap: (){
              onChanged;
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 15,
                  height: 15,
                  child: Checkbox(
                    tristate: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    side: MaterialStateBorderSide.resolveWith(
                          (states) =>
                          BorderSide(width: 1.0, color: colorsConst.greyClr),
                    ),
                    checkColor: Colors.white,
                    activeColor: colorsConst.blueClr,
                    value: isCheck,
                    onChanged: onChanged,
                  ),
                ),
                // InkWell(
                //   onTap: (){
                //     Navigator.of(context).pop();
                //     addNameController.text = templateName.toString();
                //     addSubjectController.text = subject.toString();
                //     addMessageController.text = msg.toString();
                //     showAddTemplateDialog(context, isEdit: true,id: id.toString());
                //   },
                //   child: SvgPicture.asset(assets.edit,
                //   ),
                // ),
                5.width,
                Container(
                  alignment: Alignment.center,
                  height: 50,
                  child: CustomText(
                    text: templateName.toString(),
                    size: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            height: 50,
            child: CustomText(
              text: subject.toString().trim(),
              size: 13,
            ),
          ),
        ]);
  }

  Future<void> updateTemplateAPI(context,String id) async {
    try {
      Map<String, String> data = {
        "action": updateTemplate,
        "template_name": addNameController.text.trim(),
        "subject": addSubjectController.text.trim(),
        "message": addMessageController.text.trim(),
        "updated_by": localData.storage.read("id"),
        "cos_id": localData.storage.read("cos_id"),
        "id": id
      };
      final response =await custRepo.addData(data);
      print(data.toString());
      print(response.toString());
      if (response.isNotEmpty){
        addNameController.clear();
        addSubjectController.clear();
        addMessageController.clear();
        allTemplates();
        Navigator.pop(context);
        utils.showSuccessToast(context:context,text: "Templates added successfully");
        addCtr.reset();
      } else {
        utils.showErrorToast(context: context);
        addCtr.reset();
      }
    } catch (e) {
      utils.showErrorToast(context: context);
      addCtr.reset();
    }
    notifyListeners();
  }
  Future<void> insertTemplateAPI(context) async {
    try {
      Map<String, String> data = {
        "action": addTemplate,
        "template_name": addNameController.text.trim(),
        "subject": addSubjectController.text.trim(),
        "message": addMessageController.text.trim(),
        "created_by": localData.storage.read("id"),
        "cos_id": localData.storage.read("cos_id")
      };
      final response =await custRepo.addData(data);
      print(data.toString());
      print(response.toString());
      if (response.isNotEmpty){
        addNameController.clear();
        addSubjectController.clear();
        addMessageController.clear();
        allTemplates();
        Navigator.pop(context);
        utils.showSuccessToast(context:context,text: "Templates added successfully");
        addCtr.reset();
      } else {
        utils.showErrorToast(context: context);
        addCtr.reset();
      }
    } catch (e) {
      utils.showErrorToast(context: context);
      addCtr.reset();
    }
    notifyListeners();
  }
  Future<void> allTemplates() async {
    _refresh= true;
    final url = Uri.parse(phpFile);
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "action": getAllData,
          "cos_id": localData.storage.read("cos_id"),
          "search_type": "templates"
        }),
      );
      print("response.body");
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rolesJson = data;
        templateList = rolesJson.map((json) => TemplateModel.fromJson(json)).toList();
        templateCount = templateList.length;
      } else {
        templateList = [];
        templateCount = 0;
        print("Failed to load template: ${response.body}");
      }
    } catch (e) {
      templateList = [];
      templateCount = 0;
      print("Error fetching template: $e");
    } finally {
      _refresh = false;
    }
    notifyListeners();
  }

}
