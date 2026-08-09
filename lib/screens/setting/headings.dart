import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/component/custom_textfield.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:master_code/view_model/location_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/view_model/setting_provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_text.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/task_provider.dart';
import '../common/dashboard.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

class AppHeadings extends StatefulWidget {
  const AppHeadings({super.key});

  @override
  State<AppHeadings> createState() => _AppHeadingsState();
}

class _AppHeadingsState extends State<AppHeadings>{

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<SettingProvider>(context, listen: false).getHeading();
    });
  }

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer2<SettingProvider,HomeProvider>(
        builder: (context, setPvr, homeProvider, _) {
          return Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: "App Values"),
            ),
            body: setPvr.refresh==false?
            const Loading():
            setPvr.headingList.isEmpty?
            Column(
              children: [
                100.height,
                Center(
                  child: CustomText(text: "No Values Found",
                      colors: colorsConst.greyClr),
                )
              ],
            ) :
            Center(
              child: SizedBox(
                width: kIsWeb?webWidth:phoneWidth,
                child: ListView.builder(
                    itemCount: setPvr.headingList.length,
                    itemBuilder: (context, index) {
                      final sortedData = setPvr.headingList;
                      final data = sortedData[index];
                      return Column(
                        children: [
                          if(index==0)
                          15.height,
                          InkWell(
                            onTap: (){
                              utils.navigatePage(context, ()=> DashBoard(child: HeadingValues(name: data["categories"].toString(), id: data["id"].toString())));
                            },
                            child: Container(
                              width: kIsWeb?webWidth:phoneWidth,
                              decoration: customDecoration.baseBackgroundDecoration(
                                color: Colors.white,radius: 1
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: CustomText(text: data["categories"].toString().trim()),
                              ),
                            ),
                          ),
                          8.height,
                        ],
                      );
                    }),
              ),
            ),
          );
        });
  }
}



class HeadingValues extends StatefulWidget {
  final String id;
  final String name;
  const HeadingValues({super.key, required this.id, required this.name});

  @override
  State<HeadingValues> createState() => _HeadingValuesState();
}

class _HeadingValuesState extends State<HeadingValues>{

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<SettingProvider>(context, listen: false).getAppHeadings(widget.id);
    });
  }
var isEditMode=false;
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer2<SettingProvider,HomeProvider>(
        builder: (context, setPvr, homeProvider, _) {
          return Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: widget.name,
                callback: (){
                  utils.navigatePage(context, ()=>const DashBoard(child: AppHeadings()));
                },
              ),
            ),
            floatingActionButton: isEditMode?CustomLoadingButton(callback: (){
              setPvr.changeAppValues(context, widget.id, widget.name);
            }, isLoading: true,controller: setPvr.signCtr,
                backgroundColor: Provider.of<HomeProvider>(context, listen: false).primary, radius: 5, width: 100,text: "Save",):null,
            body: PopScope(
              canPop: false,
              onPopInvoked: (bool didPop) {
                if (!didPop) {
                  utils.navigatePage(context, ()=>const DashBoard(child: AppHeadings()));
                }
              },
              child: setPvr.refresh==false?
              const Loading():
              setPvr.appHeadingList.isEmpty?
              Column(
                children: [
                  100.height,
                  Center(
                    child: CustomText(text: "No Values Found",
                        colors: colorsConst.greyClr),
                  )
                ],
              ) :
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: (){
                        setState(() {
                          isEditMode=!isEditMode;
                        });
                      }, child: Row(
                        children: [
                          CustomText(text: isEditMode?"View Mode":"Edit Mode",colors: isEditMode?colorsConst.greyClr:colorsConst.blueClr,isBold: true,),5.width,
                          SvgPicture.asset(assets.edit),
                        ],
                      )),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: setPvr.appHeadingList.length,
                        itemBuilder: (context, index) {
                          final sortedData = setPvr.appHeadingList;
                          final data = sortedData[index];
                          return Column(
                            children: [
                              if(index==0)
                              15.height,
                              Container(
                                width: kIsWeb?webWidth:phoneWidth,
                                decoration: customDecoration.baseBackgroundDecoration(
                                  color: Colors.white,radius: 1
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    isEditMode?
                                    SizedBox(
                                      width: kIsWeb?webWidth:phoneWidth/2,
                                      child: TextField(
                                        controller: data.valueCtr,
                                        onChanged: (value){
                                          setState(() {
                                            data.value=value;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(),
                                        ),
                                      ),
                                    ):
                                    CustomText(text: "   ${data.value.toString().trim()}"),
                                    // if(isEditMode)
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed:isEditMode?(){
                                            setState(() {
                                              if(data.required=="1"){
                                                data.required="0";
                                              }else{
                                                data.required="1";
                                              }
                                              print(setPvr.appHeadingList[index].required);
                                            });
                                          }:null,
                                            child: CustomText(text: data.required=="1"?"Required":"Optional",colors: data.required=="1"?Colors.green:Colors.grey,)),
                                        TextButton(
                                            onPressed:isEditMode?(){
                                              setState(() {
                                                if(data.active=="1"){
                                                  data.active="0";
                                                }else{
                                                  data.active="1";
                                                }
                                              });
                                            }:null,
                                            child: CustomText(text: "Delete",colors: data.active=="1"?Colors.red:Colors.grey,)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              8.height,
                            ],
                          );
                        }),
                  ),
                ],
              ),
            ),
          );
        });
  }
}



