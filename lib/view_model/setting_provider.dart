import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../model/setting/features_model.dart';
import '../model/user_model.dart';
import '../repo/home_repo.dart';
import '../screens/common/dashboard.dart';
import '../screens/setting/headings.dart';
import '../source/constant/api.dart';
import '../source/constant/local_data.dart';
import '../source/utilities/utils.dart';

class SettingProvider with ChangeNotifier{
final HomeRepository empRepo = HomeRepository();

TextEditingController signFirstName = TextEditingController();
TextEditingController signLastName = TextEditingController();
TextEditingController signMobileNumber = TextEditingController();
TextEditingController signPassword = TextEditingController();

final RoundedLoadingButtonController signCtr =RoundedLoadingButtonController();

Future<void> manageSetting(context,String cosId) async {
  try {
    Map data = {
      "action": manageSettings,
      "cos_id": cosId,
      "user_id": "0",
      'featuresList': _featuresList, // The list
    };
    final response =await empRepo.manageSetting(data);
    log(response.toString());
    if (response.toString().contains("successfully")){
      if(componentsList.isNotEmpty){
        manageComponent(context,cosId);
      }else{
        utils.showSuccessToast(context: context,text: "Saved successfully.",);
        getAppFeatures(cosId);
        signCtr.reset();
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
Future<void> manageComponent(context,String cosId) async {
  try {
    Map data = {
      "action": manageComponents,
      "cos_id": cosId,
      "user_id": "0",
      'componentsList': componentsList, // The list
    };
    final response =await empRepo.manageSetting(data);
    log(response.toString());
    if (response.toString().contains("successfully")){
      utils.showSuccessToast(context: context,text: "Saved successfully.",);
      getAppFeatures(cosId);
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
Future<void> changeAppValues(context,String catId,String category) async {
  try {
    Map data = {
      "action": appValues,
      "cos_id": localData.storage.read("cos_id"),
      "created_by": localData.storage.read("id"),
      'valueList': _appHeadingList, // The list
    };
    print("_appHeadingList");
    print(_appHeadingList);
    final response =await empRepo.manageSetting(data);
    log(response.toString());
    if (response.toString().contains("successfully")){
      utils.showSuccessToast(context: context,text: "Saved successfully.",);
      utils.navigatePage(context, ()=> DashBoard(child: HeadingValues(name: category, id: catId)));
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
void clear(){
  componentsList.clear();
  notifyListeners();
}
Future<void> roleComponent(context,String cosId,String featureId) async {
  try {
    Map data = {
      "action": roleComponents,
      "cos_id": cosId,
      "f_id": featureId,
      "created_by": "0",
      'componentsList': componentsList, // The list
    };
    final response =await empRepo.manageSetting(data);
    log(response.toString());
    if (response.toString().contains("successfully")){
      componentsList.clear();
      utils.showSuccessToast(context: context,text: "Saved successfully.",);
      getRolesManagement(cosId);
      // getAppFeatures(cosId);
      await FirebaseFirestore.instance.collection('attendance').add({
        'emp_id': localData.storage.read("id"),
        'time': DateTime.now(),
        'status': "",
      });
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
void initValues(){
  signFirstName.clear();
  signLastName.clear();
  signMobileNumber.clear();
  signPassword.clear();
}
bool _refresh = true;
bool get refresh =>_refresh;
List componentsList=[];
List<FeaturesModel> _featuresList=[];
List<FeaturesModel> get featuresList => _featuresList;

List<UserModel> _adminList=[];
List<UserModel> get adminList => _adminList;
Future<void> getAppFeatures(String cosId) async {
  _refresh=false;
  _featuresList.clear();
  notifyListeners();
  try {
    Map data = {
      "action": settingData,
      "search_type": "client_setting",
      "cos_id":cosId,
    };
    final response =await empRepo.getFeatures(data);
    if (response.isNotEmpty) {
      _featuresList=response;
      _refresh=true;
    } else {
      _featuresList=[];
      _refresh=true;
    }
  } catch (e) {
    _featuresList=[];
    _refresh=true;
    log(e.toString());
  }
  notifyListeners();
}

List _roleFeaList=[];
List get roleFeaList => _roleFeaList;
void check(String feId) {
  print("---- Checking roles ----");
  print("Role Values: $_roleValues");
  print("Role-Feature List: $_roleFeaList");

  for (var role in _roleValues) {

    // Find the matching feature-role mapping
    var matchedItem = _roleFeaList.firstWhere(
          (f) =>
      f["role_id"].toString() == role["id"].toString() &&
          f["c_id"].toString() == feId,
      orElse: () => null,
    );

    bool alreadyAssigned = matchedItem != null;

    // Apply manage flag
    role["manage"] = alreadyAssigned;

    print(
        "feId: $feId | "
            "feature_id: ${matchedItem != null ? matchedItem["f_id"] : "NO MATCH"} | "
            "Role ID: ${role["id"]} | "
            "Role Name: ${role["role"]} | "
            "Assigned: $alreadyAssigned"
    );
  }

  print("Updated roleValues: $_roleValues");

  notifyListeners();
}
void checkList(String feId,List valueList) {
  print("---- Checking roles ----");
  print("Role Values: $valueList");
  print("Role-Feature List: $_roleFeaList");

  for (var role in valueList) {

    // Find the matching feature-role mapping
    var matchedItem = _roleFeaList.firstWhere(
          (f) =>
      f["role_id"].toString() == role["id"].toString() &&
          f["c_id"].toString() == feId,
      orElse: () => null,
    );

    bool alreadyAssigned = matchedItem != null;

    // Apply manage flag
    role["manage"] = alreadyAssigned;

    print(
        "feId: $feId | "
            "feature_id: ${matchedItem != null ? matchedItem["f_id"] : "NO MATCH"} | "
            "Role ID: ${role["id"]} | "
            "Role Name: ${role["role"]} | "
            "Assigned: $alreadyAssigned"
    );
  }

  print("Updated roleValues: $valueList");

  notifyListeners();
}

Future<void> getRolesManagement(String cosId) async {
  _roleFeaList.clear();
  notifyListeners();
  try {
    Map data = {
      "action": settingData,
      "search_type": "roles_management",
      "cos_id":cosId,
    };
    final response =await empRepo.getRole(data);
    if (response.isNotEmpty) {
      _roleFeaList=response;
    } else {
      _roleFeaList=[];
    }
  } catch (e) {
    _roleFeaList=[];
    log(e.toString());
  }
  notifyListeners();
}
List _roleValues = [];
List get roleValues => _roleValues;

Future<void> getRoles(String cosId) async {
  try {
    componentsList.clear();
    _roleValues.clear();
    notifyListeners();
    Map data = {
      "action": settingData,
      "search_type":"allroles",
      "cos_id":cosId,
    };
    final response = await empRepo.getRole(data);
    print("response");
    print(response);
    if(response.isNotEmpty){
      List<Map<String, dynamic>> callList = response.map((e) => {
        "id": e['id'].toString(),
        "role": e['role'].toString(),
        "manage": false,
      }).toList();
      _roleValues=callList;
    }
    else{
      _roleValues.clear();
    }
  } catch (e) {
    _roleValues.clear();
  }
  notifyListeners();
}

List _headingList = [];
List get headingList => _headingList;

Future<void> getHeading() async {
  try {
    _headingList.clear();
    _refresh=false;
    notifyListeners();
    Map data = {
      "action": settingData,
      "search_type":"app_headings",
      "cos_id":localData.storage.read("cos_id"),
    };
    // print("response");
    final response = await empRepo.getRole(data);
    // print(response);
    if(response.isNotEmpty){
      _headingList=response;
      _refresh=true;
    }
    else{
      _refresh=true;
      _headingList.clear();
    }
  } catch (e) {
    _refresh=true;
    _headingList.clear();
  }
  notifyListeners();
}
void selectUser(){
  _featuresList.clear();
  getAppFeatures(localData.storage.read("cos_id"));
  getRoles(localData.storage.read("cos_id"));
  getRolesManagement(localData.storage.read("cos_id"));
  notifyListeners();
}
List<ValuesModel> _appHeadingList = [];
List<ValuesModel> get appHeadingList => _appHeadingList;
Future<void> getAppHeadings(String id) async {
  try {
  print("getAppHeadings.........");
    _refresh=false;
    _appHeadingList.clear();
    notifyListeners();
    Map data = {
      "action": settingData,
      "search_type":"app_values",
      "cat_id":id,
      "cos_id": localData.storage.read("cos_id")
    };
    final response = await empRepo.getData(data);
    print(data.toString());
    print(response);
    if(response.isNotEmpty){
      _appHeadingList=response;
      _refresh=true;
    }
    else{
      _appHeadingList.clear();
      _refresh=true;
    }
  } catch (e) {
    _appHeadingList.clear();
    _refresh=true;
  }
  notifyListeners();
}

}