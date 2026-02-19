import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_checkbox.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/key_constant.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/leave_provider.dart';

class LeaveSetting extends StatefulWidget {
  const LeaveSetting({super.key});

  @override
  State<LeaveSetting> createState() => _LeaveSettingState();
}

class _LeaveSettingState extends State<LeaveSetting> {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
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
    return Consumer<LeaveProvider>(builder: (context,levProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            appBar: PreferredSize(
                preferredSize: const Size(300, 60),
                child: CustomAppbar(text: "Leave Setting",
                  callback: () {
                    _myFocusScopeNode.unfocus();
                    levProvider.changePage(context);
                  },)),
            backgroundColor: colorsConst.bacColor,
            floatingActionButton: SizedBox(
              width: 50,
              height: 50,
              child: RoundedLoadingButton(
                  borderRadius: 50,
                  elevation: 0.0,
                  color: colorsConst.primary,
                  successColor: Colors.white,
                  valueColor: Colors.white,
                  onPressed: () {
                    if(levProvider.isChanged==true){
                      _myFocusScopeNode.unfocus();
                      levProvider.insertLeaveDays(context);
                    }else{
                      utils.showWarningToast(context, text: "Please select leave dates");
                      levProvider.submitCtr.reset();
                    }
                  },
                  controller: levProvider.submitCtr,
                  child: const Icon(Icons.check, color: Colors.white,)
              ),
            ),
            body: PopScope(
              canPop: false,
              onPopInvoked: (bool pop) {
                _myFocusScopeNode.unfocus();
                levProvider.changePage(context);
              },
              child: Center(
                child: SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  child: levProvider.getLeave == false ?
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
                    child: Loading(),
                  ) :SingleChildScrollView(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap: () {
                              // showCustomYearPicker(context: context, function: () {
                              //   levProvider.getLeaves();
                              // },year: levProvider.year);
                            },
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  assets.fixLeaves, width: 25, height: 25,),
                                10.width,
                                CustomText(text: levProvider.year,size: 16,)
                              ],
                            )),
                        10.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomCheckBox(
                              text: "All Sunday",
                              onChanged: (bool? value) {
                                levProvider.allSunDay(value);
                              },
                              saveValue: levProvider.allSunday,),
                            10.width,
                            CustomCheckBox(
                              text: "All Saturday",
                              onChanged: (bool? value) {
                                  levProvider.allSaturDay(value);
                              },
                              saveValue: levProvider.allSaturday,),
                          ],
                        ),
                        10.height,
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomText(text: "Saturday"),
                          ],
                        ),
                        5.height,
                        SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CustomCheckBox(
                                text: "1",
                                onChanged: (bool? value) {
                                    levProvider.firstSaturDay(value);
                                },
                                saveValue: levProvider.saturday1,),
                              20.width,
                              CustomCheckBox(
                                text: "2",
                                onChanged: (bool? value) {
                                    levProvider.secondSaturDay(value);
                                },
                                saveValue: levProvider.saturday2,),
                              20.width,
                              CustomCheckBox(
                                text: "3",
                                onChanged: (bool? value) {
                                    levProvider.thirdSaturDay(value);
                                },
                                saveValue: levProvider.saturday3,),
                              20.width,
                              CustomCheckBox(
                                text: "4",
                                onChanged: (bool? value) {
                                    levProvider.fourthSaturDay(value);
                                },
                                saveValue: levProvider.saturday4,),
                              20.width,
                              CustomCheckBox(
                                text: "5",
                                onChanged: (bool? value) {
                                    levProvider.fivthSaturDay(value);
                                },
                                saveValue: levProvider.saturday5,),
                            ],
                          ),
                        ),
                        10.height,
                        SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child:
                          Column(
                            children: [
                              CustomTextField(
                                text: "",
                                controller: levProvider.search,
                                keyboardType: TextInputType.text,
                                inputFormatters: constInputFormatters.numTextInput,
                                textInputAction: TextInputAction.done,
                                width: kIsWeb?webWidth:phoneWidth,
                                hintText: "Search Holidays",
                                isIcon: true,
                                iconData: Icons.search,
                                isShadow: true,
                                onChanged: (value) {
                                    levProvider.searchDay(value);
                                },
                                isSearch: levProvider.search.text.isNotEmpty?true:false,
                                searchCall: (){
                                  levProvider.search.clear();
                                  levProvider.searchDay("");
                                },
                              ),
                              if(levProvider.searchFutureHolidays.isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CustomCheckBox(
                                      leftAligned: true,
                                      text: "Check All",
                                      onChanged: (bool? value) {
                                          levProvider.changeValue(value);
                                      },
                                      saveValue: levProvider.allSelect,),
                                  ],
                                ),
                              levProvider.searchFutureHolidays.isEmpty ?
                              const Center(
                                  child: CustomText(text: "No Holidays Found")) :
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: levProvider.searchFutureHolidays.length,
                                  itemBuilder: (context, index) {
                                    var st = DateTime.parse(
                                        levProvider.searchFutureHolidays[index].date
                                            .toString());
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                      child: Container(
                                        decoration: customDecoration
                                            .baseBackgroundDecoration(
                                            color: Colors.grey.shade50,
                                            radius: 5
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                CustomText(text: "  ${levProvider
                                                    .searchFutureHolidays[index].name
                                                    .toString()}",colors: colorsConst.primary,isBold: true,),5.height,
                                                Row(
                                                  children: [
                                                    CustomText(
                                                      text: "  ${utils.returnPadLeft(
                                                          st.day.toString())}/${utils
                                                          .returnPadLeft(
                                                          st.month.toString())}/${st
                                                          .year}",colors: colorsConst.greyClr,),10.width,
                                                    CustomText(
                                                      text: DateFormat('EEEE').format(DateFormat('dd-MM-yyyy').parse("${utils.returnPadLeft(st.day.toString())}-${utils.returnPadLeft(st.month.toString())}-${st.year}")),colors: Colors.grey,),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            CustomCheckBox(
                                              text: "",
                                              onChanged: (bool? value) {
                                                levProvider.changeCheckBox(value,levProvider.searchFutureHolidays[index].date);
                                              },
                                              saveValue: levProvider
                                                  .searchFutureHolidays[index].isClick
                                                  ,),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                              80.height
                            ],
                          )
                        ),

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
