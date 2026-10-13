import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/screens/task/task_chat.dart';
import 'package:master_code/screens/task/task_details.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../model/task/task_data_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/language_model.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/task_provider.dart';
import '../common/dashboard.dart';

class TaskCalendar extends StatefulWidget {
  final TaskProvider taskPvr;
  const TaskCalendar({super.key, required this.taskPvr});

  @override
  CalendarAppointment createState() => CalendarAppointment();
}

class CalendarAppointment extends State<TaskCalendar> {
  final CalendarController _calendarController = CalendarController();

  // ---------------------------------------------------------------------------
  // PERFORMANCE HELPERS
  // ---------------------------------------------------------------------------

  /// ✅ DateFormat create panradhu costly. Munnadi ovoru task kum, ovoru build
  /// kum puthusa create aagitu irundhuchu. Ippo oru dhadava mattum.
  static final DateFormat _df = DateFormat('dd-MM-yyyy');
  static final DateFormat _displayDf = DateFormat('dd MMM yyyy');

  /// ✅ parse cache (same date string thirumba thirumba parse aagaadhu)
  final Map<String, DateTime?> _parseCache = {};

  DateTime? _parse(String? s) {
    if (s == null) return null;
    final key = s.trim();
    if (key.isEmpty || key == "null") return null;
    return _parseCache.putIfAbsent(key, () {
      try {
        return _df.parse(key);
      } catch (_) {
        return null;
      }
    });
  }

  int _dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  /// ✅ appointment irukkura dates oru Set la. Munnadi ovoru calendar cell kum
  /// (42 cells) ellaa appointments um scan aagitu irundhuchu.
  /// Ippo provider data maarina (dataVersion) mattum thirumba build aagum.
  int _cachedVersion = -1;
  Set<int> _apptDays = <int>{};

