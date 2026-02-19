import 'dart:developer';
import 'package:master_code/repo/payroll_repo.dart';
import 'package:master_code/view_model/leave_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:master_code/model/user_model.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../component/month_calendar.dart';
import '../model/payroll/payroll_details_model.dart';
import '../model/payroll/payroll_setting_model.dart';
import '../screens/payroll/add_category.dart';
import '../screens/payroll/add_charges.dart';
import '../screens/payroll/edit_payroll_salary.dart';
import '../screens/payroll/payroll_calculation.dart';
import '../screens/payroll/payroll_details.dart';
import '../screens/payroll/payroll_settings.dart';
import '../source/constant/api.dart';
import '../source/constant/default_constant.dart';
import '../source/constant/local_data.dart';
import '../source/utilities/utils.dart';

class PayrollProvider with ChangeNotifier {
  final PayrollARepository payrollRepo = PayrollARepository();

  late PayrollDetailsModel empData;

  List categoryList=[];
  bool isPayrollRefresh=true,catLoading=true,isLess=true,isLoading=true,listAdding=true,payrollRefresh=true,isPayrollCalculated=true;
  String catType="0",stDate="",enDate="";
  int calYear=int.parse(DateTime.now().year.toString()),calMonth=int.parse(DateTime.now().month.toString().padLeft(2,"0"));
  var category,name,start,end,year,lastDate;
  var selectedIndex = 0;
  var settingEdit=false;
  var addCategory=false;
  var cal=false;
  void changePages(int index){
    cal=false;
    addCategory=false;
    settingEdit=false;
    selectedIndex=index;
    changeList();
    notifyListeners();
  }
  void changeFirst(){
    cal=false;
    addCategory=false;
    settingEdit=false;
    selectedIndex=0;
    changeList();
    notifyListeners();
  }
  void addAction(){
    addCategory=true;
    changeList();
    notifyListeners();
  }
  void intVal(){
    catId="";
    catType="0";
    isLess=true;
    categoryName.clear();
    notifyListeners();
  }
  void intValues(){
    category=null;
    addDate="";
    chargeType=false;
    catId="";
    nameId="";
    amount.clear();
    date.clear();
    comment.clear();
    search.clear();
    notifyListeners();
  }
  var addedAmount=0;
  var lessAmount=0;
  var addedCategory="0";
  var lessCategory="0";
  var lopAmount=0;
  void initPayrollDetails(PayrollDetailsModel empData){
    var data = empData;
    isPayrollCalculated=false;
    basic.text=settingList[0].basicDa.toString()=="null"&&settingList[0].basicDa.toString()==""?"0":settingList[0].basicDa.toString();
    hra.text=settingList[0].hra.toString()=="null"&&settingList[0].hra.toString()==""?"0":settingList[0].hra.toString();
    conv.text=settingList[0].conv.toString()=="null"&&settingList[0].conv.toString()==""?"0":settingList[0].conv.toString();
    wa.text=settingList[0].wa.toString()=="null"&&settingList[0].wa.toString()==""?"0":settingList[0].wa.toString();
    esi.text=settingList[0].esi.toString()=="null"&&settingList[0].esi.toString()==""?"0":settingList[0].esi.toString();
    pf.text=settingList[0].pf.toString()=="null"&&settingList[0].pf.toString()==""?"0":settingList[0].pf.toString();
    rate.text=settingList[0].otRate.toString()=="null"&&settingList[0].otRate.toString()==""?"0":settingList[0].otRate.toString();
    duty.clear();
    lop=0;
    basicDA=0;
    hraTotal=0;
    totalEarn=0;
    empEsi=0;
    empPf=0;
    totalDetection=0;
    netAmount=0;
    salary=data.salary.toString()=='null'||data.salary.toString()==''?0:int.parse(data.salary.toString());
    // duty.text=data.dutyDays.toString();
    notifyListeners();
  }
  void getData(context,PayrollDetailsModel empData)async{
    Provider.of<LeaveProvider>(context, listen: false).getOwnLeaves(empData.id.toString(),startDate,endDate);
    Provider.of<LeaveProvider>(context, listen: false).getLeavesRules(empData.id.toString());
    if(empData.cat!.isNotEmpty){
      addAmount(empData);
    }
    calculation(context,empData);
    notifyListeners();
  }
  void addAmount(PayrollDetailsModel data){
    for (var i=0;i<data.cat!.length;i++){
      if(data.cat![i].categoryType.toString()=="1"){
        addedCategory+='{'
            '${data.cat![i].category} - ${data.cat![i].categoryAmount}  ${i==data.cat!.length-1?",":""}'
            '}';
        addedAmount+= int.parse(data.cat![i].categoryAmount.toString());
      }else if(data.cat![i].categoryType.toString()=="0"){
        lessCategory+='{'
            '${data.cat![i].category} - ${data.cat![i].categoryAmount}  ${i==data.cat!.length-1?",":""}'
            '}';
        lessAmount+= int.parse(data.cat![i].categoryAmount.toString());
      }else{
        lop=int.parse(data.cat![i].categoryAmount.toString()=="null"?"0":data.cat![i].categoryAmount.toString());
      }
    }
    // log("Added Amount $addedAmount");
    notifyListeners();
  }
  void calculation(context,PayrollDetailsModel data){
    basic.text=settingList[0].basicDa.toString()=="null"&&settingList[0].basicDa.toString()==""?"0":settingList[0].basicDa.toString();
    hra.text=settingList[0].hra.toString()=="null"&&settingList[0].hra.toString()==""?"0":settingList[0].hra.toString();
    conv.text=settingList[0].conv.toString()=="null"&&settingList[0].conv.toString()==""?"0":settingList[0].conv.toString();
    wa.text=settingList[0].wa.toString()=="null"&&settingList[0].wa.toString()==""?"0":settingList[0].wa.toString();
    esi.text=settingList[0].esi.toString()=="null"&&settingList[0].esi.toString()==""?"0":settingList[0].esi.toString();
    pf.text=settingList[0].pf.toString()=="null"&&settingList[0].pf.toString()==""?"0":settingList[0].pf.toString();
    rate.text=settingList[0].otRate.toString()=="null"&&settingList[0].otRate.toString()==""?"0":settingList[0].otRate.toString();
      print("Duty");
      print(data.dutyDays.toString());
      if(data.dutyDays.toString()!="0"&&data.dutyDays.toString()!=""){
        var lastDay=int.parse('${int.parse(noOfWorkingDay.text)-Provider.of<LeaveProvider>(context, listen: false).fixedMonthLeaves.length}');
        // print("No Of Working Day");
        // print(lastDay.toString());
        double e=salary/lastDay;
        var oneDaySalary=e.truncate();
        var totalSalary=0.0;
        var otSalary=0;
        var pfLess=0.0;
        var esiLess=0.0;
        print("One day Salary $oneDaySalary");
        if(data.dutyDays.toString().isNotEmpty){
          var dutyy=(int.parse(data.dutyDays.toString()));
          double c=(dutyy/lastDay)*100;
          // var d=c.truncate();
          totalSalary=c/100*salary;
          print("Total Salary ${totalSalary.truncate()}");
        }
        var otCal=int.parse(noOfWorkingDay.text)-int.parse(data.dutyDays.toString());
        log("Total Salary OT Days $otCal");
        if(otCal>0){
        }else if (otCal < 0) {
          int absoluteValue = otCal.abs();

          log("Absolute Value: $absoluteValue");
          overTime.text=absoluteValue.toString();
        }
        if(overTime.text.isNotEmpty&&rate.text.isNotEmpty){
          var ot=oneDaySalary*(int.parse(rate.text));
          // print("OverTime $ot");
          var otDay=int.parse(overTime.text);
          otSalary=otDay*ot;
          // print("OverTime Salary$otSalary");
        }
        if(totalSalary!=0){
          var totalEarnn=totalSalary+otSalary;
          totalEarn=totalEarnn.round();
          print("Total Earn $totalEarn");
        }
        if(totalEarn!=0){
          var basicc=(totalEarn/100)*(int.parse(basic.text));
          var store=basicc;
          basicDA=store.truncate();
          print("basicDA % ${basic.text}");
          print("basicDA ${basicDA}");

          var hraa=(totalEarn/100)*(int.parse(hra.text));
          var storeHra=hraa;
          hraTotal=storeHra.truncate();
          print("hra % ${hra.text}");
          print("hraTotal ${hraTotal}");

          var convv=(totalEarn/100)*(int.parse(conv.text));
          var storeConv=convv;
          conTotal=storeConv.truncate();
          print("conv % ${conv.text}");
          print("conTotal ${conTotal}");

          var waa=(totalEarn/100)*(int.parse(wa.text));
          var storeWa=waa;
          wgTotal=storeWa.truncate();
          print("wa % ${wa.text}");
          print("wgTotal ${wgTotal}");

        }
print("pf.text");
print(pf.text);
        if(data.pf.toString()!="0"&&data.pf.toString()!=""){
          var pfCal=int.parse(pf.text);
          pfLess=salary/100*pfCal;
          empPf=pfLess.truncate();
          print("PF $pfLess");
        }
        if(data.esi.toString()!="0"&&data.esi.toString()!=""){
          var esiCal=double.parse(esi.text);
          esiLess=salary/100*esiCal;
          empEsi=esiLess.truncate();
          print("ESI $esiLess");
        }
        if(lop!=0){
          var lopAmt=lop*oneDaySalary;
          lopAmount=lopAmt;
        }
        var totalDetectionn=pfLess+esiLess+lessAmount+lopAmount;
        totalDetection=totalDetectionn.round();
        print("Total Detection $totalDetection");

        if(totalEarn!=0||totalDetection!=0){
          var netAmountt=totalEarn-totalDetection;
          netAmount=netAmountt.round();
          if(addedAmount!=0){
            var inc=addedAmount;
            netAmount=netAmount+inc;
            print("Incentive + Net Amount ${netAmount}");
          }else{
            netAmount=netAmount.round();
            print("Net Amount ${netAmount}");
          }
        }
        payrollList.add(
            {
              "Role":data.roleId.toString(),
              "Name":data.fName.toString(),
              "Number":data.mobileNumber.toString(),
              "Salary":data.salary.toString(),
              "Duty":data.dutyDays.toString(),
              "OT":'0',
              "OT Rate":"",
              "Basic+DA":basicDA.toString(),
              "HRA":hraTotal.toString(),
              "CONV":"",
              "WA":"",
              "Total Earn":totalEarn.toString(),
              "ESI":empEsi.toString(),
              "PF":empPf.toString(),
              "Categories1":addedCategory.toString(),
              "Categories2":lessCategory.toString(),
              "Total DED":totalDetection.toString(),
              "NET Amount":netAmount.toString(),
              "SIGNATURE":"",
              "bank_name":data.bankName.toString(),
              "acc_no":data.accNo.toString(),
              "ifsc_code":data.ifscCode.toString(),
            }
        );
      }
      isPayrollCalculated=true;
      notifyListeners();
  }

