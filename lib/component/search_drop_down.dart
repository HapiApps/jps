import 'package:master_code/source/extentions/extensions.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../model/customer/customer_model.dart';
import '../source/constant/colors_constant.dart';
import '../source/styles/decoration.dart';
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
    employeeList.sort((a, b) => a.companyName!.toLowerCase().compareTo(b.companyName!.toLowerCase()));
    return SizedBox(
      width: size,
      child: Column(
        children: [
          if(hintText==true)
            Row(
              children: [
                CustomText(text:text.toString(),size:13,isBold: false,),
                if(isRequired==true)
                  CustomText(text:"*",colors:colorsConst.appRed,size:18,isBold: false,),
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