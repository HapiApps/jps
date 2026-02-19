import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/employee_provider.dart';

class ViewNotification extends StatefulWidget {
  const ViewNotification({super.key});

  @override
  State<ViewNotification> createState() => _ViewNotificationState();
}

class _ViewNotificationState extends State<ViewNotification> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<EmployeeProvider>(context, listen: false).getNotifications(markSeen: true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var webWidth = MediaQuery.of(context).size.width * 0.5;
    var phoneWidth = MediaQuery.of(context).size.width * 0.9;

    return Consumer<EmployeeProvider>(builder: (context, empProvider, _) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: const PreferredSize(
            preferredSize: Size(300, 50),
            child: CustomAppbar(text: "View Notifications"),
          ),
          body: Center(
            child: SizedBox(
              width: kIsWeb ? webWidth : phoneWidth,
              child: empProvider.refresh == false
                  ? const Loading()
                  : Column(
                children: [
                  20.height,
                  empProvider.notifyData.isEmpty
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
                      itemCount: empProvider.notifyData.length,
                      itemBuilder: (context, index) {
                        final employeeData = empProvider.notifyData[index];

                        DateTime dateTime =
                        DateTime.parse(employeeData["created_ts"]);

                        String sectionTitle = formatCreatedDate(dateTime);

                        String time =
                        DateFormat('h:mm a').format(dateTime);

                        String title = employeeData["title"] ?? "";
                        String body = employeeData["body"] ?? "";
                        String createdBy =
                        employeeData["firstname"]?.toString() == "null"
                            ? ""
                            : employeeData["firstname"].toString();

                        String type =
                        title.toLowerCase().contains("task")
                            ? "Task"
                            : "Feedback";
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
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showHeader) ...[
                              10.height,
                              CustomText(
                                text: sectionTitle,
                                colors: Colors.grey,
                              ),
                              10.height,
                            ],
                            Container(
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
                                          color: type == "Task"
                                              ? const Color(0xffE8F5E9)
                                              : const Color(0xffE3F2FD),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          type,
                                          style: TextStyle(
                                            color: type == "Task"
                                                ? const Color(0xff2E7D32)
                                                : const Color(0xff1A85DB),
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
                                  12.height,
                                  CustomText(
                                    text: title,
                                    size: 14,
                                    isBold: true,
                                  ),

                                  8.height,

                                  /// 🔹 Body
                                  CustomText(
                                    text: body,
                                    colors: colorsConst.greyClr,
                                  ),

                                  12.height,

                                  /// 🔹 Created By
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: "Created by ",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xffA80007),
                                              ),
                                            ),
                                            TextSpan(
                                              text: createdBy,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xffA80007),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Image.asset(
                                        "assets/images/message_icon.png",
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            if (index == empProvider.notifyData.length - 1)
                              80.height,
                          ],
                        );

                        // return Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     if (showDateHeader)
                        //       Padding(
                        //         padding: const EdgeInsets.symmetric(vertical: 5),
                        //         child: CustomText(
                        //           text: createdBy,
                        //           colors: Colors.grey,
                        //         ),
                        //       ),
                        //     Container(
                        //       width: kIsWeb ? webWidth : phoneWidth,
                        //       decoration: customDecoration.baseBackgroundDecoration(
                        //         color: Colors.white,
                        //         borderColor: Colors.grey.shade200,
                        //         isShadow: true,
                        //         shadowColor: Colors.grey.shade200,
                        //         radius: 5,
                        //       ),
                        //       child: Padding(
                        //         padding: const EdgeInsets.all(10),
                        //         child: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Row(
                        //               mainAxisAlignment:
                        //               MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 Row(
                        //                   children: [
                        //                     CustomText(
                        //                       text: employeeData["firstname"].toString()=="null"?"":employeeData["firstname"].toString(),
                        //                       colors: colorsConst.appOrg,
                        //                     ),
                        //                     if(employeeData["role"].toString()!="null")
                        //                     CustomText(
                        //                       text:
                        //                       " ( ${employeeData["role"].toString()} )",
                        //                       colors: Colors.grey,
                        //                     ),
                        //                   ],
                        //                 ),
                        //                 CustomText(
                        //                   text: time,
                        //                   colors: colorsConst.blue2,
                        //                 ),
                        //               ],
                        //             ),
                        //             10.height,
                        //             CustomText(
                        //               text: employeeData["title"].toString(),
                        //             ),
                        //             10.height,
                        //             CustomText(
                        //               text: employeeData["body"].toString(),
                        //               colors: colorsConst.greyClr,
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //     10.height,
                        //     if (index == empProvider.notifyData.length - 1)
                        //       80.height,
                        //   ],
                        // );
                      },
                    ),
                  ),
                ],
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
}
