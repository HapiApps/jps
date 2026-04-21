import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  List<WorkPlanModel> workPlans = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final custProvider = Provider.of<CustomerProvider>(context, listen: false);
      await custProvider.getAllCustomers(true);

      setState(() {
        workPlans.add(WorkPlanModel());
      });
    });
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
                onPressed: () {
                  setState(() {
                    workPlans.add(WorkPlanModel());
                  });
                },
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
                      itemCount: workPlans.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final item = workPlans[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 5,top: 5),
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

                              /// 🔥 PLAN + DELETE + STATUS
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
                                      Text("Achieved:  ",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
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



                              /// 🔥 COMPANY + CUSTOMER SAME LINE
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start, // ✅ FIX
                                children: [
                                  Expanded(
                                    child: CustomerDropdown(
                                      text: item.companyName.isEmpty
                                          ? constValue.companyName
                                          : item.companyName,
                                      employeeList: custProvider.customer,
                                      onChanged: (CustomerModel? value) {
                                        if (value == null) return;

                                        item.companyId = value.userId.toString();
                                        item.companyName = value.companyName.toString();

                                        item.selectedCustomers = [];
                                        item.sendList = [];

                                        var idList = value.customerId.toString().split('||');
                                        var usersList = value.firstName.toString().split('||');
                                        var phoneList = value.phoneNumber.toString().split('||');

                                        for (var i = 0; i < usersList.length; i++) {
                                          item.sendList.add({
                                            "id": idList[i],
                                            "name": usersList[i],
                                            "no": phoneList[i],
                                          });
                                        }

                                        if (item.sendList.length == 1) {
                                          item.selectedCustomers = [item.sendList[0]];
                                        }

                                        setState(() {});
                                      },
                                      size: (mainWidth / 2) - 5,
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  Expanded(
                                    child: MultiSelectDropdown(
                                      hintText: "Customer",
                                      dropText: "name",
                                      list: item.sendList,
                                      width: (mainWidth / 2) - 5,
                                      selectedItems: item.selectedCustomers,
                                      onChanged: (list) {
                                        setState(() {
                                          item.selectedCustomers = list;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),



                              /// 🔥 DESCRIPTION (NO FIXED HEIGHT)
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

                  /// 🔥 BUTTONS
                  SizedBox(
                    width: mainWidth,
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              side: BorderSide(color: colorsConst.primary),
                              padding:
                              const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: colorsConst.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: colorsConst.primary,
                              padding:
                              const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              for (var plan in workPlans) {
                                debugPrint("Company: ${plan.companyName}");
                                debugPrint("Customers: ${plan.selectedCustomers}");
                                debugPrint(
                                    "Desc: ${plan.descriptionController.text}");
                                debugPrint("Status: ${plan.status}");
                              }

                              // API Call Here
                            },
                            child: const Text(
                              "Save",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
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