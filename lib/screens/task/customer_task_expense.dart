import 'package:master_code/source/utilities/utils.dart';
import 'package:master_code/view_model/expense_provider.dart';
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

class CustomerTaskExpense extends StatefulWidget {
  final String id;
  final String date1;
  final String date2;
  final String name;
  const CustomerTaskExpense({super.key, required this.id, required this.date1, required this.date2, required this.name});

  @override
  State<CustomerTaskExpense> createState() => _CustomerTaskExpenseState();
}

class _CustomerTaskExpenseState extends State<CustomerTaskExpense> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).getCustomerTaskExpense(widget.id,widget.date1,widget.date2);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.95;
    return Consumer<ExpenseProvider>(builder: (context,expProvider,_){
      return SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
            appBar: const PreferredSize(
              preferredSize: Size(300, 50),
              child: CustomAppbar(text: "Task Expense Report"),
            ),
          body: Center(
            child: SizedBox(
              width: kIsWeb?webWidth:phoneWidth,
              // color: Colors.red,
              child:  expProvider.refresh==false?
              const Loading():
              Column(
                children: [
                  CustomText(text: "${widget.name}\n"),
                  expProvider.expenseData.isEmpty ?
                  Column(
                    children: [
                      100.height,
                      CustomText(text: "No Expense Found",
                          colors: colorsConst.greyClr)
                    ],
                  ):
                  Expanded(
                    child: ListView.builder(
                        itemCount: expProvider.expenseData.length,
                        itemBuilder: (context, index) {
                          var createdBy = "";
                          String timestamp = expProvider.expenseData[index].createdTs.toString();
                          DateTime dateTime = DateTime.parse(timestamp);
                          DateFormat('EEEE').format(dateTime);
                          DateTime today = DateTime.now();
                          if (dateTime.day == today.day && dateTime.month == today.month && dateTime.year == today.year) {
                          } else if (dateTime.isAfter(today.subtract(const Duration(days: 1))) &&
                              dateTime.isBefore(today)) {
                          } else {
                          }
                          createdBy = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                          return InkWell(
                            // onTap: (){
                            //   utils.navigatePage(context, ()=> DashBoard(child: ExpenseDetails(visitId: expProvider.expenseData[index].taskTitle.toString(), isExpense: false,companyId: "", id: expProvider.expenseData[index].id.toString(),
                            //       name: expProvider.expenseData[index].firstname.toString(), role: expProvider.expenseData[index].role.toString(),
                            //       customer: expProvider.expenseData[index].projectName.toString(), purpose: expProvider.expenseData[index].taskTitle.toString())));
                            // },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: Column(
                                children: [
                                  Container(
                                    width: kIsWeb?webWidth:phoneWidth,
                                    decoration: customDecoration.baseBackgroundDecoration(
                                        color: Colors.white,radius: 10
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // expProvider.expenseData[index].projectName.toString()!="null"?
                                              // Row(
                                              //   children: [
                                              //     const CustomText(text: "Task : ",colors: Colors.grey),
                                              //     CustomText(text: expProvider.expenseData[index].projectName.toString(),colors: colorsConst.bankColor),
                                              //   ],
                                              // ):
                                              CustomText(text: expProvider.expenseData[index].status.toString()=="0"?"Rejected":expProvider.expenseData[index].status.toString()=="2"?"Approved":"In Process",
                                                  colors: expProvider.expenseData[index].status.toString()=="0"?colorsConst.appRed:expProvider.expenseData[index].status.toString()=="2"?colorsConst.appDarkGreen:Colors.grey,isItalic: true),
                                              CustomText(text: createdBy,colors: Colors.grey,),
                                            ],
                                          ),
                                          5.height,
                                          if(expProvider.expenseData[index].projectName.toString()!="null")
                                          SizedBox(
                                              width: kIsWeb?webWidth:phoneWidth,
                                              child: CustomText(text: expProvider.expenseData[index].taskTitle.toString(),colors: colorsConst.greyClr)),
                                          5.height,
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              if(expProvider.expenseData[index].firstname.toString()!="null")
                                                CustomText(text: expProvider.expenseData[index].firstname.toString(),),
                                              // CustomText(text: data.placeVisited.toString(),),
                                              CustomText(text: "₹ ${utils.formatNo(expProvider.expenseData[index].amount.toString())}",colors: colorsConst.appRed,isBold: true,),
                                            ],
                                          ),
                                          if(expProvider.expenseData[index].status.toString()=="2")
                                            5.height,
                                          if(expProvider.expenseData[index].status.toString()=="2")
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const CustomText(text: "Approved Amount : ",colors: Colors.blueGrey,),
                                                    CustomText(text: "₹ ${expProvider.expenseData[index].approvalAmt.toString()!=""&&expProvider.expenseData[index].approvalAmt.toString()!="null"?
                                                    utils.formatNo(expProvider.expenseData[index].approvalAmt.toString()):"0"}",colors: colorsConst.appOrg,isBold: true,),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const CustomText(text: "Paid Amount : ",colors: Colors.blueGrey,),
                                                    CustomText(text: "₹ ${expProvider.expenseData[index].paidAmt.toString()!=""&&expProvider.expenseData[index].paidAmt.toString()!="null"?
                                                    utils.formatNo(expProvider.expenseData[index].paidAmt.toString()):"0"}",colors: colorsConst.appGreen,isBold: true,),
                                                  ],
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if(index==expProvider.expenseData.length-1)
                                    80.height
                                ],
                              ),
                            ),
                          );
                          // :0.width;
                        }),
                  ),
                ],
              ),
            ),
          )
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