// class AddType extends StatefulWidget {
//   const AddType({super.key});
//
//   @override
//   State<AddType> createState() => _AddTypeState();
// }
//
// class _AddTypeState extends State<AddType>{
//   final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
//
//   @override
//   void initState() {
//     Future.delayed(Duration.zero, () {
//       Provider.of<setPvr>(context, listen: false).typeCtr.clear();
//     });
//     super.initState();
//   }
//   @override
//   void dispose() {
//     _myFocusScopeNode.dispose();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     var webWidth=MediaQuery.of(context).size.width * 0.5;
//     var phoneWidth=MediaQuery.of(context).size.width * 0.9;
//     return Consumer<setPvr>(builder: (context,setPvr,_){
//       return FocusScope(
//         node: _myFocusScopeNode,
//         child: SafeArea(
//           child: Scaffold(
//               backgroundColor: colorsConst.bacColor,
//               appBar: const PreferredSize(
//                 preferredSize: Size(300, 50),
//                 child: CustomAppbar(text: "Add Task Types"),
//               ),
//               body: Center(
//                 child: SizedBox(
//                   width: kIsWeb?webWidth:phoneWidth,
//                   // color: Colors.red,
//                   child:
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       CustomTextField(
//                           width: kIsWeb?webWidth:phoneWidth,
//                           isRequired: true,
//                           textInputAction: TextInputAction.done,
//                           text: "Type", controller: setPvr.typeCtr),
//                       100.height,
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           CustomLoadingButton(
//                               callback: (){
//                                 Future.microtask(() => Navigator.pop(context));
//                               }, isLoading: false,text: "Cancel",
//                               backgroundColor: Colors.white, textColor: Provider.of<HomeProvider>(context, listen: false).primary,radius: 10,
//                               width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
//                           CustomLoadingButton(
//                               callback: (){
//                                 if (setPvr.typeCtr.text.trim().isEmpty) {
//                                   utils.showWarningToast(context, text: "Please fill type");
//                                   setPvr.taskCtr.reset();
//                                 }else {
//                                   _myFocusScopeNode.unfocus();
//                                   setPvr.insertTaskType(context);
//                                 }
//                               }, isLoading: true,text: "Save",controller: setPvr.taskCtr,
//                               backgroundColor: Provider.of<HomeProvider>(context, listen: false).primary,radius: 10,
//                               width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//           ),
//         ),
//       );
//     });
//   }
// }
//
//
// class EditType extends StatefulWidget {
//   final String id;
//   final String value;
//   const EditType({super.key, required this.value, required this.id});
//
//   @override
//   State<EditType> createState() => _EditTypeState();
// }
//
// class _EditTypeState extends State<EditType>{
//   final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
//
//   @override
//   void initState() {
//     Future.delayed(Duration.zero, () {
//       Provider.of<setPvr>(context, listen: false).typeCtr.text=widget.value;
//     });
//     super.initState();
//   }
//   @override
//   void dispose() {
//     _myFocusScopeNode.dispose();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     var webWidth=MediaQuery.of(context).size.width * 0.5;
//     var phoneWidth=MediaQuery.of(context).size.width * 0.9;
//     return Consumer<setPvr>(builder: (context,setPvr,_){
//       return FocusScope(
//         node: _myFocusScopeNode,
//         child: SafeArea(
//           child: Scaffold(
//               backgroundColor: colorsConst.bacColor,
//               appBar: const PreferredSize(
//                 preferredSize: Size(300, 50),
//                 child: CustomAppbar(text: "Edit Task Types"),
//               ),
//               body: Center(
//                 child: SizedBox(
//                   width: kIsWeb?webWidth:phoneWidth,
//                   // color: Colors.red,
//                   child:
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       CustomTextField(
//                           width: kIsWeb?webWidth:phoneWidth,
//                           isRequired: true,
//                           textInputAction: TextInputAction.done,
//                           text: "Type", controller: setPvr.typeCtr),
//                       100.height,
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           CustomLoadingButton(
//                               callback: (){
//                                 Future.microtask(() => Navigator.pop(context));
//                               }, isLoading: false,text: "Cancel",
//                               backgroundColor: Colors.white, textColor: Provider.of<HomeProvider>(context, listen: false).primary,radius: 10,
//                               width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
//                           CustomLoadingButton(
//                               callback: (){
//                                 if (setPvr.typeCtr.text.trim().isEmpty) {
//                                   utils.showWarningToast(context, text: "Please fill type");
//                                   setPvr.taskCtr.reset();
//                                 }else {
//                                   _myFocusScopeNode.unfocus();
//                                   setPvr.editTaskType(context,widget.id);
//                                 }
//                               }, isLoading: true,text: "Save",controller: setPvr.taskCtr,
//                               backgroundColor: Provider.of<HomeProvider>(context, listen: false).primary,radius: 10,
//                               width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//           ),
//         ),
//       );
//     });
//   }
// }