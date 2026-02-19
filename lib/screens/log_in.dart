import 'package:master_code/screens/sign_up.dart';
import 'package:master_code/view_model/location_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/source/constant/assets_constant.dart';
import 'package:master_code/source/constant/local_data.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../component/custom_checkbox.dart';
import '../component/custom_loading_button.dart';
import '../component/custom_text.dart';
import '../component/custom_textfield.dart';
import '../component/update_app.dart';
import '../source/constant/colors_constant.dart';
import '../source/constant/default_constant.dart';
import '../source/constant/key_constant.dart';
import '../source/utilities/utils.dart';
import '../view_model/home_provider.dart';
import 'forgot_password.dart';
class LoginPage extends StatefulWidget {
  final String? number;
  const LoginPage({super.key, this.number});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Provider.of<HomeProvider>(context, listen: false).checkVersion();
      Provider.of<HomeProvider>(context, listen: false).getToken();
      Provider.of<LocationProvider>(context, listen: false).requestNotificationPermissions();
      Provider.of<HomeProvider>(context, listen: false).checkLoginValues(widget.number.toString());
      await Provider.of<LocationProvider>(context, listen: false).manageLocation(context,false);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width*0.5; 
    var phoneWidth=MediaQuery.of(context).size.width*0.83;
    var webHeight=MediaQuery.of(context).size.height*0.3;
    var phoneHeight=MediaQuery.of(context).size.height*0.3;
    return Consumer<HomeProvider>(builder: (context, homeProvider, _) {
      final homeProvider = context.read<HomeProvider>();
      return PopScope(
        canPop: false,
        onPopInvoked: (bool pop){
          return utils.customDialog(
              context: context,
              callback: (){SystemNavigator.pop();
              }, title: "Do you want to Exit the App?");
        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            bottomNavigationBar: SizedBox(
              width: kIsWeb?webWidth:phoneWidth,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 30, 5),
                child: SizedBox(
                  // color: Colors.pink,
                    width: kIsWeb?webWidth:phoneWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomText(text: "Version ${localData.versionNumber}",colors: colorsConst.greyClr),
                      ],
                    )),
              ),
            ),
            body: homeProvider.versionCheck==false
                ?const Center(child: Loading())
                :homeProvider.currentVersion!=""&&homeProvider.versionCheck==true&&
                homeProvider.versionActive==false?
            const UpdateApp()
                :SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      30.height,
                      SvgPicture.asset(assets.login,
                        width: kIsWeb?webWidth:phoneWidth,
                        height: kIsWeb?webHeight:phoneHeight),
                      20.height,
                      // CustomText(text: constValue.login,colors: Colors.black,size: 20,isBold: true,),
                      20.height,
                      CustomTextField(
                        width: kIsWeb?webWidth:phoneWidth,
                        isRequired: true,
                        text: "Phone Number",controller: homeProvider.loginNumber,
                        keyboardType: TextInputType.phone,
                        inputFormatters: constInputFormatters.mobileNumberInput,
                        onChanged: (value)  {
                          homeProvider.remember(false);
                        },
                      ),
                      CustomTextField(
                        width: kIsWeb?webWidth:phoneWidth,
                        isSpace: false,
                        isLogin: true,isRequired: true,
                        obsure: homeProvider.isEyeOpen,
                        iconColor: Colors.grey,
                        iconData: homeProvider.isEyeOpen==true?Icons.visibility_off:Icons.remove_red_eye_outlined,
                        iconCallBack: (){
                          homeProvider.manageEye();
                        },
                        text: constValue.password,controller: homeProvider.loginPassword,
                        textInputAction: TextInputAction.done,
                        inputFormatters: constInputFormatters.passwordInput,
                        keyboardType: TextInputType.visiblePassword,
                        textCapitalization: TextCapitalization.none,
                        onChanged: (value) {
                          homeProvider.remember(false);
                        },
                        onEditingComplete: (){
                          homeProvider.loginCtr.start();
                          if(homeProvider.loginNumber.text.trim().isEmpty){
                            utils.showWarningToast(context,text: "Please fill phone number");
                            homeProvider.loginCtr.reset();
                          }else if(homeProvider.loginNumber.text.trim().length!=10){
                            utils.showWarningToast(context,text: "Please check phone number");
                            homeProvider.loginCtr.reset();
                          }else if(homeProvider.loginPassword.text.trim().isEmpty){
                            utils.showWarningToast(context,text: "Please fill password");
                            homeProvider.loginCtr.reset();
                          }else if(homeProvider.loginPassword.text.trim().length<6) {
                            utils.showWarningToast(context,text: "Password must be 6 characters");
                            homeProvider.loginCtr.reset();
                          }else {
                            FocusScope.of(context).unfocus();
                            homeProvider.login(context);
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomCheckBox(
                            text: constValue.remember,
                            onChanged: (bool? value)  {
                              homeProvider.remember(true);
                            },
                            saveValue: homeProvider.rememberMe,),
                          TextButton(
                              onPressed: (){
                                // homeProvider.verifyUser(context);
                                if (homeProvider.loginNumber.text.trim().isEmpty) {
                                  utils.showWarningToast(context,text: "Enter Your Mobile Number");
                                }else if (homeProvider.loginNumber.text.trim().length!=10) {
                                  utils.showWarningToast(context,text: "Check Your Mobile Number");
                                  homeProvider.checkCtr.reset();
                                }else{
                                  FocusScope.of(context).unfocus();
                                  utils.navigatePage(context,()=>const ForgotPassword());
                                }
                              },
                              child: CustomText(text: constValue.forgot,colors: colorsConst.primary,isBold: true,)
                          )
                        ],
                      ),
                      10.height,
                      CustomLoadingButton( isLoading: true,height: 50,
                        width: kIsWeb?webWidth:phoneWidth,
                        callback: (){
                          if(homeProvider.loginNumber.text.trim().isEmpty){
                            utils.showWarningToast(context,text: "Please fill phone number");
                            homeProvider.loginCtr.reset();
                          }else if(homeProvider.loginNumber.text.trim().length!=10){
                            utils.showWarningToast(context,text: "Please check phone number");
                            homeProvider.loginCtr.reset();
                          }else if(homeProvider.loginPassword.text.trim().isEmpty){
                            utils.showWarningToast(context,text: "Please fill password");
                            homeProvider.loginCtr.reset();
                          }else if(homeProvider.loginPassword.text.trim().length<6) {
                            utils.showWarningToast(context,text: "Password must be 6 characters");
                            homeProvider.loginCtr.reset();
                          }else {
                            FocusScope.of(context).unfocus();
                            homeProvider.login(context);
                          }
                        },
                        text: constValue.login,controller: homeProvider.loginCtr,
                        backgroundColor: colorsConst.primary,radius: 10,),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     CustomText(text: constValue.account),
                      //     TextButton(onPressed: (){
                      //       utils.navigatePage(context, ()=>const SignUp());
                      //     }, child: CustomText(text: constValue.signUp,isBold: true,colors: colorsConst.primary,)),
                      //   ],
                      // )
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