  void initPayroll(){
    search.clear();
    selectedIndex=0;
    settingEdit=false;
    addCategory=false;
    cal=false;
    notifyListeners();
  }
  Future refresh(context)async{
    search.clear();
    start =("01-${(selected.month.toString().padLeft(2, "0"))}-${selected.year}");
    var ex = start.split("-");
    var date = DateTime(int.parse(ex.first), int.parse(ex[1]) + 1,0);
    lastDate = date.day;
    end = "${date.day.toString().padLeft(2, "0")}-${selected.month.toString().padLeft(2, "0")}-${selected.year}";
    _month=DateFormat("MMM yyyy").format(DateTime.now());
    year = ex[0];
    _startDate=start;
    _endDate=end;
    getPayrollUserDetails();
    Provider.of<LeaveProvider>(context, listen: false).getMonthLeaves(true,startDate,endDate);
    noOfWorkingDay.text=lastDate.toString();
    notifyListeners();
  }

  List<Widget> mainContents = [
   const PayrollDetails(),
    const AddCharges(),
    const EditSalary(),
    const Categories(),
    const PayrollSetting()
  ];
  void changeList({PayrollDetailsModel? empData}){
    mainContents = [
      cal==false?
      const PayrollDetails():PayRollCalculation(empData: empData!),
      const AddCharges(),
      const EditSalary(),
      addCategory==false?
      const Categories():const AddCategory(),
      settingEdit==false?
      const PayrollSetting():const UpdatePayrollSetting()
    ];
    notifyListeners();
  }
  void changeType(String value){
    catType = value;
    notifyListeners();
  }
  String _month="";
  String get month => _month;

