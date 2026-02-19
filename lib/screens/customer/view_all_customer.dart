import 'package:master_code/screens/customer/create_customer.dart';
import 'package:master_code/screens/customer/update_customer.dart';
import 'package:master_code/screens/customer/view_task.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/component/customer_data.dart';
import 'package:master_code/screens/customer/visit/customer_visits.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:master_code/view_model/customer_provider.dart';
import 'package:provider/provider.dart';
import 'package:master_code/view_model/home_provider.dart';
import '../../component/animated_button.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/location_provider.dart';
import '../common/dashboard.dart';
import '../common/home_page.dart';
import '../../source/constant/local_data.dart';
import 'customer_details.dart';

class ViewCustomer extends StatefulWidget {
  const ViewCustomer({super.key
  });

  @override
  State<ViewCustomer> createState() => _ViewCustomerState();
}

class _ViewCustomerState extends State<ViewCustomer> with TickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      customerProvider.initFilterValue(true);
      if(kIsWeb){
        customerProvider.getLeadCategory();
        customerProvider.getVisitType();
        customerProvider.getCmtType();
      }else{
        customerProvider.getLead();
        customerProvider.getVisit();
        customerProvider.getCommentType();
      }
      customerProvider.allTemplates();
      locationProvider.manageLocation(context,false);
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
    return Consumer3<CustomerProvider,HomeProvider,LocationProvider>(builder: (context,custProvider,homeProvider,locPvr,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size(300, 55),
              child: CustomAppbar(text: constValue.customers,callback: (){
                homeProvider.updateIndex(0);
                _myFocusScopeNode.unfocus();
                utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
              },
                isButton: true,
                buttonCallback:  () {
                  _myFocusScopeNode.unfocus();
                  utils.navigatePage(context, ()=>const DashBoard(child: CreateCustomer()));
                },),
            ),
            backgroundColor: colorsConst.bacColor,
            body: SafeArea(
              child: PopScope(
                canPop: false,
                onPopInvoked: (bool didPop) {
                  homeProvider.updateIndex(0);
                  _myFocusScopeNode.unfocus();
                  if (!didPop) {
                    utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
                  }
                },
                child: custProvider.cusRefresh == false ?
                const Loading()
                    :Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomTextField(
                                text: "",radius: 30,
                                controller: custProvider.search,
                                width:kIsWeb?webWidth/1.2:phoneWidth/1.2,
                                hintText: "Search Name Or Phone No",
                                isIcon: true,
                                iconData: Icons.search,
                                textInputAction: TextInputAction.done,
                                isShadow: true,
                                onChanged: (value) {
                                  custProvider.searchCustomer(value.toString());
                                },
                                isSearch: custProvider.search.text.isNotEmpty?true:false,
                                searchCall: (){
                                  custProvider.search.clear();
                                  custProvider.searchCustomer("");
                                },
                              ),
                              InkWell(
                                onTap: (){
                                  _myFocusScopeNode.unfocus();
                                  showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Consumer<CustomerProvider>(
                                      builder: (context, empProvider, _) {
                                        return AlertDialog(
                                          actions: [
                                            SizedBox(
                                              width:kIsWeb?webWidth/1.2:phoneWidth/1.2,
                                              child: Column(
                                                children: [
                                                  20.height,
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      70.width,
                                                      const CustomText(
                                                        text: 'Filters',
                                                        colors: Colors.black,
                                                        size: 16,
                                                        isBold: true,
                                                      ),
                                                      30.width,
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.of(context, rootNavigator: true).pop();
                                                        },
                                                        child: SvgPicture.asset(assets.cancel),
                                                      )
                                                    ],
                                                  ),
                                                  20.height,
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          CustomText(
                                                            text: "From Date",
                                                            colors: colorsConst.greyClr,
                                                            size: 12,
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              custProvider.datePick(
                                                                context: context,
                                                                isStartDate: true,
                                                                date: custProvider.startDate,
                                                              );
                                                            },
                                                            child: Container(
                                                              height: 30,
                                                              width:kIsWeb?webWidth/2.5:phoneWidth/2.5,
                                                              decoration: customDecoration.baseBackgroundDecoration(
                                                                color: Colors.white,
                                                                radius: 5,
                                                                borderColor: colorsConst.litGrey,
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  CustomText(text: custProvider.startDate),
                                                                  5.width,
                                                                  SvgPicture.asset(assets.calendar2),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          CustomText(
                                                            text: "To Date",
                                                            colors: colorsConst.greyClr,
                                                            size: 12,
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              custProvider.datePick(
                                                                context: context,
                                                                isStartDate: false,
                                                                date: custProvider.endDate,
                                                              );
                                                            },
                                                            child: Container(
                                                              height: 30,
                                                              width:kIsWeb?webWidth/2.5:phoneWidth/2.5,
                                                              decoration: customDecoration.baseBackgroundDecoration(
                                                                color: Colors.white,
                                                                radius: 5,
                                                                borderColor: colorsConst.litGrey,
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  CustomText(text: custProvider.endDate),
                                                                  5.width,
                                                                  SvgPicture.asset(assets.calendar2),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  10.height,
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CustomText(
                                                        text: "Select Date Range",
                                                        colors: colorsConst.greyClr,
                                                        size: 12,
                                                      ),
                                                      Container(
                                                        height: 30,
                                                        width:kIsWeb?webWidth/1.2:phoneWidth/1.2,
                                                        decoration: customDecoration.baseBackgroundDecoration(
                                                          radius: 5,
                                                          color: Colors.white,
                                                          borderColor: colorsConst.litGrey,
                                                        ),
                                                        child: DropdownButton(
                                                          iconEnabledColor: colorsConst.greyClr,
                                                          isExpanded: true,
                                                          underline: const SizedBox(),
                                                          icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                                          value: custProvider.filterType,
                                                          onChanged: (value) {
                                                            custProvider.changeFilterType(value);
                                                          },
                                                          items: custProvider.filterTypeList.map((list) {
                                                            return DropdownMenuItem(
                                                              value: list,
                                                              child: CustomText(
                                                                text: "  $list",
                                                                colors: Colors.black,
                                                                isBold: false,
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  20.height,
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      CustomBtn(
                                                        width: 100,
                                                        text: 'Clear All',
                                                        callback: () {
                                                          custProvider.closeVisible();
                                                          custProvider.initFilterValue(true);
                                                          Navigator.of(context, rootNavigator: true).pop();
                                                        },
                                                        bgColor: Colors.grey.shade200,
                                                        textColor: Colors.black,
                                                      ),
                                                      CustomBtn(
                                                        width: 100,
                                                        text: 'Apply Filters',
                                                        callback: () {
                                                          custProvider.closeVisible();
                                                          custProvider.filterList();
                                                          Navigator.of(context, rootNavigator: true).pop();
                                                        },
                                                        bgColor: colorsConst.primary,
                                                        textColor: Colors.white,
                                                      ),
                                                    ],
                                                  ),
                                                  20.height,
                                                ],
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                                },
                                child: Container(
                                  width:kIsWeb?webWidth/6:phoneWidth/6,
                                  height: 45,
                                  decoration: customDecoration.baseBackgroundDecoration(
                                      color: custProvider.filter==true?colorsConst.primary:Colors.grey.shade300,radius: 5
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: SvgPicture.asset(assets.filter,width: 15,height: 15,),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      5.height,
                      custProvider.filterCustomerData.isEmpty ?
                      Column(
                        children: [
                          100.height,
                          CustomText(
                              text: constValue.noCustomer, colors: colorsConst.greyClr)
                        ],
                      ) : Flexible(
                        child: Center(
                          child: SizedBox(
                            width: kIsWeb?webWidth:phoneWidth,
                            child: ListView.builder(
                                itemCount: custProvider.filterCustomerData.length,
                                itemBuilder: (context, index) {
                                  // CustomerModel data = custProvider.customer[index];
                                  final sortedData = custProvider.filterCustomerData;
                                  // if (custProvider.sortBy== "1") {
                                  //   custProvider.customer.sort((a, b) =>
                                  //       a.companyName!.compareTo(b.companyName.toString()));
                                  // }else {
                                  //   custProvider.customer.sort((a, b) {
                                  //     final aChecked = a.isChecked ?? false; // Default to false if null
                                  //     final bChecked = b.isChecked ?? false; // Default to false if null
                                  //     return aChecked.toString().compareTo(bChecked.toString());
                                  //   });
                                  // }
                                  final data = sortedData[index];
                                  // print(data.createdTs.toString());
                                  var createdBy = "";
                                  String timestamp = data.createdTs.toString();
                                  DateTime dateTime = DateTime.parse(timestamp);
                                  String dayOfWeek = DateFormat('EEEE').format(dateTime);
                                  DateTime today = DateTime.now();
                                  if (dateTime.day == today.day && dateTime.month == today.month && dateTime.year == today.year) {
                                    dayOfWeek = 'Today';
                                  } else if (dateTime.isAfter(today.subtract(const Duration(days: 1))) &&
                                      dateTime.isBefore(today)) {
                                    dayOfWeek = 'Yesterday';
                                  } else {
                                    dayOfWeek = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                                  }
                                  createdBy = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                                  final showDateHeader = index == 0 || createdBy != getCreatedDate(sortedData[index - 1]);
                                  return Column(
                                    children: [
                                      CustomerData(
                                        dayOfWeek: dayOfWeek,
                                        showDateHeader: showDateHeader,
                                        callback2: (){
                                          _myFocusScopeNode.unfocus();
                                          utils.navigatePage(context, ()=> DashBoard(child: CustomerDetails(id: data.userId.toString())));
                                        },
                                        mailCallback: () {
                                          custProvider.emailSubjectCtr.clear();
                                          custProvider.emailMessageCtr.clear();
                                          custProvider.photo1 = "";
                                          custProvider.emailToCtr.clear();

                                          custProvider.sendEmailDialog(
                                            id: data.userId.toString(),
                                            name: "displayName",
                                            mobile: "",
                                            coName: data.companyName.toString(),
                                            context: context,
                                          );
                                        },
                                        customerData: data,show: custProvider.isVisible==true&&
                                          custProvider.visibleIndex==index?true:false,
                                        callback: () async {
                                          _myFocusScopeNode.unfocus();
                                          if(data.isChecked.toString()=="2"){
                                            utils.showWarningToast(context, text: "Already attendance marked");
                                          }else{
                                            localData.storage.write("cus_id", data.userId.toString());
                                            if(locPvr.latitude!=""&&locPvr.longitude!=""){
                                              custProvider.customerDailyAtt(
                                                  context,data.isChecked.toString()=="null"?"1":"2",data.firstName.toString(),
                                                  data.companyName.toString(),locPvr.latitude,locPvr.longitude);
                                            }else{
                                              await locPvr.manageLocation(context, true);
                                            }
                                          }
                                        },
                                        iconCallback: () {
                                          _myFocusScopeNode.unfocus();
                                          custProvider.visible(index);
                                        },
                                        iconCallback2: () {
                                          _myFocusScopeNode.unfocus();
                                          custProvider.closeVisible();
                                        },
                                        editCallBack: () {
                                          _myFocusScopeNode.unfocus();
                                          utils.navigatePage(context, ()=> DashBoard(child: UpdateCustomer(customerId: data.userId.toString())));
                                        },
                                        reportCallBack: () {
                                          _myFocusScopeNode.unfocus();
                                          // homeProvider.changeCusList(companyId:data.userId,companyName:data.companyName);
                                      },
                                        taskCallBack: (){
                                          _myFocusScopeNode.unfocus();
                                          var idList=data.customerId.toString().split('||');
                                          var usersList=data.firstName.toString().split('||');
                                          var phoneList=data.phoneNumber.toString().split('||');
                                          var sendList=[];
                                          for(var i=0;i<usersList.length;i++){
                                            sendList.add({"id": idList[i], "name": usersList[i], "no": phoneList[i]});
                                          }
                                          utils.navigatePage(context, ()=> DashBoard(child:
                                          ViewTasks(coId:data.userId.toString(),numberList: sendList, companyName: data.companyName.toString(),)));
                                        },
                                        shareCallback: (){
                                          custProvider.shareCustomerDetails(data);
                                        },
                                        visitsCallBack: () {
                                          _myFocusScopeNode.unfocus();
                                          var idList=data.customerId.toString().split('||');
                                          var usersList=data.firstName.toString().split('||');
                                          var phoneList=data.phoneNumber.toString().split('||');
                                          var sendList=[];
                                          for(var i=0;i<usersList.length;i++){
                                            sendList.add({"id": idList[i], "name": usersList[i], "no": phoneList[i]});
                                          }
                                          utils.navigatePage(context, ()=> DashBoard(child:
                                          CusVisits(taskId:"0",companyId: data.userId.toString(),companyName: data.companyName.toString(), customerList: sendList,)));
                                      },),
                                      15.height,
                                      if(index ==custProvider.customer.length - 1)
                                        70.height
                                    ],
                                  );
                                }),
                          ),
                        ),
                      )
                    ]
                ),
              ),
            ),
        ),),
      );
  });
  }
  String getCreatedDate(data) {
    final timestamp = data.createdTs.toString();
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}
