import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/screens/customer/visit_report/visits_report.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:master_code/view_model/location_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_code/view_model/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/customer_provider.dart';
import '../../../component/custom_appbar.dart';
import '../../../component/custom_text.dart';
import '../../../component/custom_textfield.dart';
import '../../../component/map_dropdown.dart';
import '../../../component/maxline_textfield.dart';
import '../../../model/customer/customer_model.dart';
import '../../../source/constant/colors_constant.dart';
import '../../../source/constant/default_constant.dart';
import '../../../source/constant/local_data.dart';
import '../../../source/styles/decoration.dart';
import '../../../source/utilities/utils.dart';
import '../../../view_model/employee_provider.dart';
import '../../common/dashboard.dart';
import '../../customer/viamap.dart';
import '../search_dropdown_list.dart';
import '../task_report.dart';

class AddVisit extends StatefulWidget {
  final String companyId;
  final String companyName;
  final String type;
  final String desc;
  final String taskId;
  final List numberList;
  final bool isDirect;
  const AddVisit({super.key, required this.companyId, required this.companyName, required this.numberList, required this.isDirect, required this.taskId, required this.type, required this.desc});

  @override
  State<AddVisit> createState() => _AddVisitState();
}

class _AddVisitState extends State<AddVisit> with TickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  var companyId="";
  var companyName="";
  List<Map<String, String>> sendList = [];
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setCustomer(Provider.of<CustomerProvider>(context, listen: false).customer);
       Provider.of<CustomerProvider>(context, listen: false).setValue(widget.companyId.toString());
      Provider.of<CustomerProvider>(context, listen: false).initComment(widget.numberList,widget.type);
      companyName="";
      if(Provider.of<LocationProvider>(context, listen: false).latitude!=""&&Provider.of<LocationProvider>(context, listen: false).longitude!=""){
        Provider.of<CustomerProvider>(context, listen: false).getAdd(
            double.parse(Provider.of<LocationProvider>(context, listen: false).latitude),
            double.parse(Provider.of<LocationProvider>(context, listen: false).longitude));
      }
      if(widget.isDirect==false){
        print("DIRECT ==FALSE");
        Provider.of<CustomerProvider>(context, listen: false).selectCustomer=sendList[0];
        print(Provider.of<CustomerProvider>(context, listen: false).selectCustomer);
        localData.storage.write("c_id",sendList[0]["id"]);
        localData.storage.write("c_no",sendList[0]["no"]);
        localData.storage.write("c_name",sendList[0]["name"]);
      }
    });
    // Provider.of<EmployeeProvider>(context, listen: false).getAllUsers();
    // Provider.of<CustomerProvider>(context, listen: false).getAllCustomers(true);
    super.initState();
  }
  void setCustomer(List<CustomerModel> customerList) {
    setState(() {
      companyId = widget.companyId.toString();
      companyName = widget.companyName.toString();

      // ✅ filter from the customer list, not from sendList
      List<CustomerModel> filteredList = customerList.where((customer) {
        final id = customer.userId.toString().toLowerCase();
        final name = customer.firstName.toString().toLowerCase();

        return id.contains(companyId.toLowerCase()) ||
            name.contains(companyName.toLowerCase());
      }).toList();

      if (filteredList.isEmpty) {
        print("No matching customers found");
        return;
      }

      // ✅ final map list to send

      var idList = filteredList[0].customerId.toString().split('||');
      var usersList = filteredList[0].firstName.toString().split('||');
      var phoneList = filteredList[0].phoneNumber.toString().split('||');

      for (var i = 0; i < usersList.length; i++) {
        sendList.add({
          "id": idList[i],
          "name": usersList[i],
          "no": phoneList[i],
        });
      }

      print(sendList); // ✅ now you can use this
    });
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
    return Consumer4<CustomerProvider,TaskProvider,LocationProvider,HomeProvider>(builder: (context,custProvider,taskPvr,locPvr,home,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea (
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: constValue.addVisit),
            ),
            bottomNavigationBar: SizedBox(
              width: kIsWeb?webWidth:phoneWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // CustomLoadingButton(
                  //     callback: (){
                  //       Future.microtask(() => Navigator.pop(context));
                  //     }, isLoading: false,text: "Cancel",
                  //     backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                  //     width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                  // CustomLoadingButton(
                  //     callback: ()  {
                  //       if(custProvider.selectType==null){
                  //         utils.showWarningToast(context, text: "Select a visit type");
                  //         custProvider.addCtr.reset();
                  //       }else if(custProvider.selectCustomer==null){
                  //         utils.showWarningToast(context, text: "Select a ${constValue.contactName}");
                  //         custProvider.addCtr.reset();
                  //       }else if(custProvider.disPoint.text.trim().isEmpty){
                  //         utils.showWarningToast(context, text: "Type a comment");
                  //         custProvider.addCtr.reset();
                  //       }else{
                  //         _myFocusScopeNode.unfocus();
                  //         custProvider.addVisit(context: context,companyId: widget.companyId.toString(), companyName: widget.companyName,
                  //             sendList: widget.numberList,lat: locPvr.latitude,lng: locPvr.longitude,
                  //             taskId: widget.taskId, tType: widget.type, desc: widget.desc,
                  //             callBack: (){
                  //               utils.navigatePage(context, ()=>DashBoard(child:
                  //               TaskReport(taskId: widget.taskId,coId: companyId,numberList: widget.numberList, isTask: false,
                  //                 coName: companyName,description: widget.desc,type: widget.type,
                  //                 callback: () {
                  //                   Future.microtask(() => Navigator.pop(context));
                  //                   Future.microtask(() => Navigator.pop(context));
                  //                 }, index: 1,
                  //               )));
                  //             });
                  //       }
                  //     },text: 'Save',
                  //     controller: custProvider.addCtr, isLoading: true, backgroundColor: colorsConst.primary, radius: 10, width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                ],
              ),
            ) ,
            body: Center(
              child: SizedBox(
                width: kIsWeb?webWidth:phoneWidth,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            20.height,
                             // if(widget.isDirect==true)
                            // custProvider.refresh == false?
                            // const Loading()
                            //     :CustomerDropdown(
                            //   hintText: false,
                            //   text: widget.companyName.toString(),isRequired: true,
                            //   employeeList: custProvider.customer,
                            //   onChanged: (CustomerModel? value) {
                            //     // setState(() {
                            //       // companyId=value!.userId.toString();
                            //       // companyName=value.companyName.toString();
                            //       // sendList=[];
                            //       // var idList=value.customerId.toString().split('||');
                            //       // var usersList=value.firstName.toString().split('||');
                            //       // var phoneList=value.phoneNumber.toString().split('||');
                            //       // for(var i=0;i<usersList.length;i++){
                            //       //   sendList.add({"id": idList[i], "name": usersList[i], "no": phoneList[i]});
                            //       // }
                            //       // custProvider.setCustomer(sendList);
                            //     // });
                            //   }, size: kIsWeb?webWidth:phoneWidth,),
                            CustomText(text: widget.companyName.toString()=="null"?"":widget.companyName.toString()),
                            if(widget.isDirect==false)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(text: widget.companyName,colors: colorsConst.primary,isBold: true,),10.width,
                                // CustomText(text: widget.type,colors: colorsConst.greyClr,isItalic: true,),
                              ],
                            ),
                        
                            MapDropDown(isRequired:true,
                              isRefresh: taskPvr.typeList.isEmpty?true:false,
                              callback: (){
                              if(!kIsWeb){
                                taskPvr.getTaskType(true);
                              }else{
                                taskPvr.getAllTypes();
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
                            MapDropDown(
                              isRequired: true,
                              isRefresh: taskPvr.cusTypeList.isEmpty,

                              callback: () {
                                if (!kIsWeb) {
                                  taskPvr.refreshCusType();
                                } else {
                                  taskPvr.getAllCusTypes();
                                }
                              },

                              width: kIsWeb ? webWidth : phoneWidth,
                              hintText: constValue.cusType,

                              list: taskPvr.cusTypeList,

                              saveValue: taskPvr.selectType != null
                                  ? taskPvr.selectType['id'].toString()
                                  : null,

                              onChanged: (value) {
                                final selected = taskPvr.cusTypeList.firstWhere(
                                      (e) => e['id'].toString() == value.toString(),
                                );

                                taskPvr.changeCusType(selected); // ✅ same provider
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
                                onChanged: (value) {
                                  custProvider.changeType(
                                      custProvider.cmtTypeList.firstWhere((e) => e['id'] == value)
                                  );
                                }
                            ),
                            SizedBox(
                              width: kIsWeb?webWidth:phoneWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CustomText(text: "Visit Location",colors: Colors.black),
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
                            // MapDropDown(
                            //   isRequired: true,
                            //   width: kIsWeb ? webWidth : phoneWidth,
                            //   hintText: constValue.contactName,
                            //   list: widget.isDirect == false ? widget.numberList : sendList,
                            //
                            //   // ✅ save only id
                            //   saveValue: custProvider.selectCustomer?["id"],
                            //
                            //   onChanged: (Object? value) {
                            //     setState(() {
                            //
                            //       // 🔥 find full object from list
                            //       final selected = (widget.isDirect == false
                            //           ? widget.numberList
                            //           : sendList)
                            //           .firstWhere((e) => e["id"].toString() == value.toString());
                            //
                            //       custProvider.selectCustomer = selected;
                            //
                            //       localData.storage.write("c_id", selected["id"]);
                            //       localData.storage.write("c_no", selected["no"]);
                            //       localData.storage.write("c_name", selected["name"]);
                            //     });
                            //   },
                            //
                            //   dropText: 'name',
                            // ),
                            10.height,
                            Consumer<CustomerProvider>(
                              builder: (context, custProvider, child) {
                                return SearchCustomDropdownList(
                                  text: "Customer",
                                  hintText: custProvider.selectCustomerName.isEmpty
                                      ? "Select Customer"
                                      : custProvider.selectCustomerName,
                                  valueList: widget.numberList.isNotEmpty
                                      ? widget.numberList
                                      : sendList.map((e) => e["name"].toString()).toList(),
                                  displayKey: "name",
                                  onChanged: (value) {
                                    if (value != null && value is List) {
                                      List<Map<String, dynamic>> selectedCustomers =
                                      value.map((e) => e as Map<String, dynamic>).toList();

                                      final uniqueCustomers = <Map<String, dynamic>>[];
                                      final ids = <String>{};

                                      for (var c in selectedCustomers) {
                                        if (!ids.contains(c["id"].toString())) {
                                          uniqueCustomers.add(c);
                                          ids.add(c["id"].toString());
                                        }
                                      }
                                      String displayNames = uniqueCustomers.map((e) => e["name"].toString()).join(", ");
                                      print("Display ${displayNames}");
                                      custProvider.updateCustomers(uniqueCustomers, displayNames);

                                    } else {
                                      custProvider.clearCustomers();
                                    }
                                  },
                                  width: kIsWeb ? webWidth : phoneWidth,
                                );
                              },
                            ),
                            ///
                            // MaxLineTextField(isRequired:true,
                            //   text: constValue.disPoints,
                            //   controller: custProvider.disPoint, maxLine: 5,
                            //   textCapitalization: TextCapitalization.sentences,
                            //   textInputAction: TextInputAction.done,
                            // ),
                            MapDropDown(
                              callback: (){
                                if(!kIsWeb){
                                  custProvider.refreshLead();
                                }else{
                                  custProvider.getLeadCategory();
                                }
                              },
                              isRefresh: custProvider.leadCategoryList.isEmpty?true:false,
                              width: kIsWeb?webWidth:phoneWidth,
                              hintText: constValue.leadStatus,
                              list: custProvider.leadCategoryList,
                              saveValue: custProvider.leadType?['id'],
                              onChanged: (Object? value) {
                                final selected = custProvider.leadCategoryList.firstWhere(
                                      (e) => e['id'].toString() == value.toString(),
                                  orElse: () => <String, String>{},
                                );

                                if (selected.isNotEmpty) {
                                  custProvider.changeLeadType(selected);
                                }
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
                              isRefresh: custProvider.callList.isEmpty?true:false,
                              width:kIsWeb?webWidth:phoneWidth,
                              hintText: constValue.visitType,
                              list: custProvider.callList,
                              saveValue: custProvider.callType?['id'],
                              onChanged: (Object? value) {
                                final selected = custProvider.callList
                                    .firstWhere((e) => e['id'].toString() == value.toString());

                                custProvider.changeCallType(selected);
                              },
                              dropText: 'value',),
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
                        
                          ],
                        ),
                      ),
                    ),
                    40.height,
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
                                if(custProvider.selectType==null){
                                  utils.showWarningToast(context, text: "Select a visit type");
                                  custProvider.addCtr.reset();
                                }else if(sendList.map((e) => e["name"].toString()).toList().isEmpty){
                                  utils.showWarningToast(context, text: "Select a ${constValue.contactName}");
                                  custProvider.addCtr.reset();
                                }else if(custProvider.disPoint.text.trim().isEmpty){
                                  utils.showWarningToast(context, text: "Type a comment");
                                  custProvider.addCtr.reset();
                                }else{
                                  _myFocusScopeNode.unfocus();
                                  custProvider.addVisit(context: context,companyId: widget.companyId.toString(), companyName: widget.companyName,
                                      sendList: widget.numberList,lat: locPvr.latitude,lng: locPvr.longitude,
                                      taskId: widget.taskId, tType: widget.type, desc: widget.desc, cusName:sendList.map((e) => e["name"].toString()).toList(),
                                      callBack: (){
                                        utils.navigatePage(context, ()=>
                                            DashBoard(child: VisitReport(date1: home.startDate, date2: home.endDate,month: home.month,type: home.type,)));

                                        //  Future.microtask(() => Navigator.pop(context));

                                  },
                                      );
                                }
                              },text: 'Save',
                              controller: custProvider.addCtr, isLoading: true, backgroundColor: colorsConst.primary, radius: 10, width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                        ],
                      ),
                    ),40.height
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