  DateTime selected = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final TextEditingController search=TextEditingController();
  final TextEditingController userSearch=TextEditingController();
final TextEditingController amount=TextEditingController();
final TextEditingController comment=TextEditingController();
final TextEditingController date=TextEditingController();
final TextEditingController categoryName=TextEditingController();

var formatter = NumberFormat('#,##,000');

TextEditingController basic =TextEditingController();
TextEditingController hra =TextEditingController();
TextEditingController pf =TextEditingController();
TextEditingController conv =TextEditingController();
TextEditingController wa =TextEditingController();
TextEditingController esi =TextEditingController();
TextEditingController rate =TextEditingController();
TextEditingController duty =TextEditingController();
TextEditingController overTime =TextEditingController();
  TextEditingController noOfWorkingDay =TextEditingController();
var addDate="";
var catId="";
var chargeType=false;
var nameId="";
var isCal=false;
  var salary=0;
  var totalDetection=0;
  var totalEarn=0;
  var netAmount=0;
  var basicDA=0;
  var hraTotal=0;
  var conTotal=0;
  var wgTotal=0;
  var empPf=0;
  var empEsi=0;
  var lop=0;
List<UserModel> allUsers= <UserModel>[];
List searchPayrollEdit= [];
List payrollEdit= [];
List<Map<String, dynamic>> editList= [];
List<PayrollSettingModel> settingList= <PayrollSettingModel>[];
List<PayrollDetailsModel> payrollDetailsList= <PayrollDetailsModel>[];
List<PayrollDetailsModel> searchPayrollDetailsList= <PayrollDetailsModel>[];
  String _startDate = "";
  String get startDate => _startDate;
  String _endDate="";
  String get endDate => _endDate;
  late TabController tabController;
  RoundedLoadingButtonController submitCtr=RoundedLoadingButtonController();
  RoundedLoadingButtonController updateCtr=RoundedLoadingButtonController();
  RoundedLoadingButtonController salaryCtr=RoundedLoadingButtonController();
  RoundedLoadingButtonController downloadCtr=RoundedLoadingButtonController();
  List<Map<String,dynamic>> payrollList=[];

