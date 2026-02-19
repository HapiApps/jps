import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_code/model/project/project_model.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_dropdown.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_textfield.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/constant/key_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/project_provider.dart';

class UpdateProject extends StatefulWidget {
  final ProjectModel data;
  const UpdateProject({super.key, required this.data});

  @override
  State<UpdateProject> createState() => _UpdateProjectState();
}

class _UpdateProjectState extends State<UpdateProject> with TickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    final prjProvider = Provider.of<ProjectProvider>(context, listen: false);
    prjProvider.setValue(widget.data);
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
    var phoneWidth=MediaQuery.of(context).size.width*0.9;
    return Consumer<ProjectProvider>(builder: (context,prjProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size(300, 50),
            child: CustomAppbar(text: constValue.updateProject),
          ),
          backgroundColor: colorsConst.bacColor,
          // floatingActionButton: ,
          body: Center(
            child: SizedBox(
              width: kIsWeb?webWidth:phoneWidth,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    20.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextField(
                            width: kIsWeb?webWidth/2.05:phoneWidth/2.05,
                            isRequired: true,readOnly: true,
                            text: constValue.startDate,
                            controller: prjProvider.date1,
                          onTap: (){
                            _myFocusScopeNode.unfocus();
                            utils.datePick(context: context,textEditingController: prjProvider.date1);
                          },),
                        CustomTextField(
                            width: kIsWeb?webWidth/2.05:phoneWidth/2.05,
                            isRequired: true,readOnly: true,
                            text: constValue.endDate,
                            controller: prjProvider.date2,
                          onTap: (){
                            _myFocusScopeNode.unfocus();
                            utils.datePick(context: context,textEditingController: prjProvider.date2);
                          },)
                      ],
                    ),
                    // 20.height,
                    CustomTextField(text: constValue.projectName,controller: prjProvider.projectName,
                      keyboardType: TextInputType.multiline,isRequired: true,
                      width: kIsWeb?webWidth:phoneWidth,
                    ),
                    CustomTextField(text: "Door No",controller: prjProvider.presentDoNo,
                      keyboardType: TextInputType.multiline,isRequired: true,
                      width: kIsWeb?webWidth:phoneWidth,
                    ),
                    CustomTextField(text: "Street Name",controller: prjProvider.presentStreet,
                      keyboardType: TextInputType.multiline,isRequired: true,
                      width: kIsWeb?webWidth:phoneWidth,
                    ),
                    CustomTextField(text: "Area",controller: prjProvider.presentArea,
                      keyboardType: TextInputType.multiline,isRequired: true,
                      width: kIsWeb?webWidth:phoneWidth,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextField(text: "City",controller: prjProvider.presentCity,
                          width: kIsWeb?webWidth/2.05:phoneWidth/2.05,isRequired: true,
                        ),
                        CustomDropDown(
                          size: 15,isRequired: true,
                          color: Colors.grey.shade100,
                          text: "State",saveValue: prjProvider.state,valueList: prjProvider.stateList,
                          onChanged: (value) {
                            prjProvider.changeState(value);
                          },
                          width: kIsWeb?webWidth/2.05:phoneWidth/2.05,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextField(text: "Country",controller: prjProvider.presentCountry,
                          inputFormatters: constInputFormatters.numTextInput,
                          width: kIsWeb?webWidth/2.05:phoneWidth/2.05,isRequired: true,
                        ),
                        CustomTextField(text: "Pincode",controller: prjProvider.presentPin,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,isRequired: true,
                          inputFormatters: constInputFormatters.pinCodeInput,
                          width: kIsWeb?webWidth/2.05:phoneWidth/2.05,
                        ),
                      ],
                    ),
                    CustomTextField(text: "Between meter",controller: prjProvider.betweenMtr,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: constInputFormatters.numberInput,
                      width: kIsWeb?webWidth:phoneWidth,
                    ),
                    30.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomLoadingButton(
                            callback: (){
                              Future.microtask(() => Navigator.pop(context));
                            }, isLoading: false,text: "Cancel",
                            backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
                        CustomLoadingButton(
                          isLoading: true,radius: 10,backgroundColor: colorsConst.primary,
                          width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                          callback: () {
                            if(prjProvider.projectName.text.trim().isEmpty){
                              utils.showWarningToast(context,text: "Please fill project name");
                              prjProvider.addCtr.reset();
                            }else if(prjProvider.presentDoNo.text.trim().isEmpty){
                              utils.showWarningToast(context,text: "Please fill door number");
                              prjProvider.addCtr.reset();
                            }else if(prjProvider.presentStreet.text.trim().isEmpty){
                              utils.showWarningToast(context,text: "Please fill street name");
                              prjProvider.addCtr.reset();
                            }else if(prjProvider.presentArea.text.trim().isEmpty){
                              utils.showWarningToast(context,text: "Please fill area");
                              prjProvider.addCtr.reset();
                            }else if(prjProvider.presentCity.text.trim().isEmpty){
                              utils.showWarningToast(context,text: "Please fill city");
                              prjProvider.addCtr.reset();
                            }else if(prjProvider.state==null){
                              utils.showWarningToast(context,text: "Please select state");
                              prjProvider.addCtr.reset();
                            }else if(prjProvider.presentCountry.text.trim().isEmpty){
                              utils.showWarningToast(context,text: "Please fill country");
                              prjProvider.addCtr.reset();
                            }else if(prjProvider.presentPin.text.trim().isEmpty){
                              utils.showWarningToast(context,text: "Please fill pincode");
                              prjProvider.addCtr.reset();
                            }else{
                              _myFocusScopeNode.unfocus();
                              prjProvider.checkProjectAddress(context,isUpdate: true,id: widget.data.id);
                            }
                          },
                          controller: prjProvider.addCtr, text: 'Save',),
                      ],
                    ),50.height
                  ],
                ),
              ),
            ),
          ),
        ),
            ),
      );
    });
  }
}



