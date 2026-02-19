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
import 'package:master_code/view_model/home_provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_dropdown.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/employee_provider.dart';
import '../view_model/location_provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp>{
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<EmployeeProvider>(context, listen: false).initValues();
      Provider.of<LocationProvider>(context, listen: false).manageLocation(context,false);
      if(Provider.of<LocationProvider>(context, listen: false).latitude!=""&&Provider.of<LocationProvider>(context, listen: false).longitude!=""){
        Provider.of<EmployeeProvider>(context, listen: false).getAdd(
            double.parse(Provider.of<LocationProvider>(context, listen: false).latitude),
            double.parse(Provider.of<LocationProvider>(context, listen: false).longitude));
      }
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
    var webWidth=MediaQuery.of(context).size.width*0.5;
    var phoneWidth=MediaQuery.of(context).size.width*0.9;
    return Consumer3<EmployeeProvider,HomeProvider,LocationProvider>(builder: (context,empProvider,homeProvider,locPvr,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(
                  text: constValue.signUp),
            ),
            body: Center(
              child: SizedBox(
                // color: Colors.pink,
                width: kIsWeb?webWidth:phoneWidth,
                child: SingleChildScrollView(
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
                            backgroundImage: FileImage(File(empProvider.profile))
                          ),
                        ),
                      ),
                      30.height,
                      CustomTextField(text: constValue.firstName,
                        controller: empProvider.signFirstName,
                        isRequired: true,
                        width: kIsWeb?webWidth:phoneWidth,
                      ),
                      CustomTextField(
                        width: kIsWeb?webWidth:phoneWidth,
                        text: constValue.lastName, controller: empProvider.signLastName,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextField(text: constValue.phoneNumber,
                            controller: empProvider.signMobileNumber,
                            isRequired: true,
                            width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                            keyboardType: TextInputType.number,
                            inputFormatters: constInputFormatters.mobileNumberInput,
                          ),
                          CustomTextField(text: constValue.password,
                            controller: empProvider.signPassword,
                            isRequired: true,
                            width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                            keyboardType: TextInputType.visiblePassword,
                            inputFormatters: constInputFormatters.passwordInput,
                            textCapitalization: TextCapitalization.none,
                          )
                        ],
                      ),
                      CustomTextField(text: constValue.emailId,
                        width: kIsWeb?webWidth:phoneWidth,
                        textCapitalization: TextCapitalization.none,
                        controller: empProvider.signEmailid,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextField(text: constValue.role,
                            isRequired: true,readOnly: true,
                            controller: empProvider.userRole,
                            width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                            textInputAction: TextInputAction.next,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: CustomTextField(text: constValue.referredBy,
                              controller: empProvider.signReffered,
                              width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                              // textInputAction: TextInputAction.done,
                            ),
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
                        width: kIsWeb?webWidth:phoneWidth,
                        text: constValue.addressNo,
                        // inputFormatters: constInputFormatters.addressInput,
                        controller: empProvider.doorNo,
                      ),
                      CustomTextField(
                        width: kIsWeb?webWidth:phoneWidth,
                        text: constValue.comArea,
                        // inputFormatters: constInputFormatters.addressInput,
                        controller: empProvider.comArea,
                      ),
                      Row(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomLoadingButton(
                              callback: (){
                                Future.microtask(() => Navigator.pop(context));
                              }, isLoading: false,text: "Cancel",
                              backgroundColor: Colors.white, textColor: colorsConst.primary,
                              radius: 10, width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                          CustomLoadingButton(
                              callback: (){
                                if (empProvider.signFirstName.text.trim().isEmpty) {
                                  utils.showWarningToast(context,
                                      text: "Please fill first name");
                                  empProvider.signCtr.reset();
                                }else if (empProvider.signMobileNumber.text.trim().isEmpty) {
                                  utils.showWarningToast(context,
                                      text: "Please fill mobile number");
                                  empProvider.signCtr.reset();
                                } else if (empProvider.signMobileNumber.text.trim().length != 10) {
                                  utils.showWarningToast(context,
                                      text: "Please check mobile number");
                                  empProvider.signCtr.reset();
                                } else if (empProvider.signPassword.text.trim().isEmpty) {
                                  utils.showWarningToast(context,
                                      text: "Please fill password");
                                  empProvider.signCtr.reset();
                                } else if (empProvider.signPassword.text.trim().length<8) {
                                  utils.showWarningToast(context,
                                      text: "Password must be 8 characters");
                                  empProvider.signCtr.reset();
                                }else {
                                  if(empProvider.signEmailid.text.trim().isEmpty) {
                                    _myFocusScopeNode.unfocus();
                                    empProvider.signupEmployee(context,locPvr.latitude,locPvr.longitude);
                                  }else{
                                    final bool isValid =
                                    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                        .hasMatch(empProvider.signEmailid.text.trim());
                                    if(isValid){
                                      _myFocusScopeNode.unfocus();
                                      empProvider.signupEmployee(context,locPvr.latitude,locPvr.longitude);
                                    }else{
                                      utils.showWarningToast(context,
                                          text: "Please check email id");
                                      empProvider.signCtr.reset();
                                    }
                                  }
                                }
                              }, isLoading: true,text: "Save",controller: empProvider.signCtr,
                              backgroundColor: colorsConst.primary,radius: 10,
                              width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                        ],
                      ),
                      50.height,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}