  Future<void> getCategory(bool isRefresh) async {
    try {
      if(isRefresh==true){
        addCategory=false;
        catLoading=false;
        categoryList.clear();
        notifyListeners();
      }
      Map data = {
        "action":payrollData,
        "search_type":"payroll_category",
        "cos_id":localData.storage.read("cos_id")
      };
      final response = await payrollRepo.getCategory(data);
      if(response.isNotEmpty) {
        categoryList.clear();
        for(var i=0;i<response.length;i++){
          categoryList.add({
            "cat_id": response[i]["cat_id"].toString().trim(),
            "category": response[i]["category"].toString().trim(),
            "add": response[i]["add"].toString().trim()
          });
        }
        catLoading=true;
      }else{
        categoryList.clear();
        catLoading=true;
      }
    } catch (e) {
      categoryList.clear();
      catLoading=true;
    }
    notifyListeners();
  }
  Future<void> getSettings() async {
    try {
      settingEdit=false;
      isPayrollRefresh=false;
      settingList.clear();
      notifyListeners();
      Map data = {
        "action":payrollData,
        "search_type":"payroll_settings",
        "cos_id":localData.storage.read("cos_id")
      };
      final response = await payrollRepo.getSettings(data);
      if(response.isNotEmpty) {
        settingList=response;
        isPayrollRefresh=true;
      }else{
        isPayrollRefresh=true;
      }
    } catch (e) {
      isPayrollRefresh=true;
    }
    notifyListeners();
  }
  Future<void> getPayrollUserDetails() async {
    try {
      isLoading=false;
      searchPayrollDetailsList.clear();
      payrollDetailsList.clear();
      notifyListeners();
      Map data = {
        "action":payrollData,
        "search_type":"payroll_details",
        "st_dt":_startDate,
        "en_dt":_endDate,
        "cos_id":localData.storage.read("cos_id"),
      };
      final response = await payrollRepo.getPayrollUserDetails(data);
      if(response.isNotEmpty) {
        searchPayrollDetailsList=response;
        payrollDetailsList=response;
        isLoading=true;
      }else{
        isLoading=true;
      }
    } catch (e) {
      isLoading=true;
    }
    notifyListeners();
  }
  Future<void> getOurPayrollDetails() async {
    try {
      isLoading=false;
      searchPayrollDetailsList.clear();
      notifyListeners();
      Map data = {
        "action":payrollData,
        "search_type":"our_payroll",
        "st_dt":_startDate,
        "en_dt":_endDate,
        "id":localData.storage.read("id"),
      };
      final response = await payrollRepo.getOurPayrollDetails(data);
      if(response.isNotEmpty) {
        searchPayrollDetailsList=response;
        isLoading=true;
      }else{
        isLoading=true;
      }
    } catch (e) {
      isLoading=true;
    }
    notifyListeners();
  }
  // Future<void> getPayrollUsers() async {
  //   // try {
  //     listAdding=false;
  //     payrollEdit.clear();
  //     searchPayrollEdit.clear();
  //     allUsers.clear();
  //     notifyListeners();
  //     Map data = {
  //       "action":payrollData,
  //       "search_type":"payroll_users",
  //       "cos_id":localData.storage.read("cos_id")
  //     };
  //     final response = await payrollRepo.getPayrollUsers(data);
  //     if(response.isNotEmpty) {
  //       allUsers= response;
  //       Map<String, dynamic> createPayrollEntry(Map<String, dynamic> data) {
  //         return {
  //           "id": data["id"],
  //           "f_name": data["f_name"],
  //           "mobile_number": data["mobile_number"],
  //           "role": data["role"],
  //           "esi_check": data["esi"] == "1"?true:false,
  //           "pf_check": data["pf"] == "1"?true:false,
  //           "salaryCtr": TextEditingController(text: data["salary"] == "null" ? "" : data["salary"]),
  //         };
  //       }
  //       List<Map<String, dynamic>> convertDynamicList(List<dynamic> dynamicList) {
  //         return dynamicList.cast<Map<String, dynamic>>();
  //       }
  //       List<Map<String, dynamic>> convertedList = convertDynamicList(response);
  //
  //       for(var i=0;i<response.length;i++){
  //         var payrollEntry = createPayrollEntry(convertedList[i]);
  //         searchPayrollEdit.add(payrollEntry);
  //         payrollEdit.add(payrollEntry);
  //       }
  //       listAdding=true;
  //     }else{
  //       listAdding=true;
  //     }
  //   // } catch (e) {
  //   //   listAdding=true;
  //   // }
  //   notifyListeners();
  // }
  Future<void> getPayrollUsers() async {
    try {
      listAdding = false;
      payrollEdit.clear();
      searchPayrollEdit.clear();
      allUsers.clear();
      notifyListeners();

      Map data = {
        "action": payrollData,
        "search_type": "payroll_users",
        "cos_id": localData.storage.read("cos_id"),
      };

      final response = await payrollRepo.getPayrollUsers(data);

      if (response.isNotEmpty) {
        allUsers = response;

        final addedIds = <dynamic>{};

        for (var user in response) {
          if (!addedIds.contains(user.id)) {
            addedIds.add(user.id);

            var payrollEntry = {
              "id": user.id,
              "f_name": user.firstname,
              "mobile_number": user.mobileNumber,
              "role": user.role,
              "esi_check": user.esi == "1",
              "pf_check": user.pf == "1",
              "salaryCtr": TextEditingController(
                text: user.salary == "null" ? "" : user.salary,
              ),
              "cos_id": localData.storage.read("cos_id"),
            };

            searchPayrollEdit.add(payrollEntry);
            payrollEdit.add(payrollEntry);
          }
        }
        // print("searchPayrollEdit : ${searchPayrollEdit}");
        // print("searchPayrollEdit : ${searchPayrollEdit.length}");
        listAdding = true;
      } else {
        listAdding = true;
      }
    }catch(e){
      listAdding = true;
    }
    notifyListeners();
  }

