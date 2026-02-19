import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_radio_button.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/key_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/payroll_provider.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width*0.7;
    var phoneWidth=MediaQuery.of(context).size.width*0.95;
    return Consumer<PayrollProvider>(builder: (context, payrollPvr, _) {
      final payrollPvr = context.read<PayrollProvider>();
        return SafeArea(
      child: Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: PreferredSize(
          preferredSize: const Size(300, 70),
          child: CustomAppbar(text: "Categories",
              callback: (){
                payrollPvr.changeFirst();
              }),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: colorsConst.primary,
          child: const Icon(Icons.add),
          onPressed: (){
            payrollPvr.addAction();
          },
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool pop){
            payrollPvr.changeFirst();
          },
          child: Center(
            child: SizedBox(
              width: kIsWeb?webWidth:phoneWidth,
              child: Center(
                child: Column(
                  children: [
                    payrollPvr.catLoading==false?
                    const Loading():
                    payrollPvr.categoryList.isEmpty?
                    const CustomText(text: "\n\n\n\n\n\n\n Category Found"):
                    Expanded(
                      child: kIsWeb?
                      GridView.builder(
                        primary: false,
                        itemCount: payrollPvr.categoryList.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 250.0,
                            mainAxisSpacing: 20.0,
                            mainAxisExtent: 60

                        ),
                        itemBuilder:  (context,index){
                          return GestureDetector(
                            onTap: (){
                              utils.customDialog(
                                  context: context,
                                  title: "Are you sure you want to delete",
                                  callback: (){
                                    payrollPvr.deleteCategory(context,payrollPvr.categoryList[index]["cat_id"]);
                                  },
                                  roundedLoadingButtonController: payrollPvr.submitCtr,
                                  isLoading: true
                              );
                            },
                            child: Container(
                              decoration: customDecoration.baseBackgroundDecoration(
                                color: Colors.white,
                                radius: 5,
                                borderColor: Colors.grey.shade200,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomText(text: payrollPvr.categoryList[index]["category"],),
                                  InkWell(
                                      onTap: (){
                                        utils.customDialog(
                                            context: context,
                                            title: "Are you sure you want to delete",
                                            callback: (){
                                              payrollPvr.deleteCategory(context,payrollPvr.categoryList[index]["cat_id"]);
                                            },
                                            roundedLoadingButtonController: payrollPvr.submitCtr,
                                            isLoading: true
                                        );
                                      },
                                      child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: SvgPicture.asset(assets.deleteValue,))),
                                ],
                              ),
                            ),
                          );
                        },
                      ):ListView.builder(
                          itemCount: payrollPvr.categoryList.length,
                          itemBuilder: (context,index){
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    utils.customDialog(
                                        context: context,
                                        title: "Are you sure you want to delete",
                                        callback: (){
                                          payrollPvr.deleteCategory(context,payrollPvr.categoryList[index]["cat_id"]);
                                        },
                                        roundedLoadingButtonController: payrollPvr.submitCtr,
                                        isLoading: true
                                    );
                                  },
                                  child: Container(
                                    decoration: customDecoration.baseBackgroundDecoration(
                                      color: Colors.white,
                                      radius: 5,
                                      borderColor: Colors.grey.shade200,
                                    ),
                                    width: kIsWeb?webWidth:phoneWidth,
                                    height: kIsWeb?MediaQuery.of(context).size.height * 0.9:MediaQuery.of(context).size.height * 0.08,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CustomText(text: payrollPvr.categoryList[index]["category"],),
                                          GestureDetector(
                                              onTap: (){
                                                utils.customDialog(
                                                    context: context,
                                                    title: "Are you sure you want to delete",
                                                    callback: (){
                                                      payrollPvr.deleteCategory(context,payrollPvr.categoryList[index]["cat_id"]);
                                                    },
                                                    roundedLoadingButtonController: payrollPvr.submitCtr,
                                                    isLoading: true
                                                );
                                              },
                                              child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: SvgPicture.asset(assets.deleteValue,))),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if(index==payrollPvr.categoryList.length-1)
                                  80.height,
                                if(!kIsWeb)
                                  10.height
                              ],
                            );
                          }),
                    )
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


class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)  {
      Provider.of<PayrollProvider>(context, listen: false).intVal();
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
    var webWidth=MediaQuery.of(context).size.width*0.7;
    var phoneWidth=MediaQuery.of(context).size.width*0.95;
    return Consumer<PayrollProvider>(builder: (context, payrollPvr, _) {
      final payrollPvr = context.read<PayrollProvider>();
        return Scaffold(
      backgroundColor: colorsConst.bacColor,
      appBar: PreferredSize(
        preferredSize: const Size(300, 70),
        child: CustomAppbar(text: "Add Category",
            callback: (){
              _myFocusScopeNode.unfocus();
              payrollPvr.changePages(3);
            }),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool pop){
          _myFocusScopeNode.unfocus();
          payrollPvr.changePages(3);
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              20.height,
              CustomTextField(text: "Category Name",isRequired: true,
                inputFormatters: constInputFormatters.numTextInput,
                controller: payrollPvr.categoryName,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                width: kIsWeb?webWidth:phoneWidth,
              ),20.height,
              SizedBox(
                width: kIsWeb?webWidth:phoneWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomRadioButton(
                      width: MediaQuery.of(context).size.width*0.2,
                      text:"Charges",
                      onChanged: (Object? value){
                        payrollPvr.changeType("0");
                      },
                      saveValue: payrollPvr.catType, confirmValue: "0",
                    ),
                    CustomRadioButton(
                      width: MediaQuery.of(context).size.width*0.2,
                      text:"Incentive",
                      onChanged: (Object? value)  {
                        payrollPvr.changeType("1");
                      },
                      saveValue: payrollPvr.catType, confirmValue: "1",
                    ),
                    CustomRadioButton(
                      width: MediaQuery.of(context).size.width*0.2,
                      text:"Days",
                      onChanged: (Object? value)  {
                        payrollPvr.changeType("3");
                      },
                      saveValue: payrollPvr.catType, confirmValue: "3",
                    ),
                  ],
                ),
              ),
              70.height,
              SizedBox(
                width: kIsWeb?webWidth:phoneWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomLoadingButton(
                        callback: (){
                          _myFocusScopeNode.unfocus();
                          payrollPvr.changeFirst();
                        }, isLoading: false,text: "Cancel",
                        backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
                    CustomLoadingButton(
                      width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                      isLoading: true,
                      callback: () {
                        if( payrollPvr.categoryName.text.trim().isNotEmpty){
                          _myFocusScopeNode.unfocus();
                          payrollPvr.addCategories(context);
                        }else{
                          utils.showWarningToast(context,text: "Please fill category name");
                          payrollPvr.submitCtr.reset();
                        }
                      },
                      controller: payrollPvr.submitCtr, text: 'Save', backgroundColor: colorsConst.primary, radius: 10,),
                  ],
                ),
              ),
              50.height
            ],
          ),
        ),
      ),
    );
    });
  }
}

