// import 'package:flutter/services.dart';
// import 'package:master_code/source/extentions/extensions.dart';
// import 'package:master_code/view_model/expasy_provider.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../../component/custom_dropdown.dart';
// import '../../component/custom_dropdownfield.dart';
// import '../../component/custom_loading_button.dart';
// import '../../component/custom_text.dart';
// import '../../component/custom_textfield.dart';
// import '../../model/expasy/income_obj.dart';
// import '../../source/constant/assets_constant.dart';
// import '../../source/constant/colors_constant.dart';
// import '../../source/constant/default_constant.dart';
// import '../../source/constant/local_data.dart';
// import '../../source/utilities/utils.dart';
// import 'edit_expense_page.dart';
// class ListViewScreen extends StatefulWidget {
//   const ListViewScreen({super.key});
//
//   @override
//   State<ListViewScreen> createState() => _ListViewScreenState();
// }
//
// class _ListViewScreenState extends State<ListViewScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
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
//
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
//     double screenWidth = MediaQuery.of(context).size.width;
//   return Consumer<ExpasyProvider>(
//     builder: (context, expenseProvider, _) {
//       var webHeight=MediaQuery.of(context).size.width * 0.5;
//       var phoneHeight=MediaQuery.of(context).size.width * 0.9;
//       return SingleChildScrollView(
//         child: Center(
//           child: SizedBox(
//                 width: kIsWeb?webHeight:phoneHeight,
//             child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       IconButton(
//                         onPressed: ()  async {
//                           /// generateExpenseReport(context,expenseProvider);
//                           // final bytes = Uint8List.fromList([1,2,3,4,5]);
//                           // final name = "test_${DateTime.now().millisecondsSinceEpoch}.bin";7u
//                           // final path = await saveBytesToDownloads(bytes, name);
//                           // print("Test save returned: $path");
//                         },
//
//                         icon: SvgPicture.asset(assets.download),
//                         tooltip: 'Download Expenses',
//                       )
//                     ],
//                   ),
//                   // 5.height,
//                   Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             CustomDropDown(
//                               text: "Select Filter",
//                               valueList: [
//                                 "Select Filter",
//                                 ...expenseProvider.dropFilter,
//                               ],
//                               saveValue: expenseProvider.filters,
//
//                               onChanged: (value) {
//                                 setState(() {
//                                   // expenseProvider.filterSelectedDate = null;
//                                   expenseProvider.filterDateController.clear();
//                                   expenseProvider.selectedMonth = null;
//                                   expenseProvider.filters = value;
//                                   expenseProvider.filterExpensesByRange(value.toString(), null);
//                                 });
//                               },
//                               width: kIsWeb?webHeight/2.2:phoneHeight/2.2,
//                               color: Color(0xFF222222),
//                             ),
//                             SizedBox(
//                               width: kIsWeb?webHeight/2.2:phoneHeight/2.2,
//                               height: 50,
//                               child: OutlinedButton(
//                                 style: OutlinedButton.styleFrom(
//                                   elevation: 0,
//                                   side: BorderSide(
//                                     color:Color(0xFF222222),
//                                   ),
//                                   // backgroundColor:Color(0xFF222222),
//                                 ),
//                                 onPressed: () =>
//                                     expenseProvider.filterDate(context),
//                                 child: IntrinsicHeight(
//                                     child: Row(
//                                       children: [
//                                         Icon(Icons.calendar_today,
//                                             size: 20, color: colorsConst.primary),
//                                         VerticalDivider(
//                                             color: colorsConst.primary,
//                                             thickness: 2),
//                                         Expanded(
//                                           child: CustomText(
//                                             text: expenseProvider
//                                                 .filterDateController
//                                                 .text
//                                                 .isEmpty
//                                                 ? "Select Date"
//                                                 : expenseProvider
//                                                 .filterDateController.text,
//                                             size: 15,
//                                           ),
//                                         ),
//                                         if (expenseProvider
//                                             .filterDateController.text.isNotEmpty)
//                                           IconButton(
//                                             icon: Icon(Icons.close,
//                                                 size: 15,
//                                                 color: colorsConst.primary),
//                                             onPressed: () =>
//                                                 expenseProvider.clearDateFilter(),
//                                           ),
//                                       ],
//                                     )),
//                               ),
//                             ),
//                           ]
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(
//                             width: kIsWeb?webHeight/2.2:phoneHeight/2.2,
//                             height: 50,
//                             child: OutlinedButton(
//                               style: OutlinedButton.styleFrom(
//                                 elevation: 0,
//                                 side: BorderSide(
//                                   color: const Color(0xFF222222),
//                                 ),
//                                 // backgroundColor:const Color(0xFF222222),
//                               ),
//                               onPressed: () async {
//                                 // 👇 Show a month picker dialog
//                                 // final now = DateTime.now();
//                                 // final DateTime? picked = await showMonthPicker(
//                                 //   context: context,
//                                 //   initialDate: expenseProvider.selectedMonth ?? now,
//                                 //   firstDate: DateTime(now.year - 2, 1),
//                                 //   lastDate: DateTime(now.year, now.month),
//                                 // );
//                                 //
//                                 // if (picked != null) {
//                                 //   expenseProvider.setMonthFilter(picked);
//                                 // }
//                               },
//                               child: IntrinsicHeight(
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.calendar_month, size: 20, color: colorsConst.primary),
//                                     VerticalDivider(color: colorsConst.primary, thickness: 2),
//                                     Expanded(
//                                       child: CustomText(
//                                         text: expenseProvider.selectedMonth == null
//                                             ? "Select Month"
//                                             : DateFormat('MMMM yyyy').format(expenseProvider.selectedMonth!),
//                                         size: 13,
//                                       ),
//                                     ),
//                                     if (expenseProvider.selectedMonth != null)
//                                       IconButton(
//                                         icon: Icon(Icons.close, size: 15, color: colorsConst.primary),
//                                         onPressed: () => expenseProvider.clearMonthFilter(),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 "Main Balance",
//                                 style: TextStyle(
//                                   color: Colors.green,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             // 10.height,
//                               10.width,
//                               Consumer<ExpasyProvider>(
//                                 builder: (context, expenseProvider, _) {
//                                   var balance = expenseProvider.mainBalance -
//                                       expenseProvider.totalExpenses;
//                                   if(balance < 0) balance = 0;
//
//                                   return CustomText(
//                                     text: expenseProvider.formattedAmount(balance),
//                                     colors: Colors.green,
//                                     isBold: true,
//                                     size: 20,
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   10.height,
//                   Container(
//                     width: screenWidth - 50,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: Color(0xFF222222),
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         5.height,
//                         // Income Amount
//                         Row(
//                           children: [
//                             const Padding(
//                               padding: EdgeInsets.only(left: 10),
//                               child: CustomText(text: "Income Amount"),
//                             ),
//                             85.width,
//                             Consumer<ExpasyProvider>(
//                               builder: (context, expenseProvider, _) {
//                                 return CustomText(
//                                   text:
//                                   "${constValue.rupeeSign} ${expenseProvider.formatIndianCurrency(expenseProvider.totalIncomeAmount.toString())}",
//                                   colors: colorsConst.primary,
//                                   isBold: true,
//                                   size: 15,
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//
//                         // Expense Amount
//                         Row(
//                           children: [
//                             const Padding(
//                               padding: EdgeInsets.only(left: 10),
//                               child: CustomText(text: "Expense Amount"),
//                             ),
//                             80.width,
//                             Consumer<ExpasyProvider>(
//                               builder: (context, expenseProvider, _) {
//                                 return CustomText(
//                                   text: expenseProvider.formattedAmount(
//                                       expenseProvider.filteredExpenseAmount),
//                                   colors: expenseProvider.filteredExpenseAmount >
//                                       expenseProvider.totalIncomeAmount
//                                       ? Colors.red
//                                       : Colors.blue,
//                                   isBold: true,
//                                   size: 15,
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//
//                   ),
//                   5.height,
//                   DefaultTabController(
//                     length: 2,
//                     child: Column(children: [
//                       const TabBar(
//                         indicatorColor: Colors.blue,
//                         labelColor: Colors.blue,
//                         unselectedLabelColor: Colors.grey,
//                         tabs: [
//                           Tab(text: "Income"),
//                           Tab(text: "Expense"),
//                         ],
//                       ),10.height,
//                       SizedBox(
//                         height: 400,
//                         child: TabBarView(
//                           children: [
//                             Column(
//                               children: [
//                                 expenseProvider.incomeList.isEmpty?
//                                 const Center(
//                                   child: CustomText(
//                                     text: "\n\n\n\nNo incomes found",
//                                     size: 14,
//                                     isBold: true,
//                                   ),
//                                 ):
//                                 Expanded(
//                                   child: GridView.builder(
//                                     shrinkWrap: true,
//                                     physics: const AlwaysScrollableScrollPhysics(),
//                                     itemCount: expenseProvider.incomeList.length,
//                                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                                       crossAxisCount: 2,
//                                       crossAxisSpacing: 10,
//                                       mainAxisSpacing: 20,
//                                       childAspectRatio: 0.95,
//                                     ),
//                                     itemBuilder: (context, index) {
//                                       final item = expenseProvider.incomeList[index]; // item is an IncomeData object
//                                       String formattedDate = '';
//                                       try {
//                                         if (item.date.isNotEmpty) {
//                                           final parsedDate = DateFormat("dd-MM-yyyy").parse(item.date);
//                                           formattedDate = DateFormat('MMM d').format(parsedDate);
//                                         }
//                                       } catch (e) {
//                                         formattedDate = 'Invalid Date';
//                                       }
//                                       return GestureDetector(
//                                         child: Container(
//                                           width: 150,
//                                           decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(16),
//                                             border: Border.all(
//                                               color: const Color(0xFF222222),
//                                             ),
//                                             // color: const Color(0xFF222222),
//                                           ),
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Column(
//                                               children: [
//                                                 // Date
//                                                 Align(
//                                                   alignment: Alignment.topRight,
//                                                   child: CustomText(
//                                                     text: formattedDate,
//                                                     colors: const Color(0xFF96959A),
//                                                     size: 12,
//                                                     isBold: true,
//                                                   ),
//                                                 ),
//                                                 Expanded(
//                                                   child: Column(
//                                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                                     children: [
//                                                       if (item.reason.isNotEmpty && item.reason != "EMPTY")
//                                                       Row(
//                                                           children: [
//                                                             const Icon(Icons.work, size: 18, color: Colors.blue),
//                                                             const SizedBox(width: 6),
//                                                             Expanded(
//                                                               child: CustomText(
//                                                                 text: item.reason,
//                                                                 colors: const Color(0XFF464646),
//                                                                 size: 12,
//                                                                 isBold: false,
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       5.height,
//                                                       Row(
//                                                         children: [
//                                                           const Icon(Icons.currency_rupee, size: 18, color: Colors.green),
//                                                           const SizedBox(width: 6),
//                                                           CustomText(
//                                                             text: expenseProvider.formatIndianCurrency(item.income),
//                                                             colors: const Color(0XFF000000),
//                                                             size: 14,
//                                                             isBold: true,
//                                                           ),
//                                                         ],
//                                                       ),
//                                                       5.height,
//                                                       const DottedDivider(dotSpacing: 3.0, dotColor: Colors.black),
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                         children: [
//                                                           TextButton(
//                                                             onPressed: () async {
//                                                               expenseProvider.incomeTypeController.text=item.income;
//                                                               expenseProvider.incomeReasonController.text=item.reason;
//                                                               showDialog(
//                                                                 context: context,
//                                                                 builder: (context) => AlertDialog(
//                                                                   backgroundColor: Colors.white,
//                                                                   shape: RoundedRectangleBorder(
//                                                                     borderRadius: BorderRadius.circular(15),
//                                                                   ),
//                                                                   title: CustomText(
//                                                                     text:"Update Your Income",isBold: true,
//                                                                     size: 15,
//                                                                   ),
//                                                                   content: SizedBox(
//                                                                     width: 300,
//                                                                     child: Column(
//                                                                       mainAxisSize: MainAxisSize.min,
//                                                                       children: [
//                                                                         CustomTextField(
//                                                                           text: "", hintText: "Enter Income", controller: expenseProvider.incomeTypeController,
//                                                                           keyboardType: TextInputType.number,
//                                                                           inputFormatters: [
//                                                                             FilteringTextInputFormatter.digitsOnly,
//                                                                             LengthLimitingTextInputFormatter(8),
//                                                                           ],
//                                                                           width: MediaQuery.of(context).size.width*0.7,
//                                                                         ),
//                                                                         15.width,
//                                                                         // CustomTextField(
//                                                                         //   text: "", hintText: "Enter Date", controller: expenseProvider.incomeDateController,
//                                                                         //   readOnly: true,
//                                                                         //   onTap: (){
//                                                                         //     utils.datePick(context: context,textEditingController: expenseProvider.incomeDateController,isDob: false);
//                                                                         //   },
//                                                                         //   width: MediaQuery.of(context).size.width*0.7,
//                                                                         // ),
//                                                                         // 15.width,
//                                                                         CustomTextField(
//                                                                           text: "", hintText: "Enter Reason (optional)", controller: expenseProvider.incomeReasonController,
//                                                                           textInputAction: TextInputAction.done,
//                                                                           width: MediaQuery.of(context).size.width*0.7,
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                   actions: [
//                                                                     CustomLoadingButton(
//                                                                         callback: (){
//                                                                           expenseProvider.incomeTypeController.clear();
//                                                                           expenseProvider.incomeDateController.clear();
//                                                                           expenseProvider.incomeReasonController.clear();
//                                                                           Navigator.pop(context);
//                                                                         }, isLoading: false, backgroundColor: Colors.white, radius: 5, width: 100,text: 'Cancel',textColor: Colors.black),
//                                                                     CustomLoadingButton(
//                                                                         callback: (){
//                                                                           final updated = IncomeData(
//                                                                             id: item.id,
//                                                                             income: expenseProvider.incomeTypeController.text,
//                                                                             userId: item.userId,
//                                                                             createdBy: item.createdBy,
//                                                                             updatedBy: item.userId,
//                                                                             date: item.date,
//                                                                             reason: expenseProvider.incomeReasonController.text,
//                                                                           );
//                                                                           if (expenseProvider.incomeTypeController.text.trim().isNotEmpty) {
//                                                                             expenseProvider.updateIncome(context, updated);
//                                                                           }else{
//                                                                             utils.showWarningToast(context, text: "Please fill income");
//                                                                           }
//                                                                         }, isLoading: true,controller: expenseProvider.saveCtr,
//                                                                         backgroundColor: colorsConst.primary, radius: 5, width: 100,text: 'Add')
//                                                                   ],
//                                                                 ),
//                                                               );
//                                                             },
//                                                             child: CustomText(
//                                                               text: 'Edit',colors: Colors.blue),
//                                                           ),
//                                                           TextButton(
//                                                             onPressed: () {
//                                                               utils.customDialog(
//                                                                   context: context,
//                                                                   isLoading: true,
//                                                                   title: 'Do you want to',
//                                                                   title2: 'Delete the income?',
//                                                                   roundedLoadingButtonController: expenseProvider.saveCtr,
//                                                                   callback: () {
//                                                                     expenseProvider.deleteIncome(
//                                                                       context,
//                                                                       item.id,
//                                                                       item.userId,
//                                                                     );
//                                                                   }
//                                                               );
//                                                             },
//                                                             child: CustomText(
//                                                               text:'Delete',colors: Colors.red
//                                                             ),
//                                                           ),
//
//                                                         ],
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 80.height,
//                               ],
//                             ),
//                             RefreshIndicator(
//                               onRefresh: () async {
//                                 expenseProvider.getExpenseList();
//                               },
//                               child: Consumer<ExpasyProvider>(
//                                 builder: (context, expenseProvider, _) {
//                                   if (expenseProvider.isLoading) {
//                                     return const Center(
//                                         child:
//                                         CircularProgressIndicator());
//                                   }
//                                   final filterSelectedDate =
//                                       expenseProvider
//                                           .filterDateController.text;
//                                   final expenses =
//                                       expenseProvider.expensesList;
//                                   // print("expenses.......${jsonEncode(expenses)}");
//
//                                   if (expenses.isEmpty) {
//                                     return const Center(
//                                       child: CustomText(
//                                         text: "No expenses found",
//                                         size: 14,
//                                         isBold: true,
//                                       ),
//                                     );
//                                   }
//                                   String formattedSelectedDate = '';
//                                   try {
//                                     final parsedDate =
//                                     DateFormat('dd-MM-yyyy')
//                                         .parse(filterSelectedDate);
//                                     formattedSelectedDate =
//                                         DateFormat('MMM d')
//                                             .format(parsedDate);
//                                   } catch (e) {
//                                     formattedSelectedDate = '';
//                                   }
//                                   return SingleChildScrollView(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         if (filterSelectedDate
//                                             .isNotEmpty &&
//                                             formattedSelectedDate
//                                                 .isNotEmpty)
//                                           Padding(
//                                             padding:
//                                             const EdgeInsets.only(
//                                                 bottom: 8.0),
//                                             child: CustomText(
//                                               text:
//                                               "${expenses.length} item(s) found on $formattedSelectedDate",
//                                               size: 14,
//                                               isBold: true,
//                                               colors: Colors.black87,
//                                             ),
//                                           ),
//                                         GridView.builder(
//                                           shrinkWrap: true,
//                                           physics:
//                                           const NeverScrollableScrollPhysics(),
//                                           itemCount: expenses.length,
//                                           gridDelegate:
//                                           const SliverGridDelegateWithFixedCrossAxisCount(
//                                             crossAxisCount: 2,
//                                             crossAxisSpacing: 10,
//                                             mainAxisSpacing: 20,
//                                             childAspectRatio: 0.95,
//                                           ),
//                                           itemBuilder: (context, index) {
//                                             final item = expenses[index];
//
//                                             expenseProvider.itemId =
//                                                 item.id.toString();
//                                             return GestureDetector(
//                                               onTap: () async {
//                                                 // 🔹 Fetch latest expense details before navigating
//                                                 await expenseProvider
//                                                     .fetchExpenseById(
//                                                     item.id!);
//                                                 expenseProvider.onItemTapped(
//                                                     8, () {});
//                                               },
//                                               child: Container(
//                                                 width: 150,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                   BorderRadius
//                                                       .circular(16),
//                                                   border: Border.all(
//                                                     color: Colors.grey.shade300,
//                                                   ),
//                                                   color: Colors.white,
//                                                 ),
//                                                 child: Padding(
//                                                   padding:
//                                                   const EdgeInsets
//                                                       .all(8.0),
//                                                   child: Column(
//                                                     children: [
//                                                       Align(
//                                                         alignment:
//                                                         Alignment
//                                                             .topRight,
//                                                         child: CustomText(
//                                                           text: (() {
//                                                             try {
//                                                               if (item
//                                                                   .date!
//                                                                   .toString()
//                                                                   .isNotEmpty) {
//                                                                 final parsedDate = DateFormat(
//                                                                     "dd-MM-yyyy")
//                                                                     .parse(
//                                                                     item.date!);
//                                                                 return DateFormat(
//                                                                     'MMM d')
//                                                                     .format(
//                                                                     parsedDate);
//                                                               } else {
//                                                                 return 'No Date';
//                                                               }
//                                                             } catch (e) {
//                                                               return 'Invalid Date';
//                                                             }
//                                                           })(),
//                                                           colors: const Color(
//                                                               0xFF96959A),
//                                                           size: 12,
//                                                           isBold: true,
//                                                         ),
//                                                       ),
//                                                       Expanded(
//                                                         child: Column(
//                                                           mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceEvenly,
//                                                           children: [
//                                                             Row(
//                                                               children: [
//                                                                 SizedBox(
//                                                                   width:
//                                                                   20,
//                                                                   height:
//                                                                   20,
//                                                                   child: SvgPicture.asset(assets.cart),
//                                                                 ),
//                                                                 const SizedBox(
//                                                                     width:
//                                                                     8),
//                                                                 Expanded(
//                                                                   child:
//                                                                   CustomText(
//                                                                     text: item
//                                                                         .shopName
//                                                                         .toString(),
//                                                                     colors:
//                                                                     const Color(0XFFA0A0A0),
//                                                                     size:
//                                                                     12,
//                                                                     isBold:
//                                                                     true,
//                                                                   ),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                             10.height,
//                                                             Row(
//                                                               children: [
//                                                                 SizedBox(
//                                                                   width:
//                                                                   20,
//                                                                   height:
//                                                                   20,
//                                                                   child: SvgPicture.asset(assets.food),
//                                                                 ),
//                                                                 const SizedBox(
//                                                                     width:
//                                                                     8),
//                                                                 CustomText(
//                                                                   text: item
//                                                                       .expenseHead
//                                                                       .toString(),
//                                                                   colors:
//                                                                   const Color(0XFF464646),
//                                                                   size:
//                                                                   12,
//                                                                   isBold:
//                                                                   false,
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                             10.height,
//                                                             Row(
//                                                               children: [
//                                                                 SizedBox(
//                                                                   width:
//                                                                   20,
//                                                                   height:
//                                                                   20,
//                                                                   child: SvgPicture.asset(
//                                                                       assets.vector),
//                                                                 ),
//                                                                 const SizedBox(
//                                                                     width:
//                                                                     8),
//                                                                 CustomText(
//                                                                   text: expenseProvider.formatIndianCurrency(item
//                                                                       .amount
//                                                                       .toString()),
//                                                                   colors:
//                                                                   const Color(0XFF000000),
//                                                                   size:
//                                                                   12,
//                                                                   isBold:
//                                                                   true,
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                             10.height,
//                                                             const DottedDivider(
//                                                                 dotSpacing:
//                                                                 3.0,
//                                                                 dotColor:
//                                                                 Colors
//                                                                     .black),
//                                                             Material(
//                                                               color: Colors
//                                                                   .transparent, // if you don’t want any background
//                                                               child: Row(
//                                                                 mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                                 children: [
//                                                                   // InkWell(
//                                                                   //   onTap:
//                                                                   //       () {
//                                                                   //     expenseProvider.fetchExpenseById(item.id!);
//                                                                   //
//                                                                   //     print("particulars.......${item.particulars}");
//                                                                   //
//                                                                   //     final existingData =
//                                                                   //         {
//                                                                   //       'date': item.date,
//                                                                   //       'user_account': item.userAccount,
//                                                                   //       'expense_head': item.expenseHead,
//                                                                   //       'payment_type': item.paymentType,
//                                                                   //       'shop_name': item.shop,
//                                                                   //       'city': item.city,
//                                                                   //       'particulars': item.particulars,
//                                                                   //       'amount': item.amount.toString() ?? '0',
//                                                                   //       'gst': item.gst.toString(),
//                                                                   //     };
//                                                                   //     expenseProvider.dataRows.addAll(existingData);
//                                                                   //
//                                                                   //
//                                                                   //     // final existingRows = expenseProvider.itemRows ?? [];
//                                                                   //     expenseProvider.clearItemRows();
//                                                                   //     expenseProvider.addItemRow();
//                                                                   //     expenseProvider.setItemRowsFromExpenseList(item.expenseList);
//                                                                   //     final existingRows =
//                                                                   //         expenseProvider.itemRows ?? [];
//                                                                   //     setState(() {
//                                                                   //       // expenseProvider.onItemTapped(11, () {});
//                                                                   //       expenseProvider.selectedIndex = 11;
//                                                                   //       Navigator.push(
//                                                                   //           context,
//                                                                   //           MaterialPageRoute(
//                                                                   //             builder: (context) => EditExpense(
//                                                                   //               isEditing: true,
//                                                                   //               initialItemRows: expenseProvider.itemRows,
//                                                                   //               initialData: expenseProvider.dataRows,
//                                                                   //               expenseId: item.id,
//                                                                   //               item_id: item.id,
//                                                                   //             ),
//                                                                   //           ));
//                                                                   //     });
//                                                                   //   },
//                                                                   //   child: const Text(
//                                                                   //       'Edit',
//                                                                   //       style: TextStyle(color: Colors.blue)),
//                                                                   // ),
//                                                                   InkWell(
//                                                                     onTap:
//                                                                         () async {
//                                                                       // Fetch Expense by Id
//                                                                       await expenseProvider.fetchExpenseById(item.id!);
//
//                                                                       if (expenseProvider.selectedExpense.isEmpty) {
//                                                                         print("No expense found for ID: ${item.id}");
//                                                                         return;
//                                                                       }
//                                                                       print("particulars.......${item.particulars}");
//                                                                       final expense =
//                                                                       expenseProvider.selectedExpense[0]; // 👈 latest API data
//
//                                                                       // ✅ Assign old data properly
//                                                                       final existingData =
//                                                                       {
//                                                                         'date': expense.date,
//                                                                         'user_account': expense.userAccount,
//                                                                         'expense_head': expense.expenseHead,
//                                                                         'payment_type': expense.paymentType,
//                                                                         'shop_name': expense.shopName,
//                                                                         'city': expense.city,
//                                                                         'particulars': expense.particulars,
//                                                                         'amount': expense.amount.toString() ?? '0',
//                                                                         'gst': expense.gst.toString() ?? '0',
//                                                                       };
//                                                                       expenseProvider.dataRows.addAll(existingData);
//                                                                       print("dataRows.................${expenseProvider.dataRows}");
//                                                                       expenseProvider.clearItemRows();
//                                                                       if (expense.expenseList.isNotEmpty) {
//                                                                         expenseProvider.setItemRowsFromExpenseList(expense.expenseList);
//                                                                       }
//                                                                       // ✅ Navigate cleanly
//                                                                       // expenseProvider.selectedIndex =
//                                                                       //     11;
//                                                                       Navigator.push(
//                                                                         context,
//                                                                         MaterialPageRoute(
//                                                                           builder: (context) => EditExpense(
//                                                                             isEditing: true,
//                                                                             initialItemRows: expenseProvider.itemRows,
//                                                                             initialData: expenseProvider.dataRows,
//                                                                             expenseId: expense.id,
//                                                                             item_id: expenseProvider.itemId,
//                                                                           ),
//                                                                         ),
//                                                                       );
//                                                                     },
//                                                                     child:
//                                                                     const Text(
//                                                                       'Edit',
//                                                                       style:
//                                                                       TextStyle(color: Colors.blue),
//                                                                     ),
//                                                                   ),
//                                                                   InkWell(
//                                                                     onTap: () {
//                                                                       utils.customDialog(
//                                                                           context: context,
//                                                                           isLoading: true,
//                                                                           title: 'Do you want to',
//                                                                           title2: 'Delete the expense?',
//                                                                           roundedLoadingButtonController: expenseProvider.saveCtr,
//                                                                           callback: () {
//                                                                             expenseProvider.deleteExpenseFromUI(
//                                                                               context: context,
//                                                                               expenseId: item.id.toString(),
//                                                                               userId: localData.storage.read("id"),
//                                                                               shouldDelete: false,
//                                                                             );
//                                                                           }
//                                                                       );
//                                                                     },
//                                                                     child: const Text(
//                                                                         'Delete',
//                                                                         style: TextStyle(color: Colors.red)),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ]),
//                   ),
//                 ]),
//               )));
//     });
//   }
//
// }
