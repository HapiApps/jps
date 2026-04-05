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
  const ViewCustomer({super.key});

  @override
  State<ViewCustomer> createState() => _ViewCustomerState();
}

class _ViewCustomerState extends State<ViewCustomer>
    with TickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider =
      Provider.of<CustomerProvider>(context, listen: false);
      final locationProvider =
      Provider.of<LocationProvider>(context, listen: false);

      customerProvider.initFilterValue(true);

      if (kIsWeb) {
        customerProvider.getLeadCategory();
        customerProvider.getVisitType();
        customerProvider.getCmtType();
      } else {
        customerProvider.getLead();
        customerProvider.getVisit();
        customerProvider.getCommentType();
      }

      customerProvider.allTemplates();
      locationProvider.manageLocation(context, false);
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
    var webWidth = MediaQuery.of(context).size.width * 0.5;
    var phoneWidth = MediaQuery.of(context).size.width * 0.9;

    return Consumer3<CustomerProvider, HomeProvider, LocationProvider>(
        builder: (context, custProvider, homeProvider, locPvr, _) {
          return FocusScope(
            node: _myFocusScopeNode,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: colorsConst.bacColor,
                appBar: PreferredSize(
                  preferredSize: const Size(300, 55),
                  child: CustomAppbar(
                    text: constValue.customers,
                    callback: () {
                      homeProvider.updateIndex(0);
                      _myFocusScopeNode.unfocus();
                      utils.navigatePage(
                          context, () => const DashBoard(child: HomePage()));
                    },
                    isButton: true,
                    buttonCallback: () {
                      _myFocusScopeNode.unfocus();
                      utils.navigatePage(context,
                              () => const DashBoard(child: CreateCustomer()));
                    },
                  ),
                ),
                body: PopScope(
                  canPop: false,
                  onPopInvoked: (bool didPop) {
                    homeProvider.updateIndex(0);
                    _myFocusScopeNode.unfocus();
                    if (!didPop) {
                      utils.navigatePage(
                          context, () => const DashBoard(child: HomePage()));
                    }
                  },
                  child: custProvider.cusRefresh == false
                      ? const Loading()
                      : Center(
                    child: SizedBox(
                      width: kIsWeb ? webWidth : phoneWidth,
                      child: Column(
                        children: [
                          10.height,

                          /// SEARCH + FILTER ROW
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  text: "",
                                  radius: 30,
                                  controller: custProvider.search,
                                  hintText: "Search Name / Phone No",
                                  isIcon: true,
                                  iconData: Icons.search,
                                  textInputAction: TextInputAction.done,
                                  isShadow: true,
                                  onChanged: (value) {
                                    custProvider.searchCustomer(value.toString());
                                  },
                                  isSearch:
                                  custProvider.search.text.isNotEmpty,
                                  searchCall: () {
                                    custProvider.search.clear();
                                    custProvider.searchCustomer("");
                                  },
                                ),
                              ),
                              10.width,

                              /// FILTER BUTTON
                              InkWell(
                                onTap: () {
                                  _myFocusScopeNode.unfocus();
                                  _openFilterDialog(
                                      context, custProvider, webWidth, phoneWidth);
                                },
                                child: Container(
                                  height: 45,
                                  width: 50,
                                  decoration: customDecoration
                                      .baseBackgroundDecoration(
                                    color: custProvider.filter == true
                                        ? colorsConst.primary
                                        : Colors.white,
                                    radius: 12,
                                    borderColor: colorsConst.litGrey,
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      assets.tFilter,
                                      width: 18,
                                      height: 18,
                                      color: custProvider.filter == true
                                          ? Colors.white
                                          : colorsConst.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          12.height,

                          /// CUSTOMER COUNT
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text:
                                "Total Customers : ${custProvider.filterCustomerData.length}",
                                colors: Colors.black,
                                isBold: true,
                              ),
                              if (custProvider.filter == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: colorsConst.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: CustomText(
                                    text: "Filter Applied",
                                    colors: colorsConst.primary,
                                    size: 12,
                                    isBold: true,
                                  ),
                                )
                            ],
                          ),

                          12.height,

                          /// LIST
                          custProvider.filterCustomerData.isEmpty
                              ? Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_off, size: 80, color: Colors.grey),
                                20.height,
                                CustomText(
                                  text: constValue.noCustomer,
                                  colors: colorsConst.greyClr,
                                )
                              ],
                            ),
                          )
                              : Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount:
                              custProvider.filterCustomerData.length,
                              itemBuilder: (context, index) {
                                final sortedData =
                                    custProvider.filterCustomerData;
                                final data = sortedData[index];

                                String timestamp = data.createdTs.toString();
                                DateTime dateTime = DateTime.parse(timestamp);

                                String dayOfWeek =
                                DateFormat('EEEE').format(dateTime);

                                DateTime today = DateTime.now();
                                if (dateTime.day == today.day &&
                                    dateTime.month == today.month &&
                                    dateTime.year == today.year) {
                                  dayOfWeek = "Today";
                                } else if (dateTime.isAfter(
                                    today.subtract(const Duration(days: 1))) &&
                                    dateTime.isBefore(today)) {
                                  dayOfWeek = "Yesterday";
                                } else {
                                  dayOfWeek =
                                  "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                                }

                                final createdBy =
                                    "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                                final showDateHeader = index == 0 ||
                                    createdBy !=
                                        getCreatedDate(sortedData[index - 1]);

                                return Column(
                                  children: [
                                    /// DATE HEADER STYLE
                                    if (showDateHeader)
                                      Padding(
                                        padding:
                                        const EdgeInsets.symmetric(vertical: 10),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: colorsConst.litGrey),
                                            ),
                                            child: CustomText(
                                              text: dayOfWeek,
                                              colors: colorsConst.primary,
                                              size: 12,
                                              isBold: true,
                                            ),
                                          ),
                                        ),
                                      ),

                                    /// CUSTOMER CARD
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: CustomerData(
                                        dayOfWeek: dayOfWeek,
                                        showDateHeader: false,
                                        customerData: data,
                                        show: custProvider.isVisible == true &&
                                            custProvider.visibleIndex == index
                                            ? true
                                            : false,

                                        callback2: () {
                                          _myFocusScopeNode.unfocus();
                                          utils.navigatePage(
                                            context,
                                                () => DashBoard(
                                              child: CustomerDetails(
                                                id: data.userId.toString(),
                                              ),
                                            ),
                                          );
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

                                        callback: () async {
                                          _myFocusScopeNode.unfocus();
                                          if (data.isChecked.toString() == "2") {
                                            utils.showWarningToast(context,
                                                text: "Already attendance marked");
                                          } else {
                                            localData.storage.write(
                                                "cus_id", data.userId.toString());

                                            if (locPvr.latitude != "" &&
                                                locPvr.longitude != "") {
                                              custProvider.customerDailyAtt(
                                                context,
                                                data.isChecked.toString() == "null"
                                                    ? "1"
                                                    : "2",
                                                data.firstName.toString(),
                                                data.companyName.toString(),
                                                locPvr.latitude,
                                                locPvr.longitude,
                                              );
                                            } else {
                                              await locPvr.manageLocation(
                                                  context, true);
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
                                          utils.navigatePage(
                                            context,
                                                () => DashBoard(
                                              child: UpdateCustomer(
                                                  customerId:
                                                  data.userId.toString()),
                                            ),
                                          );
                                        },

                                        reportCallBack: () {
                                          _myFocusScopeNode.unfocus();
                                        },

                                        taskCallBack: () {
                                          _myFocusScopeNode.unfocus();

                                          var idList =
                                          data.customerId.toString().split('||');
                                          var usersList =
                                          data.firstName.toString().split('||');
                                          var phoneList = data.phoneNumber
                                              .toString()
                                              .split('||');

                                          var sendList = [];
                                          for (var i = 0; i < usersList.length; i++) {
                                            sendList.add({
                                              "id": idList[i],
                                              "name": usersList[i],
                                              "no": phoneList[i]
                                            });
                                          }

                                          utils.navigatePage(
                                            context,
                                                () => DashBoard(
                                              child: ViewTasks(
                                                coId: data.userId.toString(),
                                                numberList: sendList,
                                                companyName:
                                                data.companyName.toString(),
                                              ),
                                            ),
                                          );
                                        },

                                        shareCallback: () {
                                          custProvider.shareCustomerDetails(data);
                                        },

                                        visitsCallBack: () {
                                          _myFocusScopeNode.unfocus();

                                          var idList =
                                          data.customerId.toString().split('||');
                                          var usersList =
                                          data.firstName.toString().split('||');
                                          var phoneList = data.phoneNumber
                                              .toString()
                                              .split('||');

                                          var sendList = [];
                                          for (var i = 0; i < usersList.length; i++) {
                                            sendList.add({
                                              "id": idList[i],
                                              "name": usersList[i],
                                              "no": phoneList[i]
                                            });
                                          }

                                          utils.navigatePage(
                                            context,
                                                () => DashBoard(
                                              child: CusVisits(
                                                taskId: "0",
                                                companyId: data.userId.toString(),
                                                companyName:
                                                data.companyName.toString(),
                                                customerList: sendList,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    12.height,
                                  ],
                                );
                              },
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

  void _openFilterDialog(BuildContext context, CustomerProvider custProvider,
      double webWidth, double phoneWidth) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<CustomerProvider>(
          builder: (context, custProvider, _) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              contentPadding: const EdgeInsets.all(15),
              content: SizedBox(
                width: kIsWeb ? webWidth / 1.1 : phoneWidth / 1.1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          text: "Filters",
                          size: 16,
                          isBold: true,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: SvgPicture.asset(assets.cancel),
                        )
                      ],
                    ),
                    15.height,

                    /// DATE RANGE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: "From Date",
                                colors: colorsConst.greyClr,
                                size: 12,
                              ),
                              5.height,
                              InkWell(
                                onTap: () {
                                  custProvider.datePick(
                                    context: context,
                                    isStartDate: true,
                                    date: custProvider.startDate,
                                  );
                                },
                                child: Container(
                                  height: 35,
                                  decoration:
                                  customDecoration.baseBackgroundDecoration(
                                    color: Colors.white,
                                    radius: 10,
                                    borderColor: colorsConst.litGrey,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomText(text: custProvider.startDate),
                                      8.width,
                                      SvgPicture.asset(assets.calendar2),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        10.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: "To Date",
                                colors: colorsConst.greyClr,
                                size: 12,
                              ),
                              5.height,
                              InkWell(
                                onTap: () {
                                  custProvider.datePick(
                                    context: context,
                                    isStartDate: false,
                                    date: custProvider.endDate,
                                  );
                                },
                                child: Container(
                                  height: 35,
                                  decoration:
                                  customDecoration.baseBackgroundDecoration(
                                    color: Colors.white,
                                    radius: 10,
                                    borderColor: colorsConst.litGrey,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomText(text: custProvider.endDate),
                                      8.width,
                                      SvgPicture.asset(assets.calendar2),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    15.height,

                    /// SELECT RANGE
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "Select Date Range",
                          colors: colorsConst.greyClr,
                          size: 12,
                        ),
                        5.height,
                        Container(
                          height: 40,
                          decoration: customDecoration.baseBackgroundDecoration(
                            radius: 10,
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
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: CustomText(
                                    text: list.toString(),
                                    colors: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),

                    20.height,

                    /// BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomBtn(
                            text: "Clear",
                            callback: () {
                              custProvider.closeVisible();
                              custProvider.initFilterValue(true);
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            bgColor: Colors.grey.shade200,
                            textColor: Colors.black,
                          ),
                        ),
                        10.width,
                        Expanded(
                          child: CustomBtn(
                            text: "Apply",
                            callback: () {
                              custProvider.closeVisible();
                              custProvider.filterList();
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            bgColor: colorsConst.primary,
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String getCreatedDate(data) {
    final timestamp = data.createdTs.toString();
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}