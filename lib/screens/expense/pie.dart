import 'package:master_code/view_model/expense_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_code/source/extentions/extensions.dart';
import '../../component/custom_text.dart';
import '../../source/constant/colors_constant.dart';

class TravelPieChart extends StatefulWidget {
  const TravelPieChart({super.key});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<TravelPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expProvider, _) {
        final List<Map<String, dynamic>> rawData = expProvider.report2
            .whereType<Map<String, dynamic>>()
            .toList();
      print(rawData);
        rawData.sort((a, b) {
          double amtA = double.tryParse(a["total_amount"].toString().replaceAll(",", "")) ?? 0;
          double amtB = double.tryParse(b["total_amount"].toString().replaceAll(",", "")) ?? 0;
          return amtA.compareTo(amtB); // A to Z (ascending)
        });
        // Filter data: remove total_amount == 0
        final List<Map<String, dynamic>> data = rawData.where((item) {
          double val = double.tryParse(item["total_amount"].toString()) ?? 0.0;
          return val > 0;
        }).toList();

        if (data.isEmpty) {
          return const Center(child: Text("No data available for the chart"));
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: kIsWeb?MediaQuery.of(context).size.width*0.25:MediaQuery.of(context).size.width * 0.45,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: SizedBox(
                height: 200,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 30,
                      sections: showingSections(data),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: kIsWeb?MediaQuery.of(context).size.width*0.2:100,
              color: Colors.white,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  final label = "${item['mode']}";
                  final color = _getColor(index);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Indicator(
                      color: color,
                      text: label,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  Color _getColor(int index) {
    final colors = [
      colorsConst.appDarkGreen,
      colorsConst.appRed,
      Colors.orange,
      Colors.blue,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }
  List<PieChartSectionData> showingSections(List<Map<String, dynamic>> data) {
    final double total = data.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item["total_amount"].toString()) ?? 0.0);
    });

    return List.generate(data.length, (i) {
      final item = data[i];
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 10.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      double originalValue = double.tryParse(item["total_amount"].toString()) ?? 0.0;
      double originalPercent = (originalValue / total) * 100;

      // Apply a visual boost for small values
      double adjustedPercent = originalPercent < 5 ? 5 : originalPercent;

      // Convert adjusted percent back to value (for rendering only)
      double visualValue = (adjustedPercent / 100) * total;

      return PieChartSectionData(
        color: _getColor(i),
        value: visualValue,
        borderSide: BorderSide(
          color: Colors.white,
          width: originalPercent < 5 ? 0.2 : 0, // border for small slices
        ),
        title: originalPercent < 1 ? '1%' : '${originalPercent.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }

}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    this.size = 16,
    this.textColor,
  });

  final Color color;
  final String text;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: color,
          ),
        ),
        4.width,
        CustomText(text: text, colors: textColor),
      ],
    );
  }
}