  void addPayrollSetting(context) async {
    try {
      Map data = {
        "action":insertPayrollSetting,
        "ESI":esi.text,
        "PF":pf.text,
        "Basic_DA":basic.text,
        "HRA":hra.text,
        "CONV":conv.text,
        "WA":wa.text,
        "OT_Rate":rate.text,
        "comment":comment.text,
        "added_by":localData.storage.read("id"),
        "cos_id":localData.storage.read("cos_id"),
        "log_file":"${localData.storage.read("mobile_number")}",
      };
      final response = await payrollRepo.addPayrollSetting(data);
      if (response.toString().contains("ok")) {
        utils.showSuccessToast(context:context,text: constValue.updated);
        getSettings();
        changeList();
        updateCtr.reset();
      } else {
        utils.showErrorToast(context: context);
        updateCtr.reset();
      }
    } catch (e) {
      utils.showErrorToast(context: context);
      updateCtr.reset();
    }
    notifyListeners();
  }
  void addPayrollDetails(context) async {
    try {
      Map data = {
        "action":insertPayrollDetails,
        "log_file":"${localData.storage.read("mobile_number")}",
        "emp_id":nameId,
        "cat_id":catId,
        "comment":comment.text,
        "amount":amount.text,
        "date":date.text,
        "created_by":localData.storage.read("id"),
        "platform": localData.storage.read("platform"),
        "cos_id": localData.storage.read("cos_id"),
      };
      final response = await payrollRepo.addPayrollSetting(data);
      if (response.toString().contains("ok")) {
        utils.showSuccessToast(context:context,text: constValue.updated);
        cal=false;
        selectedIndex=0;
        submitCtr.reset();
      } else {
        utils.showErrorToast(context: context);
        submitCtr.reset();
      }
    } catch (e) {
      utils.showErrorToast(context: context);
      submitCtr.reset();
    }
    notifyListeners();
  }
  void addCategories(context) async {
    try {
      Map data = {
        "action":insertCategory,
        "category":categoryName.text.trim(),
        "add":catType,
        "created_by":localData.storage.read("id"),
        "cos_id":localData.storage.read("cos_id"),
      };
      final response = await payrollRepo.addPayrollSetting(data);
      if (response.toString().contains("ok")) {
        utils.showSuccessToast(context:context,text: constValue.success);
        getCategory(true);
        changeList();
        submitCtr.reset();
      } else {
        utils.showErrorToast(context:context);
        submitCtr.reset();
      }
    } catch (e) {
      utils.showErrorToast(context:context);
      submitCtr.reset();
    }
    notifyListeners();
  }
  void deleteCategory(context,String catId) async {
    try {
      Map data = {
        "action":delete,
        "ops":"cat_delete",
        "cat_id":catId,
        "updated_by":localData.storage.read("id"),
        "platform": localData.storage.read("platform"),
      };
      final response = await payrollRepo.addPayrollSetting(data);
      if (response["status_code"]==200) {
        utils.showSuccessToast(context: context,text: constValue.deleted);
        getCategory(false);
        Navigator.pop(context);
        submitCtr.reset();
      } else {
        utils.showErrorToast(context: context);
        submitCtr.reset();
      }
    } catch (e) {
      utils.showErrorToast(context: context);
      submitCtr.reset();
    }
    notifyListeners();
  }

