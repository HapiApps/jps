import 'package:master_code/source/constant/local_data.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:provider/provider.dart';
import '../component/custom_appbar.dart';
import '../component/custom_loading_button.dart';
import '../component/custom_text.dart';
import '../component/custom_textfield.dart';
import '../source/constant/colors_constant.dart';
import '../source/constant/default_constant.dart';
import '../source/constant/key_constant.dart';
import '../source/utilities/utils.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<HomeProvider>(context, listen: false).forgotPassword1.clear();
      Provider.of<HomeProvider>(context, listen: false).forgotPassword2.clear();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width*0.5;
    var phoneWidth=MediaQuery.of(context).size.width*0.83;
    return Consumer<HomeProvider>(builder: (context,homeProvider,_){
      return SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: PreferredSize(
            preferredSize: const Size(300, 100),
            child: CustomAppbar(text: "Forgot Password"),
          ),
          bottomNavigationBar: SizedBox(
            width: kIsWeb?webWidth:phoneWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomText(text: "Version ${localData.versionNumber}   \n",colors: colorsConst.greyClr),
              ],
            ),
          ),
          body: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(isRequired: true,
                text: constValue.password,controller: homeProvider.forgotPassword1,
                width: kIsWeb?webWidth:phoneWidth,
                keyboardType: TextInputType.visiblePassword,
                inputFormatters: constInputFormatters.passwordInput,
                textCapitalization: TextCapitalization.none,
              ),
              CustomTextField(isRequired: true,
                text: "Confirm Password",controller: homeProvider.forgotPassword2,
                width: kIsWeb?webWidth:phoneWidth,
                textInputAction: TextInputAction.done,
                inputFormatters: constInputFormatters.passwordInput,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.none,
              ),
              25.height,
              CustomLoadingButton( isLoading: true,height: 50,
                width:kIsWeb?webWidth:phoneWidth, callback: (){
                  if(homeProvider.forgotPassword1.text.trim().isEmpty) {
                    utils.showWarningToast(context,text: "Please fill password");
                    homeProvider.forgotCtr.reset();
                  }else if(homeProvider.forgotPassword1.text.trim().length<8) {
                    utils.showWarningToast(context,text: "Password must be 8 characters");
                    homeProvider.forgotCtr.reset();
                  }else if(homeProvider.forgotPassword2.text.trim().isEmpty) {
                    utils.showWarningToast(context,text: "Please fill confirm password");
                    homeProvider.forgotCtr.reset();
                  }else if(homeProvider.forgotPassword1.text.trim()!=homeProvider.forgotPassword2.text.trim()) {
                    utils.showWarningToast(context,text: "Please check password");
                    homeProvider.forgotCtr.reset();
                  }else{
                    FocusScope.of(context).unfocus();
                    homeProvider.forgotPassword(context);
                  }
                },
                text: "RESET PASSWORD",controller: homeProvider.forgotCtr,backgroundColor: colorsConst.primary,radius: 10,),
            ],
          ),
        ),
      );
    });
  }
}