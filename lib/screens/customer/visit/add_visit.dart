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
import '../../../component/multi_dropdown.dart' hide MapDropDown, MultiSelectDropdown;
import '../../../component/search_drop_down.dart';
import '../../../model/customer/customer_model.dart';
import '../../../source/constant/colors_constant.dart';
import '../../../source/constant/default_constant.dart';
import '../../../source/styles/decoration.dart';
import '../../../source/utilities/utils.dart';
import '../../../view_model/task_provider.dart';
import '../../common/dashboard.dart';
import '../../task/search_custom_dropdown.dart' hide MapDropDown, MultiSelectDropdown;
import '../../task/search_dropdown_list.dart';
import '../viamap.dart';
import '../visit_report/visits_report.dart';
import 'add_company.dart';
import 'add_customer.dart';

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
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);

      /// 🔥 RESET
      customerProvider.resetVisitForm();
      customerProvider.setMultiSelectedCustomers([]);

      setState(() {
        companyId = widget.companyId.toString();
        companyName = widget.companyName.toString();
        sendList = [];
      });

      /// ✅ Run API parallel (fast + no lag)
      await Future.wait([
        employeeProvider.getAllUsers(),
        taskProvider.getCustomerType(false),
        customerProvider.getAllCustomers(true),
      ]);

      if (!kIsWeb) {
        await taskProvider.getAllTypes();
      } else {
        await Future.wait([
          taskProvider.getTaskType(false),
          taskProvider.getTaskStatuses(),
        ]);
      }

      if (widget.isDirect == true) {
        if (kIsWeb) {
          await Future.wait([
            customerProvider.getLeadCategory(),
            customerProvider.getVisitType(),
            customerProvider.getCmtType(),
          ]);
        } else {
          await Future.wait([
            customerProvider.getLead(),
            customerProvider.getVisit(),
            customerProvider.getCommentType(),
          ]);
        }
      }

      customerProvider.initComment(widget.numberList, widget.type);

      if (locationProvider.latitude.isNotEmpty &&
          locationProvider.longitude.isNotEmpty) {
        customerProvider.getAdd(
          double.parse(locationProvider.latitude),
          double.parse(locationProvider.longitude),
        );
      }
    });
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

    return Consumer4<CustomerProvider,LocationProvider,TaskProvider,HomeProvider>(
        builder: (context,custProvider,locPvr,taskProvider,home,_){
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                22.width,
                                CustomText(text: constValue.companyName,colors:Colors.black,size: 14,),10.width,

                              ],
                            ),
                            if(widget.isDirect==true)
                              Consumer<CustomerProvider>(
                                builder: (context, custProvider, child) {

                                  List<CustomerModel> updatedCompanyList = [
                                    CustomerModel(
                                      userId: "add_company",
                                      companyName: "+ Add Company",
                                      customerId: "",
                                      firstName: "",
                                      phoneNumber: "",
                                    ),
                                    ...custProvider.customer,
                                  ];

                                  return CustomerDropdown(
                                    key: ValueKey(custProvider.customer.length),
                                    hintText: false,// 🔥 force rebuild
                                    text: companyId == "" ? constValue.companyName : companyName,
                                    employeeList: updatedCompanyList,
                                    onChanged: (CustomerModel? value) async {

                                      if (value == null) return;

                                      // ✅ Add Company Click
                                      if (value.userId.toString() == "add_company") {

                                        final result = await showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (_) => const AddCompanyPopup(),
                                        );

                                        if (result != null && result is CustomerModel) {

                                          // ✅ company set instantly
                                          setState(() {
                                            companyId = result.userId.toString();
                                            companyName = result.companyName.toString();
                                          });

                                          custProvider.setMultiSelectedCustomers([]);

                                          // ✅ build customer list for that company
                                          List<Map<String, dynamic>> tempList = [];

                                          var idList = result.customerId.toString().split("||");
                                          var usersList = result.firstName.toString().split("||");
                                          var phoneList = result.phoneNumber.toString().split("||");

                                          for (int i = 0; i < usersList.length; i++) {
                                            tempList.add({
                                              "id": idList[i],
                                              "name": usersList[i],
                                              "no": phoneList[i],
                                            });
                                          }

                                          setState(() {
                                            sendList = tempList;
                                          });

                                          // ✅ auto select first customer
                                          if (tempList.isNotEmpty) {
                                            custProvider.setMultiSelectedCustomers([tempList[0]]);
                                          }
                                        }

                                        return; // 🔥 stop here
                                      }

                                      // ✅ Normal Company Select
                                      setState(() {
                                        companyId = value.userId.toString();
                                        companyName = value.companyName.toString();
                                      });

                                      custProvider.setMultiSelectedCustomers([]);

                                      List<Map<String, dynamic>> tempList = [];

                                      var idList = value.customerId.toString().split("||");
                                      var usersList = value.firstName.toString().split("||");
                                      var phoneList = value.phoneNumber.toString().split("||");

                                      for (int i = 0; i < usersList.length; i++) {
                                        tempList.add({
                                          "id": idList[i],
                                          "name": usersList[i],
                                          "no": phoneList[i],
                                        });
                                      }

                                      setState(() {
                                        sendList = tempList;
                                      });

                                      if (tempList.length == 1) {
                                        custProvider.setMultiSelectedCustomers([tempList[0]]);
                                      }
                                    },
                                    size: kIsWeb ? webWidth : phoneWidth,
                                  );
                                },
                              ),

                            if(widget.isDirect==false)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomText(text: widget.companyName=="null"?"":widget.companyName,colors: colorsConst.primary,isBold: true,),10.width,
                                  // CustomText(text: widget.type,colors: colorsConst.greyClr,isItalic: true,),
                                ],
                              ),
                            MapDropDown(
                              isRefresh: taskProvider.cusTypeList.isEmpty,
                              callback: () {
                                if (!kIsWeb) {
                                  taskProvider.refreshCusType();
                                } else {
                                  taskProvider.getAllCusTypes();
                                }
                              },
                              width: kIsWeb ? webWidth : phoneWidth,
                              hintText: constValue.cusType,
                              list: taskProvider.cusTypeList,

                              saveValue: taskProvider.selectType != null
                                  ? taskProvider.selectType['id']   // ✅ remove toString
                                  : null,

                              onChanged: (value) {
                                final selected = taskProvider.cusTypeList.firstWhere(
                                      (e) => e['id'] == value, // ✅ direct compare
                                );

                                taskProvider.changeCusType(selected);
                              },

                              dropText: 'value',
                            ),

                            // Consumer<CustomerProvider>(
                            //   builder: (context, custProvider, child) {
                            //
                            //     return MultiSelectDropdown(
                            //       key: ValueKey(sendList), // 🔥 MUST (force rebuild)
                            //       hintText: "Select Customer",
                            //       dropText: "name",
                            //
                            //       list: sendList, // 🔥 updated list
                            //
                            //       width: kIsWeb ? webWidth : phoneWidth,
                            //
                            //       selectedItems: custProvider.multiSelectedCustomerList,
                            //
                            //       onChanged: (list) {
                            //         print("👆 MultiSelect onChanged CALLED");
                            //         print("📝 Selected List: $list");
                            //
                            //         custProvider.setMultiSelectedCustomers(list);
                            //       },
                            //     );
                            //   },
                            // ),
        Consumer<CustomerProvider>(
          builder: (context, custProvider, child) {

            List<dynamic> updatedList = [];

            // ✅ sendList empty illa na mattum Add Customer add pannunga
            if (sendList.isNotEmpty) {
              updatedList = [
                {"id": "add_customer", "name": "+ Add Customer"},
                ...sendList,
              ];
            } else {
              updatedList = sendList; // empty list
            }

            return MultiSelectDropdown(
              key: ValueKey(updatedList),
              hintText: "Select Customer",
              dropText: "name",
              list: updatedList,
              width: kIsWeb ? webWidth : phoneWidth,
              selectedItems: custProvider.multiSelectedCustomerList,
              onChanged: (list) async {

                bool isAddCustomerSelected =
                list.any((item) => item["id"] == "add_customer");

                if (isAddCustomerSelected) {

                  list.removeWhere((e) => e["id"] == "add_customer");

                  final result = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => AddCustomerPopup(
                      companyId: companyId.toString(), // ✅ selected companyId
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      sendList.insert(0, result); // ✅ dropdown list update
                    });

                    list.add(result);
                    custProvider.setMultiSelectedCustomers(list);
                  }
                }

                custProvider.setMultiSelectedCustomers(list);
              },
            );
          },
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



                            // InkWell(
                            //   onTap: () {
                            //     final listData =
                            //     widget.numberList.isNotEmpty ? widget.numberList : sendList;
                            //
                            //     custProvider.openMultiSelectCustomerDialog(context, listData);
                            //   },
                            //   child: Container(
                            //     height: 50,
                            //     width: kIsWeb ? webWidth : phoneWidth,
                            //     padding: const EdgeInsets.symmetric(horizontal: 12),
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(10),
                            //       border: Border.all(color: Colors.grey.shade300),
                            //       color: Colors.white,
                            //     ),
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //       children: [
                            //         Expanded(
                            //           child: Text(
                            //             custProvider.selectedCustomers.isEmpty
                            //                 ? "Select Contact Name"
                            //                 : custProvider.selectedCustomers.map((e) => e["name"]).join(", "),
                            //             maxLines: 1,
                            //             overflow: TextOverflow.ellipsis,
                            //             style: const TextStyle(fontSize: 13),
                            //           ),
                            //         ),
                            //         const Icon(Icons.keyboard_arrow_down),
                            //       ],
                            //     ),
                            //   ),
                            // ),
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
                              hintText: constValue.leadStatus,isRequired: true,
                              list: (custProvider.leadCategoryList..sort((a, b) {
                                return int.parse(a["id"].toString())
                                    .compareTo(int.parse(b["id"].toString()));
                              })),
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
                            ),
                            5.height,
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
                                  utils.showWarningToast(context, text: "Select a Lead type");
                                  custProvider.addCtr.reset();
                                }
                                // else if(custProvider.selectCustomer==null){
                                //   utils.showWarningToast(context, text: "Select a ${constValue.contactName}");
                                //   custProvider.addCtr.reset();
                                // }
                                else if(custProvider.disPoint.text.trim().isEmpty){
                                  utils.showWarningToast(context, text: "Type a comment");
                                  custProvider.addCtr.reset();
                                }
                                else{
                                  _myFocusScopeNode.unfocus();
                                  custProvider.addVisit(
                                    context: context,companyId: widget.isDirect==true?
                                  companyId:widget.companyId.toString(),
                                    companyName: widget.isDirect==true?companyName:widget.companyName,
                                    sendList: custProvider.multiSelectedCustomerList
                                        .map((e) => e["id"].toString())
                                        .toList(),

                                    cusName: custProvider.multiSelectedCustomerList
                                        .map((e) => e["name"].toString())
                                        .toList(),
                                    lat: locPvr.latitude,
                                    lng: locPvr.longitude,
                                    taskId: widget.taskId,
                                    tType: widget.type,
                                    desc: widget.desc,
                                    callBack: () {
                                      // if(widget.isDirect==true){
                                      //   Navigator.pop(context);
                                      // }else{
                                      //   custProvider.getCusVisits(widget.companyId);
                                      //   Navigator.pop(context);
                                      // }
                                      utils.navigatePage(context, ()=>
                                          DashBoard(child: VisitReport(
                                            date1: home.startDate,
                                            date2: home.endDate,
                                            month: home.month,
                                            type: home.type,)));

                                    },
                                  );
                                }
                                // }
                              },text: 'Save',
                              controller: custProvider.addCtr, isLoading: true,
                              backgroundColor: colorsConst.primary,
                              radius: 10,
                              width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
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