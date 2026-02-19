import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/task_provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../../../component/custom_appbar.dart';
import '../../../component/custom_loading.dart';
import '../../../component/custom_text.dart';
import '../../../model/customer/customer_report_model.dart';
import '../../../source/constant/colors_constant.dart';
import '../../../source/constant/default_constant.dart';
import '../../../source/constant/local_data.dart';
import '../../../source/styles/styles.dart';
import '../../../source/utilities/utils.dart';
import '../../../view_model/customer_provider.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:provider/provider.dart';

import '../../source/constant/assets_constant.dart';
import '../../source/styles/decoration.dart';

class TaskChat extends StatefulWidget {
  final String taskId;
  final String assignedId;
  const TaskChat({super.key, required this.taskId, required this.assignedId});

  @override
  State<TaskChat> createState() => _TaskChatState();
}

class _TaskChatState extends State<TaskChat> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<CustomerProvider>(context, listen: false).disPoint.clear();
      Provider.of<CustomerProvider>(context, listen: false).getTaskComments(widget.taskId);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer2<CustomerProvider,TaskProvider>(builder: (context,custProvider,taskProvider,_){
      var webWidth=MediaQuery.of(context).size.width * 0.5;
      var phoneWidth=MediaQuery.of(context).size.width * 0.9;
      return SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: PreferredSize(
            preferredSize: const Size(300, 120),
            child: CustomAppbar(text: constValue.comments),
          ),
          bottomSheet: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.8,height: 50,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.9,
                    child: TextFormField(
                      // maxLines: maxLine,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        controller:custProvider.disPoint,
                        decoration: customStyle.inputDecoration(text: "Type a comment", fieldClr: Colors.white,radius: 50)
                    ),
                  ),
                ),
                SizedBox(
                  height: 45,
                  width: 45,
                  child: RoundedLoadingButton(
                      borderRadius: 30,
                      color: colorsConst.primary,
                      successColor: colorsConst.primary,
                      valueColor: Colors.white,
                      onPressed: (){
                        if(custProvider.disPoint.text.trim().isEmpty){
                          utils.showWarningToast(context, text: "Type a comment");
                          custProvider.addCtr.reset();
                        }else{
                          custProvider.tComment(context: context,taskId: widget.taskId.toString(), assignedId: widget.assignedId.toString());
                        }
                      },
                      controller: custProvider.addCtr,
                      child: const Icon(Icons.send)
                  ),
                )
              ],
            ),
          ),
          body: custProvider.refresh==false?
          const Loading():
          custProvider.customerReport.isEmpty?
          const Center(child: CustomText(text: "No Comments Found",size: 15,))
              :ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: custProvider.customerReport.length,
            itemBuilder: (context, index) {
              CustomerReportModel data = custProvider.customerReport[index];
              var createdBy = "";
              String timestamp = data.createdTs.toString();
              DateTime dateTime = DateTime.parse(timestamp);
              String dayOfWeek = DateFormat('EEEE').format(dateTime);
              DateTime today = DateTime.now();
              if (dateTime.day == today.day && dateTime.month == today.month && dateTime.year == today.year) {
                dayOfWeek = 'Today';
              } else if (dateTime.isAfter(today.subtract(const Duration(days: 1))) &&
                  dateTime.isBefore(today)) {
                dayOfWeek = 'Yesterday';
              } else {
                dayOfWeek = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
              }
              createdBy = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
              final showDateHeader = index == 0 || createdBy != getCreatedDate(custProvider.customerReport[index - 1]);
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showDateHeader==true)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: CustomText(text:dayOfWeek),
                    ),
                  Align(
                    alignment:custProvider.customerReport[index].createdBy==localData.storage.read("id") ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: custProvider.customerReport[index].createdBy==localData.storage.read("id") ? colorsConst.primary : colorsConst.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        // border: Border.all(
                        //   color: custProvider.customerReport[index].createdBy==localData.storage.read("id") ? Colors.grey.shade300 : Colors.grey.shade300,
                        // ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if(custProvider.customerReport[index].createdBy!=localData.storage.read("id"))
                            Row(
                              children: [
                                CustomText(text:custProvider.customerReport[index].firstname.toString(),colors: colorsConst.primary,),
                                CustomText(text:" ( ${custProvider.customerReport[index].role} )",colors: colorsConst.greyClr,),
                              ],
                            ),
                          CustomText(text:custProvider.customerReport[index].comments.toString(),colors: custProvider.customerReport[index].createdBy!=localData.storage.read("id") ?Colors.black:Colors.white,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomText(text:DateFormat('hh:mm a').format(DateTime.parse(data.createdTs.toString())),size: 10,colors: custProvider.customerReport[index].createdBy!=localData.storage.read("id") ?Colors.black:Colors.white,),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
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



