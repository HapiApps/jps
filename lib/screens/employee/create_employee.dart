import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/component/custom_textfield.dart';
import 'package:master_code/screens/employee/viamap.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/constant/key_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_code/source/styles/decoration.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_checkbox.dart';
import '../../component/custom_dropdown.dart';
import '../../component/custom_text.dart';
import '../../component/document_container.dart';
import '../../component/map_dropdown.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/employee_provider.dart';
import '../../view_model/location_provider.dart';

class CreateEmployee extends StatefulWidget {
  const CreateEmployee({super.key});

  @override
  State<CreateEmployee> createState() => _CreateEmployeeState();
}

class _CreateEmployeeState extends State<CreateEmployee>with SingleTickerProviderStateMixin{
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override 
  void initState() {
    Provider.of<EmployeeProvider>(context, listen: false).tabController=TabController(length:7, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeProvider>(context, listen: false).tabController?.addListener(() {
        _myFocusScopeNode.unfocus();
        Provider.of<EmployeeProvider>(context, listen: false).updateIndex(Provider.of<EmployeeProvider>(context, listen: false).tabController!.index);
      });
      Provider.of<EmployeeProvider>(context, listen: false).initValues();
    });
  super.initState();
  }
  @override
  void dispose() {
    _myFocusScopeNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer2<EmployeeProvider,LocationProvider>(builder: (context,empProvider,locPvr,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: constValue.createEmployee),
            ),
            bottomNavigationBar:Container(
              width:kIsWeb?webWidth:phoneWidth,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                // color:Colors.blue,
              child:empProvider.tabController!.index==0?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomLoadingButton(
                      callback: (){
                        if (empProvider.signFirstName.text.trim().isEmpty) {
                          utils.showWarningToast(context, text: "Please fill first name");
                        } else if (empProvider.signMobileNumber.text.trim().isEmpty) {
                          utils.showWarningToast(context, text: "Please fill mobile number");
                        } else if (empProvider.signMobileNumber.text.trim().length != 10) {
                          utils.showWarningToast(context, text: "Please check mobile number");
                        } else if (empProvider.signPassword.text.trim().isEmpty) {
                          utils.showWarningToast(context, text: "Please fill password");
                        } else if (empProvider.signPassword.text.trim().length < 8) {
                          utils.showWarningToast(context, text: "Password must be at least 8 characters");
                        } else if (empProvider.role == null) {
                          utils.showWarningToast(context, text: "Please select role");
                        } else if (empProvider.pinCode.text.trim().isNotEmpty &&
                            empProvider.pinCode.text.trim().length != 6) {
                          utils.showWarningToast(context, text: "Please check pincode");
                        } else if (empProvider.signWhatsappNumber.text.trim().isNotEmpty &&
                            empProvider.signWhatsappNumber.text.trim().length != 10) {
                          utils.showWarningToast(context, text: "Please check whatsapp number");
                        } else {
                          _myFocusScopeNode.unfocus();
                          empProvider.tabController?.animateTo(1);
                        }
                      }, isLoading: false,text: "Add More",
                      backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                      width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                  CustomLoadingButton(
                      callback: (){
                        if (empProvider.signFirstName.text.trim().isEmpty) {
                          utils.showWarningToast(context, text: "Please fill first name");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signMobileNumber.text.trim().isEmpty) {
                          utils.showWarningToast(context, text: "Please fill mobile number");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signMobileNumber.text.trim().length != 10) {
                          utils.showWarningToast(context, text: "Please check mobile number");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signPassword.text.trim().isEmpty) {
                          utils.showWarningToast(context, text: "Please fill password");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signPassword.text.trim().length < 8) {
                          utils.showWarningToast(context, text: "Password must be at least 8 characters");
                          empProvider.signCtr.reset();
                        } else if (empProvider.role == null) {
                          utils.showWarningToast(context, text: "Please select role");
                          empProvider.signCtr.reset();
                        } else if (empProvider.pinCode.text.trim().isNotEmpty &&
                            empProvider.pinCode.text.trim().length != 6) {
                          utils.showWarningToast(context, text: "Please check pincode");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signWhatsappNumber.text.trim().isNotEmpty &&
                            empProvider.signWhatsappNumber.text.trim().length != 10) {
                          utils.showWarningToast(context, text: "Please check whatsapp number");
                          empProvider.signCtr.reset();
                        } else {
                          _myFocusScopeNode.unfocus();
                          empProvider.insertEmployeeDetails(context, locPvr.latitude, locPvr.longitude);
                        }
                      }, isLoading: true,text: "Save",controller: empProvider.signCtr,
                      backgroundColor: colorsConst.primary,radius: 10,
                      width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                ],
              )
              :empProvider.tabController!.index==1?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomLoadingButton(
                      callback: (){
                        _myFocusScopeNode.unfocus();
                        empProvider.tabController?.animateTo(0);
                      }, isLoading: false,text: "Back",
                      backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                      width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                  CustomLoadingButton(
                      callback: (){
                        final email = empProvider.signEmailid.text.trim();
                        final aadhar = empProvider.signAadhar.text.trim();
                        final pan = empProvider.signPan.text.trim();

                        if (email.isNotEmpty &&
                            !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
                          utils.showWarningToast(context, text: "Please check email id");
                        } else if (aadhar.isNotEmpty && aadhar.length != 12) {
                          utils.showWarningToast(context, text: "Please check aadhaar number");
                        } else if (pan.isNotEmpty && pan.length != 10) {
                          utils.showWarningToast(context, text: "Please check pan number");
                        } else {
                          _myFocusScopeNode.unfocus();
                          empProvider.tabController?.animateTo(2);
                        }
                      }, isLoading: false,text: "Next",controller: empProvider.signCtr,
                      backgroundColor: colorsConst.primary,radius: 10,
                      width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                ],
              )
              :empProvider.tabController!.index==2?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomLoadingButton(
                      callback: (){
                        _myFocusScopeNode.unfocus();
                        empProvider.tabController?.animateTo(1);
                      }, isLoading: false,text: "Back",
                      backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                      width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                  CustomLoadingButton(
                      callback: (){
                        if (empProvider.permanentPin.text.trim().isNotEmpty &&
                            empProvider.permanentPin.text.trim().length != 6) {
                          utils.showWarningToast(context, text: "Please check pincode");
                        }else {
                          _myFocusScopeNode.unfocus();
                          empProvider.tabController?.animateTo(3);
                        }
                      }, isLoading: false,text: "Next",controller: empProvider.signCtr,
                      backgroundColor: colorsConst.primary,radius: 10,
                      width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                ],
              )
              :empProvider.tabController!.index==3?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomLoadingButton(
                      callback: (){
                        _myFocusScopeNode.unfocus();
                        empProvider.tabController?.animateTo(2);
                      }, isLoading: false,text: "Back",
                      backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                      width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                  CustomLoadingButton(
                      callback: (){
                        if (empProvider.signEmPh.text.trim().isNotEmpty &&
                            empProvider.signEmPh.text.trim().length != 10) {
                          utils.showWarningToast(context, text: "Please check phone number");
                        }else {
                          _myFocusScopeNode.unfocus();
                          empProvider.tabController?.animateTo(4);
                        }
                      }, isLoading: false,text: "Next",controller: empProvider.signCtr,
                      backgroundColor: colorsConst.primary,radius: 10,
                      width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                ],
              )
              :empProvider.tabController!.index==4?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomLoadingButton(
                      callback: (){
                        _myFocusScopeNode.unfocus();
                        empProvider.tabController?.animateTo(3);
                      }, isLoading: false,text: "Back",
                      backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                      width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                  CustomLoadingButton(
                      callback: (){
                        _myFocusScopeNode.unfocus();
                        empProvider.tabController?.animateTo(5);
                      }, isLoading: false,text: "Next",controller: empProvider.signCtr,
                      backgroundColor: colorsConst.primary,radius: 10,
                      width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                ],
              )
              :empProvider.tabController!.index==5?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomLoadingButton(
                      callback: (){
                        _myFocusScopeNode.unfocus();
                        empProvider.tabController?.animateTo(4);
                      }, isLoading: false,text: "Back",
                      backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                      width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                  CustomLoadingButton(
                      callback: (){
                        if (empProvider.signRePh1.text.trim().isNotEmpty &&
                            empProvider.signRePh1.text.trim().length != 10) {
                          utils.showWarningToast(context, text: "Please check reference 1 phone number");
                        }else if (empProvider.signRePh2.text.trim().isNotEmpty &&
                            empProvider.signRePh2.text.trim().length != 10) {
                          utils.showWarningToast(context, text: "Please check reference 2 phone number");
                        }else {
                          _myFocusScopeNode.unfocus();
                          empProvider.tabController?.animateTo(6);
                        }
                      }, isLoading: false,text: "Next",controller: empProvider.signCtr,
                      backgroundColor: colorsConst.primary,radius: 10,
                      width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                ],
              )
              :Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomLoadingButton(
                      callback: (){
                        Future.microtask(() => Navigator.pop(context));
                      }, isLoading: false,text: "Cancel",
                      backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                      width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                  CustomLoadingButton(
                      callback: (){
                        final email = empProvider.signEmailid.text.trim();
                        final aadhar = empProvider.signAadhar.text.trim();
                        final pan = empProvider.signPan.text.trim();
                        final permanentPin = empProvider.permanentPin.text.trim();
                        final signEmPh = empProvider.signEmPh.text.trim();
                        final signRePh1 = empProvider.signRePh1.text.trim();
                        final signRePh2 = empProvider.signRePh2.text.trim();

                        if (empProvider.signFirstName.text.trim().isEmpty) {
                          utils.showWarningToast(context, text: "Please fill first name");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signMobileNumber.text.trim().isEmpty) {
                          utils.showWarningToast(context, text: "Please fill mobile number");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signMobileNumber.text.trim().length != 10) {
                          utils.showWarningToast(context, text: "Please check mobile number");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signPassword.text.trim().isEmpty) {
                          utils.showWarningToast(context, text: "Please fill password");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signPassword.text.trim().length < 8) {
                          utils.showWarningToast(context, text: "Password must be at least 8 characters");
                          empProvider.signCtr.reset();
                        } else if (empProvider.role == null) {
                          utils.showWarningToast(context, text: "Please select role");
                          empProvider.signCtr.reset();
                        } else if (empProvider.pinCode.text.trim().isNotEmpty &&
                            empProvider.pinCode.text.trim().length != 6) {
                          utils.showWarningToast(context, text: "Please check pincode");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signWhatsappNumber.text.trim().isNotEmpty &&
                            empProvider.signWhatsappNumber.text.trim().length != 10) {
                          utils.showWarningToast(context, text: "Please check whatsapp number");
                          empProvider.signCtr.reset();
                        }else if (email.isNotEmpty &&
                            !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
                          utils.showWarningToast(context, text: "Please check email id");
                          empProvider.signCtr.reset();
                        } else if (aadhar.isNotEmpty && aadhar.length != 12) {
                          utils.showWarningToast(context, text: "Please check aadhaar number");
                          empProvider.signCtr.reset();
                        } else if (pan.isNotEmpty && pan.length != 10) {
                          utils.showWarningToast(context, text: "Please check pan number");
                          empProvider.signCtr.reset();
                        }else if (permanentPin.isNotEmpty && permanentPin.length != 6) {
                          utils.showWarningToast(context, text: "Please check permanent address pincode");
                          empProvider.signCtr.reset();
                        }else if (signEmPh.isNotEmpty && signEmPh.length != 10) {
                          utils.showWarningToast(context, text: "Please check phone number");
                          empProvider.signCtr.reset();
                        }else if (signRePh1.isNotEmpty &&signRePh1.length != 10) {
                          utils.showWarningToast(context, text: "Please check reference 1 phone number");
                          empProvider.signCtr.reset();
                        }else if (signRePh2.isNotEmpty &&signRePh2.length != 10) {
                          utils.showWarningToast(context, text: "Please check reference 2 phone number");
                          empProvider.signCtr.reset();
                        }else{
                          _myFocusScopeNode.unfocus();
                          empProvider.insertEmployeeDetails(context, locPvr.latitude, locPvr.longitude);
                        }
                      }, isLoading: true,text: "Save",controller: empProvider.signCtr,
                      backgroundColor: colorsConst.primary,radius: 10,
                      width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                ],
          ),
            ),
            body: Center(
              child: SizedBox(
                width: kIsWeb?webWidth:phoneWidth,
                child: Column(
                  children: [
                    Container(
                        height: 8,
                        decoration: customDecoration.baseBackgroundDecoration(
                            color: Colors.transparent,
                            radius: 10
                        ),
                        child: TabBar(
                          controller: empProvider.tabController,
                          indicatorSize: TabBarIndicatorSize.label,
                          indicatorWeight: 0,
                          indicator: customDecoration.baseBackgroundDecoration(
                              color: colorsConst.primary,
                              radius: 30
                          ),
                          onTap: (int index){
                            empProvider.updateIndex(index);
                          },
                          labelColor: Colors.green,
                          unselectedLabelColor: Colors.green,
                          tabs:  [
                            Tab(child:Container(color:empProvider.swipeIndex==0?colorsConst.primary:Colors.grey.shade300,width: 35,height: 5,)),
                            Tab(child:Container(color:empProvider.swipeIndex==1?colorsConst.primary:Colors.grey.shade300,width: 35,height: 5,)),
                            Tab(child:Container(color:empProvider.swipeIndex==2?colorsConst.primary:Colors.grey.shade300,width: 35,height: 5,)),
                            Tab(child:Container(color:empProvider.swipeIndex==3?colorsConst.primary:Colors.grey.shade300,width: 35,height: 5,)),
                            Tab(child:Container(color:empProvider.swipeIndex==4?colorsConst.primary:Colors.grey.shade300,width: 25,height: 5,)),
                            Tab(child:Container(color:empProvider.swipeIndex==5?colorsConst.primary:Colors.grey.shade300,width: 25,height: 5,)),
                            Tab(child:Container(color:empProvider.swipeIndex==6?colorsConst.primary:Colors.grey.shade300,width: 25,height: 5,)),
                          ],
                        )
                    ),10.height,
                    CustomText(text:
                    empProvider.swipeIndex==0||empProvider.swipeIndex==1?"Personal Information\n"
                        :empProvider.swipeIndex==2?"Permanent Address\n"
                        :empProvider.swipeIndex==3?"Emergency Contact Information\n"
                        :empProvider.swipeIndex==4?"Job Information\n"
                        :empProvider.swipeIndex==5?"Reference\n"
                        :"KYC\n",
                      colors: Colors.black,size: 15,isBold: true,),
                    Expanded(
                      child: TabBarView(
                          controller: empProvider.tabController,
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      _myFocusScopeNode.unfocus();
                                      empProvider.signDialog(
                                        context: context,
                                        img: empProvider.profile,
                                        imgName: empProvider.profileName,
                                        imgList: empProvider.profileList,
                                        docType: "profile",
                                        onPicked: empProvider.setDocument,
                                        onRemove: empProvider.removeDocument,
                                      );
                                    },
                                    child: Container(
                                      width: 80,height: 80,
                                      decoration: customDecoration.baseBackgroundDecoration(
                                          color: Colors.grey,radius: 80,borderColor: colorsConst.primary
                                      ),
                                      child: empProvider.profile==""?CircleAvatar(
                                          radius: 40,
                                          backgroundColor: Colors.grey.shade100,
                                          child: SvgPicture.asset(assets.profile,width: 80,height: 80,)
                                      ):CircleAvatar(
                                          radius: 40,
                                          backgroundColor: Colors.white,
                                          // backgroundImage: kIsWeb?Image.memory(base64Decode(empProvider.profile)):FileImage(File(empProvider.profile))
                                          backgroundImage: kIsWeb?MemoryImage(base64Decode(empProvider.profile)):FileImage(File(empProvider.profile))
                                      ),
                                    ),
                                  ),
                                  30.height,
                                  Row(
                                    children: [
                                      CustomDropDown(
                                        color: colorsConst.primary,isRequired: true,
                                        text: constValue.firstName,saveValue: empProvider.signPrefix,valueList: empProvider.prefix,
                                        onChanged: (value) {
                                          empProvider.changePrefix(value);
                                        },
                                        width: kIsWeb?webWidth/6.4:phoneWidth/4,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        child: CustomTextField(text: "",
                                          controller: empProvider.signFirstName,
                                          width: kIsWeb?webWidth/1.2:phoneWidth/1.34,
                                        ),
                                      ),
                                    ],
                                  ),
                                  CustomTextField(
                                    text: constValue.middleName, controller: empProvider.signMiddleName,
                                    width: kIsWeb?webWidth:phoneWidth,
                                  ),
                                  CustomTextField(
                                    text: constValue.lastName, controller: empProvider.signLastName,
                                    width: kIsWeb?webWidth:phoneWidth,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomTextField(text: constValue.phoneNumber2,
                                        controller: empProvider.signMobileNumber,
                                        isRequired: true,isLogin: true,
                                        iconCallBack: (){
                                          empProvider.isWhatsAppCheck(isUpdate: true);
                                        },
                                        onChanged: (value){
                                          empProvider.isWhatsAppCheck(isUpdate: false);
                                        },
                                        iconData: Icons.check_circle,
                                        iconColor: empProvider.isWhatsApp==true?Colors.green:Colors.grey,
                                        width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: constInputFormatters.mobileNumberInput,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: CustomTextField(text: constValue.whatsappNo,
                                          controller: empProvider.signWhatsappNumber,
                                          width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.mobileNumberInput,
                                        ),
                                      ),
                                    ],
                                  ),
                                  CustomTextField(text: constValue.password,
                                    controller: empProvider.signPassword,
                                    isRequired: true,
                                    width: kIsWeb?webWidth:phoneWidth,
                                    keyboardType: TextInputType.visiblePassword,
                                    inputFormatters: constInputFormatters.passwordInput,
                                    textCapitalization: TextCapitalization.none,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomTextField(text: constValue.dateOfBirth,
                                        controller: empProvider.signDob,
                                        width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                        readOnly: true,
                                        onTap: (){
                                          utils.datePick(context: context,textEditingController: empProvider.signDob,isDob: true);
                                        },
                                      ),
                                      CustomTextField(text: constValue.dateOfJoin,
                                        controller: empProvider.signJoiningDate,
                                        width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                        readOnly: true,
                                        onTap: (){
                                          utils.datePick(context: context,textEditingController: empProvider.signJoiningDate);
                                        },
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      MapDropDown(
                                        isRefresh: empProvider.roleValues.isEmpty?true:false,
                                        callback: (){
                                          empProvider.refreshRoles();
                                        },
                                        isHint: true,
                                        width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                        isRequired: true,
                                        hintText: "Role",
                                        list: empProvider.roleValues,
                                        saveValue: empProvider.role,
                                        onChanged: (Object? value) {
                                          empProvider.changeRole(value);
                                        },
                                        dropText: 'role',),
                                      MapDropDown(
                                        isRefresh: empProvider.gradeValues.isEmpty?true:false,
                                        callback: (){
                                          if (empProvider.gradeValues.isEmpty) {
                                            utils.showWarningToast(
                                              context,
                                              text: "Please go to Settings to add a grade and its amount before proceeding",
                                            );
                                          } else {
                                            empProvider.getGrades(false);
                                          }
                                        },
                                        isHint: true,
                                        width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                        hintText: "Grade",
                                        list: empProvider.gradeValues,
                                        saveValue: empProvider.grade,
                                        onChanged: (Object? value) {
                                          empProvider.changeGrade(value,false);
                                        },
                                        dropText: 'grade',),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomTextField(
                                        text: constValue.bloodGroup,
                                        controller: empProvider.blood,
                                        width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                      ),
                                      CustomTextField(
                                        text: "Salary",
                                        inputFormatters: constInputFormatters.amtInput,
                                        keyboardType: TextInputType.number,
                                        controller: empProvider.salary,
                                        width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                        textInputAction: TextInputAction.done,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          _myFocusScopeNode.unfocus();
                                          if(locPvr.latitude==""&&locPvr.longitude==""){
                                            await locPvr.manageLocation(context,true);
                                          }else{
                                            if(!kIsWeb){
                                              utils.navigatePage(context, ()=> const EmpViaMap());
                                            }
                                          }
                                        },
                                        child: Icon(
                                            Icons.location_on_sharp, color: colorsConst.appDarkGreen),
                                      ),
                                    ],
                                  ),
                                  CustomTextField(
                                    text: constValue.addressNo,
                                    width: kIsWeb?webWidth:phoneWidth,
                                    // inputFormatters: constInputFormatters.addressInput,
                                    controller: empProvider.doorNo,
                                  ),
                                  CustomTextField(
                                    text: constValue.streetAddress,
                                    width: kIsWeb?webWidth:phoneWidth,
                                    // inputFormatters: constInputFormatters.addressInput,
                                    controller: empProvider.streetName,
                                  ),
                                  CustomTextField(
                                    text: constValue.area,
                                    width: kIsWeb?webWidth:phoneWidth,
                                    // inputFormatters: constInputFormatters.addressInput,
                                    controller: empProvider.comArea,
                                  ),
                                  SizedBox(
                                    width: kIsWeb?webWidth:phoneWidth,
                                    height: 85,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextField(
                                          text: constValue.city,
                                          inputFormatters: constInputFormatters.textInput,
                                          controller: empProvider.city,
                                          width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                        ),
                                        CustomDropDown(
                                          size: 15,
                                          color: Colors.white,
                                          text: "State",
                                          saveValue: empProvider.state,
                                          valueList: empProvider.stateList,
                                          onChanged: (value) {
                                            empProvider.changeState(value);
                                          },
                                          width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomTextField(
                                        text: constValue.pinCode,
                                        inputFormatters: constInputFormatters
                                            .pinCodeInput,
                                        keyboardType: TextInputType.number,
                                        controller: empProvider.pinCode,
                                        width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                      ),
                                      CustomTextField(
                                        text: constValue.country,
                                        inputFormatters: constInputFormatters.textInput,
                                        controller: empProvider.country,
                                        width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                        textInputAction: TextInputAction.done,
                                      ),
                                    ],
                                  ),
                                  20.height,
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     CustomLoadingButton(
                                  //         callback: (){
                                  //             if (empProvider.signFirstName.text.trim().isEmpty) {
                                  //               utils.showWarningToast(context, text: "Please fill first name");
                                  //             } else if (empProvider.signMobileNumber.text.trim().isEmpty) {
                                  //               utils.showWarningToast(context, text: "Please fill mobile number");
                                  //             } else if (empProvider.signMobileNumber.text.trim().length != 10) {
                                  //               utils.showWarningToast(context, text: "Please check mobile number");
                                  //             } else if (empProvider.signPassword.text.trim().isEmpty) {
                                  //               utils.showWarningToast(context, text: "Please fill password");
                                  //             } else if (empProvider.signPassword.text.trim().length < 6) {
                                  //               utils.showWarningToast(context, text: "Password must be at least 6 characters");
                                  //             } else if (empProvider.role == null) {
                                  //               utils.showWarningToast(context, text: "Please select role");
                                  //             } else if (empProvider.pinCode.text.trim().isNotEmpty &&
                                  //                 empProvider.pinCode.text.trim().length != 6) {
                                  //               utils.showWarningToast(context, text: "Please check pincode");
                                  //             } else if (empProvider.signWhatsappNumber.text.trim().isNotEmpty &&
                                  //                 empProvider.signWhatsappNumber.text.trim().length != 10) {
                                  //               utils.showWarningToast(context, text: "Please check whatsapp number");
                                  //             } else {
                                  //               _myFocusScopeNode.unfocus();
                                  //               empProvider.tabController?.animateTo(1);
                                  //             }
                                  //           }, isLoading: false,text: "Add More",
                                  //         backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                                  //         width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                                  //     CustomLoadingButton(
                                  //         callback: (){
                                  //           if (empProvider.signFirstName.text.trim().isEmpty) {
                                  //             utils.showWarningToast(context, text: "Please fill first name");
                                  //             empProvider.signCtr.reset();
                                  //           } else if (empProvider.signMobileNumber.text.trim().isEmpty) {
                                  //             utils.showWarningToast(context, text: "Please fill mobile number");
                                  //             empProvider.signCtr.reset();
                                  //           } else if (empProvider.signMobileNumber.text.trim().length != 10) {
                                  //             utils.showWarningToast(context, text: "Please check mobile number");
                                  //             empProvider.signCtr.reset();
                                  //           } else if (empProvider.signPassword.text.trim().isEmpty) {
                                  //             utils.showWarningToast(context, text: "Please fill password");
                                  //             empProvider.signCtr.reset();
                                  //           } else if (empProvider.signPassword.text.trim().length < 6) {
                                  //             utils.showWarningToast(context, text: "Password must be at least 6 characters");
                                  //             empProvider.signCtr.reset();
                                  //           } else if (empProvider.role == null) {
                                  //             utils.showWarningToast(context, text: "Please select role");
                                  //             empProvider.signCtr.reset();
                                  //           } else if (empProvider.pinCode.text.trim().isNotEmpty &&
                                  //               empProvider.pinCode.text.trim().length != 6) {
                                  //             utils.showWarningToast(context, text: "Please check pincode");
                                  //             empProvider.signCtr.reset();
                                  //           } else if (empProvider.signWhatsappNumber.text.trim().isNotEmpty &&
                                  //               empProvider.signWhatsappNumber.text.trim().length != 10) {
                                  //             utils.showWarningToast(context, text: "Please check whatsapp number");
                                  //             empProvider.signCtr.reset();
                                  //           } else {
                                  //             _myFocusScopeNode.unfocus();
                                  //             empProvider.insertEmployeeDetails(context, locPvr.latitude, locPvr.longitude);
                                  //           }
                                  //         }, isLoading: true,text: "Save",controller: empProvider.signCtr,
                                  //         backgroundColor: colorsConst.primary,radius: 10,
                                  //         width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                                  //   ],
                                  // ),
                                  // 50.height,
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  CustomTextField(text: constValue.emailId,
                                    textCapitalization: TextCapitalization.none,
                                    controller: empProvider.signEmailid,
                                    keyboardType: TextInputType.emailAddress,
                                    width: kIsWeb?webWidth:phoneWidth,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      DocumentContainer(
                                        text:"Aadhaar Card\n( Front )",
                                        imageValue:empProvider.aadharPhoto, callback: () {
                                        _myFocusScopeNode.unfocus();
                                        empProvider.signDialog(
                                          context: context,
                                          img: empProvider.aadharPhoto,
                                          imgName: empProvider.aadharPhotoName,
                                          imgList: empProvider.aadharPhotoList,
                                          docType: "aadhar",
                                          onPicked: empProvider.setDocument,
                                          onRemove: empProvider.removeDocument,
                                        );
                                      },
                                      ),
                                      DocumentContainer(
                                        text:"    Aadhaar Card\n( Back Optional )",
                                        imageValue:empProvider.aadharPhoto2, callback: () {
                                        _myFocusScopeNode.unfocus();
                                        empProvider.signDialog(
                                          context: context,
                                          img: empProvider.aadharPhoto2,
                                          imgName: empProvider.aadharPhotoName2,
                                          imgList: empProvider.aadharPhotoList2,
                                          docType: "aadhar2",
                                          onPicked: empProvider.setDocument,
                                          onRemove: empProvider.removeDocument,
                                        );
                                      },
                                      ),
                                      DocumentContainer(
                                        text:"PAN \nCard",
                                        imageValue:empProvider.panPhoto,callback: ()  {
                                        _myFocusScopeNode.unfocus();
                                        empProvider.signDialog(
                                          context: context,
                                          img: empProvider.panPhoto,
                                          imgName: empProvider.panPhotoName,
                                          imgList: empProvider.panPhotoList,
                                          docType: "pan",
                                          onPicked: empProvider.setDocument,
                                          onRemove: empProvider.removeDocument,
                                        );
                                      },
                                      ),
                                    ],
                                  ),
                                  CustomTextField(text: "Aadhaar Number",controller: empProvider.signAadhar,
                                    inputFormatters: constInputFormatters.aadharInput,
                                    width: kIsWeb?webWidth:phoneWidth,
                                    keyboardType: TextInputType.number,
                                  ),
                                  CustomTextField(text: "PAN Number",controller: empProvider.signPan,
                                    width: kIsWeb?webWidth:phoneWidth,
                                    textCapitalization: TextCapitalization.characters,
                                    inputFormatters: constInputFormatters.panInput,
                                  ),
                                  CustomDropDown(
                                    color: Colors.grey.shade100,
                                    text: "House Type",saveValue: empProvider.houseType,valueList: empProvider.houseTypeList,
                                    onChanged: (value) {
                                      empProvider.changeHouseType(value);
                                    },
                                    width: kIsWeb?webWidth:phoneWidth,
                                  ),
                                  CustomDropDown(
                                    color: Colors.grey.shade100,
                                    text: "Marital Status",saveValue: empProvider.maritalStatus,valueList: empProvider.maritalList,
                                    onChanged: (value) {
                                      empProvider.changeMaritalStatus(value);
                                    },
                                    width: kIsWeb?webWidth:phoneWidth,
                                  ),
                                  CustomDropDown(
                                    color: Colors.grey.shade100,
                                    text: "Relationship",saveValue: empProvider.relation,valueList: empProvider.relationList,
                                    onChanged: (value)  {
                                      empProvider.changeRelation(value);
                                    },
                                    width: kIsWeb?webWidth:phoneWidth,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomDropDown(
                                        color: colorsConst.primary,
                                        text: "Full Name",saveValue: empProvider.signSpousePrefix,valueList: empProvider.prefix,
                                        onChanged: (value) {
                                          empProvider.changePrefix2(value);
                                        },
                                        width: kIsWeb?webWidth/6.4:phoneWidth/4,
                                      ),
                                      CustomTextField(text: "",controller: empProvider.signSpFirstname,
                                        width: kIsWeb?webWidth/1.2:phoneWidth/1.35,
                                        // inputFormatters: constInputFormatters.textInput,
                                        textInputAction: TextInputAction.done,
                                      ),
                                    ],
                                  ),
                                  20.height,
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     CustomLoadingButton(
                                  //         callback: (){
                                  //           _myFocusScopeNode.unfocus();
                                  //           empProvider.tabController?.animateTo(0);
                                  //         }, isLoading: false,text: "Back",
                                  //         backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                                  //         width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                                  //     CustomLoadingButton(
                                  //         callback: (){
                                  //           final email = empProvider.signEmailid.text.trim();
                                  //           final aadhar = empProvider.signAadhar.text.trim();
                                  //           final pan = empProvider.signPan.text.trim();
                                  //
                                  //           if (email.isNotEmpty &&
                                  //               !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
                                  //             utils.showWarningToast(context, text: "Please check email id");
                                  //           } else if (aadhar.isNotEmpty && aadhar.length != 12) {
                                  //             utils.showWarningToast(context, text: "Please check aadhaar number");
                                  //           } else if (pan.isNotEmpty && pan.length != 10) {
                                  //             utils.showWarningToast(context, text: "Please check pan number");
                                  //           } else {
                                  //             _myFocusScopeNode.unfocus();
                                  //             empProvider.tabController?.animateTo(2);
                                  //           }
                                  //           }, isLoading: false,text: "Next",controller: empProvider.signCtr,
                                  //         backgroundColor: colorsConst.primary,radius: 10,
                                  //         width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                                  //   ],
                                  // ),50.height,
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                                child:
                                Column(
                                  children: [
                                    10.height,
                                    Center(
                                      child: SizedBox(
                                        // color:Colors.yellow,
                                        width: kIsWeb?webWidth:phoneWidth,
                                        child: CustomCheckBox(
                                          text:"Copy From Present Address?",
                                          onChanged: (bool? value) {
                                            empProvider.addressCheck(value);
                                          },
                                          saveValue: empProvider.isPermanentAdd,),
                                      ),
                                    ),
                                    10.height,
                                    CustomTextField(text: "Door No",controller: empProvider.permanentDoNo,
                                      width: kIsWeb?webWidth:phoneWidth,
                                      keyboardType: TextInputType.multiline,
                                    ),
                                    CustomTextField(text: "Street Name",controller: empProvider.permanentStreet,
                                      width: kIsWeb?webWidth:phoneWidth,
                                      keyboardType: TextInputType.multiline,
                                    ),
                                    CustomTextField(text: "Area",controller: empProvider.permanentArea,
                                      width: kIsWeb?webWidth:phoneWidth,
                                      keyboardType: TextInputType.multiline,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextField(text: "City",controller: empProvider.permanentCity,
                                          width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                        ),
                                        CustomDropDown(
                                          size: 15,
                                          color: Colors.grey.shade100,
                                          text: "State",saveValue: empProvider.permanentState,valueList: empProvider.stateList,
                                          onChanged: (value)  {
                                            empProvider.changeState2(value);
                                          },
                                          width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextField(text: "Country",controller: empProvider.permanentCountry,
                                          inputFormatters: constInputFormatters.numTextInput,
                                          width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                        ),
                                        CustomTextField(text: "Pincode",controller: empProvider.permanentPin,
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.done,
                                          inputFormatters: constInputFormatters.pinCodeInput,
                                          width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                        ),
                                      ],
                                    ),
                                    // 50.height,
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     CustomLoadingButton(
                                    //         callback: (){
                                    //           _myFocusScopeNode.unfocus();
                                    //           empProvider.tabController?.animateTo(1);
                                    //         }, isLoading: false,text: "Back",
                                    //         backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                                    //         width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                                    //     CustomLoadingButton(
                                    //         callback: (){
                                    //           if (empProvider.permanentPin.text.trim().isNotEmpty &&
                                    //               empProvider.permanentPin.text.trim().length != 6) {
                                    //             utils.showWarningToast(context, text: "Please check pincode");
                                    //           }else {
                                    //             _myFocusScopeNode.unfocus();
                                    //             empProvider.tabController?.animateTo(3);
                                    //           }
                                    //         }, isLoading: false,text: "Next",controller: empProvider.signCtr,
                                    //         backgroundColor: colorsConst.primary,radius: 10,
                                    //         width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                                    //   ],
                                    // ),
                                  ],
                                )
                            ),
                            SingleChildScrollView(
                                child:
                                Column(
                                  children: [
                                    CustomTextField(text: "Full Name",controller: empProvider.signEmFname,
                                      width: kIsWeb?webWidth:phoneWidth,
                                    ),
                                    CustomTextField(text: "Phone Number",controller: empProvider.signEmPh,
                                      width: kIsWeb?webWidth:phoneWidth,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: constInputFormatters.mobileNumberInput,
                                    ),
                                    CustomTextField(text: "Relation",controller: empProvider.signEmRelation,
                                      width: kIsWeb?webWidth:phoneWidth,
                                      textInputAction: TextInputAction.done,
                                    ),
                                    // 50.height,
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     CustomLoadingButton(
                                    //         callback: (){
                                    //           _myFocusScopeNode.unfocus();
                                    //           empProvider.tabController?.animateTo(2);
                                    //         }, isLoading: false,text: "Back",
                                    //         backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                                    //         width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                                    //     CustomLoadingButton(
                                    //         callback: (){
                                    //           if (empProvider.signEmPh.text.trim().isNotEmpty &&
                                    //               empProvider.signEmPh.text.trim().length != 10) {
                                    //             utils.showWarningToast(context, text: "Please check phone number");
                                    //           }else {
                                    //             _myFocusScopeNode.unfocus();
                                    //             empProvider.tabController?.animateTo(4);
                                    //           }
                                    //         }, isLoading: false,text: "Next",controller: empProvider.signCtr,
                                    //         backgroundColor: colorsConst.primary,radius: 10,
                                    //         width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                                    //   ],
                                    // ),
                                  ],
                                )
                            ),
                            SingleChildScrollView(
                                child:
                                Column(
                                  children: [
                                    CustomTextField(text: "Last Organization",controller: empProvider.signLastOrganization,
                                      width: kIsWeb?webWidth:phoneWidth,
                                    ),
                                    // CustomTextField(text: "Person name who referred you in Lending Paisa",controller: empProvider.signReffered,
                                    CustomTextField(text: "Referred By",controller: empProvider.signReffered,
                                      width: kIsWeb?webWidth:phoneWidth,
                                      textInputAction: TextInputAction.done,
                                    ),
                                    // 50.height,
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     CustomLoadingButton(
                                    //         callback: (){
                                    //           _myFocusScopeNode.unfocus();
                                    //           empProvider.tabController?.animateTo(3);
                                    //         }, isLoading: false,text: "Back",
                                    //         backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                                    //         width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                                    //     CustomLoadingButton(
                                    //         callback: (){
                                    //           _myFocusScopeNode.unfocus();
                                    //           empProvider.tabController?.animateTo(5);
                                    //         }, isLoading: false,text: "Next",controller: empProvider.signCtr,
                                    //         backgroundColor: colorsConst.primary,radius: 10,
                                    //         width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                                    //   ],
                                    // ),
                                  ],
                                )
                            ),
                            SingleChildScrollView(
                                child:
                                Column(
                                  children: [
                                    CustomTextField(text: "Reference 1 Full Name",controller: empProvider.signReFname1,
                                      width: kIsWeb?webWidth:phoneWidth,
                                    ),
                                    CustomTextField(text: "Reference 1 Phone Number",controller: empProvider.signRePh1,
                                        keyboardType: TextInputType.phone,
                                        width: kIsWeb?webWidth:phoneWidth,
                                        inputFormatters: constInputFormatters.mobileNumberInput,
                                    ),
                                    CustomTextField(text: "Reference 2 Full Name",controller: empProvider.signReFname2,
                                      width: kIsWeb?webWidth:phoneWidth,
                                    ),
                                    CustomTextField(text: "Reference 2 Phone Number",controller: empProvider.signRePh2,
                                        keyboardType: TextInputType.phone,
                                        width: kIsWeb?webWidth:phoneWidth,
                                        inputFormatters: constInputFormatters.mobileNumberInput,
                                        textInputAction: TextInputAction.done,
                                    ),
                                    // 50.height,
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     CustomLoadingButton(
                                    //         callback: (){
                                    //           _myFocusScopeNode.unfocus();
                                    //           empProvider.tabController?.animateTo(4);
                                    //         }, isLoading: false,text: "Back",
                                    //         backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                                    //         width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                                    //     CustomLoadingButton(
                                    //         callback: (){
                                    //           if (empProvider.signRePh1.text.trim().isNotEmpty &&
                                    //               empProvider.signRePh1.text.trim().length != 10) {
                                    //             utils.showWarningToast(context, text: "Please check reference 1 phone number");
                                    //           }else if (empProvider.signRePh2.text.trim().isNotEmpty &&
                                    //               empProvider.signRePh2.text.trim().length != 10) {
                                    //             utils.showWarningToast(context, text: "Please check reference 2 phone number");
                                    //           }else {
                                    //             _myFocusScopeNode.unfocus();
                                    //             empProvider.tabController?.animateTo(6);
                                    //           }
                                    //         }, isLoading: false,text: "Next",controller: empProvider.signCtr,
                                    //         backgroundColor: colorsConst.primary,radius: 10,
                                    //         width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                                    //   ],
                                    // ),
                                  ],
                                )
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(radius: 10,backgroundColor: empProvider.chequePhoto==""?Colors.grey:Colors.red,),
                                    Container(height: 1,width: kIsWeb?webWidth/2.5:phoneWidth/2.5,color: Colors.grey,),
                                    CircleAvatar(radius: 10,backgroundColor: empProvider.licensePhoto==""?Colors.grey:Colors.red,),
                                    Container(height: 1,width: kIsWeb?webWidth/2.5:phoneWidth/2.5,color: Colors.grey,),
                                    CircleAvatar(radius: 10,backgroundColor: empProvider.voterPhoto==""?Colors.grey:Colors.red,),
                                  ],
                                ),
                                5.height,
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(text: "Cheque",colors: Colors.grey,size: 14),
                                    CustomText(text: kIsWeb?"Voter (Optional)":"Voter\n(Optional)",colors: Colors.grey,size: 14),
                                    CustomText(text: kIsWeb?"License (Optional)":"License\n(Optional)",colors: Colors.grey,size: 14),
                                  ],
                                ),
                                25.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    DocumentContainer(
                                      text:"Cheque",
                                      imageValue:empProvider.chequePhoto, callback: () {
                                      _myFocusScopeNode.unfocus();
                                      empProvider.signDialog(
                                        context: context,
                                        img: empProvider.chequePhoto,
                                        imgName: empProvider.chequePhotoName,
                                        imgList: empProvider.chequePhotoList,
                                        docType: "cheque",
                                        onPicked: empProvider.setDocument,
                                        onRemove: empProvider.removeDocument,
                                      );
                                    },
                                    ),
                                    DocumentContainer(
                                      text:"License",
                                      imageValue:empProvider.licensePhoto, callback: () {
                                      _myFocusScopeNode.unfocus();
                                      empProvider.signDialog(
                                        context: context,
                                        img: empProvider.licensePhoto,
                                        imgName: empProvider.licensePhotoName,
                                        imgList: empProvider.licensePhotoList,
                                        docType: "license",
                                        onPicked: empProvider.setDocument,
                                        onRemove: empProvider.removeDocument,
                                      );
                                    },
                                    ),
                                    DocumentContainer(
                                      text:"Voter",
                                      imageValue:empProvider.voterPhoto, callback: () {
                                      _myFocusScopeNode.unfocus();
                                      empProvider.signDialog(
                                        context: context,
                                        img: empProvider.voterPhoto,
                                        imgName: empProvider.voterPhotoName,
                                        imgList: empProvider.voterPhotoList,
                                        docType: "voter",
                                        onPicked: empProvider.setDocument,
                                        onRemove: empProvider.removeDocument,
                                      );
                                    },
                                    ),
                                  ],
                                ),
                                // 70.height,
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     CustomLoadingButton(
                                //         callback: (){
                                //           Future.microtask(() => Navigator.pop(context));
                                //         }, isLoading: false,text: "Cancel",
                                //         backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                                //         width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                                //     CustomLoadingButton(
                                //         callback: (){
                                //           final email = empProvider.signEmailid.text.trim();
                                //           final aadhar = empProvider.signAadhar.text.trim();
                                //           final pan = empProvider.signPan.text.trim();
                                //           final permanentPin = empProvider.permanentPin.text.trim();
                                //           final signEmPh = empProvider.signEmPh.text.trim();
                                //           final signRePh1 = empProvider.signRePh1.text.trim();
                                //           final signRePh2 = empProvider.signRePh2.text.trim();
                                //
                                //           if (empProvider.signFirstName.text.trim().isEmpty) {
                                //             utils.showWarningToast(context, text: "Please fill first name");
                                //             empProvider.signCtr.reset();
                                //           } else if (empProvider.signMobileNumber.text.trim().isEmpty) {
                                //             utils.showWarningToast(context, text: "Please fill mobile number");
                                //             empProvider.signCtr.reset();
                                //           } else if (empProvider.signMobileNumber.text.trim().length != 10) {
                                //             utils.showWarningToast(context, text: "Please check mobile number");
                                //             empProvider.signCtr.reset();
                                //           } else if (empProvider.signPassword.text.trim().isEmpty) {
                                //             utils.showWarningToast(context, text: "Please fill password");
                                //             empProvider.signCtr.reset();
                                //           } else if (empProvider.signPassword.text.trim().length < 6) {
                                //             utils.showWarningToast(context, text: "Password must be at least 6 characters");
                                //             empProvider.signCtr.reset();
                                //           } else if (empProvider.role == null) {
                                //             utils.showWarningToast(context, text: "Please select role");
                                //             empProvider.signCtr.reset();
                                //           } else if (empProvider.pinCode.text.trim().isNotEmpty &&
                                //               empProvider.pinCode.text.trim().length != 6) {
                                //             utils.showWarningToast(context, text: "Please check pincode");
                                //             empProvider.signCtr.reset();
                                //           } else if (empProvider.signWhatsappNumber.text.trim().isNotEmpty &&
                                //               empProvider.signWhatsappNumber.text.trim().length != 10) {
                                //             utils.showWarningToast(context, text: "Please check whatsapp number");
                                //             empProvider.signCtr.reset();
                                //           }else if (email.isNotEmpty &&
                                //               !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
                                //             utils.showWarningToast(context, text: "Please check email id");
                                //             empProvider.signCtr.reset();
                                //           } else if (aadhar.isNotEmpty && aadhar.length != 12) {
                                //             utils.showWarningToast(context, text: "Please check aadhaar number");
                                //             empProvider.signCtr.reset();
                                //           } else if (pan.isNotEmpty && pan.length != 10) {
                                //             utils.showWarningToast(context, text: "Please check pan number");
                                //             empProvider.signCtr.reset();
                                //           }else if (permanentPin.isNotEmpty && permanentPin.length != 6) {
                                //             utils.showWarningToast(context, text: "Please check permanent address pincode");
                                //             empProvider.signCtr.reset();
                                //           }else if (signEmPh.isNotEmpty && signEmPh.length != 10) {
                                //             utils.showWarningToast(context, text: "Please check phone number");
                                //             empProvider.signCtr.reset();
                                //           }else if (signRePh1.isNotEmpty &&signRePh1.length != 10) {
                                //             utils.showWarningToast(context, text: "Please check reference 1 phone number");
                                //             empProvider.signCtr.reset();
                                //           }else if (signRePh2.isNotEmpty &&signRePh2.length != 10) {
                                //             utils.showWarningToast(context, text: "Please check reference 2 phone number");
                                //             empProvider.signCtr.reset();
                                //           }else{
                                //             _myFocusScopeNode.unfocus();
                                //             empProvider.insertEmployeeDetails(context, locPvr.latitude, locPvr.longitude);
                                //           }
                                //         }, isLoading: true,text: "Save",controller: empProvider.signCtr,
                                //         backgroundColor: colorsConst.primary,radius: 10,
                                //         width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                                //   ],
                                // ),
                              ],
                            ),
                          ]
                      )),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}



