import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_button/group_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:video_player/video_player.dart';
import '../component/custom_text.dart';
import '../local_database/sqlite.dart';
import '../model/audio_model.dart';
import '../model/customer/customer_attendance_model.dart';
import '../model/leave/holidays_model.dart';
import '../model/task/task_data_model.dart';
import '../model/task/task_details_model.dart';
import '../model/task/task_list_model.dart';
import '../model/user_model.dart';
import '../repo/task_repo.dart';
import '../model/task/task_chart_model.dart';
import '../screens/common/camera.dart';
import '../screens/common/dashboard.dart';
import '../screens/customer/view_task.dart';
import '../screens/task/task_details.dart';
import '../screens/task/view_task.dart';
import '../source/constant/api.dart';
import '../source/constant/colors_constant.dart';
import '../source/constant/default_constant.dart';
import '../source/constant/local_data.dart';
import 'employee_provider.dart';
import 'home_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

// class TaskProvider with ChangeNotifier {
//   late VideoPlayerController videoPlayerController;
//   final TaskRepo _taskRepo = TaskRepo();
//
//   RoundedLoadingButtonController taskCtr = RoundedLoadingButtonController();
//   RoundedLoadingButtonController taskStatusCtr = RoundedLoadingButtonController();
//
//   GroupButtonController statusController = GroupButtonController();
//
//   late CalendarDataSource dataSource;
//   String _year="";
//   String get year=> _year;
//   int total=0;
//
//   dynamic _defaultMonth=DateTime.now().month;
//   dynamic get defaultMonth =>_defaultMonth;
//   String _thisMonthLeave = "0";
//   String get thisMonthLeave=>_thisMonthLeave;
//
//   int _filterTasks = 0;
//   int get filterTasks=>_filterTasks;
//   List<HolyDaysModel> _fixedLeaves= <HolyDaysModel>[];
//   List<HolyDaysModel> get fixedLeaves=> _fixedLeaves;
//   void checkMonth(ViewChangedDetails details){
//     _filterDate="";
//     _filterTasks=0;
//     _defaultMonth =details.visibleDates[15].month;
//     var count = 0;
//     for (var i = 0; i <_allTasks.length; i++) {
//       String dateStr = _allTasks[i].taskDate.toString(); // "24-05-2025"
//       DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(dateStr);
//       var st = parsedDate;
//       if (utils.returnPadLeft(_defaultMonth.toString()) ==
//           utils.returnPadLeft(st.month.toString())) {
//         count++;
//       }
//     }
//     _thisMonthLeave = count.toString();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       notifyListeners();
//     });
//   }
//   void changeMonth(dynamic value){
//     _defaultMonth = value;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       notifyListeners();
//     });
//   }
//   void checkMonth2(){
//     var count = 0;
//     for (var i = 0; i <_allTasks.length; i++) {
//       if (_filterDate==_allTasks[i].taskDate.toString()) {
//         count++;
//       }
//     }
//     _filterTasks = count;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       notifyListeners();
//     });
//   }
//
//   String _filterDate = "";
//   String get filterDate=>_filterDate;
//   void filterDateList(String value,DateTime dateTime){
//     _filterDate=value;
//     _selectedDate = dateTime;
//     print(_filterDate);
//     print(_selectedDate);
//     notifyListeners();
//   }
//
//   var _statusT;
//   String _filter="1";
//   String statusId="";
//   int matched=0;
//   get statusT => _statusT;
//   String get filter => _filter;
//   void changeFilterStatus(dynamic value) {
//     _status=value;
//     statusId="";
//     matched=0;
//     print(value);
//     var list = [];
//     list.add(value);
//     statusId = list[0]["value"];
//     for(var i=0;i<_allTasks.length;i++){
//       if(statusId==_allTasks[i].statval){
//         matched++;
//       }
//     }
//     notifyListeners();
//   } void changeFilter(String value) {
//     _filter = value;
//     notifyListeners();
//   } void changeStatusT(String value) {
//     _statusT = value;
//     notifyListeners();
//   }
//   void setStatus(String value) {
//     for(var i=0;i<statusList.length;i++){
//       if(statusList[i]["value"]==value){
//         statusController = GroupButtonController(selectedIndex: i);
//       }
//     }
//     notifyListeners();
//   }
//
//   TextEditingController search     = TextEditingController();
//   TextEditingController search2     = TextEditingController();
//   TextEditingController taskTitleCont     = TextEditingController();
//   TextEditingController projectNameCont   = TextEditingController();
//   TextEditingController departmentCont    = TextEditingController();
//   TextEditingController projectSearchCont = TextEditingController();
//   TextEditingController taskDt = TextEditingController();
//   List<TextEditingController> fileNameCont  = <TextEditingController>[];
//   void searchTask(String value){
//     final suggestions=_searchAllTasks.where(
//             (user){
//           final userFName=user.projectName.toString().toLowerCase();
//           final userNumber = user.assignedNames.toString().toLowerCase();
//           final input=value.toString().toLowerCase();
//           return userFName.contains(input) || userNumber.contains(input);
//         }).toList();
//     _allTasks=suggestions;
//     notifyListeners();
//   }
//   String _signPrefix = "Mr";
//   String _assignedId = "";
//   String _assName = "";
//   String get assName => _assName;
//   String _assignedNames = "";
//   String get assignedNames => _assignedNames;
//
//   String _cusId = "";
//   String _cusName = "";
//   String get cusId => _cusId;
//   String get cusName => _cusName;
//   var _title;
//   var _department;
//   var _type;
//   var _status;
//   bool _isUpdate=false;
//   String _level = "Normal";
//   String _taskSDate = "";
//   String _taskEDate = "";
//   String _taskSTime = "";
//   String _taskETime = "";
//   String _changeTaskStatus = "";
//   int _count = 0;
//
//   bool get isUpdate => _isUpdate;
//   void updateChanges(){
//   _isUpdate=true;
//   notifyListeners();
// }
//   String get signPrefix => _signPrefix;
//   String get assignedId => _assignedId;
//   get title => _title;
//   get department => _department;
//   get type => _type;
//   get status => _status;
//   String get level => _level;
//   String get taskSDate => _taskSDate;
//   String get taskEDate => _taskEDate;
//   String get taskSTime => _taskSTime;
//   String get taskETime => _taskETime;
//   String get changeTaskStatus => _changeTaskStatus;
//   int get count => _count;
//
//   var prefix = ["Mr", "Mrs", "Dr", "Ms"];
//   List<String> titleList = [
//     "Bug Report",
//     "UI Update",
//     "API Integration",
//     "Issue Fix"
//   ];
//   var departmentList = ["UI/UX Design", "Development", "Testing","HR"];
//   // var statusList = ["Assigned", "In-Queue", "Started", "On Hold", "New Issues"];
//   var fullStatusList = [
//     "Assigned",
//     "In-Queue",
//     "Started",
//     "On Hold",
//     "New Issues",
//     "Cancelled",
//     "Completed"
//   ];
//
//   void changeSignPrefix(String value) {
//     _signPrefix = value;
//     notifyListeners();
//   }
//
//   void changedTaskStatus(String value) {
//     _changeTaskStatus = value;
//     notifyListeners();
//   }
//
//   // void changeAssignedIs(context, List<dynamic> names) {
//   //   List<String> ids = [];
//   //   var list = Provider.of<EmployeeProvider>(context, listen: false).filterUserData;
//   //
//   //   for (var name in names) {
//   //     var found = list.firstWhere(
//   //           (element) => element.firstname.toString().trim().toLowerCase() == name.toString().trim().toLowerCase(),
//   //       orElse: () => UserModel(id: "0", firstname: ''), // use valid default
//   //     );
//   //
//   //     if (found.id != 0) {
//   //       ids.add(found.id.toString());
//   //     }
//   //   }
//   //
//   //   _assignedId = ids.join(",");
//   //   print("assign $_assignedId");
//   //   notifyListeners();
//   // }
//   void changeAssignedIs(context, List<dynamic> names) {
//     List<String> ids = [];
//     List<String> selectedNames = [];
//
//     var list = Provider.of<EmployeeProvider>(context, listen: false).filterUserData;
//
//     for (var name in names) {
//       var found = list.firstWhere(
//             (element) => element.firstname.toString().trim().toLowerCase() == name.toString().trim().toLowerCase(),
//         orElse: () => UserModel(id: "0", firstname: ''),
//       );
//
//       if (found.id != "0") {
//         ids.add(found.id.toString());
//         selectedNames.add(found.firstname.toString()); // save the matched name
//       }
//     }
//
//     _assignedId = ids.join(",");
//     _assignedNames = selectedNames.join(", "); // <- add this line to save names
//
//     print("Assigned IDs: $_assignedId");
//     print("Assigned Names: $_assignedNames");
//
//     notifyListeners();
//   }
//
//   void changeTitle(String value) {
//     _title = value;
//     notifyListeners();
//   }
//
//   void changeDepartment(String value) {
//     _department = value;
//     notifyListeners();
//   }
//
//   void changeType(dynamic value) {
//     _type = value;
//     // print(value);
//     // var list = [];
//     // list.add(value);
//     localData.storage.write("type_id", value);
//     notifyListeners();
//   }
//
//   void changeStatus(dynamic value) {
//     _status = value;
//     var list = [];
//     list.add(value);
//     localData.storage.write("status_id", list[0]["id"]);
//     notifyListeners();
//   }
//   void setStatusByName(String value) {
//     // // Find the map where name matches
//     // final selectedStatus = statusList.firstWhere(
//     //       (status) => status["value"] == value,
//     //   orElse: () => {"id": "0", "value": "Unknown"},
//     // );
//     //
//     // _status = selectedStatus;
//     //
//     // localData.storage.write("status_id", selectedStatus["id"]);
//     _isUpdate=false;
//     notifyListeners();
//   }
//   void changeLevel(String value) {
//     _level = value;
//     notifyListeners();
//   }
//
//   void changeCount(int value) {
//     _count = value;
//     notifyListeners();
//   }
//
//   List<Map<String, dynamic>> _selectedFiles = [];
//
//   List<Map<String, dynamic>> get selectedFiles => _selectedFiles;
//   final ImagePicker picker = ImagePicker();
//
//   /// Pick Image or File from Gallery
//   Future<void> pickFile() async {
//     final List<XFile> files = await picker.pickMultiImage();
//
//     if (files.isNotEmpty) {
//       for (XFile file in files) {
//         final int fileSizeBytes = File(file.path).lengthSync();
//         final String formattedSize = formatFileSize(fileSizeBytes);
//
//         _selectedFiles.add({
//           'name': file.name,
//           'size': formattedSize,
//           'path': file.path,
//         });
//         fileNameCont.add(TextEditingController());
//       }
//
//       notifyListeners();
//     }
//   }
//
//   /// Format file size dynamically (KB or MB)
//   String formatFileSize(int bytes) {
//     double kb = bytes / 1024;
//     if (kb < 1024) {
//       return "${kb.toStringAsFixed(2)} KB";
//     } else {
//       double mb = kb / 1024;
//       return "${mb.toStringAsFixed(2)} MB";
//     }
//   }
//
//   /// Remove File from List
//   void removeFile(int index) {
//     _selectedFiles.removeAt(index);
//     fileNameCont.removeAt(index);
//     notifyListeners();
//   }
//
//   void removeVideo(int index) {
//     _videos.removeAt(index);
//     notifyListeners();
//   }
//
//   List<String> _assignList = [];
//   List<String> get assignList => _assignList;
//
//   List<Map<String, dynamic>> _assignItems = [
//     {'name': 'Selvi', 'selected': false},
//     {'name': 'Priya Mehra', 'selected': false},
//     {'name': 'Aditya Singh', 'selected': false},
//     {'name': 'Meera Nair', 'selected': false},
//   ];
//
//   List<Map<String, dynamic>> get assignItems => _assignItems;
//
//   String get selectedItemsText {
//     final selectedNames = _assignItems
//         .where((item) => item['selected'])
//         .map((item) => item['name'])
//         .toList();
//     return selectedNames.isEmpty
//         ? 'Select Assignees'
//         : selectedNames.join(', ');
//   }
//
//   void toggleSelectAll(bool? isSelected) {
//     for (var item in _assignItems) {
//       item['selected'] = isSelected ?? false;
//     }
//     notifyListeners();
//   }
//
//   void toggleItem(int index, bool? isSelected) {
//     _assignItems[index]['selected'] = isSelected ?? false;
//     notifyListeners();
//   }
//
//   final AudioRecorder _record = AudioRecorder();
//   final AudioPlayer audioPlayer = AudioPlayer();
//
//   String? _audioPath;
//   String? _currentlyPlayingPath;
//   bool _isRecording = false;
//   bool _isPlaying = true;
//   bool _isVedioPlaying = false;
//   bool _isLoading = false;
//   bool _isProjectLoading = false;
//   bool _isDepartmentLoading = false;
//   bool _isTaskLoading = false;
//   bool _isError = false;
//   DateTime _selectedDate = DateTime.now();
//
//   DateTime get selectedDate => _selectedDate;
//
//   void datePick({required BuildContext context, required TextEditingController date}) {
//     DateTime dateTime = DateTime.now();
//
//     showDatePicker(
//       context: context,
//       initialDate: dateTime,
//       firstDate: DateTime(1920),
//       lastDate: DateTime(3000),
//     ).then((value) {
//       if (value != null) {
//         String formattedDate = "${value.day.toString().padLeft(2, "0")}-"
//             "${value.month.toString().padLeft(2, "0")}-"
//             "${value.year.toString()}";
//         date.text = formattedDate;
//         notifyListeners();
//       }
//     });
//   }
//
//   Future<void> customTimePicker({
//     required BuildContext context,
//     required bool isStartTime,
//   }) async {
//     TimeOfDay? time = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//         builder: (BuildContext context, Widget? child) {
//           return MediaQuery(
//             data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
//             child: child!,
//           );
//         });
//     if (time != null) {
//       var selectedTime = _formatTime12Hour(time, context);
//       if (isStartTime) {
//         _taskSTime = selectedTime.toString();
//       } else {
//         _taskETime = selectedTime.toString();
//       }
//       notifyListeners();
//     }
//   }
//
//   String _formatTime12Hour(TimeOfDay time, BuildContext context) {
//     int hour = time.hourOfPeriod;
//     String period = time.period == DayPeriod.am ? 'AM' : 'PM';
//
//     String hourStr = hour.toString().padLeft(2, '0');
//     String minuteStr = time.minute.toString().padLeft(2, '0');
//
//     return '$hourStr:$minuteStr $period';
//   }
//
//   String? get currentlyPlayingPath => _currentlyPlayingPath;
//   String? get audioPath => _audioPath;
//   bool get isRecording => _isRecording;
//   bool get isPlaying => _isPlaying;
//   bool get isVideoPlaying => _isVedioPlaying;
//   bool get isLoading => _isLoading;
//   bool get isProjectLoading => _isProjectLoading;
//   bool get isDepartmentLoading => _isDepartmentLoading;
//   bool get isTaskLoading => _isTaskLoading;
//   bool get isError => _isError;
//   double _recordingDuration = 0.0;
//   double get recordingDuration => _recordingDuration;
//
//   Duration _position = Duration.zero;
//   Duration? _duration;
//
//   Duration get position => _position;
//   Duration? get duration => _duration;
//
//   Timer? timer;
//   late DateTime _startTime;
//
//   final List<String> _videos = [];
//
//   List<String> get videos => _videos;
//
//   List<Response> _taskList = [];
//   List<Response> _filteredTasks = [];
//   List<String> _projectDropList = [];
//   List<DepResponse> _departmentList = [];
//   //List<Response> get taskList => _taskList;
//   List<Response> get taskList => _filteredTasks;
//   List<String>  get projectDropList => _projectDropList;
//   List<DepResponse> get serverDepartmentList => _departmentList;
//   List<TaskResponse> _taskDetailsList = [];
//   List<TaskResponse> get taskDetailsList => _taskDetailsList;
//   List<dynamic> _userNameList = [];
//   List<dynamic> get userNameList => _userNameList;
//
//
//
//   Future<void> pickedVideo() async {
//     final XFile? recordedFile =
//         await picker.pickVideo(source: ImageSource.gallery);
//     if (recordedFile != null) {
//       // print("Path ${recordedFile.path}");
//       //String url = await _taskRepo.insertVideoApi(video: recordedFile.path);
//       _videos.add(recordedFile.path);
//     }
//     notifyListeners();
//   }
//
//   Future<VideoPlayerController> initializeVideoController(String path) async {
//     try {
//       final controller = VideoPlayerController.file(File(path));
//       await controller.initialize();
//       await controller.pause(); // Keep the video in a paused state
//       return controller;
//     } catch (e) {
//       throw "Video error";
//     }
//   }
//
//   List<AddAudioModel> _recordedAudioPaths = [];
//   List<AddAudioModel> get recordedAudioPaths => _recordedAudioPaths;
//
//   /// Start Recording
//   // Future<void> startRecording() async {
//   //   HapticFeedback.heavyImpact();
//   //
//   //   try {
//   //     if (await _record.hasPermission()) {
//   //       // print("Audio Start");
//   //       final dir = await getApplicationDocumentsDirectory();
//   //       String path =
//   //           "${dir.path}/recorded_audio_${DateTime.now().millisecondsSinceEpoch}.m4a";
//   //       await _record.start(const RecordConfig(), path: path);
//   //
//   //       _isRecording = true;
//   //       _startTime = DateTime.now();
//   //       _recordingDuration = 0.0;
//   //
//   //       timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//   //         final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
//   //         _recordingDuration = elapsed / 1000; // Convert to seconds
//   //         notifyListeners();
//   //       });
//   //     }
//   //   } catch (e) {
//   //     log("Error in startRecording: $e");
//   //   }
//   //   notifyListeners();
//   // }
//   Future<void> startRecording() async {
//     if (_isRecording) return; // Prevent duplicate starts
//
//     HapticFeedback.heavyImpact();
//
//     try {
//       if (await _record.hasPermission()) {
//         final dir = await getApplicationDocumentsDirectory();
//         String path =
//             "${dir.path}/recorded_audio_${DateTime.now().millisecondsSinceEpoch}.m4a";
//
//         await _record.start(const RecordConfig(), path: path);
//
//         _isRecording = true;
//         _startTime = DateTime.now();
//         _recordingDuration = 0.0;
//
//         timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//           final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
//           _recordingDuration = elapsed / 1000;
//           notifyListeners();
//         });
//
//         notifyListeners();
//       }
//     } catch (e) {
//       log("Error in startRecording: $e");
//     }
//   }
//
//   /// Stop Recording
//   // Future<void> stopRecording() async {
//   //   try {
//   //     final path = await _record.stop();
//   //     if (path != null) {
//   //       _isRecording = false;
//   //       _recordedAudioPaths
//   //           .add(AddAudioModel(audioPath: path, second: _recordingDuration));
//   //       await Future.delayed(Duration(seconds: 1));
//   //       loadAudioDuration(path);
//   //     }
//   //     timer?.cancel();
//   //     // print("_recordedAudioPaths: ${_recordedAudioPaths.last.second}");
//   //   } catch (e) {
//   //     // print("Error in stopRecording: $e");
//   //   }
//   //   notifyListeners();
//   // }
//   Future<void> stopRecording() async {
//     if (!_isRecording) return; // Prevent stop if not recording
//
//     try {
//       final path = await _record.stop();
//
//       if (path != null) {
//         _isRecording = false;
//         timer?.cancel();
//
//         _recordedAudioPaths.add(
//           AddAudioModel(audioPath: path, second: _recordingDuration),
//         );
//
//         await Future.delayed(Duration(seconds: 1)); // Optional delay
//         loadAudioDuration(path);
//       }
//     } catch (e) {
//       log("Error in stopRecording: $e");
//     }
//
//     notifyListeners();
//   }
//
//   void removeAudio(int index) {
//     _recordedAudioPaths.removeAt(index);
//     notifyListeners();
//   }
//
//   // Future<void> playAudio(String audioPath, int index) async {
//   //   if (audioPath.isNotEmpty) {
//   //     _isPlaying = true;
//   //     _recordedAudioPaths[index].play = true;
//   //     notifyListeners();
//   //
//   //     audioPlayer.onDurationChanged.listen((durationV) {
//   //       _duration = durationV;
//   //       notifyListeners();
//   //     });
//   //
//   //     audioPlayer.onPositionChanged.listen((positionV) {
//   //       _position = positionV;
//   //       notifyListeners();
//   //     });
//   //
//   //     audioPlayer.onPlayerComplete.listen((event) {
//   //       _isPlaying = false;
//   //       _position = Duration.zero;
//   //       _recordedAudioPaths[index].play = false;
//   //       notifyListeners();
//   //     });
//   //
//   //     try {
//   //       await audioPlayer.play(DeviceFileSource(audioPath));
//   //     } catch (e) {
//   //       _isPlaying = false;
//   //       _recordedAudioPaths[index].play = false;
//   //       // print("Audio play error: $e");
//   //       notifyListeners();
//   //     }
//   //   }
//   // }
//   Future<void> playAudio(String audioPath, int index) async {
//     if (audioPath.isNotEmpty) {
//       // Reset all to false
//       for (var i = 0; i < _recordedAudioPaths.length; i++) {
//         _recordedAudioPaths[i].play = false;
//       }
//
//       _isPlaying = true;
//       _recordedAudioPaths[index].play = true;
//       notifyListeners();
//
//       // Remove old subscriptions
//       audioPlayer.onDurationChanged.listen(null);
//       audioPlayer.onPositionChanged.listen(null);
//       audioPlayer.onPlayerComplete.listen(null);
//
//       audioPlayer.onDurationChanged.listen((durationV) {
//         _recordedAudioPaths[index].duration = durationV;
//         notifyListeners();
//       });
//
//       audioPlayer.onPositionChanged.listen((positionV) {
//         _recordedAudioPaths[index].position = positionV;
//         notifyListeners();
//       });
//
//       audioPlayer.onPlayerComplete.listen((event) {
//         _isPlaying = false;
//         _recordedAudioPaths[index].position = Duration.zero;
//         _recordedAudioPaths[index].play = false;
//         notifyListeners();
//       });
//
//       try {
//         await audioPlayer.play(DeviceFileSource(audioPath));
//       } catch (e) {
//         _isPlaying = false;
//         _recordedAudioPaths[index].play = false;
//         notifyListeners();
//       }
//     }
//   }
//
//   Future<void> stopAudio() async {
//     await audioPlayer.pause();
//     _isPlaying = false;
//     notifyListeners();
//   }
//
//   Future<void> loadAudioDuration(String url) async {
//     try {
//       await audioPlayer.setSourceUrl(url);
//       Duration? fetchedDuration = await audioPlayer.getDuration();
//       if (fetchedDuration != null) {
//         _duration = fetchedDuration;
//         // print("Duration $duration");
//       }
//     } catch (e) {
//       // print("Error fetching duration: $e");
//     }
//     notifyListeners();
//   }
//
//
//   String calculateDueDays(String dateRange,
//       {String? timeRange, String? updatedDate, String? status}) {
//     try {
//       List<String> dates = dateRange.split("||");
//       DateTime endDate = DateFormat("dd-MM-yyyy").parse(dates[1].trim());
//
//       DateTime now = DateTime.now();
//       DateTime today = DateTime(now.year, now.month, now.day);
//       DateTime taskEndDate = DateTime(endDate.year, endDate.month, endDate.day);
//
//       if (status == "Completed") {
//         String updateDateStr = updatedDate.toString();
//         DateTime updateDate = DateTime.parse(updateDateStr);
//         int diffDays = updateDate.difference(taskEndDate).inDays;
//         if (diffDays > 0) {
//           return "Completed - Extra $diffDays days";
//         } else {
//           return "Completed";
//         }
//       }
//
//       // Check if today is same as end date
//       if (taskEndDate == today && timeRange != null && timeRange.contains("||")) {
//         List<String> times = timeRange.split("||");
//
//         String endTimeStr = times[1].trim();
//         // print("end $endTimeStr");
//         if (endTimeStr.isEmpty) {
//           endTimeStr = "11:59 PM"; // Default fallback time
//         }
//
//         DateTime parsedEndTime = DateFormat("hh:mm a").parse(endTimeStr);
//
//         DateTime endTime = DateTime(
//           today.year,
//           today.month,
//           today.day,
//           parsedEndTime.hour,
//           parsedEndTime.minute,
//         );
//
//         if (now.isAfter(endTime)) {
//           return "Overdue";
//         } else {
//           int remainingMinutes = endTime.difference(now).inMinutes;
//           int hours = remainingMinutes ~/ 60;
//           int minutes = remainingMinutes % 60;
//
//           return hours == 0
//               ? "$minutes minutes left"
//               : "$hours hours $minutes minutes left";
//         }
//       }
//
//       if (taskEndDate.isBefore(today)) {
//         return "Overdue";
//       }
//
//       int remainingDays = taskEndDate.difference(today).inDays;
//       return "$remainingDays days left";
//     } catch (e) {
//       return "Invalid Input";
//     }
//   }
// bool _refresh = true;
// bool get refresh =>_refresh;
//
// bool _viewRefresh = true;
// bool get viewRefresh =>_viewRefresh;
// List<TaskData> _allTasks = <TaskData>[];
// List<TaskData> _searchAllTasks = <TaskData>[];
// List<TaskData> get allTasks => _allTasks;
// List<TaskData> get searchAllTasks => _searchAllTasks;
// List<UserModel> assignEmployees=[];
//
// Future<void> getTaskUsers() async {
//     try {
//       Map data = {
//         "action": getAllData,
//         "search_type": "task_users",
//         "cos_id":localData.storage.read("cos_id"),
//         "role":localData.storage.read("role"),
//       };
//       final response =await _taskRepo.getUsers(data);
//       // log(response.toString());
//       if (response.isNotEmpty) {
//         assignEmployees=[];
//         assignEmployees=response;
//       }else{
//         assignEmployees=[];
//       }
//     } catch (e) {
//       assignEmployees=[];
//       log(e.toString());
//     }
//     notifyListeners();
//   }
//
// void initValue(){
//   _isRecording = false;
//   _selectedFiles.clear();
//   _recordedAudioPaths.clear();
//   selectedPhotos.clear();
//   taskTitleCont.clear();
//   _type=null;
//   _status=null;
//   _assignedId="";
//   _level="Normal";
//   _count=0;
//   if(typeList.isNotEmpty){
//     _type=typeList[0]["id"];
//   }
//   final selectedStatus = statusList.firstWhere(
//           (status) => status["value"] == "Assigned",
//       orElse: () => {"id": "0", "value": "Unknown"}
//   );
//   _status = selectedStatus;
//   localData.storage.write("status_id", selectedStatus["id"]);
//   taskDt.text="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
//     notifyListeners();
// }
// void initEditValue(context,TaskData data){
//
//   taskTitleCont.text=data.taskTitle.toString();
//   _level=data.level.toString();
//   taskDt.text=data.taskDate.toString();
//   _assignedId=data.assigned.toString();
//   _assName=data.assignedNames.toString();
//   _cusId=data.companyId.toString();
//   _cusName=data.projectName.toString();
//   _status=null;
//   _type=null;
//   notifyListeners();
//   final selectedStatus = statusList.firstWhere(
//         (status) => status["value"] == data.statval,
//     orElse: () => {"id": "0", "value": "Unknown"}
//   );
//   _status = selectedStatus;
//   localData.storage.write("status_id", selectedStatus["id"]);
//
//   final selectedType = typeList.firstWhere(
//         (status) => status["value"] == data.type, // Matching condition
//     orElse: () => {"id": "0", "value": "Unknown"}, // Default if not found
//   );
//
// // Set the selected type
//   _type = selectedType["id"];
//
// // Save the ID in local storage
//   localData.storage.write("type_id", selectedType["id"]);
//
//   changeAssignedIs(context,data.assignedNames.toString().split(","));
//   notifyListeners();
// }
//   Future<void> addTask({context,required String id}) async {
//     try {
//     List<Map<String, String>> customersList = [];
//
// // Loop for selected files
//     for (int i = 0; i < _selectedFiles.length; i++) {
//       // print("////$i");
//       customersList.add({
//         "image_$i": _selectedFiles[i]['path'],
//       });
//     }
//
// // Loop for recorded audio paths
//     for (int i = _selectedFiles.length; i < _selectedFiles.length + _recordedAudioPaths.length; i++) {
//       // print("----$i");
//       customersList.add({
//         "image_$i": _recordedAudioPaths[i - _selectedFiles.length].audioPath, // Adjust index
//       });
//     }
//
// // Loop for selected photos
//     for (int i = _selectedFiles.length + _recordedAudioPaths.length; i < _selectedFiles.length + _recordedAudioPaths.length + selectedPhotos.length; i++) {
//       // print("]]]]$i");
//       customersList.add({
//         "image_$i": selectedPhotos[i - (_selectedFiles.length + _recordedAudioPaths.length)], // Adjust index
//       });
//     }
//
//     String jsonString = json.encode(customersList);
//     Map<String, String> data = {
//       'project_name': id,
//       'task_title': taskTitleCont.text.trim(),
//       'department': departmentCont.text.trim(),
//       'log_file': localData.storage.read("mobile_number"),
//       'type': _type.toString(),
//       'assigned': assignedId,
//       'level': level,
//       'status': localData.storage.read("status_id"),
//       'user_id': localData.storage.read("id"),
//       'task_date': taskDt.text.trim(),
//       'task_time': "$taskSTime||$taskETime",
//       'action': adTask,
//       'cos_id': localData.storage.read("cos_id"),
//       "data": jsonString,
//     };
//     final response =await _taskRepo.addTask(data,customersList);
//     log(response.toString());
//       if (response.toString().contains("200")){
//         utils.showSuccessToast(context: context,text: constValue.success,);
//         taskCtr.reset();
//         // getAllTask(true);
//         Provider.of<HomeProvider>(context, listen: false).getMainReport(true);
//         utils.navigatePage(context, ()=>const DashBoard(child: ViewTask()));
//         // Future.microtask(() => Navigator.pop(context));
//       }else {
//         utils.showErrorToast(context: context);
//         taskCtr.reset();
//       }
//     } catch (e) {
//       utils.showWarningToast(context,text: e.toString());
//       taskCtr.reset();
//     }
//     notifyListeners();
//   }
//   Future<void> updateTaskDetail(context,{required String taskId,required String id,required bool isDirect,required List numberList,required String companyName}) async {
//     try {
//       Map<String, String> data = {
//       'id': taskId,
//       'project_name': id,
//       'task_title': taskTitleCont.text.trim(),
//       'department': departmentCont.text.trim(),
//       'log_file': localData.storage.read("mobile_number"),
//       'type': localData.storage.read("type_id"),
//       'assigned': assignedId,
//       'level': level,
//       'status': localData.storage.read("status_id"),
//       'user_id': localData.storage.read("id"),
//       'task_date': taskDt.text.trim(),
//       'task_time': "$taskSTime||$taskETime",
//       'action': updateTask,
//       'cos_id': localData.storage.read("cos_id"),
//     };
//     final response =await _taskRepo.updateTask(data);
//     // print(data.toString());
//     log(response.toString());
//       if (response.toString().contains("200")){
//         utils.showSuccessToast(context: context,text: constValue.updated,);
//         taskCtr.reset();
//         Provider.of<HomeProvider>(context, listen: false).getMainReport(true);
//         if(isDirect==true){
//           utils.navigatePage(context, ()=>const DashBoard(child: ViewTask()));
//         }else{
//           utils.navigatePage(context, ()=> DashBoard(child:
//           ViewTasks(coId:cusId,numberList: numberList, companyName: companyName)));
//     }
//       }else {
//         utils.showErrorToast(context: context);
//         taskCtr.reset();
//       }
//     } catch (e) {
//       utils.showWarningToast(context,text: "Failed",);
//   taskCtr.reset();
//     }
//     notifyListeners();
//   }
//
//   List<CustomerAttendanceModel> _customerAttendanceReport = <CustomerAttendanceModel>[];
//   List<CustomerAttendanceModel> get customerAttendanceReport=>_customerAttendanceReport;
//
//   Future<void> getAttendance(String id) async {
//     _refresh=false;
//     _customerAttendanceReport.clear();
//     notifyListeners();
//     try {
//       Map data = {
//         "action": getAllData,
//         "search_type":"task_visits",
//         "task_id":id,
//         "id":localData.storage.read("id"),
//         "cos_id":localData.storage.read("cos_id"),
//         "role":localData.storage.read("role"),
//       };
//       final response =await _taskRepo.getAttendances(data);
//       log(data.toString());
//       log(response.toString());
//       if (response.isNotEmpty) {
//         _customerAttendanceReport=response;
//         _refresh=true;
//       } else {
//         _refresh=true;
//       }
//     } catch (e) {
//       _refresh=true;
//     }
//     notifyListeners();
//   }
//   String crtDate(String dateTimeString, String type) {
//     var parts = dateTimeString.split(' ');
//     var dateParts = parts[0].split('-'); // Split the date into year, month, and day
//     var formattedDate = "${dateParts[2]}/${dateParts[1]}/${dateParts[0]}"; // Reorder to dd-MM-yyyy
//
//     var timeParts = parts[1].split(':');
//     int hour = int.parse(timeParts[0]);
//     String period = hour >= 12 ? 'PM' : 'AM';
//     hour = hour % 12 == 0 ? 12 : hour % 12;
//
//     if (type == "1") {
//       return formattedDate;
//     } else {
//       return "$hour:${timeParts[1]} $period";
//     }
//   }
//
//   Future<void> editTask({context,required String taskId,required String coId,required bool isDirect}) async {
//     try {
//     // Map<String, String> data = {
//     //   "user_id": localData.storage.read("id"),
//     //   "action": "update_status",
//     //   "task_id": taskId,
//     //   "status": status,
//     //   "mobile": localData.storage.read("mobile_number"),
//     //   'cos_id': localData.storage.read("cos_id")
//     // };
//     final response =await _taskRepo.updateTaskStatusApi(taskId: taskId, status: localData.storage.read("status_id"));
//     // print(response.toString());
//       if (response.toString().contains("200")){
//         utils.showSuccessToast(context: context,text: constValue.updated,);
//         taskCtr.reset();
//         Provider.of<HomeProvider>(context, listen: false).getMainReport(true);
//         if(isDirect==true){
//           getAllTask(true);
//         }else{
//           getAllCoTask(coId,true);
//         }
//         Future.microtask(() => Navigator.pop(context));
//       }else {
//         utils.showErrorToast(context: context);
//         taskCtr.reset();
//       }
//     } catch (e) {
//       utils.showWarningToast(context,text: "Failed",);
//   taskCtr.reset();
//     }
//     notifyListeners();
//   }
//   Future<void> getAllCoTask(String coId,bool isRefresh) async {
//     if(isRefresh==true){
//       _filter="1";
//       statusId="";
//       matched=0;
//       _status=null;
//       search.clear();
//       _allTasks.clear();
//       _searchAllTasks.clear();
//       _refresh=false;
//     }
//     notifyListeners();
//     try {
//       Map data = {
//         "action": taskDatas,
//         "search_type":"co_tasks",
//         "co_id":coId,
//         "cos_id": localData.storage.read("cos_id"),
//         "role": localData.storage.read("role"),
//         "id": localData.storage.read("id")
//       };
//       final response =await _taskRepo.getReport(data);
//       // print(data.toString());
//       // print(response.toString());
//       if (response.isNotEmpty) {
//         _allTasks=response;
//         _searchAllTasks=response;
//         _refresh=true;
//       }
//     } catch (e) {
//       _allTasks=[];
//       _searchAllTasks=[];
//       _refresh=true;
//     }
//     notifyListeners();
//   }
//   String _profile="";
//   String get profile=>_profile;
//   Future<void> signDialog({required BuildContext context, required String img,required Function(String newImg) onTap}) async {
//     _profile="";
//     var imgData = await Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => const CameraWidget(
//               cameraPosition: CameraType.front,
//               isSelfie: true,
//             )));
//     if (!context.mounted) return;
//     // Navigator.pop(context);
//     if (imgData != null) {
//       onTap(imgData);
//     }
//   }
//   void profilePick(String imgData){
//     _profile = imgData;
//     notifyListeners();
//   }
//   bool hasAppointment(DateTime date) {
//     return dataSource.appointments!.any((appt) =>
//     appt.startTime.year == date.year &&
//         appt.startTime.month == date.month &&
//         appt.startTime.day == date.day);
//   }
//   bool hasStatus(DateTime date, String status) {
//     return dataSource.appointments!.any((appt) =>
//     appt.startTime.year == date.year &&
//         appt.startTime.month == date.month &&
//         appt.startTime.day == date.day &&
//         (appt.subject?.toLowerCase() ?? '') == status.toLowerCase());
//   }
//   List<RoundedLoadingButtonController> controllers = [];
//
//   Future<void> getAllTask(bool isRefresh) async {
//     if(isRefresh==true){
//       _filter="1";
//       statusId="";
//       matched=0;
//       _filterDate=="";
//       _filterTasks=0;
//       _status=null;
//       search.clear();
//       search2.clear();
//       _allTasks.clear();
//       _searchAllTasks.clear();
//       controllers.clear();
//       _viewRefresh=false;
//       notifyListeners();
//     }
//   try {
//       Map data = {
//         "action": taskDatas,
//         "search_type":"all_tasks",
//         "cos_id": localData.storage.read("cos_id"),
//         "role": localData.storage.read("role"),
//         "id": localData.storage.read("id")
//       };
//       final response =await _taskRepo.getReport(data);
//       // print(data.toString());
//       // print(response.toString());
//       if (response.isNotEmpty) {
//         _allTasks=response;
//         _searchAllTasks=response;
//        if(isRefresh==true){
//          controllers = List.generate(_allTasks.length, (_) => RoundedLoadingButtonController());
//        }
//
//         for(var i=0;i<response.length;i++){
//             String dateStr = response[i].taskDate.toString(); // "24-05-2025"
//             DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(dateStr);
//             DateTime dateObject = parsedDate;
//             Appointment app = Appointment(
//               startTime: dateObject,
//               endTime: dateObject,
//               subject: response[i].statval.toString(),
//               color: colorsConst.red2,
//             );
//             dataSource.appointments!.add(app);
//             dataSource.notifyListeners(CalendarDataSourceAction.add, <Appointment>[app]);
//             // print("Adding Appointment....");
//             var count=0;
//             for(var i=0;i<response.length;i++){
//               var st = parsedDate;
//               if(utils.returnPadLeft(defaultMonth.toString())==utils.returnPadLeft(st.month.toString())){
//                 count++;
//               }
//             }
//             _thisMonthLeave=count.toString();
//           }
//         _viewRefresh=true;
//       }
//     } catch (e) {
//       _allTasks=[];
//       _searchAllTasks=[];
//       _viewRefresh=true;
//     }
//     notifyListeners();
//   }
//
//   Future<void> taskAttDirect(context,
//       {required String status, required String lat, required String lng,  required int ctrIndex, required String taskId}) async {
//     try {
//       print("ctrIndex : $ctrIndex");
//       Map<String, String> data = {
//         "action": taskAtt,
//         "log_file": localData.storage.read("mobile_number"),
//         "line_id": "0",
//         "line_customer_id": taskId,
//         "salesman_id": localData.storage.read("id"),
//         "self_img_count": "0",
//         "comp_img_count": "0",
//         "collection_amt": "0",
//         "sales_amt": "0",
//         "is_checked_out": status,
//         "lat": lat,
//         "lng": lng,
//         "traveled_kms": "0.0",
//         "id": localData.storage.read("tk_id").toString(),
//         "cos_id": localData.storage.read("cos_id"),
//
//       };
//       final response =await _taskRepo.addAttendance(data,_profile);
//       print("ctrIndex : $ctrIndex");
//       // print(response.toString());
//       if (response.isNotEmpty){
//         localData.storage.write("tk_id", response[0]["id"]);
//         utils.showSuccessToast(text: status=="1"?"Check In Successful":"Check Out Successful",context: context);
//         getAllTask(false);
//         Provider.of<HomeProvider>(context, listen: false).getMainReport(true);
//       }else {
//         utils.showErrorToast(context: context);
//         notifyListeners();
//       }
//     } catch (e) {
//       log(e.toString());
//       utils.showErrorToast(context: context);
//     }finally{
//       controllers[ctrIndex].reset();
//       notifyListeners();
//     }
//   }
//   Future<void> taskAttendance(context,
//       {required String status,
//       required String taskId,
//       required String coId,
//       required String lat,
//       required String lng}) async {
//     try {
//       showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Center(
//                 child: Column(
//                   children: [
//                     const CustomText(text: "Marking Please Wait",
//                       colors: Colors.grey,
//                       size: 15,
//                       isBold: true,),
//                     20.height,
//                     LoadingAnimationWidget.staggeredDotsWave(
//                       color: colorsConst.primary,
//                       size: 25,
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//       );
//       Map<String, String> data = {
//         "action": taskAtt,
//         "log_file": localData.storage.read("mobile_number"),
//         "line_id": "0",
//         "line_customer_id": taskId,
//         "salesman_id": localData.storage.read("id"),
//         "self_img_count": "0",
//         "comp_img_count": "0",
//         "collection_amt": "0",
//         "sales_amt": "0",
//         "is_checked_out": status,
//         "lat": lat,
//         "lng": lng,
//         "traveled_kms": "0.0",
//         "id": localData.storage.read("tk_id"),
//         "cos_id": localData.storage.read("cos_id"),
//       };
//       final response =await _taskRepo.addAttendance(data,_profile);
//       log(response.toString());
//       if (response.isNotEmpty){
//         localData.storage.write("tk_id", response[0]["id"]);
//         utils.showSuccessToast(text: status=="1"?"Check In Successful":"Check Out Successful",context: context);
//         getAllCoTask(coId,false);
//         Navigator.of(context, rootNavigator: true).pop();
//       }else {
//         Navigator.of(context, rootNavigator: true).pop();
//         utils.showErrorToast(context: context);
//       }
//     } catch (e) {
//       log(e.toString());
//       Navigator.of(context, rootNavigator: true).pop();
//       utils.showErrorToast(context: context);
//     }
//     notifyListeners();
//   }
//
//   Future<void> updateTaskStatus(
//       {required BuildContext context,
//       required String taskId,
//       required String status,
//       required bool isTaskPage,
//         required String selectStatus
//       }) async {
//     try {
//       final response =
//           await _taskRepo.updateTaskStatusApi(taskId: taskId, status: status);
//
//       log(response.toString());
//       if (response["status_code"] == 200) {
//         if (isTaskPage) {
//           if (!context.mounted) return;
//           final dashProvider = Provider.of<TaskProvider>(context, listen: false);
//           dashProvider.fetchTaskCount();
//           await Future.delayed(const Duration(seconds: 1));
//           fetchTaskDetails(taskId);
//           await Future.delayed(const Duration(seconds: 1));
//           fetchTaskList(selectStatus);
//         } else {
//           if (!context.mounted) return;
//           final dashProvider = Provider.of<TaskProvider>(context, listen: false);
//           dashProvider.fetchTaskCount();
//           Navigator.of(context).pop();
//           //await Future.delayed(const Duration(seconds: 2));
//           fetchTaskList(selectStatus);
//         }
//         taskStatusCtr.reset();
//         notifyListeners();
//       } else {
//         if (!context.mounted) return;
//         utils.showErrorToast(context: context);
//       }
//     } catch (e) {
//       log("$e");
//       if (!context.mounted) return;
//       utils.showErrorToast(context: context);
//       notifyListeners();
//       throw UnimplementedError();
//     } finally {
//       taskStatusCtr.reset();
//       notifyListeners();
//     }
//   }
//   var typeList=[];
//   var statusList=[];
//   Future<void> getTaskType() async {
//     try {
//       Map data = {
//         "action": getAllData,
//         "search_type":"cmt_type",
//         "cat_id":"7",
//         "cos_id": localData.storage.read("cos_id")
//       };
//       final response =await _taskRepo.getListDatas(data);
//       // log(response.toString());
//       if (response.isNotEmpty) {
//         List<Map<String, String>> list = response.map((e) => {
//           "id": e['id'].toString(),
//           "value": e['value'].toString(),
//           "categories": e['categories'].toString()
//         }).toList();
//         if(!kIsWeb){
//           await LocalDatabase.insertTaskType(list);
//         }else{
//           typeList.clear();
//           typeList=list;
//           notifyListeners();
//         }
//       }
//     } catch (e) {
//       // _refresh=true;
//     }
//     notifyListeners();
//   }
//   Future<void> getTaskStatuses() async {
//     try {
//       Map data = {
//         "action": getAllData,
//         "search_type":"cmt_type",
//         "cat_id":"8",
//         "cos_id": localData.storage.read("cos_id")
//       };
//       final response =await _taskRepo.getListDatas(data);
//       // log(response.toString());
//       if (response.isNotEmpty) {
//         List<Map<String, String>> list = response.map((e) => {
//           "id": e['id'].toString(),
//           "value": e['value'].toString(),
//           "categories": e['categories'].toString()
//         }).toList();
//         if(!kIsWeb){
//           await LocalDatabase.insertTaskStatus(list);
//         }else{
//           statusList.clear();
//           statusList=list;
//           notifyListeners();
//         }
//       }
//     } catch (e) {
//       // _refresh=true;
//     }
//     notifyListeners();
//   }
//   Future<void> getAllTypes() async {
//     typeList.clear();
//     List storedLeads = await LocalDatabase.getTaskTypes();
//     typeList=storedLeads;
//     notifyListeners();
//   }
//   Future<void> refreshTypes() async {
//     _type=null;
//     typeList.clear();
//     List storedLeads = await LocalDatabase.getTaskTypes();
//     typeList=storedLeads;
//     notifyListeners();
//   }
//   Future<void> getTypeSts() async {
//     statusList.clear();
//     List storedLeads = await LocalDatabase.getTaskStatus();
//     statusList=storedLeads;
//     notifyListeners();
//   }
//   Future<void> refreshStatus() async {
//     _status=null;
//     statusList.clear();
//     List storedLeads = await LocalDatabase.getTaskStatus();
//     statusList=storedLeads;
//     notifyListeners();
//   }
//
//   void _applyFilter(String selectedStatus) {
//     if (selectedStatus == "Pending Tasks") {
//
//       _filteredTasks = _taskList.where((task) {
//         String days = calculateDueDays(
//           task.taskDate.toString(),
//           timeRange: task.taskTime.toString(),
//           status: task.status,
//           updatedDate: task.updatedTs.toString(),
//         );
//         return days.contains("left");
//       }).toList();
//     }else if(selectedStatus == "Completed Tasks"){
//       _filteredTasks = _taskList.where((task) {
//         String days = calculateDueDays(
//           task.taskDate.toString(),
//           timeRange: task.taskTime.toString(),
//           status: task.status,
//           updatedDate: task.updatedTs.toString(),
//         );
//         return days.contains("Completed");
//       }).toList();
//     }else if(selectedStatus == "Overdue Tasks"){
//       _filteredTasks = _taskList.where((task) {
//         String days = calculateDueDays(
//           task.taskDate.toString(),
//           timeRange: task.taskTime.toString(),
//           status: task.status,
//           updatedDate: task.updatedTs.toString(),
//         );
//         return days.contains("Overdue");
//       }).toList();
//     }else {
//       _filteredTasks = _taskList;
//     }
//     notifyListeners();
//   }
//
//   Future<void> fetchTaskList(String selectedStatus) async {
//     _isLoading = true;
//     _isError = false;
//     notifyListeners();
//     try {
//       final response = await _taskRepo.getTaskList();
//       if (response.responseCode == '200') {
//         _taskList = response.response ?? [];
//         _applyFilter(selectedStatus);
//       } else {
//         _taskList = [];
//       }
//     } catch (e) {
//       _isError = true;
//       _taskList = [];
//       notifyListeners();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//
//   Future<void> fetchTaskDepartmentList(String projectName,String department) async {
//     _isLoading = true;
//     _isError = false;
//     notifyListeners();
//     try {
//       final response = await _taskRepo.getTaskDepartmentList(projectName, department);
//       if (response.responseCode == '200') {
//         _taskList = response.response ?? [];
//         _applyFilter("All");
//       } else {
//         _taskList = [];
//       }
//     } catch (e) {
//       _isError = true;
//       _taskList = [];
//       notifyListeners();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//
//   Future<void> fetchDepartmentList(String projectName) async {
//     _isDepartmentLoading = true;
//     _isError = false;
//     notifyListeners();
//     try {
//       final response = await _taskRepo.getDepartmentList(projectName);
//       if (response.responseCode == '200') {
//         _departmentList = response.response ?? [];
//       } else {
//         _departmentList = [];
//       }
//     } catch (e) {
//       _isError = true;
//       _taskList = [];
//       notifyListeners();
//     } finally {
//       _isDepartmentLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> fetchDepartmentCountList(String projectName) async {
//     _isDepartmentLoading = true;
//     _isError = false;
//     notifyListeners();
//     try {
//       final response = await _taskRepo.getDepartmentCountList(projectName);
//       if (response.responseCode == '200') {
//         _departmentList = response.response ?? [];
//       } else {
//         _departmentList = [];
//       }
//     } catch (e) {
//       _isError = true;
//       _taskList = [];
//       notifyListeners();
//     } finally {
//       _isDepartmentLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> fetchTaskDetails(String taskId) async {
//     _isTaskLoading = true;
//     _isError = false;
//     notifyListeners();
//     try {
//       final response = await _taskRepo.getTaskDetails(taskId);
//       if (response.responseCode == '200') {
//         _taskDetailsList = response.taskResponse ?? [];
//       } else {
//         _taskDetailsList = [];
//       }
//     } catch (e) {
//       _isError = true;
//       _taskDetailsList = [];
//       notifyListeners();
//     } finally {
//       _isTaskLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> fetchUserNameList() async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       final response = await _taskRepo.getUserNames();
//       if (response["ResponseCode"].toString() == "200") {
//         List<dynamic> data = response["Response"] ?? [];
//         _userNameList = data;
//         _assignList = [];
//         // for(var name in _userNameList){
//         //   if(name["f_name"]==localData.currentUserName){
//         //     _assignList.add("Self");
//         //   }else{
//         //     _assignList.add(name["f_name"]);
//         //   }
//         // }
//         _assignList = _userNameList.map((e) => e["f_name"].toString()).toList();
//       } else {
//         _userNameList = [];
//       }
//     } catch (e) {
//       // print("FetchUserNameList error $e");
//       _userNameList = [];
//       notifyListeners();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   /// Play Recorded Audio
//   // Future<void> playAudio() async {
//   //   if (_audioPath != null) {
//   //     _isPlaying = true;
//   //     notifyListeners();
//   //     await _audioPlayer.play(DeviceFileSource(_audioPath!));
//   //     _audioPlayer.onPlayerComplete.listen((event) {
//   //       _isPlaying = false;
//   //       notifyListeners();
//   //     });
//   //   }
//   // }
//
//   /// Stop Audio Playback
//   // Future<void> stopAudio() async {
//   //   await _audioPlayer.stop();
//   //   _isPlaying = false;
//   //   notifyListeners();
//   // }
// /// CHART
//   String _totalCount = "";
//   String _pendingCount = "";
//   String _completedCount = "";
//   String _overdueCount = "";
//   double _pendingCountPer = 0.0;
//   double _completedCountPer = 0.0;
//   double _overdueCountPer = 0.0;
//   bool _isDashboardLoading = false;
//
//   String get totalCount => _totalCount;
//   String get pendingCount => _pendingCount;
//   String get completedCount => _completedCount;
//   String get overdueCount => _overdueCount;
//   double get pendingCountPer => _pendingCountPer;
//   double get completedCountPer => _completedCountPer;
//   double get overdueCountPer => _overdueCountPer;
//   bool get isDashboardLoading => _isDashboardLoading;
//
//   Future<void> fetchTaskCount() async {
//     _isDashboardLoading = true;
//     notifyListeners();
//     try {
//       final response = await _taskRepo.getDashboardCount();
//       // print("dashboard output ${response["Response"]}");
//       if (response["ResponseCode"].toString() == "200") {
//         List<dynamic> data = response["Response"] ?? [];
//         _totalCount = data[0]["total_count"];
//         _pendingCount = data[0]["pending_count"];
//         _completedCount = data[0]["complete_count"];
//         _overdueCount = data[0]["overdue_count"];
//         double total = double.tryParse(_totalCount) ?? 1;
//         double completed = double.tryParse(_completedCount) ?? 0;
//         double pending = double.tryParse(_pendingCount) ?? 0;
//         double overdue = double.tryParse(_overdueCount) ?? 0;
//         _completedCountPer = (completed / total) * 100;
//         _pendingCountPer = (pending / total) * 100;
//         _overdueCountPer = (overdue / total) * 100;
//         notifyListeners();
//       } else {
//         _totalCount = "0";
//         _pendingCount = "0";
//         _completedCount = "0";
//         _overdueCount = "0";
//       }
//       notifyListeners();
//     } catch (e) {
//       _totalCount = "0";
//       _pendingCount = "0";
//       _completedCount = "0";
//       _overdueCount = "0";
//       // print("FetchUserNameList error $e");
//       notifyListeners();
//     } finally {
//       _isDashboardLoading = false;
//       notifyListeners();
//     }
//   }
//   /// copy of customer add visit page
//
//
//   List<String> _selectedPhotos = [];
//
//   List<String> get selectedPhotos => _selectedPhotos;
//
//   Future<void> pickCamera(BuildContext context) async {
//     var imgData = await Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => const CameraWidget(
//               cameraPosition: CameraType.back,
//             )));
//     _selectedPhotos.add(imgData);
//     notifyListeners();
//   }
//   void removePhotos(int index) {
//     _selectedPhotos.removeAt(index);
//     notifyListeners();
//   }
//
//   final AudioRecorder record = AudioRecorder();
//
//   bool isValidUrl(String url) {
//     final Uri? uri = Uri.tryParse(url);
//     return uri != null && (uri.hasScheme && uri.hasAuthority);
//   }
//
//   String formatDuration(Duration d) {
//     String minutes = d.inMinutes.toString().padLeft(2, '0');
//     String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
//     return "$minutes:$seconds";
//   }
// }


