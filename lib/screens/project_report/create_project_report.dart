import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/project_provider.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../component/maxline_textfield.dart';
import '../../component/search_drop_down2.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/report_provider.dart';

class CreateProjectReport extends StatefulWidget {
  const CreateProjectReport({super.key});

  @override
  State<CreateProjectReport> createState() => _CreateProjectReportState();
}

class _CreateProjectReportState extends State<CreateProjectReport> with TickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ReportProvider>(context, listen: false).initProjReport();
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
    return Consumer2<ReportProvider,ProjectProvider>(builder: (context,repProvider,prjPvr,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: constValue.addProjectReport),
            ),
            backgroundColor: colorsConst.bacColor,
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    50.height,
                    InkWell(
                      onTap: () {
                        _myFocusScopeNode.unfocus();
                        utils.datePick(context: context,textEditingController: repProvider.addDate);
                      },
                      child: SizedBox(
                        width: kIsWeb?webWidth:phoneWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.calendar_today, size: 15,), 5.width,
                            CustomText(text: repProvider.addDate.text,),
                            15.width,
                          ],
                        ),
                      ),
                    ),
                    30.height,
                    CustomSearchDropDown2(
                      isUser: false,isRequired: true,
                      list: prjPvr.projectData,
                      color: Colors.grey.shade100,
                      width:kIsWeb?webWidth:phoneWidth,
                      hintText: constValue.projectName,
                      saveValue: repProvider.projectName,
                      onChanged: (Object? value) {
                        repProvider.changeProject(value);
                      },
                      dropText: 'name',),
                    10.height,
                    MaxLineTextField(isRequired: true,
                      text: constValue.cmt,
                      controller: repProvider.comment,
                      maxLine: 5,
                      textInputAction: TextInputAction.done,
                      width:kIsWeb?webWidth:phoneWidth,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () {
                          if (repProvider.addDocuments.isNotEmpty&&repProvider.addDocuments.last.imagePath == "") {
                            utils.showWarningToast(context,text: "Please add document");
                          } else {
                            repProvider.addDocument();
                          }
                        },
                            icon: const Icon(
                              Icons.add, color: Colors.black,
                              size: 30,)),
                      ],
                    ),
                    if(repProvider.addDocuments.isNotEmpty)
                      SizedBox(
                        width:kIsWeb?webWidth:phoneWidth,
                        child: GridView.builder(
                          itemCount: repProvider.addDocuments.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            // mainAxisExtent: 70,
                          ),
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                _myFocusScopeNode.unfocus();
                                repProvider.signDialog(context,index: index);
                              },
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: customDecoration
                                    .baseBackgroundDecoration(
                                    borderColor: Colors.grey.shade300,
                                    radius: 20,
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: SizedBox(
                                          width: 80,
                                          height: 50,
                                          child:repProvider.addDocuments[index].imagePath == ""?
                                             Icon(Icons.camera_alt)
                                            :Image.file(File(repProvider.addDocuments[index].imagePath),fit: BoxFit.cover)
                                      ),
                                    ),
                                    if(repProvider.addDocuments.length!=1)
                                    Positioned(
                                      right: 2,
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: customDecoration
                                            .baseBackgroundDecoration(
                                            color: Colors.transparent,
                                            radius: 20
                                        ),
                                        child: IconButton(
                                            onPressed: () {
                                              _myFocusScopeNode.unfocus();
                                              if (repProvider.addDocuments.isEmpty) {
                                              } else if (repProvider.addDocuments .length == 1) {
                                                utils.showWarningToast(context,text:"Please add document");
                                              } else {
                                                repProvider.removeDocument(index);
                                              }
                                            },
                                            icon: SvgPicture.asset(
                                              assets.deleteValue,
                                              width: 20,
                                              height: 20,)),
                                      ),)
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    40.height,
                    SizedBox(
                      width:kIsWeb?webWidth:phoneWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomLoadingButton(
                              callback: (){
                                Future.microtask(() => Navigator.pop(context));
                              }, isLoading: false,text: "Cancel",
                              backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                              width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
                          CustomLoadingButton(
                            width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                            isLoading: true,
                            callback: () {
                              if (repProvider.projectName == null) {
                                utils.showWarningToast(context,text: "Please select project name");
                                repProvider.addCtr.reset();
                              } else if (repProvider.comment.text.trim().isEmpty) {
                                utils.showWarningToast(context,text: "Please add comment");
                                repProvider.addCtr.reset();
                              } else if (repProvider.addDocuments[0].imagePath == "") {
                                _myFocusScopeNode.unfocus();
                                utils.showWarningToast(context,text: "Please upload document");
                                repProvider.addCtr.reset();
                              } else if (repProvider.addDocuments.last.imagePath == "") {
                                _myFocusScopeNode.unfocus();
                                utils.showWarningToast(context,text: "Please upload document");
                                repProvider.addCtr.reset();
                              } else {
                                _myFocusScopeNode.unfocus();
                                repProvider.insertProjectReport(context);
                              }
                            },
                            controller: repProvider.addCtr, text: 'Save', backgroundColor: colorsConst.primary, radius: 10,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}



