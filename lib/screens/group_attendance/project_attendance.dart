import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/constant/assets_constant.dart';
import 'package:master_code/source/constant/local_data.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:master_code/view_model/location_provider.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_checkbox.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/constant/key_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/project_provider.dart';
import '../common/dashboard.dart';
import '../common/home_page.dart';

class ProjectAttendance extends StatefulWidget {
  const ProjectAttendance({super.key});
  @override
  State<ProjectAttendance> createState() => _ProjectAttendanceState();
}

class _ProjectAttendanceState extends State<ProjectAttendance>with SingleTickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ProjectProvider>(context, listen: false).searchController.clear();
      Provider.of<ProjectProvider>(context, listen: false).getAllProject(true);
      Provider.of<ProjectProvider>(context, listen: false).getAllUsers();
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
    return Consumer3<ProjectProvider,LocationProvider,HomeProvider>(builder: (context,prjProvider,locPvr,homeProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: PreferredSize(
            preferredSize: const Size(300, 60),
            child: CustomAppbar(text: constValue.grpAtt,
            callback: (){
              _myFocusScopeNode.unfocus();
              homeProvider.updateIndex(0);
              utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
            },),
          ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(15.0),
          child: CustomLoadingButton( isLoading: true,
            width: kIsWeb?webWidth:phoneWidth,
            callback: () {
              _myFocusScopeNode.unfocus();
              if(prjProvider.selectProject==null){
                utils.showWarningToast(context,text: "Please Select ${constValue.projectName}");
                prjProvider.projectCtr.reset();
              }else if(prjProvider.prjGroupAttendanceList.isNotEmpty){
                prjProvider.getProjectGroupAtt(context,localData.storage.read("g_prj_id"));
              }else{
                utils.showWarningToast(context,text: "Please select check in");
                prjProvider.projectCtr.reset();
              }
            },
            text: "Mark Attendance",controller: prjProvider.projectCtr,backgroundColor: colorsConst.primary,radius: 5,),
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
              child: Column(
                children: [
                  20.height,
                  Container(
                    width: kIsWeb?webWidth:phoneWidth,
                    height: 50,
                    decoration: customDecoration.baseBackgroundDecoration(
                      borderColor: Colors.grey.shade200,
                      color: Colors.white,radius: 10
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: kIsWeb?webWidth/1.5:phoneWidth/1.5,
                          child: DropdownButtonHideUnderline(
                            child:ButtonTheme(
                              alignedDropdown:true,
                              child: DropdownButton(
                                hint: CustomText(text:constValue.projectName),
                                isExpanded: true,
                                value:prjProvider.selectProject,
                                iconEnabledColor: Colors.black,
                                items:prjProvider.projectData.map((list) {
                                  return DropdownMenuItem(
                                    value: list,
                                    child: CustomText(text:list.name.toString()),
                                  );
                                }
                                ).toList(),
                                onChanged: (value){
                                  prjProvider.changeProject(value);
                                },
                              ),
                            ),
                          ),
                        ),
                        Container(width: 1,height:40,color: Colors.grey.shade200,),
                        InkWell(
                          onTap: () {
                            _myFocusScopeNode.unfocus();
                            prjProvider.datePick(context:context,textEditingController: prjProvider.date1);
                          },
                          child: SizedBox(
                            width: kIsWeb?webWidth/3.5:phoneWidth/3.5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(assets.calendar2),
                                5.width,
                                CustomText(text:  prjProvider.date1.text,),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if(prjProvider.selectProject!=null)
                  CustomTextField(
                    text:"",controller: prjProvider.searchController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    inputFormatters: constInputFormatters.numTextInput,
                    width: kIsWeb?webWidth:phoneWidth,
                    hintText: "Search Name Or Number",isIcon:true,iconData: Icons.search,isShadow: true,
                    onChanged:(value){
                      prjProvider.searchProjectUsers(value.toString());
                    },
                    isSearch: prjProvider.searchController.text.isNotEmpty?true:false,
                    searchCall: (){
                      prjProvider.searchController.clear();
                      prjProvider.searchProjectUsers("");
                    },
                  ),
                  prjProvider.attRefresh==false?
                  Padding(
                    padding: const EdgeInsets.all(100),
                    child: const Loading(),
                  ):
                  prjProvider.searchPrjUserEdit.isEmpty?
                  Padding(
                    padding: const EdgeInsets.all(100),
                    child: CustomText(text: constValue.noUser,colors: colorsConst.secondary),
                  ):prjProvider.selectProject==null?
                  Center(child: CustomText(text: "\n\n\n\nSelect ${constValue.projectName}",colors: colorsConst.secondary)):
                  Flexible(
                    child: ListView.builder(
                        itemCount: prjProvider.searchPrjUserEdit.length,
                        itemBuilder: (context,index){
                          return Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, index==prjProvider.searchPrjUserEdit.length-1?80:10),
                            child: Container(
                              decoration: customDecoration.baseBackgroundDecoration(
                                  color: Colors.white,
                                  borderColor: Colors.grey.shade100,
                                  radius: 5
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    10.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CustomText(text: prjProvider.searchPrjUserEdit[index]["f_name"].toString(),colors: colorsConst.greyClr,isBold: true,),
                                            5.width,
                                            CustomText(text: prjProvider.searchPrjUserEdit[index]["role"].toString(),colors: Colors.grey),
                                          ],
                                        ),
                                        CustomText(text: prjProvider.searchPrjUserEdit[index]["mobile_number"].toString(),colors: colorsConst.greyClr,),
                                      ],
                                    ),
                                    15.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CustomCheckBox(
                                              text:"In",
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if(prjProvider.searchPrjUserEdit[index]["in"]!=""){

                                                  }else{
                                                    if(prjProvider.searchPrjUserEdit[index]["check_in"]==true){
                                                      prjProvider.searchPrjUserEdit[index]["check_in"]=false;
                                                      prjProvider.prjGroupAttendanceList.removeWhere((element)  => element['usr_id'] == prjProvider.searchPrjUserEdit[index]["user_id"]);
                                                    }else if(prjProvider.searchPrjUserEdit[index]["check_in"]==false){
                                                      prjProvider.searchPrjUserEdit[index]["check_in"]=true;
                                                      prjProvider.prjGroupAttendanceList.add({
                                                        "id": prjProvider.searchPrjUserEdit[index]["att_id"],
                                                        "salesman_id": prjProvider.searchPrjUserEdit[index]["user_id"],
                                                        "created_by": localData.storage.read('id'),
                                                        "line_customer_id": localData.storage.read("g_prj_id"),
                                                        "cos_id": localData.storage.read("cos_id"),
                                                        "is_checked_out": "1",
                                                        "lat": locPvr.latitude,
                                                        "lng": locPvr.longitude,
                                                        "time": combineDateWithCurrentTime(prjProvider.date1.text),
                                                      });
                                                    }
                                                  }
                                                });
                                                // print("${prjProvider.prjGroupAttendanceList.length}");
                                              },
                                              saveValue: prjProvider.searchPrjUserEdit[index]["check_in"],),
                                            CustomText(text: prjProvider.searchPrjUserEdit[index]["in"].toString()==""?"":" - ${DateFormat('hh:mm a').format(DateTime.parse(prjProvider.searchPrjUserEdit[index]["in"].toString()))}",),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            CustomCheckBox(
                                              text:"Out",
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if(prjProvider.searchPrjUserEdit[index]["in"]!=""){
                                                    if(prjProvider.searchPrjUserEdit[index]["out"]!=""){

                                                    }else{
                                                      if(prjProvider.searchPrjUserEdit[index]["check_out"]==true){
                                                        prjProvider.searchPrjUserEdit[index]["check_out"]=false;
                                                        prjProvider.prjGroupAttendanceList.removeWhere((element)  => element['usr_id'] == prjProvider.searchPrjUserEdit[index]["user_id"]);
                                                      }else if(prjProvider.searchPrjUserEdit[index]["check_out"]==false){
                                                        prjProvider.searchPrjUserEdit[index]["check_out"]=true;
                                                        prjProvider.prjGroupAttendanceList.add({
                                                          "id": prjProvider.searchPrjUserEdit[index]["att_id"],
                                                          "salesman_id": prjProvider.searchPrjUserEdit[index]["user_id"],
                                                          "created_by": localData.storage.read('id'),
                                                          "line_customer_id": localData.storage.read("g_prj_id"),
                                                          "cos_id": localData.storage.read("cos_id"),
                                                          "is_checked_out": "2",
                                                          "in_time": prjProvider.searchPrjUserEdit[index]["in"],
                                                          "lat": locPvr.latitude,
                                                          "lng": locPvr.longitude,
                                                          "time": combineDateWithCurrentTime(prjProvider.date1.text),
                                                        });
                                                      }
                                                    }
                                                  }else{
                                                    utils.showWarningToast(context,text: "Please Check in first");
                                                  }
                                                });
                                              },
                                              saveValue: prjProvider.searchPrjUserEdit[index]["check_out"],),
                                            CustomText(text: prjProvider.searchPrjUserEdit[index]["out"].toString()==""?"":" - ${DateFormat('hh:mm a').format(DateTime.parse(prjProvider.searchPrjUserEdit[index]["out"].toString()))}",),
                                          ],
                                        ),
                                      ],
                                    ),
                                    10.height,
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  )
                ],
              ),
            ),
          ),
        ),
            ),
      );
    });
  }
  String combineDateWithCurrentTime(String inputDate) {
    DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(inputDate);
    DateTime now = DateTime.now();
    DateTime combined = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      now.hour,
      now.minute,
      now.second,
    );
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(combined);
  }
}
