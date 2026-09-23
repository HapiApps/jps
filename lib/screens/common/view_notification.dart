import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/screens/task/view_task.dart';
import 'package:master_code/source/constant/local_data.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/employee_provider.dart';
import '../../view_model/leave_provider.dart';
import '../leave_management/leave_dashboard.dart';
import '../leave_management/leave_report.dart';
import 'dashboard.dart';
import '../customer/visit_report/visits_report.dart';
import '../task/task_chat.dart';
import 'detail_work_plan.dart';

class ViewNotification extends StatefulWidget {
  const ViewNotification({super.key});

  @override
  State<ViewNotification> createState() => _ViewNotificationState();
}

class _ViewNotificationState extends State<ViewNotification> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final empProvider =
      Provider.of<EmployeeProvider>(context, listen: false);

      await empProvider.getNotifications();

      if (empProvider.notifyData.isNotEmpty) {
        await empProvider.markNotificationsSeen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var webWidth = MediaQuery.of(context).size.width * 0.5;
    var phoneWidth = MediaQuery.of(context).size.width * 0.9;

    return Consumer<EmployeeProvider>(builder: (context, empProvider, _) {
      var webHeight=MediaQuery.of(context).size.width * 0.5;
      var phoneHeight=MediaQuery.of(context).size.width * 0.95;
      return SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;

            Navigator.pop(context, true);
          },
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar:  PreferredSize(
              preferredSize: Size(300, 50),
              child: CustomAppbar(text: "${constValue.viewNotifications}",buttonCallback: (){ Navigator.pop(context, true);}),

            ),
            body: Center(
              child: SizedBox(
                width: kIsWeb ? webWidth : phoneWidth,
                child: empProvider.refresh == false
                    ? const Loading()
                    : Column(
                  children: [
                    20.height,
                    if(empProvider.filter==true)
                      10.height,
                    if(empProvider.filter==true)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Left chips
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (empProvider.startDate != empProvider.endDate)
                                  if (empProvider.startDate.isNotEmpty &&
                                      empProvider.endDate.isNotEmpty)
                                    _filterChip(
                                      "${empProvider.startDate} - ${empProvider.endDate}",
                                    ),

                                if (empProvider.type.isNotEmpty || empProvider.type!="null")
                                  _filterChip(empProvider.type), // Last 7 days

                                if (empProvider.userName.isNotEmpty)
                                  _filterChip(empProvider.userName),
                              ],
                            ),
                          ),
                        ],
                      ),
                    empProvider.filteredNotifyDatas.isEmpty
                        ? Column(
                      children: [
                        100.height,
                        CustomText(
                            text: "No Notifications Found",
                            colors: colorsConst.greyClr),
                      ],
                    )
                        : Expanded(
                      child: ListView.builder(
                        itemCount: empProvider.filteredNotifyDatas.length,
                        itemBuilder: (context, index) {
                          final employeeData = empProvider.filteredNotifyDatas[index];

                          // Parse once, reuse everywhere (avoids repeated DateTime.parse in this item)
                          final DateTime dateTime =
                          DateTime.parse(employeeData["created_ts"]);
                          final String createdTsFormattedDMY =
                          DateFormat("dd-MM-yyyy").format(dateTime);

                          String sectionTitle = formatCreatedDate(dateTime);

                          String time =
                          DateFormat('h:mm a').format(dateTime);

                          String title = employeeData["title"] ?? "";
                          String body = employeeData["body"] ?? "";

                          String message = body;
                          String date = "";

                          if (body.contains("||")) {
                            List<String> parts = body.split("||");

                            message = parts[0].trim();

                            if (parts.length > 1) {
                              date = parts[1].trim();
                            }
                          }
                          String createdBy =
                          employeeData["firstname"]?.toString() == "null"
                              ? ""
                              : employeeData["firstname"].toString();
                          String type =
                          title.toLowerCase().contains("feedback")
                              ? "Feedback":
                          title.toLowerCase().contains("visit report")
                              ? "Visit Report":
                          message.toLowerCase().contains("requested")
                              ? "Leave":
                          message.toLowerCase().contains("Created")
                              ? "Feedback":
                          message.toLowerCase().contains("daily work plan")
                              ? "Daily Work Plan"
                              :"Task";
                          final sortedData = empProvider.notifyData;

                          String? prevCreatedBy;
                          if (index != 0) {
                            final prevDateTime = DateTime.parse(
                                sortedData[index - 1]["created_ts"]);
                            prevCreatedBy = formatCreatedDate(prevDateTime);
                          }
                          bool showHeader = true;
                          if (index > 0) {
                            final prevDate =
                            DateTime.parse(empProvider.notifyData[index - 1]["created_ts"]);
                            showHeader =
                                formatCreatedDate(prevDate) != sectionTitle;
                          }

                          final showDateHeader = index == 0 ||
                              createdBy != prevCreatedBy;

                          // Reuse the already-parsed date instead of parsing empProvider.notifyData[index] again
                          String mesBody = employeeData["body"] ?? "";
                          String taskDate = createdTsFormattedDMY;
                          if (mesBody.contains("||")) {
                            final parts = mesBody.split("||");

                            if (parts.length > 1) {
                              String dateStr = parts[1].trim();
                              try {
                                taskDate = DateFormat("dd-MM-yyyy").format(
                                  DateFormat("dd-MM-yyyy").parseStrict(dateStr),
                                );
                              } catch (e) {
                                taskDate = createdTsFormattedDMY;
                                print("Date Parse Error: $e");
                              }
                            }
                          }

                          // Navigation logic pulled out so onTap stays snappy;
                          // scheduled after the current frame so the tap/ripple
                          // feedback renders immediately instead of feeling stuck.
                          void handleNotificationTap() {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;

                              if (type == "Feedback") {
                                utils.navigatePage(
                                  context,
                                      () => DashBoard(
                                    child: TaskChat(
                                      isVisit: false,
                                      taskId: employeeData["purpose_id"],
                                      assignedId: "",
                                      assignedName: "",
                                      name: createdBy,
                                      date1: '',
                                      date2: '',
                                      type: '',
                                      index: -1,
                                    ),
                                  ),
                                );
                              } else if (type == "Visit Report") {
                                utils.navigatePage(
                                  context,
                                      () => DashBoard(
                                    child: VisitReport(
                                      date1: createdTsFormattedDMY,
                                      date2: createdTsFormattedDMY,
                                      month: "",
                                      type: "Today",
                                    ),
                                  ),
                                );
                              } else if (type == "Leave") {
                                if (localData.storage.read("role") == "1") {
                                  Provider.of<LeaveProvider>(context, listen: false)
                                      .changeIndex(2);

                                  utils.navigatePage(
                                    context,
                                        () => const DashBoard(
                                        child: LeaveManagementDashboard()),
                                  );
                                } else {
                                  utils.navigatePage(
                                    context,
                                        () => DashBoard(
                                      child: ViewMyLeaves(
                                        date1: createdTsFormattedDMY,
                                        date2: createdTsFormattedDMY,
                                        isDirect: true,
                                      ),
                                    ),
                                  );
                                }
                              } else if (type == "Daily Work Plan") {
                                utils.navigatePage(
                                  context,
                                      () => const DashBoard(
                                      child: DailyReportStatusPage()),
                                );
                              } else {
                                utils.navigatePage(
                                  context,
                                      () => DashBoard(
                                    child: ViewTask(
                                      date1: taskDate,
                                      date2: taskDate,
                                      type: "Today",
                                    ),
                                  ),
                                );
                              }
                            });
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showHeader) ...[
                                5.height,
                                CustomText(
                                  text: sectionTitle,
                                  colors: Colors.grey,
                                ),
                                5.height,
                              ],
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: handleNotificationTap,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade200,
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        /// 🔹 Top Row
                                        Row(
                                          children: [

                                            /// Type chip
                                            Container(
                                              padding:
                                              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: type == "Daily Work Plan"
                                                    ? Colors.brown.shade50
                                                    : type == "Task"
                                                    ? const Color(0xffE8F5E9)
                                                    : type == "Leave"?Colors.red.shade200
                                                    : type == "Feedback"?Colors.purple.shade200:
                                                const Color(0xffE3F2FD),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                type,
                                                style: TextStyle(
                                                  color: type == "Daily Work Plan"
                                                      ? Colors.brown:
                                                  type == "Task"
                                                      ? const Color(0xff2E7D32):
                                                  type == "Leave"?Colors.red:
                                                  type == "Feedback"?Colors.purple:
                                                  const Color(0xff1A85DB),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),

                                            const Spacer(),

                                            Row(
                                              children: [
                                                const Icon(Icons.circle,
                                                    size: 6, color: Color(0xff7E7E7E)),
                                                6.width,
                                                CustomText(
                                                  text: time,
                                                  colors: Colors.grey,
                                                  size: 12,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        5.height,

                                        /// 🔹 Body
                                        if(!message.toLowerCase().contains("daily work plan"))
                                          CustomText(
                                            text: title.toLowerCase().contains("feedback")&&message==""?"Voice Message":message,isBold: true,
                                          ),
                                        if(!message.toLowerCase().contains("daily work plan"))
                                          5.height,

                                        /// 🔹 Created By
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: message.toLowerCase().contains("daily work plan")?"Added by ":type=="Feedback"?"Feedback sent by ":type=="Leave"?"Leave Applied  ":"Created by ",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xffA80007),
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: createdBy=="null"?"Admin":createdBy,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xffA80007),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if(type!="Leave")
                                              SvgPicture.asset(
                                                assets.tMessage,
                                                height: 25,width: 25,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              if (index == empProvider.notifyData.length - 1)
                                80.height,
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
      );
    });
  }

  String formatCreatedDate(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime dataDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dataDate == today) {
      return "Today";
    } else if (dataDate == today.subtract(const Duration(days: 1))) {
      return "Yesterday";
    } else {
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }
  }
  Widget _filterChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xff353535),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xffF5F5F5),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}