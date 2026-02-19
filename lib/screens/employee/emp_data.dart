import 'package:master_code/screens/employee/update_employee.dart';
import 'package:master_code/screens/employee/view_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:master_code/source/extentions/extensions.dart';
import '../../component/custom_text.dart';
import '../../component/dotted_border.dart';
import '../../model/user_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/employee_provider.dart';
import '../common/dashboard.dart';
import 'employee_details.dart';

class EmpData extends StatelessWidget {
  final bool showDateHeader;
  final UserModel employeeData;
  final String dayOfWeek;
  final FocusScopeNode focusScope;
  const EmpData({super.key, required this.showDateHeader, required this.employeeData, required this.dayOfWeek, required this.focusScope});

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width*0.5;
    var phoneWidth=MediaQuery.of(context).size.width*0.9;
    return Consumer<EmployeeProvider>(builder: (context,empProvider,_){
      return Column(
        children: [
          if (showDateHeader==true)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: CustomText(
                text: dayOfWeek,
                colors: colorsConst.greyClr,
              ),
            ),
          InkWell(
            onTap:employeeData.active.toString()=="2"?null:(){
              focusScope.unfocus();
              utils.navigatePage(context, ()=> DashBoard(child: EmployeeDetails(id:employeeData.id.toString(),active:employeeData.active.toString(),role:employeeData.roleName.toString())));
            },
            child: Container(
              width: kIsWeb?webWidth:phoneWidth,
              decoration: customDecoration
                  .baseBackgroundDecoration(
                  color: employeeData.active.toString()=="1"?Colors.white:Colors.grey.shade200,
                  borderColor: employeeData.active.toString()=="1"?Colors.grey.shade200:Colors.grey.shade300,
                  isShadow: true,
                  shadowColor: Colors.grey.shade200,
                  radius: 10
              ),
              child: Column(
                children: [
                  Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colorsConst.appDarkGreen,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                            ),
                          ),width: 8,height: 10,),
                        Row(
                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width:kIsWeb?webWidth/3.5:phoneWidth/3.5,
                              // color:Colors.pink,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: CustomText(
                                  text: employeeData.firstname.toString(),
                                  colors: employeeData.active.toString()=="2"?Colors.grey:colorsConst.primary,
                                  isBold: true,),
                              ),
                            ),
                            SizedBox(
                              // color:Colors.yellow,
                              width:kIsWeb?webWidth/3.5:phoneWidth/3.5,
                              child: CustomText(
                                text: employeeData.roleName.toString(),
                                colors: employeeData.active.toString()=="2"?Colors.grey:Colors.black,
                              ),
                            ),
                            SizedBox(
                              // color: Colors.pinkAccent,
                              width:kIsWeb?webWidth/3.5:phoneWidth/3.5,
                              child: CustomText(
                                text: employeeData.mobileNumber.toString(),
                                colors: employeeData.active.toString()=="2"?Colors.grey:Colors.black,),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(onTap: employeeData.active.toString()=="2"?null:(){
                                utils.makingPhoneCall(ph: employeeData.mobileNumber.toString(),);
                              }, child: SvgPicture.asset(employeeData.active.toString()=="1"?assets.call:assets.call2)),
                            )
                          ],
                        ),
                        Positioned(
                            child: SvgPicture.asset(employeeData.active.toString()=="1"?assets.active:assets.inactive))
                      ]
                  ),
                  const DotLine(),
                  Row(
                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: employeeData.active.toString()=="2"?null:(){
                          focusScope.unfocus();
                          if(employeeData.id==localData.storage.read("id")){
                            utils.customDialog(
                                context: context,
                                title: "Editing an Admin account,proceed\n        with caution. After editing\n          Re-login will be required.",
                                title2:"Do you want to continue?",
                                callback: (){
                                  Navigator.pop(context);
                                  // homeProvider.showType(2);
                                  // homeProvider.changeList(id:employeeData.id);
                                  utils.navigatePage(context, ()=> DashBoard(child: UpdatedEmployee(id: employeeData.id.toString(), isDetailView: false)));
                                },
                                isLoading: false,roundedLoadingButtonController: empProvider.signCtr);
                          }else{
                            utils.navigatePage(context, ()=> DashBoard(child: UpdatedEmployee(id: employeeData.id.toString(), isDetailView: false)));
                          }
                        },
                        child: SizedBox(
                          // color: Colors.blueGrey,
                          height: 30,
                          width:kIsWeb?webWidth/3.5:phoneWidth/3.5,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 5, 0, 0),
                            child: CustomText(text: "Edit",colors: employeeData.active.toString()=="2"?colorsConst.blueClr.withOpacity(0.4):colorsConst.blueClr,isBold: true),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: employeeData.active.toString()=="2"?null:(){
                          focusScope.unfocus();
                          utils.navigatePage(context, ()=> DashBoard(child: ViewLog(id: employeeData.id.toString())));
                        },
                        child: SizedBox(
                          height: 30,
                          // color: Colors.blue,
                          width:kIsWeb?webWidth/3.5:phoneWidth/3.5,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: CustomText(text: "View Activities",colors: employeeData.active.toString()=="2"?Colors.orange.shade200:Colors.orange,isBold: true),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          focusScope.unfocus();
                          if(employeeData.id==localData.storage.read("id")){
                            utils.customDialog(
                                context: context,
                                title: "Editing an Admin account,proceed\n        with caution. After editing\n          Re-login will be required.",
                                title2:"Do you want to continue?",
                                callback: (){
                                  Navigator.pop(context);
                                  empProvider.deleteReason.clear();
                                  utils.editDialog(
                                      context: context,
                                      name: employeeData.firstname,
                                      role: employeeData.roleName,
                                      reason: employeeData.active.toString()=="1"?"Deactivation":"Activate",
                                      title: 'Do you want to',
                                      title2: '${employeeData.active.toString()=="1"?"Deactivate":"Activate"} this employee?',
                                      roundedLoadingButtonController: empProvider.signCtr,
                                      textEditCtr: empProvider.deleteReason,
                                      callback: () {
                                        if(empProvider.deleteReason.text.trim().isEmpty){
                                          utils.showWarningToast(context, text: "Type a reason");
                                          empProvider.signCtr.reset();
                                        }else{
                                          focusScope.unfocus();
                                          empProvider.empActive(context,userId: employeeData.id.toString(), active: employeeData.active.toString()=="1"?'2':'1');
                                        }
                                      }
                                  );
                                },
                                isLoading: false,roundedLoadingButtonController: empProvider.signCtr);
                          }
                          else{
                            empProvider.deleteReason.clear();
                            utils.editDialog(
                                context: context,
                                name: employeeData.firstname,
                                role: employeeData.roleName,
                                reason: employeeData.active.toString()=="1"?"Deactivation":"Activate",
                                title: 'Do you want to',
                                title2: '${employeeData.active.toString()=="1"?"Deactivate":"Activate"} this employee?',
                                roundedLoadingButtonController: empProvider.signCtr,
                                textEditCtr: empProvider.deleteReason,
                                callback: () {
                                  if(empProvider.deleteReason.text.trim().isEmpty){
                                    utils.showWarningToast(context, text: "Type a reason");
                                    empProvider.signCtr.reset();
                                  }else{
                                    focusScope.unfocus();
                                    empProvider.empActive(context,userId: employeeData.id.toString(), active: employeeData.active.toString()=="1"?'2':'1');
                                  }
                                }
                            );
                          }
                        },
                        child: SizedBox(
                          height: 30,
                          // color: Colors.pinkAccent,
                          width:kIsWeb?webWidth/3.5:phoneWidth/3.5,
                          child: InkWell( child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: CustomText(text: employeeData.active.toString()=="1"?"Make Inactive":"Make Active",
                                colors: employeeData.active.toString()=="1"?Colors.grey.shade500:colorsConst.appDarkGreen,isBold: true),
                          )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.add,color: Colors.transparent,size: 15,),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          10.height,
        ],
      );
    });
  }
}
