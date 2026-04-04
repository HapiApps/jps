import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:master_code/view_model/location_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/customer_provider.dart';
import '../../../component/custom_appbar.dart';
import '../../../component/custom_loading.dart';
import '../../../component/custom_text.dart';
import '../../../component/custom_textfield.dart';
import '../../../component/map_dropdown.dart';
import '../../../component/maxline_textfield.dart';
import '../../../component/search_drop_down.dart';
import '../../../model/customer/customer_model.dart';
import '../../../source/constant/colors_constant.dart';
import '../../../source/constant/default_constant.dart';
import '../../../source/constant/local_data.dart';
import '../../../source/styles/decoration.dart';
import '../../../source/utilities/utils.dart';
import '../../../view_model/task_provider.dart';
import '../../common/dashboard.dart';
import '../viamap.dart';
import '../visit_report/visits_report.dart';

class CusAddVisit extends StatefulWidget {
  final String companyId;
  final String companyName;
  final String type;
  final String desc;
  final String taskId;
  final List numberList;
  final bool isDirect;
  const CusAddVisit({super.key, required this.companyId, required this.companyName, required this.numberList, required this.isDirect, required this.taskId, required this.type, required this.desc});

  @override
  State<CusAddVisit> createState() => _CusAddVisitState();
}

class _CusAddVisitState extends State<CusAddVisit> with TickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  var companyId="";
  var companyName="";
  @override
  void initState() {
    localData.storage.write("c_id","");
    localData.storage.write("c_no","");
    localData.storage.write("c_name","");
    setCustomer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      if(!kIsWeb){
        Provider.of<TaskProvider>(context, listen: false).getAllTypes();
        Provider.of<EmployeeProvider>(context, listen: false).getAllUsers();
        Provider.of<CustomerProvider>(context, listen: false).getAllCustomers(true);
      }else{
        Provider.of<TaskProvider>(context, listen: false).getTaskType(false);
        Provider.of<TaskProvider>(context, listen: false).getTaskStatuses();
        Provider.of<EmployeeProvider>(context, listen: false).getAllUsers();
        Provider.of<CustomerProvider>(context, listen: false).getAllCustomers(true);
      }
      if(widget.isDirect==true){
        if(kIsWeb){
          customerProvider.getLeadCategory();
          customerProvider.getVisitType();
          customerProvider.getCmtType();
          Provider.of<EmployeeProvider>(context, listen: false).getAllUsers();
          Provider.of<CustomerProvider>(context, listen: false).getAllCustomers(true);
        }else{
          customerProvider.getLead();
          customerProvider.getVisit();
          customerProvider.getCommentType();
          Provider.of<EmployeeProvider>(context, listen: false).getAllUsers();
          Provider.of<CustomerProvider>(context, listen: false).getAllCustomers(true);
        }
      }
      // customerProvider.setValue(widget.companyId.toString());
      customerProvider.initComment(widget.numberList,widget.type);
      companyName="";
      Provider.of<EmployeeProvider>(context, listen: false).getAllUsers();
      Provider.of<CustomerProvider>(context, listen: false).getAllCustomers(true);
      if(Provider.of<LocationProvider>(context, listen: false).latitude!=""&&Provider.of<LocationProvider>(context, listen: false).longitude!=""){
        customerProvider.getAdd(
            double.parse(Provider.of<LocationProvider>(context, listen: false).latitude),
            double.parse(Provider.of<LocationProvider>(context, listen: false).longitude));
      }
    });
    super.initState();
  }
  void setCustomer(){
    companyId=widget.companyId.toString();
    companyName=widget.companyName.toString();
  }
  @override
  void dispose() {
    _myFocusScopeNode.dispose();
    super.dispose();
  }
  List sendList=[];
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer4<CustomerProvider,LocationProvider,TaskProvider,HomeProvider>(builder: (context,custProvider,locPvr,taskProvider,home,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea (
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: constValue.addVisit),
            ),
            body: Center(
              child: SizedBox(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            20.height,
                            if(widget.isDirect==true)
                            custProvider.refresh == false?
                            const Loading()
                                :CustomerDropdown(
                              text: constValue.companyName,
                              employeeList: custProvider.customer,
                              onChanged: (CustomerModel? value) {
                                setState(() {
                                  companyId=value!.userId.toString();
                                  companyName=value.companyName.toString();
                                  sendList=[];
                                  var idList=value.customerId.toString().split('||');
                                  var usersList=value.firstName.toString().split('||');
                                  var phoneList=value.phoneNumber.toString().split('||');
                                  for(var i=0;i<usersList.length;i++){
                                    sendList.add({"id": idList[i], "name": usersList[i], "no": phoneList[i]});
                                  }
                                  custProvider.selectCustomer=sendList[0];
                                  localData.storage.write("c_id",sendList[0]["id"]);
                                  localData.storage.write("c_no",sendList[0]["no"]);
                                  localData.storage.write("c_name",sendList[0]["name"]);
                                });
                              }, size: kIsWeb?webWidth:phoneWidth,),
                            if(widget.isDirect==false)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(text: widget.companyName=="null"?"":widget.companyName,colors: colorsConst.primary,isBold: true,),10.width,
                                // CustomText(text: widget.type,colors: colorsConst.greyClr,isItalic: true,),
                              ],
                            ),
                            //type
                            MapDropDown(isRequired:true,
                              isRefresh: taskProvider.typeList.isEmpty?true:false,
                              callback: (){
                                if(!kIsWeb){
                                  taskProvider.getTaskType(true);
                                }else{
                                  taskProvider.getAllTypes();
                                }
                              },
                              width: kIsWeb?webWidth:phoneWidth,
                              hintText: constValue.type,
                              list: custProvider.cmtTypeList,
                              // saveValue: custProvider.selectType,
                              saveValue: custProvider.selectType?['id'],
                              onChanged: (Object? value) {
                                final selected = custProvider.cmtTypeList
                                    .firstWhere((e) => e['id'].toString() == value.toString());

                                custProvider.changeType(selected);
                              },
                              dropText: 'value',),
                            CustomTextField(
                              width: kIsWeb?webWidth:phoneWidth,
                              text: "Date", controller: custProvider.commentDate,
                              isRequired: true,
                              onTap: (){
                                utils.datePick(context:context,textEditingController: custProvider.commentDate);
                              },
                              onChanged: null,
                            ),
                            SizedBox(
                              width: kIsWeb?webWidth:phoneWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CustomText(text: "Visit Location",colors: Colors.black,),
                                ],
                              ),
                            ),5.height,
                            Container(
                              width: kIsWeb?webWidth:phoneWidth,
                              decoration: customDecoration.baseBackgroundDecoration(
                                color: Colors.white,radius: 10,borderColor: Colors.grey.shade300
                              ),
                              child:
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: kIsWeb?MediaQuery.of(context).size.width*0.3:MediaQuery.of(context).size.width*0.68,
                                      // color: Colors.yellow,
                                      child: CustomText(
                                        text: [custProvider.address.text,custProvider.comArea.text,custProvider.city.text,
                                          custProvider.state ?? '',custProvider.country.text,custProvider.pinCode.text,
                                        ].where((e) => e.trim().isNotEmpty).join(', '),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        _myFocusScopeNode.unfocus();
                                        if(locPvr.latitude==""&&locPvr.longitude==""){
                                          await locPvr.manageLocation(context,true);
                                        }else{
                                          utils.navigatePage(context, ()=> const ViaMap());
                                        }
                                      },
                                        child: Icon(Icons.location_on_outlined,color: colorsConst.appRed,))
                                  ],
                                ),
                              ),
                            ),
                            10.height,
                            MapDropDown(
                              width: kIsWeb?webWidth:phoneWidth,
                              hintText: constValue.contactName,
                              list: widget.numberList.isNotEmpty?widget.numberList:sendList,
                              saveValue: custProvider.selectCustomer != null
                                  ? custProvider.selectCustomer["id"]
                                  : null,
                              onChanged: (Object? value) {
                                setState(() {

                                  var selected = (widget.numberList.isNotEmpty
                                      ? widget.numberList
                                      : sendList)
                                      .firstWhere((e) => e["id"] == value);

                                  custProvider.selectCustomer = selected;

                                  localData.storage.write("c_id", selected["id"]);
                                  localData.storage.write("c_no", selected["no"]);
                                  localData.storage.write("c_name", selected["name"]);
                                });
                              },
                              dropText: 'name',
                            ),
                            ///
                            // MaxLineTextField(
                            // isRequired:true,
                            //   text: constValue.disPoints,
                            //   controller: custProvider.disPoint, maxLine: 5,
                            //   textCapitalization: TextCapitalization.sentences,
                            //   textInputAction: TextInputAction.done,
                            // ),
                            //lead
          MapDropDown(
            callback: () {
              if (!kIsWeb) {
                custProvider.refreshLead();
              } else {
                custProvider.getLeadCategory();
              }
            },
            isRefresh: custProvider.leadCategoryList.isEmpty,
            width: kIsWeb ? webWidth : phoneWidth,
            hintText: constValue.leadStatus,
            list: custProvider.leadCategoryList,
            saveValue: custProvider.leadType == null
                ? null
                : custProvider.leadType["id"].toString(),
            onChanged: (Object? value) {
              custProvider.changeLeadType1(value);
            },
            dropText: 'value',
          ),
                            MapDropDown(
                              callback: (){
                                if(!kIsWeb){
                                  custProvider.refreshVisit();
                                }else{
                                  custProvider.getVisitType();
                                }
                              },
                              isRefresh: custProvider.callList.isEmpty,
                              width: kIsWeb ? webWidth : phoneWidth,
                              hintText: constValue.visitType,
                              list: custProvider.callList,
                              saveValue: custProvider.callType,
                              onChanged: (Object? value) {
                                custProvider.changeCallType1(value);
                              },
                              dropText: 'value',
                            ),
                            MaxLineTextField(
                              width: kIsWeb?webWidth:phoneWidth,
                              isRequired: true,
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
                            // SizedBox(
                            //   width: kIsWeb?webWidth:phoneWidth,
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Row(
                            //         children: [
                            //           CustomText(text :"Visit Review",colors: Colors.grey.shade500,),
                            //           CustomText(text :"*",colors: colorsConst.appRed,size: 18,),
                            //         ],
                            //       ),
                            //       10.height,
                            //       Row(
                            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //           children:[
                            //             CustomRadioButton(
                            //               text: 'Complete',
                            //               onChanged: (Object? value) {
                            //                 custProvider.changeReview(value);
                            //               },
                            //               saveValue: custProvider.selectReview, confirmValue: 'Complete',),
                            //             CustomRadioButton(
                            //               text: 'Revisit',
                            //               onChanged: (Object? value) {
                            //                 custProvider.changeReview(value);
                            //               },
                            //               saveValue: custProvider.selectReview, confirmValue: 'Revisit',),
                            //             // CustomRadioButton(
                            //             //   text: 'Cancel',
                            //             //   onChanged: (Object? value) {
                            //             //     custProvider.changeReview(value);
                            //             //   },
                            //             //   saveValue: custProvider.selectReview, confirmValue: 'Cancel',)
                            //           ]
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            40.height,

                          ],
                        ),
                      ),
                    ),
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
                              callback: ()  {
                                // if(widget.isDirect==true&&custProvider.selectCustomer==null){
                                //   utils.showWarningToast(context, text: "Select ${constValue.companyName}");
                                //   custProvider.addCtr.reset();
                                // }
                                // else{
                                if(custProvider.leadType==null){
                                  utils.showWarningToast(context, text: "Select a visit type");
                                  custProvider.addCtr.reset();
                                }
                                // else if(custProvider.selectCustomer==null){
                                //   utils.showWarningToast(context, text: "Select a ${constValue.contactName}");
                                //   custProvider.addCtr.reset();
                                // }
                                else if(custProvider.disPoint.text.trim().isEmpty){
                                  utils.showWarningToast(context, text: "Type a comment");
                                  custProvider.addCtr.reset();
                                }else{
                                  _myFocusScopeNode.unfocus();
                                  custProvider.addVisit(context: context,companyId: widget.isDirect==true?companyId:widget.companyId.toString(), companyName: widget.isDirect==true?companyName:widget.companyName,
                                    sendList: widget.numberList,lat: locPvr.latitude,lng: locPvr.longitude, taskId: widget.taskId, tType: widget.type, desc: widget.desc,
                                    callBack: () {
                                      // if(widget.isDirect==true){
                                      //   Navigator.pop(context);
                                      // }else{
                                      //   custProvider.getCusVisits(widget.companyId);
                                      //   Navigator.pop(context);
                                      // }
                                      utils.navigatePage(context, ()=>
                                          DashBoard(child: VisitReport(date1: home.startDate, date2: home.endDate,month: home.month,type: home.type,)));

                                    },
                                  );
                                }
                                // }
                              },text: 'Save',
                              controller: custProvider.addCtr, isLoading: true, backgroundColor: colorsConst.primary, radius: 10, width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                        ],
                      ),
                    ),
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



