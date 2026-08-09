import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_network_image.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../model/report/work_report_model.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/project_provider.dart';
import '../../view_model/report_provider.dart';
import '../common/dashboard.dart';
import '../common/home_page.dart';
import 'create_project_report.dart';
class ViewProjectReport extends StatefulWidget {
  const ViewProjectReport({super.key
  });

  @override
  State<ViewProjectReport> createState() => _ViewProjectReportState();
}

class _ViewProjectReportState extends State<ViewProjectReport> with TickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ReportProvider>(context, listen: false).getProjectReport();
      Provider.of<ProjectProvider>(context, listen: false).getAllProject(true);
    });
    // Future.delayed(Duration.zero,() {
    //   repProvider.date1.value="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
    //   repProvider.date2.value="";
    // });
    super.initState();
  }

  @override
  void dispose() {
    _myFocusScopeNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var web=MediaQuery.of(context).size.width*0.7;
    var phone=MediaQuery.of(context).size.width*0.95;
    return Consumer2<ReportProvider,HomeProvider>(builder: (context,repProvider,homeProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: PreferredSize(
            preferredSize: const Size(300, 50),
            child: CustomAppbar(text: constValue.projectReport,
            isButton: true,
            buttonCallback: (){
              _myFocusScopeNode.unfocus();
              utils.navigatePage(context, ()=>const DashBoard(child: CreateProjectReport()));
              },
            callback: (){
              _myFocusScopeNode.unfocus();
              homeProvider.updateIndex(0);
              utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
            },),
          ),
          body: PopScope(
            canPop: false,
            onPopInvoked: (bool didPop) {
              _myFocusScopeNode.unfocus();
              homeProvider.updateIndex(0);
              if (!didPop) {
                utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
              }
            },
            child: Center(
              child: SizedBox(
                  width: kIsWeb ? web : phone,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // InkWell(
                        //   onTap: () {
                        //     // utils.datePick(context: context, textEdittingController:repProvider.date1);
                        //   },
                        //   child: Container(
                        //     color: Colors.grey.shade100,
                        //     height: 50,
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //       children: [
                        //         Row(
                        //           children: [
                        //             // Icon(
                        //             //   Icons.calendar_today, size: 15,
                        //             //   color: colorsConst.third,), 5.width,
                        //             // CustomText(
                        //             //   text: "${repProvider.date1.value}${repProvider
                        //             //       .date1.value ==
                        //             //       repProvider.date2.value ||
                        //             //       repProvider.date2.value == ""
                        //             //       ? ""
                        //             //       : " To ${repProvider.date2.value}"}",)
                        //           ],
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        CustomTextField(
                          text: "",radius: 30,
                          width: kIsWeb ? web : phone,
                          controller: repProvider.search,
                          hintText: "Search Name Or Project Name",
                          isIcon: true,
                          iconData: Icons.search,
                          textInputAction: TextInputAction.done,
                          isShadow: true,
                          onChanged: (value) {
                            repProvider.searchPrjReport(value);
                          },
                          isSearch: repProvider.search.text.isNotEmpty?true:false,
                          searchCall: (){
                            repProvider.search.clear();
                            repProvider.searchPrjReport("");
                          },
                        ),
                        repProvider.dataRefresh == false ?
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
                          child: Loading(),
                        )
                            : repProvider.searchProjectReport.isEmpty ?
                        Column(
                          children: [
                            100.height,
                            Center(
                                child: CustomText(
                                  text: constValue.noData, size: 14,)),
                          ],
                        )
                            : Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: repProvider.searchProjectReport.length,
                              itemBuilder: (context, index) {
                                ReportModel data = repProvider
                                    .searchProjectReport[index];
                                var docsList = data.documents.toString().split(',');
                                var createdBy = "";
                                String timestamp = data.createdTs.toString();
                                DateTime dateTime = DateTime.parse(timestamp);
                                String dayOfWeek = DateFormat('EEEE').format(
                                    dateTime);
                                DateTime today = DateTime.now();
                                if (dateTime.day == today.day &&
                                    dateTime.month == today.month &&
                                    dateTime.year == today.year) {
                                  dayOfWeek = 'Today';
                                } else if (dateTime.isAfter(today.subtract(
                                    const Duration(days: 1))) &&
                                    dateTime.isBefore(today)) {
                                  dayOfWeek = 'Yesterday';
                                } else {
                                  dayOfWeek =
                                  "${dateTime.day}/${dateTime.month}/${dateTime
                                      .year}";
                                }
                                createdBy =
                                "${dateTime.day}/${dateTime.month}/${dateTime
                                    .year}";
                                final showDateHeader = index == 0 ||
                                    createdBy != getCreatedDate(repProvider
                                        .searchProjectReport[index - 1]);
                                return Column(
                                  children: [
                                    if(showDateHeader)
                                      CustomText(
                                        text: dayOfWeek,
                                        colors: colorsConst.greyClr,
                                        isBold: true,),
                                    Container(
                                      width: kIsWeb ? web : phone,
                                      decoration: customDecoration
                                          .baseBackgroundDecoration(
                                          color: Colors.white,
                                          borderColor: Colors.grey.shade200,
                                          isShadow: true,
                                          shadowColor: Colors.grey.shade200,
                                          radius: 5
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            10.height,
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                CustomText(
                                                  text: data.fName.toString(),
                                                  colors: colorsConst.primary,
                                                  isBold: true,),
                                                CustomText(text: data.projectName
                                                    .toString(),
                                                    colors: colorsConst.secondary),
                                              ],
                                            ),
                                            10.height,
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    CustomText(
                                                        text: constValue.cmt,
                                                        colors: Colors.grey),
                                                    CustomText(
                                                      text: data.date.toString(),
                                                      colors: colorsConst.greyClr,),
                                                  ],
                                                ),
                                                10.height,
                                                CustomText(
                                                    text: data.comment.toString(),
                                                    colors: colorsConst.greyClr),
                                                10.height,
                                              ],
                                            ),
                                            5.height,
                                            SizedBox(
                                              height: 50,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.horizontal,
                                                itemCount: docsList.length,
                                                itemBuilder: (context, i) {
                                                  return Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          _myFocusScopeNode.unfocus();
                                                          utils.imgDialog(
                                                              context: context,
                                                              img: docsList[i],
                                                              title: ""
                                                          );
                                                        },
                                                        child: Container(
                                                          height: 50,
                                                          width: 50,
                                                          decoration: customDecoration
                                                              .baseBackgroundDecoration(
                                                              radius: 5
                                                          ),
                                                          child: NetworkImg(
                                                            image: docsList[i],
                                                            width: 5,),
                                                        ),
                                                      ),
                                                      5.width
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                            5.height,
                                          ],
                                        ),
                                      ),
                                    ),
                                    30.height,
                                    if(index ==
                                        repProvider.searchProjectReport.length - 1)
                                      80.height
                                  ],
                                );
                              }),
                        ),
                      ]
                  )
              ),
            ),
          ),
        ),
      );
    });
  }
  String getCreatedDate(data) {
    final timestamp = data.createdTs.toString();
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}
