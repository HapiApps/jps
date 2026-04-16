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

  const CustomerDropdown({
    super.key,
    required this.employeeList,
    required this.onChanged,
    this.text = "",
    required this.size,
    this.isRequired,
    this.hintText = true,
  });

  @override
  Widget build(BuildContext context) {
    employeeList.sort((a, b) =>
        a.companyName!.toLowerCase().compareTo(b.companyName!.toLowerCase()));

    return SizedBox(
      width: size,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hintText == true)
            Row(
              children: [
                CustomText(
                  text: text.toString(),
                  size: 13,
                  isBold: false,
                ),
                if (isRequired == true)
                  CustomText(
                    text: "*",
                    colors: colorsConst.appRed,
                    size: 18,
                    isBold: false,
                  ),
              ],
            ),
          4.height,

          /// ✅ DROPDOWN HEIGHT REDUCED
          Container(
            width: size,
            height: 44, // ✅ reduced height
            decoration: customDecoration.baseBackgroundDecoration(
              color: Colors.white,
              borderColor: Colors.grey.shade200,
              radius: 10,
            ),
            child: DropdownSearch<CustomerModel>(
              items: employeeList,
              itemAsString: (CustomerModel? product) =>
              product?.companyName ?? '',
              onChanged: onChanged,

              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  hintText: "$text",
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),

                  /// ✅ reduce padding for fit in 42 height
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

                  border: InputBorder.none,
                ),
              ),

              popupProps: PopupProps.menu(
                showSearchBox: true,

                /// ✅ search box also reduce
                searchFieldProps: TextFieldProps(
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Search...",
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                fit: FlexFit.loose,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),

                itemBuilder:
                    (context, CustomerModel? product, bool isSelected) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: product!.companyName ?? '',
                          colors: colorsConst.primary,
                          isBold: true,
                          size: 13,
                        ),
                        4.height,
                        Row(
                          children: [
                            const CustomText(
                              text: 'Created By : ',
                              colors: Colors.grey,
                              size: 12,
                            ),
                            CustomText(
                              text: product.creator ?? '',
                              colors: Colors.blueGrey,
                              size: 12,
                            ),
                          ],
                        ),
                        const Divider(color: Colors.grey),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          7.height
        ],
      ),
    );
  }
}