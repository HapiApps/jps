import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'custom_text.dart';
class CustomDropdownField extends StatelessWidget {
  final String? selectedValue;
  final String? value;
  final List<String> items;
  final String hintText;
  final ValueChanged<String?> onChanged;


  const CustomDropdownField({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.hintText,
    required this.onChanged, this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<String>(
        menuMaxHeight: 300,

        isExpanded: true,
        dropdownColor: Colors.white,
        // initialValue: value,
        value: (selectedValue != null && selectedValue!.isNotEmpty && items.contains(selectedValue))
            ? selectedValue
            : null,
        hint: CustomText(text: hintText,colors: Colors.grey),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.shade300
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style:  TextStyle(fontSize: 16,
                      color: Colors.black
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class ExpasyList extends StatelessWidget {
  final String value;
  final String iconPath;
  final String label;
  const ExpasyList({super.key, required this.value, required this.iconPath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(iconPath, width: 24, height: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: label,
                colors: const Color(0xff464646),
                size: 14,
                isBold: false,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomText(
            text: value,
            colors: const Color(0xff000000),
            size: 14,
            isBold: true,
          ),
        ),
      ],
    );
  }
}

class DottedDivider extends StatelessWidget {
  final double dotSpacing;
  final Color dotColor;

  const DottedDivider({
    super.key,
    this.dotSpacing = 2.0,
    this.dotColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dotCount = (constraints.constrainWidth() / (3.0 + dotSpacing)).floor();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dotCount, (index) {
              return Container(
                width: 7.0,
                height: 2.0,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}