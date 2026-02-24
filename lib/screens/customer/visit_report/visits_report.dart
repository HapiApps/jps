import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/screens/customer/visit_report/visit_report_details.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:provider/provider.dart';
import '../../../component/animated_button.dart';
import '../../../component/custom_appbar.dart';
import '../../../component/custom_dropdown.dart';
import '../../../component/custom_loading.dart';
import '../../../component/custom_radio_button.dart';
import '../../../component/custom_text.dart';
import '../../../component/custom_textfield.dart';
import '../../../component/dotted_border.dart';
import '../../../component/map_dropdown.dart';
import '../../../model/customer/customer_report_model.dart';
import '../../../model/user_model.dart';
import '../../../source/constant/assets_constant.dart';
import '../../../source/constant/colors_constant.dart';
import '../../../source/constant/default_constant.dart';
import '../../../source/constant/local_data.dart';
import '../../../source/styles/decoration.dart';
import '../../../view_model/customer_provider.dart';

class VisitReport extends StatefulWidget {
  final String date1;
  final String date2;
  final String month;
  final String type;
  const VisitReport({super.key, required this.date1, required this.date2, required this.month, required this.type});

  @override
  State<VisitReport> createState() => _VisitReportState();
}

class _VisitReportState extends State<VisitReport> with SingleTickerProviderStateMixin{
  late TabController tabController;