  Set<int> _getApptDays() {
    final v = widget.taskPvr.dataVersion;
    if (v != _cachedVersion) {
      _cachedVersion = v;
      final set = <int>{};
      try {
        final list = widget.taskPvr.dataSource.appointments;
        if (list != null) {
          for (final a in list) {
            if (a is Appointment) {
              set.add(_dayKey(a.startTime));
            }
          }
        }
      } catch (_) {
        // dataSource innum set aagala na empty
      }
      _apptDays = set;
    }
    return _apptDays;
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var webWidth = MediaQuery.of(context).size.width * 0.5;
    var phoneWidth = MediaQuery.of(context).size.width * 0.95;
    final DateTime now = DateTime.now();
    final DateTime firstDayOfYear = DateTime(now.year - 1, 12, 1);
    final DateTime lastDayOfYear = DateTime(now.year, 12, 31);

    final tp = widget.taskPvr;
    final String monthPad = utils.returnPadLeft(tp.defaultMonth.toString());

    /// ✅ CALCULATE "THIS MONTH" COUNT BASED ON CALENDAR'S CURRENT VISIBLE MONTH
    /// (same defaultMonth the list uses, so count and list stay in sync)
    int thisMonthCount = 0;
    for (final task in tp.allTasks) {
      final d = _parse(task.taskDate?.toString());
      if (d != null && monthPad == utils.returnPadLeft(d.month.toString())) {
        thisMonthCount++;
      }
    }

    /// ✅ Month + selected date filter pannina list, ONCE per build.
    /// Munnadi allTasks full list ku ListView.builder + non-matching ku
    /// SizedBox return pannitu irundhom (ellaa tasks um build aagum).
    final List<TaskData> monthTasks = tp.taskList;

    /// ✅ selected filter date, once per build (munnadi ovoru cell kum parse)
    final DateTime? parsedFilterDate =
    tp.filterDate.isNotEmpty ? _parse(tp.filterDate) : null;

    final Set<int> apptDays = _getApptDays();

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorsConst.bacColor,
        body: Center(
          child: tp.refresh == false
              ? Loading()
              : Column(
            children: [
              15.height,
              SizedBox(
                width: kIsWeb ? webWidth : phoneWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomText(
                            text: "Total Task",
                            colors: colorsConst.secondary),
                        CustomText(
                          text: "  ${tp.searchAllTasks.length}",
                          colors: colorsConst.primary,
                          isBold: true,
                        )
                      ],
                    ),
                    Row(
                      children: [
                        CustomText(
                            text: "This Month",
                            colors: colorsConst.secondary),
                        CustomText(
                            text: "  $thisMonthCount",
                            colors: colorsConst.appRed,
                            isBold: true),
                      ],
                    ),
                  ],
                ),
              ),
              10.height,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: kIsWeb ? webWidth : phoneWidth,
                        height: 45,
                        decoration: customDecoration
                            .baseBackgroundDecoration(
                          radius: 30,
                          color: colorsConst.primary,
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            Center(
                                child: Icon(Icons.search,
                                    color: Colors.white)),
                            SizedBox(
                              width: kIsWeb
                                  ? webWidth
                                  : phoneWidth / 1.1,
                              child: TextFormField(
                                cursorColor: colorsConst.primary,
                                onChanged: (value) {
                                  tp.searchTask2(value.toString());
                                },
                                textInputAction:
                                TextInputAction.done,
                                controller: tp.search2,
                                decoration: InputDecoration(
                                  hintText:
                                  "Search Name or ${constValue.customer}",
                                  hintStyle: TextStyle(
                                      color: colorsConst.primary,
                                      fontSize: 14),
                                  fillColor: Colors.white,
                                  filled: true,
                                  suffixIcon: tp.search2.text
                                      .isNotEmpty
                                      ? GestureDetector(
                                      onTap: () {
                                        tp.search2.clear();
                                        tp.searchTask2("");
                                      },
                                      child: Container(
                                          width: 10,
                                          height: 10,
                                          color: Colors
                                              .transparent,
                                          child: Padding(
                                            padding:
                                            const EdgeInsets
                                                .all(8.0),
                                            child: SvgPicture
                                                .asset(assets
                                                .cancel2),
                                          )))
                                      : null,
                                  errorStyle: const TextStyle(
                                    fontSize: 12.0,
                                    height: 0.20,
                                  ),
                                  focusedBorder:
                                  OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: colorsConst
                                              .primary),
                                      borderRadius:
                                      BorderRadius
                                          .circular(30)),
                                  focusedErrorBorder:
                                  OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: colorsConst
                                              .primary),
                                      borderRadius:
                                      BorderRadius
                                          .circular(30)),
                                  contentPadding:
                                  const EdgeInsets.fromLTRB(
                                      10, 10, 10, 10),
                                  errorBorder:
                                  OutlineInputBorder(
                                      borderSide:
                                      const BorderSide(
                                          color: Colors
                                              .transparent),
                                      borderRadius:
                                      BorderRadius
                                          .circular(30)),
                                  enabledBorder:
                                  OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors
                                              .grey.shade300),
                                      borderRadius:
                                      BorderRadius
                                          .circular(30)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      10.height,
                      Container(
                        decoration: customDecoration
                            .baseBackgroundDecoration(
                            color: Colors.white, radius: 10),
                        width: kIsWeb ? webWidth : phoneWidth,
                        height: 300,
                        child: SfCalendar(
                          controller: _calendarController,
                          view: CalendarView.month,
                          headerHeight: 50,
                          cellBorderColor: Colors.transparent,
                          todayTextStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          dataSource: tp.dataSource,
                          minDate: firstDayOfYear,
                          maxDate: lastDayOfYear,
                          onLongPress: null,
                          onSelectionChanged: null,
                          onTap: (CalendarTapDetails value) {
                            if (value.date != null) {
                              final tappedMonth = value.date!.month;
                              final visibleMonth = tp.defaultMonth;

                              if (tappedMonth != visibleMonth) {
                                _calendarController.displayDate =
                                value.date!;
                                return;
                              }

                              String selectedDate =
                              _df.format(value.date!);

                              tp.setFilterDate(selectedDate);
                            }
                          },
                          onViewChanged: (details) {
                            tp.checkMonth2();
                            tp.checkMonth(details);
                          },
                          monthCellBuilder: (BuildContext context,
                              MonthCellDetails details) {
                            // ✅ O(1) Set lookup (munnadi list scan)
                            final bool hasAppointments =
                            apptDays.contains(_dayKey(details.date));

                            final bool isSelected =
                                parsedFilterDate != null &&
                                    isSameDate(
                                        details.date, parsedFilterDate);

                            // Middle date -> current visible month
                            int midIndex =
                                details.visibleDates.length ~/ 2;
                            int visibleMonth =
                                details.visibleDates[midIndex].month;

                            bool isInCurrentMonth =
                                details.date.month == visibleMonth;
                            Color textColor = isSelected
                                ? colorsConst.greyClr
                                : isInCurrentMonth
                                ? Colors.black
                                : colorsConst.litGrey;

                            return Container(
                              alignment: Alignment.topLeft,
                              margin: const EdgeInsets.all(4),
                              decoration: customDecoration
                                  .baseBackgroundDecoration(
                                color: hasAppointments
                                    ? colorsConst.primary
                                    : Colors.transparent,
                                radius: 50,
                              ),
                              child: Center(
                                child: CustomText(
                                  text: details.date.day.toString(),
                                  isBold: true,
                                  colors: hasAppointments
                                      ? Colors.white
                                      : isSelected
                                      ? Colors.black
                                      : textColor,
                                ),
                              ),
                            );
                          },
                          monthViewSettings: MonthViewSettings(
                            appointmentDisplayMode:
                            MonthAppointmentDisplayMode.none,
                            monthCellStyle: MonthCellStyle(
                              textStyle: TextStyle(
                                color: colorsConst.appDarkGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                              trailingDatesTextStyle: TextStyle(
                                color: colorsConst.litGrey,
                              ),
                              leadingDatesTextStyle: TextStyle(
                                color: colorsConst.litGrey,
                              ),
                            ),
                          ),
                        ),
                      ),

                      /// ✅ Already filtered list (month + selected date).
                      /// Match aagura tasks mattum build aagum.
                      monthTasks.isEmpty
                          ? CustomText(
                        text: "\n\nNo tasks found",
                        colors: colorsConst.secondary,
                        size: 14,
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(),
                        itemCount: monthTasks.length,
                        itemBuilder: (context, index) {
                          final TaskData data = monthTasks[index];
                          return dataList(
                            kIsWeb ? webWidth : phoneWidth,
                            data,
                          );
                        },
                      ),
                      30.height
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// allTasks la intha task oda index (munnadi pola). Tap pannum bodhu mattum
  /// compute aagum, ovoru item build la illa.
  int _indexInAllTasks(TaskData data) {
    final i = widget.taskPvr.allTasks.indexOf(data);
    return i < 0 ? 0 : i;
  }

  Widget dataList(double width, TaskData data) {
    final DateTime? taskDt = _parse(data.taskDate?.toString());
    final String taskDateText =
    taskDt != null ? _displayDf.format(taskDt) : "";

    return GestureDetector(
      onTap: () {
        utils.navigatePage(
          context,
              () => DashBoard(
            child: TaskDetails(
              data: data,
              isDirect: true,
              coId: "0",
              numberList: const [],
              index: _indexInAllTasks(data),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: colorsConst.primary,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: Container(
              decoration: customDecoration.baseBackgroundDecoration(
                  color: Colors.white,
                  borderColor: Colors.transparent,
                  radius: 10),
              width: width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: width / 1.5,
                            child: CustomText(
                              text: data.taskTitle.toString(),
                              isBold: true,
                            )),
                        Container(
                          width: width / 4,
                          decoration: customDecoration
                              .baseBackgroundDecoration(
                              color: Colors.pink.shade100, radius: 10),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: CustomText(
                                  text: data.statval.toString(),
                                  colors: colorsConst.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    5.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CustomText(
                              text: data.projectName.toString() == "null"
                                  ? ""
                                  : data.projectName.toString(),
                              colors: colorsConst.primary,
                            ),
                            5.width,
                            const Icon(Icons.circle, size: 8),
                            5.width,
                            CustomText(text: data.type.toString()),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_sharp,
                                color: colorsConst.greyClr, size: 15),
                            5.width,
                            CustomText(
                              text: taskDateText,
                              colors: colorsConst.greyClr,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (data.assignedNames.toString() != "null")
                          Row(
                            children: [
                              Icon(
                                Icons.featured_play_list_outlined,
                                color: colorsConst.greyClr,
                                size: 15,
                              ),
                              5.width,
                              CustomText(
                                text: data.assignedNames.toString(),
                                colors: colorsConst.greyClr,
                              ),
                            ],
                          ),
                        IconButton(
                            onPressed: () {
                              utils.navigatePage(
                                context,
                                    () => TaskChat(
                                  isVisit: false,
                                  taskId: data.id.toString(),
                                  assignedId: data.assigned.toString(),
                                  name: data.creator.toString(),
                                  assignedName: data.assignedNames.toString(),
                                  date1: '',
                                  date2: '',
                                  type: '',
                                  index: _indexInAllTasks(data),
                                ),
                              );
                            },
                            icon: SvgPicture.asset(assets.tMessage,
                                width: 25, height: 25))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}