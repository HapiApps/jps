// import 'dart:async';
//
// class TaskTimer {
//   DateTime? startTime;      // when it was last started/resumed
//   int accumulatedSeconds;   // total time before current run
//   bool isRunning;
//
//   TaskTimer({this.startTime, this.accumulatedSeconds = 0, this.isRunning = false});
// }
//
// // In your State class:
// late List<TaskTimer> taskTimers;
// Timer? _uiTicker; // just refreshes UI every second, no per-task timer needed
//
// @override
// void initState() {
//   super.initState();
//   taskTimers = List.generate(statusList.length, (_) => TaskTimer());
// }
//
// @override
// void dispose() {
//   _uiTicker?.cancel();
//   super.dispose();
// }