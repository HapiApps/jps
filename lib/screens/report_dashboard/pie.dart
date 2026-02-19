import 'package:master_code/view_model/home_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/report_provider.dart';
import '../../component/custom_text.dart';
import '../../source/constant/colors_constant.dart';

class TaskPieChart extends StatefulWidget {
  const TaskPieChart({super.key});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(builder: (context,repProvider,_){
      return AspectRatio(
      aspectRatio: kIsWeb?4:1.3,
      child: Container(
        width: MediaQuery.of(context).size.width*0.8,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
                bottomLeft: Radius.circular(10)
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
              height: 100,
              width: MediaQuery.of(context).size.width*0.4,
              // color: Colors.pink,
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
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 0,
                    centerSpaceRadius: 30,
                    sections: showingSections(
                        repProvider.taskReport.isEmpty?"40":repProvider.taskReport[0]["total_tasks"],
                        repProvider.taskReport.isEmpty?"40":repProvider.taskReport[0]["complete_count"],
                        repProvider.taskReport.isEmpty?"40":repProvider.taskReport[0]["incomplete_count"]
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Indicator(
                  color: colorsConst.blueClr,
                  text: 'Assigned',
                ),10.width,
                Indicator(
                  color: colorsConst.appDarkGreen,
                  text: 'Completed',
                ),10.width,
                Indicator(
                  color: colorsConst.appRed,
                  text: 'Pending',
                )
              ],
            )
          ],
        ),
      ),
    );
    });
  }

  List<PieChartSectionData> showingSections(String value1,String value2,String value3) {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: colorsConst.blueClr,
            value: double.parse(value1),
            title: value1.toString(),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: colorsConst.appDarkGreen,
            value: double.parse(value2),
            title: value2.toString(),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
          case 2:
          return PieChartSectionData(
            color: colorsConst.appRed,
            value: double.parse(value3),
            title: value3.toString(),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
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
            // shape: BoxShape.circle,
            color: color,
          ),
        ),
        4.width,
        CustomText(text: text,colors: textColor),
      ],
    );
  }
}


class CustomerTaskPieChart extends StatefulWidget {
  const CustomerTaskPieChart({super.key});

  @override
  State<StatefulWidget> createState() => CustomerTaskPieChartState();
}

class CustomerTaskPieChartState extends State {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(builder: (context,repProvider,_){
      return AspectRatio(
        aspectRatio: kIsWeb?4:1.3,
        child: Container(
          width: MediaQuery.of(context).size.width*0.8,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10)
              )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width*0.4,
                // color: Colors.pink,
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
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 30,
                      sections: showingSections(
                          repProvider.customerTasks.isEmpty?"40":repProvider.customerTasks[0]["total_tasks"],
                          repProvider.customerTasks.isEmpty?"40":repProvider.customerTasks[0]["complete_count"],
                          repProvider.customerTasks.isEmpty?"40":repProvider.customerTasks[0]["incomplete_count"]
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomerIndicator(
                    color: colorsConst.blueClr,
                    text: 'Assigned',
                  ),10.width,
                  CustomerIndicator(
                    color: colorsConst.appDarkGreen,
                    text: 'Completed',
                  ),10.width,
                  CustomerIndicator(
                    color: colorsConst.appRed,
                    text: 'Pending',
                  )
                ],
              )
            ],
          ),
        ),
      );
    });
  }

  List<PieChartSectionData> showingSections(String value1,String value2,String value3) {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: colorsConst.blueClr,
            value: double.parse(value1),
            title: value1.toString(),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: colorsConst.appDarkGreen,
            value: double.parse(value2),
            title: value2.toString(),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: colorsConst.appRed,
            value: double.parse(value3),
            title: value3.toString(),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}

class CustomerIndicator extends StatelessWidget {
  const CustomerIndicator({
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
            // shape: BoxShape.circle,
            color: color,
          ),
        ),
        4.width,
        CustomText(text: text,colors: textColor),
      ],
    );
  }
}


class PieChartDash extends StatefulWidget {
  const PieChartDash({super.key});

  @override
  State<StatefulWidget> createState() => PieChartDashState();
}

class PieChartDashState extends State {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context,cusProvider,_){
      return PieChart(
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
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: 0,
          centerSpaceRadius: 0,
          sections: showingSections(
              // cusProvider.mainReportList[0]["total_tasks"],
              cusProvider.mainReportList[0]["incomplete_count"],
              cusProvider.mainReportList[0]["complete_count"]
          ),
        ),
      );
    });
  }

  List<PieChartSectionData> showingSections(String value2,String value3) {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 10.0;
      final radius = isTouched ? 35.0 : 25.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        // case 0:
          // return PieChartSectionData(
          //   color: Colors.blue,
          //   value: double.parse(value1),
          //   title: value1.toString(),
          //   radius: radius,
          //   titleStyle: TextStyle(
          //     fontSize: fontSize,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.white,
          //     shadows: shadows,
          //   ),
          // );
        case 0:
          return PieChartSectionData(
            color: Colors.red,
            value: double.parse(value2),
            title: value2.toString(),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
          case 1:
          return PieChartSectionData(
            color:Colors.green,
            value: double.parse(value3),
            title: value3.toString(),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}