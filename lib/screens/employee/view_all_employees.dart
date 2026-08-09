import 'package:master_code/screens/employee/create_employee.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/source/constant/assets_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_code/view_model/home_provider.dart';
import '../../component/animated_button.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../component/map_dropdown.dart';
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

class _ViewEmployeesState extends State<ViewEmployees>
    with SingleTickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider =
      Provider.of<LocationProvider>(context, listen: false);
      final employeeProvider =
      Provider.of<EmployeeProvider>(context, listen: false);
      Provider.of<EmployeeProvider>(context, listen: false).getAllUsers();
      locationProvider.manageLocation(context, false);
      employeeProvider.initFilterValue(true);
      employeeProvider.getGrades(true);

      if (!kIsWeb) {
        employeeProvider.getAllRoles();
      } else {
        employeeProvider.getRoles();
      }

      if (locationProvider.latitude.isNotEmpty &&
          locationProvider.longitude.isNotEmpty) {
        final lat = double.tryParse(locationProvider.latitude);
        final lng = double.tryParse(locationProvider.longitude);
        if (lat != null && lng != null) {
          employeeProvider.getAdd(lat, lng);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _myFocusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var webWidth = MediaQuery.of(context).size.width * 0.5;
    var phoneWidth = MediaQuery.of(context).size.width * 0.9;

    if (_tabController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer2<EmployeeProvider, HomeProvider>(
        builder: (context, empProvider, homeProvider, _) {

          final activeList = empProvider.filterUserData
              .where((e) => e.active.toString() == "1")
              .toList()
            ..sort((a, b) => (a.firstname ?? "")
                .toLowerCase()
                .compareTo((b.firstname ?? "").toLowerCase()));

          final inactiveList = empProvider.filterUserData
              .where((e) => e.active.toString() == "2")
              .toList()
            ..sort((a, b) => (a.firstname ?? "")
                .toLowerCase()
                .compareTo((b.firstname ?? "").toLowerCase()));

          return FocusScope(
            node: _myFocusScopeNode,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: colorsConst.bacColor,
                appBar: PreferredSize(
                  preferredSize: const Size(300, 55),
                  child: CustomAppbar(
                    text: constValue.employee,
                    callback: () {
                      homeProvider.updateIndex(0);
                      _myFocusScopeNode.unfocus();
                      utils.navigatePage(
                          context, () => const DashBoard(child: HomePage()));
                    },
                    isButton: true,
                    buttonCallback: () {
                      _myFocusScopeNode.unfocus();
                      utils.navigatePage(
                          context, () => const DashBoard(child: CreateEmployee()));
                    },
                  ),
                ),
                body: PopScope(
                  canPop: false,
                  onPopInvoked: (bool didPop) {
                    _myFocusScopeNode.unfocus();
                    homeProvider.updateIndex(0);
                    if (!didPop) {
                      utils.navigatePage(
                          context, () => const DashBoard(child: HomePage()));
                    }
                  },
                  child: Center(
                    child: SizedBox(
                      width: kIsWeb ? webWidth : phoneWidth,
                      child: empProvider.empRefresh == false
                          ? const Loading()
                          : Column(
                        children: [
                          20.height,
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: colorsConst.primary,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    children: [

                                      /// Search Field
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: TextField(
                                            controller: empProvider.search,
                                            decoration: const InputDecoration(
                                              hintText: "Search Name or No",
                                              prefixIcon: Icon(
                                                Icons.search,
                                                color: Colors.grey,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding:
                                              EdgeInsets.symmetric(vertical: 15),
                                            ),
                                            onChanged: (value) {
                                              empProvider.searchUser(value);
                                            },
                                          ),
                                        ),
                                      ),

                                      /// Filter Button
                                      InkWell(
                                        onTap: () {
                                          _myFocusScopeNode.unfocus();

                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Consumer<EmployeeProvider>(
                                                builder: (context, empProvider, _) {
                                                  return AlertDialog(
                                                    actions: [
                                                      SizedBox(
                                                        width: kIsWeb
                                                            ? webWidth / 1.2
                                                            : phoneWidth / 1.2,
                                                        child: Column(
                                                          children: [
                                                            20.height,
                                                            Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                              children: [
                                                                70.width,
                                                                const CustomText(
                                                                  text: 'Filters',
                                                                  colors:
                                                                  Colors.black,
                                                                  size: 16,
                                                                  isBold: true,
                                                                ),
                                                                30.width,
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                        true)
                                                                        .pop();
                                                                  },
                                                                  child: SvgPicture
                                                                      .asset(assets
                                                                      .cancel),
                                                                )
                                                              ],
                                                            ),
                                                            20.height,

                                                            /// DATE RANGE
                                                            Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                              children: [
                                                                Column(
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                                  children: [
                                                                    CustomText(
                                                                      text:
                                                                      "From Date",
                                                                      colors:
                                                                      colorsConst
                                                                          .greyClr,
                                                                      size: 12,
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () {
                                                                        empProvider
                                                                            .datePick(
                                                                          context:
                                                                          context,
                                                                          isStartDate:
                                                                          true,
                                                                          date: empProvider
                                                                              .startDate,
                                                                        );
                                                                      },
                                                                      child:
                                                                      Container(
                                                                        height: 30,
                                                                        width: kIsWeb
                                                                            ? webWidth /
                                                                            2.5
                                                                            : phoneWidth /
                                                                            2.5,
                                                                        decoration:
                                                                        customDecoration
                                                                            .baseBackgroundDecoration(
                                                                          color: Colors
                                                                              .white,
                                                                          radius: 5,
                                                                          borderColor:
                                                                          colorsConst
                                                                              .litGrey,
                                                                        ),
                                                                        child: Row(
                                                                          mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                          children: [
                                                                            CustomText(
                                                                                text:
                                                                                empProvider.startDate),
                                                                            5.width,
                                                                            SvgPicture
                                                                                .asset(
                                                                              assets
                                                                                  .calendar2,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                                  children: [
                                                                    CustomText(
                                                                      text: "To Date",
                                                                      colors:
                                                                      colorsConst
                                                                          .greyClr,
                                                                      size: 12,
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () {
                                                                        empProvider
                                                                            .datePick(
                                                                          context:
                                                                          context,
                                                                          isStartDate:
                                                                          false,
                                                                          date: empProvider
                                                                              .endDate,
                                                                        );
                                                                      },
                                                                      child:
                                                                      Container(
                                                                        height: 30,
                                                                        width: kIsWeb
                                                                            ? webWidth /
                                                                            2.5
                                                                            : phoneWidth /
                                                                            2.5,
                                                                        decoration:
                                                                        customDecoration
                                                                            .baseBackgroundDecoration(
                                                                          color: Colors
                                                                              .white,
                                                                          radius: 5,
                                                                          borderColor:
                                                                          colorsConst
                                                                              .litGrey,
                                                                        ),
                                                                        child: Row(
                                                                          mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                          children: [
                                                                            CustomText(
                                                                                text:
                                                                                empProvider.endDate),
                                                                            5.width,
                                                                            SvgPicture
                                                                                .asset(
                                                                              assets
                                                                                  .calendar2,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ],
                                                            ),

                                                            10.height,

                                                            /// SELECT DATE RANGE DROPDOWN
                                                            Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                CustomText(
                                                                  text:
                                                                  "Select Date Range",
                                                                  colors: colorsConst
                                                                      .greyClr,
                                                                  size: 12,
                                                                ),
                                                                Container(
                                                                  height: 30,
                                                                  width: kIsWeb
                                                                      ? webWidth /
                                                                      1.2
                                                                      : phoneWidth /
                                                                      1.2,
                                                                  decoration:
                                                                  customDecoration
                                                                      .baseBackgroundDecoration(
                                                                    radius: 5,
                                                                    color:
                                                                    Colors.white,
                                                                    borderColor:
                                                                    colorsConst
                                                                        .litGrey,
                                                                  ),
                                                                  child:
                                                                  DropdownButton(
                                                                    iconEnabledColor:
                                                                    colorsConst
                                                                        .greyClr,
                                                                    isExpanded: true,
                                                                    underline:
                                                                    const SizedBox(),
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .keyboard_arrow_down_outlined),
                                                                    value:
                                                                    empProvider
                                                                        .type,
                                                                    onChanged:
                                                                        (value) {
                                                                      empProvider
                                                                          .changeType(
                                                                          value);
                                                                    },
                                                                    items: empProvider
                                                                        .typeList
                                                                        .map((list) {
                                                                      return DropdownMenuItem(
                                                                        value: list,
                                                                        child:
                                                                        CustomText(
                                                                          text:
                                                                          "  $list",
                                                                          colors: Colors
                                                                              .black,
                                                                          isBold:
                                                                          false,
                                                                        ),
                                                                      );
                                                                    }).toList(),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                            10.height,

                                                            MapDropDown(
                                                              isRefresh: empProvider.roleValues.isEmpty?true:false,
                                                              callback: (){
                                                                empProvider.refreshRoles();
                                                              },
                                                              isHint: true,
                                                              width: kIsWeb
                                                                  ? webWidth /
                                                                  1.2
                                                                  : phoneWidth /
                                                                  1.2,
                                                              isRequired: true,
                                                              hintText: "Role",
                                                              list: empProvider.roleValues,
                                                              saveValue: empProvider.role,
                                                              onChanged: (Object? value) {
                                                                empProvider.changeRole(value);
                                                              },
                                                              dropText: 'role',),
                                                            10.height,


                                                            /// CLEAR & APPLY BUTTONS
                                                            Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                              children: [
                                                                CustomBtn(
                                                                  width: 100,
                                                                  text: 'Clear All',
                                                                  callback: () {
                                                                    empProvider
                                                                        .initFilterValue(
                                                                        true);
                                                                    empProvider.clearRole();
                                                                    Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                        true)
                                                                        .pop();
                                                                  },
                                                                  bgColor: Colors
                                                                      .grey.shade200,
                                                                  textColor:
                                                                  Colors.black,
                                                                ),
                                                                CustomBtn(
                                                                  width: 100,
                                                                  text:
                                                                  'Apply Filters',
                                                                  callback: () {
                                                                    empProvider
                                                                        .initFilterValue(
                                                                        false);
                                                                    empProvider
                                                                        .filterList();
                                                                    Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                        true)
                                                                        .pop();
                                                                  },
                                                                  bgColor:
                                                                  colorsConst
                                                                      .primary,
                                                                  textColor:
                                                                  Colors.white,
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
                                          width: 60,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.tune,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),



                          10.height,

                          /// TAB BAR
                          Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                color: colorsConst.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.black,
                              tabs: [
                                Tab(text: "Active (${activeList.length})"),
                                Tab(text: "Inactive (${inactiveList.length})"),
                              ],
                            ),
                          ),

                          10.height,

                          /// TAB VIEW
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                /// ---------------- ACTIVE TAB ----------------
                                activeList.isEmpty
                                    ? Center(
                                  child: CustomText(
                                    text: "No Active Employees Found",
                                    colors: colorsConst.greyClr,
                                  ),
                                )
                                    : ListView.builder(
                                  itemCount: activeList.length,
                                  itemBuilder: (context, index) {
                                    final employeeData = activeList[index];

                                    return Column(
                                      children: [
                                        EmpData(
                                          showDateHeader: false, // ✅ no date header
                                          employeeData: employeeData,
                                          dayOfWeek: "", // ✅ not needed
                                          focusScope: _myFocusScopeNode,
                                        ),
                                        if (index == activeList.length - 1) 70.height,
                                      ],
                                    );
                                  },
                                ),

                                /// ---------------- INACTIVE TAB ----------------
                                inactiveList.isEmpty
                                    ? Center(
                                  child: CustomText(
                                    text: "No Inactive Employees Found",
                                    colors: colorsConst.greyClr,
                                  ),
                                )
                                    : ListView.builder(
                                  itemCount: inactiveList.length,
                                  itemBuilder: (context, index) {
                                    final employeeData = inactiveList[index];

                                    return Column(
                                      children: [
                                        EmpData(
                                          showDateHeader: false, // ✅ no date header
                                          employeeData: employeeData,
                                          dayOfWeek: "", // ✅ not needed
                                          focusScope: _myFocusScopeNode,
                                        ),
                                        if (index == inactiveList.length - 1) 70.height,
                                      ],
                                    );
                                  },
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
            ),
          );
        });
  }
}