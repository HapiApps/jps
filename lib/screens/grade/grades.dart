import 'package:master_code/component/custom_textfield.dart';
import 'package:master_code/screens/grade/grade_policy.dart';
import 'package:master_code/source/constant/key_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/create_button.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/employee_provider.dart';
import '../common/dashboard.dart';

class Grades extends StatelessWidget {
  const Grades({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size(300, 50),
          child: CustomAppbar(text: "Grades & Expense Policy"),
        ),
        backgroundColor: colorsConst.bacColor,
        body: Column(
          children: [
            Container(
                height: 40,
                decoration: customDecoration.baseBackgroundDecoration(
                    color: Colors.transparent,
                    radius: 10
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 0,
                  indicator: customDecoration.baseBackgroundDecoration(
                      color: Colors.white,
                      radius: 5,
                    borderColor: colorsConst.primary
                  ),
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.green,
                  tabs:  const [
                    Tab(child: SizedBox(
                      width: 100,height: 80,
                        child: Center(child: CustomText(text: "Grades"))),
                    ),
                    Tab(child:SizedBox(
                        width: 100,height: 80,
                        child: Center(child: CustomText(text: "Amount")))),
                  ],
                )
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  EmployeesGrades(),
                  AllGrade()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}






class EmployeesGrades extends StatefulWidget {
  const EmployeesGrades({super.key});

  @override
  State<EmployeesGrades> createState() => _EmployeesGradesState();
}

class _EmployeesGradesState extends State<EmployeesGrades>{
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<EmployeeProvider >(context, listen: false).getGrades(true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer<EmployeeProvider>(builder: (context,empProvider,_){
      return SafeArea(
        child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            body: Center(
              child: SizedBox(
                width: kIsWeb?webWidth:phoneWidth,
                // color: Colors.red,
                child:
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CreateButton(
                          callback: () {
                            utils.navigatePage(context, ()=>const DashBoard(child: AddGrade()));
                          },
                        ),
                      ],
                    ),
                    empProvider.refresh==false?
                    Column(
                      children: [
                        100.height,
                        const Loading()
                      ],
                    ) :empProvider.gradeValues.isEmpty ?
                    Column(
                      children: [
                        100.height,
                        CustomText(text: "No Grades Found", colors: colorsConst.greyClr)
                      ],
                    ) :
                    Expanded(
                      child: ListView.builder(
                          itemCount: empProvider.gradeValues.length,
                          itemBuilder: (context, index) {
                            final sortedData = empProvider.gradeValues;
                            final employeeData = sortedData[index];
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: ListTile(
                                title: CustomText(text: employeeData["grade"].toString(),colors: Colors.grey),
                                tileColor: Colors.white,
                                trailing: IconButton(onPressed: (){
                                  utils.customDialog(
                                      context: context,
                                      isLoading: true,
                                      title: 'Do you want to',
                                      title2: 'Delete the grade?',
                                      roundedLoadingButtonController: empProvider.signCtr,
                                      callback: () {
                                        empProvider.deletedGrade(context,id:employeeData["id"].toString());
                                      }
                                  );
                                }, icon: SvgPicture.asset(assets.deleteValue)),
                              ),
                            );
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
}


class AddGrade extends StatefulWidget {
  const AddGrade({super.key});

  @override
  State<AddGrade> createState() => _AddGradeState();
}

class _AddGradeState extends State<AddGrade>{
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<EmployeeProvider>(context, listen: false).gradeCtr.clear();
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
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer<EmployeeProvider>(builder: (context,empProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
              backgroundColor: colorsConst.bacColor,
              appBar: const PreferredSize(
                preferredSize: Size(300, 50),
                child: CustomAppbar(text: "Add Grades"),
              ),
              body: Center(
                child: SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  // color: Colors.red,
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextField(
                          width: kIsWeb?webWidth:phoneWidth,
                          isRequired: true,
                          textInputAction: TextInputAction.done,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: constInputFormatters.numTextInput,
                          text: "Grades", controller: empProvider.gradeCtr),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomLoadingButton(
                              callback: (){
                                Future.microtask(() => Navigator.pop(context));
                              }, isLoading: false,text: "Cancel",
                              backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                              width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                          CustomLoadingButton(
                              callback: (){
                                if (empProvider.gradeCtr.text.trim().isEmpty) {
                                  utils.showWarningToast(context,
                                      text: "Please fill grade");
                                  empProvider.signCtr.reset();
                                }else {
                                  _myFocusScopeNode.unfocus();
                                  empProvider.addEmpGrade(context);
                                }
                              }, isLoading: true,text: "Save",controller: empProvider.signCtr,
                              backgroundColor: colorsConst.primary,radius: 10,
                              width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                        ],
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
}










