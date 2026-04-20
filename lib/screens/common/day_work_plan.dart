import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/custom_appbar.dart';
import '../../component/custom_text.dart';
import '../../component/maxline_textfield.dart';
import '../../component/multi_dropdown.dart';
import '../../component/search_drop_down.dart';
import '../../model/customer/customer_model.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../view_model/customer_provider.dart';

class DayWorkPlanPage extends StatefulWidget {
  const DayWorkPlanPage({super.key});

  @override
  State<DayWorkPlanPage> createState() => _DayWorkPlanPageState();
}

class _DayWorkPlanPageState extends State<DayWorkPlanPage> {
  List<Map<String, dynamic>> sendList = [];

  /// 🔥 Each Plan Model
  List<WorkPlanModel> workPlans = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final custProvider = Provider.of<CustomerProvider>(context, listen: false);

      /// load company list
      await custProvider.getAllCustomers(true);

      /// first plan auto add
      setState(() {
        workPlans.add(WorkPlanModel());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var webWidth = MediaQuery.of(context).size.width * 0.5;
    var phoneWidth = MediaQuery.of(context).size.width * 0.9;

    return Consumer<CustomerProvider>(
      builder: (context, custProvider, child) {
        return Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: const PreferredSize(
            preferredSize: Size(300, 50),
            child: CustomAppbar(text: "Day Work Plan"),
          ),
          body: Center(
            child: SizedBox(
              width: kIsWeb ? webWidth : phoneWidth,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: workPlans.length,
                      itemBuilder: (context, index) {
                        final item = workPlans[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// 🔥 Title Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    text: "Plan ${index + 1}",
                                    isBold: true,
                                    size: 15,
                                  ),
                                  if (workPlans.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          workPlans.removeAt(index);
                                        });
                                      },
                                    ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              /// 🔥 Company Dropdown
                              CustomerDropdown(
                                text: item.companyName == ""
                                    ? constValue.companyName
                                    : item.companyName,
                                employeeList: custProvider.customer,
                                onChanged: (CustomerModel? value) {
                                  if (value == null) return;

                                  /// update company
                                  item.companyId = value.userId.toString();
                                  item.companyName = value.companyName.toString();

                                  /// clear old customer selection
                                  item.selectedCustomers = [];

                                  /// prepare customers list
                                  sendList = [];
                                  var idList = value.customerId.toString().split('||');
                                  var usersList = value.firstName.toString().split('||');
                                  var phoneList = value.phoneNumber.toString().split('||');

                                  for (var i = 0; i < usersList.length; i++) {
                                    sendList.add({
                                      "id": idList[i],
                                      "name": usersList[i],
                                      "no": phoneList[i],
                                    });
                                  }

                                  /// auto select if single customer
                                  if (sendList.length == 1) {
                                    item.selectedCustomers = [sendList[0]];
                                  }

                                  setState(() {});
                                },
                                size: kIsWeb ? webWidth : phoneWidth,
                              ),

                              const SizedBox(height: 10),

                              /// 🔥 Customer MultiSelect Dropdown
                              MultiSelectDropdown(
                                hintText: "Select Customer",
                                dropText: "name",
                                list: sendList,
                                width: kIsWeb ? webWidth : phoneWidth,

                                /// ✅ each plan separate selected list
                                selectedItems: item.selectedCustomers,

                                onChanged: (list) {
                                  setState(() {
                                    item.selectedCustomers = list;
                                  });
                                },
                              ),

                              const SizedBox(height: 10),

                              /// 🔥 Description
                              MaxLineTextField(
                                width: kIsWeb ? webWidth : phoneWidth,
                                text: "Description",
                                controller: item.descriptionController,
                                maxLine: 4,
                                isRequired: true,
                                textCapitalization: TextCapitalization.sentences,
                              ),

                              const SizedBox(height: 10),

                              /// 🔥 Yes / No Status
                              Row(
                                children: [
                                  const CustomText(
                                    text: "Status : ",
                                    isBold: true,
                                  ),
                                  const SizedBox(width: 10),

                                  ChoiceChip(
                                    label: const Text("Yes"),
                                    selected: item.status == "1",
                                    selectedColor: Colors.green,
                                    backgroundColor: Colors.grey.shade200,
                                    labelStyle: TextStyle(
                                      color: item.status == "1" ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    onSelected: (val) {
                                      setState(() {
                                        item.status = "1";
                                      });
                                    },
                                  ),

                                  ChoiceChip(
                                    label: const Text("No"),
                                    selected: item.status == "0",
                                    selectedColor: Colors.red,
                                    backgroundColor: Colors.grey.shade200,
                                    labelStyle: TextStyle(
                                      color: item.status == "0" ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    onSelected: (val) {
                                      setState(() {
                                        item.status = "0";
                                      });
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 🔥 Add Button
                  SizedBox(
                    width: kIsWeb ? webWidth : phoneWidth,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorsConst.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text("Add New Plan"),
                      onPressed: () {
                        setState(() {
                          workPlans.add(WorkPlanModel());
                        });
                      },
                    ),
                  ),


                  const SizedBox(height: 10),

                  SizedBox(
                    width: kIsWeb ? webWidth : phoneWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        /// ❌ CANCEL BUTTON
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: colorsConst.primary),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: colorsConst.primary),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// ✅ SAVE BUTTON
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorsConst.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              for (var plan in workPlans) {
                                debugPrint("Company: ${plan.companyName}");
                                debugPrint("Customers: ${plan.selectedCustomers}");
                                debugPrint("Desc: ${plan.descriptionController.text}");
                                debugPrint("Status: ${plan.status}");
                              }

                              // API call here
                            },
                            child: const Text("Save"),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🔥 MODEL CLASS
class WorkPlanModel {
  String companyId = "";
  String companyName = "";

  List<Map<String, dynamic>> selectedCustomers = [];

  TextEditingController descriptionController = TextEditingController();

  String status = "0";
}