class TaskProvider with ChangeNotifier {
  late VideoPlayerController videoPlayerController;
  final TaskRepo _taskRepo = TaskRepo();

  RoundedLoadingButtonController taskCtr = RoundedLoadingButtonController();
  RoundedLoadingButtonController taskStatusCtr = RoundedLoadingButtonController();

  GroupButtonController statusController = GroupButtonController();
  bool _isFilter=false;
  bool get isFilter=>_isFilter;
  String _startDate = "";
  String get startDate => _startDate;
  String _endDate="";
  String get endDate => _endDate;
  String _companyName="";
  String get companyName => _companyName;

  // void dateFilterList(String date1,String date2) {
  //   final dateFormat = DateFormat('dd-MM-yyyy');
  //   final parsedStartDate = dateFormat.parse(date1);
  //   final parsedEndDate = dateFormat.parse(date2);
  //
  //   _filterUserData = _searchAllTasks.where((contact) {
  //     // Parse contact.taskDate (in dd-MM-yyyy format)
  //     final taskDate = dateFormat.parse(contact.taskDate.toString());
  //     final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);
  //
  //     // Filter by date range
  //     final isWithinDateRange =
  //         !taskDateOnly.isBefore(parsedStartDate) && !taskDateOnly.isAfter(parsedEndDate);
  //
  //     // Optional filters
  //     final isTypeMatch = _fType == "" || _fType == contact.type;
  //     final isEmpMatch = _userName == "" || contact.assignedNames.toString().contains(_userName);
  //     final isCusMatch = _companyName == "" || contact.projectName == _companyName;
  //
  //     // Return if all filters match
  //     return isWithinDateRange && isTypeMatch && isEmpMatch && isCusMatch;
  //   }).toList();
  //   print("(((((((((((((((((.......${_filterUserData.length}");
  //
  //   notifyListeners();
  // }
  ///
  // void filterList() {
  //   print("*****filter list");
  //   final dateFormat = DateFormat('dd-MM-yyyy');
  //   final parsedStartDate = dateFormat.parse(_startDate);
  //   final parsedEndDate = dateFormat.parse(_endDate);
  //
  //   _filterUserData = _searchAllTasks.where((contact) {
  //     // Parse contact.taskDate (in dd-MM-yyyy format)
  //     final taskDate = dateFormat.parse(contact.taskDate.toString());
  //     final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);
  //
  //     // Filter by date range
  //     final isWithinDateRange =
  //         !taskDateOnly.isBefore(parsedStartDate) && !taskDateOnly.isAfter(parsedEndDate);
  //
  //     // Optional filters
  //     final isTypeMatch = _fType == "" || _fType == contact.type;
  //     final isEmpMatch = _userName == "" || contact.assignedNames.toString().contains(_userName);
  //     final isCusMatch = _companyName == "" || contact.projectName == _companyName;
  //
  //     // Return if all filters match
  //     return isWithinDateRange && isTypeMatch && isEmpMatch && isCusMatch;
  //   }).toList();
  //
  //   notifyListeners();
  // }
  void filterList() {
    final dateFormat = DateFormat('dd-MM-yyyy');
    final parsedStartDate = dateFormat.parse(_startDate);
    final parsedEndDate = dateFormat.parse(_endDate);

    _filterUserData = _searchAllTasks.where((contact) {
      final taskDate = dateFormat.parse(contact.taskDate.toString());
      final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);

      final isWithinDateRange =
          !taskDateOnly.isBefore(parsedStartDate) &&
              !taskDateOnly.isAfter(parsedEndDate);

      final isTypeMatch = _fType == "" || _fType == contact.type;

      final isEmpMatch = _assignedNames == "" ||
          contact.assignedNames
              .toString()
              .split(',')
              .map((e) => e.trim().toLowerCase())
              .any((name) =>
          name.contains(_assignedNames.toLowerCase()) ||
              _assignedNames.toLowerCase().contains(name));

      final isCusMatch =
          _companyName == "" || contact.projectName == _companyName;

      return isWithinDateRange &&
          isTypeMatch &&
          isEmpMatch &&
          isCusMatch;
    }).toList();

