import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/custom_loading_button.dart';
import '../../component/maxline_textfield.dart';
import '../../component/multi_dropdown.dart';
import '../../component/search_drop_down.dart';
import '../../model/customer/customer_model.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/customer_provider.dart';
import '../../view_model/leave_provider.dart';

class DayWorkPlanPage extends StatefulWidget {
  const DayWorkPlanPage({super.key});

  @override
  State<DayWorkPlanPage> createState() => _DayWorkPlanPageState();
}

class _DayWorkPlanPageState extends State<DayWorkPlanPage> {
  List<WorkPlanModel> workPlans = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final custProvider =
      Provider.of<CustomerProvider>(context, listen: false);
      await custProvider.getAllCustomers(true);

      setState(() {
        workPlans.add(WorkPlanModel());
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var item in workPlans) {
      item.descriptionController.dispose();
    }
    super.dispose();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void addNewPlan() {
    if (workPlans.isNotEmpty) {
      if (workPlans.last.descriptionController.text.trim().isEmpty) {
        utils.showWarningToast(context, text: "Please enter description");
        return;
      }
    }

    setState(() {
      workPlans.add(WorkPlanModel());
    });

    scrollToBottom();
  }

  bool validateAllPlans() {
    for (int i = 0; i < workPlans.length; i++) {
      final item = workPlans[i];

      if (item.descriptionController.text.trim().isEmpty) {
        utils.showWarningToast(
          context,
          text: "Please enter description in Plan ${i + 1}",
        );

        /// 🔥 Reset Loading Button
        Provider.of<LeaveProvider>(context, listen: false).addWorkCtr.reset();

        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var webWidth = MediaQuery.of(context).size.width * 0.5;
    var phoneWidth = MediaQuery.of(context).size.width * 0.9;

    double mainWidth = kIsWeb ? webWidth : phoneWidth;

    return Consumer<CustomerProvider>(
      builder: (context, custProvider, child) {
        return Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: AppBar(
            backgroundColor: colorsConst.bacColor,
            title: Text(
              "Day Work Plan",
              style: TextStyle(
                color: colorsConst.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: colorsConst.primary),
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: colorsConst.primary, size: 20),
                onPressed: addNewPlan,
              ),
            ],
          ),
          body: Center(
            child: SizedBox(
              width: mainWidth,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: workPlans.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final item = workPlans[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 5, top: 5),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// PLAN + DELETE + STATUS
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Plan ${index + 1}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 6),

                                      /// DELETE BUTTON
                                      if (workPlans.length > 1)
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              workPlans.removeAt(index);
                                            });
                                          },
                                          child: const Icon(
                                            Icons.delete,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                        ),
                                    ],
                                  ),

                                  /// STATUS
                                  Row(
                                    children: [
                                      const Text(
                                        "Achieved:  ",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ChoiceChip(
                                        label: const Text("Yes"),
                                        selected: item.status == "1",
                                        selectedColor: Colors.green,
                                        backgroundColor: Colors.grey.shade200,
                                        labelStyle: TextStyle(
                                          fontSize: 10,
                                          color: item.status == "1"
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: const VisualDensity(
                                            horizontal: -4, vertical: -4),
                                        onSelected: (val) {
                                          setState(() {
                                            item.status = "1";
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      ChoiceChip(
                                        label: const Text("No"),
                                        selected: item.status == "0",
                                        selectedColor: Colors.red,
                                        backgroundColor: Colors.grey.shade200,
                                        labelStyle: TextStyle(
                                          fontSize: 10,
                                          color: item.status == "0"
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: const VisualDensity(
                                            horizontal: -4, vertical: -4),
                                        onSelected: (val) {
                                          setState(() {
                                            item.status = "0";
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              /// COMPANY DROPDOWN
                              CustomerDropdown(
                                text: item.companyName.isEmpty
                                    ? constValue.companyName
                                    : item.companyName,
                                employeeList: custProvider.customer,
                                onChanged: (CustomerModel? value) {
                                  if (value == null) return;

                                  item.companyId = value.userId.toString();
                                  item.companyName =
                                      value.companyName.toString();

                                  item.selectedCustomers = [];
                                  item.sendList = [];

                                  var idList =
                                  value.customerId.toString().split('||');
                                  var usersList =
                                  value.firstName.toString().split('||');
                                  var phoneList = value.phoneNumber
                                      .toString()
                                      .split('||');

                                  for (var i = 0; i < usersList.length; i++) {
                                    item.sendList.add({
                                      "id": idList[i],
                                      "name": usersList[i],
                                      "no": phoneList[i],
                                    });
                                  }

                                  if (item.sendList.length == 1) {
                                    item.selectedCustomers = [
                                      item.sendList[0]
                                    ];
                                  }

                                  setState(() {});
                                },
                                size: mainWidth,
                              ),

                              const SizedBox(height: 8),

                              /// CUSTOMER DROPDOWN ONLY IF COMPANY SELECTED
                              if (item.companyId.isNotEmpty)
                                MultiSelectDropdown(
                                  hintText: "Customer",
                                  dropText: "name",
                                  list: item.sendList,
                                  width: mainWidth,
                                  selectedItems: item.selectedCustomers,
                                  onChanged: (list) {
                                    setState(() {
                                      item.selectedCustomers = list;
                                    });
                                  },
                                ),

                              const SizedBox(height: 8),

                              /// DESCRIPTION
                              MaxLineTextField(
                                width: mainWidth,
                                text: "Description",
                                controller: item.descriptionController,
                                maxLine: 2,
                                isRequired: true,
                                textCapitalization:
                                TextCapitalization.sentences,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// SAVE + CANCEL BUTTONS
                  SizedBox(
                    width: mainWidth,
                    child: Row(
                      children: [
                        /// CANCEL
                        CustomLoadingButton(
                            callback: (){
                              Future.microtask(() => Navigator.pop(context));
                            }, isLoading: false,text: "Cancel",
                            backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                            width: kIsWeb?webWidth/2.1:phoneWidth/2.1),

                        const SizedBox(width: 6),

                        /// SAVE
                        Consumer<LeaveProvider>(
                          builder: (context, provider, child) {
                            return CustomLoadingButton(
                              callback: () {
                                if (!validateAllPlans()) return;
                                provider.workPlanSubmit(context, workPlans);
                              },
                              text: "Save",
                              controller: provider.addWorkCtr, // if exists
                              isLoading: true,
                              backgroundColor: colorsConst.primary,
                              radius: 10,
                              width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 70),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// MODEL
class WorkPlanModel {
  String companyId = "";
  String companyName = "";

  List<Map<String, dynamic>> sendList = [];
  List<Map<String, dynamic>> selectedCustomers = [];

  TextEditingController descriptionController = TextEditingController();

  String status = "0";
}