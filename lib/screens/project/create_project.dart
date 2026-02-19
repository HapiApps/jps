import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/screens/project/viamap.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_dropdown.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_textfield.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/constant/key_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/location_provider.dart';
import '../../view_model/project_provider.dart';

class CreateProject extends StatefulWidget {
  const CreateProject({super.key});

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> with TickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    final prjProvider = Provider.of<ProjectProvider>(context, listen: false);
    prjProvider.initValues();
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    locationProvider.manageLocation(context, false);
    if (locationProvider.latitude.isNotEmpty && locationProvider.longitude.isNotEmpty) {
      final lat = double.tryParse(locationProvider.latitude);
      final lng = double.tryParse(locationProvider.longitude);
      if (lat != null && lng != null) {
        prjProvider.getAdd(lat, lng);
      }
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
    var webWidth=MediaQuery.of(context).size.width*0.7;
    var phoneWidth=MediaQuery.of(context).size.width*0.9;
    return Consumer2<ProjectProvider,LocationProvider>(builder: (context,prjProvider,locPvr,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: constValue.addProject),
            ),
            backgroundColor: colorsConst.bacColor,
            body: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  child: Column(
                    children: [
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextField(
                              width: kIsWeb?webWidth/2.05:phoneWidth/2.05,
                              isRequired: true,readOnly: true,
                              text: constValue.startDate,
                              onTap: (){
                                _myFocusScopeNode.unfocus();
                                utils.datePick(context: context,textEditingController: prjProvider.date1);
                              },
                              controller: prjProvider.date1),
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
                      CustomTextField(text: constValue.projectName,controller: prjProvider.projectName,
                        keyboardType: TextInputType.multiline,isRequired: true,
                        width: kIsWeb?webWidth:phoneWidth,
                      ),
                      Row(
                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextField(text: "Door No",controller: prjProvider.presentDoNo,
                            keyboardType: TextInputType.multiline,isRequired: true,
                            width: kIsWeb?webWidth/1.1:phoneWidth/1.1,
                          ),
                          InkWell(
                            onTap: (){
                              _myFocusScopeNode.unfocus();
                              if(locPvr.latitude==""&&locPvr.longitude==""){
                                locPvr.manageLocation(context,true);
                              }else{
                                utils.navigatePage(context, ()=>ViaMap());
                              }
                            },
                            child: SvgPicture.asset(assets.location,width: 25,height: 25,),
                          )
                        ],
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
                            inputFormatters: constInputFormatters.numTextInput,isRequired: true,
                            width: kIsWeb?webWidth/2.05:phoneWidth/2.05,
                          ),
                          CustomTextField(text: "Pincode",controller: prjProvider.presentPin,
                            keyboardType: TextInputType.number,isRequired: true,
                            inputFormatters: constInputFormatters.pinCodeInput,
                            width: kIsWeb?webWidth/2.05:phoneWidth/2.05,
                          ),
                        ],
                      ),
                      CustomTextField(text: "Between meter",controller: prjProvider.betweenMtr,
                        keyboardType: TextInputType.number,
                        width: kIsWeb?webWidth:phoneWidth,
                        textInputAction: TextInputAction.done,
                        inputFormatters: constInputFormatters.numberInput,
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
                            width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                            isLoading: true,
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
                                prjProvider.checkProjectAddress(context);
                              }
                            },
                            controller: prjProvider.addCtr, text: 'Save', backgroundColor: colorsConst.primary, radius: 10,),
                        ],
                      ),
                      30.height,
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