    notifyListeners();
  }

  // void filterList() {
  //   final dateFormat = DateFormat('dd-MM-yyyy');
  //   final parsedStartDate = dateFormat.parse(_startDate);
  //   final parsedEndDate = dateFormat.parse(_endDate);
  //
  //   _filterUserData = _searchAllTasks.where((contact) {
  //     // Parse contact.taskDate (in dd-MM-yyyy format)
  //     final taskDate = dateFormat.parse(contact.taskDate.toString());
  //     final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);
  //
  //     // Filter by date range
  //     final isWithinDateRange = !taskDateOnly.isBefore(parsedStartDate) && !taskDateOnly.isAfter(parsedEndDate);
  //     // Optional filters
  //     final isTypeMatch = _fType == "" || _fType == contact.type;
  //     final isEmpMatch = _userName == "" || contact.assignedNames.toString().contains(_userName);
  //     final isCusMatch = _companyName == "" || contact.projectName == _companyName;
  //
  //     // Return if all filters match
  //     return isWithinDateRange && isTypeMatch && isEmpMatch && isCusMatch;
  //   }).toList();
  //
  //   notifyListeners();
  // }

  String _fType = "";
  String get fType => _fType;
  void checkFilterType(dynamic value) {
    _type = value;
    print("value");
    print(value);
    var list = [];
    list.add(value);
    _fType=list[0]["value"]=="All"?"":list[0]["value"];
    notifyListeners();
  }

  void filterList2() {
    final dateFormat = DateFormat('dd-MM-yyyy');
    final parsedStartDate = dateFormat.parse(_startDate);
    final parsedEndDate = dateFormat.parse(_endDate);
    _filterUserData = _searchAllTasks.where((contact) {
      // Parse contact.taskDate (in dd-MM-yyyy format)
      final taskDate = dateFormat.parse(contact.taskDate.toString());
      final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);

      // Filter by date range
      final isWithinDateRange =
          !taskDateOnly.isBefore(parsedStartDate) && !taskDateOnly.isAfter(parsedEndDate);

      // Optional filters
      final isTypeMatch = _fType == "" || _fType == contact.type;
      final isEmpMatch = _userName == "" || contact.assignedNames.toString().contains(_userName);
      final isCusMatch = _companyName == "" || contact.projectName == _companyName;

      // Return if all filters match
      return isWithinDateRange && isTypeMatch && isEmpMatch && isCusMatch;
    }).toList();

    notifyListeners();
  }
  void changeName(value) {
    _companyName=value!.companyName.toString();
    notifyListeners();
  }
  String _stDate="";
  String _enDate="";
  String get stDate=> _stDate;
  String get enDate=> _enDate;
  PickerDateRange? selectedDate2;
  List<DateTime> datesBetween = [];
  String betweenDates="";
  List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    List<DateTime> days = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(DateTime(start.year, start.month, start.day + i));
    }
    return days;
  }
  void showDatePickerDialog(BuildContext context) {
    DateTime today = DateTime.now();
    selectedDate2 = PickerDateRange(today, today);
    datesBetween = getDatesInRange(selectedDate2!.startDate!, selectedDate2!.endDate!);

    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    List<String> formattedDates = datesBetween.map((date) => dateFormat.format(date)).toList();
    betweenDates = formattedDates.join(' || ');

    _stDate = dateFormat.format(selectedDate2!.startDate!);
    notifyListeners();
    notifyListeners();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(text: '   Select Date',colors: colorsConst.secondary,isBold: true,),
          content: SizedBox(
            height: 300, // Adjust height as needed
            width: 300, // Adjust width as needed
            child: SfDateRangePicker(
              minDate: DateTime(2025), // Disable past dates
              maxDate: DateTime.now(),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                selectedDate2 = args.value;
                _startDate="";
                _endDate="";
                if(selectedDate2?.endDate!=null){
                  _startDate="${selectedDate2?.startDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate2?.startDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate2?.startDate?.year.toString()}";

                  _endDate="${selectedDate2?.endDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate2?.endDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate2?.endDate?.year.toString()}";
                }else{
                  _startDate="${selectedDate2?.startDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate2?.startDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate2?.startDate?.year.toString()}";
                  _endDate="${selectedDate2?.startDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate2?.startDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate2?.startDate?.year.toString()}";
                }
                notifyListeners();
              },
              selectionMode: DateRangePickerSelectionMode.range,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(text: 'Click and drag to select multiple dates',colors: colorsConst.greyClr,),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const CustomText(text:'Cancel',colors: Colors.grey,isBold: true,),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: CustomText(text: 'OK',colors: colorsConst.primary,isBold: true,),
                  onPressed: () {
                    if (selectedDate2 != null) {
                      datesBetween = getDatesInRange(
                        selectedDate2!.startDate!,
                        selectedDate2!.endDate ?? selectedDate2!.startDate!,
                      );
                    }
                    DateFormat dateFormat = DateFormat('dd-MM-yyyy');

                    List<String> formattedDates = datesBetween.map((date) => dateFormat.format(date)).toList();
                    betweenDates = formattedDates.join(' || ');
                    filterList2();
                    initFilterValue(false);
                    notifyListeners();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void initDateValue(String date1,String date2,String type,){
      _isFilter=false;
      _filterType=type;
      _type=null;
      _companyName="";
      _fType="";
      _filterUserData=_allTasks;
      _userName="";
    _filterDate="";
    _startDate=date1;
    _endDate=date2;
    search.clear();
    filterList();
    notifyListeners();
  }
  void initFilterValue(bool isClear,{String? date1, String? date2, String? type}){
    if(isClear==false){
      _isFilter=true;
    }else{
      _isFilter=false;
      _filterType=type;
      _type=null;
      _companyName="";
      _fType="";
      _filterUserData=_allTasks;
      _userName="";
      _filterDate="";
      _startDate=date1!;
      _endDate=date2!;
      search.clear();
      _assignedNames="";
    }
    // _filterDate="";
    // _stDate="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
    // _enDate="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
    search.clear();
    notifyListeners();
  }
  void filterPick({required BuildContext context, required String date, required bool isStartDate}) {
    DateTime dateTime = DateTime.now();
    final parsedDate = DateFormat('dd-MM-yyyy').parse(date);
    final now = DateTime.now();
    DateTime initDate = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      now.hour,
      now.minute,
      now.second,
    );
    showDatePicker(
      context: context,
      initialDate: initDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    ).then((value) {
      if (value != null) {
        String formattedDate = "${value.day.toString().padLeft(2, "0")}-"
            "${value.month.toString().padLeft(2, "0")}-"
            "${value.year.toString()}";

        if (isStartDate) {
          _startDate = formattedDate;
        } else {
          _endDate = formattedDate;
        }

        notifyListeners();
      }
    });
  }
  dynamic _filterType;
  dynamic get filterType =>_filterType;
  void changeFilterType(dynamic value){
    _filterType = value;
    if(_filterType=="Today"){
      daily();
    }else if(_filterType=="Yesterday"){
      yesterday();
    }else if(_filterType=="Last 7 Days"){
      last7Days();
    }else if(_filterType=="Last 30 Days"){
      last30Days();
    }else if(_filterType=="This Week"){
      thisWeek();
    }else if(_filterType=="This Month"){
      thisMonth();
    }else if(_filterType=="Last 3 months"){
      last3Month();
    }
    notifyListeners();
  }

  DateTime stDt = DateTime.now();
  DateTime enDt = DateTime.now().add(const Duration(days: 1));
  void daily() {
    stDt=DateTime.now();
    enDt=DateTime.now().add(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(stDt);
    notifyListeners();
  }
  void yesterday() {
    stDt=DateTime.now().subtract(const Duration(days: 1));
    enDt = DateTime.now();
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(stDt);
    notifyListeners();
  }
  void last7Days() {
    DateTime now = DateTime.now();
    DateTime lastWeekStart = now.subtract(const Duration(days: 6));
    DateTime lastWeekEnd = now;
    _startDate = DateFormat('dd-MM-yyyy').format(lastWeekStart);
    _endDate = DateFormat('dd-MM-yyyy').format(lastWeekEnd);
    notifyListeners();
  }
  void last30Days() {
    DateTime now = DateTime.now();
    DateTime lastMonthStart = now.subtract(const Duration(days: 29));
    DateTime lastMonthEnd = now;
    _startDate = DateFormat('dd-MM-yyyy').format(lastMonthStart);
    _endDate = DateFormat('dd-MM-yyyy').format(lastMonthEnd);
    notifyListeners();
  }
  void thisWeek() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime stDt = now.subtract(Duration(days: currentWeekday - 1));
    DateTime enDt = now.add(Duration(days: 7 - currentWeekday));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }
  // void thisMonth() {
  //   DateTime now = DateTime.now();
  //   stDt = DateTime(now.year, now.month, 1);
  //   enDt = DateTime(now.year, now.month + 1, 0);
  //   _startDate = DateFormat('dd-MM-yyyy').format(stDt);
  //   _endDate = DateFormat('dd-MM-yyyy').format(enDt);
  //   notifyListeners();
  // }
  void thisMonth() {
    DateTime now = DateTime.now();
    stDt = DateTime(now.year, now.month, 1); // Start of month
    enDt = now; // Today’s date
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }

  void last3Month() {
    DateTime now = DateTime.now();
    DateTime stDt = DateTime(now.year, now.month - 2, now.day);
    DateTime enDt = now;

    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }
  void lastMonth() {
    DateTime now = DateTime.now();
    stDt = DateTime(now.year, now.month, 1);
    enDt = DateTime(now.year, now.month + 1, 0);
    stDt = DateTime(stDt.year, stDt.month - 1, 1);
    enDt = DateTime(enDt.year, enDt.month - 1, 1);
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(DateTime(enDt.year, enDt.month + 1, 0));
    notifyListeners();
  }
  var filterTypeList = ["Today","Yesterday","Last 7 Days","Last 30 Days","This Week","This Month","Last 3 months"];
  dynamic _user;
  dynamic get user=>_user;
  String _userName="";
  String get userName=>_userName;
  void selectUser(UserModel value){
    _user=value.id;
    _userName=value.firstname.toString();
    filterList();
    notifyListeners();
  }

  Future<void> downloadAllTask(context) async {
    // _searchAllTasks.clear();
    notifyListeners();
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      Map data = {
        "action": taskDatas,
        "search_type":"download_reports",
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "id": localData.storage.read("id"),
        "date1":_startDate,
        "date2":_endDate
      };
      final response =await _taskRepo.downloadReport(data);
      // print(data.toString());
      // log("response.toString()");
      // log(response.toString());
      if (response.isNotEmpty) {
        List<DTaskModel> test = response.where((contact) {

          final isTypeMatch = _fType == "" || _fType == contact.type;
          final isEmpMatch = _userName == "" || contact.assignedNames.toString().contains(_userName);
          final isCusMatch = _companyName == "" || contact.projectName == _companyName;
          return isTypeMatch && isEmpMatch && isCusMatch;
        }).toList();
        if(test.isNotEmpty){
          generatePdf(test,context);
        }else{
          utils.showWarningToast(context, text: "No Task Found");
          Navigator.pop(context);
          notifyListeners();
        }
      }else{
        utils.showWarningToast(context, text: "No Task Found");
        Navigator.pop(context);
        notifyListeners();
      }
    } catch (e) {
      utils.showWarningToast(context, text: "No Task Found");
      Navigator.pop(context);
      notifyListeners();
    }
    notifyListeners();
  }

  String parseDate(String value) {
    try {
      return DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(value));
    } catch (_) {
      return value; // if invalid format, return as-is
    }
  }

  // Future<void> generatePdf(List<DTaskModel> taskList, BuildContext context) async {
  //   final pdf = pw.Document();
  //
  //   // Unicode-safe fonts
  //   final font = await PdfGoogleFonts.notoSansRegular();
  //   final boldFont = await PdfGoogleFonts.notoSansBold();
  //
  //   // Helper to load and compress images
  //   Future<pw.MemoryImage?> loadAndCompressImage(String url,
  //       {int maxWidth = 800, int maxHeight = 800, int quality = 70}) async {
  //     try {
  //       final response = await http.get(Uri.parse("$imageFile?path=$url"));
  //       if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
  //         img.Image? image = img.decodeImage(response.bodyBytes);
  //         if (image != null) {
  //           image = img.copyResize(image,
  //               width: image.width > maxWidth ? maxWidth : image.width,
  //               height: image.height > maxHeight ? maxHeight : image.height);
  //           return pw.MemoryImage(img.encodeJpg(image, quality: quality));
  //         }
  //       }
  //     } catch (_) {}
  //     return null;
  //   }
  //
  //   // Preload all images for tasks
  //   Map<DTaskModel, List<pw.MemoryImage>> taskImages = {};
  //   for (var task in taskList) {
  //     final images = <pw.MemoryImage>[];
  //     final docs = [task.docsType1, task.docsType2, task.docsType3];
  //     for (var docList in docs) {
  //       if (docList != null && docList.isNotEmpty) {
  //         for (var url in docList) {
  //           if (url.isNotEmpty && url != "null") {
  //             final imgData = await loadAndCompressImage(url);
  //             if (imgData != null) images.add(imgData);
  //           }
  //         }
  //       }
  //     }
  //     taskImages[task] = images;
  //   }
  //
  //   // Build PDF
  //   pdf.addPage(
  //     pw.MultiPage(
  //       pageFormat: PdfPageFormat.a4,
  //       build: (context) {
  //         return [
  //           pw.Center(
  //             child: pw.Text(
  //               "Task Reports - $startDate${startDate != endDate ? " To $endDate" : ""}",
  //               style: pw.TextStyle(fontSize: 20, font: boldFont),
  //             ),
  //           ),
  //           pw.SizedBox(height: 15),
  //           ...taskList.map((task) {
  //             // Prepare expense data map
  //             final expIds = task.expenseIds;
  //             final expAmounts = task.expenseAmount;
  //             final expStatus = task.expenseStatus;
  //             Map<String, Map<String, List<List<String>>>> expenseData = {};
  //             for (var id in expIds) {
  //               expenseData[id] = {"travel": [], "da": [], "conv": []};
  //             }
  //
  //             // Travel details
  //             if (task.travelDetails != null) {
  //               for (var travelBlock in task.travelDetails) {
  //                 final travelRows = travelBlock.split("||");
  //                 for (var row in travelRows) {
  //                   final parts = row.split("|").map((e) => e.trim()).toList();
  //                   if (parts.isNotEmpty && expenseData.containsKey(parts[0])) {
  //                     expenseData[parts[0]]!["travel"]!.add(parts.sublist(1));
  //                   }
  //                 }
  //               }
  //             }
  //
  //             // DA details
  //             if (task.daDetails != null) {
  //               for (var daBlock in task.daDetails) {
  //                 final daGroups = daBlock.split("###");
  //                 for (var group in daGroups) {
  //                   final rows = group.split("||");
  //                   for (var row in rows) {
  //                     final parts = row.split("|").map((e) => e.trim()).toList();
  //                     if (parts.isNotEmpty && expenseData.containsKey(parts[0])) {
  //                       expenseData[parts[0]]!["da"]!.add(parts.sublist(1));
  //                     }
  //                   }
  //                 }
  //               }
  //             }
  //
  //             // Conveyance details
  //             if (task.convDetails != null) {
  //               for (var convBlock in task.convDetails) {
  //                 final convGroups = convBlock.split("###");
  //                 for (var group in convGroups) {
  //                   final rows = group.split("||");
  //                   for (var row in rows) {
  //                     final parts = row.split("|").map((e) => e.trim()).toList();
  //                     if (parts.isNotEmpty && expenseData.containsKey(parts[0])) {
  //                       expenseData[parts[0]]!["conv"]!.add(parts.sublist(1));
  //                     }
  //                   }
  //                 }
  //               }
  //             }
  //
  //             // Build task section
  //             return pw.Column(
  //               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //               children: [
  //                 pw.Row(
  //                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       pw.RichText(
  //                         text: pw.TextSpan(
  //                           children: [
  //                             pw.TextSpan(text: "Task Date: ", style: pw.TextStyle(font: font)),
  //                             pw.TextSpan(text: task.taskDate, style: pw.TextStyle(font: boldFont)),
  //                           ],
  //                         ),
  //                       ),
  //                       pw.RichText(
  //                         text: pw.TextSpan(
  //                           children: [
  //                             pw.TextSpan(text: "Status: ", style: pw.TextStyle(font: font)),
  //                             pw.TextSpan(text: task.status, style: pw.TextStyle(font: boldFont)),
  //                           ],
  //                         ),
  //                       ),
  //                     ]
  //                 ),
  //                 pw.RichText(
  //                   text: pw.TextSpan(
  //                     children: [
  //                       pw.TextSpan(text: "Task: ", style: pw.TextStyle(font: font)),
  //                       pw.TextSpan(text: task.taskTitle, style: pw.TextStyle(font: boldFont)),
  //                     ],
  //                   ),
  //                 ),
  //                 pw.RichText(
  //                   text: pw.TextSpan(
  //                     children: [
  //                       pw.TextSpan(text: "Company Name: ", style: pw.TextStyle(font: font)),
  //                       pw.TextSpan(text: task.projectName, style: pw.TextStyle(font: boldFont)),
  //                     ],
  //                   ),
  //                 ),
  //                 pw.Row(
  //                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       pw.RichText(
  //                         text: pw.TextSpan(
  //                           children: [
  //                             pw.TextSpan(text: "Assigned To: ", style: pw.TextStyle(font: font)),
  //                             pw.TextSpan(text: task.assignedNames, style: pw.TextStyle(font: boldFont)),
  //                           ],
  //                         ),
  //                       ),
  //                       pw.RichText(
  //                         text: pw.TextSpan(
  //                           children: [
  //                             pw.TextSpan(text: "Created By: ", style: pw.TextStyle(font: font)),
  //                             pw.TextSpan(text: task.creator, style: pw.TextStyle(font: boldFont)),
  //                           ],
  //                         ),
  //                       ),
  //                     ]
  //                 ),
  //                 pw.SizedBox(height: 5),
  //                 // Attendance
  //                 if (task.checkInTs.toString()!="null")
  //                   pw.Column(
  //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                     children: [
  //                       pw.Text("Visits", style: pw.TextStyle(font: boldFont, fontSize: 14)),
  //                       pw.SizedBox(height: 5),
  //
  //                       // Split the comma-separated strings
  //                           () {
  //                         final inTimeList = task.checkInTs.toString().split(",");
  //                         final outTimeList = task.checkOutTs.toString().split(",");
  //                         final isCheckedOutList = task.isCheckedOut.toString().split(",");
  //                         final visitedRows = <List<String>>[];
  //
  //                         for (var i = 0; i < inTimeList.length; i++) {
  //                           final inTime = inTimeList.length > i ? inTimeList[i].trim() : "";
  //                           final outTime = outTimeList.length > i ? outTimeList[i].trim() : "";
  //                           final isCheckedOut = isCheckedOutList.length > i ? isCheckedOutList[i].trim() : "";
  //
  //                           // Extract only the date part from inTime
  //                           String datePart = "";
  //                           String inTimeOnly = "";
  //                           String outTimeOnly = "-";
  //
  //                           if (inTime.isNotEmpty) {
  //                             final dt = DateTime.tryParse(inTime);
  //                             if (dt != null) {
  //                               datePart = DateFormat('dd-MM-yyyy').format(dt);
  //                               inTimeOnly = DateFormat('hh:mm a').format(dt);
  //                             }
  //                           }
  //
  //                           if (outTime.isNotEmpty && isCheckedOut == "2") {
  //                             final dtOut = DateTime.tryParse(outTime);
  //                             if (dtOut != null) {
  //                               outTimeOnly = DateFormat('hh:mm a').format(dtOut);
  //                             }
  //                           }
  //
  //                           visitedRows.add([datePart, inTimeOnly, outTimeOnly]);
  //                         }
  //
  //                         // Return a table with headers
  //                         return pw.Table.fromTextArray(
  //                           headers: ['Date', 'Check-In', 'Check-Out'],
  //                           data: visitedRows,
  //                           headerStyle: pw.TextStyle(font: boldFont),
  //                           cellStyle: pw.TextStyle(font: font),
  //                           headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
  //                           cellAlignment: pw.Alignment.centerLeft,
  //                         );
  //                       }(),
  //                     ],
  //                   ),
  //                 pw.SizedBox(height: 10),
  //
  //                 // Attendance
  //                 if (task.cvDates.toString()!="null")
  //                   pw.Column(
  //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                     children: [
  //                       pw.Text("Visits Report", style: pw.TextStyle(font: boldFont, fontSize: 14)),
  //                       pw.SizedBox(height: 5),
  //
  //                           () {
  //                         final dateList = task.cvDates.toString().split(",");
  //                         final cusNameList = task.cvCustomerNames.toString().split(",");
  //                         final discList = task.cvDiscussionPoints.toString().split(",");
  //                         final actionList = task.cvActionTakens.toString().split(",");
  //                         final visitedRows = <List<String>>[];
  //
  //                         for (var i = 0; i < dateList.length; i++) {
  //                           visitedRows.add([
  //                             dateList[i].trim(),
  //                             cusNameList.length > i ? cusNameList[i].trim() : "",
  //                             discList.length > i ? discList[i].trim() : "",
  //                             actionList.length > i ? actionList[i].trim() : "",
  //                           ]);
  //                         }
  //
  //                         return pw.Table.fromTextArray(
  //                           headers: ['Date', 'Customer Name', 'Discussion Points', 'Action to be taken'],
  //                           data: visitedRows,
  //                           headerStyle: pw.TextStyle(font: boldFont),
  //                           cellStyle: pw.TextStyle(font: font),
  //                           headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
  //                           cellAlignment: pw.Alignment.centerLeft,
  //                         );
  //                       }(),
  //                     ],
  //                   ),
  //                 pw.SizedBox(height: 10),
  //
  //                 // Expenses
  //                 if (expenseData.isNotEmpty)
  //                   pw.Column(
  //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                     children: [
  //                       pw.Text("Expenses", style: pw.TextStyle(fontSize: 14, font: boldFont)),
  //                       pw.SizedBox(height: 5),
  //                       ...expenseData.keys.map((id) {
  //                         final index = expIds.indexOf(id);
  //                         final total = index < expAmounts.length ? expAmounts[index] : "0";
  //                         final status = index < expStatus.length ? expStatus[index] : "0";
  //
  //                         return pw.Column(
  //                           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                           children: [
  //                             pw.Text(
  //                               "Expense - Total: ₹$total – Status: ${status == "0" ? "Rejected" : status == "1" ? "In Process" : "Approved"}",
  //                               style: pw.TextStyle(font: font),
  //                             ),
  //                             pw.SizedBox(height: 5),
  //
  //                             // DA Table
  //                             if (expenseData[id]!["da"]!.isNotEmpty)
  //                               pw.Column(
  //                                 crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                                 children: [
  //                                   pw.Text("DA Expenses", style: pw.TextStyle(font: boldFont)),
  //                                   ...chunkList(expenseData[id]!["da"]!, 15).map((chunk) {
  //                                     return pw.Table.fromTextArray(
  //                                       headers: ['Day', 'Type', 'Amount'],
  //                                       data: chunk,
  //                                     );
  //                                   }),
  //                                 ],
  //                               ),
  //
  //                             // Travel Table
  //                             if (expenseData[id]!["travel"]!.isNotEmpty)
  //                               pw.Column(
  //                                 crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                                 children: [
  //                                   pw.Text("Travel Expenses", style: pw.TextStyle(font: boldFont)),
  //                                   ...chunkList(expenseData[id]!["travel"]!, 15).map((chunk) {
  //                                     return pw.Table.fromTextArray(
  //                                       headers: [
  //                                         'From', 'To', 'Start Date', 'Start Time',
  //                                         'End Date', 'End Time', 'Mode', 'Amount'
  //                                       ],
  //                                       data: chunk,
  //                                     );
  //                                   }),
  //                                 ],
  //                               ),
  //
  //                             // Conveyance Table
  //                             if (expenseData[id]!["conv"]!.isNotEmpty)
  //                               pw.Column(
  //                                 crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                                 children: [
  //                                   pw.Text("Conveyance Expenses", style: pw.TextStyle(font: boldFont)),
  //                                   ...chunkList(expenseData[id]!["conv"]!, 15).map((chunk) {
  //                                     return pw.Table.fromTextArray(
  //                                       headers: ['Date', 'From', 'To', 'Mode', 'Amount'],
  //                                       data: chunk,
  //                                     );
  //                                   }),
  //                                 ],
  //                               ),
  //                             pw.SizedBox(height: 10),
  //                           ],
  //                         );
  //                       }),
  //                     ],
  //                   ),
  //
  //                 // Expense images
  //                 if (taskImages[task] != null && taskImages[task]!.isNotEmpty)
  //                   pw.Column(
  //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                     children: [
  //                       pw.Text("Expense Documents", style: pw.TextStyle(font: boldFont, fontSize: 14)),
  //                       pw.SizedBox(height: 5),
  //                       ...List.generate((taskImages[task]!.length / 3).ceil(), (rowIndex) {
  //                         final rowImages = taskImages[task]!.skip(rowIndex * 3).take(3).toList();
  //                         return pw.Row(
  //                           mainAxisAlignment: pw.MainAxisAlignment.start,
  //                           children: rowImages
  //                               .map((img) => pw.Padding(
  //                             padding: const pw.EdgeInsets.only(right: 5, bottom: 5),
  //                             child: pw.Image(img, width: 180, height: 120, fit: pw.BoxFit.contain),
  //                           ))
  //                               .toList(),
  //                         );
  //                       }),
  //                     ],
  //                   ),
  //                 pw.Divider(),
  //                 pw.SizedBox(height: 20),
  //               ],
  //             );
  //           }),
  //         ];
  //       },
  //     ),
  //   );
  //
  //   Navigator.pop(context); // hide loading
  //   await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  // }
  Future<void> generatePdf(List<DTaskModel> taskList, BuildContext context) async {
    final pdf = pw.Document();

    // Load fonts (Google Noto for Unicode)
    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    // Helper: load + compress images
    Future<pw.MemoryImage?> loadAndCompressImage(String url,
        {int maxWidth = 600, int maxHeight = 600, int quality = 50}) async {
      try {
        final response = await http.get(Uri.parse("$imageFile?path=$url"));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          img.Image? image = img.decodeImage(response.bodyBytes);
          if (image != null) {
            image = img.copyResize(
              image,
              width: image.width > maxWidth ? maxWidth : image.width,
              height: image.height > maxHeight ? maxHeight : image.height,
            );
            return pw.MemoryImage(img.encodeJpg(image, quality: quality));
          }
        }
      } catch (_) {}
      return null;
    }

    // Preload all task images
    Map<DTaskModel, List<pw.MemoryImage>> taskImages = {};
    for (var task in taskList) {
      final images = <pw.MemoryImage>[];
      final docs = [task.docsType1, task.docsType2, task.docsType3];
      for (var docList in docs) {
        if (docList != null && docList.isNotEmpty) {
          for (var url in docList) {
            if (url.isNotEmpty && url != "null") {
              final imgData = await loadAndCompressImage(url);
              if (imgData != null) images.add(imgData);
            }
          }
        }
      }
      taskImages[task] = images;
    }

    // Helper to chunk lists safely
    List<List<T>> chunkList<T>(List<T> list, int chunkSize) {
      final chunks = <List<T>>[];
      for (var i = 0; i < list.length; i += chunkSize) {
        chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
      }
      return chunks;
    }

    // Helper to build a single task section
    pw.Widget buildTaskSection(DTaskModel task, List<pw.MemoryImage> images) {
      // Prepare expense data
      final expIds = task.expenseIds;
      final expAmounts = task.expenseAmount;
      final expStatus = task.expenseStatus;
      Map<String, Map<String, List<List<String>>>> expenseData = {};
      for (var id in expIds) {
        expenseData[id] = {"travel": [], "da": [], "conv": []};
      }

      // Travel, DA, Conv details
      void parseExpense(List<String>? details, String key, String delimiter) {
        if (details != null) {
          for (var block in details) {
            final groups = block.split(delimiter);
            for (var group in groups) {
              final rows = group.split("||");
              for (var row in rows) {
                final parts = row.split("|").map((e) => e.trim()).toList();
                if (parts.isNotEmpty && expenseData.containsKey(parts[0])) {
                  expenseData[parts[0]]![key]!.add(parts.sublist(1));
                }
              }
            }
          }
        }
      }

      parseExpense(task.travelDetails, "travel", "||");
      parseExpense(task.daDetails, "da", "###");
      parseExpense(task.convDetails, "conv", "###");

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Divider(),
          pw.Text(
            "Task Reports - ${task.taskDate}",
            style: pw.TextStyle(fontSize: 16, font: boldFont),
          ),
          pw.SizedBox(height: 5),
          pw.Text("Task: ${task.taskTitle}", style: pw.TextStyle(font: font)),
          pw.Text("Company: ${task.projectName}", style: pw.TextStyle(font: font)),
          pw.Text("Assigned To: ${task.assignedNames}", style: pw.TextStyle(font: font)),
          pw.Text("Created By: ${task.creator}", style: pw.TextStyle(font: font)),
          pw.SizedBox(height: 10),

          // Attendance section
          if (task.checkInTs.toString() != "null")
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Visits", style: pw.TextStyle(font: boldFont, fontSize: 14)),
                pw.SizedBox(height: 5),
                    () {
                  final inTimeList = task.checkInTs.toString().split(",");
                  final outTimeList = task.checkOutTs.toString().split(",");
                  final isCheckedOutList = task.isCheckedOut.toString().split(",");
                  final visitedRows = <List<String>>[];

                  for (var i = 0; i < inTimeList.length; i++) {
                    final inTime = inTimeList.length > i ? inTimeList[i].trim() : "";
                    final outTime = outTimeList.length > i ? outTimeList[i].trim() : "";
                    final isCheckedOut = isCheckedOutList.length > i ? isCheckedOutList[i].trim() : "";

                    String datePart = "";
                    String inTimeOnly = "";
                    String outTimeOnly = "-";

                    if (inTime.isNotEmpty) {
                      final dt = DateTime.tryParse(inTime);
                      if (dt != null) {
                        datePart = DateFormat('dd-MM-yyyy').format(dt);
                        inTimeOnly = DateFormat('hh:mm a').format(dt);
                      }
                    }

                    if (outTime.isNotEmpty && isCheckedOut == "2") {
                      final dtOut = DateTime.tryParse(outTime);
                      if (dtOut != null) {
                        outTimeOnly = DateFormat('hh:mm a').format(dtOut);
                      }
                    }

                    visitedRows.add([datePart, inTimeOnly, outTimeOnly]);
                  }

                  return pw.Table.fromTextArray(
                    headers: ['Date', 'Check-In', 'Check-Out'],
                    data: visitedRows,
                    headerStyle: pw.TextStyle(font: boldFont),
                    cellStyle: pw.TextStyle(font: font),
                    headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                  );
                }(),
              ],
            ),
          pw.SizedBox(height: 10),

          // Expense Section
          if (expenseData.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Expenses", style: pw.TextStyle(font: boldFont, fontSize: 14)),
                pw.SizedBox(height: 5),
                ...expenseData.keys.map((id) {
                  final index = expIds.indexOf(id);
                  final total = index < expAmounts.length ? expAmounts[index] : "0";
                  final status = index < expStatus.length ? expStatus[index] : "0";

                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Expense - ₹$total (${status == "0" ? "Rejected" : status == "1" ? "In Process" : "Approved"})",
                        style: pw.TextStyle(font: font),
                      ),
                      pw.SizedBox(height: 5),
                      if (expenseData[id]!["travel"]!.isNotEmpty)
                        pw.Table.fromTextArray(
                          headers: ['From', 'To', 'Start Date', 'End Date', 'Mode', 'Amount'],
                          data: expenseData[id]!["travel"]!,
                        ),
                      if (expenseData[id]!["da"]!.isNotEmpty)
                        pw.Table.fromTextArray(
                          headers: ['Day', 'Type', 'Amount'],
                          data: expenseData[id]!["da"]!,
                        ),
                      if (expenseData[id]!["conv"]!.isNotEmpty)
                        pw.Table.fromTextArray(
                          headers: ['Date', 'From', 'To', 'Mode', 'Amount'],
                          data: expenseData[id]!["conv"]!,
                        ),
                      pw.SizedBox(height: 10),
                    ],
                  );
                }),
              ],
            ),

          // Expense Images
          if (images.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Expense Documents", style: pw.TextStyle(font: boldFont, fontSize: 14)),
                pw.SizedBox(height: 5),
                ...List.generate((images.length / 3).ceil(), (rowIndex) {
                  final rowImages = images.skip(rowIndex * 3).take(3).toList();
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: rowImages
                        .map((img) => pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 5, bottom: 5),
                      child: pw.Image(img, width: 160, height: 100, fit: pw.BoxFit.contain),
                    ))
                        .toList(),
                  );
                }),
              ],
            ),
        ],
      );
    }

    // 🔹 Split tasks into chunks (avoid TooManyPagesException)
    const int chunkSize = 10; // adjust based on size (10–20 safe)
    for (int i = 0; i < taskList.length; i += chunkSize) {
      final chunk = taskList.skip(i).take(chunkSize).toList();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => chunk
              .map((task) => buildTaskSection(task, taskImages[task] ?? []))
              .toList(),
        ),
      );
    }

    Navigator.pop(context); // hide loader
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