  void addOrUpdatePayrollEdit(int index) {
    final newItem = {
      "updated_by": localData.storage.read("id"),
      "id": searchPayrollEdit[index]["id"],
      "esi": searchPayrollEdit[index]["esi_check"]==true?"1":"0",
      "pf": searchPayrollEdit[index]["pf_check"]==true?"1":"0",
      "salary": searchPayrollEdit[index]["salaryCtr"].text,
      "cos_id": localData.storage.read("cos_id"),
    };

    final existingIndex = editList.indexWhere((item) => item["id"] == newItem["id"]);

    if (existingIndex != -1) {
      editList[existingIndex] = newItem;
    } else {
      editList.add(newItem);
    }
    notifyListeners();
  }

  void insertSalaryDetails(context,List<Map<String, dynamic>> dataList) async {
    try {
      final Map<String, dynamic> data = {
        'action': addPayrollSalary,
        'salaryList': dataList, // The list
      };
      final response = await payrollRepo.insertSalaryDetails(data);
      if (response.toString().contains("ok")) {
        utils.showSuccessToast(context: context,text: constValue.updated);
        salaryCtr.reset();
        getPayrollUsers();
        editList.clear();
        notifyListeners();
      } else {
        utils.showErrorToast(context: context);
        salaryCtr.reset();
      }
      salaryCtr.reset();
    } catch (e) {
      utils.showErrorToast(context: context);
      salaryCtr.reset();
    }
    salaryCtr.reset();
    notifyListeners();
  }
void searchPayroll(String value){
    final suggestions=payrollDetailsList.where(
            (user){
          final userFName=user.fName.toString().toLowerCase();
          final userNumber = user.mobileNumber.toString().toLowerCase();
          final input=value.toString().toLowerCase();
          return userFName.contains(input) || userNumber.contains(input);
        }).toList();
    searchPayrollDetailsList=suggestions;
    notifyListeners();
}
void searchPayrollUsers(String value){
  final suggestions=payrollEdit.where(
          (user){
        final userFName = user["f_name"].toString().toLowerCase();
        final userNumber = user["mobile_number"].toString().toLowerCase();
        final input = value.toString().toLowerCase().trim();
        return userFName.contains(input) || userNumber.contains(input);
      }).toList();
  searchPayrollEdit=suggestions;
    notifyListeners();
}
  void showCustomMonthPicker({
    required BuildContext context,
    // required void Function() function,
  }) {
    // If _month already has a value like "Nov 2025", parse it
    DateTime now = DateTime.now();
    DateTime initialDate;

    try {
      initialDate = month.isNotEmpty
          ? DateFormat("MMM yyyy").parse(month)
          : now;
    } catch (e) {
      initialDate = now;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            width: 300,
            height: 400,
            child: CustomMonthPicker(
              initialMonth: initialDate.month,
              initialYear: initialDate.year,
              firstYear: 2024,
              lastYear: DateTime.now().month,
              onSelected: (value) {
                int selectedMonth = value.month;
                int selectedYear = value.year;
                String sd = DateFormat("dd-MM-yyyy").format(DateTime(selectedYear, selectedMonth, 1));
                String ed = DateFormat("dd-MM-yyyy").format(DateTime(selectedYear, selectedMonth + 1, 0));
                _month=DateFormat("MMM yyyy").format(value);
                _startDate=sd;
                _endDate=ed;
                // function();
                isLoading=false;
                getPayrollUserDetails();
                Provider.of<LeaveProvider>(context, listen: false).getMonthLeaves(true,_startDate,_endDate);
                notifyListeners();
              },
            ),
          ),
        );
      },
    );
  }
}


