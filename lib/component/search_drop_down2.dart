import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:master_code/model/project/project_model.dart';
import 'package:master_code/source/extentions/extensions.dart';
import '../model/customer/customer_model.dart';
import '../model/user_model.dart';
import '../source/constant/colors_constant.dart';
import '../source/styles/decoration.dart';
import '../source/utilities/utils.dart';
import 'custom_text.dart';

class CustomerDropdown extends StatelessWidget {
  final List<CustomerModel> employeeList;
  final ValueChanged<CustomerModel?> onChanged;
  final String? text;
  final double size;
  final bool? isRequired;
  final bool? hintText;
  const CustomerDropdown({super.key, required this.employeeList, required this.onChanged,this.text="", required this.size, this.isRequired, this.hintText=true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Column(
        children: [
          if(hintText==true)
            Row(
              children: [
                CustomText(text:text.toString(),colors:Colors.grey,size:13,isBold: false,),
                if(isRequired==true)
                  CustomText(text:"*",colors:colorsConst.primary,size:18,isBold: false,),
              ],
            ),
          Container(
            width: size,
            height: 47,
            decoration: customDecoration.baseBackgroundDecoration(
              color: Colors.white,borderColor: Colors.grey.shade200,
              radius: 10,
            ),
            child: DropdownSearch<CustomerModel>(
              items: employeeList, // Pass the list of EmployeeModel directly
              itemAsString: (CustomerModel? product) => product?.companyName ?? '',
              onChanged: onChanged,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  // labelText: widget.label,
                    hintText: "$text",
                    hintStyle: const TextStyle(color: Colors.grey,fontSize: 13,fontFamily:'Poppins'),
                    contentPadding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
                    border: InputBorder.none
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                fit: FlexFit.loose,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9, // Set max width for the dropdown popup
                ),
                itemBuilder: (context, CustomerModel? product, bool isSelected) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text:product!.companyName ?? '',colors: colorsConst.primary,isBold: true,),5.height,
                        Row(
                          children: [
                            const CustomText(text:'Created By : ',colors: Colors.grey,),
                            CustomText(text:product.creator ?? '',colors: Colors.blueGrey,),
                          ],
                        ),
                        const Divider(color: Colors.grey,)
                      ],
                    ),
                  );
                },
              ),
            ),
          ),7.height
        ],
      ),
    );
  }
}

