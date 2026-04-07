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
import '../../../source/utilities/utils.dart';
import '../../../view_model/customer_provider.dart';
import '../../common/dashboard.dart';
import '../../common/home_page.dart';

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
    tabController = TabController(
      length: localData.storage.read("role") == "1" ? 2 : 1,
      vsync: this,
      initialIndex: 0, // 🔥 Visits first
    );
    tabController.addListener(() {
      tabController.index;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<CustomerProvider>(context, listen: false).getCommentType();
      Provider.of<CustomerProvider>(context, listen: false).initVisitReport(widget.date1,widget.date2,widget.type);
      Provider.of<CustomerProvider>(context, listen: false).getVisitReport(context);
      Provider.of<CustomerProvider>(context, listen: false).getEmpWiseReport(context);
    });
    super.initState();
  }
  Widget filterChip(String text){
    return Container(
      padding: EdgeInsets.symmetric(horizontal:10,vertical:5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize:14),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(builder: (context,custProvider,_){
      Set<String> seenNames = {};
      var webWidth=MediaQuery.of(context).size.width * 0.5;
      var phoneWidth=MediaQuery.of(context).size.width * 0.95;
      //
      return WillPopScope(
        onWillPop: () async {

          utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));

          return false;
        },
        child: SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: PreferredSize(
            preferredSize: const Size(300, 70),
            child: CustomAppbar(text: constValue.visitRepo,isMain: true,),
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
                      child:TabBar(
                        controller: tabController,
                        indicator: BoxDecoration(
                          color: colorsConst.primary,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: colorsConst.primary,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: "Visits Summary"),
                          Tab(text: "Summary Details"),
                        ],
                      ),

                  ),
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
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
                                                                  custProvider.changeDailyVisitType(value,context);
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
                                                                custProvider.getEmpWiseReport(context);
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
                                                                custProvider.getEmpWiseReport(context);
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
                                          color: Colors.grey.shade300,radius: 5
                                        // color: custProvider.filter==true?colorsConst.primary:Colors.grey.shade300,radius: 5
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: SvgPicture.asset(assets.tFilter,width: 15,height: 15,color: colorsConst.primary,),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (custProvider.startDate == custProvider.endDate)
                                filterChip("Date: ${custProvider.startDate}")
                              else ...[
                                filterChip("Date: ${custProvider.startDate}-${custProvider.endDate}"),

                              ],
                              custProvider.refresh==false?
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 200, 0, 0),
                                child: Loading(),
                              ):
                              custProvider.refresh == false
                                  ? Padding(
                                padding: const EdgeInsets.fromLTRB(0, 200, 0, 0),
                                child: Loading(),
                              )
                                  : custProvider.groupedList.isEmpty
                                  ? const Padding(
                                padding: EdgeInsets.fromLTRB(0, 80, 0, 0),
                                child: Center(
                                  child: CustomText(
                                    text: "No Visit Report Found",
                                    size: 15,
                                  ),
                                ),
                              )
                                  : Expanded(
                                child: ListView.builder(
                                  itemCount: custProvider.groupedList.length,
                                  itemBuilder: (context, index) {

                                    var data = custProvider.groupedList[index];

                                    return Column(
                                      children: [
                                        if (index == 0) 10.height,

                                        InkWell(
                                          // onTap: () {
                                          //   tabController.animateTo(0);
                                          //   custProvider.manageFilter(true);
                                          //
                                          //   custProvider.selectUser(
                                          //     UserModel(
                                          //       id: data["role"],
                                          //       firstname: data["firstname"],
                                          //     ),
                                          //   );
                                          //
                                          //   custProvider.getVisitReport();
                                          // },
                                          onTap: () {

                                            /// 🔥 STEP 1: select user first
                                            custProvider.selectUser(
                                              UserModel(
                                                id: data["role"],
                                                firstname: data["firstname"],
                                              ),
                                            );

                                            /// 🔥 STEP 2: enable filter
                                            custProvider.manageFilter(true);

                                            /// 🔥 STEP 3: switch tab
                                            tabController.animateTo(1);

                                            /// 🔥 STEP 4: delay + API call
                                            Future.delayed(const Duration(milliseconds: 300), () {
                                              custProvider.getVisitReport(context);
                                            });
                                          },

                                          child: Container(
                                            width: MediaQuery.of(context).size.width * 0.9,
                                            margin: const EdgeInsets.symmetric(vertical: 5),
                                            decoration: customDecoration.baseBackgroundDecoration(
                                              color: Colors.white,
                                              borderColor: Colors.grey.shade200,
                                              radius: 5,
                                            ),

                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),

                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  /// 🔹 NAME + ROLE
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.60,
                                                        child: Row(
                                                          children: [
                                                            CustomText(
                                                              text: "${data["firstname"]} ",
                                                              isBold: true,
                                                              colors: colorsConst.orange,
                                                              size: 15,
                                                            ),
                                                            CustomText(
                                                              text: "( ${data["role"]} )",
                                                              colors: colorsConst.blue2,
                                                              size: 15,
                                                            ),

                                                          ],
                                                        ),


                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          CustomText(
                                                            text: "Total Visits: ",
                                                            colors: Colors.black,
                                                          ),
                                                          CustomText(
                                                            text: "${data["total"]}",
                                                            colors: colorsConst.primary,
                                                            isBold: true,
                                                          ),
                                                        ],
                                                      ),
                                                      //const Icon(Icons.arrow_forward_ios, size: 14),
                                                    ],
                                                  ),

                                                  const Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: DotLine(),
                                                  ),

                                                  /// 🔥 TOTAL


                                                  const SizedBox(height: 5),

                                                  /// 🔥 TYPES (Dynamic)
                                                  ...data["types"].entries.map<Widget>((entry) {
                                                    return Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          CustomText(
                                                            text: entry.key,
                                                            colors: colorsConst.greyClr,
                                                          ),
                                                          CustomText(
                                                            text: entry.value.toString(),
                                                            colors: colorsConst.primary,
                                                            isBold: true,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),

                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                              ),
                            ],
                          ),
                          Column(  //Employee visit
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: CustomTextField(
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
                                                                custProvider.changeDailyVisitType(value,context);
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
                                                      // Column(
                                                      //   crossAxisAlignment: CrossAxisAlignment.start,
                                                      //   children: [
                                                      //     CustomText(
                                                      //       text: "Employee Name",
                                                      //       colors: colorsConst.greyClr,
                                                      //       size: 12,
                                                      //     ),
                                                      //     EmployeeDropdown(
                                                      //       callback: (){
                                                      //         ePvr.getAllUsers();
                                                      //       },
                                                      //       isHint: false,
                                                      //       text:  custProvider.userName,
                                                      //       employeeList: ePvr.filterUserData,
                                                      //       onChanged: (UserModel? value) {
                                                      //         custProvider.selectUser(value!);
                                                      //       },
                                                      //       size:kIsWeb?webWidth/1.2:phoneWidth/1.2,
                                                      //     ),
                                                      //   ],
                                                      // ),
                                                      // 10.height,
                                                      // Column(
                                                      //   crossAxisAlignment: CrossAxisAlignment.start,
                                                      //   children: [
                                                      //     CustomText(
                                                      //       text: "Type",
                                                      //       colors: colorsConst.greyClr,
                                                      //       size: 12,
                                                      //     ),
                                                      //     MapDropDown(saveValue: custProvider.dailyType, hintText: "",
                                                      //         width: kIsWeb?webWidth/1.2:phoneWidth/1.2,
                                                      //         isHint: false,
                                                      //         onChanged: (value){
                                                      //           custProvider.changeSelect(value);
                                                      //         }, dropText: "value", list: custProvider.cmtTypeList),
                                                      //   ],
                                                      // ),
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
                                                              custProvider.getVisitReport(context);
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
                                                              custProvider.getVisitReport(context);
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
                                        color: custProvider.filter==true?Colors.grey.shade300:Colors.grey.shade300,radius: 5
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: SvgPicture.asset(assets.tFilter,width: 15,height: 15,color: colorsConst.primary,),
                                    ),
                                  ),
                                ),
                                CustomLoadingButton(callback: (){
                                  custProvider.getVisitHoursEmpReport(context);
                                }, isLoading: true, backgroundColor: colorsConst.primary,
                                  controller: custProvider.addCtr,
                                  radius: 5, width: 100,text: "Download",),

                              ],
                            ),
                            if (custProvider.filter) ...[
                              10.height,
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [

                                    if ((custProvider.startDate??"").isNotEmpty)
                                    filterChip("From: ${custProvider.startDate}"),

                                   if ((custProvider.endDate ?? "").isNotEmpty)
                                  filterChip("To: ${custProvider.endDate}"),

                                   if ((custProvider.userName ?? "").isNotEmpty)
                                    filterChip("Emp: ${custProvider.userName}"),
                                   //
                                   // if ((custProvider.typeValue ?? "").isNotEmpty)
                                   // filterChip("Type: ${custProvider.typeValue}"),

                                ],
                              ),
                              20.height,
                            ],
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
                                   // CustomerReportModel data1 = custProvider.customerReport[index];
                                   //  print("created${data1.createdBy}");
                                   //  print("created com ${data1.companyName}");
                                    print("created${data.createdBy}");
                                    print("created com ${data.companyName}");
                                    return VisitReportDetails(data: data);
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
