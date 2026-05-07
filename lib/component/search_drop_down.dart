import 'package:master_code/source/extentions/extensions.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../model/customer/customer_model.dart';
import '../source/constant/colors_constant.dart';
import '../source/styles/decoration.dart';
import 'custom_text.dart';

class CustomerDropdown extends StatefulWidget {
  final List<CustomerModel> employeeList;
  final ValueChanged<CustomerModel?> onChanged;
  final String? text;
  final double size;
  final bool? isRequired;
  final bool? hintText;
  /// 🔥 ADD THIS
  final double height;
  final double itemHeight;
  const CustomerDropdown({
    super.key,
    required this.employeeList,
    required this.onChanged,
    this.text = "",
    required this.size,
    this.isRequired,
    this.hintText = true,
    /// 🔥 DEFAULT VALUES
    this.height = 40,
    this.itemHeight = 45,
  });

  @override
  State<CustomerDropdown> createState() => _CustomerDropdownState();
}

class _CustomerDropdownState extends State<CustomerDropdown> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    List<CustomerModel> sortedList = List.from(widget.employeeList)
      ..sort((a, b) =>
          a.companyName!.toLowerCase().compareTo(b.companyName!.toLowerCase()));

    return SizedBox(
      width: widget.size,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.hintText == true)
            Row(
              children: [
                CustomText(
                  text: widget.text.toString(),
                  size: 13,
                  colors: Colors.black,
                  isBold: false,
                ),
                if (widget.isRequired == true)
                  CustomText(
                    text: "*",
                    colors: colorsConst.appRed,
                    size: 18,
                    isBold: false,
                  ),
              ],
            ),
          4.height,

          Container(
            width: widget.size,
            height: widget.height,

            decoration: customDecoration.baseBackgroundDecoration(
              color: Colors.white,
              borderColor: Colors.grey.shade200,
              radius: 10,
            ),
            child: DropdownSearch<CustomerModel>(
              items: sortedList,
              itemAsString: (CustomerModel? product) =>
              product?.companyName ?? '',
              onChanged: widget.onChanged,

              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  hintText: "${widget.text}",
                  hintStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),

                  border: InputBorder.none,

                  /// ✅ OPEN CLOSE ICON CHANGE
                  suffixIcon: Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: Colors.black,
                  ),
                ),
              ),

              popupProps: PopupProps.menu(
                showSearchBox: true,

                /// ✅ when popup close
                onDismissed: () {
                  setState(() {
                    isOpen = false;
                  });
                },

                searchFieldProps: TextFieldProps(
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Search...",
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                fit: FlexFit.loose,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: 330, // 👈 popup overall height
                ),

                itemBuilder: (context, CustomerModel? product, bool isSelected) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: product?.companyName ?? '',
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
                              text: product?.creator ?? '',
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

              /// ✅ when popup open
              onBeforePopupOpening: (selectedItem) async {
                setState(() {
                  isOpen = true;
                });
                return true;
              },
            ),
          ),

          7.height
        ],
      ),
    );
  }
}