import 'dart:developer';
import 'package:master_code/screens/task/wages_work_report.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/model/task/task_data_model.dart';
import 'package:master_code/screens/task/task_chat.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:master_code/view_model/customer_provider.dart';
import 'package:provider/provider.dart';
import '../../component/audio_player.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../model/customer/customer_report_model.dart';
import '../../source/constant/api.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../source/utilities/voice_transcribe_service.dart';
import '../../view_model/expense_provider.dart';
import '../../view_model/task_provider.dart';
import '../common/dashboard.dart';
import 'edit_task.dart';
import 'task_summary_pdf.dart';

class TaskDetails extends StatefulWidget {
  final TaskData data;
  final bool isDirect;
  final String coId;
  final List numberList;
  final int index;
  const TaskDetails(
      {super.key,
        required this.data,
        required this.isDirect,
        required this.coId,
        required this.numberList,
        required this.index});

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails>
    with SingleTickerProviderStateMixin {

  bool isTaskTitleExpanded = true;

  // ===== DESCRIPTION =====
  bool isDescriptionExpanded = false;
  static const int _descPreviewLines = 4;

  static const int _workPreviewCount = 5;

  String level = '';
  var type = "0";
  var imgC = 0;
  var voiceC = 0;
  var docsList = [];
  var imgList = [];
  var voiceList = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool networkPlaying = false;
  final AudioPlayer _listAudioPlayer = AudioPlayer();

  String? playingUrl;
  bool isPlaying = false;
  bool isBuffering = false;
  String? loadingUrl;
  bool isLoadingAudio = false;
  Duration totalDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  Duration networkCurrent = Duration.zero;
  Duration networkTotal = Duration.zero;

  // ===== TASK SUMMARY PDF =====
  bool _pdfBusy = false;

  /// ✅ indha page-oda sondha data load (history / comments / work history).
  /// PDF button idha wait pannum -> "still loading" block illa.
  Future<void> _loadFuture = Future.value();

  // ===== VOICE TO TEXT (url -> transcript) =====
  final Map<String, String> _transcripts = {};
  final Map<String, bool> _transcribing = {};

  @override
  void initState() {
    super.initState();

    level = widget.data.level.toString();

    // ✅ docs parse -> API ku wait pannaama, first frame lerundhe attachments theriyum
    _parseDocs();

    /// ================= NETWORK PLAYER =================
    _audioPlayer.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() {
        networkTotal = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (!mounted) return;
      // ✅ second maarina mattum rebuild (sec ku 5-10 rebuild aagaadhu)
      if (p.inSeconds == networkCurrent.inSeconds) return;
      setState(() {
        networkCurrent = p;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (!mounted) return;
      setState(() {
        networkPlaying = false;
        networkCurrent = Duration.zero;
        playingUrl = null;
      });
    });

    /// ================= LIST PLAYER =================
    _listAudioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        isPlaying = state == PlayerState.playing;
        // play start aanadhum loading spinner nikkum
        if (state == PlayerState.playing) {
          isLoadingAudio = false;
          loadingUrl = null;
        }
      });
    });

    _listAudioPlayer.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() {
        totalDuration = d;
      });
    });

    _listAudioPlayer.onPositionChanged.listen((p) {
      if (!mounted) return;
      // ✅ second maarina mattum rebuild
      if (p.inSeconds == currentPosition.inSeconds) return;
      setState(() {
        currentPosition = p;
      });
    });

    _listAudioPlayer.onPlayerComplete.listen((event) {
      if (!mounted) return;
      setState(() {
        isPlaying = false;
        currentPosition = Duration.zero;
        totalDuration = Duration.zero;
        playingUrl = null;
      });
    });

    /// ================= API LOAD =================
    _loadFuture = Future.microtask(() async {
      if (!mounted) return;

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final expenseProvider =
      Provider.of<ExpenseProvider>(context, listen: false);
      final customerProvider =
      Provider.of<CustomerProvider>(context, listen: false);

      // timer: getAllTask nadakkaama direct-ah vandhaalum seed aagum
      taskProvider.ensureTimer(widget.data);

      taskProvider.lStatus = widget.data.statval.toString();
      taskProvider.setStatus(taskProvider.lStatus);
      taskProvider.setStatusByName(widget.data.statval.toString());

      // ✅ 3 independent chains -> parallel (munnadi ellam sequential, slow)
      await Future.wait([
        _loadExpenses(expenseProvider),
        _loadHistory(taskProvider),
        _loadComments(customerProvider),
        _loadWorkHistory(taskProvider),
      ]);

      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _loadExpenses(ExpenseProvider expenseProvider) async {
    try {
      if (kIsWeb) {
        await expenseProvider.getExpenseType();
      } else {
        await expenseProvider.getTypesOfExpense();
      }
      await expenseProvider.getAllExpense();
    } catch (e) {
      debugPrint("LOAD EXPENSES ERROR => $e");
    }
  }

  Future<void> _loadHistory(TaskProvider taskProvider) async {
    try {
      await taskProvider.getStatusHistory(widget.data.id.toString());

      // ✅ History load aanadhukku apram, latest status-ah provider-ku sync pannum
      final latest = _latestHistoryStatus(taskProvider);
      if (latest != null) {
        taskProvider.lStatus = latest;
        taskProvider.setStatus(latest);
        taskProvider.setStatusByName(latest);
      }
    } catch (e) {
      debugPrint("LOAD HISTORY ERROR => $e");
    }
  }

  // getComments & getTaskComments rendum same provider state ah use pannum,
  // adhanaala ivanga rendum sequential ah dhaan irukkanum
  Future<void> _loadComments(CustomerProvider customerProvider) async {
    try {
      await customerProvider.getComments(widget.data.id.toString());
      await customerProvider.getTaskComments(widget.data.id.toString());
    } catch (e) {
      debugPrint("LOAD COMMENTS ERROR => $e");
    }
  }

  Future<void> _loadWorkHistory(TaskProvider p) async {
    try {
      await p.getWorkHistory(widget.data.id.toString());
    } catch (e) {
      debugPrint("LOAD WORK HISTORY ERROR => $e");
    }
  }

  DateTime? _dt(dynamic v) => DateTime.tryParse((v ?? "").toString().trim());

  String _dur(Duration d) {
    final s = d.inSeconds < 0 ? 0 : d.inSeconds;
    final h = s ~/ 3600, m = (s % 3600) ~/ 60, x = s % 60;
    if (h > 0) return "${h}h ${m}m";
    if (m > 0) return "${m}m ${x}s";
    return "${x}s";
  }

  /// logs (ASC) -> rows with label + "Worked 30m" / "Paused 10m"
  List<Map<String, dynamic>> _buildWorkRows(List logs) {
    final rows = <Map<String, dynamic>>[];
    final lastAction = <String, String>{};
    final lastTime = <String, DateTime>{};
    final lastStart = <String, DateTime>{};

    for (final raw in logs) {
      final l = Map<String, dynamic>.from(raw as Map);
      final emp = l['employee_id'].toString();
      final action = l['action'].toString();
      final t = _dt(l['action_time']);
      final prev = lastAction[emp];

      String label;
      String note = "";
      Color color;

      if (action == "Start" || action == "Resume") {
        final resumed = action == "Resume" || (prev != null && prev != "Start");
        label = resumed ? "Resumed" : "Started";
        color = resumed ? Colors.blue : Colors.green;
        if (resumed && t != null && lastTime[emp] != null) {
          note = "Paused ${_dur(t.difference(lastTime[emp]!))}";
        }
        if (t != null) lastStart[emp] = t;
      } else if (action == "Hold") {
        label = "On Hold";
        color = Colors.orange;
        if (t != null && lastStart[emp] != null) {
          note = "Worked ${_dur(t.difference(lastStart[emp]!))}";
        }
      } else {
        label = "Completed";
        color = const Color(0xff0B5FB5);
        if (t != null && lastStart[emp] != null) {
          note = "Worked ${_dur(t.difference(lastStart[emp]!))}";
        }
      }

      lastAction[emp] = action;
      if (t != null) lastTime[emp] = t;

      rows.add({
        "label": label,
        "note": note,
        "color": color,
        "name": (l['employee_name'] ?? "").toString(),
        "time": t != null ? DateFormat("dd-MM-yyyy, hh:mm a").format(t) : "-",
      });
    }
    return rows;
  }

  Widget _workRow(Map<String, dynamic> r, bool isLast) {
    final Color c = r["color"] as Color;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r["label"].toString(),
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold, color: c),
                    ),
                    Text(
                      r["name"].toString(),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    if (r["note"].toString().isNotEmpty)
                      Text(
                        r["note"].toString(),
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ),
              Text(
                r["time"].toString(),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: Colors.grey.shade300, thickness: 1),
      ],
    );
  }

  void _showAllWorkHistory(List<Map<String, dynamic>> rows) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Work History (${rows.length})",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(sheetCtx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    itemCount: rows.length,
                    itemBuilder: (_, i) =>
                        _workRow(rows[i], i == rows.length - 1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _workHistoryCard(TaskProvider tp, double width) {
    // duration calc oldest->newest; display newest first
    final rows = _buildWorkRows(tp.workHistory).reversed.toList();
    final visibleRows = rows.take(_workPreviewCount).toList();

    return Center(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Work History",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              12.height,
              if (tp.workHistoryLoading)
                const Loading()
              else if (rows.isEmpty)
                Center(
                  child: CustomText(
                    text: "No Work History Found",
                    size: 14,
                    colors: Colors.grey,
                  ),
                )
              else ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visibleRows.length,
                    itemBuilder: (context, i) =>
                        _workRow(visibleRows[i], i == visibleRows.length - 1),
                  ),
                  if (rows.length > _workPreviewCount)
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () => _showAllWorkHistory(rows),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, right: 5),
                          child: Text(
                            "View More (${rows.length - _workPreviewCount} more)",
                            style: TextStyle(
                              color: colorsConst.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // DESCRIPTION SECTION
  // ===========================================================================

  /// Task description (null / "null" / empty -> "")
  /// ⚠️ TaskData model-la field name vera na (eg: taskDescription, details),
  /// indha line-la mattum maathunga.
  String get _taskDescription {
    final d = (widget.data.taskDesc ?? "").toString().trim();
    return d == "null" ? "" : d;
  }

  Widget _descriptionCard(double width) {
    final String desc = _taskDescription;

    const descStyle = TextStyle(
      fontSize: 14,
      fontFamily: "Lato",
      color: Colors.black87,
      height: 1.45,
    );

    return Center(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= TITLE =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description_outlined,
                          size: 18, color: colorsConst.primary),
                      6.width,
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (desc.isNotEmpty)
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Clipboard.setData(ClipboardData(text: desc));
                        utils.showSuccessToast(
                            context: context, text: "Description copied");
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.copy_rounded,
                            size: 18, color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ),
              Divider(color: Colors.grey.shade300, thickness: 1.2),
              6.height,

              /// ================= BODY =================
              if (desc.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: CustomText(
                      text: "No Description Found",
                      size: 14,
                      colors: Colors.grey,
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    // 4 line-ku mela pogudha nu check pannum
                    final tp = TextPainter(
                      text: TextSpan(text: desc, style: descStyle),
                      maxLines: _descPreviewLines,
                      textDirection: Directionality.of(context),
                    )..layout(maxWidth: constraints.maxWidth);
                    final bool hasOverflow = tp.didExceedMaxLines;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isDescriptionExpanded || !hasOverflow
                            ? SelectableText(desc, style: descStyle)
                            : Text(
                          desc,
                          style: descStyle,
                          maxLines: _descPreviewLines,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hasOverflow)
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => isDescriptionExpanded =
                                !isDescriptionExpanded);
                              },
                              child: Padding(
                                padding:
                                const EdgeInsets.only(top: 8, right: 5),
                                child: Text(
                                  isDescriptionExpanded
                                      ? "Show Less"
                                      : "Show More",
                                  style: TextStyle(
                                    color: colorsConst.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // WORK TIMER (Start / Hold / Resume / Complete) - View Task card-oda adhe logic
  // ===========================================================================
  static const int _daySecs = 24 * 3600;

  String _hms(int s) {
    if (s < 0) s = 0;
    if (s >= _daySecs) return _worked(s);
    final h = (s ~/ 3600).toString().padLeft(2, '0');
    final m = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final x = (s % 60).toString().padLeft(2, '0');
    return "$h:$m:$x";
  }

  String _worked(int s) {
    if (s < 0) s = 0;
    final d = s ~/ _daySecs;
    final h = (s % _daySecs) ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final x = s % 60;
    if (d > 0) return "${d}d ${h}h ${m}m";
    if (h > 0) return "${h}h ${m}m";
    if (m > 0) return "${m}m ${x}s";
    return "${x}s";
  }

  Widget _timerBtn(String text, IconData icon, Color color, VoidCallback onTap,
      {bool filled = true}) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? color : color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: filled ? Colors.white : color),
          const SizedBox(width: 5),
          Text(text,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: filled ? Colors.white : color)),
        ]),
      ),
    );
  }

  Future<void> _afterTimerAction(TaskProvider tp) async {
    if (!mounted) return;
    await tp.getWorkHistory(widget.data.id.toString());
    // ✅ Complete -> status "Completed" aagum, Progress Tracker-um refresh
    if (!mounted) return;
    await tp.getStatusHistory(widget.data.id.toString());
  }

  Future<void> _confirmComplete(TaskProvider tp, TaskData d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Complete work?"),
        content: Text("Total worked: ${_worked(tp.currentSeconds(d.id.toString()))}"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Yes, Complete")),
        ],
      ),
    );
    if (ok == true && mounted) {
      await tp.insertTaskLogHistory(context, id: d.id.toString(), level: "Complete");
      await _afterTimerAction(tp);
    }
  }

  Widget _workTimerCard(TaskProvider tp, double width) {
    final d = tp.latestTask(widget.data);
    final id = d.id.toString();
    final mine = tp.isMyTask(d);

    return ValueListenableBuilder<int>(
      valueListenable: tp.tickNotifier,
      builder: (_, __, ___) {
        final state = tp.workState(d);
        final secs = tp.currentSeconds(id);

        // munnadi: en task illa + start aagala -> bar-ae hide (adhanaala overdue
        // task-la "Start" illa-nu thonuchu). Ippo reason-oda info bar kaattum.
        final bool locked = state == "idle" && !mine;
        if (locked && kDebugMode) {
          debugPrint("TIMER-LOCKED id=$id assigned='${d.assigned}' "
              "names='${d.assignedNames}' myId='${localData.storage.read("id")}' "
              "myName='${localData.storage.read("f_name")}'");
        }

        Color accent;
        String title, sub;
        switch (state) {
          case "running":
            accent = const Color(0xff1FAF38);
            title = _hms(secs);
            sub = secs >= _daySecs
                ? "Working now • running over a day, check timer"
                : "Working now";
            break;
          case "hold":
            accent = const Color(0xffF59E0B);
            title = _hms(secs);
            sub = "On hold • worked ${_worked(secs)}";
            break;
          case "done":
            accent = const Color(0xff0B5FB5);
            title = _worked(secs);
            sub = "Work completed";
            break;
          default:
            accent = const Color(0xff6B7280);
            if (locked) {
              final who = (d.assignedNames ?? "").toString().trim();
              title = "Not started yet";
              sub = who.isEmpty || who == "null"
                  ? "Only the assigned person can start"
                  : "Only $who can start this timer";
            } else {
              title = "Ready to start";
              sub = "Tap Start (or set status to Started) to track time";
            }
        }

        Widget actions;
        if (state == "done") {
          actions = Icon(Icons.check_circle, color: accent, size: 26);
        } else if (!mine) {
          actions = locked
              ? const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xff9CA3AF))
              : const SizedBox.shrink(); // others only watch
        } else if (state == "idle") {
          actions = _timerBtn("Start", Icons.play_arrow_rounded, colorsConst.primary,
                  () async {
                await tp.startWork(context, d);
                await _afterTimerAction(tp);
              });
        } else if (state == "running") {
          actions = Wrap(spacing: 6, runSpacing: 6, children: [
            _timerBtn("Hold", Icons.pause_rounded, const Color(0xffF59E0B), () async {
              await tp.insertTaskLogHistory(context, id: id, level: "Hold");
              await _afterTimerAction(tp);
            }, filled: false),
            _timerBtn("Complete", Icons.check_rounded, const Color(0xff1FAF38),
                    () => _confirmComplete(tp, d)),
          ]);
        } else {
          actions = Wrap(spacing: 6, runSpacing: 6, children: [
            _timerBtn("Resume", Icons.play_arrow_rounded, colorsConst.primary, () async {
              await tp.startWork(context, d);
              await _afterTimerAction(tp);
            }),
            _timerBtn("Complete", Icons.check_rounded, const Color(0xff1FAF38),
                    () => _confirmComplete(tp, d),
                filled: false),
          ]);
        }

        final bool idle = state == "idle";

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Center(
            child: Container(
              width: width,
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: accent.withOpacity(0.30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 18, color: accent),
                      6.width,
                      const Text(
                        "Work Timer",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.shade300, thickness: 1.2),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: idle ? Colors.transparent : accent,
                          border: Border.all(color: accent, width: 1.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: idle ? 15 : 22,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xff14151F),
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            2.height,
                            Text(
                              sub,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: accent,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(child: actions),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _parseDocs() {
    docsList = (widget.data.documents.toString() == "null" ||
        widget.data.documents.toString().isEmpty)
        ? []
        : widget.data.documents.toString().split('||');

    voiceList.clear();
    imgList.clear();
    voiceC = 0;
    imgC = 0;

    for (var i = 0; i < docsList.length; i++) {
      if (_isAudioFile(docsList[i].toString())) {
        voiceList.add(docsList[i]);
        voiceC++;
      } else {
        imgList.add(docsList[i]);
        imgC++;
      }
    }

    log("TASK ${widget.data.id} DOCS => $docsList | voiceList: $voiceList | imgList: $imgList");
  }

  @override
  void dispose() {
    // Stop + release both audio players so they don't keep playing or
    // leaking after this screen is popped.
    _audioPlayer.dispose();
    _listAudioPlayer.dispose();
    super.dispose();
  }

  // ===========================================================================
  // VOICE TO TEXT
  // ===========================================================================
  Future<void> _convertToText(String url) async {
    if (_transcribing[url] == true) return;
    setState(() => _transcribing[url] = true);
    try {
      final text = await VoiceTranscribeService.transcribeUrl(url);
      if (!mounted) return;
      setState(() => _transcripts[url] = text);
    } catch (e) {
      debugPrint("convertToText error: $e");
      if (!mounted) return;
      utils.showWarningToast(context,
          text: e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _transcribing[url] = false);
    }
  }

  /// Convert button + transcript box (voice note / chat voice kezha show aagum)
  Widget _convertSection(String url) {
    final isConverting = _transcribing[url] == true;
    final transcript = _transcripts[url];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: isConverting ? null : () => _convertToText(url),
            icon: isConverting
                ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorsConst.primary,
              ),
            )
                : Icon(Icons.text_fields, size: 18, color: colorsConst.primary),
            label: CustomText(
              text: isConverting
                  ? "Converting..."
                  : (transcript == null ? "Convert to text" : "Convert again"),
              colors: colorsConst.primary,
              size: 13,
            ),
          ),
        ),
        if (transcript != null && transcript.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 2, bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  transcript,
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: transcript));
                      utils.showSuccessToast(
                          context: context, text: "Copied");
                    },
                    child: const Text("Copy"),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// ✅ History-la irukkura LATEST status (created_ts vachi, list position vachi illa)
  String? _latestHistoryStatus(TaskProvider p) {
    if (p.historyDetails.isEmpty) return null;
    dynamic latest;
    DateTime? latestTime;
    for (final h in p.historyDetails) {
      final t = DateTime.tryParse(h["created_ts"].toString());
      if (latest == null ||
          (t != null && (latestTime == null || t.isAfter(latestTime)))) {
        latest = h;
        latestTime = t;
      }
    }
    return latest?["value"]?.toString();
  }

  /// Voice note file-ah nu check pannum (case-insensitive, query string irundhaalum)
  bool _isAudioFile(String path) {
    final p = path.toLowerCase().split('?').first.trim();
    const exts = [
      '.m4a', '.mp3', '.wav', '.aac', '.ogg', '.opus',
      '.amr', '.3gp', '.caf', '.webm'
    ];
    return exts.any((e) => p.endsWith(e));
  }

  String formatDateTime(String? date) {
    if (date == null || date.isEmpty) return "";

    final parsedDate = DateTime.parse(date);

    return DateFormat('dd-MM-yy h:mm a').format(parsedDate);
  }

  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  Future<void> playNetworkAudio(String url) async {
    try {
      if (playingUrl == url && networkPlaying) {
        await _audioPlayer.pause();
        setState(() {
          networkPlaying = false;
        });
        return;
      }

      if (playingUrl != url) {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(url));

        setState(() {
          playingUrl = url;
          networkPlaying = true;
        });
      } else {
        await _audioPlayer.resume();
        setState(() {
          networkPlaying = true;
        });
      }
    } catch (e) {
      debugPrint("Audio play error => $e");
      if (!mounted) return;
      utils.showWarningToast(context, text: "Audio cannot be played");
    }
  }

  Future<void> playAudio(String url) async {
    try {
      // same audio playing -> pause
      if (playingUrl == url && isPlaying) {
        await _listAudioPlayer.pause();
        return;
      }

      // same audio paused -> resume
      if (playingUrl == url &&
          !isPlaying &&
          currentPosition > Duration.zero) {
        await _listAudioPlayer.resume();
        return;
      }

      log("Playing audio => $url");

      setState(() {
        playingUrl = url;
        loadingUrl = url;
        isLoadingAudio = true;
        currentPosition = Duration.zero;
        totalDuration = Duration.zero;
      });

      await _listAudioPlayer.stop();
      await _listAudioPlayer.play(UrlSource(url));

      // 8 sec-la play start aagala na, loader nikkum + error toast
      Future.delayed(const Duration(seconds: 8), () {
        if (!mounted) return;

        if (isLoadingAudio && loadingUrl == url) {
          setState(() {
            isLoadingAudio = false;
            loadingUrl = null;
          });
          if (!isPlaying) {
            utils.showWarningToast(context, text: "Audio cannot be played");
          }
        }
      });
    } catch (e) {
      debugPrint("Audio error => $e");
      if (!mounted) return;

      setState(() {
        isLoadingAudio = false;
        loadingUrl = null;
      });
      utils.showWarningToast(context, text: "Audio cannot be played");
    }
  }

  void changeLevel() {
    setState(() {
      if (level == "High") {
        level = "Normal";
      } else if (level == "Normal") {
        level = "Immediate";
      } else {
        level = "High";
      }
      Provider.of<TaskProvider>(context, listen: false).updateLevelDetail(
          context,
          id: widget.data.id.toString(),
          level: level);
    });
  }

  // ===========================================================================
  // TASK SUMMARY PDF (Download / Share / Print)
  // ===========================================================================
  void _openPdfMenu() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        Widget item(IconData icon, Color color, String title, String sub, String action) {
          return ListTile(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
            onTap: () {
              Navigator.pop(sheetCtx);
              _makePdf(action);
            },
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 6),
                  child: Text("Task Summary Report (PDF)",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                item(Icons.download_rounded, const Color(0xff0B5FB5), "Download PDF",
                    "Save and open the summary", "download"),
                item(Icons.share_rounded, const Color(0xff1FAF38), "Share PDF",
                    "WhatsApp, mail or save to Files", "share"),
                if (!kIsWeb)
                  item(Icons.print_rounded, const Color(0xff7C3AED), "Print / Preview",
                      "Preview before printing", "print"),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _makePdf(String action) async {
    if (_pdfBusy) return;
    final tp = Provider.of<TaskProvider>(context, listen: false);
    final cp = Provider.of<CustomerProvider>(context, listen: false);

    // ✅ munnadi: flag false-na udane "still loading" toast + block.
    // Ippo: icon-la spinner kaatti, data load mudiyura varaikkum wait pannum.
    setState(() => _pdfBusy = true);
    try {
      await _waitForData(tp, cp);
      if (!mounted) return;
      final task = tp.latestTask(widget.data);
      final id = task.id.toString();

      // status history (oldest -> newest)
      final hist = tp.historyDetails
          .map((h) => Map<String, dynamic>.from(h as Map))
          .toList()
        ..sort((a, b) => (a["created_ts"] ?? "")
            .toString()
            .compareTo((b["created_ts"] ?? "").toString()));
      final statusHistory = hist.map((h) {
        final d = DateTime.tryParse((h["created_ts"] ?? "").toString());
        return {
          "status": (h["value"] ?? "").toString(),
          "by": (h["firstname"] ?? "").toString(),
          "time": d != null
              ? DateFormat("dd-MM-yyyy hh:mm a").format(d)
              : (h["created_ts"] ?? "").toString(),
        };
      }).toList();

      // work history (same calc as the Work History card)
      final workHistory = _buildWorkRows(tp.workHistory)
          .map((r) => {
        "action": r["label"].toString(),
        "by": r["name"].toString(),
        "note": r["note"].toString(),
        "time": r["time"].toString(),
      })
          .toList();

      // ALL comments (card-la last 5 mattum, PDF-la ellame)
      final comments = cp.customerReport.map((m) {
        String doc = (m.documents ?? "").toString().trim();
        if (doc == "null") doc = "";
        final parts = doc.split('||').map((e) => e.trim()).where((e) => e.isNotEmpty);
        final hasVoice = parts.any(_isAudioFile);
        String text = (m.comments ?? "").toString().trim();
        if (text == "null") text = "";
        if (text.isEmpty) {
          text = hasVoice ? "[Voice note]" : (doc.isNotEmpty ? "[Attachment]" : "");
        } else if (hasVoice) {
          text = "$text  [Voice note]";
        }
        final d = DateTime.tryParse(m.createdTs.toString());
        return {
          "by": m.firstname.toString(),
          "text": text,
          "time": d != null
              ? DateFormat("dd-MM-yyyy hh:mm a").format(d)
              : m.createdTs.toString(),
        };
      }).toList();

      final bytes = await TaskSummaryPdf.build(TaskSummaryData(
        task: task,
        workState: tp.workState(task),
        workedSeconds: tp.currentSeconds(id),
        statusHistory: statusHistory,
        workHistory: workHistory,
        comments: comments,
        imagePaths: imgList.map((e) => e.toString()).toList(),
        voiceCount: voiceC,
      ));

      final name = TaskSummaryPdf.fileName(task);
      if (action == "share") {
        await TaskSummaryPdf.share(bytes, name);
      } else if (action == "print") {
        await TaskSummaryPdf.printPdf(bytes, name);
      } else {
        await TaskSummaryPdf.download(bytes, name);
        if (mounted) {
          utils.showSuccessToast(context: context, text: "Task summary downloaded");
        }
      }
    } catch (e, st) {
      debugPrint("TASK PDF ERROR => $e\n$st");
      if (mounted) {
        // ✅ real reason kaattum (munnadi "Unable to create PDF" mattum)
        var msg = e.toString().replaceFirst('Exception: ', '');
        if (msg.length > 120) msg = "${msg.substring(0, 120)}...";
        utils.showWarningToast(context, text: "Unable to create PDF: $msg");
      }
    } finally {
      if (mounted) setState(() => _pdfBusy = false);
    }
  }

  /// role int-ah save aagirundhaalum ("1" / 1) correct-ah check aagum
  bool get _isAdmin => localData.storage.read("role").toString() == "1";

  /// App bar-la chinna round icon button (PDF / Edit same size, same look)
  Widget _appBarAction({
    required String tooltip,
    required VoidCallback? onTap,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorsConst.primary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Page data load mudiyura varaikkum wait (max ~20 sec), apram irukkura
  /// data-oda PDF generate aagum. Shared provider flags (refresh) vera page
  /// API-aala false-ah stuck aanaalum ninnudaadhu.
  Future<void> _waitForData(TaskProvider tp, CustomerProvider cp) async {
    try {
      await _loadFuture.timeout(const Duration(seconds: 15));
    } catch (_) {
      // timeout / error -> irukkura data-vae podhum
    }
    // timer action apram work history / status history reload nadandhaa
    final until = DateTime.now().add(const Duration(seconds: 5));
    while (mounted &&
        (tp.workHistoryLoading || tp.refresh == false || cp.refresh == false) &&
        DateTime.now().isBefore(until)) {
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }

  /// Go back INSTANTLY (pop first, no waiting for network call).
  void _handleBack() {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
  }

  void _openTaskChat() {
    utils.navigatePage(
      context,
          () => DashBoard(
        child: TaskChat(
          isVisit: false,
          taskId: widget.data.id.toString(),
          assignedId: widget.data.assigned.toString(),
          name: widget.data.creator.toString(),
          assignedName: widget.data.assignedNames.toString(),
          date1: '',
          date2: '',
          type: '',
          index: widget.index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var webWidth = MediaQuery.of(context).size.width * 0.5;
    var phoneWidth = MediaQuery.of(context).size.width * 0.9;

    // ✅ Selector (dataVersion): provider data really maarina mattum rebuild.
    return Selector<TaskProvider, int>(
        selector: (_, p) => p.dataVersion,
        builder: (context, _, __) {
          final taskProvider = context.read<TaskProvider>();

          // ✅ FIX: history-la irukkura LATEST status (.last use panna koodadhu)
          String currentStatus = taskProvider.selectedStatusValue.toString();
          final latestStatus = _latestHistoryStatus(taskProvider);
          if (latestStatus != null) {
            currentStatus = latestStatus;
          }

          return Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: colorsConst.bacColor,
              elevation: 0.0,
              centerTitle: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: widget.data.creator.toString(),
                    size: 15,
                    isBold: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, left: 4),
                    child: CustomText(
                      text: "V ${localData.versionNumber}",
                      colors: Colors.grey,
                      size: 10,
                    ),
                  ),
                ],
              ),
              leading: IconButton(
                // INSTANT back
                onPressed: _handleBack,
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: colorsConst.primary,
                  size: 20,
                ),
              ),
              actions: [
                /// ✅ TASK SUMMARY PDF (ellaarukkum)
                _appBarAction(
                  tooltip: "Task summary PDF",
                  onTap: _pdfBusy ? null : _openPdfMenu,
                  child: _pdfBusy
                      ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: colorsConst.primary),
                  )
                      : Icon(Icons.picture_as_pdf_outlined,
                      color: colorsConst.primary, size: 20),
                ),

                /// ✅ EDIT (admin-ku eppovum, Completed task-um edit pannalaam)
                if (_isAdmin)
                  _appBarAction(
                    tooltip: "Edit task",
                    onTap: () {
                      HapticFeedback.lightImpact();
                      utils.navigatePage(
                          context,
                              () => DashBoard(
                              child: EditTask(
                                  data: taskProvider.latestTask(widget.data),
                                  isDirect: widget.isDirect,
                                  numberList: widget.numberList)));
                    },
                    child: SvgPicture.asset(
                      assets.tEdit,
                      width: 18,
                      height: 18,
                      placeholderBuilder: (_) => Icon(Icons.edit_outlined,
                          size: 18, color: colorsConst.primary),
                    ),
                  ),
                8.width,
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Container(
                        width: kIsWeb ? webWidth : phoneWidth,
                        decoration: customDecoration.baseBackgroundDecoration(
                            color: Colors.white, radius: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  /// TASK TITLE WITH VIEW MORE
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final String taskTitle =
                                        widget.data.taskTitle.toString();

                                        final textStyle = const TextStyle(
                                          fontSize: 16,
                                          fontFamily: "Lato",
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        );

                                        // Check whether the title overflows in one line.
                                        final textPainter = TextPainter(
                                          text: TextSpan(
                                            text: taskTitle,
                                            style: textStyle,
                                          ),
                                          maxLines: 1,
                                          textDirection: Directionality.of(context),
                                        )..layout(maxWidth: constraints.maxWidth);

                                        final bool hasOverflow = textPainter.didExceedMaxLines;

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              taskTitle,
                                              style: textStyle,
                                              maxLines: isTaskTitleExpanded ? null : 1,
                                              overflow: isTaskTitleExpanded
                                                  ? TextOverflow.visible
                                                  : TextOverflow.ellipsis,
                                            ),

                                            if (hasOverflow)
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    isTaskTitleExpanded = !isTaskTitleExpanded;
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    isTaskTitleExpanded
                                                        ? "Show Less"
                                                        : "Show More",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.blue,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),

                                  10.width,

                                  /// LEVEL TAG
                                  GestureDetector(
                                    onTap: localData.storage.read("role") == "1"
                                        ? changeLevel
                                        : null,
                                    child: Container(
                                      decoration:
                                      customDecoration.baseBackgroundDecoration(
                                        color: level == 'High'
                                            ? Colors.red.shade50
                                            : level == 'Immediate'
                                            ? Colors.purple.shade50
                                            : Colors.blue.shade50,
                                        radius: 10,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              color: level == 'High'
                                                  ? Colors.red
                                                  : level == 'Immediate'
                                                  ? Colors.purple
                                                  : Colors.blue,
                                              size: 10,
                                            ),
                                            5.width,
                                            CustomText(
                                              text: level,
                                              colors: level == 'High'
                                                  ? Colors.red
                                                  : level == 'Immediate'
                                                  ? Colors.purple
                                                  : Colors.blue,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Divider(
                                color: Colors.grey.shade200,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  /// ================= Assigned To =================
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        CustomText(
                                          text: "Assigned To: ",
                                          colors: colorsConst.greyClr,
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (widget.data.assignedNames
                                                  .toString()
                                                  .length >
                                                  15) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                        title:
                                                        const Text("Assigned To"),
                                                        content: Text(widget
                                                            .data.assignedNames
                                                            .toString()),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(context),
                                                            child: const Text("Close"),
                                                          )
                                                        ],
                                                      ),
                                                );
                                              }
                                            },
                                            child: RichText(
                                              overflow: TextOverflow.ellipsis,
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: widget.data.assignedNames
                                                        .toString()
                                                        .length >
                                                        12
                                                        ? "${widget.data.assignedNames.toString().substring(0, 12)}.."
                                                        : widget.data.assignedNames
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: "Lato",
                                                      color: colorsConst.blueClr,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// ================= Task Date =================
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: "Date: ",
                                          colors: colorsConst.greyClr,
                                          size: 12,
                                        ),
                                        CustomText(
                                            text: widget.data.taskDate.toString()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey.shade200,
                                thickness: 1.2,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                          width:
                                          kIsWeb ? webWidth / 4 : phoneWidth / 2,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              CustomText(
                                                text: "Created: ",
                                                colors: colorsConst.greyClr,
                                              ),
                                              CustomText(
                                                text:
                                                widget.data.creator.toString(),
                                                colors: Colors.black,
                                                isBold: true,
                                              ),
                                            ],
                                          )),
                                      CustomText(
                                        text: formatDateTime(
                                            widget.data.createdTs.toString()),
                                        size: 11,
                                      ),
                                    ],
                                  ),
                                  10.height,
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                          width:
                                          kIsWeb ? webWidth / 4 : phoneWidth / 4,
                                          child: Row(
                                            children: [
                                              CustomText(
                                                text: "Updated: ",
                                                colors: colorsConst.greyClr,
                                              ),
                                              CustomText(
                                                text: widget.data.updatedByName
                                                    .toString() ==
                                                    "null"
                                                    ? "-"
                                                    : widget.data.updatedByName
                                                    .toString(),
                                                colors: Colors.black,
                                                size: 13,
                                                isBold: true,
                                              ),
                                            ],
                                          )),
                                      CustomText(
                                        text: formatDateTime(
                                            widget.data.updatedTs.toString()),
                                        size: 11,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey.shade200,
                              ),
                              CustomText(
                                text: "Attachments",
                                colors: colorsConst.greyClr,
                              ),
                              5.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        type = "1";
                                      });
                                    },
                                    child: Container(
                                      width: kIsWeb
                                          ? webWidth / 2.5
                                          : phoneWidth / 2.7,
                                      decoration:
                                      customDecoration.baseBackgroundDecoration(
                                          color: type == "1"
                                              ? Colors.white
                                              : const Color(0xffE5E5E5),
                                          radius: 30,
                                          borderColor: type == "1"
                                              ? colorsConst.primary
                                              : const Color(0xffE5E5E5)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SvgPicture.asset(type == "1"
                                                ? assets.img2
                                                : assets.img1),
                                            CustomText(
                                              text: "Images",
                                              colors: type == "1"
                                                  ? colorsConst.primary
                                                  : Colors.black,
                                              size: 15,
                                            ),
                                            CircleAvatar(
                                              radius: 10,
                                              backgroundColor: colorsConst.primary,
                                              child: CustomText(
                                                text: imgC.toString(),
                                                colors: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        type = "2";
                                      });
                                    },
                                    child: Container(
                                      width:
                                      kIsWeb ? webWidth / 2 : phoneWidth / 2.3,
                                      decoration:
                                      customDecoration.baseBackgroundDecoration(
                                          color: type == "2"
                                              ? Colors.white
                                              : const Color(0xffE5E5E5),
                                          radius: 30,
                                          borderColor: type == "2"
                                              ? colorsConst.primary
                                              : const Color(0xffE5E5E5)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SvgPicture.asset(type == "2"
                                                ? assets.voice1
                                                : assets.voice2),
                                            CustomText(
                                              text: "Voice Notes",
                                              colors: type == "2"
                                                  ? colorsConst.primary
                                                  : Colors.black,
                                              size: 15,
                                            ),
                                            CircleAvatar(
                                              radius: 10,
                                              backgroundColor: colorsConst.primary,
                                              child: CustomText(
                                                text: voiceC.toString(),
                                                colors: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              10.height,
                              if (type == "1" && imgList.isNotEmpty)
                                GridView.builder(
                                    gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 50,
                                      mainAxisSpacing: 50,
                                      mainAxisExtent: 70,
                                    ),
                                    itemCount: imgList.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return SizedBox(
                                        width: kIsWeb ? webWidth : phoneWidth,
                                        child: ShowNetWrKImg(
                                          img: imgList[index],
                                        ),
                                      );
                                    }),

                              // ✅ VOICE NOTES + CONVERT TO TEXT
                              if (type == "2" && voiceList.isNotEmpty)
                                ListView.builder(
                                    itemCount: voiceList.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final String voiceUrl =
                                          '$imageFile?path=${voiceList[index]}';
                                      return SizedBox(
                                        width: kIsWeb ? webWidth : phoneWidth,
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            AudioTile(
                                                key: ValueKey(voiceList[index]),
                                                audioUrl: voiceUrl),
                                            _convertSection(voiceUrl),
                                          ],
                                        ),
                                      );
                                    }),
                              // Divider(
                              //   color: Colors.grey.shade200,
                              // ),
                            ],
                          ),
                        )),
                  ),
                  20.height,
                  /// ================= DESCRIPTION (separate section) =================
                  _descriptionCard(kIsWeb ? webWidth : phoneWidth),
                  20.height,

                  /// ================= WORK TIMER (View Task maadhiri) =================
                  _workTimerCard(taskProvider, kIsWeb ? webWidth : phoneWidth),
                  Center(
                    child: Container(
                      width: kIsWeb ? webWidth : phoneWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// ================= TITLE =================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Progress Tracker",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // ✅ FIX: latest status Completed illana mattum Save show aagum
                                if (currentStatus != "Completed")
                                  CustomLoadingButton(
                                    callback: () async {
                                      if (taskProvider.isUpdate == false) {
                                        utils.showWarningToast(context,
                                            text: "Please make changes");
                                        taskProvider.taskStatusCtr.reset();
                                      } else {
                                        // Save-ku munnadi state (save apram statval maaridum)
                                        final newStatus =
                                        (taskProvider.statusT ?? "").toString().trim();
                                        final prevState = taskProvider.workState(
                                            taskProvider.latestTask(widget.data));

                                        await taskProvider.editTask(
                                          context: context,
                                          data: widget.data,
                                          taskId: widget.data.id.toString(),
                                          isDirect: widget.isDirect,
                                          coId: widget.coId.toString(),
                                        );

                                        // "Started" -> timer start, "Completed" -> timer stop
                                        if (!mounted) return;
                                        await taskProvider.syncTimerWithStatus(
                                            context, widget.data, newStatus, prevState);
                                      }
                                    },
                                    isLoading: true,
                                    text: "Save",
                                    controller: taskProvider.taskStatusCtr,
                                    backgroundColor: colorsConst.primary,
                                    radius: 10,
                                    height: 28,
                                    width: kIsWeb ? webWidth / 3.5 : phoneWidth / 4,
                                  ),
                              ],
                            ),

                            10.height,

                            /// ================= BUTTONS =================
                            Center(
                              child: GroupButton(
                                controller: taskProvider.statusController,
                                buttons: const ["Assigned", "Started", "Completed"],
                                options: GroupButtonOptions(
                                  spacing: 5,
                                  buttonHeight: 30,
                                  buttonWidth: 80,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                buttonBuilder: (selected, value, context) {
                                  bool disabled =
                                  taskProvider.isButtonDisabled(value);

                                  return Container(
                                    width: 80,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: disabled
                                          ? Colors.grey.shade300
                                          : selected
                                          ? taskProvider.getStatusColor(value)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: disabled
                                            ? Colors.grey
                                            : taskProvider.getStatusColor(value),
                                        width: 1.2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: disabled
                                            ? Colors.grey.shade600
                                            : selected
                                            ? Colors.white
                                            : taskProvider.getStatusColor(value),
                                      ),
                                    ),
                                  );
                                },
                                onSelected: (name, index, isSelect) {
                                  if (taskProvider.isButtonDisabled(name)) return;

                                  final selectedStatus =
                                  taskProvider.statusList.firstWhere(
                                        (e) => e['value'] == name,
                                    orElse: () => {"id": "0", "value": "Unknown"},
                                  );

                                  // Debug: "Unknown" vandha statusList value match aagala
                                  debugPrint(
                                      "Selected: $name -> ${selectedStatus['value']} (id: ${selectedStatus['id']})");

                                  taskProvider
                                      .changeStatusT(selectedStatus['value']);
                                  taskProvider.changeStatus(selectedStatus);
                                  taskProvider.updateChanges();

                                  setState(() {});
                                },
                              ),
                            ),

                            Divider(
                              color: Colors.grey.shade300,
                              thickness: 1.2,
                            ),

                            /// ================= HISTORY LIST =================
                            taskProvider.refresh == false
                                ? const Loading()
                                : taskProvider.historyDetails.isEmpty
                                ? Center(
                              child: CustomText(
                                text: "No History Found",
                                size: 14,
                                colors: Colors.grey,
                              ),
                            )
                                : ListView.builder(
                              shrinkWrap: true,
                              physics:
                              const NeverScrollableScrollPhysics(),
                              itemCount:
                              taskProvider.historyDetails.length,
                              itemBuilder: (context, index) {
                                final data =
                                taskProvider.historyDetails[index];

                                return Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        /// LEFT STATUS
                                        SizedBox(
                                          width: kIsWeb
                                              ? webWidth / 4.5
                                              : phoneWidth / 4.5,
                                          child: Text(
                                            data["value"].toString(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: colorsConst.primary,
                                            ),
                                          ),
                                        ),

                                        /// DOT
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue,
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 2),
                                          ),
                                        ),

                                        const SizedBox(width: 5),

                                        /// NAME
                                        Expanded(
                                          child: Text(
                                            data["firstname"].toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),

                                        /// DATE
                                        Text(
                                          DateFormat("dd-MM-yyyy, hh:mm a")
                                              .format(DateTime.parse(
                                              data["created_ts"])),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  20.height,
                  Center(
                    child: Container(
                      width: kIsWeb ? webWidth : phoneWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Recent Comments",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    _openTaskChat();
                                  },
                                  child: const Icon(
                                    Icons.message_outlined,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            20.height,
                            Consumer<CustomerProvider>(
                              builder: (context, chatProvider, _) {
                                if (chatProvider.refresh == false) {
                                  return const Loading();
                                }

                                if (chatProvider.customerReport.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text(
                                        "No Recent Chat Found",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  );
                                }

                                /// total messages
                                int totalCount = chatProvider.customerReport.length;

                                /// show only last 5
                                int startIndex =
                                totalCount > 5 ? totalCount - 5 : 0;

                                List<CustomerReportModel> lastFive = chatProvider
                                    .customerReport
                                    .sublist(startIndex, totalCount)
                                    .reversed
                                    .toList();

                                return Column(
                                  children: [
                                    /// CHAT LIST
                                    ListView.builder(
                                      itemCount: lastFive.length,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final msg = lastFive[index];
                                        String doc =
                                        (msg.documents ?? "").toString().trim();
                                        if (doc == "null") doc = "";

                                        // multiple docs irundhaalum first voice file-ah edukkum
                                        final docParts = doc
                                            .split('||')
                                            .map((e) => e.trim())
                                            .where((e) => e.isNotEmpty)
                                            .toList();
                                        final String audioDoc = docParts
                                            .firstWhere(_isAudioFile,
                                            orElse: () => "");

                                        bool isAudio = audioDoc.isNotEmpty;

                                        String audioUrl =
                                            "$imageFile?path=$audioDoc";
                                        log("CHAT => doc: '$doc' | audioDoc: '$audioDoc' | isAudio: $isAudio | url: $audioUrl");
                                        double sliderValue = 0;

                                        if (playingUrl == audioUrl &&
                                            totalDuration.inSeconds > 0) {
                                          sliderValue =
                                              currentPosition.inSeconds.toDouble();
                                          if (sliderValue >
                                              totalDuration.inSeconds.toDouble()) {
                                            sliderValue =
                                                totalDuration.inSeconds.toDouble();
                                          }
                                        }
                                        DateTime? createdDate;

                                        try {
                                          createdDate = DateTime.parse(
                                              msg.createdTs.toString());
                                        } catch (e) {
                                          createdDate = null;
                                        }

                                        return InkWell(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            _openTaskChat();
                                          },
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        isAudio
                                                            ? Container(
                                                          height: 50,
                                                          width:
                                                          double.infinity,
                                                          padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal:
                                                              8),
                                                          decoration:
                                                          BoxDecoration(
                                                            color: Colors
                                                                .grey.shade100,
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                12),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              (isLoadingAudio &&
                                                                  loadingUrl ==
                                                                      audioUrl)
                                                                  ? const SizedBox(
                                                                height:
                                                                20,
                                                                width:
                                                                20,
                                                                child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                  2,
                                                                  color:
                                                                  Colors.green,
                                                                ),
                                                              )
                                                                  : IconButton(
                                                                icon:
                                                                Icon(
                                                                  (playingUrl == audioUrl &&
                                                                      isPlaying)
                                                                      ? Icons.pause
                                                                      : Icons.play_arrow,
                                                                  color:
                                                                  Colors.green,
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  log("PLAY TAPPED: $audioUrl");
                                                                  await playAudio(
                                                                      audioUrl);
                                                                },
                                                              ),
                                                              Expanded(
                                                                child: Slider(
                                                                  activeColor:
                                                                  Colors
                                                                      .green,
                                                                  inactiveColor:
                                                                  Colors
                                                                      .grey
                                                                      .shade600,
                                                                  thumbColor:
                                                                  Colors
                                                                      .green,
                                                                  value:
                                                                  sliderValue,
                                                                  min: 0,
                                                                  max: (playingUrl ==
                                                                      audioUrl &&
                                                                      totalDuration.inSeconds >
                                                                          0)
                                                                      ? totalDuration
                                                                      .inSeconds
                                                                      .toDouble()
                                                                      : 10,
                                                                  onChanged:
                                                                      (value) async {
                                                                    if (playingUrl ==
                                                                        audioUrl) {
                                                                      await _listAudioPlayer.seek(Duration(
                                                                          seconds:
                                                                          value.toInt()));
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                              Text(
                                                                (playingUrl ==
                                                                    audioUrl &&
                                                                    totalDuration.inSeconds >
                                                                        0)
                                                                    ? formatTime(
                                                                    totalDuration)
                                                                    : "00:00",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                    11),
                                                              ),
                                                              const SizedBox(
                                                                  width: 5),
                                                            ],
                                                          ),
                                                        )
                                                            : Text(
                                                          (msg.comments.toString() == "null" ||
                                                              msg.comments
                                                                  .toString()
                                                                  .trim()
                                                                  .isEmpty)
                                                              ? (doc.isNotEmpty
                                                              ? "📎 Attachment"
                                                              : "")
                                                              : msg.comments
                                                              .toString(),
                                                          maxLines: 1,
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                          style:
                                                          const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            color:
                                                            Colors.black,
                                                          ),
                                                        ),

                                                        // ✅ CONVERT TO TEXT (chat voice)
                                                        if (isAudio)
                                                          _convertSection(
                                                              audioUrl),

                                                        const SizedBox(height: 3),
                                                        Text(
                                                          msg.firstname.toString(),
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .grey.shade500,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  5.width,
                                                  Text(
                                                    createdDate != null
                                                        ? DateFormat(
                                                        "dd-MM-yy / hh:mm a")
                                                        .format(createdDate)
                                                        : "-",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(color: Colors.grey.shade300),
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                                    /// VIEW MORE
                                    if (totalCount > 5)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: InkWell(
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            _openTaskChat();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 5,
                                              right: 5,
                                            ),
                                            child: Text(
                                              "View More",
                                              style: TextStyle(
                                                color: colorsConst.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  20.height,
                  _workHistoryCard(taskProvider, kIsWeb ? webWidth : phoneWidth),
                  20.height,
                  ///Comment for JPS
                  Center(
                    child: SizedBox(
                      width: kIsWeb ? webWidth : phoneWidth,
                      child: WagesWorkReportSection(
                        taskId: widget.data.id.toString(),
                      ),
                    ),
                  ),
                  140.height,
                ],
              ),
            ),
          );
        });
  }
}