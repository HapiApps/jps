import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../../view_model/payroll_provider.dart';

class PayrollSetting extends StatefulWidget {
  const PayrollSetting({super.key});

  @override
  State<PayrollSetting> createState() => _PayrollSettingState();
}

class _PayrollSettingState extends State<PayrollSetting> {

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width*0.7;
    var phoneWidth=MediaQuery.of(context).size.width*0.95;
    return Consumer<PayrollProvider>(builder: (context, payrollPvr, _) {
      final payrollPvr = context.read<PayrollProvider>();
        return Scaffold(
      backgroundColor: colorsConst.bacColor,
      appBar: PreferredSize(
        preferredSize: const Size(300, 70),
        child: CustomAppbar(text: "Payroll Setting",
            callback: (){
              payrollPvr.changeFirst();
            }),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool pop){
          payrollPvr.changeFirst();
        },
        child: Center(
          child: payrollPvr.isPayrollRefresh==false?
          const Loading():
          payrollPvr.settingList.isEmpty?
          const CustomText(text: "No Setting Found")
              :Column(
            children: [
              SizedBox(
                width: kIsWeb?webWidth:phoneWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: (){
                          payrollPvr.basic.text=payrollPvr.settingList[0].basicDa.toString();
                          payrollPvr.rate.text=payrollPvr.settingList[0].otRate.toString();
                          payrollPvr.hra.text=payrollPvr.settingList[0].hra.toString();
                          payrollPvr.conv.text=payrollPvr.settingList[0].conv.toString();
                          payrollPvr.wa.text=payrollPvr.settingList[0].wa.toString();
                          payrollPvr.esi.text=payrollPvr.settingList[0].esi.toString();
                          payrollPvr.pf.text=payrollPvr.settingList[0].pf.toString();
                          payrollPvr.settingEdit=true;
                          payrollPvr.changeList();
                        },
                        icon: SvgPicture.asset(assets.edit,width: 15,height: 15,))
                  ],
                ),
              ),
              Container(
                width: kIsWeb?webWidth/1.5:phoneWidth/1.5,
                decoration: customDecoration.baseBackgroundDecoration(
                    borderColor: Colors.grey.shade300,
                    color: Colors.white,
                    radius: 2
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(text: "\n BASIC+DA\n",colors: colorsConst.primary,isBold: true,),
                          CustomText(text: "\n${payrollPvr.settingList[0].basicDa.toString()} %\n",colors: colorsConst.greyClr),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(text: "\n HRA\n",colors: colorsConst.primary,isBold: true,),
                          CustomText(text: "\n${payrollPvr.settingList[0].hra.toString()} %\n",colors: colorsConst.greyClr),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(text: "\nCONV\n",colors: colorsConst.primary,isBold: true,),
                          CustomText(text: "\n${payrollPvr.settingList[0].conv.toString()} %\n",colors: colorsConst.greyClr),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(text: "\nWA\n",colors: colorsConst.primary,isBold: true,),
                          CustomText(text: "\n${payrollPvr.settingList[0].wa.toString()} %\n",colors: colorsConst.greyClr),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    });
  }
}


class UpdatePayrollSetting extends StatefulWidget {
  const UpdatePayrollSetting({super.key});

  @override
  State<UpdatePayrollSetting> createState() => _UpdatePayrollSettingState();
}

class _UpdatePayrollSettingState extends State<UpdatePayrollSetting> {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void dispose() {
    super.dispose();
    _myFocusScopeNode.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width*0.7;
    var phoneWidth=MediaQuery.of(context).size.width*0.95;
    return Consumer<PayrollProvider>(builder: (context, payrollPvr, _) {
      final payrollPvr = context.read<PayrollProvider>();
    return FocusScope(
      node: _myFocusScopeNode,
      child: Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: PreferredSize(
          preferredSize: const Size(300, 70),
          child: CustomAppbar(text: "Update Payroll Setting",
              callback: (){
                _myFocusScopeNode.unfocus();
                payrollPvr.changePages(4);
              }),
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool pop){
            _myFocusScopeNode.unfocus();
            payrollPvr.changePages(4);
          },
          child: Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        text: "Basic+DA",isRequired: true,
                        controller: payrollPvr.basic,
                        inputFormatters: constInputFormatters.decimalInput,
                        keyboardType: TextInputType.number,
                        width: kIsWeb?webWidth/3.2:phoneWidth/3.2,
                      ),
                      10.width,
                      CustomTextField(
                        text: "CONV",isRequired: true,
                        controller: payrollPvr.conv,
                        inputFormatters: constInputFormatters.decimalInput,
                        keyboardType: TextInputType.number,
                        width: kIsWeb?webWidth/3.2:phoneWidth/3.2,
                      ),
                      10.width,
                      CustomTextField(
                        text: "WA",isRequired: true,
                        controller: payrollPvr.wa,
                        inputFormatters: constInputFormatters.decimalInput,
                        width: kIsWeb?webWidth/3.2:phoneWidth/3.2,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        text: "HRA",isRequired: true,
                        controller: payrollPvr.hra,
                        textInputAction: TextInputAction.done,
                        inputFormatters: constInputFormatters.decimalInput,
                        width: kIsWeb?webWidth/3.2:phoneWidth/3.2,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                150.height,
                SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomLoadingButton(
                          callback: (){
                            _myFocusScopeNode.unfocus();
                            payrollPvr.changePages(4);
                          }, isLoading: false,text: "Cancel",
                          backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
                      CustomLoadingButton(
                        width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                        isLoading: true,
                        callback: () {
                          if(payrollPvr.basic.text.trim().isNotEmpty
                              &&payrollPvr.conv.text.trim().isNotEmpty
                              &&payrollPvr.hra.text.trim().isNotEmpty
                              &&payrollPvr.wa.text.trim().isNotEmpty
                          ){
                            _myFocusScopeNode.unfocus();
                            payrollPvr.addPayrollSetting(context);
                          }else{
                            utils.showWarningToast(text: "Please fill all fields",context);
                            payrollPvr.updateCtr.reset();
                          }
                        },
                        controller: payrollPvr.updateCtr, text: 'Save', backgroundColor: colorsConst.primary, radius: 10,),
                    ],
                  ),
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
