import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/key_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/leave_provider.dart';

class LeaveTypes extends StatefulWidget {
  const LeaveTypes({super.key});

  @override
  State<LeaveTypes> createState() => _LeaveTypesState();
}

class _LeaveTypesState extends State<LeaveTypes> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LeaveProvider>(builder: (context,levProvider,_){
      return SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: PreferredSize(
            preferredSize: Size(300, 50),
            child: CustomAppbar(text: "Leave Types",
            isButton: true,
              callback: (){
                levProvider.changePage(context);
              },
              buttonCallback: () {
                levProvider.changeAddType();
              },),
          ),
          body: PopScope(
            canPop: false,
            onPopInvoked: (bool pop) async {
              levProvider.changePage(context);
            },
            child: Center(
              child: Center(
                child: Column(
                  children: [
                    20.height,
                    levProvider.getTypes == false ?
                    const Loading() :
                    levProvider.types.isEmpty ?
                    const CustomText(text: "No Types Found") :
                    Expanded(
                      child: kIsWeb ?
                      GridView.builder(
                        primary: false,
                        itemCount: levProvider.types.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 50.0,
                            mainAxisSpacing: 20.0,
                            mainAxisExtent: 100

                        ),
                        itemBuilder: (context, index) {
                          return itemBuilder(context,index,levProvider);
                        },
                      ) : ListView.builder(
                          itemCount: levProvider.types.length,
                          itemBuilder: (context, index) {
                            return itemBuilder(context,index,levProvider);
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
  Widget itemBuilder(BuildContext context, int index, var levProvider) {
    var webWidth=MediaQuery.of(context).size.width*0.7;
    var phoneWidth=MediaQuery.of(context).size.width*0.95;
    return Column(
      children: [
        Container(
          decoration: customDecoration.baseBackgroundDecoration(
            color: Colors.white,
            radius: 5,
            borderColor: Colors.grey.shade200,
          ),
          width: kIsWeb?webWidth:phoneWidth,
          height: kIsWeb
              ? MediaQuery.of(context).size.height * 0.08
              : MediaQuery.of(context).size.height * 0.08,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(text: levProvider.types[index]["type"]),
                InkWell(
                  onTap: () {
                    utils.customDialog(
                      context: context,
                      title: "Are you sure you want to delete",
                      callback: () {
                        levProvider.deleteLeaveType(context,levProvider.types[index]["id"]);
                      },
                      roundedLoadingButtonController: levProvider.submitCtr,
                      isLoading: true,
                    );
                  },
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: SvgPicture.asset(assets.deleteValue),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!kIsWeb) 10.height,
      ],
    );
  }
}


class AddType extends StatefulWidget {
  const AddType({super.key});

  @override
  State<AddType> createState() => _AddTypeState();
}

class _AddTypeState extends State<AddType> {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<LeaveProvider >(context, listen: false).reason.clear();
    });
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
    _myFocusScopeNode.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<LeaveProvider>(builder: (context,levProvider,_){
      var webWidth=MediaQuery.of(context).size.width*0.7;
      var phoneWidth=MediaQuery.of(context).size.width*0.95;
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: Size(300, 50),
              child: CustomAppbar(text: "Add Leave Type",
                callback: () {
                  _myFocusScopeNode.unfocus();
                  levProvider.changePage2();
                  },),
            ),
            body: PopScope(
              canPop: false,
              onPopInvoked: (bool pop) async {
                _myFocusScopeNode.unfocus();
                levProvider.changePage2();
              },
              child: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: kIsWeb?webWidth:phoneWidth,
                    child: Column(
                      children: [
                        70.height,
                        CustomTextField(text: "Type",
                          isRequired: true,
                          inputFormatters: constInputFormatters.numTextInput,
                          controller: levProvider.reason,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          width: kIsWeb?webWidth:phoneWidth,
                        ),
                        70.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomLoadingButton(
                                callback: (){
                                  levProvider.changePage2();
                                  _myFocusScopeNode.unfocus();
                                }, isLoading: false,text: "Cancel",
                                backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
                            CustomLoadingButton(
                              width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                              isLoading: true,
                              callback: () {
                                if (levProvider.reason.text.trim().isNotEmpty) {
                                  _myFocusScopeNode.unfocus();
                                  levProvider.addTypes(context);
                                } else {
                                  utils.showWarningToast(context,text: "Please fill leave type");
                                  levProvider.addCtr.reset();
                                }
                              },
                              controller: levProvider.addCtr, text: 'Save', backgroundColor: colorsConst.primary, radius: 10,),
                          ],
                        ),
                        50.height
                      ],
                    ),
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

