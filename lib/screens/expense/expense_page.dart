import 'package:master_code/screens/expense/view_expense.dart';
import 'package:master_code/view_model/expense_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_code/view_model/home_provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_text.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../common/dashboard.dart';
import '../common/home_page.dart';
import 'expense_dashboard.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> with SingleTickerProviderStateMixin {
  late TabController tabController;
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      _myFocusScopeNode.unfocus();
    });
    Future.delayed(Duration.zero, () {
      if(kIsWeb){
        Provider.of<ExpenseProvider>(context, listen: false).getExpenseType();
      }else{
        Provider.of<ExpenseProvider>(context, listen: false).getTypesOfExpense();
      }
    });
    super.initState();
  }
  @override
  void dispose() {
    tabController.dispose();
    _myFocusScopeNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer2<ExpenseProvider,HomeProvider>(builder: (context,expProvider,homeProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
              backgroundColor: colorsConst.bacColor,
              appBar: PreferredSize(
                preferredSize: const Size(300, 50),
                child: CustomAppbar(text: "All Expenses",callback: (){
                  _myFocusScopeNode.unfocus();
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
                    width: kIsWeb?webWidth:phoneWidth,
                    // color: Colors.red,
                    child: Column(
                      children: [
                        20.height,
                        Container(
                            height: 40,
                            decoration: customDecoration.baseBackgroundDecoration(
                                color: Colors.transparent,
                                radius: 5
                            ),
                            child: TabBar(
                              controller: tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicatorWeight: 0,
                              indicator: customDecoration.baseBackgroundDecoration(
                                  color: Colors.white,
                                  borderColor: colorsConst.primary,
                                  radius: 5
                              ),
                              labelColor: Colors.green,
                              unselectedLabelColor: Colors.green,
                              tabs:  const [
                                Tab(child:CustomText(text: "Report")),
                                Tab(child:CustomText(text: "Expense Details")),
                              ],
                            )
                        ),
                        Expanded(
                          child: TabBarView(
                              controller: tabController,
                              children: [
                                ExpenseDashboard(),
                                ViewExpense(date1: homeProvider.startDate, date2: homeProvider.endDate,type: homeProvider.type,tab:true),
                              ]),
                        )
                      ],
                    ),
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
}










