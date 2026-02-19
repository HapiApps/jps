import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_code/model/user_model.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:master_code/view_model/leave_provider.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../component/search_drop_down2.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/key_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';

class AddLeaveRules extends StatefulWidget {
  const AddLeaveRules({super.key});

  @override
  State<AddLeaveRules> createState() => _AddLeaveRulesState();
}

class _AddLeaveRulesState extends State<AddLeaveRules> {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<LeaveProvider >(context, listen: false).iniValues();
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
    return Consumer2<LeaveProvider,EmployeeProvider>(builder: (context,levProvider,empProvider,_){
      return SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: PreferredSize(
            preferredSize: Size(300, 50),
            child: CustomAppbar(text: "Add Annual Leaves",
              callback: () {
                _myFocusScopeNode.unfocus();
                levProvider.changePage(context);
              },),
          ),
          body: PopScope(
            canPop: false,
            onPopInvoked: (bool pop) async {
              _myFocusScopeNode.unfocus();
              levProvider.changePage(context);
            },
            child: Center(
              child: Column(
                children: [
                  20.height,
                  CustomSearchDropDown(
                    isUser: true,
                    controller: levProvider.search,
                    list2: empProvider.activeEmps,
                    color: Colors.grey.shade100,
                    width: kIsWeb?webWidth:phoneWidth,
                    hintText: "",
                    saveValue: levProvider.name,
                    onChanged: (Object? value) {
                      levProvider.selectUser2(value);
                    },
                    dropText: 'name',),
                  20.height,
                  levProvider.name==null?
                  CustomText(text: "Select User Name"):
                  levProvider.isLeave == true ?
                  Expanded(
                    child: SizedBox(
                      width: kIsWeb?webWidth:phoneWidth,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: levProvider.types.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Container(
                                    decoration: customDecoration
                                        .baseBackgroundDecoration(
                                        color: Colors.grey.shade100,
                                        radius: 5
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        CustomText(text: "  ${levProvider
                                            .types[index]["type"]}"),
                                        SizedBox(
                                          width: 130,
                                          height: 40,
                                          child: TextField(
                                            controller: levProvider
                                                .types[index]["days"],
                                            keyboardType: TextInputType.number,
                                            textInputAction: index ==
                                                levProvider.types.length - 1
                                                ? TextInputAction.done
                                                : TextInputAction.next,
                                            inputFormatters: constInputFormatters
                                                .numberInput,
                                            onChanged: (value) {
                                              setState(() {
                                                if (value.toString() != "") {
                                                  levProvider.rulesList.add({
                                                    "emp_id": levProvider.nameId,
                                                    "type_id": levProvider.types[index]["id"],
                                                    "days": levProvider.types[index]["days"].text.trim(),
                                                    "created_by": localData.storage.read("id"),
                                                    "platform": "1",
                                                    "cos_id":localData.storage.read("cos_id")
                                                  });
                                                }
                                              });
                                            },
                                            decoration: InputDecoration(
                                              hintText: "Days",
                                              fillColor: Colors.grey.shade100,
                                              filled: true,
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.grey,),
                                                  borderRadius: BorderRadius
                                                      .circular(1)
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey),
                                                  borderRadius: BorderRadius
                                                      .circular(1)
                                              ),
                                              focusedErrorBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey),
                                                  borderRadius: BorderRadius
                                                      .circular(1)
                                              ),
                                              contentPadding: const EdgeInsets
                                                  .fromLTRB(10, 0, 10, 0),
                                              errorBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey),
                                                  borderRadius: BorderRadius
                                                      .circular(1)
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                                20.height,
                                if(index == levProvider.types.length - 1)
                                  20.height,
                                if(index == levProvider.types.length - 1)
                                SizedBox(
                                    width: kIsWeb?webWidth:phoneWidth,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomLoadingButton(
                                            callback: (){
                                              levProvider.changePage(context);
                                              _myFocusScopeNode.unfocus();
                                            }, isLoading: false,text: "Cancel",
                                            backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
                                        CustomLoadingButton(
                                          width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                                          isLoading: true,
                                          callback: () async {
                                            if (levProvider.name == null) {
                                              utils.showWarningToast(context, text: "Select User Name");
                                              levProvider.submitCtr.reset();
                                              return;
                                            }

                                            if (levProvider.rulesList.isEmpty) {
                                              utils.showWarningToast(context, text: "Please make changes");
                                              levProvider.submitCtr.reset();
                                              return;
                                            }

                                            _myFocusScopeNode.unfocus();

                                            try {
                                              await levProvider.addLeaveRule(context); // wait
                                            } catch (e) {
                                              debugPrint("Error: $e");
                                            } finally {
                                              levProvider.submitCtr.reset(); // ALWAYS reset
                                            }
                                          },
                                          controller: levProvider.submitCtr, text: 'Apply', backgroundColor: colorsConst.primary, radius: 10,),
                                      ],
                                    ),
                              ),
                              ],
                            );
                          }),
                    ),
                  ) :
                  const Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Loading(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

