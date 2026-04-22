import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:provider/provider.dart';
import '../../model/task/work_details_plan.dart';
import '../../view_model/home_provider.dart';


class DailyReportStatusPage extends StatefulWidget {
  final int initialTab;

  const DailyReportStatusPage({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<DailyReportStatusPage> createState() => _DailyReportStatusPageState();
}

class _DailyReportStatusPageState extends State<DailyReportStatusPage>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();

  late TabController tabController;
  Color indicatorColor = Colors.green;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
    tabController.index = widget.initialTab;

    indicatorColor = widget.initialTab == 0 ? Colors.green : Colors.red;

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        setState(() {
          indicatorColor = tabController.index == 0 ? Colors.green : Colors.red;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      String todayDate = DateTime.now().toIso8601String().split("T")[0];
      Provider.of<HomeProvider>(context, listen: false)
          .getWorkPlanList(true, todayDate);
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dateText = DateFormat("dd-MM-yyyy").format(selectedDate);

    return Scaffold(
      backgroundColor: colorsConst.bacColor,
      appBar: AppBar(
        backgroundColor: colorsConst.bacColor,
        title: Text(
          "Daily Work Details",
          style: TextStyle(
            color: colorsConst.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
          color: colorsConst.primary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: Consumer<HomeProvider>(
            builder: (context, provider, child) {
              final submittedList = provider.workPlanList
                  .where((e) => e.plans.isNotEmpty)
                  .toList();

              final notSubmittedList = provider.workPlanList
                  .where((e) => e.plans.isEmpty)
                  .toList();

              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: tabController,
                    indicator: BoxDecoration(
                      color: indicatorColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black54,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: "Submitted (${submittedList.length})"),
                      Tab(text: "Not Submitted (${notSubmittedList.length})"),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (!provider.workPlanRefresh) {
            return const Center(child: CircularProgressIndicator());
          }

          final submittedList =
          provider.workPlanList.where((e) => e.plans.isNotEmpty).toList();

          final notSubmittedList =
          provider.workPlanList.where((e) => e.plans.isEmpty).toList();

          return Column(
            children: [
              5.height,

              /// Date Picker
              Row(
                children: [
                  20.width,
                  Text(
                    "Date : $dateText",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_month, color: colorsConst.primary),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });

                        String apiDate =
                        picked.toIso8601String().split("T")[0];

                        provider.getWorkPlanList(true, apiDate);
                      }
                    },
                  )
                ],
              ),

              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    /// ✅ SUBMITTED TAB
                    submittedList.isEmpty
                        ? const Center(child: Text("No Submitted Plans"))
                        : ListView.builder(
                      itemCount: submittedList.length,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemBuilder: (context, index) {
                        WorkPlanModelDetails emp = submittedList[index];

                        int totalTask = emp.plans.length;
                        int completedTask = emp.plans
                            .where((p) => p.workStatus == "1")
                            .length;

                        double percent = totalTask == 0
                            ? 0
                            : completedTask / totalTask;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ExpansionTile(
                            title: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                /// Name + Role + Date
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          emp.name,
                                          style: const TextStyle(
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "(${emp.role})",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    // Text(
                                    //   "Date: ${emp.date}",
                                    //   style: const TextStyle(
                                    //       fontSize: 12,
                                    //       color: Colors.grey),
                                    // ),
                                  ],
                                ),

                                /// Completed/Total + Progress
                                Row(
                                  children: [
                                    Text(
                                      "$completedTask/$totalTask",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 60,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: percent,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            children: [
                              ListView.builder(
                                itemCount: emp.plans.length,
                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, planIndex) {
                                  DailyWorkPlanDetails plan =
                                  emp.plans[planIndex];

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 12,
                                              backgroundColor:
                                              Colors.blue.shade100,
                                              child: Text(
                                                "${planIndex + 1}",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                            10.width,
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4.0),
                                                child: Text(plan.desc,style: TextStyle(color: Colors.grey.shade600),),
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 30, top: 4.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                  Colors.black),
                                              children: [
                                                const TextSpan(
                                                  text: "Company : ",
                                                ),
                                                TextSpan(
                                                  text:
                                                  "${plan.company}\n",
                                                  style:
                                                  const TextStyle(
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.grey,
                                                  ),
                                                ),
                                                const TextSpan(
                                                  text: "Customer : ",
                                                ),
                                                TextSpan(
                                                  text: plan.customer,
                                                  style:
                                                  const TextStyle(
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        trailing: Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5),
                                          decoration: BoxDecoration(
                                            color: plan.workStatus == "1"
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            plan.workStatus == "1"
                                                ? "Achieved"
                                                : "Not Achieved",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      if (planIndex !=
                                          emp.plans.length - 1)
                                        const Divider(
                                            thickness: 1, height: 1),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    /// ❌ NOT SUBMITTED TAB
                    notSubmittedList.isEmpty
                        ? const Center(child: Text("No Not Submitted Users"))
                        : ListView.builder(
                      itemCount: notSubmittedList.length,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemBuilder: (context, index) {
                        WorkPlanModelDetails emp =
                        notSubmittedList[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(
                                  emp.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "(${emp.role})",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                            // subtitle: Text(
                            //   "Date: ${emp.date}",
                            //   style: const TextStyle(
                            //       fontSize: 12, color: Colors.grey),
                            // ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}