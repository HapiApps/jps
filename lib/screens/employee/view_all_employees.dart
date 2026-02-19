import 'package:master_code/screens/employee/create_employee.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/constant/assets_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_code/view_model/home_provider.dart';
import '../../component/animated_button.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/employee_provider.dart';
import '../../view_model/location_provider.dart';
import '../common/dashboard.dart';
import '../common/home_page.dart';
import 'emp_data.dart';

class ViewEmployees extends StatefulWidget {
  const ViewEmployees({super.key});

  @override
  State<ViewEmployees> createState() => _ViewEmployeesState();
}

class _ViewEmployeesState extends State<ViewEmployees> with SingleTickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

      locationProvider.manageLocation(context, false);
      employeeProvider.initFilterValue(true);
      employeeProvider.getGrades(true);

      if (!kIsWeb) {
        employeeProvider.getAllRoles();
      } else {
        employeeProvider.getRoles();
      }

      if (locationProvider.latitude.isNotEmpty && locationProvider.longitude.isNotEmpty) {
        final lat = double.tryParse(locationProvider.latitude);
        final lng = double.tryParse(locationProvider.longitude);
        if (lat != null && lng != null) {
          employeeProvider.getAdd(lat, lng);
        }
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
    return Consumer2<EmployeeProvider,HomeProvider>(builder: (context,empProvider,homeProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
              appBar: PreferredSize(
                preferredSize: const Size(300, 55),
                child: CustomAppbar(text: constValue.employee,callback: (){
                  homeProvider.updateIndex(0);
                  _myFocusScopeNode.unfocus();
                  utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
                },
                  isButton: true,
                  buttonCallback:  () {
                    _myFocusScopeNode.unfocus();
                    utils.navigatePage(context, ()=>const DashBoard(child: CreateEmployee()));
                  },
                ),
              ),
            body: PopScope(
              canPop: false,
              onPopInvoked: (bool didPop) {
                _myFocusScopeNode.unfocus();
                homeProvider.updateIndex(0);
                if (!didPop) {
                  utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
                }
              },
              child: Center(
                child: SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  // color: Colors.red,
                  child: empProvider.empRefresh==false?
                  const Loading():
                  Column(
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextField(
                              controller: empProvider.search,radius: 30,
                              width:kIsWeb?webWidth/1.2:phoneWidth/1.2,
                              text: "",
                              isIcon: true,hintText: "Search Name or No",
                              iconData: Icons.search,
                              textInputAction: TextInputAction.done,
                              onChanged: (value) {
                                empProvider.searchUser(value.toString());
                              },
                              isSearch: empProvider.search.text.isNotEmpty?true:false,
                              searchCall: (){
                                empProvider.search.clear();
                                empProvider.searchUser("");
                              },
                            ),
                            InkWell(
                              onTap: (){
                                _myFocusScopeNode.unfocus();
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Consumer<EmployeeProvider>(
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
                                                              empProvider.datePick(
                                                                context: context,
                                                                isStartDate: true,
                                                                date: empProvider.startDate,
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
                                                                  CustomText(text: empProvider.startDate),
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
                                                              empProvider.datePick(
                                                                context: context,
                                                                isStartDate: false,
                                                                date: empProvider.endDate,
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
                                                                  CustomText(text: empProvider.endDate),
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
                                                          value: empProvider.type,
                                                          onChanged: (value) {
                                                            empProvider.changeType(value);
                                                          },
                                                          items: empProvider.typeList.map((list) {
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
                                                  10.height,
                                                  SizedBox(
                                                    width:kIsWeb?webWidth/1.2:phoneWidth/1.2,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        CustomText(
                                                          text: "Employee Role",
                                                          colors: colorsConst.greyClr,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  5.height,
                                                  SizedBox(
                                                    // height: empProvider.roleValues.length <= 2
                                                    //     ? 15
                                                    //     : (empProvider.roleValues.length / 2).ceil() * 15 + 30,
                                                    // height: empProvider.roleValues.length*20, // Adjust this height to your needs
                                                    width:kIsWeb?webWidth/1.2:phoneWidth/1.2,
                                                    child: GridView.builder(
                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 3,
                                                        crossAxisSpacing: kIsWeb?5:10,
                                                        mainAxisSpacing: kIsWeb?5:10,
                                                        mainAxisExtent: 40, // a little taller
                                                      ),
                                                      itemCount: empProvider.roleValues.length,
                                                      shrinkWrap: true,
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      itemBuilder: (context, index) {
                                                        return InkWell(
                                                            onTap: () {
                                                              empProvider.selectedRole(
                                                                  empProvider.roleValues[index]["id"]);
                                                            },
                                                            child: Container(
                                                              // height: 10,
                                                              decoration: customDecoration.baseBackgroundDecoration(
                                                                color: empProvider.selectRole ==
                                                                    empProvider.roleValues[index]["id"]
                                                                    ? colorsConst.primary
                                                                    : Colors.white,
                                                                radius: 5,
                                                                borderColor: empProvider.selectRole ==
                                                                    empProvider.roleValues[index]["id"]
                                                                    ? colorsConst.primary
                                                                    : colorsConst.litGrey,
                                                              ),
                                                              child: Center(
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(3.0),
                                                                  child: CustomText(
                                                                      text:
                                                                      "  ${empProvider.roleValues[index]["role"]}  ",
                                                                      colors: empProvider.selectRole ==
                                                                          empProvider.roleValues[index]["id"]
                                                                          ? Colors.white
                                                                          : Colors.black
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  10.height,
                                                  SizedBox(
                                                    width:kIsWeb?webWidth/1.2:phoneWidth/1.2,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        CustomText(
                                                          text: "Status",
                                                          colors: colorsConst.greyClr,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width:kIsWeb?webWidth/1.2:phoneWidth/1.2,
                                                    child: Row(
                                                      children: [
                                                        InkWell(
                                                          onTap: (){
                                                            empProvider.selectStatus("1");
                                                          },
                                                          child: Container(
                                                            height: 30,
                                                            decoration: customDecoration.baseBackgroundDecoration(
                                                              color: empProvider.empStatus=="1"?colorsConst.primary:Colors.white,
                                                              borderColor: empProvider.empStatus=="1"?colorsConst.primary:colorsConst.litGrey,
                                                              radius: 5,
                                                            ),
                                                            child: Center(
                                                              child: CustomText(
                                                                text: "  Active  ",
                                                                colors: empProvider.empStatus=="1"?Colors.white:Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        10.width,
                                                        InkWell(
                                                          onTap: (){
                                                            empProvider.selectStatus("0");
                                                          },
                                                          child: Container(
                                                            height: 30,
                                                            decoration: customDecoration.baseBackgroundDecoration(
                                                              color: empProvider.empStatus=="0"?colorsConst.primary:Colors.white,
                                                              borderColor: empProvider.empStatus=="0"?colorsConst.primary:colorsConst.litGrey,
                                                              radius: 5,
                                                            ),
                                                            child: Center(
                                                              child: CustomText(
                                                                text: "  Inactive  ",
                                                                colors: empProvider.empStatus=="0"?Colors.white:Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  20.height,
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      CustomBtn(
                                                        width: 100,
                                                        text: 'Clear All',
                                                        callback: () {
                                                          empProvider.initFilterValue(true);
                                                          Navigator.of(context, rootNavigator: true).pop();
                                                        },
                                                        bgColor: Colors.grey.shade200,
                                                        textColor: Colors.black,
                                                      ),
                                                      CustomBtn(
                                                        width: 100,
                                                        text: 'Apply Filters',
                                                        callback: () {
                                                          empProvider.initFilterValue(false);
                                                          empProvider.filterList();
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
                                  color: empProvider.filter==true?colorsConst.primary:Colors.grey.shade300,radius: 5
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CustomText(text: "Active",colors: colorsConst.appDarkGreen),10.width,
                              CustomText(text: "${empProvider.active}",isBold: true),
                            ],
                          ),
                          Row(
                            children: [
                              CustomText(text: "Inactive",colors: colorsConst.greyClr),10.width,
                              CustomText(text: "${empProvider.inActive}",isBold: true,),
                            ],
                          ),
                        ],
                      ),10.height,
                      empProvider.filterUserData.isEmpty ?
                      Column(
                        children: [
                          100.height,
                          CustomText(text: "No Employees Found",
                              colors: colorsConst.greyClr)
                        ],
                      ) :
                      Expanded(
                        child: ListView.builder(
                            itemCount: empProvider.filterUserData.length,
                            itemBuilder: (context, index) {
                              final sortedData = empProvider.filterUserData;
                              final employeeData = sortedData[index];
                              var createdBy = "";
                              String timestamp = employeeData.createdTs.toString();
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
                              final showDateHeader = index == 0 || createdBy != utils.getCreatedDate(sortedData[index - 1]);
        
                              return
                                Column(
                                  children: [
                                    EmpData(
                                    showDateHeader: showDateHeader==true?true:false,
                                    employeeData: employeeData,
                                    dayOfWeek: dayOfWeek, focusScope: _myFocusScopeNode,),
                                    if(index==empProvider.filterUserData.length-1)
                                    70.height
                                  ],
                                );
                              // :0.width;
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ),
        ),
      );
    });
  }
}