class CustomSearchDropDown extends StatelessWidget {
  final double width;
  final dynamic saveValue;
  final String hintText;
  final String dropText;
  final List<UserModel>? list2;
  final TextEditingController? controller;
  final ValueChanged<Object?> onChanged;
  final Color? color;
  final bool? isHint;
  final bool isUser;
  final bool? isRequired;
  const CustomSearchDropDown({super.key, required this.width, required this.saveValue, required this.hintText, required this.onChanged, required this.dropText, this.color=Colors.white, this.isHint=false, this.list2, this.controller, required this.isUser, this.isRequired});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(isHint==false)
            Row(
              children: [
                CustomText(
                  text: hintText,
                  colors: Colors.grey.shade400,
                  size: 13,
                  isBold: false,
                ),
                if (isRequired == true)
                  CustomText(text:"*",colors: colorsConst.appRed,size:20,isBold: false,
                  ),
              ],
            ),2.height,
          Container(
            width: width,
            height: 45,
            decoration: customDecoration.baseBackgroundDecoration(
                color: Colors.white,borderColor: Colors.grey.shade300,
                radius: 10
            ),
            child:DropdownButtonHideUnderline(
              child:DropdownMenu<dynamic>(
                // initialSelection: menuItems.first,
                controller: controller,
                inputDecorationTheme: const InputDecorationTheme(
                  border: InputBorder.none,
                  contentPadding:EdgeInsets.fromLTRB(10, 0, 10, 15),
                ),
                menuHeight: MediaQuery.of(context).size.height*0.50,
                width: MediaQuery.of(context).size.height*0.90,
                hintText: "Search Name",
                enableSearch: true,
                requestFocusOnTap: true,
                enableFilter: true,
                onSelected: onChanged,
                trailingIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 17),
                  child: Icon(Icons.arrow_drop_down),
                ),
                dropdownMenuEntries: list2!.map<DropdownMenuEntry<String>>((e) {
                  return DropdownMenuEntry<String>(
                      value: "${e.id},${e.firstname}",
                      label: "${e.firstname}",
                      trailingIcon: CustomText(text: '${e.roleName}',colors: Colors.grey,)
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
///
// class CustomSearchDropDown extends StatelessWidget {
//   final double width;
//   final dynamic saveValue;
//   final String hintText;
//   final String dropText;
//   final List<UserModel>? list2;
//   final TextEditingController? controller;
//   final ValueChanged<UserModel?> onChanged;
//   final Color? color;
//   final bool? isHint;
//   final bool isUser;
//   final bool? isRequired;
//   const CustomSearchDropDown({super.key, required this.width, required this.saveValue, required this.hintText, required this.onChanged, required this.dropText, this.color=Colors.white, this.isHint=false, this.list2, this.controller, required this.isUser, this.isRequired});
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: width,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if(isHint==false)
//             Row(
//               children: [
//                 CustomText(
//                   text: hintText,
//                   colors: Colors.grey.shade400,
//                   size: 13,
//                   isBold: false,
//                 ),
//                 if (isRequired == true)
//                   CustomText(text:"*",colors: colorsConst.appRed,size:20,isBold: false,
//                   ),
//               ],
//             ),2.height,
//           Container(
//             width: width,
//             height: 45,
//             decoration: customDecoration.baseBackgroundDecoration(
//                 color: Colors.white,borderColor: Colors.grey.shade300,
//                 radius: 10
//             ),
//             child:DropdownButtonHideUnderline(
//               child:DropdownMenu<UserModel>(
//                 // initialSelection: menuItems.first,
//                 controller: controller,
//                 inputDecorationTheme: const InputDecorationTheme(
//                   border: InputBorder.none,
//                   contentPadding:EdgeInsets.fromLTRB(10, 10, 10, 10),
//                 ),
//                 menuHeight: MediaQuery.of(context).size.height*0.50,
//                 width: MediaQuery.of(context).size.height*0.90,
//                 hintText: "Search Name",
//                 enableSearch: true,
//                 requestFocusOnTap: true,
//                 enableFilter: true,
//                 onSelected: (UserModel? value) {
//                   onChanged(value);
//                 },
//                 dropdownMenuEntries: list2!.map<DropdownMenuEntry<UserModel>>((e) {
//                   return DropdownMenuEntry<UserModel>(
//                     value: e,   // FIXED → whole object as value
//                     label: e.firstname ?? "",
//                     trailingIcon: CustomText(
//                       text: e.roleName ?? "",
//                       colors: Colors.grey,
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
class CustomSearchDropDown2 extends StatelessWidget {
  final double width;
  final dynamic saveValue;
  final String hintText;
  final String dropText;
  final List<ProjectModel> list;
  final TextEditingController? controller;
  final ValueChanged<Object?> onChanged;
  final Color? color;
  final bool? isHint;
  final bool isUser;
  final bool? isRequired;
  const CustomSearchDropDown2({super.key, required this.width, required this.saveValue, required this.hintText,
    required this.onChanged, required this.dropText, this.color=Colors.white, this.isHint=false, required this.list, this.controller, required this.isUser, this.isRequired});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(list.isEmpty){
          utils.showWarningToast(context, text: "Please add the project details.");
        }
        return;
      },
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(isHint==false)
              Row(
                children: [
                  CustomText(
                    text: hintText,
                    colors: Colors.grey.shade400,
                    size: 13,
                    isBold: false,
                  ),
                  if (isRequired == true)
                    CustomText(text:"*",colors: colorsConst.appRed,size:20,isBold: false,
                    ),
                ],
              ),2.height,
            AbsorbPointer(
              absorbing: list.isEmpty,
              child: Container(
                width: width,
                height: 45,
                decoration: customDecoration.baseBackgroundDecoration(
                    color: Colors.white,borderColor: Colors.grey.shade300,
                    radius: 10
                ),
                child:DropdownButtonHideUnderline(
                  child:DropdownMenu<dynamic>(
                    // initialSelection: menuItems.first,
                    controller: controller,
                    inputDecorationTheme: const InputDecorationTheme(
                      border: InputBorder.none,
                      contentPadding:EdgeInsets.fromLTRB(10, 10, 10, 10),
                    ),
                    menuHeight: MediaQuery.of(context).size.height*0.50,
                    width: MediaQuery.of(context).size.height*0.90,
                    hintText: "Search Name",
                    enableSearch: true,
                    requestFocusOnTap: true,
                    enableFilter: true,
                    onSelected: list.isNotEmpty?onChanged:null,
                    dropdownMenuEntries: list.map<DropdownMenuEntry<String>>((e) {
                      return DropdownMenuEntry<String>(
                        value: "${e.id},${e.name}",
                        label: "${e.name}",
                      );
                    }).toList(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}