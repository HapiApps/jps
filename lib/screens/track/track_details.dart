import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:master_code/view_model/home_provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/track_provider.dart';

class NewEmpReport extends StatefulWidget {
  final String id;
  final String name;
  const NewEmpReport({super.key, required this.id,required this.name});

  @override
  State<NewEmpReport> createState() => _NewEmpReportState();
}

class _NewEmpReportState extends State<NewEmpReport> with SingleTickerProviderStateMixin{

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<TrackProvider>(context, listen: false).todayReport({"1"}.contains(
          localData.storage.read("role"))?widget.id:localData.storage.read("id"));
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer2<TrackProvider,HomeProvider>(builder: (context,trackProvider,homeProvider,_)
    {
      return Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: PreferredSize(
          preferredSize: const Size(300, 40),
          child: CustomAppbar(text: constValue.trackD),
        ),
        body: Column(
          children: [
            trackProvider.isTrack == false ? const Padding(
              padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
              child: Loading(),
            ) :
            trackProvider.detailReport.isNotEmpty ?
            Expanded(
                child: ListView.builder(
                    itemCount:trackProvider.detailReport.length,
                    itemBuilder: (context,index){
                      return Column(
                          children: [
                            10.height,
                            if(index==0)
                              SizedBox(
                                width: MediaQuery.of(context).size.width*0.83,
                                // decoration: customDecoration.baseBackgroundDecoration(
                                //   color: Colors.white,
                                //   radius: 5,
                                //   borderColor: Colors.grey.shade200,
                                // ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Column(
                                    children: [
                                      // Row(
                                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     Row(
                                      //       children: [
                                      //         const CustomText(text:'Start Time : ',colors: Colors.grey,),
                                      //         CustomText(text:trackProvider.formatTime(trackProvider.time1)),
                                      //       ],
                                      //     ),
                                      //     Row(
                                      //       children: [
                                      //         const CustomText(text:'End Time : ',colors: Colors.grey,),
                                      //         CustomText(text:trackProvider.formatTime(trackProvider.time2)),
                                      //       ],
                                      //     ),
                                      //   ],
                                      // ),
                                      // 5.height,
                                      // Row(
                                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     Row(
                                      //       children: [
                                      //         const CustomText(text: 'Total Distance : ',colors: Colors.grey,),
                                      //         CustomText(text: '${trackProvider.totalDst} km'),
                                      //       ],
                                      //     ),
                                      //     Row(
                                      //       children: [
                                      //         CustomText(text: '${trackProvider.detailReport.length-1}'),
                                      //       ],
                                      //     ),
                                      //   ],
                                      // ),
                                      CustomText(text: widget.name,isBold: true,size: 15,),15.height,
                                      CustomText(text: '${trackProvider.detailReport.length-1} ${trackProvider.detailReport.length-1==1?"Client":"Client's"} Visit Summary',isBold: true,size: 13,),
                                    ],
                                  ),
                                ),
                              ),
                            if(trackProvider.detailReport[index]['Unit Name']!="null")
                              Container(
                                width: MediaQuery.of(context).size.width*0.83,
                                decoration: customDecoration.baseBackgroundDecoration(
                                  color: Colors.white,
                                  radius: 5,
                                  borderColor: Colors.grey.shade200,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(text:'${trackProvider.detailReport[index]['Unit Name']}'),
                                      Container(color: Colors.grey,width: 0.5,height: 40,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const CustomText(text: 'Check In',colors: Colors.grey,),
                                          CustomText(text: trackProvider.formatTime(trackProvider.detailReport[index]["Start Time"])),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const CustomText(text: 'Check Out',colors: Colors.grey,),
                                          CustomText(text: trackProvider.detailReport[index]["End Image"]=="null"||trackProvider.detailReport[index]["End Image"]==""?"-":trackProvider.formatTime(trackProvider.detailReport[index]["End Time"])),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const CustomText(text: 'Duration',colors: Colors.grey,),
                                          CustomText(text: utils.calculateDuration(trackProvider.formatTime(trackProvider.detailReport[index]["Start Time"].toString()),trackProvider.formatTime(trackProvider.detailReport[index]["End Time"].toString()))),
                                        ],
                                      ),
                                      // Column(
                                      //   children: [
                                      //     const CustomText(text: 'Distance',colors: Colors.grey,),
                                      //     CustomText(text: '${trackProvider.detailReport[index]["Distance"]} km'),
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                          ]
                      );
                    }
                )
            ) : const Padding(
              padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
              child: CustomText(text: "No Result Data"),
            ),
          ],
        ),
      );
    });
  }
}
