import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/component/custom_checkbox.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/component/custom_radio_button.dart';
import 'package:master_code/screens/customer/viamap.dart';
import 'package:master_code/source/constant/key_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/styles/decoration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_dropdown.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../component/map_dropdown.dart';
import '../../component/maxline_textfield.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/customer_provider.dart';
import '../../view_model/location_provider.dart';

class CreateCustomer extends StatefulWidget {
  const CreateCustomer({super.key});

  @override
  State<CreateCustomer> createState() => _CreateCustomerState();
}

class _CreateCustomerState extends State<CreateCustomer> with TickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<CustomerProvider>(context, listen: false).initValues();
    if(Provider.of<LocationProvider>(context, listen: false).latitude!=""&&Provider.of<LocationProvider>(context, listen: false).longitude!=""){
      Provider.of<CustomerProvider>(context, listen: false).getAdd(
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
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer2<CustomerProvider,LocationProvider>(builder: (context,custProvider,locPvr,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: constValue.createCustomer,
                callback: (){
                  _myFocusScopeNode.unfocus();
                  if (custProvider.showIndex==0) {
                    Future.microtask(() => Navigator.pop(context));
                  }else if (custProvider.showIndex==1) {
                    custProvider.changeIndex(0);
                  }else if (custProvider.showIndex==2) {
                    custProvider.changeIndex(1);
                  }
                },),
            ),
            backgroundColor: colorsConst.bacColor,
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          _myFocusScopeNode.unfocus();
          if (!didPop) {
            if (custProvider.showIndex==0) {
              Future.microtask(() => Navigator.pop(context));
            }else if (custProvider.showIndex==1) {
              custProvider.changeIndex(0);
            }else if (custProvider.showIndex==2) {
              custProvider.changeIndex(1);
            }
          }
        },
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: kIsWeb?webWidth:phoneWidth,
              child: Column(
                children: [
                  20.height,
                  custProvider.showIndex==0?
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            // color: Colors.yellow,
                            width: kIsWeb?webWidth/1.5:phoneWidth/1.5,
                            child: Center(
                              child: CustomText(text: "       ${constValue.customerDetails}",
                                colors: colorsConst.greyClr,
                                isBold: true,
                                size: 15,),
                            ),
                          ),
                          Row(
                            children: [
                              CustomCheckBox(
                                  text: "",
                                  onChanged: (value){
                                    custProvider.clearAddress(context,locPvr.latitude,locPvr.longitude);
                                  },
                                  saveValue: custProvider.clear),
                              // GestureDetector(
                              //   onTap: () {
                              //     custProvider.clearAddress();
                              //   },
                              //   child: CustomText(text: "Remove Address",
                              //     colors: colorsConst.third,
                              //     size: 15,),
                              // ),
                              10.width,
                              GestureDetector(
                                onTap: () async {
                                  _myFocusScopeNode.unfocus();
                                  if(locPvr.latitude==""&&locPvr.longitude==""){
                                    await locPvr.manageLocation(context,true);
                                  }else{
                                    if(!kIsWeb){
                                      utils.navigatePage(context, ()=> const ViaMap());
                                    }
                                  }
                                },
                                child: const Icon(
                                  Icons.location_on_sharp, color: Colors.green,),
                              ),
                            ],
                          ),
                        ],
                      ),
                      CustomTextField(
                        text: constValue.companyName,
                        isRequired: true,
                        width: kIsWeb?webWidth:phoneWidth,
                        // inputFormatters: constInputFormatters.addressInput,
                        controller: custProvider.companyName,
                      ),
                      CustomTextField(
                        text: "Emergency Name",
                        width: kIsWeb?webWidth:phoneWidth,
                        // inputFormatters: constInputFormatters.addressInput,
                        controller: custProvider.emgName,
                      ),
                      CustomTextField(
                        text: "Emergency Number",
                        width: kIsWeb?webWidth:phoneWidth,
                        inputFormatters: constInputFormatters.mobileNumberInput,
                        controller: custProvider.emgNo,
                        keyboardType: TextInputType.number,
                      ),
                      CustomTextField(
                        text: constValue.addressNo,
                        width: kIsWeb?webWidth:phoneWidth,
                        // inputFormatters: constInputFormatters.addressInput,
                        controller: custProvider.address,
                      ),
                      CustomTextField(
                        text: constValue.comArea,
                        width: kIsWeb?webWidth:phoneWidth,
                        // inputFormatters: constInputFormatters.addressInput,
                        controller: custProvider.comArea,
                      ),
                      CustomTextField(
                        text: "Landmark",
                        width: kIsWeb?webWidth:phoneWidth,
                        controller: custProvider.landmark,
                      ),
                      SizedBox(
                        height: 85,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextField(
                              text: constValue.city,
                              inputFormatters: constInputFormatters.textInput,
                              controller: custProvider.city,
                              width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                            ),
                            CustomDropDown(
                              size: 15,
                              color: Colors.white,
                              text: "State",
                              saveValue: custProvider.state,
                              valueList: custProvider.stateList,
                              onChanged: (value) {
                                custProvider.changeState(value);
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
                            controller: custProvider.pinCode,
                            width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                          ),
                          CustomTextField(
                            text: constValue.country,
                            inputFormatters: constInputFormatters.textInput,
                            controller: custProvider.country,
                            width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                          ),
                        ],
                      ),
                      CustomDropDown(
                        color: Colors.white,
                        text: "Select Type",saveValue: custProvider.type,
                        valueList: custProvider.cusList,
                        onChanged: (value){
                          custProvider.changeCusType(value);
                        },
                        width: kIsWeb?webWidth:phoneWidth,
                      ),20.height,
                      SizedBox(
                        width: kIsWeb?webWidth:phoneWidth,
                        child: Row(
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
                                if (custProvider.companyName.text.trim().isEmpty) {
                                  utils.showWarningToast(context, text: "Please fill ${constValue.customerName}");
                                } else {
                                  final emgNo = custProvider.emgNo.text.trim();
                                  final pinCode = custProvider.pinCode.text.trim();

                                  if (emgNo.isEmpty && pinCode.isEmpty) {
                                    _myFocusScopeNode.unfocus();
                                    custProvider.changeIndex(1);
                                  } else {
                                    if (emgNo.isNotEmpty && emgNo.length != 10) {
                                      utils.showWarningToast(context, text: "Please check emergency number");
                                    } else if (pinCode.isNotEmpty && pinCode.length != 6) {
                                      utils.showWarningToast(context, text: "Please check pincode");
                                    } else {
                                      _myFocusScopeNode.unfocus();
                                      custProvider.changeIndex(1);
                                    }
                                  }
                                }
                              }, isLoading: false, backgroundColor: colorsConst.primary,
                              radius: 10, width: kIsWeb?webWidth/2.1:phoneWidth/2.1,text: "Next",),
                          ],
                        ),
                      ),
                    ],
                  ):
                  custProvider.showIndex==1?
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(onPressed: (){
                            _myFocusScopeNode.unfocus();
                            custProvider.changeIndex(0);
                          }, icon: const Icon(Icons.arrow_back_ios,size: 15,)),
                          Row(
                            children: [
                              CustomText(text: constValue.contactDetails,
                                colors: colorsConst.greyClr,
                                isBold: true,
                                size: 15,),
                              TextButton(onPressed: () {
                                custProvider.addCustomerList(context);
                              },
                                  child: Row(
                                    children: [
                                      CustomText(text: constValue.addContact,size: 12,),
                                      const Icon(Icons.add),
                                    ],
                                  ))
                            ],
                          ),
                        ],
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          reverse: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: custProvider.addCustomer.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: customDecoration
                                  .baseBackgroundDecoration(
                                  color: Colors.white,
                                  // borderColor: colorsConst.litGrey,
                                  radius: 2
                              ),
                              child: Column(
                                children: [
                                  5.height,
                                  SizedBox(
                                    width: kIsWeb?webWidth/1.5:phoneWidth/1.5,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            // CustomCheckBox(
                                            //     text: "", onChanged: (value){
                                            //   custProvider.mainCustomer(index);
                                            // },
                                            //     saveValue: custProvider.addCustomer[index].isMain),
                                            CustomText(text: "${constValue.contactDetails} ${index+1}",
                                              colors: colorsConst.greyClr,
                                              isBold: true,
                                              size: 15,),
                                          ],
                                        ),
                                        if(custProvider.addCustomer.length!=1)
                                        IconButton(onPressed: () {
                                            custProvider.removeList(context, index);
                                        },
                                            icon: SvgPicture.asset(assets.deleteValue))
                                      ],
                                    ),
                                  ),
                                  5.height,
                                  CustomTextField(
                                    fieldColor: Colors.grey.shade100,
                                    text: constValue.contactName,
                                    isRequired: true,
                                    // inputFormatters: constInputFormatters
                                    //     .numTextInput,
                                    controller: custProvider
                                        .addCustomer[index].name,
                                    width: kIsWeb?webWidth/1.02:phoneWidth/1.02,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center,
                                    children: [
                                      CustomTextField(
                                        fieldColor: Colors.grey.shade100,
                                        text: "Department",
                                        controller: custProvider.addCustomer[index].department,
                                        width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                      ),
                                      5.width,
                                      CustomTextField(
                                        fieldColor: Colors.grey.shade100,
                                        text: "Designation",
                                        controller: custProvider.addCustomer[index].designation,
                                        width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: kIsWeb?webWidth/1.02:phoneWidth/1.02,
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CustomText(text: "Role",colors: Colors.grey.shade400,),
                                          ],
                                        ),5.height,
                                        kIsWeb?
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                           CustomRadioButton(text: "Decision Maker",
                                               width: MediaQuery.of(context).size.width*0.2,
                                               onChanged: (value){
                                                custProvider.changeRole("Decision Maker",index);
                                               },
                                               saveValue: "Decision Maker", confirmValue: custProvider.addCustomer[index].roleC),
                                            CustomRadioButton(text: "Supporter",                                                             width: MediaQuery.of(context).size.width*0.2,
                                                onChanged: (value){
                                             custProvider.changeRole("Supporter",index);
                                           },
                                               saveValue: "Supporter", confirmValue: custProvider.addCustomer[index].roleC),
                                           CustomRadioButton(text: "Influencer",                                                             width: MediaQuery.of(context).size.width*0.2,
                                               onChanged: (value){
                                             custProvider.changeRole("Influencer",index);
                                           },
                                               saveValue: "Influencer", confirmValue: custProvider.addCustomer[index].roleC),
                                           CustomRadioButton(text: "Other",                                                            width: MediaQuery.of(context).size.width*0.2,
                                               onChanged: (value){
                                             custProvider.changeRole("Other",index);
                                           },
                                               saveValue: "Other", confirmValue: custProvider.addCustomer[index].roleC),
                                          ],
                                        ):
                                        Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                           SizedBox(
                                             width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                             child: Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: [
                                                 CustomRadioButton(text: "Decision Maker",
                                                     width: MediaQuery.of(context).size.width*0.2,
                                                     onChanged: (value){
                                                      custProvider.changeRole("Decision Maker",index);
                                                     },
                                                     saveValue: "Decision Maker", confirmValue: custProvider.addCustomer[index].roleC),
                                                 15.height,
                                                 CustomRadioButton(text: "Supporter",
                                                     width: MediaQuery.of(context).size.width*0.2,
                                                     onChanged: (value){
                                                   custProvider.changeRole("Supporter",index);
                                                 },
                                                     saveValue: "Supporter", confirmValue: custProvider.addCustomer[index].roleC),
                                               ],
                                             ),
                                           ),
                                           SizedBox(
                                             width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                             child: Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: [
                                                 CustomRadioButton(text: "Influencer",                                                             width: MediaQuery.of(context).size.width*0.2,
                                                     onChanged: (value){
                                                   custProvider.changeRole("Influencer",index);
                                                 },
                                                     saveValue: "Influencer", confirmValue: custProvider.addCustomer[index].roleC),
                                                 15.height,
                                                 CustomRadioButton(text: "Other",                                                            width: MediaQuery.of(context).size.width*0.2,
                                                     onChanged: (value){
                                                   custProvider.changeRole("Other",index);
                                                 },
                                                     saveValue: "Other", confirmValue: custProvider.addCustomer[index].roleC),
                                               ],
                                             ),
                                           ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  10.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center,
                                    children: [
                                      CustomTextField(
                                        fieldColor: Colors.grey.shade100,
                                        text: constValue.phoneNumber,
                                        isRequired: true,
                                        controller: custProvider.addCustomer[index].phone,
                                        inputFormatters: constInputFormatters.mobileNumberInput,
                                        keyboardType: TextInputType.number,
                                        width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                        isLogin: true,
                                        iconData: custProvider.addCustomer[index].isWhatsapp==true?Icons.check_circle:Icons.circle_outlined,
                                        iconColor: custProvider.addCustomer[index].isWhatsapp==true?colorsConst.appGreen:colorsConst.litGrey,
                                        onChanged: (value){
                                          custProvider.changeNumber(index);
                                        },
                                        iconCallBack: (){
                                          custProvider.copyNumber(index);
                                        },
                                      ),
                                      5.width,
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                        child: CustomTextField(
                                          fieldColor: Colors.grey.shade100,
                                          text: constValue.mobileNumber,
                                          controller: custProvider.addCustomer[index].whatsApp,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.mobileNumberInput,
                                          width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                          onChanged: (value){
                                            custProvider.removeCheck(index);
                                          },
                                        ),
                                      ),

                                    ],
                                  ),
                                  CustomTextField(
                                    text: constValue.emailId,
                                    fieldColor: Colors.grey.shade100,
                                    controller: custProvider.addCustomer[index].email,
                                    textCapitalization: TextCapitalization.none,
                                    keyboardType: TextInputType.emailAddress,
                                    width: kIsWeb?webWidth/1.02:phoneWidth/1.02,
                                    textInputAction: TextInputAction.done,
                                  ),
                                  if((custProvider.addCustomer.length!=1&&index==custProvider.addCustomer.length-1)||index!=0)
                                    Container(height: 1,color: Colors.grey.shade300,),
                                  // if(custProvider.addCustomer.length!=1&&index==custProvider.addCustomer.length-1)
                                  //   Row(
                                  //     mainAxisAlignment: MainAxisAlignment.end,
                                  //     children: [
                                  //       IconButton(onPressed: () {
                                  //         custProvider.addCustomerList(context);
                                  //       },
                                  //           icon: Icon(Icons.add,
                                  //             color: colorsConst
                                  //                 .secondary,)),
                                  //     ],
                                  //   ),
                                  10.height,
                                ],
                              ),
                            );
                          }),
                      20.height,
                      SizedBox(
                        width: kIsWeb?webWidth:phoneWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomLoadingButton(
                                callback: (){
                                  custProvider.changeIndex(0);
                                  _myFocusScopeNode.unfocus();
                                }, isLoading: false,text: "Back",
                                backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                                width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                            CustomLoadingButton(
                              callback: (){
                                final customer = custProvider.addCustomer.last;

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
                                    custProvider.changeIndex(2);
                                    _myFocusScopeNode.unfocus();
                                  }else{
                                    final bool isValid =
                                    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                        .hasMatch(customer.email.text.trim());
                                    if(isValid){
                                      _myFocusScopeNode.unfocus();
                                      custProvider.changeIndex(2);
                                    }else{
                                      utils.showWarningToast(context,text: "Please Check Email Id");
                                    }
                                  }
                                }
                              }, isLoading: false, backgroundColor: colorsConst.primary,
                              radius: 10, width: kIsWeb?webWidth/2.1:phoneWidth/2.1,text: "Next",),
                          ],
                        ),
                      ),
                    ],
                  ):
                  Column(
                    children: [
                      MapDropDown(
                        callback: (){
                          if(!kIsWeb){
                            custProvider.refreshLead();
                          }else{
                            custProvider.getLeadCategory();
                          }
                        },
                        isRequired: true,
                        isRefresh: custProvider.leadCategoryList.isEmpty?true:false,
                        width: kIsWeb?webWidth:phoneWidth,
                        hintText: constValue.leadStatus,
                        list: custProvider.leadCategoryList,
                        saveValue: custProvider.leadType,
                        onChanged: (Object? value) {
                          custProvider.changeLeadType(value);
                        },
                        dropText: 'value',),
                      MapDropDown(
                        callback: (){
                          if(!kIsWeb){
                            custProvider.refreshVisit();
                          }else{
                            custProvider.getVisitType();
                          }
                        },
                        isRequired: true,
                        isRefresh: custProvider.callList.isEmpty?true:false,
                        width:kIsWeb?webWidth:phoneWidth,
                        hintText: constValue.visitType,
                        list: custProvider.callList,
                        saveValue: custProvider.callType,
                        onChanged: (Object? value) {
                          custProvider.changeCallType(value);
                        },
                        dropText: 'value',),
                      MaxLineTextField(
                        width: kIsWeb?webWidth:phoneWidth,
                        text: constValue.disPoints,
                        textCapitalization: TextCapitalization.sentences,
                        controller: custProvider.disPoint, maxLine: 5,
                      ),
                      MaxLineTextField(
                        width: kIsWeb?webWidth:phoneWidth,
                        text: constValue.addPoints,
                        textCapitalization: TextCapitalization.sentences,
                        controller: custProvider.points, maxLine: 5,
                        textInputAction: TextInputAction.done,
                      ),
                      20.height,
                      SizedBox(
                        width: kIsWeb?webWidth:phoneWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomLoadingButton(
                                callback: (){
                                  custProvider.changeIndex(1);
                                  _myFocusScopeNode.unfocus();
                                }, isLoading: false,text: "Back",
                                backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                                width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                            CustomLoadingButton(
                              callback: (){
                                final customer = custProvider.addCustomer.last;

                                if (customer.name.text.trim().isEmpty) {
                                  utils.showWarningToast(context, text: "Please Fill ${constValue.contact} Name");
                                  custProvider.addCtr.reset();
                                } else if (customer.phone.text.trim().isEmpty) {
                                  utils.showWarningToast(context, text: "Please Fill ${constValue.contact} ${constValue.phoneNumber}");
                                  custProvider.addCtr.reset();
                                } else if (customer.phone.text.trim().length != 10) {
                                  utils.showWarningToast(context, text: "Please Check ${constValue.contact} ${constValue.phoneNumber}");
                                  custProvider.addCtr.reset();
                                } else if (customer.whatsApp.text.trim().isNotEmpty && customer.whatsApp.text.trim().length != 10) {
                                  utils.showWarningToast(context, text: "Please Check ${constValue.contact} ${constValue.mobileNumber}");
                                  custProvider.addCtr.reset();
                                } else {
                                  if(customer.email.text.trim().isEmpty) {
                                    _myFocusScopeNode.unfocus();
                                    if(custProvider.addCustomer.length!=1){
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            contentPadding: const EdgeInsets.all(10),
                                            content: StatefulBuilder(
                                              builder: (context, setState) {
                                                return SizedBox(
                                                  width: kIsWeb?webWidth/1.5:phoneWidth/1.5,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                            },
                                                            child: SvgPicture.asset(assets.cancel),
                                                          ),
                                                        ],
                                                      ),
                                                      Center(
                                                        child: CustomText(
                                                          text: "Make this ${constValue.contact.toLowerCase()} the main ${constValue.contact.toLowerCase()}?",
                                                          colors: Colors.black,
                                                          size: 15,
                                                          isBold: true,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      SizedBox(
                                                        height: custProvider.addCustomer.length * 50,
                                                        child: ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount: custProvider.addCustomer.length,
                                                          itemBuilder: (context, index) {
                                                            return Padding(
                                                              padding: const EdgeInsets.fromLTRB(15, 10, 0, 10),
                                                              child: Row(
                                                                children: [
                                                                  CustomCheckBox(
                                                                    text: "",
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                        custProvider.mainCustomer(index);
                                                                      });
                                                                    },
                                                                    saveValue: custProvider.addCustomer[index].isMain,
                                                                  ),
                                                                  CustomText(text: custProvider.addCustomer[index].name.text),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          OutlinedButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                              custProvider.addCtr.reset();
                                                            },
                                                            style: OutlinedButton.styleFrom(
                                                              backgroundColor: Colors.white,
                                                              side: BorderSide(color: Colors.grey.shade300),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                            ),
                                                            child: const CustomText(text: "Cancel", size: 15),
                                                          ),
                                                          CustomLoadingButton(
                                                            height: 35,
                                                            isLoading: true,
                                                            radius: 10,
                                                            width: 70,
                                                            backgroundColor: colorsConst.primary,
                                                            text: "Save",
                                                            callback: () {
                                                              custProvider.customerList(context, "1", locPvr.latitude, locPvr.longitude);
                                                            },
                                                            controller: custProvider.addCtr,
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    }else{
                                      custProvider.customerList(context,"1",locPvr.latitude,locPvr.longitude);
                                    }
                                  }else{
                                    final bool isValid =
                                    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                        .hasMatch(customer.email.text.trim());
                                    if(isValid){
                                      _myFocusScopeNode.unfocus();
                                      if(custProvider.addCustomer.length!=1){
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              contentPadding: const EdgeInsets.all(10),
                                              content: StatefulBuilder(
                                                builder: (context, setState) {
                                                  return SizedBox(
                                                    width: kIsWeb?webWidth/1.5:phoneWidth/1.5,
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                              child: SvgPicture.asset(assets.cancel),
                                                            ),
                                                          ],
                                                        ),
                                                        Center(
                                                          child: CustomText(
                                                            text: "Make this ${constValue.contact.toLowerCase()} the main ${constValue.contact.toLowerCase()}?",
                                                            colors: Colors.black,
                                                            size: 15,
                                                            isBold: true,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        SizedBox(
                                                          height: custProvider.addCustomer.length * 50,
                                                          child: ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount: custProvider.addCustomer.length,
                                                            itemBuilder: (context, index) {
                                                              return Padding(
                                                                padding: const EdgeInsets.fromLTRB(15, 10, 0, 10),
                                                                child: Row(
                                                                  children: [
                                                                    CustomCheckBox(
                                                                      text: "",
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          custProvider.mainCustomer(index);
                                                                        });
                                                                      },
                                                                      saveValue: custProvider.addCustomer[index].isMain,
                                                                    ),
                                                                    CustomText(text: custProvider.addCustomer[index].name.text),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            OutlinedButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                custProvider.addCtr.reset();
                                                              },
                                                              style: OutlinedButton.styleFrom(
                                                                backgroundColor: Colors.white,
                                                                side: BorderSide(color: Colors.grey.shade300),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                ),
                                                              ),
                                                              child: const CustomText(text: "Cancel", size: 15),
                                                            ),
                                                            CustomLoadingButton(
                                                              height: 35,
                                                              isLoading: true,
                                                              radius: 10,
                                                              width: 70,
                                                              backgroundColor: colorsConst.primary,
                                                              text: "Save",
                                                              callback: () {
                                                                custProvider.customerList(context, "1", locPvr.latitude, locPvr.longitude);
                                                              },
                                                              controller: custProvider.addCtr,
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      }else{
                                        custProvider.customerList(context,"1",locPvr.latitude,locPvr.longitude);
                                      }
                                    }else{
                                      utils.showWarningToast(context,text: "Please Check Email Id");
                                      custProvider.addCtr.reset();
                                    }
                                  }
                                }
                              }, isLoading: custProvider.addCustomer.length==1?true:false, backgroundColor: colorsConst.primary,
                              radius: 10, width: kIsWeb?webWidth/2.1:phoneWidth/2.1,text: "Save",controller: custProvider.addCtr,),
                          ],
                        ),
                      ),
                    ],
                  ),
                  40.height
                ],
              ),
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



