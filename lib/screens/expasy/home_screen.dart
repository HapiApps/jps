// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:master_code/component/custom_loading_button.dart';
// import 'package:master_code/screens/expasy/simple_expense.dart';
// import 'package:master_code/source/constant/default_constant.dart';
// import 'package:master_code/source/extentions/extensions.dart';
// import 'package:master_code/view_model/expasy_provider.dart';
// import 'package:provider/provider.dart';
// import '../../component/custom_appbar.dart';
// import '../../component/custom_text.dart';
// import '../../component/custom_textfield.dart';
// import '../../source/constant/assets_constant.dart';
// import '../../source/constant/colors_constant.dart';
// import '../../source/constant/local_data.dart';
// import '../../source/utilities/utils.dart';
// import 'add_expense.dart';
// import 'all_expense_screen.dart';
// import 'edit_expense_page.dart';
// import 'expense_details_page.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ExpasyProvider>(context, listen: false);
//       final expenseProvider =Provider.of<ExpasyProvider>(context, listen: false);
//       expenseProvider.filterDateController.clear();
//       expenseProvider.selectedMonth = null;
//       expenseProvider.filters = "Today";
//       expenseProvider.fetchIncome();
//       expenseProvider.fetchAllExpense();
//       expenseProvider.updateTotalExpenseFromOutside(
//         expenseProvider.totalExpenseAmount,
//       );
//       expenseProvider.loadIncomes(localData.storage.read("id"));
//       expenseProvider.loadIncomeAmountFromPrefs(localData.storage.read("id"));
//       expenseProvider.loadBalanceAmountFromPrefs();
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     final expProvider = Provider.of<ExpasyProvider>(context);
//     // Future<void> generateExpenseReport(BuildContext context, ExpasyProvider expProvider) async {
//     //   print("📥 generateExpenseReport() STARTED");
//     //
//     //   if (expProvider.expensesList.isEmpty) {
//     //     utils.showWarningToast(context, text: "No Expenses");
//     //     return;
//     //   }
//     //   if (expProvider.selectedMonth == null) {
//     //     utils.showWarningToast(context, text: "Select Month");
//     //     return;
//     //   }
//     //
//     //   // build excel
//     //   print("📄 Creating Excel...");
//     //   var excel = Excel.createExcel();
//     //   var sheet = excel['Expenses'];
//     //   excel.delete('Sheet1');
//     //
//     //   sheet.appendRow([
//     //     TextCellValue("Date"),
//     //     TextCellValue("Item Name"),
//     //     TextCellValue("Amount"),
//     //   ]);
//     //
//     //   int rows = 0;
//     //
//     //   expProvider.expensesList.sort((a, b) {
//     //     DateTime da = DateFormat('dd-MM-yyyy').parse(a.date);
//     //     DateTime db = DateFormat('dd-MM-yyyy').parse(b.date);
//     //     return da.compareTo(db);
//     //   });
//     //
//     //   print("➡️ Adding rows...");
//     //   for (var expense in expProvider.expensesList) {
//     //     DateTime dt = DateFormat('dd-MM-yyyy').parse(expense.date);
//     //     String dateFormatted = DateFormat('d-M-yyyy').format(dt);
//     //     double gst = double.tryParse(expense.gst.toString()) ?? 0;
//     //
//     //     for (var sub in expense.expenseList) {
//     //       double price = double.tryParse(sub.price.toString()) ?? 0;
//     //       double total = price + (price * gst);
//     //       rows++;
//     //       sheet.appendRow([
//     //         TextCellValue(dateFormatted),
//     //         TextCellValue(sub.itemName.toString()),
//     //         DoubleCellValue(total),
//     //       ]);
//     //     }
//     //   }
//     //
//     //   sheet.appendRow([
//     //     TextCellValue(""),
//     //     TextCellValue("Total Expense"),
//     //     FormulaCellValue("SUM(C2:C${rows + 1})"),
//     //   ]);
//     //
//     //   final bytes = excel.encode();
//     //   if (bytes == null) {
//     //     print("❌ Excel encoding failed");
//     //     utils.showWarningToast(context, text: "Failed to create file");
//     //     return;
//     //   }
//     //
//     //   DateTime selected = expProvider.selectedMonth!;
//     //   final fileName = "${DateFormat('MMM yyyy').format(selected)}_Expense_Report.xlsx";
//     //   print("📁 File Name: $fileName");
//     //
//     //   // ----- WEB
//     //   if (kIsWeb) {
//     //     final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
//     //     final url = html.Url.createObjectUrlFromBlob(blob);
//     //     final anchor = html.AnchorElement(href: url)
//     //       ..setAttribute("download", fileName)
//     //       ..click();
//     //     html.Url.revokeObjectUrl(url);
//     //     utils.showWarningToast(context, text: "Downloaded Successfully");
//     //     return;
//     //   }
//     //
//     //   // ----- MOBILE (Android / iOS)
//     //   Directory downloadsDir;
//     //   bool savedToDownloads = false;
//     //
//     //   if (Platform.isAndroid) {
//     //     // Request runtime permission:
//     //     bool granted = false;
//     //
//     //     // For Android 11+ try MANAGE_EXTERNAL_STORAGE first
//     //     try {
//     //       // If manage external storage is available (Android 11+), request it.
//     //       if (await Permission.manageExternalStorage.isGranted) {
//     //         granted = true;
//     //       } else {
//     //         final status = await Permission.manageExternalStorage.request();
//     //         if (status.isGranted) {
//     //           granted = true;
//     //         } else {
//     //           // try legacy storage permission fallback (for < Android 11 or when manage denied)
//     //           if (await Permission.storage.isGranted) {
//     //             granted = true;
//     //           } else {
//     //             final s = await Permission.storage.request();
//     //             granted = s.isGranted;
//     //           }
//     //         }
//     //       }
//     //     } catch (e) {
//     //       // permission_handler might throw on some platforms; fallback to storage permission flow
//     //       if (await Permission.storage.isGranted) {
//     //         granted = true;
//     //       } else {
//     //         final s = await Permission.storage.request();
//     //         granted = s.isGranted;
//     //       }
//     //     }
//     //
//     //     if (granted) {
//     //       // Try to use Download directory
//     //       downloadsDir = Directory('/storage/emulated/0/Download');
//     //       // ensure directory exists
//     //       if (!await downloadsDir.exists()) {
//     //         try {
//     //           await downloadsDir.create(recursive: true);
//     //         } catch (e) {
//     //           // fallback to app dir if creation fails
//     //           downloadsDir = await getApplicationDocumentsDirectory();
//     //         }
//     //       }
//     //       final savedPath = "${downloadsDir.path}/$fileName";
//     //       try {
//     //         final file = File(savedPath);
//     //         await file.writeAsBytes(bytes, flush: true);
//     //         savedToDownloads = true;
//     //         print("💾 File saved at: $savedPath");
//     //         try {
//     //           await OpenFile.open(savedPath);
//     //         } catch (e) {
//     //           print("❌ OpenFile error: $e");
//     //         }
//     //         utils.showSuccessToast(context: context, text: "Downloaded: $savedPath");
//     //         return;
//     //       } catch (e) {
//     //         print("⚠️ Could not write to Downloads despite permission: $e");
//     //         // fallback to app directory below
//     //       }
//     //     }
//     //
//     //     // not granted or failed — fall back to application documents dir
//     //     downloadsDir = await getApplicationDocumentsDirectory();
//     //     final savedPath = "${downloadsDir.path}/$fileName";
//     //     try {
//     //       final file = File(savedPath);
//     //       await file.writeAsBytes(bytes, flush: true);
//     //       print("💾 File saved in app folder: $savedPath");
//     //       try {
//     //         await OpenFile.open(savedPath);
//     //       } catch (e) {
//     //         print("❌ OpenFile error: $e");
//     //       }
//     //       utils.showWarningToast(context,
//     //         text: "Saved to app folder (permission not granted): $savedPath"
//     //       );
//     //       return;
//     //     } catch (e) {
//     //       print("❌ Final fallback write error: $e");
//     //       utils.showErrorToast(context: context);
//     //       return;
//     //     }
//     //   } else {
//     //     // iOS, macOS, others -> app documents
//     //     downloadsDir = await getApplicationDocumentsDirectory();
//     //     final savedPath = "${downloadsDir.path}/$fileName";
//     //     try {
//     //       final file = File(savedPath);
//     //       await file.writeAsBytes(bytes, flush: true);
//     //       print("💾 File saved at: $savedPath");
//     //       try {
//     //         await OpenFile.open(savedPath);
//     //       } catch (e) {
//     //         print("❌ OpenFile error: $e");
//     //       }
//     //       utils.showSuccessToast(context:context, text: "Downloaded: $savedPath");
//     //       return;
//     //     } catch (e) {
//     //       print("❌ Write error (iOS): $e");
//     //       utils.showErrorToast(context: context);
//     //       return;
//     //     }
//     //   }
//     // }
//     return Consumer<ExpasyProvider>(
//         builder: (context, expenseProvider, child) {
//       return SafeArea(
//         child: Scaffold(
//           key: _scaffoldKey,
//           appBar: PreferredSize(
//             preferredSize: Size(300, 50),
//             child: CustomAppbar(text: expenseProvider.selected == 1
//                 ? constValue.reportG
//                 : expenseProvider.selected == 3
//                 ? constValue.moreApps
//                 : expenseProvider.selected == 4
//                 ? constValue.settings
//                 : expenseProvider.selected == 5
//                 ? constValue.dbScreen
//                 : expenseProvider.selected == 8
//                 ? constValue.expDetails
//                 : expenseProvider.selected == 9
//                 ? constValue.addExp
//                 : expenseProvider.selected == 11
//                 ? constValue.updExp
//                 : constValue.allExp),
//           ),
//           backgroundColor: colorsConst.bacColor,
//           body: expenseProvider.selected == 1
//               ? const ListViewScreen()
//               : expenseProvider.selected == 2
//                   ? const ListViewScreen()
//                   :expenseProvider.selected == 8
//                                   ? ExpenseDetailsPage(
//                                       expenseId: "")
//                                   : expenseProvider.selected == 9
//                                       ? const AddExpense()
//                                           : expenseProvider.selected == 11
//                                               ? EditExpense(
//                                                   isEditing: true,
//                                                   initialItemRows:
//                                                       expenseProvider.itemRows,
//                                                   initialData:
//                                                       expenseProvider.dataRows,
//                                                 )
//                                               : const ListViewScreen(),
//                                 floatingActionButton: expenseProvider.selected==0||expenseProvider.selected==7
//                                 ? SpeedDial(
//             icon: Icons.menu,
//             activeIcon: Icons.close,
//             backgroundColor: colorsConst.primary,
//             spacing: 10,
//             spaceBetweenChildren: 10,
//             children: [
//               SpeedDialChild(
//                 child: SvgPicture.asset(assets.detail,colorFilter: const ColorFilter.mode(
//                   Colors.grey,
//                   BlendMode.srcIn,
//                 ),),
//                 label: 'Income',
//                 onTap: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       backgroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       title: CustomText(
//                         text:"Add Your Income",isBold: true,
//                           size: 15,
//                       ),
//                       content: SizedBox(
//                         width: 300,
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             CustomTextField(
//                               text: "", hintText: "Enter Income", controller: expenseProvider.incomeTypeController,
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                                 LengthLimitingTextInputFormatter(8),
//                               ],
//                               width: MediaQuery.of(context).size.width*0.7,
//                             ),
//                             15.width,
//                             CustomTextField(
//                               text: "", hintText: "Enter Date", controller: expenseProvider.incomeDateController,
//                               readOnly: true,
//                               onTap: (){
//                                 utils.datePick(context: context,textEditingController: expenseProvider.incomeDateController,isDob: false);
//                               },
//                               width: MediaQuery.of(context).size.width*0.7,
//                             ),
//                             15.width,
//                             CustomTextField(
//                               text: "", hintText: "Enter Reason (optional)", controller: expenseProvider.incomeReasonController,
//                               textInputAction: TextInputAction.done,
//                               width: MediaQuery.of(context).size.width*0.7,
//                             ),
//                           ],
//                         ),
//                       ),
//                       actions: [
//                         CustomLoadingButton(
//                             callback: (){
//                               expenseProvider.incomeTypeController.clear();
//                               expenseProvider.incomeDateController.clear();
//                               expenseProvider.incomeReasonController.clear();
//                               Navigator.pop(context);
//                             }, isLoading: false, backgroundColor: Colors.white, radius: 5, width: 100,text: 'Cancel',textColor: Colors.black),
//                         CustomLoadingButton(
//                             callback: (){
//                               String newIncome = expenseProvider.incomeTypeController.text.trim();
//                               String reason = expenseProvider.incomeReasonController.text.trim();
//                               String date = expenseProvider.incomeDateController.text.trim();
//
//                               if (newIncome.isNotEmpty &&double.tryParse(newIncome) != null &&double.parse(newIncome) <= 10000000 &&date.isNotEmpty) {
//                                 expenseProvider.createIncome(
//                                   context: context,
//                                   income: newIncome,
//                                   reason: reason.isNotEmpty ? reason : "",
//                                   date: date,
//                                   userId: localData.storage.read("id"),
//                                 );
//                               } else {
//                                 expenseProvider.saveCtr.reset();
//                                 utils.showWarningToast(context, text: 'Please enter amount and date correctly');
//                               }
//                             }, isLoading: true,controller: expenseProvider.saveCtr,
//                             backgroundColor: colorsConst.primary, radius: 5, width: 100,text: 'Add')
//                       ],
//                     ),
//                   );
//                 },
//               ),
//               SpeedDialChild(
//                 child: SvgPicture.asset(assets.card),
//                 label: 'Expense',
//                 onTap: () {
//                   expenseProvider.filterDateController.clear();
//                   expenseProvider.clearFormData();
//                   expenseProvider.clearItemRows();
//                   expenseProvider.addItemRow();
//                   setState(() {
//                     expenseProvider.selectedIndex = 9;
//                   });
//                 },
//               ),
//             ],
//           ): null,
//                                 floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//         ),
//       );
//     });
//   }
// }
