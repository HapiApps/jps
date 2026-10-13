import 'package:flutter/material.dart';
import 'package:master_code/source/extentions/extensions.dart';
import '../source/constant/colors_constant.dart';
import 'custom_text.dart';

class CustomMonthPicker extends StatefulWidget {
  final int initialMonth;
  final int initialYear;
  final int firstYear;
  final int lastYear;
  final ValueChanged<DateTime> onSelected;

  const CustomMonthPicker({
    super.key,
    required this.initialMonth,
    required this.initialYear,
    required this.firstYear,
    required this.lastYear,
    required this.onSelected,
  });

  @override
  _CustomMonthPickerState createState() => _CustomMonthPickerState();
}

class _CustomMonthPickerState extends State<CustomMonthPicker> {
  late int selectedMonth;
  late int selectedYear;
  bool isYearPickerVisible = false;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialMonth;
    selectedYear = widget.initialYear;
  }

  Widget _buildYearGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemCount: widget.lastYear - widget.firstYear + 1,
      itemBuilder: (context, index) {
        final year = widget.firstYear + index;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedYear = year;
              isYearPickerVisible = false;
            });
          },
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: selectedYear == year
                  ? colorsConst.primary
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$year',
              style: TextStyle(
                color: selectedYear == year ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget _buildMonthGrid() {
  //   const monthNames = [
  //     'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  //     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  //   ];
  //
  //   return GridView.builder(
  //     shrinkWrap: true,
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 4,
  //       mainAxisSpacing: 8.0,
  //       crossAxisSpacing: 8.0,
  //     ),
  //     itemCount: 12,
  //     itemBuilder: (context, index) {
  //       final month = index + 1;
  //       return GestureDetector(
  //         onTap: () {
  //           setState(() {
  //             selectedMonth = month;
  //           });
  //         },
  //         child: Container(
  //           alignment: Alignment.center,
  //           margin: const EdgeInsets.all(4.0),
  //           decoration: BoxDecoration(
  //             color: selectedMonth == month
  //                 ? colorsConst.primary
  //                 : Colors.transparent,
  //             shape: BoxShape.circle,
  //           ),
  //           child: CustomText(
  //             text: monthNames[index],
  //             colors: selectedMonth == month ? Colors.white : Colors.black,
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildMonthGrid() {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final now = DateTime.now();
    final isCurrentYear = selectedYear == now.year;
    final currentMonth = now.month;

    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final isEnabled = !isCurrentYear || month == currentMonth;
        return GestureDetector(
          onTap: isEnabled
              ? () {
            setState(() {
              selectedMonth = month;
            });
          }
              : null,
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.3,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: selectedMonth == month
                    ? colorsConst.primary
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: CustomText(
                text: monthNames[index],
                colors: selectedMonth == month ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: colorsConst.primary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                text: "Select Month/Year",
                size: 10,
                colors: Colors.white,
              ),
              CustomText(
                text:
                '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][selectedMonth - 1]} $selectedYear',
                size: 20,
                colors: Colors.white,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                isYearPickerVisible = !isYearPickerVisible;
              });
            },
            child: Row(
              children: [
                CustomText(text: '$selectedYear'),
                Icon(
                  isYearPickerVisible
                      ? Icons.arrow_drop_up_outlined
                      : Icons.arrow_drop_down_outlined,
                  size: 25,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: isYearPickerVisible ? _buildYearGrid() : _buildMonthGrid(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: CustomText(
                text: 'Cancel',
                colors: colorsConst.greyClr,
              ),
            ),
            TextButton(
              onPressed: () {
                widget.onSelected(DateTime(selectedYear, selectedMonth));
                Navigator.of(context).pop();
              },
              child: CustomText(
                text: 'OK',
                colors: colorsConst.primary,isBold: true,
              ),
            ),
            20.width,
          ],
        ),
      ],
    );
  }
}


