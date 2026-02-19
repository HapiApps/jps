import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/source/constant/default_constant.dart';
import 'package:master_code/view_model/expense_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/animated_button.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_dropdown.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../component/map_dropdown.dart';
import '../../component/search_drop_down.dart';
import '../../model/customer/customer_model.dart';
import '../../model/expense_model.dart';
import '../../model/user_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/customer_provider.dart';
import '../../view_model/employee_provider.dart';
import '../common/dashboard.dart';
import 'expense_details.dart';


class ViewExpense extends StatefulWidget {
  final String date1;
  final String date2;
  final String type;
  final bool tab;
  const ViewExpense({super.key,required this.date1, required this.date2,required this.type, required this.tab, });

  @override
  State<ViewExpense> createState() => _ViewExpenseState();
}

class _ViewExpenseState extends State<ViewExpense> with SingleTickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<ExpenseProvider>(context, listen: false).changeDate();
      Provider.of<ExpenseProvider>(context, listen: false).getAllExpense(date1:widget.date1,date2:widget.date2);
      Provider.of<ExpenseProvider>(context, listen: false).filterList();
      Provider.of<ExpenseProvider>(context, listen: false).initFilterValue(false);
      Provider.of<ExpenseProvider>(context, listen: false).initExpenseValue(widget.date1,widget.date2,widget.type);
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
    var webHeight=MediaQuery.of(context).size.width * 0.5;
    var phoneHeight=MediaQuery.of(context).size.width * 0.9;
    return Consumer<ExpenseProvider>(builder: (context,expProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
              appBar:widget.tab==false? PreferredSize(
                preferredSize: Size(300, 50),
                child: CustomAppbar(text: "View Expense"),
              ):null,
              backgroundColor: colorsConst.bacColor,
              body: Center(
                child: SizedBox(
                  width: kIsWeb?webHeight:phoneHeight,
                  // color: Colors.red,
                  child: expProvider.refresh==false?
                  const Loading():
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextField(
                            controller: expProvider.search,radius: 30,
                            width: kIsWeb?webHeight/1.3:phoneHeight/1.3,
                            text: "",
                            isIcon: true,hintText: "Search Name or Company",
                            iconData: Icons.search,
                            textInputAction: TextInputAction.done,
                            onChanged: (value) {
                              expProvider.searchExpense(value.toString());
                            },
                            isSearch: expProvider.search.text.isNotEmpty?true:false,
                            searchCall: (){
                              expProvider.search.clear();
                              expProvider.searchExpense("");
                            },
                          ),
                          InkWell(
                            onTap: (){
                              _myFocusScopeNode.unfocus();
                              print(expProvider.stList);
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Consumer3<ExpenseProvider,CustomerProvider,EmployeeProvider>(
                                    builder: (context, expProvider,cusPvr,empProvider, _) {
                                      return AlertDialog(
                                        actions: [
                                          SizedBox(
                                            width: kIsWeb?MediaQuery.of(context).size.width*0.3:MediaQuery.of(context).size.width*0.9,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                20.height,
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    70.width,
                                                    const CustomText(
                                                      text: 'Filters',
                                                      colors: Colors.black,
                                                      size: 16,
                                                      isBold: true,
                                                    ),
                                                    30.width,
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.of(context, rootNavigator: true).pop();
                                                      },
                                                      child: SvgPicture.asset(assets.cancel),
                                                    )
                                                  ],
                                                ),
                                                20.height,
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText(
                                                          text: "From Date",
                                                          colors: colorsConst.greyClr,
                                                          size: 12,
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            expProvider.filterPick(
                                                              context: context,
                                                              isStartDate: true,
                                                            );
                                                          },
                                                          child: Container(
                                                            height: 30,
                                                            width: kIsWeb?MediaQuery.of(context).size.width*0.14:MediaQuery.of(context).size.width * 0.35,
                                                            decoration: customDecoration.baseBackgroundDecoration(
                                                              color: Colors.white,
                                                              radius: 5,
                                                              borderColor: colorsConst.litGrey,
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                CustomText(text: expProvider.startDate),
                                                                5.width,
                                                                SvgPicture.asset(assets.calendar2),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText(
                                                          text: "To Date",
                                                          colors: colorsConst.greyClr,
                                                          size: 12,
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            expProvider.filterPick(
                                                              context: context,
                                                              isStartDate: false,
                                                            );
                                                          },
                                                          child: Container(
                                                            height: 30,
                                                            width: kIsWeb?MediaQuery.of(context).size.width*0.14:MediaQuery.of(context).size.width * 0.35,
                                                            decoration: customDecoration.baseBackgroundDecoration(
                                                              color: Colors.white,
                                                              radius: 5,
                                                              borderColor: colorsConst.litGrey,
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                CustomText(text: expProvider.endDate),
                                                                5.width,
                                                                SvgPicture.asset(assets.calendar2),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                10.height,
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: "Select Date Range",
                                                      colors: colorsConst.greyClr,
                                                      size: 12,
                                                    ),
                                                    Container(
                                                      height: 30,
                                                      width: kIsWeb?MediaQuery.of(context).size.width*0.29:MediaQuery.of(context).size.width * 0.72,
                                                      decoration: customDecoration.baseBackgroundDecoration(
                                                        radius: 5,
                                                        color: Colors.white,
                                                        borderColor: colorsConst.litGrey,
                                                      ),
                                                      child: DropdownButton(
                                                        iconEnabledColor: colorsConst.greyClr,
                                                        isExpanded: true,
                                                        underline: const SizedBox(),
                                                        icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                                        value: expProvider.filterType,
                                                        onChanged: (value) {
                                                          expProvider.changeFilterType(value);
                                                        },
                                                        items: expProvider.filterTypeList.map((list) {
                                                          return DropdownMenuItem(
                                                            value: list,
                                                            child: CustomText(
                                                              text: "  $list",
                                                              colors: Colors.black,
                                                              isBold: false,
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                10.height,
                                                CustomDropDown(
                                                  color: Colors.white,
                                                  text: constValue.status,saveValue: expProvider.type,
                                                  valueList: expProvider.stList,
                                                  onChanged: (value) {
                                                    expProvider.checkFilterType(value);
                                                  },
                                                ),
                                                CustomText(
                                                  text: constValue.companyName,
                                                  colors: colorsConst.greyClr,
                                                  size: 12,
                                                ),
                                                // 2.height,
                                                CustomerDropdown(
                                                  text: expProvider.companyName==""?constValue.companyName:expProvider.companyName,
                                                  isRequired: true,hintText: false,
                                                  employeeList: cusPvr.customer,
                                                  onChanged: (CustomerModel? value) {
                                                    expProvider.changeName(value);
                                                  }, size: kIsWeb?webHeight:phoneHeight,),
                                                10.height,
                                                CustomText(
                                                  text: "Employee Name",
                                                  colors: colorsConst.greyClr,
                                                  size: 12,
                                                ),
                                                EmployeeDropdown(
                                                    callback: (){
                                                    },
                                                    text: expProvider.userName==""?"Name":expProvider.userName,
                                                    employeeList: empProvider.activeEmps,
                                                    onChanged: (UserModel? value) {
                                                      expProvider.selectUser(value!);
                                                    },
                                                    size: kIsWeb?webHeight:phoneHeight),
                                                20.height,
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    CustomBtn(
                                                      width: 100,
                                                      text: 'Clear All',
                                                      callback: () {
                                                        expProvider.initFilterValue(true);
                                                        Navigator.of(context, rootNavigator: true).pop();
                                                      },
                                                      bgColor: Colors.grey.shade200,
                                                      textColor: Colors.black,
                                                    ),
                                                    CustomBtn(
                                                      width: 100,
                                                      text: 'Apply Filters',
                                                      callback: () {
                                                        expProvider.initFilterValue(false);
                                                        expProvider.filterList();
                                                        Navigator.of(context, rootNavigator: true).pop();
                                                      },
                                                      bgColor: colorsConst.primary,
                                                      textColor: Colors.white,
                                                    ),
                                                  ],
                                                ),
                                                20.height,
                                              ],
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: Container(
                              width: kIsWeb?webHeight/5:phoneHeight/5,
                              height: 45,
                              decoration: customDecoration.baseBackgroundDecoration(
                                  color: expProvider.isFilter==true?colorsConst.primary:Colors.grey.shade300,radius: 5
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: SvgPicture.asset(assets.filter,width: 15,height: 15,),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                              onTap: () {
                                expProvider.showDatePickerDialog(context);
                              },
                              child: Container(
                                height: 45,
                                width: kIsWeb?webHeight/2:phoneHeight/1.8,
                                decoration: customDecoration.baseBackgroundDecoration(
                                    color: Colors.white,
                                    radius: 5,borderColor: Colors.grey.shade200
                                ),
                                child: Row(
                                  children: [
                                    5.width,
                                    CustomText(
                                        text: "${expProvider.startDate}${expProvider.startDate!=expProvider.endDate? " To ${expProvider.endDate}": ""}"),
                                  ],
                                ),
                              )),
                          CustomLoadingButton(callback: (){
                            expProvider.downloadCtr.reset();
                            expProvider.downloadAllExpense(context);
                          }, text: "Download", isLoading: false,controller: expProvider.downloadCtr,
                              backgroundColor: colorsConst.primary, radius: 5, width: kIsWeb?webHeight/2:phoneHeight/3)
                        ],
                      ),
                      5.height,
                      // if(expProvider.filterExpenseData.isNotEmpty)
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     CustomRadioButton(text: "Date",
                      //         onChanged: (value){
                      //           expProvider.changeFilter(value.toString());
                      //           expProvider.filterExpenseData.sort((a, b) =>
                      //               DateTime.parse(a.createdTs.toString()).compareTo(DateTime.parse(b.createdTs.toString())));
                      //         },
                      //         saveValue: expProvider.filter, confirmValue: "1"),
                      //     CustomRadioButton(text: constValue.customer,
                      //         onChanged: (value){
                      //           expProvider.changeFilter(value.toString());
                      //           // expProvider.filterExpenseData.sort((a, b) =>
                      //           //     a.projectName!.compareTo(b.projectName.toString()));
                      //           expProvider.filterExpenseData.sort((a, b) =>
                      //               (a.projectName ?? '').compareTo(b.projectName ?? ''));
                      //         },
                      //         saveValue: expProvider.filter, confirmValue: "2"),
                      //     CustomRadioButton(text: "Amount",
                      //         onChanged: (value){
                      //           expProvider.changeFilter(value.toString());
                      //           expProvider.filterExpenseData.sort((a, b) {
                      //             double amtA = double.tryParse(a.amount.toString().replaceAll(",", "")) ?? 0;
                      //             double amtB = double.tryParse(b.amount.toString().replaceAll(",", "")) ?? 0;
                      //             return amtA.compareTo(amtB); // A to Z (ascending)
                      //           });
                      //         },
                      //         saveValue: expProvider.filter, confirmValue: "3"),
                      //     CustomDropDown(text: "Status", valueList: expProvider.stList,width: 110,isHint: true,
                      //         saveValue: expProvider.status,
                      //         onChanged: (value){
                      //           expProvider.changeStatus(value);
                      //         }),
                      //   ],
                      // ),
                      expProvider.filterExpenseData.isEmpty||(expProvider.status!=null&&expProvider.matched==0) ?
                      Column(
                        children: [
                          100.height,
                          CustomText(text: "No Expense Found",
                              colors: colorsConst.greyClr)
                        ],
                      ) :
                      Expanded(
                        child: ListView.builder(
                            itemCount: expProvider.filterExpenseData.length,
                            itemBuilder: (context, index) {
                              final sortedData = expProvider.filterExpenseData;
                              final data = sortedData[index];
                              var createdBy = "";
                              String timestamp = data.createdTs.toString();
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
                                onTap: (){
                                  _myFocusScopeNode.unfocus();
                                  utils.navigatePage(context, ()=> DashBoard(child: ExpenseDetails(visitId: '0', isExpense: true,companyId: "", id: data.id.toString(),
                                    name: data.firstname.toString(), role: data.role.toString(),
                                    customer: data.projectName.toString(), purpose: data.taskTitle.toString(),)));
                                },
                                child: Column(
                                  children: [
                                    // if(index==0)
                                    //   const Padding(
                                    //     padding: EdgeInsets.all(8.0),
                                    //     child: Row(
                                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //       children: [
                                    //         CustomText(text: "Employee Name",colors: Colors.grey,),
                                    //         CustomText(text: "Visited Place",colors: Colors.grey,),
                                    //         CustomText(text: "Total Amount",colors: Colors.grey,),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // _status=="Rejected"&&expenseData[i].status=="0"
                                    expProvider.status==null?
                                    detail(createdBy: createdBy,data: data)
                                        :expProvider.status=="Rejected"&&data.status=="0"?
                                    detail(createdBy: createdBy,data: data)
                                        :expProvider.status=="Approved"&&data.status=="2"?
                                    detail(createdBy: createdBy,data: data)
                                        :expProvider.status=="In Process"&&data.status=="1"?
                                    detail(createdBy: createdBy,data: data):0.height,
                                    if(index==expProvider.filterExpenseData.length-1)
                                      80.height
                                  ],
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
        ),
      );
    });
  }
  String getCreatedDate(data) {
    final timestamp = data.createdTs.toString();
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
  Widget detail({required String createdBy, required ExpenseModel data}){
    var webHeight=MediaQuery.of(context).size.width * 0.5;
    var phoneHeight=MediaQuery.of(context).size.width * 0.9;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Container(
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
                  data.projectName.toString()!="null"?
                  Row(
                    children: [
                      const CustomText(text: "Task : ",colors: Colors.grey),
                      CustomText(text: data.projectName.toString(),colors: colorsConst.bankColor),
                    ],
                  ):
                  CustomText(text: data.status.toString()=="0"?"Rejected":data.status.toString()=="2"?"Approved":"In Process",
                    colors: data.status.toString()=="0"?colorsConst.appRed:data.status.toString()=="2"?colorsConst.appDarkGreen:Colors.grey,isItalic: true,),
                  CustomText(text: createdBy,colors: Colors.grey,),
                ],
              ),
              5.height,
              if(data.projectName.toString()!="null")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      // color: Colors.pinkAccent,
                        width: kIsWeb?webHeight/2:phoneHeight/1.4,
                        child: CustomText(text: data.taskTitle.toString(),colors: colorsConst.greyClr)),
                    CustomText(text: data.status.toString()=="0"?"Rejected":data.status.toString()=="2"?"Approved":"In Process",
                      colors: data.status.toString()=="0"?colorsConst.appRed:data.status.toString()=="2"?colorsConst.appDarkGreen:Colors.grey,isItalic: true,),
                  ],
                ),
              5.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(text: data.firstname.toString(),),
                  // CustomText(text: data.placeVisited.toString(),),
                  CustomText(text: "₹ ${utils.formatNo(data.amount.toString())}",colors: colorsConst.primary,isBold: true,),
                ],
              ),
              if(data.status.toString()=="2")
                5.height,
              if(data.status.toString()=="2")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CustomText(text: "Approved Amount : ",colors: Colors.blueGrey,),
                        CustomText(text: "₹ ${data.approvalAmt.toString()!=""&&data.approvalAmt.toString()!="null"?
                        utils.formatNo(data.approvalAmt.toString()):"0"}",colors: colorsConst.appOrg,isBold: true,),
                      ],
                    ),
                    Row(
                      children: [
                        const CustomText(text: "Paid Amount : ",colors: Colors.blueGrey,),
                        CustomText(text: "₹ ${data.paidAmt.toString()!=""&&data.paidAmt.toString()!="null"?
                        utils.formatNo(data.paidAmt.toString()):"0"}",colors: colorsConst.appGreen,isBold: true,),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}









