import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../model/report/work_report_model.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/home_provider.dart';
import '../../view_model/project_provider.dart';
import '../../view_model/report_provider.dart';
import '../common/dashboard.dart';
import '../common/home_page.dart';
import 'create_work_report.dart';
class ViewWorkReport extends StatefulWidget {
  const ViewWorkReport({super.key
  });

  @override
  State<ViewWorkReport> createState() => _ViewWorkReportState();
}

class _ViewWorkReportState extends State<ViewWorkReport> with TickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ReportProvider>(context, listen: false).getWorkReport();
      Provider.of<ProjectProvider>(context, listen: false).getAllProject(true);
    });
    super.initState();
  }
  @override
  void dispose() {
    _myFocusScopeNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width*0.7;
    var phoneWidth=MediaQuery.of(context).size.width*0.95;
    return Consumer2<ReportProvider,HomeProvider>(builder: (context,repProvider,homeProvider,_){
    return FocusScope(
      node: _myFocusScopeNode,
      child: Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: PreferredSize(
          preferredSize: const Size(300, 50),
          child: CustomAppbar(text: constValue.workReport,isButton: true,
          callback: (){
            _myFocusScopeNode.unfocus();
            homeProvider.updateIndex(0);
            utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
          },
          buttonCallback: (){
            _myFocusScopeNode.unfocus();
            utils.navigatePage(context, ()=>const DashBoard(child: CreateWorkReport()));
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
          child: repProvider.dataRefresh==false?
          const Loading()
              :Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                repProvider.addedReport.isEmpty?
                Column(
                  children: [
                    200.height,
                    Center(
                        child: CustomText(text:constValue.noData,size: 14,)),
                  ],
                )
                    :Flexible(
                  child: ListView.builder(
                      itemCount: repProvider.addedReport.length,
                      itemBuilder: (context,index){
                        ReportModel data = repProvider.addedReport[index];
                        var usersList=data.users.toString().split(',');
                        var inTimeList=data.inTimes.toString().split(',');
                        var outTimeList=data.outTimes.toString().split(',');
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Container(
                                width: kIsWeb?webWidth:phoneWidth,
                                decoration: customDecoration.baseBackgroundDecoration(
                                    color: Colors.white,
                                    borderColor: Colors.grey.shade200,
                                    isShadow: true,
                                    shadowColor: Colors.grey.shade200,
                                    radius: 10
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      10.height,
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CustomText(text: constValue.projectName,colors: Colors.grey),
                                              5.height,
                                              CustomText(text: data.projectName.toString(),colors: colorsConst.secondary,isBold: true,),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              CustomText(text: constValue.engineerName,colors: Colors.grey),
                                              5.height,
                                              CustomText(text: data.engineerName.toString(),colors: colorsConst.secondary,isBold: true,),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              CustomText(text: "Date",colors: Colors.grey),
                                              5.height,
                                              CustomText(text: data.date.toString(),colors: colorsConst.secondary,isBold: true,),
                                            ],
                                          ),
                                        ],
                                      ),
                                      10.height,
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: usersList.length,
                                          itemBuilder: (context,index){
                                            return Table(
                                              border: TableBorder.all(color: Colors.grey.shade300),
                                              columnWidths: const {
                                                0: FlexColumnWidth(2),
                                                1: FlexColumnWidth(1),
                                                2: FlexColumnWidth(1),
                                              },
                                              children: [
                                                if(index==0)
                                                  TableRow(
                                                      decoration: customDecoration.baseBackgroundDecoration(
                                                          color: Colors.grey.shade100,
                                                          radius: 0
                                                      ),
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.all(10.0),
                                                          child: CustomText(text: constValue.name,colors: Colors.grey),
                                                        ),
                                                        Padding(
                                                            padding: const EdgeInsets.all(10.0),
                                                            child: CustomText(text: constValue.inTime,colors: Colors.grey)
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.all(10.0),
                                                          child: CustomText(text: constValue.outTime,colors: Colors.grey),
                                                        ),
                                                      ]
                                                  ),
                                                TableRow(
                                                    decoration: customDecoration.baseBackgroundDecoration(
                                                        color: Colors.grey.shade100,
                                                        radius: 0
                                                    ),
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(text: usersList[index],colors: colorsConst.secondary),
                                                      ),
                                                      Padding(
                                                          padding: const EdgeInsets.all(10.0),
                                                          child: CustomText(text: inTimeList[index],colors: colorsConst.secondary)
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(text: outTimeList[index],colors: colorsConst.secondary),
                                                      ),
                                                    ]
                                                ),
                                              ],
                                            );
                                          }),
                                      10.height,
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CustomText(text: constValue.planWork,colors: Colors.grey),
                                          10.height,
                                          CustomText(text: data.planWork.toString(),colors: colorsConst.secondary,isBold: true,),
                                          10.height,
                                          CustomText(text: constValue.finishedWork,colors: Colors.grey),
                                          10.height,
                                          CustomText(text: data.finishedWork.toString(),colors: colorsConst.secondary,isBold: true,),
                                          10.height,
                                          CustomText(text: constValue.pendingWork,colors: Colors.grey),
                                          10.height,
                                          CustomText(text: data.pendingWork.toString(),colors: colorsConst.secondary,isBold: true,),
                                          10.height,
                                        ],
                                      ),
                                      10.height,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            30.height,
                            if(index==repProvider.addedReport.length-1)
                              80.height
                          ],
                        );
                      }),
                ),
              ]
          ),
        )
      ),
    );
    });
  }
}
