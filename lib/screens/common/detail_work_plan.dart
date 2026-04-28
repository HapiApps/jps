import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:provider/provider.dart';
import '../../model/task/work_details_plan.dart';
import '../../source/constant/local_data.dart';
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

  bool get isAdmin => localData.storage.read("role") == "1";

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
  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "-";

    try {
      DateTime dt = DateTime.parse(dateTime);
      return DateFormat("hh:mm a").format(dt);
    } catch (e) {
      return dateTime;
    }
  }
  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  /// ✅ Plan Tile Common Widget
  Widget buildPlanTile(
      DailyWorkPlanDetails plan, int planIndex, int totalPlans) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Plan Number + Description Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      "${planIndex + 1}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  10.width,
                  Expanded(
                    child: Text(
                      plan.desc,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: localData.storage.read("role") != "1"
                            ? InkWell(
                          onTap: () async {
                            String newStatus =
                            plan.workStatus == "1" ? "0" : "1";

                            bool? confirm = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text(
                                    "Confirm",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: "Mark this work plan as ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: newStatus == "1"
                                              ? "Achieved "
                                              : "Not Achieved ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: newStatus == "1"
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: "?",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: newStatus == "1"
                                            ? Colors.green
                                            : Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        "Yes",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm != true) return;

                            await Provider.of<HomeProvider>(context,
                                listen: false)
                                .updateWorkStatus(
                              true,
                              plan.detailId,
                              newStatus,
                              context,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: plan.workStatus == "1"
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              plan.workStatus == "1"
                                  ? "Achieved"
                                  : "Not Achieved",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                            : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                            plan.workStatus == "1" ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            plan.workStatus == "1"
                                ? "Achieved"
                                : "Not Achieved",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),


            5.height,
              /// Company + Customer Row
              if ((plan.company ?? "").toString().trim().isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                             TextSpan(
                              text: "Company : ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            TextSpan(
                              text: (plan.company ?? ""),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                             TextSpan(
                              text: "Customer : ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,

                                fontSize: 13,
                              ),
                            ),
                            TextSpan(
                              text: (plan.customer ?? ""),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),



              /// Created + Updated Time Row
              Row(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          "Created: ",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,

                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDateTime(plan.createdTime),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          "  Updated: ",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDateTime(plan.updatedTime),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              /// Status Button (Last Row)

            ],
          ),
        ),

        if (planIndex != totalPlans - 1)
          const SizedBox(height: 2),
      ],
    );
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
          onPressed: () {
            Navigator.pop(context, true); // <-- refresh flag
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: colorsConst.primary,
        ),

        /// ✅ ONLY ADMIN TAB BAR SHOW
        bottom: isAdmin
            ? PreferredSize(
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
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
                      Tab(
                          text:
                          "Not Submitted (${notSubmittedList.length})"),
                    ],
                  ),
                ),
              );
            },
          ),
        )
            : PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: const SizedBox(),
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
                    icon:
                    Icon(Icons.calendar_month, color: colorsConst.primary),
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

                        /// ✅ API format date (yyyy-MM-dd)
                        String apiDate =
                        picked.toIso8601String().split("T")[0];

                        /// ✅ Call Provider API
                        Provider.of<HomeProvider>(context, listen: false)
                            .getWorkPlanList(true, apiDate);
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
                          child: isAdmin
                              ? ExpansionTile(
                            title: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                /// Name + Role
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
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
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
                                        BorderRadius.circular(
                                            10),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment:
                                        Alignment.centerLeft,
                                        widthFactor: percent,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                            BorderRadius
                                                .circular(10),
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

                                  return buildPlanTile(plan,
                                      planIndex, emp.plans.length);
                                },
                              ),
                            ],
                          )
                              : Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
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
                                    const SizedBox(width: 40),
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
                              ),
                              const Divider(height: 1),
                              ListView.builder(
                                itemCount: emp.plans.length,
                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, planIndex) {
                                  DailyWorkPlanDetails plan =
                                  emp.plans[planIndex];

                                  return buildPlanTile(plan,
                                      planIndex, emp.plans.length);
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