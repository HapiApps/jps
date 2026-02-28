import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class CommentChat extends StatefulWidget {
  final String visitId;
  final String companyName;
  final List numberList;
  final String companyId;
  final String createdBy;
  const CommentChat({super.key, required this.visitId, required this.companyName, required this.numberList, required this.companyId, required this.createdBy});

  @override
  State<CommentChat> createState() => _CommentChatState();
}

class _CommentChatState extends State<CommentChat> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<CustomerProvider>(context, listen: false).disPoint.clear();
      Provider.of<CustomerProvider>(context, listen: false).getComments(widget.visitId);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(builder: (context,custProvider,_){
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
                        decoration: customStyle.inputDecoration(text: "Type a comment", fieldClr: Colors.white)
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
                          custProvider.addComment(context: context,visitId: widget.visitId.toString(),path: "",
                              companyName: widget.companyName,companyId: widget.companyId, numberList: widget.numberList, taskId: "0", createdBy: widget.createdBy, assignedId: '');
                          // custProvider.addComment(context: context,companyId: widget.visitId.toString(), type: custProvider.selectType.toString());
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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        color: custProvider.customerReport[index].createdBy==localData.storage.read("id") ? Colors.white : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: CustomText(text:custProvider.customerReport[index].comments.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomText(text:DateFormat('hh:mm a').format(DateTime.parse(data.createdTs.toString())),size: 10,),
                              ],
                            ),
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