  @override
  void initState() {
    tabController=TabController(length:localData.storage.read("role")=="1"?2:1, vsync: this);
    tabController.addListener(() {
      tabController.index;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<CustomerProvider>(context, listen: false).getCommentType();
      Provider.of<CustomerProvider>(context, listen: false).initVisitReport(widget.date1,widget.date2,widget.type);
      Provider.of<CustomerProvider>(context, listen: false).getVisitReport();
      Provider.of<CustomerProvider>(context, listen: false).getEmpWiseReport();
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(builder: (context,custProvider,_){
      Set<String> seenNames = {};
      var webWidth=MediaQuery.of(context).size.width * 0.5;
      var phoneWidth=MediaQuery.of(context).size.width * 0.95;
      return SafeArea(
      child: Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: PreferredSize(
          preferredSize: const Size(300, 70),
          child: CustomAppbar(text: constValue.visitRepo),
        ),
        body:Center(
          child: SizedBox(
            width: kIsWeb?webWidth:phoneWidth,
            child: Column(
              children: [
                if(localData.storage.read("role")=="1")
                Container(
                    height: 40,
                    decoration: customDecoration.baseBackgroundDecoration(
                        color: Colors.transparent,
                        radius: 5
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorWeight: 0,
                      indicator: customDecoration.baseBackgroundDecoration(
                          color: Colors.white,
                          borderColor: colorsConst.primary,
                          radius: 5
                      ),
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.green,
                      controller: tabController,
                      tabs:  const [
                        Tab(child:CustomText(text: "Reports")),
                        Tab(child:CustomText(text: "Visits")),
                      ],
                    )
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomTextField(
                                text: "",radius: 30,
                                controller: custProvider.search,
                                width: kIsWeb?webWidth/1.2:phoneWidth/1.2,
                                hintText: "${constValue.companyName}/${constValue.customer}/Emp/No",
                                isIcon: true,
                                iconData: Icons.search,
                                textInputAction: TextInputAction.done,
                                isShadow: true,
                                onChanged: (value) {
                                  custProvider.searchVisitReport(value.toString());
                                },
                              ),
                              InkWell(
                                onTap: (){
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Consumer2<CustomerProvider,EmployeeProvider>(
                                        builder: (context, empProvider, ePvr,_) {
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
                                                                width:kIsWeb?webWidth/2.8:phoneWidth/2.8,
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
                                                                width:kIsWeb?webWidth/2.8:phoneWidth/2.8,
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
                                                            value: custProvider.repType,
                                                            onChanged: (value) {
                                                              custProvider.changeDailyVisitType(value);
                                                            },
                                                            items: custProvider.typeList.map((list) {
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
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText(
                                                          text: "Employee Name",
                                                          colors: colorsConst.greyClr,
                                                          size: 12,
                                                        ),
                                                        EmployeeDropdown(
                                                          callback: (){
                                                            ePvr.getAllUsers();
                                                          },
                                                          isHint: false,
                                                          text:  custProvider.userName,
                                                          employeeList: ePvr.filterUserData,
                                                          onChanged: (UserModel? value) {
                                                            custProvider.selectUser(value!);
                                                          },
                                                          size:kIsWeb?webWidth/1.2:phoneWidth/1.2,
                                                        ),
                                                      ],
                                                    ),
                                                    10.height,
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText(
                                                          text: "Type",
                                                          colors: colorsConst.greyClr,
                                                          size: 12,
                                                        ),
                                                        MapDropDown(saveValue: custProvider.dailyType, hintText: "",
                                                            width: kIsWeb?webWidth/1.2:phoneWidth/1.2,
                                                            isHint: false,
                                                            onChanged: (value){
                                                              custProvider.changeSelect(value);
                                                            }, dropText: "value", list: custProvider.cmtTypeList),
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
                                                            custProvider.initVisitReport(custProvider.startDate,custProvider.endDate,custProvider.reportType);
                                                            custProvider.manageFilter(false);
                                                            custProvider.getVisitReport();
                                                            Navigator.of(context, rootNavigator: true).pop();
                                                          },
                                                          bgColor: Colors.grey.shade200,
                                                          textColor: Colors.black,
                                                        ),
                                                        CustomBtn(
                                                          width: 100,
                                                          text: 'Apply Filters',
                                                          callback: () {
                                                            custProvider.manageFilter(true);
                                                            custProvider.getVisitReport();
                                                            // custProvider.closeVisible();
                                                            // custProvider.filterList();
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
                          custProvider.refresh==false?
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 200, 0, 0),
                            child: Loading(),
                          ):
                          custProvider.dailyVisitReport.isEmpty?
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 80, 0, 0),
                            child: Center(child: CustomText(text: "No Visit Report Found",size: 15,)),
                          ):Expanded(
                            child: ListView.builder(
                                itemCount: custProvider.dailyVisitReport.length,
                                itemBuilder: (context,index){
                                  CustomerReportModel data = custProvider.dailyVisitReport[index];
                                  return VisitReportDetails(data: data);
                                }),
                          ),
                        ],
                      ),
                      if(localData.storage.read("role")=="1")
                      Column(
                        children: [
                          10.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomLoadingButton(callback: (){
                                custProvider.getVisitHoursReport(context);
                              }, isLoading: true, backgroundColor: colorsConst.primary,
                                controller: custProvider.addCtr,
                                radius: 5, width: 100,text: "Download",),
                              // ElevatedButton(
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor: colorsConst.primary
                              //   ),
                              //     onPressed: (){
                              //   custProvider.downloadExcelReport(custProvider.empWiseCount);
                              // }, child: CustomText(text: "Download",colors: Colors.white,)),
                              10.width,
                              InkWell(
                                onTap: (){
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Consumer2<CustomerProvider,EmployeeProvider>(
                                        builder: (context, empProvider, ePvr,_) {
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
                                                                width:kIsWeb?webWidth/2.8:phoneWidth/2.8,
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
                                                                width:kIsWeb?webWidth/2.8:phoneWidth/2.8,
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
                                                            value: custProvider.repType,
                                                            onChanged: (value) {
                                                              custProvider.changeDailyVisitType(value);
                                                            },
                                                            items: custProvider.typeList.map((list) {
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
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        CustomBtn(
                                                          width: 100,
                                                          text: 'Clear All',
                                                          callback: () {
                                                            custProvider.initVisitReport(custProvider.startDate,custProvider.endDate,custProvider.reportType);
                                                            custProvider.manageFilter(false);
                                                            custProvider.getEmpWiseReport();
                                                            Navigator.of(context, rootNavigator: true).pop();
                                                          },
                                                          bgColor: Colors.grey.shade200,
                                                          textColor: Colors.black,
                                                        ),
                                                        CustomBtn(
                                                          width: 100,
                                                          text: 'Apply Filters',
                                                          callback: () {
                                                            custProvider.manageFilter(true);
                                                            custProvider.getEmpWiseReport();
                                                            // custProvider.closeVisible();
                                                            // custProvider.filterList();
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
                          custProvider.refresh==false?
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 200, 0, 0),
                            child: Loading(),
                          ):
                          custProvider.empWiseCount.isEmpty?
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 80, 0, 0),
                            child: Center(child: CustomText(text: "No Visit Report Found",size: 15,)),
                          ):Expanded(
                            child: ListView.builder(
                                itemCount: custProvider.empWiseCount.length,
                                itemBuilder: (context, index) {
                                  var data = custProvider.empWiseCount[index];
                                  String name = data["firstname"];
                                  bool isNameRepeated = seenNames.contains(name);
                                  print(seenNames);
                                  if (isNameRepeated==false) {
                                    // print("isNameRepeated ${isNameRepeated}");
                                    seenNames.add(name);  // Mark the name as seen
                                  }
                                  print(custProvider.empWiseCount);
                                  // var valueList=data["value_list"].toString().split('||');
                                  // var totalCounts=data["total_counts"].toString().split('||');
                                  return Column(
                                    children: [
                                      if(index == 0)
                                        10.height,
                                      InkWell(
                                        onTap: () {
                                          tabController.animateTo(0);
                                          custProvider.manageFilter(true);
                                          custProvider.selectUser(UserModel(id: data["role"],firstname: data["firstname"]));
                                          custProvider.getVisitReport();
                                        },
                                        child: Container(
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width * 0.9,
                                            decoration: customDecoration
                                                .baseBackgroundDecoration(
                                                color: Colors.white,
                                                borderColor: Colors.grey.shade200,
                                                radius: 5
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // if (!isNameRepeated)
                                                    Row(
                                                      mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                          // color:Colors.pink,
                                                            width: MediaQuery
                                                                .of(context)
                                                                .size
                                                                .width * 0.8,
                                                            child: Row(
                                                              children: [
                                                                CustomText(
                                                                  text: "${data["firstname"]} ",
                                                                  isBold: true,
                                                                  colors: colorsConst.orange,size: 15,),CustomText(
                                                                    text: "( ${data["role"]} )",
                                                                    colors: colorsConst.blue2,size: 15),
                                                              ],
                                                            )),
                                                        SizedBox(
                                                            width: MediaQuery.of(context).size.width * 0.05,
                                                            child: Icon(Icons.arrow_back_ios,color: colorsConst.blue2,size: 15,)),
                                                      ],
                                                    ),
                                                  // if (!isNameRepeated)
                                                    const Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: DotLine(),
                                                    ),
                                                  Row(
                                                    mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.8,
                                                        child: CustomText(
                                                          text: "${data["value"]}",
                                                          colors: colorsConst.greyClr,),
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.05,
                                                        child: CustomText(
                                                          text: "${data["total_count"]}",
                                                          colors: colorsConst.primary,isBold: true,),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    });
  }
  String formatCreatedTs(String createdTs) {
    try {
      createdTs = createdTs.trim();
      DateTime dateTime;
      if (createdTs.contains(".")) {
        dateTime = DateFormat("yyyy-MM-dd HH:mm:ss.SSS").parseStrict(createdTs);
      } else {
        dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(createdTs);
      }
      String formattedDate = DateFormat("dd-M-yyyy, hh:mm a").format(dateTime);
      return formattedDate;
    } catch (e) {
      return "Invalid Date";
    }
  }}
