import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/screens/project/project_report.dart';
import 'package:master_code/screens/project/update_project.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:master_code/view_model/location_provider.dart';
import 'package:master_code/view_model/project_provider.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_checkbox.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../common/dashboard.dart';
import '../common/home_page.dart';
import '../expense/simple_expense.dart';
import 'create_project.dart';
class ViewProject extends StatefulWidget {
  const ViewProject({super.key
  });

  @override
  State<ViewProject> createState() => _ViewProjectState();
}

class _ViewProjectState extends State<ViewProject> with TickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ProjectProvider>(context, listen: false).searchController.clear();
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
    return Consumer3<ProjectProvider,LocationProvider,HomeProvider>(builder: (context,prjProvider,locPvr,homeProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: PreferredSize(
          preferredSize: const Size(300, 50),
          child: CustomAppbar(text: constValue.project,isButton: localData.storage.read("role")=="1"?true:false,
          buttonCallback: (){
            _myFocusScopeNode.unfocus();
            utils.navigatePage(context, ()=>const CreateProject());
          },callback: (){
              _myFocusScopeNode.unfocus();
              homeProvider.updateIndex(0);
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
              // color: Colors.pink,
              width: kIsWeb?webWidth:phoneWidth,
              child: prjProvider.refresh==false?
              const Loading()
                  :Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomTextField(
                      controller: prjProvider.searchController,radius: 30,
                      width: kIsWeb?webWidth:phoneWidth,
                      text: "",
                      isIcon: true,hintText: "Search Name Or City",
                      iconData: Icons.search,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        prjProvider.searchProject(value.toString());
                      },
                      isSearch: prjProvider.searchController.text.isNotEmpty?true:false,
                      searchCall: (){
                        prjProvider.searchController.clear();
                        prjProvider.searchProject("");
                      },
                    ),
                    if(prjProvider.searchProjectData.isNotEmpty)
                      SizedBox(
                        width: kIsWeb?webWidth:phoneWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomCheckBox(
                              text:"Sort By Date",
                              onChanged: (bool? value) {
                                prjProvider.sortBy(value);
                              },
                              saveValue: prjProvider.isSort,),
                            Row(
                              children: [
                                const CustomText(text: "Total Project : ",colors: Colors.grey),
                                CustomText(text: prjProvider.searchProjectData.length.toString(),colors: colorsConst.greyClr,isBold: true,),
                              ],
                            ),
                          ],
                        ),
                      ),
                    if (prjProvider.searchProjectData.isEmpty) Column(
                      children: [
                        200.height,
                        Center(
                            child: CustomText(text:constValue.noProject,size: 14,)),
                      ],
                    ) else Flexible(
                      child: SlidableAutoCloseBehavior(
                        child: ListView.builder(
                            itemCount: prjProvider.searchProjectData.length,
                            itemBuilder: (context,index){
                              final sortedData = prjProvider.searchProjectData;
                              if(prjProvider.isSort==true){
                                sortedData.sort((a, b) => b.createdTs.toString().compareTo(a.createdTs.toString()));
                              }else{
                                sortedData.sort((a, b) => a.name.toString().compareTo(b.name.toString()));
                              }
                              final data = sortedData[index];

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
                              final showDateHeader = index == 0 || createdBy != getCreatedDate(prjProvider.searchProjectData[index - 1]);
                              return Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, index==prjProvider.searchProjectData.length-1?100:10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if(showDateHeader)
                                    Center(child: CustomText(text: dayOfWeek,colors: colorsConst.greyClr,)),
                                    Container(
                                        width: kIsWeb?webWidth:phoneWidth,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: Colors.white,
                                            radius: 5,
                                            borderColor: Colors.grey.shade300
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                          child: Column(
                                            children: [
                                              IntrinsicHeight(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      // color:Colors.yellow,
                                                      width: localData.storage.read("role")=="1"&&kIsWeb?webWidth/1.1:
                                                      localData.storage.read("role")=="1"&&!kIsWeb?phoneWidth/1.3:
                                                      localData.storage.read("role")!="1"&&kIsWeb?webWidth:phoneWidth/1.1,
                                                      child: Padding(
                                                        padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                SizedBox(
                                                                  // color:Colors.pink,
                                                                    width: localData.storage.read("role")=="1"&&kIsWeb?webWidth/1.6:
                                                                    localData.storage.read("role")=="1"&&!kIsWeb?phoneWidth/2.2:
                                                                    localData.storage.read("role")!="1"&&kIsWeb?webWidth/1.5:phoneWidth/2.5,
                                                                    child: CustomText(text: data.name.toString(),isBold: true,)),
                                                                Container(
                                                                  // height: 20,
                                                                    width: localData.storage.read("role")=="1"&&kIsWeb?webWidth/4.5:
                                                                    localData.storage.read("role")=="1"&&!kIsWeb?phoneWidth/3.5:
                                                                    localData.storage.read("role")!="1"&&kIsWeb?webWidth/1.5:phoneWidth/2,
                                                                    decoration: BoxDecoration(
                                                                        color: colorsConst.secondary.withOpacity(0.1),
                                                                        borderRadius: BorderRadius.circular(10)
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(4.0),
                                                                      child: CustomText(text: "${data.startDate.toString()} to ${data.endDate.toString()}",),
                                                                    )),
                                                              ],
                                                            ),
                                                            CustomText(text: "${data.addressLine1.toString()},${data.addressLine2.toString()},${data.area.toString()},${data.city.toString()},${data.state.toString()},${data.country.toString()},${data.pincode.toString()}",colors: colorsConst.greyClr,),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    if(localData.storage.read("role")=="1")
                                                      Container(width: 1,color: Colors.grey.shade300,),
                                                    if(localData.storage.read("role")=="1")
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          IconButton(
                                                            onPressed : (){
                                                              _myFocusScopeNode.unfocus();
                                                              utils.navigatePage(context, ()=>UpdateProject(data: data));
                                                            },
                                                            icon: SvgPicture.asset(assets.edit),
                                                          ),
                                                          IconButton(
                                                            onPressed : (){
                                                              _myFocusScopeNode.unfocus();
                                                              utils.customDialog(
                                                                  context: context,
                                                                  title: "Are you sure you want",
                                                                  title2: "to inactive the project?",
                                                                  callback: (){
                                                                    prjProvider.deleteProject(context,data.id.toString());
                                                                  },
                                                                  isLoading: true,
                                                                  roundedLoadingButtonController: prjProvider.addCtr);
                                                            },
                                                            icon: SvgPicture.asset(assets.deleteValue,width: 17,height: 17,),
                                                          ),
                                                        ],
                                                      )
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  TextButton(
                                                      onPressed: (){
                                                        _myFocusScopeNode.unfocus();
                                                        utils.navigatePage(context, ()=>SimpleExpense(projectId: data.id.toString(),));
                                                      },
                                                      child: CustomText(text: "Add Expense",colors: colorsConst.blueClr,)),
                                                  TextButton(
                                                      onPressed: (){
                                                        _myFocusScopeNode.unfocus();
                                                        utils.navigatePage(context, ()=>ProjectReport(projectId: data.id.toString(), projectName: data.name.toString(),));
                                                      },
                                                      child: CustomText(text: "View Report",colors: colorsConst.appDarkGreen,)),
                                                  SizedBox(
                                                    width:kIsWeb?webWidth/3:phoneWidth/3,
                                                    height: 30,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: data.isChecked.toString()=="null"?colorsConst.litGrey:data.isChecked.toString()=="2"?colorsConst.litGrey:colorsConst.appGreen,
                                                        shape: StadiumBorder()
                                                      ),
                                                      onPressed: () async {
                                                        _myFocusScopeNode.unfocus();
                                                        if(locPvr.latitude!=""&&locPvr.longitude!=""){
                                                          double distance=prjProvider.calculateDistance(
                                                              double.parse(data.lat.toString()), double.parse(data.lng.toString()),
                                                              double.parse(locPvr.latitude), double.parse(locPvr.longitude));
                                                          // if(data.metre=="0"||data.metre=="null"||data.metre==""){
                                                          //   prjProvider.signDialog(context: context,
                                                          //     img: prjProvider.profile,
                                                          //     onTap:(newImg){
                                                          //       prjProvider.profilePick(newImg);
                                                          //       prjProvider.projectAttendance(
                                                          //           context,
                                                          //           status:data.isChecked.toString()=="null"||data.isChecked.toString()=="2"?"1":"2",
                                                          //           taskId: data.id.toString(),
                                                          //           lat:locPvr.latitude,
                                                          //           lng:locPvr.longitude);
                                                          //     },
                                                          //   );
                                                          // }else if(int.parse(data.metre.toString())>=distance){
                                                            prjProvider.signDialog(context: context,
                                                              img: prjProvider.profile,
                                                              onTap:(newImg){
                                                                prjProvider.profilePick(newImg);
                                                                prjProvider.projectAttendance(
                                                                    context,
                                                                    status:data.isChecked.toString()=="null"||data.isChecked.toString()=="2"?"1":"2",
                                                                    taskId: data.id.toString(),
                                                                    lat:locPvr.latitude,
                                                                    lng:locPvr.longitude);
                                                              },
                                                            );
                                                          // }else{
                                                          //   prjProvider.checkDistance();
                                                          //   utils.showWarningToast(context,text: "You are not near your project");
                                                          // }
                                                        }else{
                                                          utils.showWarningToast(context, text: "Check your location accuracy.");
                                                          await locPvr.manageLocation(context, true);
                                                        }
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.location_on_outlined,color: data.isChecked.toString()=="null"?Colors.black: data.isChecked.toString()=="2"?Colors.black: Colors.white,size: 15,),
                                                          CustomText(text: data.isChecked.toString()=="null"?"Check In":data.isChecked.toString()=="1"?"Check Out":"Check In",
                                                            colors: data.isChecked.toString()=="null"?Colors.black:data.isChecked.toString()=="2"?Colors.black: Colors.white,isBold: true,),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ),
                  ]
              ),
            ),
          ),
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
