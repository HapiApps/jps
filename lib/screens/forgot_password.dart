import 'package:master_code/source/constant/local_data.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:provider/provider.dart';
import '../component/custom_appbar.dart';
import '../component/custom_loading_button.dart';
import '../component/custom_text.dart';
import '../component/custom_textfield.dart';
import '../source/constant/api.dart';
import '../source/constant/assets_constant.dart';
import '../source/constant/colors_constant.dart';
import '../source/constant/default_constant.dart';
import '../source/constant/key_constant.dart';
import '../source/utilities/utils.dart';

class Otp extends StatefulWidget {
  const Otp({super.key});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, LanguageManager>(builder: (context,homeProvider,langManager,_){
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size(300, 70),
          child: CustomAppbar(text: constValue.otpTitle),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 250,
                width: 250,
                child: Image.asset(assets.otpImage),
              ),
              CustomText(text: constValue.otpVerification,colors: Colors.black,size: 17,isBold: true,),
              10.height,
              CustomText(text: "${constValue.enterOtpSentTo}${homeProvider.loginNumber.text.toString().substring(homeProvider.loginNumber.text.length-2)}",colors: Colors.black,size: 15),
              50.height,
              OTPTextFieldV2(
                controller: homeProvider.otpbox,
                length: 6,
                width: MediaQuery.of(context).size.width*0.95,
                fieldWidth: 50,
                outlineBorderRadius:3,
                spaceBetween: 5,
                style:  TextStyle(
                    fontSize: 20,
                    color: colorsConst.secondary
                ),
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldStyle: FieldStyle.box,
                onCompleted: (pin) {
                  setState(()  {
                    homeProvider.otp=pin;
                    homeProvider.verifyOtp(context);
                  });
                },
              ),
              40.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(text: constValue.receiveOtp,colors: Colors.black,size: 15),
                  TextButton(onPressed: (){
                    homeProvider.sentOtp = "";
                    homeProvider.otpbox.clear();
                    if(isRelease==true) {
                      homeProvider.sentOtpNumber('${homeProvider.countryDial}${homeProvider.loginNumber.text}',context);
                    }else{
                      utils.showSuccessToast(context:context,text: constValue.otpSent);
                    }
                  }, child: CustomText(text: constValue.resend,colors: colorsConst.primary,size: 15,isBold: true,),)
                ],
              ),
              20.height,
            ],
          ),
        ),
      );
    });
  }
}


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
    return Consumer2<HomeProvider, LanguageManager>(builder: (context,homeProvider,langManager,_){
      return SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: PreferredSize(
            preferredSize: const Size(300, 60),
            child: CustomAppbar(text: constValue.forgotPasswordTitle),
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
              20.height,
              CustomTextField(isRequired: true,
                isLogin: true,
                obsure: homeProvider.isEyeOpen,
                iconColor: Colors.grey,
                iconData: homeProvider.isEyeOpen==true?Icons.visibility_off:Icons.remove_red_eye_outlined,
                iconCallBack: (){
                  homeProvider.manageEye();
                },
                text: constValue.password,controller: homeProvider.forgotPassword1,
                width: kIsWeb?webWidth:phoneWidth,
                keyboardType: TextInputType.visiblePassword,
                inputFormatters: constInputFormatters.passwordInput,
                textCapitalization: TextCapitalization.none,
              ),
              CustomTextField(isRequired: true,
                isLogin: true,
                obsure: homeProvider.isEyeOpen2,
                iconData: homeProvider.isEyeOpen2==true?Icons.visibility_off:Icons.remove_red_eye_outlined,
                iconCallBack: (){
                  homeProvider.manageEye2();
                },
                text: constValue.confirmPassword,controller: homeProvider.forgotPassword2,
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
                    utils.showWarningToast(context,text: constValue.fillPassword);
                    homeProvider.forgotCtr.reset();
                  }else if(homeProvider.forgotPassword1.text.trim().length<8) {
                    utils.showWarningToast(context,text: constValue.passwordMinLength);
                    homeProvider.forgotCtr.reset();
                  }else if(homeProvider.forgotPassword2.text.trim().isEmpty) {
                    utils.showWarningToast(context,text: constValue.pleaseFillConfirmPassword);
                    homeProvider.forgotCtr.reset();
                  }else if(homeProvider.forgotPassword1.text.trim()!=homeProvider.forgotPassword2.text.trim()) {
                    utils.showWarningToast(context,text: constValue.pleaseCheckPassword);
                    homeProvider.forgotCtr.reset();
                  }else{
                    FocusScope.of(context).unfocus();
                    homeProvider.forgotPassword(context);
                  }
                },
                text: constValue.resetPassword,controller: homeProvider.forgotCtr,backgroundColor: colorsConst.primary,radius: 10,),
            ],
          ),
        ),
      );
    });
  }
}