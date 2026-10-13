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
      Provider.of<EmployeeProvider>(context, listen: false).getNotifications();
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
                        final sortedData = empProvider.notifyData;
                        final employeeData = sortedData[index];
                        String timestamp =
                        employeeData["created_ts"].toString();
                        DateTime dateTime = DateTime.parse(timestamp);

                        String createdBy = formatCreatedDate(dateTime);
                        String time =
                        DateFormat('h:mm a').format(dateTime);

                        String? prevCreatedBy;
                        if (index != 0) {
                          final prevDateTime = DateTime.parse(
                              sortedData[index - 1]["created_ts"]);
                          prevCreatedBy = formatCreatedDate(prevDateTime);
                        }

                        final showDateHeader = index == 0 ||
                            createdBy != prevCreatedBy;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDateHeader)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: CustomText(
                                  text: createdBy,
                                  colors: Colors.grey,
                                ),
                              ),
                            Container(
                              width: kIsWeb ? webWidth : phoneWidth,
                              decoration: customDecoration.baseBackgroundDecoration(
                                color: Colors.white,
                                borderColor: Colors.grey.shade200,
                                isShadow: true,
                                shadowColor: Colors.grey.shade200,
                                radius: 5,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CustomText(
                                              text: employeeData["firstname"]
                                                  .toString(),
                                              colors: colorsConst.appOrg,
                                            ),
                                            CustomText(
                                              text:
                                              " ( ${employeeData["role"].toString()} )",
                                              colors: Colors.grey,
                                            ),
                                          ],
                                        ),
                                        CustomText(
                                          text: time,
                                          colors: colorsConst.blue2,
                                        ),
                                      ],
                                    ),
                                    10.height,
                                    CustomText(
                                      text: employeeData["title"].toString(),
                                    ),
                                    10.height,
                                    CustomText(
                                      text: employeeData["body"].toString(),
                                      colors: colorsConst.greyClr,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            10.height,
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
