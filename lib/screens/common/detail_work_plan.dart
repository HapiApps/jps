import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
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
  Color indicatorColor = Colors.green; // default submitted green

  /// Dummy Data
  final List<Map<String, dynamic>> employeeList = [
    {
      "name": "Raj Kumar",

      "plans": [
        {
          "company": "HapiApps",
          "customer": "Ravi",
          "desc": "Visited client and demo done",
          "workStatus": "1"
        },
        {
          "company": "ABC Pvt Ltd",
          "customer": "Karthik",
          "desc": "Follow-up call completed",
          "workStatus": "0"
        },
        {
          "company": "TechZone",
          "customer": "Anitha",
          "desc": "Collected payment and updated report",
          "workStatus": "1"
        },
      ]
    },
    {"name": "Suresh",

      "plans": []
    },
    {
      "name": "Priya",
      "plans": [
        {
          "company": "TechZone",
          "customer": "Anitha",
          "desc": "Collected payment and updated report",
          "workStatus": "0"
        },
        {
          "company": "HapiApps",
          "customer": "Ravi",
          "desc": "Visited client and demo done",
          "workStatus": "1"
        },
        {
          "company": "ABC Pvt Ltd",
          "customer": "Karthik",
          "desc": "Follow-up call completed",
          "workStatus": "0"
        },
        {
          "company": "PSS Pvt Ltd",
          "customer": "Kumar",
          "desc": "Follow-up call completed and meeting",
          "workStatus": "0"
        },
      ]
    },
    {"name": "Anitha",
      "plans": []
    },
  ];


  @override
  // void initState() {
  //   super.initState();
  //
  //   tabController = TabController(length: 2, vsync: this);
  //
  //   tabController.index = widget.initialTab;
  //
  //   tabController.addListener(() {
  //     if (tabController.index == 0) {
  //       setState(() {
  //         indicatorColor = Colors.green;
  //       });
  //     } else {
  //       setState(() {
  //         indicatorColor = Colors.red;
  //       });
  //     }
  //   });
  // }
  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);

    /// set initial tab
    tabController.index = widget.initialTab;

    /// 🔥 IMPORTANT: listen after frame
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        setState(() {
          indicatorColor =
          tabController.index == 0 ? Colors.green : Colors.red;
        });
      }
    });

    /// 🔥 set initial color properly
    indicatorColor =
    widget.initialTab == 0 ? Colors.green : Colors.red;
  }
  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dateText = DateFormat("dd-MM-yyyy").format(selectedDate);

    final submittedList =
    employeeList.where((e) => e["status"] == true).toList();

    final notSubmittedList =
    employeeList.where((e) => e["status"] == false).toList();

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

        /// ✅ TAB BAR (Grey BG + Green/Red Indicator)
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.grey.shade300, // ✅ Grey Background
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: tabController,
                indicator: BoxDecoration(
                  color: indicatorColor, // ✅ Green / Red indicator
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
          ),
        ),
      ),
      body: Column(
        children: [
          5.height,

          /// Date Picker Row
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
                  }
                },
              )
            ],
          ),

          /// TAB VIEW
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                /// ✅ SUBMITTED TAB
                ListView.builder(
                  itemCount: submittedList.length,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemBuilder: (context, index) {
                    final emp = submittedList[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  emp["name"],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "(Employee)",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            /// ✅ Completed / Total
                            Builder(builder: (context) {
                              int totalTask = emp["plans"].length;
                              int completedTask = emp["plans"]
                                  .where((p) => p["workStatus"] == "Achieved")
                                  .length;

                              double percent = totalTask == 0 ? 0 : completedTask / totalTask;

                              return Row(
                                children: [
                                  Text(
                                    "$completedTask/$totalTask",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  /// ✅ Mini Progress Bar
                                  Container(
                                    width: 60,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: percent,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                        children: [
                          ListView.builder(
                            itemCount: emp["plans"].length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, planIndex) {
                              final plan = emp["plans"][planIndex];

                              return Column(
                                children: [
                                  ListTile(
                                    title: Row(

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
                                        Column(

                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                style: const TextStyle(
                                                    fontSize: 14, color: Colors.black),
                                                children: [
                                                  const TextSpan(
                                                    text: "Company : ",
                                                    style:
                                                    TextStyle(color: Colors.black),
                                                  ),
                                                  TextSpan(
                                                    text: "${plan["company"]}\n",
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text: "Customer : ",
                                                    style:
                                                    TextStyle(color: Colors.black),
                                                  ),
                                                  TextSpan(
                                                    text: "${plan["customer"]}",
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          ],
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(left:30,top: 4.0),
                                      child: Text(plan["desc"]),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: plan["workStatus"] == "Achieved"
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        plan["workStatus"],
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  if (planIndex != emp["plans"].length - 1)
                                    const Divider(thickness: 1, height: 1),
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
                ListView.builder(
                  itemCount: notSubmittedList.length,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemBuilder: (context, index) {
                    final emp = notSubmittedList[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(
                              emp["name"],
                              style:
                                TextStyle(fontWeight: FontWeight.bold),
                            ),
                              SizedBox(width: 6),
                              Text(
                              "(Employee)",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,fontSize: 12,
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
      ),
    );
  }
}