// Helper to chunk large lists into smaller lists (to prevent too many rows in one table)
  List<List<T>> chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }


  late CalendarDataSource dataSource;
  String _year="";
  String get year=> _year;
  int total=0;

  dynamic _defaultMonth=DateTime.now().month;
  dynamic get defaultMonth =>_defaultMonth;
  String _thisMonthLeave = "0";
  String get thisMonthLeave=>_thisMonthLeave;

  int _filterTasks = 0;
  int get filterTasks=>_filterTasks;
  List<HolyDaysModel> _fixedLeaves= <HolyDaysModel>[];
  List<HolyDaysModel> get fixedLeaves=> _fixedLeaves;
  List<TaskData> get filteredTasks {
    return _allTasks.where((task) {
      String dateStr = task.taskDate ?? "";
      DateTime st = DateFormat('dd-MM-yyyy').parse(dateStr);

      bool sameMonth = utils.returnPadLeft(defaultMonth.toString()) ==
          utils.returnPadLeft(st.month.toString());

      bool dateMatch = (filterDate == "" || filterDate == dateStr);

      return sameMonth && dateMatch;
    }).toList();
  }
  void checkMonth(ViewChangedDetails details){
    _filterDate="";
    // _filterTasks=0;
    _defaultMonth =details.visibleDates[15].month;
    var count = 0;
    for (var i = 0; i <_allTasks.length; i++) {
      String dateStr = _allTasks[i].taskDate.toString(); // "24-05-2025"
      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(dateStr);
      var st = parsedDate;
      if (utils.returnPadLeft(_defaultMonth.toString()) ==
          utils.returnPadLeft(st.month.toString())) {
        count++;
      }
    }
    _thisMonthLeave = count.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    print("_filterDate22 ${_filterDate}");

  }
  void changeMonth(dynamic value){
    _defaultMonth = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  void checkMonth2(){
    var count = 0;
    for (var i = 0; i <_allTasks.length; i++) {
      if (_filterDate==_allTasks[i].taskDate.toString()) {
        count++;
      }
    }
    _filterTasks = count;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    // print("_filterDate ${_filterDate}");
  }

  String _filterDate = "";
  String get filterDate=>_filterDate;
  void filterDateList(String value,DateTime dateTime){
    _filterDate=value;
    _selectedDate = dateTime;
    print(_filterDate);
    print(_selectedDate);
    notifyListeners();
  }

  var _statusT;
  String _filter="1";
  String statusId="";
  int matched=0;
  get statusT => _statusT;
  String get filter => _filter;
  void changeFilterStatus(dynamic value) {
    _status=value;
    statusId="";
    matched=0;
    print(value);
    var list = [];
    list.add(value);
    statusId = list[0]["value"];
    for(var i=0;i<_allTasks.length;i++){
      if(statusId==_allTasks[i].statval){
        matched++;
      }
    }
    notifyListeners();
  } void changeFilter(String value) {
    _filter = value;
    notifyListeners();
  } void changeStatusT(String value) {
    _statusT = value;
    notifyListeners();
  }
  void setStatus(String value) {
    for(var i=0;i<statusList.length;i++){
      if(statusList[i]["value"]==value){
        statusController = GroupButtonController(selectedIndex: i);
      }
    }
    notifyListeners();
  }

  TextEditingController search     = TextEditingController();
  TextEditingController search2     = TextEditingController();
  TextEditingController taskTitleCont     = TextEditingController();
  TextEditingController projectNameCont   = TextEditingController();
  TextEditingController departmentCont    = TextEditingController();
  TextEditingController projectSearchCont = TextEditingController();
  TextEditingController taskDt = TextEditingController();
  List<TextEditingController> fileNameCont  = <TextEditingController>[];
  void searchTask(String value){
    if(_isFilter==false){
      final suggestions=_filterUserData.where(
              (user){
            final userFName=user.projectName.toString().toLowerCase();
            final userNumber = user.assignedNames.toString().toLowerCase();
            final input=value.toString().toLowerCase();
            return userFName.contains(input) || userNumber.contains(input);
          }).toList();
      _filterUserData=suggestions;
    }else{
      final suggestions=_filterUserData.where(
              (user){
            final userFName=user.projectName.toString().toLowerCase();
            final userNumber = user.assignedNames.toString().toLowerCase();
            final input=value.toString().toLowerCase();
            return userFName.contains(input) || userNumber.contains(input);
          }).toList();
      _filterUserData=suggestions;
    }
    if(value.isEmpty){
      filterList();
    }
    // _allTasks=suggestions;
    notifyListeners();
  }
  void searchTask2(String value){
    _filterTasks=0;
    final suggestions=_searchAllTasks.where(
            (user){
          final userFName=user.projectName.toString().toLowerCase();
          final userNumber = user.assignedNames.toString().toLowerCase();
          final input=value.toString().toLowerCase();
          return userFName.contains(input) || userNumber.contains(input);
        }).toList();
    _allTasks=suggestions;
    _filterTasks=_taskList.length;
    if(value.isEmpty){
      _filterTasks=_searchAllTasks.length;
    }
    notifyListeners();
  }
  String _signPrefix = "Mr";
  String _assignedId = "";
  String _assName = "";
  String get assName => _assName;
  String _assignedNames = "";
  String get assignedNames => _assignedNames;

  String _cusId = "";
  String _cusName = "";
  String get cusId => _cusId;
  String get cusName => _cusName;
  var _title;
  var _department;
  var _type;
  var _status;
  bool _isUpdate=false;
  String _level = "Normal";
  String _taskSDate = "";
  String _taskEDate = "";
  String _taskSTime = "";
  String _taskETime = "";
  String _changeTaskStatus = "";

  bool get isUpdate => _isUpdate;
  void updateChanges(){
    _isUpdate=true;
    notifyListeners();
  }
  String get signPrefix => _signPrefix;
  String get assignedId => _assignedId;
  get title => _title;
  get department => _department;
  get type => _type;
  get status => _status;
  String get level => _level;
  String get taskSDate => _taskSDate;
  String get taskEDate => _taskEDate;
  String get taskSTime => _taskSTime;
  String get taskETime => _taskETime;
  String get changeTaskStatus => _changeTaskStatus;

  var prefix = ["Mr", "Mrs", "Dr", "Ms"];
  List<String> titleList = [
    "Bug Report",
    "UI Update",
    "API Integration",
    "Issue Fix"
  ];
  var departmentList = ["UI/UX Design", "Development", "Testing","HR"];
  // var statusList = ["Assigned", "In-Queue", "Started", "On Hold", "New Issues"];
  var fullStatusList = [
    "Assigned",
    "In-Queue",
    "Started",
    "On Hold",
    "New Issues",
    "Cancelled",
    "Completed"
  ];

  void changeSignPrefix(String value) {
    _signPrefix = value;
    notifyListeners();
  }

  void changedTaskStatus(String value) {
    _changeTaskStatus = value;
    notifyListeners();
  }

  // void changeAssignedIs(context, List<dynamic> names) {
  //   List<String> ids = [];
  //   var list = Provider.of<EmployeeProvider>(context, listen: false).filterUserData;
  //
  //   for (var name in names) {
  //     var found = list.firstWhere(
  //           (element) => element.firstname.toString().trim().toLowerCase() == name.toString().trim().toLowerCase(),
  //       orElse: () => UserModel(id: "0", firstname: ''), // use valid default
  //     );
  //
  //     if (found.id != 0) {
  //       ids.add(found.id.toString());
  //     }
  //   }
  //
  //   _assignedId = ids.join(",");
  //   print("assign $_assignedId");
  //   notifyListeners();
  // }
  void changeAssignedIs(context, List<dynamic> names) {
    List<String> ids = [];
    List<String> selectedNames = [];

    var list = Provider.of<EmployeeProvider>(context, listen: false).activeEmps;

    for (var name in names) {
      var found = list.firstWhere(
            (element) => element.firstname.toString().trim().toLowerCase() == name.toString().trim().toLowerCase(),
        orElse: () => UserModel(id: "0", firstname: ''),
      );

      if (found.id != "0") {
        ids.add(found.id.toString());
        selectedNames.add(found.firstname.toString()); // save the matched name
      }
    }

    _assignedId = ids.join(",");
    _assignedNames = selectedNames.join(", "); // <- add this line to save names

    print("Assigned IDs: $_assignedId");
    print("Assigned Names: $_assignedNames");

    notifyListeners();
  }

  void changeTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void changeDepartment(String value) {
    _department = value;
    notifyListeners();
  }

  void changeType(dynamic value) {
    _type = value;
    // print(value);
    // var list = [];
    // list.add(value);
    localData.storage.write("type_id", value);
    notifyListeners();
  }

  void changeStatus(dynamic value) {
    _status = value;
    var list = [];
    list.add(value);
    localData.storage.write("status_id", list[0]["id"]);
    notifyListeners();
  }
  void setStatusByName(String value) {
    // // Find the map where name matches
    // final selectedStatus = statusList.firstWhere(
    //       (status) => status["value"] == value,
    //   orElse: () => {"id": "0", "value": "Unknown"},
    // );
    //
    // _status = selectedStatus;
    //
    // localData.storage.write("status_id", selectedStatus["id"]);
    _isUpdate=false;
    notifyListeners();
  }
  void changeLevel(String value) {
    _level = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> _selectedFiles = [];

  List<Map<String, dynamic>> get selectedFiles => _selectedFiles;
  final ImagePicker picker = ImagePicker();

  /// Pick Image or File from Gallery
  Future<void> pickFile() async {
    final List<XFile> files = await picker.pickMultiImage();

    if (files.isNotEmpty) {
      for (XFile file in files) {
        final int fileSizeBytes = File(file.path).lengthSync();
        final String formattedSize = formatFileSize(fileSizeBytes);

        _selectedFiles.add({
          'name': file.name,
          'size': formattedSize,
          'path': file.path,
        });
        fileNameCont.add(TextEditingController());
      }

      notifyListeners();
    }
  }

  /// Format file size dynamically (KB or MB)
  String formatFileSize(int bytes) {
    double kb = bytes / 1024;
    if (kb < 1024) {
      return "${kb.toStringAsFixed(2)} KB";
    } else {
      double mb = kb / 1024;
      return "${mb.toStringAsFixed(2)} MB";
    }
  }

  /// Remove File from List
  void removeFile(int index) {
    _selectedFiles.removeAt(index);
    fileNameCont.removeAt(index);
    notifyListeners();
  }

  void removeVideo(int index) {
    _videos.removeAt(index);
    notifyListeners();
  }

  List<String> _assignList = [];
  List<String> get assignList => _assignList;

  List<Map<String, dynamic>> _assignItems = [
    {'name': 'Selvi', 'selected': false},
    {'name': 'Priya Mehra', 'selected': false},
    {'name': 'Aditya Singh', 'selected': false},
    {'name': 'Meera Nair', 'selected': false},
  ];

  List<Map<String, dynamic>> get assignItems => _assignItems;

  String get selectedItemsText {
    final selectedNames = _assignItems
        .where((item) => item['selected'])
        .map((item) => item['name'])
        .toList();
    return selectedNames.isEmpty
        ? 'Select Assignees'
        : selectedNames.join(', ');
  }

  void toggleSelectAll(bool? isSelected) {
    for (var item in _assignItems) {
      item['selected'] = isSelected ?? false;
    }
    notifyListeners();
  }

  void toggleItem(int index, bool? isSelected) {
    _assignItems[index]['selected'] = isSelected ?? false;
    notifyListeners();
  }

  final AudioRecorder _record = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();

  String? _audioPath;
  String? _currentlyPlayingPath;
  bool _isRecording = false;
  bool _isPlaying = true;
  bool _isVedioPlaying = false;
  bool _isLoading = false;
  bool _isProjectLoading = false;
  bool _isDepartmentLoading = false;
  bool _isTaskLoading = false;
  bool _isError = false;
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void datePick({required BuildContext context, required TextEditingController date}) {
    DateTime dateTime = DateTime.now();

    showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(1920),
      lastDate: DateTime(3000),
    ).then((value) {
      if (value != null) {
        String formattedDate = "${value.day.toString().padLeft(2, "0")}-"
            "${value.month.toString().padLeft(2, "0")}-"
            "${value.year.toString()}";
        date.text = formattedDate;
        notifyListeners();
      }
    });
  }

  Future<void> customTimePicker({
    required BuildContext context,
    required bool isStartTime,
  }) async {
    TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          );
        });
    if (time != null) {
      var selectedTime = _formatTime12Hour(time, context);
      if (isStartTime) {
        _taskSTime = selectedTime.toString();
      } else {
        _taskETime = selectedTime.toString();
      }
      notifyListeners();
    }
  }

  String _formatTime12Hour(TimeOfDay time, BuildContext context) {
    int hour = time.hourOfPeriod;
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';

    String hourStr = hour.toString().padLeft(2, '0');
    String minuteStr = time.minute.toString().padLeft(2, '0');

    return '$hourStr:$minuteStr $period';
  }

  String? get currentlyPlayingPath => _currentlyPlayingPath;
  String? get audioPath => _audioPath;
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  bool get isVideoPlaying => _isVedioPlaying;
  bool get isLoading => _isLoading;
  bool get isProjectLoading => _isProjectLoading;
  bool get isDepartmentLoading => _isDepartmentLoading;
  bool get isTaskLoading => _isTaskLoading;
  bool get isError => _isError;
  double _recordingDuration = 0.0;
  double get recordingDuration => _recordingDuration;

  Duration _position = Duration.zero;
  Duration? _duration;

  Duration get position => _position;
  Duration? get duration => _duration;

  Timer? timer;
  late DateTime _startTime;

  final List<String> _videos = [];

  List<String> get videos => _videos;
  List<TaskData> get _taskList {
    return _allTasks.where((task) {
      String dateStr = task.taskDate ?? "";
      DateTime st = DateFormat('dd-MM-yyyy').parse(dateStr);

      bool sameMonth = utils.returnPadLeft(defaultMonth.toString()) ==
          utils.returnPadLeft(st.month.toString());

      bool dateMatch = (filterDate == "" || filterDate == dateStr);

      // return sameMonth;
      return sameMonth && dateMatch;
    }).toList();
  }

  List<String> _projectDropList = [];
  List<DepResponse> _departmentList = [];
  //List<Response> get taskList => _taskList;
  List<TaskData> get taskList => _taskList;
  List<String>  get projectDropList => _projectDropList;
  List<DepResponse> get serverDepartmentList => _departmentList;
  List<TaskResponse> _taskDetailsList = [];
  List<TaskResponse> get taskDetailsList => _taskDetailsList;
  List<dynamic> _userNameList = [];
  List<dynamic> get userNameList => _userNameList;

  String _recordingTime = "";
  String formatDurationTime(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    return formatTime(hours: hours,minutes: minutes,seconds: secs);
  }
  String formatTime({
    required int hours,
    required int minutes,
    required int seconds,
  }) {
    if (hours > 0) {
      // hours irundha → h.m.s
      return "$hours.$minutes.$seconds";
    } else if (minutes > 0) {
      // minutes irundha → m.s
      return "$minutes.$seconds";
    } else {
      // only seconds → 0.s
      return "0.$seconds";
    }
  }
  Future<void> pickedVideo() async {
    final XFile? recordedFile =
    await picker.pickVideo(source: ImageSource.gallery);
    if (recordedFile != null) {
      // print("Path ${recordedFile.path}");
      //String url = await _taskRepo.insertVideoApi(video: recordedFile.path);
      _videos.add(recordedFile.path);
    }
    notifyListeners();
  }

  Future<VideoPlayerController> initializeVideoController(String path) async {
    try {
      final controller = VideoPlayerController.file(File(path));
      await controller.initialize();
      await controller.pause(); // Keep the video in a paused state
      return controller;
    } catch (e) {
      throw "Video error";
    }
  }

  List<AddAudioModel> _recordedAudioPaths = [];
  List<AddAudioModel> get recordedAudioPaths => _recordedAudioPaths;

  /// Start Recording
  // Future<void> startRecording() async {
  //   HapticFeedback.heavyImpact();
  //
  //   try {
  //     if (await _record.hasPermission()) {
  //       // print("Audio Start");
  //       final dir = await getApplicationDocumentsDirectory();
  //       String path =
  //           "${dir.path}/recorded_audio_${DateTime.now().millisecondsSinceEpoch}.m4a";
  //       await _record.start(const RecordConfig(), path: path);
  //
  //       _isRecording = true;
  //       _startTime = DateTime.now();
  //       _recordingDuration = 0.0;
  //
  //       timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
  //         final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
  //         _recordingDuration = elapsed / 1000; // Convert to seconds
  //         notifyListeners();
  //       });
  //     }
  //   } catch (e) {
  //     log("Error in startRecording: $e");
  //   }
  //   notifyListeners();
  // }
  Future<void> startRecording() async {
    if (_isRecording) return; // Prevent duplicate starts

    HapticFeedback.heavyImpact();

    try {
      if (await _record.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        String path =
            "${dir.path}/recorded_audio_${DateTime.now().millisecondsSinceEpoch}.m4a";

        await _record.start(const RecordConfig(), path: path);

        _isRecording = true;
        _startTime = DateTime.now();
        _recordingDuration = 0.0;
        _recordingTime ="";
        timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
          _recordingTime = formatDurationTime(elapsed);
          _recordingDuration = elapsed / 1000;
          notifyListeners();
        });

        notifyListeners();
      }
    } catch (e) {
      log("Error in startRecording: $e");
    }
  }

  /// Stop Recording
  // Future<void> stopRecording() async {
  //   try {
  //     final path = await _record.stop();
  //     if (path != null) {
  //       _isRecording = false;
  //       _recordedAudioPaths
  //           .add(AddAudioModel(audioPath: path, second: _recordingDuration));
  //       await Future.delayed(Duration(seconds: 1));
  //       loadAudioDuration(path);
  //     }
  //     timer?.cancel();
  //     // print("_recordedAudioPaths: ${_recordedAudioPaths.last.second}");
  //   } catch (e) {
  //     // print("Error in stopRecording: $e");
  //   }
  //   notifyListeners();
  // }
  Future<void> stopRecording() async {
    if (!_isRecording) return; // Prevent stop if not recording

    try {
      final path = await _record.stop();

      if (path != null) {
        _isRecording = false;
        timer?.cancel();

        _recordedAudioPaths.add(
          AddAudioModel(audioPath: path, second: _recordingDuration, time: _recordingTime),
        );

        await Future.delayed(Duration(seconds: 1)); // Optional delay
        loadAudioDuration(path);
      }
    } catch (e) {
      log("Error in stopRecording: $e");
    }

    notifyListeners();
  }

  void removeAudio(int index) {
    _recordedAudioPaths.removeAt(index);
    notifyListeners();
  }

  // Future<void> playAudio(String audioPath, int index) async {
  //   if (audioPath.isNotEmpty) {
  //     _isPlaying = true;
  //     _recordedAudioPaths[index].play = true;
  //     notifyListeners();
  //
  //     audioPlayer.onDurationChanged.listen((durationV) {
  //       _duration = durationV;
  //       notifyListeners();
  //     });
  //
  //     audioPlayer.onPositionChanged.listen((positionV) {
  //       _position = positionV;
  //       notifyListeners();
  //     });
  //
  //     audioPlayer.onPlayerComplete.listen((event) {
  //       _isPlaying = false;
  //       _position = Duration.zero;
  //       _recordedAudioPaths[index].play = false;
  //       notifyListeners();
  //     });
  //
  //     try {
  //       await audioPlayer.play(DeviceFileSource(audioPath));
  //     } catch (e) {
  //       _isPlaying = false;
  //       _recordedAudioPaths[index].play = false;
  //       // print("Audio play error: $e");
  //       notifyListeners();
  //     }
  //   }
  // }
  Future<void> playAudio(String audioPath, int index) async {
    if (audioPath.isNotEmpty) {
      // Reset all to false
      for (var i = 0; i < _recordedAudioPaths.length; i++) {
        _recordedAudioPaths[i].play = false;
      }

      _isPlaying = true;
      _recordedAudioPaths[index].play = true;
      notifyListeners();

      // Remove old subscriptions
      audioPlayer.onDurationChanged.listen(null);
      audioPlayer.onPositionChanged.listen(null);
      audioPlayer.onPlayerComplete.listen(null);

      audioPlayer.onDurationChanged.listen((durationV) {
        _recordedAudioPaths[index].duration = durationV;
        notifyListeners();
      });

      audioPlayer.onPositionChanged.listen((positionV) {
        _recordedAudioPaths[index].position = positionV;
        notifyListeners();
      });

      audioPlayer.onPlayerComplete.listen((event) {
        _isPlaying = false;
        _recordedAudioPaths[index].position = Duration.zero;
        _recordedAudioPaths[index].play = false;
        notifyListeners();
      });

      try {
        await audioPlayer.play(DeviceFileSource(audioPath));
      } catch (e) {
        _isPlaying = false;
        _recordedAudioPaths[index].play = false;
        notifyListeners();
      }
    }
  }

  Future<void> stopAudio() async {
    await audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> loadAudioDuration(String url) async {
    try {
      await audioPlayer.setSourceUrl(url);
      Duration? fetchedDuration = await audioPlayer.getDuration();
      if (fetchedDuration != null) {
        _duration = fetchedDuration;
        // print("Duration $duration");
      }
    } catch (e) {
      // print("Error fetching duration: $e");
    }
    notifyListeners();
  }


  String calculateDueDays(String dateRange,
      {String? timeRange, String? updatedDate, String? status}) {
    try {
      List<String> dates = dateRange.split("||");
      DateTime endDate = DateFormat("dd-MM-yyyy").parse(dates[1].trim());

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime taskEndDate = DateTime(endDate.year, endDate.month, endDate.day);

      if (status == "Completed") {
        String updateDateStr = updatedDate.toString();
        DateTime updateDate = DateTime.parse(updateDateStr);
        int diffDays = updateDate.difference(taskEndDate).inDays;
        if (diffDays > 0) {
          return "Completed - Extra $diffDays days";
        } else {
          return "Completed";
        }
      }

      // Check if today is same as end date
      if (taskEndDate == today && timeRange != null && timeRange.contains("||")) {
        List<String> times = timeRange.split("||");

        String endTimeStr = times[1].trim();
        // print("end $endTimeStr");
        if (endTimeStr.isEmpty) {
          endTimeStr = "11:59 PM"; // Default fallback time
        }

        DateTime parsedEndTime = DateFormat("hh:mm a").parse(endTimeStr);

        DateTime endTime = DateTime(
          today.year,
          today.month,
          today.day,
          parsedEndTime.hour,
          parsedEndTime.minute,
        );

        if (now.isAfter(endTime)) {
          return "Overdue";
        } else {
          int remainingMinutes = endTime.difference(now).inMinutes;
          int hours = remainingMinutes ~/ 60;
          int minutes = remainingMinutes % 60;

          return hours == 0
              ? "$minutes minutes left"
              : "$hours hours $minutes minutes left";
        }
      }

      if (taskEndDate.isBefore(today)) {
        return "Overdue";
      }

      int remainingDays = taskEndDate.difference(today).inDays;
      return "$remainingDays days left";
    } catch (e) {
      return "Invalid Input";
    }
  }
  bool _refresh = true;
  bool get refresh =>_refresh;

  bool _viewRefresh = true;
  bool get viewRefresh =>_viewRefresh;
  List<TaskData> _allTasks = <TaskData>[];
  List<TaskData> _searchAllTasks = <TaskData>[];
  List<TaskData> get allTasks => _allTasks;
  List<TaskData> get searchAllTasks => _searchAllTasks;
  List<UserModel> assignEmployees=[];
  List historyDetails=[];

  Future<void> getTaskUsers() async {
    try {
      Map data = {
        "action": getAllData,
        "search_type": "task_users",
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
      };
      final response =await _taskRepo.getUsers(data);
      // log(response.toString());
      if (response.isNotEmpty) {
        assignEmployees=[];
        assignEmployees=response;
      }else{
        assignEmployees=[];
      }
    } catch (e) {
      assignEmployees=[];
      log(e.toString());
    }
    notifyListeners();
  }
  Future<void> getStatusHistory(String taskId) async {
    try {
      historyDetails.clear();
      Map data = {
        "action": taskDatas,
        "search_type": "task_status_history",
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
        "id":localData.storage.read("id"),
        "task_id":taskId,
      };
      final response =await _taskRepo.getTasks(data);
      log(response.toString());
      if (response.isNotEmpty) {
        historyDetails=response;
      }else{
        historyDetails=[];
      }
    } catch (e) {
      historyDetails=[];
      log(e.toString());
    }
    notifyListeners();
  }

  void initValue(){
    _isRecording = false;
    _selectedFiles.clear();
    _recordedAudioPaths.clear();
    selectedPhotos.clear();
    taskTitleCont.clear();
    _type=null;
    _status=null;
    _assignedId="";
    _level="Normal";
    if(typeList.isNotEmpty){
      _type=typeList[0]["id"];
    }
    final selectedStatus = statusList.firstWhere(
            (status) => status["value"] == "Assigned",
        orElse: () => {"id": "0", "value": "Unknown"}
    );
    _status = selectedStatus;
    localData.storage.write("status_id", selectedStatus["id"]);
    taskDt.text="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
    notifyListeners();
  }
  void initEditValue(context,TaskData data){

    taskTitleCont.text=data.taskTitle.toString();
    _level=data.level.toString();
    taskDt.text=data.taskDate.toString();
    _assignedId=data.assigned.toString();
    _assName=data.assignedNames.toString();
    _cusId=data.companyId.toString();
    _cusName=data.projectName.toString();
    _status=null;
    _type=null;
    notifyListeners();
    final selectedStatus = statusList.firstWhere(
            (status) => status["value"] == data.statval,
        orElse: () => {"id": "0", "value": "Unknown"}
    );
    _status = selectedStatus;
    localData.storage.write("status_id", selectedStatus["id"]);

    // final selectedType = typeList.firstWhere(
    //       (status) => status["value"] == data.type, // Matching condition
    //   orElse: () => {"id": typeList[0]["id"], "value": typeList[0]["value"]}, // Default if not found
    // );
    final selectedType = typeList.firstWhere(
          (status) => status["value"] == data.type,
      orElse: () => <String, String>{
        "id": typeList.isNotEmpty ? typeList[0]["id"]! : "",
        "value": typeList.isNotEmpty ? typeList[0]["value"]! : "",
      },
    );



// Set the selected type
    _type = selectedType["id"];

// Save the ID in local storage
    localData.storage.write("type_id", selectedType["id"]);

    changeAssignedIs(context,data.assignedNames.toString().split(","));
    notifyListeners();
  }
  Future<void> addTask({context,required String id}) async {
    try {
      List<Map<String, String>> customersList = [];

// Loop for selected files
      for (int i = 0; i < _selectedFiles.length; i++) {
        // print("////$i");
        customersList.add({
          "image_$i": _selectedFiles[i]['path'],
        });
      }

// Loop for recorded audio paths
      for (int i = _selectedFiles.length; i < _selectedFiles.length + _recordedAudioPaths.length; i++) {
        // print("----$i");
        customersList.add({
          "image_$i": _recordedAudioPaths[i - _selectedFiles.length].audioPath, // Adjust index
        });
      }

// Loop for selected photos
      for (int i = _selectedFiles.length + _recordedAudioPaths.length; i < _selectedFiles.length + _recordedAudioPaths.length + selectedPhotos.length; i++) {
        // print("]]]]$i");
        customersList.add({
          "image_$i": selectedPhotos[i - (_selectedFiles.length + _recordedAudioPaths.length)], // Adjust index
        });
      }

      String jsonString = json.encode(customersList);
      Map<String, String> data = {
        'project_name': id,
        'task_title': taskTitleCont.text.trim(),
        'department': departmentCont.text.trim(),
        'log_file': localData.storage.read("mobile_number"),
        'type': _type.toString(),
        'assigned': assignedId,
        'level': level,
        'status': localData.storage.read("status_id"),
        'user_id': localData.storage.read("id"),
        'task_date': taskDt.text.trim(),
        'task_time': "$taskSTime||$taskETime",
        'action': adTask,
        'cos_id': localData.storage.read("cos_id"),
        "data": jsonString,
      };
      final response =await _taskRepo.addTask(data,customersList);
      log(response.toString());
      if (response.toString().contains("200")){
        utils.showSuccessToast(context: context,text: constValue.success,);
        try {
          await Provider.of<EmployeeProvider>(context, listen: false)
              .sendSomeUserNotification(
            "A new task has been assigned to you by (${localData.storage.read("f_name")})",
            taskTitleCont.text.trim(),
            _assignedId,
          );
        } catch (e) {
          print("User notification error: $e");
        }

        // admin notification (always run)
        try {
          await Provider.of<EmployeeProvider>(context, listen: false)
              .sendAdminNotification(
            "A new task has been assigned to $assignedNames.",
            taskTitleCont.text.trim(),
            localData.storage.read("role"),
          );
        } catch (e) {
          print("Admin notification error: $e");
        }
        taskCtr.reset();
        await FirebaseFirestore.instance.collection('attendance').add({
          'emp_id': localData.storage.read("id"),
          'time': DateTime.now(),
          'status': "",
        });
        // getAllTask(true);
        utils.navigatePage(context, ()=> DashBoard(child: ViewTask(date1: Provider.of<HomeProvider>(context, listen: false).startDate, date2: Provider.of<HomeProvider>(context, listen: false).endDate, type: Provider.of<HomeProvider>(context, listen: false).type)));
        // Future.microtask(() => Navigator.pop(context));
      }else {
        utils.showErrorToast(context: context);
        taskCtr.reset();
      }
    } catch (e) {
      utils.showWarningToast(context,text: e.toString());
      taskCtr.reset();
    }
    notifyListeners();
  }
  Future<void> updateTaskDetail(context,{required String taskId,required String id,required bool isDirect,required List numberList,required String companyName}) async {
    try {
      Map<String, String> data = {
        'id': taskId,
        'project_name': id,
        'task_title': taskTitleCont.text.trim(),
        'department': departmentCont.text.trim(),
        'log_file': localData.storage.read("mobile_number"),
        'type': localData.storage.read("type_id"),
        'assigned': assignedId,
        'level': level,
        'status': localData.storage.read("status_id"),
        'user_id': localData.storage.read("id"),
        'task_date': taskDt.text.trim(),
        'task_time': "$taskSTime||$taskETime",
        'action': updateTask,
        'cos_id': localData.storage.read("cos_id"),
      };
      final response =await _taskRepo.updateTask(data);
      // print(data.toString());
      log(response.toString());
      if (response.toString().contains("200")){
        utils.showSuccessToast(context: context,text: constValue.updated,);
        try {
          await Provider.of<EmployeeProvider>(context, listen: false).sendSomeUserNotification(
            "Task detail updated by (${localData.storage.read("f_name")})",
            taskTitleCont.text.trim(),
            assignedId,
          );
        } catch (e) {
          print("User notification error: $e");
        }

        // admin notification (always run)
        try {
          await Provider.of<EmployeeProvider>(context, listen: false).sendAdminNotification(
            "Task detail updated by (${localData.storage.read("f_name")})",
            taskTitleCont.text.trim(),
            localData.storage.read("role"),
          );
        } catch (e) {
          print("Admin notification error: $e");
        }
        taskCtr.reset();
        await FirebaseFirestore.instance.collection('attendance').add({
          'emp_id': localData.storage.read("id"),
          'time': DateTime.now(),
          'status': "",
        });
        Provider.of<HomeProvider>(context, listen: false).getMainReport(false);
        if(isDirect==true){
          utils.navigatePage(context, ()=> DashBoard(child: ViewTask(date1: Provider.of<HomeProvider>(context, listen: false).startDate, date2: Provider.of<HomeProvider>(context, listen: false).endDate, type: Provider.of<HomeProvider>(context, listen: false).type)));
        }else{
          utils.navigatePage(context, ()=> DashBoard(child:
          ViewTasks(coId:cusId,numberList: numberList, companyName: companyName)));
        }
      }else {
        utils.showErrorToast(context: context);
        taskCtr.reset();
      }
    } catch (e) {
      utils.showWarningToast(context,text: "Failed",);
      taskCtr.reset();
    }
    notifyListeners();
  }
  Future<void> updateLevelDetail(context,{required String id,required String level}) async {
    try {
      Map<String, String> data = {
        'id': id,
        'level': level,
        'user_id': localData.storage.read("id"),
        'action': updateLevel,
        'cos_id': localData.storage.read("cos_id"),
        'log_file': localData.storage.read("mobile_number"),
      };
      final response =await _taskRepo.updateTask(data);
      print(data.toString());
      log(response.toString());
      if (response.toString().contains("200")){
        utils.showSuccessToast(context: context,text: constValue.updated,);
        taskCtr.reset();
        getAllTask(false);
      }else {
        utils.showErrorToast(context: context);
        taskCtr.reset();
      }
    } catch (e) {
      utils.showWarningToast(context,text: "Failed",);
      taskCtr.reset();
    }
    notifyListeners();
  }

  List<CustomerAttendanceModel> _customerAttendanceReport = <CustomerAttendanceModel>[];
  List<CustomerAttendanceModel> get customerAttendanceReport=>_customerAttendanceReport;

  Future<void> getAttendance(String id) async {
    _refresh=false;
    _customerAttendanceReport.clear();
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type":"task_visits",
        "task_id":id,
        "id":localData.storage.read("id"),
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
      };
      final response =await _taskRepo.getAttendances1(data);
      log(data.toString());
      log(response.toString());
      if (response.isNotEmpty) {
        _customerAttendanceReport=response;
        _refresh=true;
      } else {
        _refresh=true;
      }
    } catch (e) {
      _refresh=true;
    }
    notifyListeners();
  }
  Future<void> getUserTaskAttendance(String id,String date1,String date2) async {
    _refresh=false;
    _customerAttendanceReport.clear();
    notifyListeners();
    try {
      Map data = {
        "action": taskDatas,
        "search_type":"emp_visits_details",
        "id":localData.storage.read("role")=="1"?id:localData.storage.read("id"),
        "date1":date1,
        "date2":date2,
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
      };
      final response =await _taskRepo.getAttendances(data);
      log(data.toString());
      log(response.toString());
      if (response.isNotEmpty) {
        _customerAttendanceReport=response;
        _refresh=true;
      } else {
        _refresh=true;
      }
    } catch (e) {
      _refresh=true;
    }
    notifyListeners();
  }
  Future<void> getCustomerTaskAttendance(String id,String date1,String date2) async {
    _refresh=false;
    _customerAttendanceReport.clear();
    notifyListeners();
    try {
      Map data = {
        "action": taskDatas,
        "search_type":"customer_visits_details",
        "id":id,
        "date1":date1,
        "date2":date2,
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
        "user_id":localData.storage.read("role")=="1"?id:localData.storage.read("id"),
      };
      final response =await _taskRepo.getAttendances(data);
      log(data.toString());
      log(response.toString());
      if (response.isNotEmpty) {
        _customerAttendanceReport=response;
        _refresh=true;
      } else {
        _refresh=true;
      }
    } catch (e) {
      _refresh=true;
    }
    notifyListeners();
  }
  String crtDate(String dateTimeString, String type) {
    var parts = dateTimeString.split(' ');
    var dateParts = parts[0].split('-'); // Split the date into year, month, and day
    var formattedDate = "${dateParts[2]}/${dateParts[1]}/${dateParts[0]}"; // Reorder to dd-MM-yyyy

    var timeParts = parts[1].split(':');
    int hour = int.parse(timeParts[0]);
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12 == 0 ? 12 : hour % 12;

    if (type == "1") {
      return formattedDate;
    } else {
      return "$hour:${timeParts[1]} $period";
    }
  }

  Future<void> editTask({context,required TaskData data,required String taskId,required String coId,required bool isDirect}) async {
    try {
      // Map<String, String> data = {
      //   "user_id": localData.storage.read("id"),
      //   "action": "update_status",
      //   "task_id": taskId,
      //   "status": status,
      //   "mobile": localData.storage.read("mobile_number"),
      //   'cos_id': localData.storage.read("cos_id")
      // };
      final response =await _taskRepo.updateTaskStatusApi(taskId: taskId, status: localData.storage.read("status_id"));
      print(response.toString());
      if (response.toString().contains("200")){
        utils.showSuccessToast(context: context,text: constValue.updated,);
        taskCtr.reset();
        Provider.of<HomeProvider>(context, listen: false).getMainReport(false);
        getAllTask(false);
        TaskData? sentData;
        for(var i=0;i<_allTasks.length;i++){
          if(_allTasks[i].id==data.id){
            sentData=_allTasks[i];
            break;
          }
        }
        utils.navigatePage(context, ()=>DashBoard(child: TaskDetails(
            data:sentData!,isDirect:true,coId: "0", numberList: const [])));
        // Future.microtask(() => Navigator.pop(context));
      }else {
        utils.showErrorToast(context: context);
        taskCtr.reset();
      }
    } catch (e) {
      utils.showWarningToast(context,text: "Failed",);
      taskCtr.reset();
    }
    notifyListeners();
  }
  Future<void> getAllCoTask(String coId,bool isRefresh) async {
    if(isRefresh==true){
      _filter="1";
      statusId="";
      matched=0;
      _status=null;
      search.clear();
      _allTasks.clear();
      _searchAllTasks.clear();
      _refresh=false;
    }
    notifyListeners();
    try {
      Map data = {
        "action": taskDatas,
        "search_type":"co_tasks",
        "co_id":coId,
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "id": localData.storage.read("id")
      };
      final response =await _taskRepo.getReport(data);
      // print(data.toString());
      // print(response.toString());
      if (response.isNotEmpty) {
        _allTasks=response;
        _searchAllTasks=response;
        _refresh=true;
      }
    } catch (e) {
      _allTasks=[];
      _searchAllTasks=[];
      _refresh=true;
    }
    notifyListeners();
  }
  String _profile="";
  String get profile=>_profile;
  Future<void> signDialog({required BuildContext context, required String img,required Function(String newImg) onTap}) async {
    _profile="";
    var imgData = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const CameraWidget(
              cameraPosition: CameraType.front,
              isSelfie: true,
            )));
    if (!context.mounted) return;
    // Navigator.pop(context);
    if (imgData != null) {
      final compressedFile = await compressImage(imgData);
      onTap(compressedFile.path);
    }
  }
  Future<XFile> compressImage(String filePath) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.absolute.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: 70, // lower = more compressed
    );

    return result!;
  }
  void profilePick(String imgData){
    _profile = imgData;
    notifyListeners();
  }
  bool hasAppointment(DateTime date) {
    return dataSource.appointments!.any((appt) =>
    appt.startTime.year == date.year &&
        appt.startTime.month == date.month &&
        appt.startTime.day == date.day);
  }
  bool hasStatus(DateTime date, String status) {
    return dataSource.appointments!.any((appt) =>
    appt.startTime.year == date.year &&
        appt.startTime.month == date.month &&
        appt.startTime.day == date.day &&
        (appt.subject?.toLowerCase() ?? '') == status.toLowerCase());
  }
  String _checkAtt="";
  String _checkAttName="";
  String get checkAtt => _checkAtt;
  String get checkAttName => _checkAttName;
  List<TaskData> _filterUserData = <TaskData>[];
  List<TaskData> get filterUserData => _filterUserData;

  Future<void> getAllTask(bool isRefresh,
      {String? date1, String? date2, String? type}) async {
    _checkAtt="";
    _checkAttName="";
    if(isRefresh==true){
      _filter="1";
      statusId="";
      matched=0;
      _filterDate=="";
      _filterTasks=0;
      _status=null;
      search.clear();
      search2.clear();
      _allTasks.clear();
      _searchAllTasks.clear();
      _filterUserData.clear();
      _viewRefresh=false;
    }
    notifyListeners();
    try {
      Map data = {
        "action": taskDatas,
        "search_type":"all_tasks",
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "id": localData.storage.read("id"),
        // "date1": date1,
        // "date2": date2,
      };
      final response =await _taskRepo.getReport(data);
      print(data.toString());
      print(response.toString());
      if (response.isNotEmpty) {
        _allTasks=response;
        _searchAllTasks=response;
        _filterUserData=response;
        for(var i=0;i<response.length;i++){
          String dateStr = response[i].taskDate.toString(); // "24-05-2025"
          DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(dateStr);
          DateTime dateObject = parsedDate;
          Appointment app = Appointment(
            startTime: dateObject,
            endTime: dateObject,
            subject: response[i].statval.toString(),
            color: colorsConst.red2,
          );
          dataSource.appointments!.add(app);
          dataSource.notifyListeners(CalendarDataSourceAction.add, <Appointment>[app]);
          // print("Adding Appointment....");
          var count=0;
          var st = parsedDate;
          if(utils.returnPadLeft(defaultMonth.toString())==utils.returnPadLeft(st.month.toString())){
            count++;
          }
          _thisMonthLeave=count.toString();
        }
        for(var i=0;i<response.length;i++){
          if(response[i].isChecked.toString()=="1"){
            _checkAtt=response[i].id.toString();
            _checkAttName=response[i].projectName.toString();
            break;
          }
        }
        filterList();
        print("_isFilter");
        // print(_isFilter);
        _viewRefresh=true;
      }
    } catch (e) {
      _allTasks=[];
      _checkAtt="";
      _checkAttName="";
      _searchAllTasks=[];
      _filterUserData=[];
      _viewRefresh=true;
    }
    notifyListeners();
  }
  List<TaskData> _userAllTasks = <TaskData>[];
  List<TaskData> get userAllTasks => _userAllTasks;
  Future<void> getUserTasks(String id,String date1,String date2) async {
    _filter="1";
    statusId="";
    matched=0;
    _filterDate=="";
    _filterTasks=0;
    _status=null;
    _userAllTasks.clear();
    _viewRefresh=false;
    notifyListeners();
    try {
      Map data = {
        "action": taskDatas,
        "search_type":"emp_tasks_details",
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "id":localData.storage.read("role")=="1"?id:localData.storage.read("id"),
        "date1": date1,
        "date2": date2
      };
      final response =await _taskRepo.getReport(data);
      // print(data.toString());
      // print(response.toString());
      if (response.isNotEmpty) {
        _userAllTasks=response;
        _viewRefresh=true;
      }
    } catch (e) {
      _userAllTasks=[];
      _viewRefresh=true;
    }
    notifyListeners();
  }
  Future<void> getCustomerTasks(String id,String date1,String date2) async {
    _filter="1";
    statusId="";
    matched=0;
    _filterDate=="";
    _filterTasks=0;
    _status=null;
    _userAllTasks.clear();
    _viewRefresh=false;
    notifyListeners();
    try {
      Map data = {
        "action": taskDatas,
        "search_type":"customer_tasks_details",
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "user_id":localData.storage.read("role")=="1"?id:localData.storage.read("id"),
        "id":id,
        "date1": date1,
        "date2": date2
      };
      final response =await _taskRepo.getReport(data);
      // print(data.toString());
      // print(response.toString());
      if (response.isNotEmpty) {
        _userAllTasks=response;
        _viewRefresh=true;
      }
    } catch (e) {
      _userAllTasks=[];
      _viewRefresh=true;
    }
    notifyListeners();
  }

  Future<void> taskAttDirect(context,{required String status,required String lat, required String lng,required String taskId}) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                child: Column(
                  children: [
                    const CustomText(text: "Marking Please Wait",
                      colors: Colors.grey,
                      size: 15,
                      isBold: true,),
                    20.height,
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: colorsConst.primary,
                      size: 25,
                    ),
                  ],
                ),
              ),
            );
          }
      );
      Map<String, String> data = {
        "action": taskAtt,
        "log_file": localData.storage.read("mobile_number"),
        "line_id": "0",
        "line_customer_id": taskId,
        "salesman_id": localData.storage.read("id"),
        "self_img_count": "0",
        "comp_img_count": "0",
        "collection_amt": "0",
        "sales_amt": "0",
        "is_checked_out": status,
        "lat": lat,
        "lng": lng,
        "traveled_kms": "0.0",
        "id": localData.storage.read("tk_id").toString(),
        "cos_id": localData.storage.read("cos_id"),

      };
      final response =await _taskRepo.addAttendance(data,_profile);
      // print(response.toString());
      if (response.isNotEmpty){
        localData.storage.write("tk_id", response[0]["id"]);
        utils.showSuccessToast(text: status=="1"?"Check In Successful":"Check Out Successful",context: context);
        getAllTask(false);
        Provider.of<HomeProvider>(context, listen: false).getMainReport(false);
        Navigator.of(context, rootNavigator: true).pop();
      }else {
        Navigator.of(context, rootNavigator: true).pop();
        utils.showErrorToast(context: context);
        notifyListeners();
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      log(e.toString());
      utils.showErrorToast(context: context);
    }finally{
      notifyListeners();
    }
  }
  Future<void> taskAttendance(context,
      {required String status,
        required String taskId,
        required String coId,
        required String lat,
        required String lng}) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                child: Column(
                  children: [
                    const CustomText(text: "Marking Please Wait",
                      colors: Colors.grey,
                      size: 15,
                      isBold: true,),
                    20.height,
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: colorsConst.primary,
                      size: 25,
                    ),
                  ],
                ),
              ),
            );
          }
      );
      Map<String, String> data = {
        "action": taskAtt,
        "log_file": localData.storage.read("mobile_number"),
        "line_id": "0",
        "line_customer_id": taskId,
        "salesman_id": localData.storage.read("id"),
        "self_img_count": "0",
        "comp_img_count": "0",
        "collection_amt": "0",
        "sales_amt": "0",
        "is_checked_out": status,
        "lat": lat,
        "lng": lng,
        "traveled_kms": "0.0",
        "id": localData.storage.read("tk_id"),
        "cos_id": localData.storage.read("cos_id"),
      };
      final response =await _taskRepo.addAttendance(data,_profile);
      log(response.toString());
      if (response.isNotEmpty){
        localData.storage.write("tk_id", response[0]["id"]);
        utils.showSuccessToast(text: status=="1"?"Check In Successful":"Check Out Successful",context: context);
        getAllCoTask(coId,false);
        Navigator.of(context, rootNavigator: true).pop();
      }else {
        Navigator.of(context, rootNavigator: true).pop();
        utils.showErrorToast(context: context);
      }
    } catch (e) {
      log(e.toString());
      Navigator.of(context, rootNavigator: true).pop();
      utils.showErrorToast(context: context);
    }
    notifyListeners();
  }

  var typeList=[];
  var statusList=[];

  bool _addRefresh = true;
  bool get addRefresh =>_addRefresh;
  dynamic _selectType;
  dynamic get selectType=>_selectType;
  void changeTypeValue(dynamic value){
    _selectType=null;
    _selectType=value;
    var list=[];
    list.add(value);
    localData.storage.write("type_id",list[0]["id"]);
    localData.storage.write("typeName",list[0]["value"]);

    notifyListeners();
  }

  Future<void> getTaskType(bool isRefresh) async {
    try {
      _selectType=null;
      if(isRefresh==true){
        _addRefresh=false;
        notifyListeners();
      }
      Map data = {
        "action": getAllData,
        "search_type":"cmt_type",
        "cat_id":"7",
        "cos_id": localData.storage.read("cos_id")
      };
      final response =await _taskRepo.getListDatas(data);
      log(data.toString());
      log(response.toString());
      if (response.isNotEmpty) {
        List<Map<String, String>> list = response.map((e) => {
          "id": e['id'].toString(),
          "value": e['value'].toString().trim(),
          "categories": e['categories'].toString()
        }).toList();
        if(!kIsWeb){
          await LocalDatabase.insertTaskType(list);
          getAllTypes();
        }else{
          typeList.clear();
          typeList=list;
          _addRefresh=true;
          notifyListeners();
        }
      }else{
        _addRefresh=true;
      }
    } catch (e) {
      _addRefresh=true;
    }
    notifyListeners();
  }
  TextEditingController typeCtr = TextEditingController();

  Future<void> getTaskStatuses() async {
    try {
      Map data = {
        "action": getAllData,
        "search_type":"cmt_type",
        "cat_id":"8",
        "cos_id": localData.storage.read("cos_id")
      };
      final response =await _taskRepo.getListDatas(data);
      // log(response.toString());
      if (response.isNotEmpty) {
        List<Map<String, String>> list = response.map((e) => {
          "id": e['id'].toString(),
          "value": e['value'].toString(),
          "categories": e['categories'].toString()
        }).toList();
        if(!kIsWeb){
          await LocalDatabase.insertTaskStatus(list);
        }else{
          statusList.clear();
          statusList=list;
          notifyListeners();
        }
      }
    } catch (e) {
      // _refresh=true;
    }
    notifyListeners();
  }
  Future<void> getAllTypes() async {
    typeList.clear();
    List storedLeads = await LocalDatabase.getTaskTypes();
    typeList=storedLeads;
    _addRefresh=true;
    print("typeList......${typeList}");
    _selectType=null;
    notifyListeners();
  }
  Future<void> refreshTypes() async {
    _type=null;
    typeList.clear();
    List storedLeads = await LocalDatabase.getTaskTypes();
    typeList=storedLeads;
    notifyListeners();
  }
  Future<void> getTypeSts() async {
    statusList.clear();
    List storedLeads = await LocalDatabase.getTaskStatus();
    statusList=storedLeads;
    notifyListeners();
  }
  Future<void> refreshStatus() async {
    _status=null;
    statusList.clear();
    List storedLeads = await LocalDatabase.getTaskStatus();
    statusList=storedLeads;
    notifyListeners();
  }


  Future<void> fetchUserNameList() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _taskRepo.getUserNames();
      if (response["ResponseCode"].toString() == "200") {
        List<dynamic> data = response["Response"] ?? [];
        _userNameList = data;
        _assignList = [];
        // for(var name in _userNameList){
        //   if(name["f_name"]==localData.currentUserName){
        //     _assignList.add("Self");
        //   }else{
        //     _assignList.add(name["f_name"]);
        //   }
        // }
        _assignList = _userNameList.map((e) => e["f_name"].toString()).toList();
      } else {
        _userNameList = [];
      }
    } catch (e) {
      // print("FetchUserNameList error $e");
      _userNameList = [];
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Play Recorded Audio
  // Future<void> playAudio() async {
  //   if (_audioPath != null) {
  //     _isPlaying = true;
  //     notifyListeners();
  //     await _audioPlayer.play(DeviceFileSource(_audioPath!));
  //     _audioPlayer.onPlayerComplete.listen((event) {
  //       _isPlaying = false;
  //       notifyListeners();
  //     });
  //   }
  // }

  /// Stop Audio Playback
  // Future<void> stopAudio() async {
  //   await _audioPlayer.stop();
  //   _isPlaying = false;
  //   notifyListeners();
  // }
  /// CHART
  String _totalCount = "";
  String _pendingCount = "";
  String _completedCount = "";
  String _overdueCount = "";
  double _pendingCountPer = 0.0;
  double _completedCountPer = 0.0;
  double _overdueCountPer = 0.0;
  bool _isDashboardLoading = false;

  String get totalCount => _totalCount;
  String get pendingCount => _pendingCount;
  String get completedCount => _completedCount;
  String get overdueCount => _overdueCount;
  double get pendingCountPer => _pendingCountPer;
  double get completedCountPer => _completedCountPer;
  double get overdueCountPer => _overdueCountPer;
  bool get isDashboardLoading => _isDashboardLoading;

  Future<void> fetchTaskCount() async {
    _isDashboardLoading = true;
    notifyListeners();
    try {
      final response = await _taskRepo.getDashboardCount();
      // print("dashboard output ${response["Response"]}");
      if (response["ResponseCode"].toString() == "200") {
        List<dynamic> data = response["Response"] ?? [];
        _totalCount = data[0]["total_count"];
        _pendingCount = data[0]["pending_count"];
        _completedCount = data[0]["complete_count"];
        _overdueCount = data[0]["overdue_count"];
        double total = double.tryParse(_totalCount) ?? 1;
        double completed = double.tryParse(_completedCount) ?? 0;
        double pending = double.tryParse(_pendingCount) ?? 0;
        double overdue = double.tryParse(_overdueCount) ?? 0;
        _completedCountPer = (completed / total) * 100;
        _pendingCountPer = (pending / total) * 100;
        _overdueCountPer = (overdue / total) * 100;
        notifyListeners();
      } else {
        _totalCount = "0";
        _pendingCount = "0";
        _completedCount = "0";
        _overdueCount = "0";
      }
      notifyListeners();
    } catch (e) {
      _totalCount = "0";
      _pendingCount = "0";
      _completedCount = "0";
      _overdueCount = "0";
      // print("FetchUserNameList error $e");
      notifyListeners();
    } finally {
      _isDashboardLoading = false;
      notifyListeners();
    }
  }
  /// copy of customer add visit page


  List<String> _selectedPhotos = [];

  List<String> get selectedPhotos => _selectedPhotos;

  Future<void> pickCamera(BuildContext context) async {
    var imgData = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const CameraWidget(
              cameraPosition: CameraType.back,
            )));
    _selectedPhotos.add(imgData);
    notifyListeners();
  }
  void removePhotos(int index) {
    _selectedPhotos.removeAt(index);
    notifyListeners();
  }

  final AudioRecorder record = AudioRecorder();

  bool isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && (uri.hasScheme && uri.hasAuthority);
  }

  String formatDuration(Duration d) {
    String minutes = d.inMinutes.toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
  Future<void> insertTaskType(context) async {
    try {
      Map<String, String> data = {
        "action": addTaskType,
        "meta_id":"7",
        "value":typeCtr.text.trim(),
        "created_by": localData.storage.read("id"),
        "platform": localData.storage.read("platform").toString(),
        "cos_id": localData.storage.read("cos_id").toString(),
        "log_file": localData.storage.read("mobile_number").toString(),
      };
      final response =await _taskRepo.addType(data);
      print(data.toString());
      print(response.toString());
      if (response.toString().contains("This type already exits")){
        utils.showWarningToast(context,text: "This type already exits");
        taskCtr.reset();
      }else if (response["status_code"]==200){
        utils.showSuccessToast(context: context,text: constValue.success);
        getTaskType(true);
        Navigator.pop(context);
        taskCtr.reset();
      }else {
        utils.showErrorToast(context: context);
        taskCtr.reset();
      }
    } catch (e) {
      log(e.toString());
      utils.showErrorToast(context: context);
      taskCtr.reset();
    }
    notifyListeners();
  }
  void deleteType(context,String id) async {
    try {
      Map data = {
        "action":delete,
        "ops":"type",
        "id":id,
        "meta_id":"7",
        "updated_by":localData.storage.read("id"),
        "platform": localData.storage.read("platform"),
        "cos_id": localData.storage.read("cos_id"),
      };
      final response = await _taskRepo.addType(data);
      if (response["status_code"]==200) {
        utils.showSuccessToast(context: context,text: constValue.deleted);
        if(!kIsWeb){
          await LocalDatabase.deleteTaskTypeById(id);
        }
        getTaskType(false);
        Navigator.pop(context);
        taskCtr.reset();
      } else {
        utils.showErrorToast(context: context);
        taskCtr.reset();
      }
    } catch (e) {
      utils.showErrorToast(context: context);
      taskCtr.reset();
    }
    notifyListeners();
  }

}
