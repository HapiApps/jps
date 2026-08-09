// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
// import '../../component/custom_dropdownfield.dart';
// import '../../component/custom_text.dart';
// import '../../source/constant/colors_constant.dart';
// import '../../view_model/expasy_provider.dart';
//
// class SimpleExpense extends StatefulWidget {
//   const SimpleExpense({super.key});
//
//   @override
//   State<SimpleExpense> createState() => _SimpleExpenseState();
// }
//
// class _SimpleExpenseState extends State<SimpleExpense> {
//   String selectedGroup = "";
//   final TextEditingController amountController = TextEditingController();
//   final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
//   @override
//   void dispose() {
//     amountController.dispose();
//     Provider.of<ExpasyProvider>(context, listen: false).clearSimpleExpenseForm();
//
//     super.dispose();
//   }
//
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ExpasyProvider>(context, listen: false).initializeUserDataNew();
//       Provider.of<ExpasyProvider>(context, listen: false).loadShops();
//     });
//   }
//
//   void showAddDialog(String title, TextEditingController controller, VoidCallback onAdd) {
//     // showDialog(
//     //   context: context,
//     //   builder: (context) => CustomAlert(
//     //     titleText: title,
//     //     hintText: "Enter $title",
//     //     controller: controller,
//     //     onAddPressed: onAdd,
//     //     onCancelPressed: () => Navigator.pop(context),
//     //   ),
//     // );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ExpasyProvider>(builder: (context,expensePvr,_){
//       return Scaffold(
//         body:Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 900),
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Material(
//                 color: Colors.white,
//                 child: Card(
//                   color: Colors.white,
//                   elevation: 10,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 16),
//                           SizedBox(
//                             height: 50,
//                             child: SingleChildScrollView(
//                               scrollDirection: Axis.horizontal,
//                               child: Row(
//                                 children: [
//                                   buildGroupButton("Date"),
//                                   buildGroupButton("Account"),
//                                   buildGroupButton("Shop"),
//                                   buildGroupButton("City"),
//                                   buildGroupButton("Expansion Head"),
//                                   buildGroupButton("Payment Type"),
//                                   buildGroupButton("Amount"),
//                                 ].map((e) => Padding(
//                                   padding: const EdgeInsets.only(right: 8),
//                                   child: e,
//                                 )).toList(),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           const SizedBox(height: 12),
//                           if ([
//                             "Account",
//                             "Shop",
//                             "Expansion Head",
//                             "Payment Type"
//                           ].contains(selectedGroup))
//                             Align(
//                               alignment: Alignment.centerRight,
//                               child: IconButton(
//                                 icon: Icon(Icons.add_circle_outline,
//                                     color: colorsConst.primary),
//                                 onPressed: () {
//                                   if (selectedGroup == "Account") {
//                                     showAddDialog(
//                                       "Account",
//                                       expensePvr.accountControllerNew,
//                                           () {
//                                         final value = expensePvr
//                                             .accountControllerNew.text
//                                             .trim();
//                                         if (value.isNotEmpty) {
//                                           expensePvr.saveNewAccountNew(value);
//                                           expensePvr.accountControllerNew.clear();
//                                           Navigator.pop(context);
//                                         }
//                                       },
//                                     );
//                                   } else if (selectedGroup == "Shop") {
//                                     showAddDialog(
//                                       "Shop",
//                                       expensePvr.shopNameController,
//                                           () {
//                                         final value = expensePvr
//                                             .shopNameController.text
//                                             .trim();
//                                         if (value.isNotEmpty) {
//                                           expensePvr.saveNewShop(value);
//                                           expensePvr.shopNameController.clear();
//                                           Navigator.pop(context);
//                                         }
//                                       },
//                                     );
//                                   } else if (selectedGroup == "Expansion Head") {
//                                     showAddDialog(
//                                       "Expansion Head",
//                                       expensePvr.headController,
//                                           () {
//                                         final value = expensePvr
//                                             .headController.text
//                                             .trim();
//                                         if (value.isNotEmpty) {
//                                           expensePvr.saveExpansionHead(value);
//                                           expensePvr.headController.clear();
//                                           Navigator.pop(context);
//                                         }
//                                       },
//                                     );
//                                   } else if (selectedGroup == "Payment Type") {
//                                     showAddDialog(
//                                       "Payment Type",
//                                       expensePvr.paymentController,
//                                           () {
//                                         final value = expensePvr
//                                             .paymentController.text
//                                             .trim();
//                                         if (value.isNotEmpty) {
//                                           expensePvr.savePaymentType(value);
//                                           expensePvr.paymentController.clear();
//                                           Navigator.pop(context);
//                                         }
//                                       },
//                                     );
//                                   }
//                                 },
//                               ),
//                             ),
//                           if (selectedGroup == "Date")
//                             buildDateSelector(expensePvr),
//                           if (selectedGroup == "Account")
//                             buildDropdown(
//                               "Select Account",
//                               expensePvr.newaccounts,
//                               expensePvr.selectedNewAccount,
//                                   (value) =>
//                                       expensePvr.setSelectedAccountNew(value!),
//                             ),
//                           if (selectedGroup == "Shop")
//                             buildDropdown(
//                               "Select Shop",
//                               expensePvr.shop,
//                               expensePvr.selectShop,
//                                   (value) => expensePvr.setShop(value!),
//                             ),
//                           if (selectedGroup == "City")
//                             buildDropdown(
//                               "Select City",
//                               expensePvr.city,
//                               expensePvr.selectCity,
//                                   (value) => expensePvr.setCity(value!),
//                             ),
//                           if (selectedGroup == "Expansion Head")
//                             buildChips(
//                               expensePvr.expansionHead,
//                               expensePvr.selectHead,
//                                   (value) => expensePvr.setExpansionHead(value),
//                             ),
//                           if (selectedGroup == "Payment Type")
//                             buildPaymentIcons(
//                               expensePvr.paymentMethods,
//                               expensePvr.selectPaymentType,
//                                   (value) => expensePvr.setPaymentType(value),
//                             ),
//                           if (selectedGroup == "Amount") ...[
//                             const Align(
//                               alignment: Alignment.centerLeft,
//                               child: CustomText(
//                                 text: "Amount",
//                                 size: 15,
//                                 isBold: true,
//                                 colors: Color(0XFF96959A),
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 4),
//                               child: TextFormField(
//                                 controller: expensePvr.amountController,
//                                 keyboardType: const TextInputType
//                                     .numberWithOptions(decimal: true),
//                                 decoration: const InputDecoration(
//                                   hintText: "Amount",
//                                   border: OutlineInputBorder(),
//                                   contentPadding: EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 10),
//                                 ),
//                                 onChanged: (value) {
//                                   String raw =
//                                   value.replaceAll(RegExp(r'[^0-9.]'), '');
//                                   int dotIndex = raw.indexOf('.');
//                                   if (dotIndex != -1) {
//                                     raw = raw.substring(0, dotIndex + 1) +
//                                         raw.substring(dotIndex + 1)
//                                             .replaceAll('.', '');
//                                   }
//
//                                   if (raw.isEmpty) {
//                                     expensePvr.amountController.text = '';
//                                     return;
//                                   }
//
//                                   final parts = raw.split('.');
//                                   String formatted = NumberFormat.currency(
//                                     locale: 'en_IN',
//                                     symbol: '',
//                                     decimalDigits: parts.length > 1
//                                         ? parts[1].length.clamp(0, 2)
//                                         : 0,
//                                   ).format(double.tryParse(raw) ?? 0);
//
//                                   if (parts.length > 1 && parts[1].isEmpty) {
//                                     formatted += '.';
//                                   }
//
//                                   final controller =
//                                       expensePvr.amountController;
//
//                                   if (formatted != controller.text) {
//                                     controller.value = TextEditingValue(
//                                       text: formatted,
//                                       selection: TextSelection.collapsed(
//                                           offset: formatted.length),
//                                     );
//                                   }
//                                 },
//                               ),
//                             ),
//                           ],
//                           const SizedBox(height: 20),
//                           SizedBox(
//                             width: double.infinity,
//                             child: RoundedLoadingButton(
//                               controller: _btnController,
//                               color: colorsConst.primary,
//                               borderRadius: 12,
//                               onPressed: () async {
//                                 final isSaved = expensePvr
//                                     .saveSimpleExpenses(context);
//
//                                 if (isSaved) {
//                                   await Future.delayed(const Duration(seconds: 1));
//                                 }
//
//                                 _btnController.reset();
//                               },
//                               child: const Text("Save",
//                                   style: TextStyle(color: Colors.white)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//
//         // Center(
//         //   child: ConstrainedBox(
//         //     constraints: const BoxConstraints(maxWidth: 500),
//         //     child: Padding(
//         //       padding: const EdgeInsets.all(12),
//         //       child: SizedBox(
//         //         height: 300,
//         //         child: Material(
//         //           color: Colors.white,
//         //           child: Card(
//         //             color: Colors.white,
//         //             elevation: 10,
//         //             shape: RoundedRectangleBorder(
//         //                 borderRadius: BorderRadius.circular(16)),
//         //             child: Padding(
//         //               padding: const EdgeInsets.all(16),
//         //               child:Column(
//         //                 children: [
//         //                   Expanded(
//         //                     child: SingleChildScrollView(
//         //                       padding: const EdgeInsets.all(16),
//         //                       child: Column(
//         //                         crossAxisAlignment: CrossAxisAlignment.start,
//         //                         children: [
//         //                           const SizedBox(height: 16),
//         //                           SizedBox(
//         //                             height: 45,
//         //                             child: ListView(
//         //                               scrollDirection: Axis.horizontal,
//         //                               padding: const EdgeInsets.symmetric(horizontal: 12),
//         //                               children: [
//         //                                 buildGroupButton("Date"),
//         //                                 buildGroupButton("Account"),
//         //                                 buildGroupButton("Shop"),
//         //                                 buildGroupButton("City"),
//         //                                 buildGroupButton("Expansion Head"),
//         //                                 buildGroupButton("Payment Type"),
//         //                                 buildGroupButton("Amount"),
//         //                               ],
//         //                             ),
//         //                           ),
//         //                           const SizedBox(height: 12),
//         //                           if ([
//         //                             "Account",
//         //                             "Shop",
//         //                             "Expansion Head",
//         //                             "Payment Type"
//         //                           ].contains(selectedGroup))
//         //                             Align(
//         //                               alignment: Alignment.centerRight,
//         //                               child: IconButton(
//         //                                 icon: Icon(Icons.add_circle_outline, color: colorsConst.primary),
//         //                                 onPressed: () {
//         //                                   if (selectedGroup == "Account") {
//         //                                     showAddDialog(
//         //                                       "Account",
//         //                                       ExpasyProvider.accountControllerNew,
//         //                                           () {
//         //                                         final value = ExpasyProvider.accountControllerNew.text.trim();
//         //                                         if (value.isNotEmpty) {
//         //                                           ExpasyProvider.saveNewAccountNew(value);
//         //                                           ExpasyProvider.accountControllerNew.clear();
//         //                                           Navigator.pop(context);
//         //                                         }
//         //                                       },
//         //                                     );
//         //                                   } else if (selectedGroup == "Shop") {
//         //                                     showAddDialog(
//         //                                       "Shop",
//         //                                       ExpasyProvider.shopNameController,
//         //                                           () {
//         //                                         final value = ExpasyProvider.shopNameController.text.trim();
//         //                                         if (value.isNotEmpty) {
//         //                                           ExpasyProvider.saveNewShop(value);
//         //                                           ExpasyProvider.shopNameController.clear();
//         //                                           Navigator.pop(context);
//         //                                         }
//         //                                       },
//         //                                     );
//         //                                   } else if (selectedGroup == "Expansion Head") {
//         //                                     showAddDialog(
//         //                                       "Expansion Head",
//         //                                       ExpasyProvider.headController,
//         //                                           () {
//         //                                         final value = ExpasyProvider.headController.text.trim();
//         //                                         if (value.isNotEmpty) {
//         //                                           ExpasyProvider.saveExpansionHead(value);
//         //                                           ExpasyProvider.headController.clear();
//         //                                           Navigator.pop(context);
//         //                                         }
//         //                                       },
//         //                                     );
//         //                                   } else if (selectedGroup == "Payment Type") {
//         //                                     showAddDialog(
//         //                                       "Payment Type",
//         //                                       ExpasyProvider.paymentController,
//         //                                           () {
//         //                                         final value = ExpasyProvider.paymentController.text.trim();
//         //                                         if (value.isNotEmpty) {
//         //                                           ExpasyProvider.savePaymentType(value);
//         //                                           ExpasyProvider.paymentController.clear();
//         //                                           Navigator.pop(context);
//         //                                         }
//         //                                       },
//         //                                     );
//         //                                   }
//         //                                 },
//         //                               ),
//         //                             ),
//         //                           if (selectedGroup == "Date")
//         //                             buildDateSelector(ExpasyProvider),
//         //                           if (selectedGroup == "Account")
//         //                             buildDropdown(
//         //                               "Select Account",
//         //                               ExpasyProvider.newaccounts,
//         //                               ExpasyProvider.selectedNewAccount,
//         //                                   (value) => ExpasyProvider.setSelectedAccountNew(value!),
//         //                             ),
//         //                           if (selectedGroup == "Shop")
//         //                             buildDropdown(
//         //                               "Select Shop",
//         //                               expensePvr.shop,
//         //                               expensePvr.selectShop,
//         //                                   (value) => ExpasyProvider.setShop(value!),
//         //                             ),
//         //                           if (selectedGroup == "City")
//         //                             buildDropdown(
//         //                               "Select City",
//         //                               expensePvr.city,
//         //                               expensePvr.selectCity,
//         //                                   (value) => ExpasyProvider.setCity(value!),
//         //                             ),
//         //                           if (selectedGroup == "Expansion Head")
//         //                             buildChips(
//         //                               expensePvr.expansionHead,
//         //                               expensePvr.selectHead,
//         //                                   (value) => ExpasyProvider.setExpansionHead(value),
//         //                             ),
//         //                           if (selectedGroup == "Payment Type")
//         //                             buildPaymentIcons(
//         //                               expensePvr.paymentMethods,
//         //                               expensePvr.selectPaymentType,
//         //                                   (value) => ExpasyProvider.setPaymentType(value),
//         //                             ),
//         //                           if (selectedGroup == "Amount") ...[
//         //                             Align(
//         //                               alignment: Alignment.centerLeft,
//         //                               child: CustomText(
//         //                                 text: "Amount",
//         //                                 size: 15,
//         //                                 isBold: true,
//         //                                 colors: const Color(0XFF96959A),
//         //                               ),
//         //                             ),
//         //                             const SizedBox(height: 6),
//         //                             Padding(
//         //                               padding: const EdgeInsets.symmetric(horizontal: 4),
//         //                               child:TextFormField(
//         //                                 controller: ExpasyProvider.amountController,
//         //                                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//         //                                 decoration: const InputDecoration(
//         //                                   hintText: "Amount",
//         //                                   border: OutlineInputBorder(),
//         //                                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         //                                 ),
//         //                                 // inputFormatters: [
//         //                                 //   FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')), // Allows up to 2 decimal places
//         //                                 //   LengthLimitingTextInputFormatter(15),
//         //                                 // ],
//         //                                 onChanged: (value) {
//         //                                   // Allow digits and only one dot
//         //                                   String raw = value.replaceAll(RegExp(r'[^0-9.]'), '');
//         //
//         //                                   // Avoid multiple dots
//         //                                   int dotIndex = raw.indexOf('.');
//         //                                   if (dotIndex != -1) {
//         //                                     raw = raw.substring(0, dotIndex + 1) +
//         //                                         raw.substring(dotIndex + 1).replaceAll('.', '');
//         //                                   }
//         //
//         //                                   if (raw.isEmpty) {
//         //                                     ExpasyProvider.amountController.text = '';
//         //                                     return;
//         //                                   }
//         //
//         //                                   // Preserve decimal digits as typed
//         //                                   final parts = raw.split('.');
//         //                                   String formatted = NumberFormat.currency(
//         //                                     locale: 'en_IN',
//         //                                     symbol: '',
//         //                                     decimalDigits: parts.length > 1 ? parts[1].length.clamp(0, 2) : 0,
//         //                                   ).format(double.tryParse(raw) ?? 0);
//         //
//         //                                   if (parts.length > 1 && parts[1].isEmpty) {
//         //                                     formatted += '.';
//         //                                   }
//         //
//         //                                   final controller = ExpasyProvider.amountController;
//         //
//         //                                   if (formatted != controller.text) {
//         //                                     controller.value = TextEditingValue(
//         //                                       text: formatted,
//         //                                       selection: TextSelection.collapsed(offset: formatted.length),
//         //                                     );
//         //                                   }
//         //                                 },
//         //                               ),
//         //
//         //                               // TextFormField(
//         //                               //   controller: ExpasyProvider.amountController,
//         //                               //   keyboardType: const TextInputType.numberWithOptions(decimal: true),
//         //                               //   decoration: const InputDecoration(
//         //                               //     hintText: "Amount",
//         //                               //     border: OutlineInputBorder(),
//         //                               //     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         //                               //   ),
//         //                               //   inputFormatters: [
//         //                               //     LengthLimitingTextInputFormatter(15),
//         //                               //   ],
//         //                               //   onChanged: (value) {
//         //                               //     // Remove anything other than numbers and dot
//         //                               //     String raw = value.replaceAll(RegExp(r'[^0-9.]'), '');
//         //                               //
//         //                               //     if (raw.isEmpty) {
//         //                               //       ExpasyProvider.amountController.text = '';
//         //                               //       return;
//         //                               //     }
//         //                               //
//         //                               //     // Format to Indian currency
//         //                               //     String formatted = formatIndianCurrency(raw);
//         //                               //
//         //                               //     final controller = ExpasyProvider.amountController;
//         //                               //
//         //                               //     // Avoid infinite loop
//         //                               //     if (formatted != controller.text) {
//         //                               //       controller.value = TextEditingValue(
//         //                               //         text: formatted,
//         //                               //         selection: TextSelection.collapsed(offset: formatted.length),
//         //                               //       );
//         //                               //     }
//         //                               //
//         //                               //     // ExpasyProvider.updateTotalAmountWithGST();
//         //                               //   },
//         //                               // ),
//         //                             )
//         //                           ],
//         //                           const SizedBox(height: 20),
//         //                           SizedBox(
//         //                             width: double.infinity,
//         //                             child: RoundedLoadingButton(
//         //                               controller: _btnController,
//         //                               color: colorsConst.primary,
//         //                               borderRadius: 12,
//         //                               onPressed: () async {
//         //                                 final isSaved = ExpasyProvider.saveSimpleExpenses(context);
//         //
//         //                                 if (isSaved) {
//         //                                   // Wait before resetting to show success
//         //                                   await Future.delayed(Duration(seconds: 1));
//         //                                 }
//         //
//         //                                 _btnController.reset(); // Always reset button regardless
//         //                               },
//         //                               child: Text("Save", style: TextStyle(color: Colors.white)),
//         //                             ),
//         //                           ),
//         //
//         //                         ],
//         //                       ),
//         //                     ),
//         //                   ),
//         //                 ],
//         //               ),
//         //             ),
//         //           ),
//         //         ),
//         //       ),
//         //     ),
//         //   ),
//         // ),
//       );
//     });
//   }
//
// Widget buildGroupButton(String label) {
//     final isSelected = selectedGroup == label;
//     return Padding(
//       padding: const EdgeInsets.only(right: 10),
//       child: GestureDetector(
//         onTap: () => setState(() => selectedGroup = label),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           decoration: BoxDecoration(
//             color: isSelected ? colorsConst.primary : const Color(0xffF7F7F7),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: const Color(0xffE0E0E0)),
//           ),
//           child: CustomText(
//             text: label,
//             colors: isSelected ? Colors.white : Colors.black,
//             size: 14,
//             isBold: true,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildDateSelector(ExpasyProvider provider) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.arrow_left),
//             onPressed: () {
//               final newDate = (provider.selectedNewDate ?? DateTime.now()).subtract(const Duration(days: 1));
//               provider.setDates(newDate);
//             },
//           ),
//           Expanded(
//             child: GestureDetector(
//               onTap: () => provider.selectDate(context),
//               child: AbsorbPointer(
//                 child: TextFormField(
//                   controller: provider.dateControllerNew,
//                   decoration: const InputDecoration(hintText: 'Select Date'),
//                 ),
//               ),
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.arrow_right),
//             onPressed: () {
//               final newDate = (provider.selectedNewDate ?? DateTime.now()).add(const Duration(days: 1));
//               provider.setDates(newDate);
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildDropdown(String hint, List<String> items, String? selected, ValueChanged<String?> onChanged) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: CustomDropdownField(
//         selectedValue: selected,
//         items: items,
//         hintText: hint,
//         onChanged: onChanged,
//       ),
//     );
//   }
//
//   Widget buildChips(List<String> items, String? selected, ValueChanged<String> onTap) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: SizedBox(
//         height: 45,
//         child: ListView(
//           scrollDirection: Axis.horizontal,
//           children: items.map((e) {
//             final isSelected = selected == e;
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               child: GestureDetector(
//                 onTap: () => onTap(e),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     color: isSelected ? colorsConst.primary : const Color(0xffF7F7F7),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: const Color(0xffE0E0E0)),
//                   ),
//                   child: Center(
//                     child: CustomText(
//                       text: e,
//                       colors: isSelected ? Colors.white : Colors.black,
//                       size: 14,
//                       isBold: true,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//   String formatIndianCurrency(String value) {
//     double amount = double.tryParse(value.replaceAll(",", "")) ?? 0;
//
//     bool hasDecimal = value.contains('.') && value.split('.')[1].isNotEmpty;
//
//     return NumberFormat.currency(
//       locale: 'en_IN',
//       symbol: '',
//       decimalDigits: hasDecimal ? 2 : 0, // Only show decimals if user entered
//     ).format(amount);
//   }
//
//
//   // String formatIndianCurrency(String value) {
//   //   if (value.isEmpty) return '';
//   //
//   //   // Split decimal part if any
//   //   List<String> parts = value.split(".");
//   //   String intPart = parts[0];
//   //   String decPart = parts.length > 1 ? parts[1] : "";
//   //
//   //   // Format integer part to Indian number system
//   //   String result = '';
//   //   int len = intPart.length;
//   //
//   //   if (len > 3) {
//   //     result = intPart.substring(len - 3);
//   //     intPart = intPart.substring(0, len - 3);
//   //
//   //     while (intPart.length > 2) {
//   //       result = '${intPart.substring(intPart.length - 2)},$result';
//   //       intPart = intPart.substring(0, intPart.length - 2);
//   //     }
//   //
//   //     if (intPart.isNotEmpty) {
//   //       result = '$intPart,$result';
//   //     }
//   //   } else {
//   //     result = intPart;
//   //   }
//   //
//   //   return decPart.isNotEmpty ? "$result.$decPart" : result;
//   // }
//
//   Widget buildPaymentIcons(List<Map<String, dynamic>> methods, String? selected, ValueChanged<String> onTap) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: SizedBox(
//         height: 70,
//         child: ListView(
//           scrollDirection: Axis.horizontal,
//           children: methods.map((method) {
//             final isSelected = selected == method['label'];
//             return GestureDetector(
//               onTap: () => onTap(method['label']!),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 4),
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: isSelected ? colorsConst.primary : const Color(0xffD9D9D9),
//                       ),
//                       child: SvgPicture.asset(
//                         method['icon']!,
//                         height: 24,
//                         width: 24,
//                         colorFilter: ColorFilter.mode(
//                           isSelected ? Colors.white : const Color(0xff96959A),
//                           BlendMode.srcIn,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     CustomText(
//                       text: method['label']!,
//                       colors: isSelected ? colorsConst.primary : const Color(0xff96959A),
//                       size: 10,
//                       isBold: true,
//                     )
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }