import 'dart:convert';
import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:master_code/view_model/location_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/component/custom_textfield.dart';
import 'package:master_code/screens/employee/viamap.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/constant/key_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_checkbox.dart';
import '../../component/custom_dropdown.dart';
import '../../component/custom_network_image.dart';
import '../../component/custom_text.dart';
import '../../component/document_container.dart';
import '../../component/map_dropdown.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/employee_provider.dart';

class UpdatedEmployee extends StatefulWidget {
  final String id;
  final bool isDetailView;
  const UpdatedEmployee({super.key, required this.id, required this.isDetailView});

  @override
  State<UpdatedEmployee> createState() => _UpdatedEmployeeState();
}

class _UpdatedEmployeeState extends State<UpdatedEmployee> with TickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  @override
  void initState() {
    Provider.of<EmployeeProvider>(context, listen: false).tabController=TabController(length:7, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeProvider>(context, listen: false).tabController?.addListener(() {
        _myFocusScopeNode.unfocus();
        Provider.of<EmployeeProvider>(context, listen: false).updateIndex(Provider.of<EmployeeProvider>(context, listen: false).tabController!.index);
      });
      Provider.of<EmployeeProvider>(context, listen: false).getUserDetails(id: widget.id);
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
            appBar:  PreferredSize(
              preferredSize: Size(300, 50),
              child: CustomAppbar(text: constValue.updateEmployee,),
            ),
            backgroundColor: colorsConst.bacColor,
            bottomNavigationBar: Container(
              width: kIsWeb ? webWidth : phoneWidth,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: empProvider.tabController!.index == 0
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomLoadingButton(
                      callback: () {
                        if (empProvider.signFirstName.text.trim().isEmpty) {
                          utils.showWarningToast(context, text: "${constValue.fillFirstName}");
                        } else if (empProvider.signMobileNumber.text.trim().isEmpty) {
                          utils.showWarningToast(context, text: "${constValue.fillMobileNumber}");
                        } else if (empProvider.signMobileNumber.text.trim().length < 8 ||
                            empProvider.signMobileNumber.text.trim().length > 12) {
                          utils.showWarningToast(context, text: "${constValue.checkMobileNumber}");
                        } else if (empProvider.role == null) {
                          utils.showWarningToast(context, text: "${constValue.selectRole}");
                        } else if (empProvider.pinCode.text.trim().isNotEmpty &&
                            empProvider.pinCode.text.trim().length != 6) {
                          utils.showWarningToast(context, text: "${constValue.checkPincode}");
                        } else if (empProvider.signWhatsappNumber.text.trim().isNotEmpty &&
                            empProvider.signWhatsappNumber.text.trim().length != 10) {
                          utils.showWarningToast(context, text: "${constValue.checkWhatsappNumber}");
                        } else {
                          _myFocusScopeNode.unfocus();
                          empProvider.tabController?.animateTo(1);
                        }
                      },
                      isLoading: false,
                      text: "${constValue.addMore}",
                      backgroundColor: Colors.white,
                      textColor: colorsConst.primary,
                      radius: 10,
                      width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1),
                  CustomLoadingButton(
                      callback: () {
                        if (empProvider.signFirstName.text.trim().isEmpty) {
                          utils.showWarningToast(context, text: "${constValue.fillFirstName}");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signMobileNumber.text.trim().isEmpty) {
                          utils.showWarningToast(context, text: "${constValue.fillMobileNumber}");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signMobileNumber.text.trim().length < 8 ||
                            empProvider.signMobileNumber.text.trim().length > 12) {
                          utils.showWarningToast(context, text: "${constValue.checkMobileNumber}");
                          empProvider.signCtr.reset();
                        } else if (empProvider.role == null) {
                          utils.showWarningToast(context, text: "${constValue.selectRole}");
                          empProvider.signCtr.reset();
                        } else if (empProvider.pinCode.text.trim().isNotEmpty &&
                            empProvider.pinCode.text.trim().length != 6) {
                          utils.showWarningToast(context, text: "${constValue.checkPincode}");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signWhatsappNumber.text.trim().isNotEmpty &&
                            empProvider.signWhatsappNumber.text.trim().length != 10) {
                          utils.showWarningToast(context, text: "${constValue.checkWhatsappNumber}");
                          empProvider.signCtr.reset();
                        } else {
                          _myFocusScopeNode.unfocus();
                          empProvider.updatedEmployee(context, widget.id, widget.isDetailView);
                        }
                      },
                      isLoading: true,
                      text: "${constValue.save}",
                      controller: empProvider.signCtr,
                      backgroundColor: colorsConst.primary,
                      radius: 10,
                      width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1),
                ],
              )
                  : empProvider.tabController!.index == 1
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomLoadingButton(
                      callback: () {
                        _myFocusScopeNode.unfocus();
                        empProvider.tabController?.animateTo(0);
                      },
                      isLoading: false,
                      text: "${constValue.back}",
                      backgroundColor: Colors.white,
                      textColor: colorsConst.primary,
                      radius: 10,
                      width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1),
                  CustomLoadingButton(
                      callback: () {
                        final email = empProvider.signEmailid.text.trim();
                        final aadhar = empProvider.signAadhar.text.trim();
                        final pan = empProvider.signPan.text.trim();

                        if (email.isNotEmpty &&
                            !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                .hasMatch(email)) {
                          utils.showWarningToast(context, text: "${constValue.checkEmail}");
                        } else if (aadhar.isNotEmpty && aadhar.length != 12) {
                          utils.showWarningToast(context, text: "${constValue.checkAadhaar}");
                        } else if (pan.isNotEmpty && pan.length != 10) {
                          utils.showWarningToast(context, text: "${constValue.checkPan}");
                        } else {
                          _myFocusScopeNode.unfocus();
                          empProvider.tabController?.animateTo(2);
                        }
                      },
                      isLoading: false,
                      text: "${constValue.next}",
                      controller: empProvider.signCtr,
                      backgroundColor: colorsConst.primary,
                      radius: 10,
                      width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1),
                ],
              )
                  : empProvider.tabController!.index == 2
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomLoadingButton(
                      callback: () {
                        _myFocusScopeNode.unfocus();
                        empProvider.tabController?.animateTo(1);
                      },
                      isLoading: false,
                      text: "${constValue.back}",
                      backgroundColor: Colors.white,
                      textColor: colorsConst.primary,
                      radius: 10,
                      width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1),
                  CustomLoadingButton(
                      callback: () {
                        if (empProvider.permanentPin.text.trim().isNotEmpty &&
                            empProvider.permanentPin.text.trim().length != 6) {
                          utils.showWarningToast(context, text: "${constValue.checkPincode}");
                        } else {
                          _myFocusScopeNode.unfocus();
                          empProvider.tabController?.animateTo(3);
                        }
                      },
                      isLoading: false,
                      text: "${constValue.next}",
                      controller: empProvider.signCtr,
                      backgroundColor: colorsConst.primary,
                      radius: 10,
                      width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1),
                ],
              )
                  : empProvider.tabController!.index == 3
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomLoadingButton(
                      callback: () {
                        _myFocusScopeNode.unfocus();
                        empProvider.tabController?.animateTo(2);
                      },
                      isLoading: false,
                      text: "${constValue.back}",
                      backgroundColor: Colors.white,
                      textColor: colorsConst.primary,
                      radius: 10,
                      width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1),
                  CustomLoadingButton(
                      callback: () {
                        if (empProvider.signEmPh.text.trim().isNotEmpty &&
                            empProvider.signEmPh.text.trim().length != 10) {
                          utils.showWarningToast(context, text: "${constValue.checkPhoneNumber}");
                        } else {
                          _myFocusScopeNode.unfocus();
                          empProvider.tabController?.animateTo(4);
                        }
                      },
                      isLoading: false,
                      text: "${constValue.next}",
                      controller: empProvider.signCtr,
                      backgroundColor: colorsConst.primary,
                      radius: 10,
                      width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1),
                ],
              )
                  : empProvider.tabController!.index == 4
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomLoadingButton(
                      callback: () {
                        _myFocusScopeNode.unfocus();
                        empProvider.tabController?.animateTo(3);
                      },
                      isLoading: false,
                      text: "${constValue.back}",
                      backgroundColor: Colors.white,
                      textColor: colorsConst.primary,
                      radius: 10,
                      width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1),
                  CustomLoadingButton(
                      callback: () {
                        _myFocusScopeNode.unfocus();
                        empProvider.tabController?.animateTo(5);
                      },
                      isLoading: false,
                      text: "${constValue.next}",
                      controller: empProvider.signCtr,
                      backgroundColor: colorsConst.primary,
                      radius: 10,
                      width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1),
                ],
              )
                  : empProvider.tabController!.index == 5
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomLoadingButton(
                      callback: () {
                        _myFocusScopeNode.unfocus();
                        empProvider.tabController?.animateTo(4);
                      },
                      isLoading: false,
                      text: "${constValue.back}",
                      backgroundColor: Colors.white,
                      textColor: colorsConst.primary,
                      radius: 10,
                      width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1),
                  CustomLoadingButton(
                      callback: () {
                        if (empProvider.signRePh1.text.trim().isNotEmpty &&
                            empProvider.signRePh1.text.trim().length != 10) {
                          utils.showWarningToast(context, text: "${constValue.checkRef1Phone}");
                        } else if (empProvider.signRePh2.text.trim().isNotEmpty &&
                            empProvider.signRePh2.text.trim().length != 10) {
                          utils.showWarningToast(context, text: "${constValue.checkRef2Phone}");
                        } else {
                          _myFocusScopeNode.unfocus();
                          empProvider.tabController?.animateTo(6);
                        }
                      },
                      isLoading: false,
                      text: "${constValue.next}",
                      controller: empProvider.signCtr,
                      backgroundColor: colorsConst.primary,
                      radius: 10,
                      width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomLoadingButton(
                      callback: () {
                        Future.microtask(() => Navigator.pop(context));
                      },
                      isLoading: false,
                      text: "${constValue.cancel}",
                      backgroundColor: Colors.white,
                      textColor: colorsConst.primary,
                      radius: 10,
                      width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1),
                  CustomLoadingButton(
                      callback: () {
                        final email = empProvider.signEmailid.text.trim();
                        final aadhar = empProvider.signAadhar.text.trim();
                        final pan = empProvider.signPan.text.trim();
                        final permanentPin = empProvider.permanentPin.text.trim();
                        final signEmPh = empProvider.signEmPh.text.trim();
                        final signRePh1 = empProvider.signRePh1.text.trim();
                        final signRePh2 = empProvider.signRePh2.text.trim();

                        if (empProvider.signFirstName.text.trim().isEmpty) {
                          utils.showWarningToast(context, text: "${constValue.fillFirstName}");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signMobileNumber.text.trim().isEmpty) {
                          utils.showWarningToast(context, text: "${constValue.fillMobileNumber}");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signMobileNumber.text.trim().length < 8 ||
                            empProvider.signMobileNumber.text.trim().length > 12) {
                          utils.showWarningToast(context, text: "${constValue.checkMobileNumber}");
                          empProvider.signCtr.reset();
                        } else if (empProvider.role == null) {
                          utils.showWarningToast(context, text: "${constValue.selectRole}");
                          empProvider.signCtr.reset();
                        } else if (empProvider.pinCode.text.trim().isNotEmpty &&
                            empProvider.pinCode.text.trim().length != 6) {
                          utils.showWarningToast(context, text: "${constValue.checkPincode}");
                          empProvider.signCtr.reset();
                        } else if (empProvider.signWhatsappNumber.text.trim().isNotEmpty &&
                            empProvider.signWhatsappNumber.text.trim().length != 10) {
                          utils.showWarningToast(context, text: "${constValue.checkWhatsappNumber}");
                          empProvider.signCtr.reset();
                        } else if (email.isNotEmpty &&
                            !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                .hasMatch(email)) {
                          utils.showWarningToast(context, text: "${constValue.checkEmail}");
                          empProvider.signCtr.reset();
                        } else if (aadhar.isNotEmpty && aadhar.length != 12) {
                          utils.showWarningToast(context, text: "${constValue.checkAadhaar}");
                          empProvider.signCtr.reset();
                        } else if (pan.isNotEmpty && pan.length != 10) {
                          utils.showWarningToast(context, text: "${constValue.checkPan}");
                          empProvider.signCtr.reset();
                        } else if (permanentPin.isNotEmpty && permanentPin.length != 6) {
                          utils.showWarningToast(context, text: "${constValue.checkPermanentPincode}");
                          empProvider.signCtr.reset();
                        } else if (signEmPh.isNotEmpty && signEmPh.length != 10) {
                          utils.showWarningToast(context, text: "${constValue.checkPhoneNumber}");
                          empProvider.signCtr.reset();
                        } else if (signRePh1.isNotEmpty && signRePh1.length != 10) {
                          utils.showWarningToast(context, text: "${constValue.checkRef1Phone}");
                          empProvider.signCtr.reset();
                        } else if (signRePh2.isNotEmpty && signRePh2.length != 10) {
                          utils.showWarningToast(context, text: "${constValue.checkRef2Phone}");
                          empProvider.signCtr.reset();
                        } else {
                          _myFocusScopeNode.unfocus();
                          empProvider.updatedEmployee(context, widget.id, widget.isDetailView);
                        }
                      },
                      isLoading: true,
                      text: "${constValue.save}",
                      controller: empProvider.signCtr,
                      backgroundColor: colorsConst.primary,
                      radius: 10,
                      width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1),
                ],
              ),
            ),

            body: Center(
              child: empProvider.refresh==false?const Loading()
                  :SizedBox(
                width: kIsWeb?webWidth:phoneWidth,
                child: Column(
                  children: [
                    20.height,
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
                    empProvider.swipeIndex==0||empProvider.swipeIndex==1?"${constValue.personalInformationE1}\n"
                        :empProvider.swipeIndex==2?"${constValue.addressEmpE1}\n"
                        :empProvider.swipeIndex==3?"${constValue.EmergencyContactE1}\n"
                        :empProvider.swipeIndex==4?"${constValue.jobInformationE1}\n"
                        :empProvider.swipeIndex==5?"${constValue.ReferenceE1}\n"
                        :"${constValue.kyc}\n",
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
                                          img: empProvider.profile==""?empProvider.oldImage:empProvider.profile,
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
                                            color: Colors.grey.shade200,radius: 80,borderColor: colorsConst.primary
                                        ),
                                        child: empProvider.profile!=""?CircleAvatar(
                                            radius: 40,
                                            backgroundColor: Colors.grey.shade200,
                                            backgroundImage: kIsWeb?MemoryImage(base64Decode(empProvider.profile)):FileImage(File(empProvider.profile))
                                        ):empProvider.oldImage.toString().contains("uUsSrR")?CircleAvatar(
                                            radius: 40,
                                            backgroundColor: Colors.grey.shade200,
                                            child: NetworkImg(image: empProvider.oldImage, width: 50,isTap: false,)
                                        ):CircleAvatar(
                                            radius: 40,
                                            backgroundColor: Colors.grey.shade200,
                                            child: SvgPicture.asset(assets.profile)
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
                                    SizedBox(
                                      width: kIsWeb?webWidth/1.02:phoneWidth/1.02,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(10),
                                                onTap: () {
                                                  showCountryPicker(
                                                    context: context,
                                                    showPhoneCode: true,
                                                    countryListTheme: CountryListThemeData(
                                                      bottomSheetHeight: MediaQuery.of(context).size.height * 0.7,
                                                    ),
                                                    onSelect: (Country country) {
                                                      empProvider.changeSignCountryCode("+${country.phoneCode}", country.flagEmoji);
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  height: 45,
                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    border: Border.all(color: Colors.grey.shade400),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(empProvider.selectedCountryFlag, style: const TextStyle(fontSize: 14)),
                                                      2.width,
                                                      Text(empProvider.selectedCountryCode, style: const TextStyle(fontSize: 12)),
                                                      const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          4.width,
                                          Expanded(
                                            child: CustomTextField(text: constValue.phoneNumber2,
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
                                              width: double.infinity,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: constInputFormatters.mobileNumberInput,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: CustomTextField(text: constValue.whatsappNo,
                                        controller: empProvider.signWhatsappNumber,
                                        width: kIsWeb?webWidth/1.02:phoneWidth/1.02,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: constInputFormatters.mobileNumberInput,
                                      ),
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
                                          hintText: constValue.roles,
                                          list: empProvider.roleValues,
                                          saveValue: empProvider.role??"",
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
                                                text: constValue.addGradeAmountFirst,
                                              );
                                            } else {
                                              empProvider.getGrades(false);
                                            }
                                          },
                                          isHint: true,
                                          width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                          hintText: constValue.grade,
                                          list: empProvider.gradeValues,
                                          saveValue: empProvider.grade??"",
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
                                          text: constValue.salary,
                                          inputFormatters: constInputFormatters.amtInput,
                                          keyboardType: TextInputType.number,
                                          controller: empProvider.salary,
                                          width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                          textInputAction: TextInputAction.done,
                                        ),
                                      ],
                                    ),
                                    CustomTextField(text: constValue.lastWrkDay,
                                      controller: empProvider.lastWorkingday,
                                      width: kIsWeb?webWidth:phoneWidth,
                                      readOnly: true,
                                      onTap: (){
                                        utils.datePick(context: context,textEditingController: empProvider.lastWorkingday);
                                      },
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            _myFocusScopeNode.unfocus();
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
                                      controller: empProvider.doorNo,
                                    ),
                                    CustomTextField(
                                      text: constValue.streetAddress,
                                      width: kIsWeb?webWidth:phoneWidth,
                                      controller: empProvider.streetName,
                                    ),
                                    CustomTextField(
                                      text: constValue.area,
                                      width: kIsWeb?webWidth:phoneWidth,
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
                                            text: constValue.state,
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
                                          text: constValue.aadhaarFront,
                                          imageValue:empProvider.aadharPhoto,
                                          netWrk: empProvider.oldImage2,
                                          callback: () {
                                            _myFocusScopeNode.unfocus();
                                            empProvider.signDialog(
                                              context: context,
                                              img: empProvider.aadharPhoto==""?empProvider.oldImage2:empProvider.aadharPhoto,
                                              imgName: empProvider.aadharPhotoName,
                                              imgList: empProvider.aadharPhotoList,
                                              docType: "aadhar",
                                              onPicked: empProvider.setDocument,
                                              onRemove: empProvider.removeDocument,
                                            );
                                          },
                                        ),
                                        DocumentContainer(
                                          text: constValue.aadhaarBack,
                                          imageValue:empProvider.aadharPhoto2,
                                          netWrk: empProvider.oldImage3,
                                          callback: () {
                                            _myFocusScopeNode.unfocus();
                                            empProvider.signDialog(
                                              context: context,
                                              img: empProvider.aadharPhoto2==""?empProvider.oldImage3:empProvider.aadharPhoto2,
                                              imgName: empProvider.aadharPhotoName2,
                                              imgList: empProvider.aadharPhotoList2,
                                              docType: "aadhar2",
                                              onPicked: empProvider.setDocument,
                                              onRemove: empProvider.removeDocument,
                                            );
                                          },
                                        ),
                                        DocumentContainer(
                                          text: constValue.panCard,
                                          imageValue:empProvider.panPhoto,
                                          netWrk: empProvider.oldImage4,
                                          callback: ()  {
                                            _myFocusScopeNode.unfocus();
                                            empProvider.signDialog(
                                              context: context,
                                              img: empProvider.panPhoto==""?empProvider.oldImage4:empProvider.panPhoto,
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
                                    CustomTextField(text: constValue.aadhaarNumber,controller: empProvider.signAadhar,
                                      inputFormatters: constInputFormatters.aadharInput,
                                      width: kIsWeb?webWidth:phoneWidth,
                                      keyboardType: TextInputType.number,
                                    ),
                                    CustomTextField(text: constValue.panNumber,controller: empProvider.signPan,
                                      width: kIsWeb?webWidth:phoneWidth,
                                      textCapitalization: TextCapitalization.characters,
                                      inputFormatters: constInputFormatters.panInput,
                                    ),
                                    CustomDropDown(
                                      color: Colors.grey.shade100,
                                      text: constValue.houseType,saveValue: empProvider.houseType,valueList: empProvider.houseTypeList,
                                      onChanged: (value) {
                                        empProvider.changeHouseType(value);
                                      },
                                      width: kIsWeb?webWidth:phoneWidth,
                                    ),
                                    CustomDropDown(
                                      color: Colors.grey.shade100,
                                      text: constValue.maritalStatus,saveValue: empProvider.maritalStatus,valueList: empProvider.maritalList,
                                      onChanged: (value) {
                                        empProvider.changeMaritalStatus(value);
                                      },
                                      width: kIsWeb?webWidth:phoneWidth,
                                    ),
                                    CustomDropDown(
                                      color: Colors.grey.shade100,
                                      text: constValue.relationship,saveValue: empProvider.relation,valueList: empProvider.relationList,
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
                                          text: constValue.fullName,saveValue: empProvider.signSpousePrefix,valueList: empProvider.prefix,
                                          onChanged: (value) {
                                            empProvider.changePrefix2(value);
                                          },
                                          width: kIsWeb?webWidth/6.4:phoneWidth/4,
                                        ),
                                        CustomTextField(text: "",controller: empProvider.signSpFirstname,
                                          width: kIsWeb?webWidth/1.2:phoneWidth/1.35,
                                          textInputAction: TextInputAction.done,
                                        ),
                                      ],
                                    ),
                                    20.height,
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
                                          width: kIsWeb?webWidth:phoneWidth,
                                          child: CustomCheckBox(
                                            text: constValue.copyPresentAddress,
                                            onChanged: (bool? value) {
                                              empProvider.addressCheck(value);
                                            },
                                            saveValue: empProvider.isPermanentAdd,),
                                        ),
                                      ),
                                      10.height,
                                      CustomTextField(text: constValue.doorNo,controller: empProvider.permanentDoNo,
                                        width: kIsWeb?webWidth:phoneWidth,
                                        keyboardType: TextInputType.multiline,
                                      ),
                                      CustomTextField(text: constValue.streetName,controller: empProvider.permanentStreet,
                                        width: kIsWeb?webWidth:phoneWidth,
                                        keyboardType: TextInputType.multiline,
                                      ),
                                      CustomTextField(text: constValue.area,controller: empProvider.permanentArea,
                                        width: kIsWeb?webWidth:phoneWidth,
                                        keyboardType: TextInputType.multiline,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          CustomTextField(text: constValue.city,controller: empProvider.permanentCity,
                                            width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                                          ),
                                          CustomDropDown(
                                            size: 15,
                                            color: Colors.grey.shade100,
                                            text: constValue.state,saveValue: empProvider.permanentState,valueList: empProvider.stateList,
                                            onChanged: (value)  {
                                              empProvider.changeState2(value);
                                            },
                                            width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          CustomTextField(text: constValue.country,controller: empProvider.permanentCountry,
                                            inputFormatters: constInputFormatters.numTextInput,
                                            width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                                          ),
                                          CustomTextField(text: constValue.pinCode,controller: empProvider.permanentPin,
                                            keyboardType: TextInputType.number,
                                            textInputAction: TextInputAction.done,
                                            inputFormatters: constInputFormatters.pinCodeInput,
                                            width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                                          ),
                                        ],
                                      ),50.height,
                                    ],
                                  )
                              ),
                              SingleChildScrollView(
                                  child:
                                  Column(
                                    children: [
                                      CustomTextField(text: constValue.fullName,controller: empProvider.signEmFname,
                                        width: kIsWeb?webWidth:phoneWidth,
                                      ),
                                      CustomTextField(text: constValue.phoneNumber,controller: empProvider.signEmPh,
                                        width: kIsWeb?webWidth:phoneWidth,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: constInputFormatters.mobileNumberInput,
                                      ),
                                      CustomTextField(text: constValue.relation,controller: empProvider.signEmRelation,
                                        width: kIsWeb?webWidth:phoneWidth,
                                        textInputAction: TextInputAction.done,
                                      ),
                                    ],
                                  )
                              ),
                              SingleChildScrollView(
                                  child:
                                  Column(
                                    children: [
                                      CustomTextField(text: constValue.lastOrganization,controller: empProvider.signLastOrganization,
                                        width: kIsWeb?webWidth:phoneWidth,
                                      ),
                                      CustomTextField(text: constValue.referredBy,controller: empProvider.signReffered,
                                        width: kIsWeb?webWidth:phoneWidth,
                                        textInputAction: TextInputAction.done,
                                      ),
                                    ],
                                  )
                              ),
                              SingleChildScrollView(
                                  child:
                                  Column(
                                    children: [
                                      CustomTextField(text: constValue.reference1Name,controller: empProvider.signReFname1,
                                        width: kIsWeb?webWidth:phoneWidth,
                                      ),
                                      CustomTextField(text: constValue.reference1Phone,controller: empProvider.signRePh1,
                                        keyboardType: TextInputType.phone,
                                        width: kIsWeb?webWidth:phoneWidth,
                                        inputFormatters: constInputFormatters.mobileNumberInput,
                                      ),
                                      CustomTextField(text: constValue.reference2Name,controller: empProvider.signReFname2,
                                        width: kIsWeb?webWidth:phoneWidth,
                                      ),
                                      CustomTextField(text: constValue.reference2Phone,controller: empProvider.signRePh2,
                                        keyboardType: TextInputType.phone,
                                        width: kIsWeb?webWidth:phoneWidth,
                                        inputFormatters: constInputFormatters.mobileNumberInput,
                                        textInputAction: TextInputAction.done,
                                      ),
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
                                  // NOTE: "const" removed, constValue getters are not compile-time constants
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(text: constValue.cheque,colors: Colors.grey,size: 14),
                                      CustomText(
                                          text: kIsWeb
                                              ? "${constValue.voter} (${constValue.optional})"
                                              : "${constValue.voter}\n(${constValue.optional})",
                                          colors: Colors.grey,size: 14),
                                      CustomText(
                                          text: kIsWeb
                                              ? "${constValue.license} (${constValue.optional})"
                                              : "${constValue.license}\n(${constValue.optional})",
                                          colors: Colors.grey,size: 14),
                                    ],
                                  ),
                                  25.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      DocumentContainer(
                                        text: constValue.cheque,
                                        imageValue:empProvider.chequePhoto,
                                        netWrk: empProvider.oldImage5,
                                        callback: () {
                                          _myFocusScopeNode.unfocus();
                                          empProvider.signDialog(
                                            context: context,
                                            img: empProvider.chequePhoto==""?empProvider.oldImage5:empProvider.chequePhoto,
                                            imgName: empProvider.chequePhotoName,
                                            imgList: empProvider.chequePhotoList,
                                            docType: "cheque",
                                            onPicked: empProvider.setDocument,
                                            onRemove: empProvider.removeDocument,
                                          );
                                        },
                                      ),
                                      DocumentContainer(
                                        text: constValue.license,
                                        imageValue:empProvider.licensePhoto,
                                        netWrk: empProvider.oldImage6,
                                        callback: () {
                                          _myFocusScopeNode.unfocus();
                                          empProvider.signDialog(
                                            context: context,
                                            img: empProvider.licensePhoto==""?empProvider.oldImage6:empProvider.licensePhoto,
                                            imgName: empProvider.licensePhotoName,
                                            imgList: empProvider.licensePhotoList,
                                            docType: "license",
                                            onPicked: empProvider.setDocument,
                                            onRemove: empProvider.removeDocument,
                                          );
                                        },
                                      ),
                                      DocumentContainer(
                                        text: constValue.voter,
                                        imageValue:empProvider.voterPhoto,
                                        netWrk: empProvider.oldImage7,
                                        callback: () {
                                          _myFocusScopeNode.unfocus();
                                          empProvider.signDialog(
                                            context: context,
                                            img: empProvider.voterPhoto==""?empProvider.oldImage7:empProvider.voterPhoto,
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
                                ],
                              ),
                            ]))
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