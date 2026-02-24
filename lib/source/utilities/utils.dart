import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:master_code/component/custom_network_image.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../constant/assets_constant.dart';
import '../constant/colors_constant.dart';
final Utils utils = Utils._();

class Utils {
  Utils._();

  String returnPadLeft(String value){
    var output=value.toString().padLeft(2,"0");
    return output;
  }
  // void navigatePage(BuildContext context, Widget Function() pageBuilder) {
  //   Navigator.push(
  //     context,
  //     PageTransition(
  //       type: PageTransitionType.rightToLeft,
  //       duration: const Duration(milliseconds: 100),
  //       child: pageBuilder(),
  //     ),
  //   );
  // }
  void navigatePage(BuildContext context, Widget Function() pageBuilder) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => pageBuilder()),        // PageTransition(
        //   type: PageTransitionType.rightToLeft,
        //   duration: const Duration(milliseconds: 5),
        //   child: pageBuilder(),
        // ),
      );
    // });
  }


  makingPhoneCall({String? ph}) async {
    if(ph!=""&&ph!="null"){
      if (!await launchUrl(Uri.parse('tel:$ph'))) {
        throw Exception('Could not launch');
      }
    }
  }
  makingWhatsApp({required String ph}) async {
    if(ph!=""&&ph!="null"){
      final whatsappUrl = "https://wa.me/$ph?text=${Uri.encodeComponent("JPS")}";
      final Uri url = Uri.parse(whatsappUrl.toString());
      if (!await launchUrl(url)){
        throw Exception('Could not launch $url');
      }
    }
  }


  // Future<void> makingEmail({required String email}) async {
  //   final Uri emailUri = Uri(
  //     scheme: 'mailto',
  //     path: email,
  //     query: 'subject=${Uri.encodeComponent('JPS')}&body=${Uri.encodeComponent('JPS')}',
  //   );
  //
  //   if (await canLaunchUrl(emailUri)) {
  //     await launchUrl(
  //       emailUri,
  //       mode: LaunchMode.externalApplication, // Ensures it opens outside the app
  //     );
  //   } else {
  //     throw 'Could not launch email app';
  //   }
  // }
  ///
  // Future<void> makingEmail({required String email}) async {
  //   final Uri emailUri = Uri(
  //     scheme: 'mailto',
  //     path: email, // Replace with recipient's email
  //     query: 'subject=Hello&body=This is a test email', // Replace with your subject and body
  //   );
  //
  //   if (await canLaunchUrl(emailUri)) {
  //     await launchUrl(emailUri);
  //   } else {
  //     throw 'Could not open email app';
  //   }
  // }
  ///
  makingEmail({required String mail,required BuildContext context}) async {
    if(mail!=""&&mail!="null"){
      final url = 'mailto:$mail';
      final Uri urlLink = Uri.parse(url);
      if (!await launchUrl(urlLink)){
        // toast(text: "Email does not exist.", context: context);
        throw Exception('Could not launch $url');
      }
    }
  }
  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double R = 6371; // Radius of the Earth in kilometers
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLng = _degreesToRadians(lng2 - lng1);
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c; // Distance in kilometers
  }


  // void reportPick({required BuildContext context,required RxString date,required String type}){
  //   userCtr.dateTime=DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  //   showDatePicker(
  //     context: context,
  //     initialDate: userCtr.dateTime,
  //     firstDate: DateTime(2024),
  //     lastDate: DateTime.now().add(const Duration(days: 1)),
  //   ).then((value) async {
  //     userCtr.dateTime=value!;
  //     date.value= ("${(userCtr.dateTime.day.toString().padLeft(2,"0"))}-"
  //         "${(userCtr.dateTime.month.toString().padLeft(2,"0"))}-"
  //         "${(userCtr.dateTime.year.toString())}");
  //     if(type=="1"){
  //       attendanceServices.getDailyReport();
  //     }else if(type=="2"){
  //       attendanceServices.getWeeklyReport();
  //     }else if(type=="3"){
  //       attendanceServices.getMonthlyReport();
  //     }else if(type=="4"){
  //       attendanceServices.dailyRefresh();
  //     }
  //   });
  // }


  String dateReturn(String date){
    String timestamp = date;
    DateTime dateTime = DateTime.parse(timestamp);
    DateFormat('EEEE').format(dateTime);
    DateTime today = DateTime.now();
    if (dateTime.day == today.day && dateTime.month == today.month && dateTime.year == today.year) {
    } else if (dateTime.isAfter(today.subtract(const Duration(days: 1))) &&
        dateTime.isBefore(today)) {
    } else {
    }
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
  // String roleReturn(String role){
  //   String value = "";
  //   if (role == "1") {
  //     value = "Admin";
  //   } else if (role == "2") {
  //     value = "Field Staff";
  //   }else if (role == "3") {
  //     value = "Office Staff";
  //   }
  //
  //   return value;
  // }



  void datePick({
    required BuildContext context,
    bool? isDob,
    TextEditingController? textEditingController,
  }) async {
    DateTime dateTime = DateTime.now();

    if (textEditingController != null && textEditingController.text.isNotEmpty) {
      try {
        String cleaned = textEditingController.text.replaceAll("/", "-").trim();
        List<String> parts = cleaned.split("-");

        if (parts.length == 3) {
          int p1 = int.tryParse(parts[0]) ?? 0;
          int p2 = int.tryParse(parts[1]) ?? 0;
          int p3 = int.tryParse(parts[2]) ?? 0;

          // Try to detect the format automatically
          if (p1 > 31) {
            // Format: YYYY-MM-DD
            dateTime = DateTime(p1, p2, p3);
          } else if (p3 < 100) {
            // Handle short year like 25 -> 2025
            dateTime = DateTime(2000 + p3, p2, p1);
          } else {
            // Format: DD-MM-YYYY
            dateTime = DateTime(p3, p2, p1);
          }
        }
      } catch (e) {
        // Fallback safely
        dateTime = DateTime.now();
      }
    }
    const String dateFormat = "dd/MM/yyyy";

    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('en', 'GB'),
      initialDate: dateTime,
      firstDate: DateTime(1920),
      lastDate: isDob==true?DateTime.now():DateTime(3000),
      fieldHintText: dateFormat,
      fieldLabelText: 'Enter Date ($dateFormat)',
    );
    if (picked != null) {
      textEditingController?.text =
      "${picked.day.toString().padLeft(2, "0")}-"
          "${picked.month.toString().padLeft(2, "0")}-"
          "${picked.year}";
    }
  }






  static Future<void> openUrl(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  void toastBox({required BuildContext context, required String text}){
    Fluttertoast.showToast(
        msg: text,
        // toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 14.0
    );
  }
  // ScaffoldFeatureController<SnackBar, SnackBarClosedReason> toast({required BuildContext context, required String text,  bool? isSuccess}) {
  //   var snack = SnackBar(
  //       content:Center(child: Text(text,
  //         textAlign: TextAlign.center,
  //         style: const TextStyle(
  //           fontSize: 15,
  //         ),)),
  //       behavior: SnackBarBehavior.floating,
  //       duration: const Duration(seconds: 1),
  //       backgroundColor:isSuccess==true?colorsConst.appGreen:Colors.redAccent,
  //       margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
  //       elevation: 30,
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(5)))
  //   );
  //   return ScaffoldMessenger.of(context).showSnackBar(
  //     snack,
  //   );
  // }

  void showErrorToast({required context}){
    // ToastService.showErrorToast(
    //     context,
    //     length: ToastLength.short,
    //     expandedHeight: 20,
    //     message: "Failed",backgroundColor: colorsConst.appRed
    // );
    showCustomToast(
      context: context,
      message:"Failed",
      backgroundColor: colorsConst.callColor,
    );
  }
  void showWarningToast(context,{required String text}){
    // ToastService.showWarningToast(
    //     context,
    //     length: ToastLength.short,
    //     expandedHeight: 70,
    //     message: text,backgroundColor: colorsConst.primary.withOpacity(0.2)
    // );
    showCustomToast(
      context: context,
      message:text,
      backgroundColor: colorsConst.litOrange,
    );
  }
  void showSuccessToast({required context,required String text}){
    // ToastService.showSuccessToast(
    //   context,
    //   length: ToastLength.short,
    //   expandedHeight: 40,
    //   message: text,backgroundColor: colorsConst.appDarkGreen,
    // );
    showCustomToast(
      context: context,
      message:text,
      backgroundColor: colorsConst.appDarkGreen,
    );
  }

  void showCustomToast({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    Color textColor = Colors.white,
    double fontSize = 14,
    double height = 36,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 180,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: height,
            padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                backgroundColor==colorsConst.appDarkGreen?
                const Icon(Icons.check_circle, color: Colors.white, size: 18):
                backgroundColor==colorsConst.appRed?
                const Icon(Icons.cancel, color: Colors.white, size: 18):
                const Icon(Icons.warning, color: Colors.white, size: 18),
                5.width,
                Expanded(
                  child: CustomText(
                    text:message,colors: Colors.white,
                  ),
                ),
                InkWell(
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                  onTap: () {
                    overlayEntry.remove();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration).then((_) {
      // Remove only if not already removed
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }


  // Future<void> backGroundPermissions() async {
  //   final NotificationPermission notificationPermissionStatus =
  //   await FlutterForegroundTask.checkNotificationPermission();
  //   if (notificationPermissionStatus == NotificationPermission.denied) {
  //     await FlutterForegroundTask.requestNotificationPermission();
  //   } else {
  //     print("Notification permission already granted.");
  //   }
  //   if (Platform.isAndroid) {
  //     if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
  //       await FlutterForegroundTask.requestIgnoreBatteryOptimization();
  //     }
  //   }
  // }
  Future<void> backGroundPermissions() async {
    if (Platform.isAndroid) {
      bool isIgnoringBatteryOptimization =
      await FlutterForegroundTask.isIgnoringBatteryOptimizations;

      if (!isIgnoringBatteryOptimization) {
        // print("Requesting to ignore battery optimizations...");
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      } else {
        // print("Battery optimization already ignored.");
      }
    }
  }

  List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    List<DateTime> days = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(DateTime(start.year, start.month, start.day + i));
    }
    return days;
  }
  // void signDialog(bool isVisible,
  //     // int count,
  //     {required RxString img,String? img2,bool? isUpdate=false,bool? isNetwork=false,bool? isAdd=false,List<AddDocumentModel>? list
  //       // String? id,File? file
  //     }){
  //   showDialog(context: Get.context!,
  //       builder: (context){
  //         return AlertDialog(
  //             title: const Center(
  //               child: Column(
  //                 children: [
  //                   CustomText(text: "Pick Document From",colors: Colors.black,size: 15,isBold: true,),
  //                 ],
  //               ),
  //             ),
  //             content: SizedBox(
  //               height: 120,
  //               width: 300,
  //               // color: Colors.red,
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                     children: [
  //                       GestureDetector(
  //                         onTap: ()async{
  //                           img.value= await Get.to(const CameraWidget(
  //                             cameraPosition: CameraType.front,
  //                           ));
  //
  //                           if(isAdd==true){
  //                             list?[customerCtr.clickedDocumentIndex.value].imagePath = img.value;
  //                             // img.value="";
  //                           }else{
  //                             // compressImage(File(img.value),img);
  //                           }
  //                           Get.back();
  //                         },
  //                         child: Column(
  //                           children: [
  //                             SvgPicture.asset(assets.cam),
  //                             5.height,
  //                             const CustomText(text: "Camera",colors: Colors.grey,isBold: true),
  //                           ],
  //                         ),
  //                       ),
  //                         GestureDetector(
  //                           onTap: () async {
  //                             XFile? pickedFile;
  //                             if(isAdd==true) {
  //                                pickedFile= await userCtr.picker.pickImage(source: ImageSource.gallery,preferredCameraDevice: CameraDevice.front);
  //                             }else{
  //                                pickedFile= await userCtr.picker.pickImage(source: ImageSource.gallery,preferredCameraDevice: CameraDevice.front,imageQuality: 100,maxHeight: 1000,maxWidth: 1000);
  //                             }
  //                             userCtr.xFile = pickedFile;
  //                             img.value = userCtr.xFile!.path;
  //                             if(isAdd==true){
  //                               list?[customerCtr.clickedDocumentIndex.value].imagePath = img.value;
  //                               // img.value="";
  //                             }else{
  //                               // compressImage(File(userCtr.xFile!.path),img);
  //                             }
  //                             Get.back();
  //                           },
  //                           child: Column(
  //                             children: [
  //                               SvgPicture.asset(assets.gallery),
  //                               5.height,
  //                               const CustomText(text: "Gallery",colors: Colors.grey,isBold: true),
  //                             ],
  //                           ),
  //                         ),
  //                     ],
  //                   ),
  //                   if(isAdd==false)
  //                   Visibility(
  //                     visible: isVisible,
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                       children: [
  //                         if(isNetwork==false&&isAdd==true)
  //                         Visibility(
  //                             visible: isVisible,
  //                             child:TextButton(
  //                               onPressed: () async {
  //                                 img.value="";
  //                                 Get.back();
  //                               },
  //                               child:CustomText(text: "Remove",colors: colorsConst.primary,size: 15,isBold: true),
  //                             ),
  //                           ),
  //                         Visibility(
  //                           visible: isVisible,
  //                           child:TextButton(onPressed: () {
  //                             Navigator.of(context).pop();
  //                             Get.to(FullScreen(image:isNetwork==true?img2.toString():img.value, isNetwork: isNetwork!,));
  //                           },
  //                             child:CustomText(text: "Full View",colors: colorsConst.primary,size: 15,isBold: true),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             )
  //         );
  //       }
  //   );
  // }






  // Future<void> reportExport({required List dataList,required String type,})async{
  //   final Workbook workbook =Workbook();
  //   final Worksheet worksheet=workbook.worksheets[0];
  //   worksheet.getRangeByName('A1:F1').merge();
  //   worksheet.getRangeByName('A1:F1').cellStyle.hAlign= HAlignType.center;
  //   worksheet.getRangeByName('A2:F2').merge();
  //   worksheet.getRangeByName('A2:F2').cellStyle.hAlign= HAlignType.center;
  //   worksheet.getRangeByName('A3:F3').cellStyle.hAlign= HAlignType.center;
  //   worksheet.getRangeByName('A1').cellStyle.bold = true;worksheet.getRangeByName('A1').cellStyle.fontSize = 10;
  //   worksheet.getRangeByName('A2').cellStyle.bold = true;worksheet.getRangeByName('A2').cellStyle.fontSize = 10;
  //   worksheet.getRangeByName('A3:F3').cellStyle.bold = true;worksheet.getRangeByName('A3:F3').cellStyle.fontSize = 10;
  //   worksheet.getRangeByName('A3:F3').columnWidth =10;
  //   worksheet.getRangeByName('C3').columnWidth =20;
  //
  //   worksheet.getRangeByName('A3:F3').cellStyle.backColor='#ED1B26';
  //   worksheet.getRangeByName('A3:F3').cellStyle.fontColor='#ffffff';
  //
  //   worksheet.getRangeByName("A1").setText(constValue.appName);
  //   worksheet.getRangeByName("A2").setText(type);
  //   worksheet.getRangeByName("A3").setText("NAME");
  //   worksheet.getRangeByName("B3").setText("ROLE");
  //   worksheet.getRangeByName("C3").setText("PROJECT NAME");
  //   worksheet.getRangeByName("D3").setText("DATE");
  //   worksheet.getRangeByName("E3").setText("IN TIME");
  //   worksheet.getRangeByName("F3").setText("OUT TIME");
  //
  //   for(var i=0;i<dataList.length;i++){
  //     worksheet.getRangeByIndex(i+4,1).setText(dataList[i]["usr_name"]);
  //     worksheet.getRangeByIndex(i+4,2).setText(dataList[i]["role_name"]);
  //     worksheet.getRangeByIndex(i+4,3).setText(dataList[i]["name"]);
  //     worksheet.getRangeByIndex(i+4,4).setText(dateReturn(dataList[i]["created_ts"]));
  //     worksheet.getRangeByIndex(i+4,5).setText(dataList[i]["in_time"]);
  //     worksheet.getRangeByIndex(i+4,6).setText(dataList[i]["out_time"]);
  //   }
  //   final List<int> bytes =workbook.saveAsStream();
  //   // workbook.dispose();
  //   if(kIsWeb){
  //     AnchorElement(href: 'data:application/octet-stream;charset-utf-161e;base64,${base64.encode(bytes)}')
  //       ..setAttribute('download', 'Salesman.xlsx')
  //       ..click();
  //   }else{
  //     final String path=(await getApplicationSupportDirectory()).path;
  //     final String filename='$path/attendance attendance_report.xlsx';
  //     final File file=File(filename);
  //     await file.writeAsBytes(bytes,flush: true);
  //     OpenFile.open(filename);
  //   }
  // }
  String formatNo(String number) {
    double value = double.tryParse(number) ?? 0;
    return NumberFormat.decimalPattern().format(value);
  }
  String calculateDuration(String time1, String time2) {
    // Parse times in 12-hour format
    DateFormat format = DateFormat("h:mm a");
    DateTime startTime = format.parse(time1);
    DateTime endTime = format.parse(time2);

    // Calculate duration
    Duration duration = endTime.difference(startTime);

    // Handle negative durations (if endTime is on the next day)
    if (duration.isNegative) {
      endTime = endTime.add(const Duration(days: 1));
      duration = endTime.difference(startTime);
    }

    // Format the duration
    return "${duration.inHours}h ${duration.inMinutes % 60}m";
  }
  void customDialog({required BuildContext context,required String title, String? title2="",
    required VoidCallback callback,
    RoundedLoadingButtonController? roundedLoadingButtonController,
    TextEditingController? textEditCtr,
    TextEditingController? textEditCtr2,
    bool? isEdit,
    bool? isLoading,
    TextInputType? keyboardType=TextInputType.text,
  }){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            actions: [
              Center(
                child: SizedBox(
                  // color: Colors.yellow,
                  width: kIsWeb?MediaQuery.of(context).size.width*0.3:MediaQuery.of(context).size.width*0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: CustomText(text:  title,colors: Colors.black,size: 15,isBold: true,)),
                      if(title2!="")10.height,
                      if(title2!="")
                      Center(child: CustomText(text:  title2!,colors: Colors.black,size: 15,isBold: true,)),
                      20.height,
                      if(isEdit==true)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: title2.toString().contains("approve")?"Approve Amount":"Reason",colors: colorsConst.greyClr,),5.height,
                          TextField(
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 1, // Minimum height (1 line)
                            maxLines: null, // Auto-expand based on content
                            controller: textEditCtr!,textInputAction: TextInputAction.done,
                            keyboardType: keyboardType,
                            decoration: InputDecoration(
                              hintText:"",
                              hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                // grey.shade300
                                  borderSide:  BorderSide(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:  BorderSide(color: colorsConst.primary),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: colorsConst.primary),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              contentPadding:const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              errorBorder: OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                side: const BorderSide(color: Colors.white)
                            ),
                            child: const CustomText(text: "No",colors: Colors.black,size: 15,isBold: true,),
                          ),
                          isLoading==true?
                          Container(
                            height: kIsWeb?25:37,
                            width: 55,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: RoundedLoadingButton(
                                borderRadius: 5,
                                elevation: 0.0,
                                color: colorsConst.primary,
                                successColor: Colors.grey.shade200,
                                valueColor:Colors.grey.shade200,
                                onPressed: callback,
                                controller: roundedLoadingButtonController!,
                                child: const CustomText(text: "Yes",colors: Colors.white,size: 15,isBold:true)
                            ),
                          ):
                          OutlinedButton(
                            onPressed: callback,
                            style: OutlinedButton.styleFrom(
                                backgroundColor: colorsConst.primary,
                                side: BorderSide(color: colorsConst.primary)
                            ),
                            child: const CustomText(text: "Yes",colors: Colors.white,size: 15,isBold: true,),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        }
    );
  }
  String getCreatedDate(data) {
    final timestamp = data.createdTs.toString();
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
  void editDialog({required BuildContext context,required String title, String? title2="",
    required VoidCallback callback,
    RoundedLoadingButtonController? roundedLoadingButtonController,
    TextEditingController? textEditCtr,
    String? name,
    String? role,
    String? reason,
  }){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            actions: [
              Center(
                child: SizedBox(
                  // color: Colors.yellow,
                  width: kIsWeb?MediaQuery.of(context).size.width*0.3:MediaQuery.of(context).size.width*0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                              // color: Colors.yellow,
                              width: kIsWeb?MediaQuery.of(context).size.width*0.28:MediaQuery.of(context).size.width*0.65,
                              child: CustomText(text:  "$title ${title2!}",size: 15,isBold: true,)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: InkWell(onTap: (){
                              Navigator.pop(context);
                            }, child: SvgPicture.asset(assets.cancel)),
                          ),
                        ],
                      ),
                       Column(
                          children: [
                            10.height,
                            Row(
                              children: [
                                const CustomText(text:  "Name : "),5.width,
                                CustomText(text:  name!,isBold: true,colors: colorsConst.primary,),
                              ],
                            ),
                            10.height,
                            Row(
                              children: [
                                const CustomText(text:  "Role : "),15.width,
                                CustomText(text:  role!,colors: const Color(0xff9E9E9E),isBold: true,),
                              ],
                            ),15.height,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CustomText(text: "Reason"),
                                    CustomText(text:"*",colors: colorsConst.appRed,size:20,isBold: false,)
                                  ],
                                ),5.height,
                                TextField(
                                  textCapitalization: TextCapitalization.sentences,
                                  minLines: 1, // Minimum height (1 line)
                                  maxLines: null, // Auto-expand based on content
                                  controller: textEditCtr!,textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    hintText:"",
                                    hintStyle: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                        // grey.shade300
                                        borderSide:  BorderSide(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:  BorderSide(color: colorsConst.primary),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: colorsConst.primary),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    contentPadding:const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    errorBorder: OutlineInputBorder(
                                        borderSide:  BorderSide(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        10.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.grey.shade100,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10), // Adjust the radius
                                ),
                            ),
                            child: const CustomText(text: "Cancel",size: 15),
                          ),
                          Container(
                            height: 35,
                            width: 170,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: RoundedLoadingButton(
                                borderRadius: 10,
                                elevation: 0.0,
                                color: colorsConst.primary,
                                successColor: Colors.white,
                                valueColor:Colors.white,
                                onPressed: callback,
                                controller: roundedLoadingButtonController!,
                                child: CustomText(text: "Confirm $reason",colors: Colors.white,isBold:true,size: 15)
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        }
    );
  }
  void imgDialog({required BuildContext context,required String title,required String img}){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            // title: Center(
            //   child: Column(
            //     children: [
            //       CustomText(text: title,colors: Colors.black,size: 15,isBold: true,),
            //     ],
            //   ),
            // ),
            actions: [
              SizedBox(
                width: 500,
                height: 300,
                child: NetworkImg(image: img, width: 10),
              )
            ],
          );
        }
    );
  }
}