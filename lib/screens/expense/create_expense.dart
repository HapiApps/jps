import 'dart:io';
import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/component/custom_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/component/custom_textfield.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/constant/key_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_code/source/styles/decoration.dart';
import '../../component/custom_appbar.dart';
import '../../component/map_dropdown.dart';
import '../../model/task/task_data_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/expense_provider.dart';
import '../common/fullscreen_photo.dart';
class CreateExpense extends StatefulWidget {
  final String? taskId;
  final TaskData? data;
  final String coId;
  final List numberList;
  final String companyName;
  final String type;
  final String desc;
  final String date;
  const CreateExpense({super.key, this.taskId, this.data, required this.coId, required this.numberList, required this.companyName, required this.type, required this.desc, required this.date});

  @override
  State<CreateExpense> createState() => _CreateExpenseState();
}

class _CreateExpenseState extends State<CreateExpense> with TickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    Provider.of<ExpenseProvider>(context, listen: false).tabController=TabController(length:4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).tabController.addListener(() {
        Provider.of<ExpenseProvider>(context, listen: false).updateIndex(Provider.of<ExpenseProvider>(context, listen: false).tabController.index);
      });
      Provider.of<ExpenseProvider>(context, listen: false).initValues(widget.date);
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
    _myFocusScopeNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var webHeight=MediaQuery.of(context).size.width * 0.3;
    var phoneHeight=MediaQuery.of(context).size.width * 0.95;
    var splitWidth=kIsWeb?MediaQuery.of(context).size.width * 0.24:MediaQuery.of(context).size.width * 0.4;
    return Consumer<ExpenseProvider>(builder: (context,expensePvr,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: constValue.createExpense),
            ),
            floatingActionButton: expensePvr.swipeIndex==0||expensePvr.swipeIndex==1||expensePvr.swipeIndex==2?
            SizedBox(
              width: kIsWeb?webHeight:phoneHeight,
              // color: Colors.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){
                      _myFocusScopeNode.unfocus();
                      if(expensePvr.swipeIndex==0){
                        expensePvr.pickFile();
                      }else if(expensePvr.swipeIndex==1){
                        expensePvr.pickFile2();
                      }else if(expensePvr.swipeIndex==2){
                        expensePvr.pickFile3();
                      }
                    },
                    child: Container(
                      width: kIsWeb?webHeight:phoneHeight/1.5,height: 70,
                      decoration: customDecoration.baseBackgroundDecoration(
                          color: Colors.white,
                          radius: 10,
                          borderColor: colorsConst.litGrey
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(assets.upload),5.width,
                          CustomText(text: "Upload File",colors: colorsConst.greyClr,),
                        ],
                      ),
                    ),
                  ),10.width,
                  FloatingActionButton(
                      backgroundColor: colorsConst.blueClr,
                      onPressed: (){
                        _myFocusScopeNode.unfocus();
                        if(expensePvr.swipeIndex==0){
                          expensePvr.pickCamera(context);
                        }else if(expensePvr.swipeIndex==1){
                          expensePvr.pickCamera2(context);
                        }else if(expensePvr.swipeIndex==2){
                          expensePvr.pickCamera3(context);
                        }
                      }, child: const Icon(Icons.camera_alt_outlined,color: Colors.white,)),
                ],
              ),
            ):null,
            body: Center(
              child: SizedBox(
                width: kIsWeb?MediaQuery.of(context).size.width * 0.5:MediaQuery.of(context).size.width * 0.83,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(text: widget.companyName=="null"?"":widget.companyName,colors: colorsConst.primary,isBold: true,),10.width,
                        CustomText(text: widget.type,colors: colorsConst.greyClr,isItalic: true,),
                      ],
                    ),10.height,
                    SizedBox(
                      width: kIsWeb?MediaQuery.of(context).size.width * 0.5:MediaQuery.of(context).size.width * 0.7,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(text: "DA"),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: CustomText(text: "TRA"),
                          ),
                          CustomText(text: "CONV"),
                          // CustomText(text: "DOC"),
                          CustomText(text: "SUM"),
                        ],
                      ),
                    ),
                    Container(
                        height: 8,
                        decoration: customDecoration.baseBackgroundDecoration(
                            color: Colors.transparent,
                            radius: 10
                        ),
                        child: TabBar(
                          controller: expensePvr.tabController,
                          indicatorSize: TabBarIndicatorSize.label,
                          indicatorWeight: 0,
                          indicator: customDecoration.baseBackgroundDecoration(
                              color: colorsConst.primary,
                              radius: 30
                          ),
                          onTap: (int index){
                            expensePvr.updateIndex(index);
                          },
                          labelColor: Colors.green,
                          unselectedLabelColor: Colors.green,
                          tabs:  [
                            Tab(child:Container(color:expensePvr.swipeIndex==0?colorsConst.primary:Colors.grey.shade300,width: 35,height: 5,)),
                            Tab(child:Container(color:expensePvr.swipeIndex==1?colorsConst.primary:Colors.grey.shade300,width: 35,height: 5,)),
                            Tab(child:Container(color:expensePvr.swipeIndex==2?colorsConst.primary:Colors.grey.shade300,width: 35,height: 5,)),
                            Tab(child:Container(color:expensePvr.swipeIndex==3?colorsConst.primary:Colors.grey.shade300,width: 35,height: 5,)),
                            // Tab(child:Container(color:expensePvr.swipeIndex==4?colorsConst.primary:Colors.grey.shade300,width: 25,height: 5,)),
                            // Tab(child:Container(color:expensePvr.swipeIndex==5?colorsConst.primary:Colors.grey.shade300,width: 25,height: 5,)),
                          ],
                        )
                    ),
                    20.height,
                    expensePvr.travelExp.isEmpty||
                        expensePvr.otherExp.isEmpty||
                        expensePvr.conveyanceExp.isEmpty?
                    const Loading():
                    Expanded(
                      child: TabBarView(
                          controller: expensePvr.tabController,
                          children: [
                            // Column(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Column(
                            //       children: [
                            //         Row(
                            //           mainAxisAlignment: MainAxisAlignment.spaceAround,
                            //           children: [
                            //             CustomText(text: "Employee & Trip Details",colors: colorsConst.primary,isBold: true,),
                            //             Row(
                            //               children: [
                            //                 CustomText(text: "Total : ",colors: colorsConst.greyClr),
                            //                 CustomText(text: "₹ ${expensePvr.totalAmt.text.isEmpty?"0":expensePvr.totalAmt.text}",colors: colorsConst.primary,isBold: true,),
                            //               ],
                            //             ),
                            //           ],
                            //         ),10.height,
                            //         Row(
                            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //           children: [
                            //             CustomTextField(text: "Place Visited",
                            //               controller: expensePvr.visitPlace,
                            //               isRequired: true,
                            //               width: splitWidth,
                            //               inputFormatters: constInputFormatters.addressInput,
                            //             ),
                            //             CustomTextField(text: constValue.customer,
                            //               controller: expensePvr.client,
                            //               isRequired: true,
                            //               width: splitWidth,
                            //               inputFormatters: constInputFormatters.addressInput,
                            //             )
                            //           ],
                            //         ),
                            //         CustomTextField(text: "Purpose",
                            //           isRequired: true,
                            //           controller: expensePvr.purpose,
                            //           textInputAction: TextInputAction.done,
                            //         ),
                            //       ],
                            //     ),
                            //     Row(
                            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //       children: [
                            //         CustomLoadingButton(
                            //             callback: (){
                            //               Future.microtask(() => Navigator.pop(context));
                            //             }, isLoading: false,text: "Cancel",
                            //             backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: splitWidth),
                            //         CustomLoadingButton(
                            //             callback: (){
                            //               if (expensePvr.visitPlace.text.trim().isEmpty) {
                            //                 utils.showWarningToast(context,text: "Please fill place visited");
                            //               }else if (expensePvr.client.text.trim().isEmpty) {
                            //                 utils.showWarningToast(context,text: "Please fill ${constValue.customerName}");
                            //               } else if (expensePvr.purpose.text.trim().isEmpty) {
                            //                 utils.showWarningToast(context,text: "Please fill purpose");
                            //               }else {
                            //                 expensePvr.updateIndex(1);
                            //               }
                            //             }, isLoading: false,text: "Next",
                            //             backgroundColor: colorsConst.primary,radius: 10, width: splitWidth),
                            //       ],
                            //     ),
                            //   ],
                            // ),
                            ListView(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(width: MediaQuery.of(context).size.width*0.2,height:5),
                                        Row(
                                          children: [
                                            InkWell(onTap: (){
                                              expensePvr.changeOtherExp(false);
                                            }, child: const Icon(Icons.arrow_back_ios_rounded,size: 17,)),
                                            CustomText(text: "Bill # ${expensePvr.otherIndex+1}",colors: colorsConst.primary,isBold: true,),
                                            InkWell(onTap: (){
                                              expensePvr.changeOtherExp(true);
                                            }, child: const Icon(Icons.arrow_forward_ios_rounded,size: 17)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            CustomText(text: "Total : ",colors: colorsConst.greyClr),
                                            CustomText(text: "₹ ${expensePvr.otherAmt}",colors: colorsConst.primary,isBold: true,),
                                          ],
                                        ),
                                      ],
                                    ),10.height,
                                    CustomText(text: "DA/Board/Lodging/Other Expenses",colors: colorsConst.primary,isBold: true,),
                                    if(expensePvr.otherExp.length!=1)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                              onTap: (){
                                                expensePvr.removeOtherExp(expensePvr.otherIndex);
                                              },
                                              child: SvgPicture.asset(assets.deleteValue)),
                                        ],
                                      ),
                                    CustomTextField(
                                      text: "# of Days",
                                      isRequired: expensePvr.checkValidation3(),
                                      onChanged: (value){
                                        expensePvr.gradeWithDAAmt();
                                        setState(() {
                                          expensePvr.checkValidation3();
                                        });
                                      },
                                      inputFormatters: constInputFormatters.daInput,
                                      keyboardType: TextInputType.number,
                                      // readOnly: true,
                                      // onTap: (){
                                      //   expensePvr.datePick(context: context, date: expensePvr.otherExp[expensePvr.otherIndex].date);
                                      // },
                                      controller: expensePvr.otherExp[expensePvr.otherIndex].date,
                                    ),CustomTextField(
                                      isRequired: expensePvr.checkValidation3(),
                                      text: "Particular",
                                      onChanged: (value){
                                        setState(() {
                                          expensePvr.checkValidation3();
                                        });
                                      },
                                      inputFormatters: constInputFormatters.addressInput,
                                      controller: expensePvr.otherExp[expensePvr.otherIndex].particular,
                                    ),CustomTextField(
                                      text: "Amount",
                                      onChanged: (value){
                                        if(localData.storage.read("da_amount")=="0"||
                                            localData.storage.read("da_amount")==""||
                                            localData.storage.read("da_amount")=="null"){
                                          expensePvr.addOtherAmt();
                                        }
                                      },
                                      isRequired: expensePvr.checkValidation3(),
                                      readOnly: localData.storage.read("da_amount")=="0"||
                                          localData.storage.read("da_amount")==""||
                                          localData.storage.read("da_amount")=="null"?false:true,
                                      inputFormatters: constInputFormatters.amtInput,
                                      keyboardType: TextInputType.number,
                                      controller: expensePvr.otherExp[expensePvr.otherIndex].amount,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ],
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics: const ScrollPhysics(),
                                    itemCount: expensePvr.selectedFiles1.length,
                                    itemBuilder: (context, index) {
                                      final file = expensePvr.selectedFiles1[index];
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        child: InkWell(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>FullScreen(
                                              image: file['path'], isNetwork: false,)));
                                          },
                                          child: Container(
                                            width: kIsWeb?webHeight:phoneHeight,
                                            height: 60,
                                            decoration: customDecoration.baseBackgroundDecoration(
                                                color: Colors.white,radius: 10,
                                                borderColor: colorsConst.litGrey
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        10.width,
                                                        SvgPicture.asset(assets.docs),
                                                        10.width,
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width*0.5,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [10.height,
                                                              CustomText(text: file['name']),5.height,
                                                              CustomText(text: file['size'],colors: colorsConst.greyClr,size: 10,)
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    IconButton(
                                                      onPressed: (){
                                                        utils.customDialog(
                                                            context: context,
                                                            title: "Do you want to",
                                                            title2:"Delete this photo?",
                                                            callback: (){
                                                              Navigator.pop(context);
                                                              expensePvr.removeFile(index);
                                                            },
                                                            isLoading: false);
                                                      },
                                                      icon: const Icon(Icons.clear),
                                                    ),
                                                  ],
                                                ),
                                                3.height,
                                                Container(
                                                  height: 7,
                                                  decoration: BoxDecoration(
                                                    color: colorsConst.appDarkGreen,
                                                    borderRadius: const BorderRadius.only(
                                                      bottomLeft: Radius.circular(8),
                                                      bottomRight: Radius.circular(8),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                10.height,
                                // InkWell(
                                //   onTap: (){
                                //     expensePvr.pickFile();
                                //   },
                                //   child: Container(
                                //     width: kIsWeb?webHeight:phoneHeight,height: 70,
                                //     decoration: customDecoration.baseBackgroundDecoration(
                                //         color: Colors.white,
                                //         radius: 10,
                                //         borderColor: colorsConst.litGrey
                                //     ),
                                //     child: Row(
                                //       mainAxisAlignment: MainAxisAlignment.center,
                                //       children: [
                                //         SvgPicture.asset(assets.upload),5.width,
                                //         CustomText(text: "Upload File",colors: colorsConst.greyClr,),
                                //       ],
                                //     ),
                                //   ),
                                // ),10.height,
                                GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 30,
                                      mainAxisSpacing: 30,
                                      mainAxisExtent: 70,
                                    ),
                                    shrinkWrap: true,
                                    physics: const ScrollPhysics(),
                                    itemCount: expensePvr.selectedPhotos1.length,
                                    itemBuilder: (context,index){
                                      return Row(
                                        children: [
                                          Container(
                                            height: 70,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color: Colors.grey[200], // optional background
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child: Image.file(
                                              File(expensePvr.selectedPhotos1[index]),
                                              fit: BoxFit.cover, // or BoxFit.contain if you want full image
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              utils.customDialog(
                                                  context: context,
                                                  title: "Do you want to",
                                                  title2:"Delete this photo?",
                                                  callback: (){
                                                    Navigator.pop(context);
                                                    expensePvr.removePhotos(index);
                                                  },
                                                  isLoading: false);
                                            },
                                            icon: SvgPicture.asset(assets.deleteValue),
                                          ),
                                        ],
                                      );
                                    }),
                                30.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomLoadingButton(
                                        callback: (){
                                          if (expensePvr.otherExp[expensePvr.otherIndex].date.text.trim().isEmpty) {
                                            utils.showWarningToast(context,text: "Please fill days");
                                          }else if (expensePvr.otherExp[expensePvr.otherIndex].particular.text.trim().isEmpty) {
                                            utils.showWarningToast(context,text: "Please fill particular reason");
                                          } else if (expensePvr.otherExp[expensePvr.otherIndex].amount.text.trim().isEmpty) {
                                            utils.showWarningToast(context,text: "Please fill amount");
                                          } else {
                                            expensePvr.addOtherExp();
                                          }
                                        }, isLoading: false,text: "Add More",
                                        backgroundColor: colorsConst.primary,radius: 10, width: splitWidth),
                                    CustomLoadingButton(
                                        callback: (){
                                          if (expensePvr.otherExp[expensePvr.otherIndex].date.text.trim().isEmpty&&
                                              expensePvr.otherExp[expensePvr.otherIndex].particular.text.trim().isEmpty&&
                                              expensePvr.otherExp[expensePvr.otherIndex].amount.text.trim().isEmpty) {
                                            _myFocusScopeNode.unfocus();
                                            expensePvr.updateIndex(1);
                                          }else{
                                            if (expensePvr.otherExp[expensePvr.otherIndex].date.text.trim().isEmpty) {
                                              utils.showWarningToast(context,text: "Please fill days");
                                            }else if (expensePvr.otherExp[expensePvr.otherIndex].particular.text.trim().isEmpty) {
                                              utils.showWarningToast(context,text: "Please fill particular reason");
                                            } else if (expensePvr.otherExp[expensePvr.otherIndex].amount.text.trim().isEmpty) {
                                              utils.showWarningToast(context,text: "Please fill amount");
                                            } else {
                                              _myFocusScopeNode.unfocus();
                                              expensePvr.updateIndex(1);
                                            }
                                          }
                                        }, isLoading: false,text: "Next",
                                        backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: splitWidth),
                                  ],
                                ),
                                50.height,
                              ],
                            ),
                            ListView(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(width: MediaQuery.of(context).size.width*0.2,height:5),
                                    Row(
                                      children: [
                                        InkWell(onTap: (){
                                          expensePvr.changeExpTravel(false);
                                        }, child: const Icon(Icons.arrow_back_ios_rounded,size: 17,)),
                                        CustomText(text: "Bill # ${expensePvr.travelIndex+1}",colors: colorsConst.primary,isBold: true,),
                                        InkWell(onTap: (){
                                          expensePvr.changeExpTravel(true);
                                        }, child: const Icon(Icons.arrow_forward_ios_rounded,size: 17)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        CustomText(text: "Total : ",colors: colorsConst.greyClr),
                                        CustomText(text: "₹ ${expensePvr.travelAmt}",colors: colorsConst.primary,isBold: true,),
                                      ],
                                    ),
                                  ],
                                ),10.height,
                                Center(child: CustomText(text: "Travel Expenses",colors: colorsConst.primary,isBold: true,)),
                                if(expensePvr.travelExp.length!=1)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                          onTap: (){
                                            expensePvr.removeExpTravel(expensePvr.travelIndex);
                                          },
                                          child: SvgPicture.asset(assets.deleteValue)),
                                    ],
                                  ),
                                CustomTextField(
                                  text: "From Location",
                                  onChanged: (value){
                                    setState(() {
                                      expensePvr.checkValidation();
                                      expensePvr.addTravelAmt();
                                    });
                                  },
                                  isRequired: expensePvr.checkValidation(),
                                  inputFormatters: constInputFormatters.addressInput,
                                  controller: expensePvr.travelExp[expensePvr.travelIndex].from,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomTextField(
                                      isRequired: expensePvr.checkValidation(),
                                      readOnly: true,
                                      text: "Start Date",
                                      onTap: (){
                                        expensePvr.datePick(context: context, date: expensePvr.travelExp[expensePvr.travelIndex].stDate);
                                        setState(() {
                                          expensePvr.checkValidation();
                                        });
                                        expensePvr.addTravelAmt();
                                      },
                                      controller: expensePvr.travelExp[expensePvr.travelIndex].stDate,
                                      width: splitWidth,
                                    ),
                                    CustomTextField(
                                      isRequired: expensePvr.checkValidation(),
                                      text: "Start Time",
                                      readOnly: true,
                                      onTap: (){
                                        expensePvr.timePick(context, timeController: expensePvr.travelExp[expensePvr.travelIndex].stTime);
                                        setState(() {
                                          expensePvr.checkValidation();
                                        });
                                        expensePvr.addTravelAmt();
                                      },
                                      controller: expensePvr.travelExp[expensePvr.travelIndex].stTime,
                                      width: splitWidth,
                                    ),
                                  ],
                                ),
                                CustomTextField(
                                  onChanged: (value){
                                    setState(() {
                                      expensePvr.checkValidation();
                                      expensePvr.addTravelAmt();
                                    });
                                  },
                                  isRequired: expensePvr.checkValidation(),
                                  text: "To Location",
                                  inputFormatters: constInputFormatters.addressInput,
                                  controller: expensePvr.travelExp[expensePvr.travelIndex].to,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomTextField(
                                      isRequired: expensePvr.checkValidation(),
                                      readOnly: true,
                                      text: "End Date",
                                      onTap: (){
                                        expensePvr.datePick(context: context, date: expensePvr.travelExp[expensePvr.travelIndex].enDate);
                                        setState(() {
                                          expensePvr.checkValidation();
                                        });
                                        expensePvr.addTravelAmt();
                                      },
                                      controller: expensePvr.travelExp[expensePvr.travelIndex].enDate,
                                      width: splitWidth,
                                    ),
                                    CustomTextField(
                                      isRequired: expensePvr.checkValidation(),
                                      text: "End Time",
                                      readOnly: true,
                                      onTap: (){
                                        expensePvr.timePick(context, timeController: expensePvr.travelExp[expensePvr.travelIndex].enTime);
                                        setState(() {
                                          expensePvr.checkValidation();
                                        });
                                        expensePvr.addTravelAmt();
                                      },
                                      controller: expensePvr.travelExp[expensePvr.travelIndex].enTime,
                                      width: splitWidth,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    MapDropDown(
                                        isRequired: expensePvr.checkValidation(),
                                        width: splitWidth,
                                        isRefresh: expensePvr.expenseList.isEmpty?true:false,
                                        callback: (){
                                          if(!kIsWeb){
                                            expensePvr.refreshExpense();
                                          }else{
                                            expensePvr.getExpenseType();
                                          }
                                          setState(() {
                                            expensePvr.checkValidation();
                                          });
                                          expensePvr.addTravelAmt();
                                        },
                                        hintText: "Mode", list: expensePvr.expenseList,dropText: "value",
                                        saveValue: expensePvr.travelExp[expensePvr.travelIndex].mode,color: Colors.white,
                                        onChanged: (value){
                                          expensePvr.updateTraMode(value);
                                        }),
                                    CustomTextField(
                                      isRequired: expensePvr.checkValidation(),
                                      width: splitWidth,
                                      text: "Amount",
                                      onChanged: (value){
                                        expensePvr.addTravelAmt();
                                      },
                                      keyboardType: TextInputType.number,
                                      inputFormatters: constInputFormatters.amtInput,
                                      controller: expensePvr.travelExp[expensePvr.travelIndex].amt,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ],
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics: const ScrollPhysics(),
                                    itemCount: expensePvr.selectedFiles2.length,
                                    itemBuilder: (context, index) {
                                      final file = expensePvr.selectedFiles2[index];
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        child: InkWell(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>FullScreen(
                                              image: file['path'], isNetwork: false,)));
                                          },
                                          child: Container(
                                            width: kIsWeb?webHeight:phoneHeight,
                                            height: 60,
                                            decoration: customDecoration.baseBackgroundDecoration(
                                                color: Colors.white,radius: 10,
                                                borderColor: colorsConst.litGrey
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        10.width,
                                                        SvgPicture.asset(assets.docs),
                                                        10.width,
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width*0.5,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [10.height,
                                                              CustomText(text: file['name']),5.height,
                                                              CustomText(text: file['size'],colors: colorsConst.greyClr,size: 10,)
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    IconButton(
                                                      onPressed: (){
                                                        utils.customDialog(
                                                            context: context,
                                                            title: "Do you want to",
                                                            title2:"Delete this photo?",
                                                            callback: (){
                                                              Navigator.pop(context);
                                                              expensePvr.removeFile2(index);
                                                            },
                                                            isLoading: false);
                                                      },
                                                      icon: const Icon(Icons.clear),
                                                    ),
                                                  ],
                                                ),
                                                3.height,
                                                Container(
                                                  height: 7,
                                                  decoration: BoxDecoration(
                                                    color: colorsConst.appDarkGreen,
                                                    borderRadius: const BorderRadius.only(
                                                      bottomLeft: Radius.circular(8),
                                                      bottomRight: Radius.circular(8),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                10.height,
                                GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 30,
                                      mainAxisSpacing: 30,
                                      mainAxisExtent: 70,
                                    ),
                                    shrinkWrap: true,
                                    physics: const ScrollPhysics(),
                                    itemCount: expensePvr.selectedPhotos2.length,
                                    itemBuilder: (context,index){
                                      return Row(
                                        children: [
                                          Container(
                                            height: 70,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color: Colors.grey[200], // optional background
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child: Image.file(
                                              File(expensePvr.selectedPhotos2[index]),
                                              fit: BoxFit.cover, // or BoxFit.contain if you want full image
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              utils.customDialog(
                                                  context: context,
                                                  title: "Do you want to",
                                                  title2:"Delete this photo?",
                                                  callback: (){
                                                    Navigator.pop(context);
                                                    expensePvr.removePhotos2(index);
                                                  },
                                                  isLoading: false);
                                            },
                                            icon: SvgPicture.asset(assets.deleteValue),
                                          ),
                                        ],
                                      );
                                    }),30.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomLoadingButton(
                                        callback: (){
                                          if (expensePvr.travelExp[expensePvr.travelIndex].from.text.trim().isEmpty) {
                                            utils.showWarningToast(context,text: "Please fill from place");
                                          }else if (expensePvr.travelExp[expensePvr.travelIndex].stDate.text.trim().isEmpty) {
                                            utils.showWarningToast(context,text: "Please fill start date");
                                          } else if (expensePvr.travelExp[expensePvr.travelIndex].stTime.text.trim().isEmpty) {
                                            utils.showWarningToast(context,text: "Please fill start time");
                                          } else if (expensePvr.travelExp[expensePvr.travelIndex].to.text.trim().isEmpty) {
                                            utils.showWarningToast(context,text: "Please fill to place");
                                          } else if (expensePvr.travelExp[expensePvr.travelIndex].enDate.text.trim().isEmpty) {
                                            utils.showWarningToast(context, text: "Please fill end date");
                                          } else if (expensePvr.travelExp[expensePvr.travelIndex].enTime.text.trim().isEmpty) {
                                            utils.showWarningToast(context, text: "Please fill end time");
                                          } else if (expensePvr.travelExp[expensePvr.travelIndex].mode==null) {
                                            utils.showWarningToast(context, text: "Please select mode");
                                          } else if (expensePvr.travelExp[expensePvr.travelIndex].amt.text.trim().isEmpty) {
                                            utils.showWarningToast(context, text: "Please fill amount");
                                          }else {
                                            expensePvr.addExpTravel(widget.date);
                                          }
                                        }, isLoading: false,text: "Add More",
                                        backgroundColor: colorsConst.primary,radius: 10, width: splitWidth),
                                    CustomLoadingButton(
                                        callback: (){
                                          if (
                                          expensePvr.travelExp[expensePvr.travelIndex].from.text.trim().isEmpty&&
                                              // expensePvr.travelExp[expensePvr.travelIndex].stDate.text.trim().isEmpty&&
                                              expensePvr.travelExp[expensePvr.travelIndex].stTime.text.trim().isEmpty&&
                                              expensePvr.travelExp[expensePvr.travelIndex].to.text.trim().isEmpty&&
                                              expensePvr.travelExp[expensePvr.travelIndex].enDate.text.trim().isEmpty&&
                                              expensePvr.travelExp[expensePvr.travelIndex].enTime.text.trim().isEmpty&&
                                              expensePvr.travelExp[expensePvr.travelIndex].mode == null
                                          // &&expensePvr.travelExp[expensePvr.travelIndex].amt.text.trim().isEmpty
                                          ) {
                                            _myFocusScopeNode.unfocus();
                                            expensePvr.updateIndex(2);
                                          }else{
                                            if (expensePvr.travelExp[expensePvr.travelIndex].from.text.trim().isEmpty) {
                                              utils.showWarningToast(context,text: "Please fill from place");
                                            }else if (expensePvr.travelExp[expensePvr.travelIndex].stDate.text.trim().isEmpty) {
                                              utils.showWarningToast(context,text: "Please fill start date");
                                            } else if (expensePvr.travelExp[expensePvr.travelIndex].stTime.text.trim().isEmpty) {
                                              utils.showWarningToast(context,text: "Please fill start time");
                                            } else if (expensePvr.travelExp[expensePvr.travelIndex].to.text.trim().isEmpty) {
                                              utils.showWarningToast(context,text: "Please fill to place");
                                            } else if (expensePvr.travelExp[expensePvr.travelIndex].enDate.text.trim().isEmpty) {
                                              utils.showWarningToast(context, text: "Please fill end date");
                                            } else if (expensePvr.travelExp[expensePvr.travelIndex].enTime.text.trim().isEmpty) {
                                              utils.showWarningToast(context, text: "Please fill end time");
                                            } else if (expensePvr.travelExp[expensePvr.travelIndex].mode==null) {
                                              utils.showWarningToast(context, text: "Please select mode");
                                            } else if (expensePvr.travelExp[expensePvr.travelIndex].amt.text.trim().isEmpty) {
                                              utils.showWarningToast(context, text: "Please fill amount");
                                            }else {
                                              _myFocusScopeNode.unfocus();
                                              expensePvr.updateIndex(2);
                                            }
                                          }
                                        }, isLoading: false,text: "Next",
                                        backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: splitWidth),
                                  ],
                                ),50.height,
                              ],
                            ),
                            ListView(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(width: MediaQuery.of(context).size.width*0.2,height:5),
                                    Row(
                                      children: [
                                        InkWell(onTap: (){
                                          expensePvr.changeConveyanceExp(false);
                                        }, child: const Icon(Icons.arrow_back_ios_rounded,size: 17,)),
                                        CustomText(text: "Bill # ${expensePvr.conveyanceIndex+1}",colors: colorsConst.primary,isBold: true,),
                                        InkWell(onTap: (){
                                          expensePvr.changeConveyanceExp(true);
                                        }, child: const Icon(Icons.arrow_forward_ios_rounded,size: 17)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        CustomText(text: "Total : ",colors: colorsConst.greyClr),
                                        CustomText(text: "₹ ${expensePvr.convAmt}",colors: colorsConst.primary,isBold: true,),
                                      ],
                                    ),
                                  ],
                                ),10.height,
                                Center(child: CustomText(text: "Local Conveyance Expenses",colors: colorsConst.primary,isBold: true,)),
                                if(expensePvr.conveyanceExp.length!=1)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                          onTap: (){
                                            expensePvr.removeConveyanceExp(expensePvr.conveyanceIndex);
                                          },
                                          child: SvgPicture.asset(assets.deleteValue)),
                                    ],
                                  ),
                                CustomTextField(
                                  text: "Date",
                                  isRequired: expensePvr.checkValidation2(),
                                  readOnly: true,
                                  onTap: (){
                                    expensePvr.datePick(context: context, date: expensePvr.conveyanceExp[expensePvr.conveyanceIndex].date);
                                    expensePvr.addConvAmt();
                                  },
                                  controller: expensePvr.conveyanceExp[expensePvr.conveyanceIndex].date,
                                ),
                                CustomTextField(
                                  text: "From",
                                  isRequired: expensePvr.checkValidation2(),
                                  onChanged: (value){
                                    setState(() {
                                      expensePvr.checkValidation2();
                                    });
                                    expensePvr.addConvAmt();
                                  },
                                  inputFormatters: constInputFormatters.addressInput,
                                  controller: expensePvr.conveyanceExp[expensePvr.conveyanceIndex].from,
                                ),
                                CustomTextField(
                                  text: "To",
                                  isRequired: expensePvr.checkValidation2(),
                                  onChanged: (value){
                                    setState(() {
                                      expensePvr.checkValidation2();
                                    });
                                    expensePvr.addConvAmt();
                                  },
                                  inputFormatters: constInputFormatters.addressInput,
                                  controller: expensePvr.conveyanceExp[expensePvr.conveyanceIndex].to,
                                ),
                                // expensePvr.conveyanceExp[expensePvr.conveyanceIndex].mode.text.isNotEmpty?
                                // CustomTextField(
                                //   text: "Mode",
                                //   controller: expensePvr.conveyanceExp[expensePvr.conveyanceIndex].mode,
                                // ):
                                MapDropDown(
                                    isRequired: expensePvr.checkValidation2(),
                                    isRefresh: expensePvr.expenseList.isEmpty?true:false,
                                    callback: (){
                                      if(!kIsWeb){
                                        expensePvr.refreshExpense();
                                      }else{
                                        expensePvr.getExpenseType();
                                      }
                                      setState(() {
                                        expensePvr.checkValidation2();
                                      });
                                      expensePvr.addConvAmt();
                                    },
                                    hintText: "Mode", list: expensePvr.expenseList,dropText: "value",
                                    saveValue: expensePvr.conveyanceExp[expensePvr.conveyanceIndex].mode,color: Colors.white,
                                    onChanged: (value){
                                      expensePvr.updateMode(value);
                                    }),
                                CustomTextField(
                                  isRequired: expensePvr.checkValidation2(),
                                  text: "Amount",
                                  onChanged: (value){
                                    setState(() {
                                      expensePvr.checkValidation2();
                                    });
                                    expensePvr.addConvAmt();
                                  },
                                  keyboardType: TextInputType.number,
                                  inputFormatters: constInputFormatters.amtInput,
                                  controller: expensePvr.conveyanceExp[expensePvr.conveyanceIndex].amt,
                                  textInputAction: TextInputAction.done,
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics: const ScrollPhysics(),
                                    itemCount: expensePvr.selectedFiles3.length,
                                    itemBuilder: (context, index) {
                                      final file = expensePvr.selectedFiles3[index];
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        child: InkWell(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>FullScreen(
                                              image: file['path'], isNetwork: false,)));
                                          },
                                          child: Container(
                                            width: kIsWeb?webHeight:phoneHeight,
                                            height: 60,
                                            decoration: customDecoration.baseBackgroundDecoration(
                                                color: Colors.white,radius: 10,
                                                borderColor: colorsConst.litGrey
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        10.width,
                                                        SvgPicture.asset(assets.docs),
                                                        10.width,
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width*0.5,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [10.height,
                                                              CustomText(text: file['name']),5.height,
                                                              CustomText(text: file['size'],colors: colorsConst.greyClr,size: 10,)
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    IconButton(
                                                      onPressed: (){
                                                        utils.customDialog(
                                                            context: context,
                                                            title: "Do you want to",
                                                            title2:"Delete this photo?",
                                                            callback: (){
                                                              Navigator.pop(context);
                                                              expensePvr.removeFile3(index);
                                                            },
                                                            isLoading: false);
                                                      },
                                                      icon: const Icon(Icons.clear),
                                                    ),
                                                  ],
                                                ),
                                                3.height,
                                                Container(
                                                  height: 7,
                                                  decoration: BoxDecoration(
                                                    color: colorsConst.appDarkGreen,
                                                    borderRadius: const BorderRadius.only(
                                                      bottomLeft: Radius.circular(8),
                                                      bottomRight: Radius.circular(8),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                10.height,
                                // InkWell(
                                //   onTap: (){
                                //     expensePvr.pickFile3();
                                //   },
                                //   child: Container(
                                //     width: kIsWeb?webHeight:phoneHeight,height: 70,
                                //     decoration: customDecoration.baseBackgroundDecoration(
                                //         color: Colors.white,
                                //         radius: 10,
                                //         borderColor: colorsConst.litGrey
                                //     ),
                                //     child: Row(
                                //       mainAxisAlignment: MainAxisAlignment.center,
                                //       children: [
                                //         SvgPicture.asset(assets.upload),5.width,
                                //         CustomText(text: "Upload File",colors: colorsConst.greyClr,),
                                //       ],
                                //     ),
                                //   ),
                                // ),10.height,
                                GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 30,
                                      mainAxisSpacing: 30,
                                      mainAxisExtent: 70,
                                    ),
                                    shrinkWrap: true,
                                    physics: const ScrollPhysics(),
                                    itemCount: expensePvr.selectedPhotos3.length,
                                    itemBuilder: (context,index){
                                      return Row(
                                        children: [
                                          Container(
                                            height: 70,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color: Colors.grey[200], // optional background
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child: Image.file(
                                              File(expensePvr.selectedPhotos3[index]),
                                              fit: BoxFit.cover, // or BoxFit.contain if you want full image
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              utils.customDialog(
                                                  context: context,
                                                  title: "Do you want to",
                                                  title2:"Delete this photo?",
                                                  callback: (){
                                                    Navigator.pop(context);
                                                    expensePvr.removePhotos3(index);
                                                  },
                                                  isLoading: false);
                                            },
                                            icon: SvgPicture.asset(assets.deleteValue),
                                          ),
                                        ],
                                      );
                                    }),30.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomLoadingButton(
                                        callback: (){
                                          if (expensePvr.conveyanceExp[expensePvr.conveyanceIndex].date.text.trim().isEmpty) {
                                            utils.showWarningToast(context,text: "Please fill date");
                                          }else if (expensePvr.conveyanceExp[expensePvr.conveyanceIndex].from.text.trim().isEmpty) {
                                            utils.showWarningToast(context,text: "Please fill from");
                                          } else if (expensePvr.conveyanceExp[expensePvr.conveyanceIndex].to.text.trim().isEmpty) {
                                            utils.showWarningToast(context,text: "Please fill to");
                                          } else if (expensePvr.conveyanceExp[expensePvr.conveyanceIndex].mode==null) {
                                            utils.showWarningToast(context,text: "Please fill mode");
                                          } else if (expensePvr.conveyanceExp[expensePvr.conveyanceIndex].amt.text.trim().isEmpty) {
                                            utils.showWarningToast(context,text: "Please fill amount");
                                          }else {
                                            expensePvr.addConveyanceExp(widget.date);
                                          }
                                        }, isLoading: false,text: "Add More",
                                        backgroundColor: colorsConst.primary,radius: 10, width: splitWidth),
                                    CustomLoadingButton(
                                        callback: (){
                                          if (
                                          // expensePvr.conveyanceExp[expensePvr.conveyanceIndex].date.text.trim().isEmpty&&
                                          expensePvr.conveyanceExp[expensePvr.conveyanceIndex].from.text.trim().isEmpty&&
                                              expensePvr.conveyanceExp[expensePvr.conveyanceIndex].to.text.trim().isEmpty&&
                                              expensePvr.conveyanceExp[expensePvr.conveyanceIndex].mode == null
                                          // &&expensePvr.conveyanceExp[expensePvr.conveyanceIndex].amt.text.trim().isEmpty
                                          ) {
                                            _myFocusScopeNode.unfocus();
                                            expensePvr.updateIndex(3);
                                          }else{
                                            if (expensePvr.conveyanceExp[expensePvr.conveyanceIndex].date.text.trim().isEmpty) {
                                              utils.showWarningToast(context,text: "Please fill date");
                                            }else if (expensePvr.conveyanceExp[expensePvr.conveyanceIndex].from.text.trim().isEmpty) {
                                              utils.showWarningToast(context,text: "Please fill from");
                                            } else if (expensePvr.conveyanceExp[expensePvr.conveyanceIndex].to.text.trim().isEmpty) {
                                              utils.showWarningToast(context,text: "Please fill to");
                                            } else if (expensePvr.conveyanceExp[expensePvr.conveyanceIndex].mode==null) {
                                              utils.showWarningToast(context,text: "Please fill mode");
                                            } else if (expensePvr.conveyanceExp[expensePvr.conveyanceIndex].amt.text.trim().isEmpty) {
                                              utils.showWarningToast(context,text: "Please fill amount");
                                            }else {
                                              _myFocusScopeNode.unfocus();
                                              expensePvr.updateIndex(3);
                                            }
                                          }
                                        }, isLoading: false,text: "Next",
                                        backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: splitWidth),
                                  ],
                                ),50.height,
                              ],
                            ),
                            // SingleChildScrollView(
                            //   child: Column(
                            //     children: [
                            //       ListView.builder(
                            //           shrinkWrap: true,
                            //           physics: const ScrollPhysics(),
                            //           itemCount: expensePvr.selectedFiles1.length,
                            //           itemBuilder: (context, index) {
                            //             final file = expensePvr.selectedFiles1[index];
                            //             return InkWell(
                            //               onTap: (){
                            //                 Navigator.push(context, MaterialPageRoute(builder: (context)=>FullScreen(
                            //                   image: file['path'], isNetwork: false,)));
                            //               },
                            //               child: Container(
                            //                 width: kIsWeb?webHeight:phoneHeight,
                            //                 height: 60,
                            //                 decoration: customDecoration.baseBackgroundDecoration(
                            //                     color: Colors.white,radius: 10,
                            //                     borderColor: colorsConst.litGrey
                            //                 ),
                            //                 child: Column(
                            //                   children: [
                            //                     Row(
                            //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //                       children: [
                            //                         Row(
                            //                           children: [
                            //                             10.width,
                            //                             SvgPicture.asset(assets.docs),
                            //                             10.width,
                            //                             SizedBox(
                            //                               width: MediaQuery.of(context).size.width*0.5,
                            //                               child: Column(
                            //                                 crossAxisAlignment: CrossAxisAlignment.start,
                            //                                 children: [10.height,
                            //                                   CustomText(text: file['name']),5.height,
                            //                                   CustomText(text: file['size'],colors: colorsConst.greyClr,size: 10,)
                            //                                 ],
                            //                               ),
                            //                             ),
                            //                           ],
                            //                         ),
                            //                         IconButton(
                            //                           onPressed: (){
                            //                             expensePvr.removeFile(index);
                            //                           },
                            //                           icon: const Icon(Icons.clear),
                            //                         ),
                            //                       ],
                            //                     ),
                            //                     3.height,
                            //                     Container(
                            //                       height: 7,
                            //                       decoration: BoxDecoration(
                            //                         color: colorsConst.appDarkGreen,
                            //                         borderRadius: const BorderRadius.only(
                            //                           bottomLeft: Radius.circular(8),
                            //                           bottomRight: Radius.circular(8),
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ],
                            //                 ),
                            //               ),
                            //             );
                            //           }),
                            //       10.height,
                            //       InkWell(
                            //         onTap: (){
                            //           expensePvr.pickFile();
                            //         },
                            //         child: Container(
                            //           width: kIsWeb?webHeight:phoneHeight,height: 70,
                            //           decoration: customDecoration.baseBackgroundDecoration(
                            //               color: Colors.white,
                            //               radius: 10,
                            //               borderColor: colorsConst.litGrey
                            //           ),
                            //           child: Row(
                            //             mainAxisAlignment: MainAxisAlignment.center,
                            //             children: [
                            //               SvgPicture.asset(assets.upload),5.width,
                            //               CustomText(text: "Upload File",colors: colorsConst.greyClr,),
                            //             ],
                            //           ),
                            //         ),
                            //       ),10.height,
                            //       GridView.builder(
                            //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            //             crossAxisCount: 2,
                            //             crossAxisSpacing: 30,
                            //             mainAxisSpacing: 30,
                            //             mainAxisExtent: 70,
                            //           ),
                            //           shrinkWrap: true,
                            //           physics: const ScrollPhysics(),
                            //           itemCount: expensePvr.selectedPhotos1.length,
                            //           itemBuilder: (context,index){
                            //             return Row(
                            //               children: [
                            //                 Container(
                            //                   height: 70,
                            //                   width: 90,
                            //                   decoration: BoxDecoration(
                            //                     borderRadius: BorderRadius.circular(5),
                            //                     color: Colors.grey[200], // optional background
                            //                   ),
                            //                   clipBehavior: Clip.hardEdge,
                            //                   child: Image.file(
                            //                     File(expensePvr.selectedPhotos1[index]),
                            //                     fit: BoxFit.cover, // or BoxFit.contain if you want full image
                            //                   ),
                            //                 ),
                            //                 IconButton(
                            //                   onPressed: () {
                            //                     expensePvr.removePhotos(index);
                            //                   },
                            //                   icon: SvgPicture.asset(assets.deleteValue),
                            //                 ),
                            //               ],
                            //             );
                            //           }),
                            //       40.height,
                            //       Row(
                            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //         children: [
                            //           CustomLoadingButton(
                            //               callback: (){
                            //                 expensePvr.updateIndex(2);
                            //                 }, isLoading: false,text: "Back",
                            //               backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: splitWidth),
                            //           CustomLoadingButton(
                            //               callback: (){
                            //                 expensePvr.updateIndex(4);
                            //               }, isLoading: false,text: "Next",
                            //               backgroundColor: colorsConst.primary,radius: 10, width: splitWidth),
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    CustomText(text: "Total Expenses\n",colors: colorsConst.primary,isBold: true,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(text: "DA/Board/Lodging/Other Expenses",colors: colorsConst.greyClr),
                                        CustomText(text: "₹ ${expensePvr.otherAmt}",colors: colorsConst.appRed,isBold: true,),
                                      ],
                                    ),10.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(text: "Travel Expenses",colors: colorsConst.greyClr),
                                        CustomText(text: "₹ ${expensePvr.travelAmt}",colors: colorsConst.appRed,isBold: true,),
                                      ],
                                    ),10.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(text: "Local Conveyance Expenses",colors: colorsConst.greyClr),
                                        CustomText(text: "₹ ${expensePvr.convAmt}",colors: colorsConst.appRed,isBold: true,),
                                      ],
                                    ),10.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(text: "Total Expenses",colors: colorsConst.greyClr),
                                        CustomText(text: "₹ ${expensePvr.totalAmt.text}",colors: colorsConst.appRed,isBold: true,),
                                      ],
                                    ),
                                  ],
                                ),
                                // CustomText(text: "Advance & Final Settlement",colors: colorsConst.primary,isBold: true,),
                                // CustomTextField(text: "Advance",
                                //   controller: expensePvr.advance,
                                //   inputFormatters: constInputFormatters.numberInput,
                                //   keyboardType: TextInputType.number,
                                //   onChanged: (value){
                                //     expensePvr.calBalance();
                                //   },
                                // ),
                                // CustomTextField(text: "Total Amount",
                                //   controller: expensePvr.totalAmt,
                                //   readOnly: true,
                                //   keyboardType: TextInputType.number,
                                //   isRequired: true,
                                // ),
                                // CustomTextField(text: "Balance To/From The Company",
                                //   controller: expensePvr.balanceTo,
                                // ),
                                // CustomTextField(text: "Voucher No",
                                //   inputFormatters: constInputFormatters.accNoInput,
                                //   textCapitalization: TextCapitalization.characters,
                                //   controller: expensePvr.voucherNo,
                                // ),10.height,
                                // CustomText(text: "Accounts",colors: colorsConst.primary,isBold: true,),
                                // CustomTextField(text: "Debit To",
                                //   controller: expensePvr.debitTo,
                                //   textInputAction: TextInputAction.done,
                                // ),
                                25.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomLoadingButton(
                                        callback: (){
                                          Future.microtask(() => Navigator.pop(context));
                                        }, isLoading: false,text: "Cancel",
                                        backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: splitWidth),
                                    CustomLoadingButton(
                                        callback: (){
                                          bool isValid = true;
                                          if (expensePvr.totalAmt.text=="0.0") {
                                            utils.showWarningToast(context, text: "Please add the expenses to the report");
                                            expensePvr.addCtr.reset();
                                            isValid = false;
                                          }
                                          if(expensePvr.convAmt!=0){
                                            for (var i = 0; i < expensePvr.conveyanceExp.length; i++) {
                                              if (expensePvr.conveyanceExp[i].date.text.trim().isEmpty ||
                                                  expensePvr.conveyanceExp[i].from.text.trim().isEmpty ||
                                                  expensePvr.conveyanceExp[i].to.text.trim().isEmpty ||
                                                  expensePvr.conveyanceExp[i].mode == null ||
                                                  expensePvr.conveyanceExp[i].amt.text.trim().isEmpty) {
                                                utils.showWarningToast(context, text: "Check Local Conveyance Expenses Bill No ${i + 1}");
                                                expensePvr.addCtr.reset();
                                                isValid = false;
                                                break;
                                              }
                                            }
                                          }
                                          if(expensePvr.travelAmt!=0){
                                            for (var i = 0; i < expensePvr.travelExp.length; i++) {
                                              if (expensePvr.travelExp[i].from.text.trim().isEmpty ||
                                                  expensePvr.travelExp[i].stDate.text.trim().isEmpty ||
                                                  expensePvr.travelExp[i].stTime.text.trim().isEmpty ||
                                                  expensePvr.travelExp[i].to.text.trim().isEmpty ||
                                                  expensePvr.travelExp[i].enDate.text.trim().isEmpty ||
                                                  expensePvr.travelExp[i].enTime.text.trim().isEmpty ||
                                                  expensePvr.travelExp[i].mode == null ||
                                                  expensePvr.travelExp[i].amt.text.trim().isEmpty) {
                                                utils.showWarningToast(context, text: "Check Travel Expenses Bill No ${i + 1}");
                                                expensePvr.addCtr.reset();
                                                isValid = false;
                                                break;
                                              }
                                            }
                                          }
                                          if(expensePvr.otherAmt!=0){
                                            for (var i = 0; i < expensePvr.otherExp.length; i++) {
                                              if (expensePvr.otherExp[i].date.text.trim().isEmpty ||
                                                  expensePvr.otherExp[i].particular.text.trim().isEmpty ||
                                                  expensePvr.otherExp[i].amount.text.trim().isEmpty) {
                                                utils.showWarningToast(context, text: "DA/Board/Lodging/Other Expenses Bill No ${i + 1}");
                                                expensePvr.addCtr.reset();
                                                isValid = false;
                                                break;
                                              }
                                            }
                                          }
                                          if (isValid) {
                                            _myFocusScopeNode.unfocus();
                                            expensePvr.insertExpense(
                                              context,
                                              taskId: widget.taskId.toString(),
                                              coId: widget.coId.toString(),
                                              numberList: widget.numberList,
                                              companyName: widget.companyName,
                                              tType: widget.type,
                                              desc: widget.desc,
                                            );
                                          }

                                        }, isLoading: true,text: "Save",controller: expensePvr.addCtr,
                                        backgroundColor: colorsConst.primary,radius: 10, width: splitWidth),
                                  ],
                                ),
                              ],
                            ),
                          ]
                      ),
                    ),
                    50.height,
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


