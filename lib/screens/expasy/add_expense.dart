import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/component/maxline_textfield.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../component/custom_alert.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_dropdownfield.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../view_model/expasy_provider.dart';


class AddExpense extends StatefulWidget {
  final bool isEditing;
  final String? expenseId;
  final String? item_id;
  final List<Map<String, TextEditingController>>? initialItemRows;
  final Map<String, dynamic>? initialData;
  const AddExpense({super.key,
    this.initialItemRows, this.initialData, this.isEditing = false,this.expenseId,
    this.item_id
  });

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final FocusNode accountFocus = FocusNode();
  final FocusNode expenseHeadFocus = FocusNode(); // expansion head
  final FocusNode paymentFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpasyProvider>(context, listen: false).initializeUserData();
    });
    final expasyProvider = Provider.of<ExpasyProvider>(context, listen: false);

    expasyProvider.dateController.text =
        DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  final bool isSaving = false;
  @override
  void dispose() {
    // Dispose FocusNodes to prevent memory leaks

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer<ExpasyProvider>(
        builder: (context, expasyProvider, child) {
          expasyProvider.setShop(expasyProvider.shop[0]);
          expasyProvider.setCity(expasyProvider.cities[0]);
          return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(300, 50),
            child: CustomAppbar(text: constValue.addExp),
          ),
          body: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Center(
              child: SingleChildScrollView(
                // scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              5.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextField(
                                        controller: expasyProvider.dateController,
                                        text: "Select Date",
                                        obsure: false,
                                        readOnly: false,
                                        onChanged: (value) {
                                          expasyProvider.handleDateInput(value.toString());
                                        },
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          expasyProvider.selectDate(context);
                                        },
                                        // suffixIcon: IconButton(
                                        //   icon: const Icon(Icons.calendar_today,color: Colors.grey),
                                        //   onPressed: () {
                                        //     expasyProvider.selectDate(context);
                                        //   },
                                        // ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20), // space between the two columns
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Expanded(
                                            child: CustomText(text: "Account",size: 13,
                                              isBold: false,),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => CustomAlert(
                                                  titleText: "Add New Account Head",
                                                  hintText: "Account Name",
                                                  controller: expasyProvider.accountController,
                                                  onAddPressed: () {
                                                    String newAccount = expasyProvider.accountController.text.trim();
                                                    if (newAccount.isNotEmpty) {
                                                      expasyProvider.saveNewAccount(newAccount);
                                                      expasyProvider.accountController.clear();
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  onCancelPressed: () => Navigator.pop(context),
                                                ),
                                              );
                                            },
                                            child: const Icon(Icons.add, size: 25),
                                          ),
                                        ],
                                      ),
                                      // const SizedBox(height: 8),
                                      Focus(
                                        focusNode: accountFocus,
                                        onKey: (node, event) {
                                          if (event.logicalKey == LogicalKeyboardKey.enter ||
                                              event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                            accountFocus.requestFocus();
                                            return KeyEventResult.handled;
                                          }
                                          return KeyEventResult.ignored;
                                        },
                                        child: CustomDropdownField(
                                          selectedValue: expasyProvider.selectedAccount,
                                          items: expasyProvider.accounts,
                                          hintText: "Select Account",
                                          onChanged: (newValue) {
                                            expasyProvider.setSelectedAccount(newValue!);
                                          },
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                            5.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const CustomText(
                                    text: "Expansion Head",
                                    size: 13,
                                    isBold: false,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            CustomAlert(
                                              titleText: "Add New Expansion Head",
                                              hintText: "Title Name",
                                              controller: expasyProvider
                                                  .headController,
                                              onAddPressed: () async {
                                                String newHead =
                                                expasyProvider.headController.text
                                                    .trim();
                                                if (newHead.isNotEmpty) {
                                                  await expasyProvider
                                                      .saveExpansionHead(newHead);
                                                  expasyProvider.headController
                                                      .clear();
                                                  Navigator.pop(context);
                                                }
                                              },
                                              onCancelPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.add,
                                      size: 25,
                                    ),
                                  ),
                                ],
                              ),
                              Focus(
                                focusNode: expenseHeadFocus,
                                onKey: (node, event) {

                                  // ↑ GO BACK TO Account
                                  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                    accountFocus.requestFocus();
                                    return KeyEventResult.handled;
                                  }

                                  // ↓ or ENTER → Go to Payment section
                                  if (event.logicalKey == LogicalKeyboardKey.enter ||
                                      event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                    paymentFocus.requestFocus();
                                    return KeyEventResult.handled;
                                  }

                                  // Allow left/right inside list
                                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                                      event.logicalKey == LogicalKeyboardKey.arrowRight) {
                                    return KeyEventResult.handled;
                                  }

                                  return KeyEventResult.ignored;
                                },

                                child: SizedBox(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: List.generate(
                                        expasyProvider.expansionHeads.length, (index) {
                                        final isSelected = expasyProvider.selectedHead ==
                                            expasyProvider.expansionHeads[index];

                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                                          child: InkWell(
                                            onTap: () {
                                              expasyProvider.setExpansionHead(
                                                  expasyProvider.expansionHeads[index]);
                                            },
                                            child: Container(
                                              width: 120,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? colorsConst.primary
                                                    : const Color(0xffF7F7F7),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: const Color(0xffE0E0E0),
                                                ),
                                              ),
                                              child: Center(
                                                child: CustomText(
                                                  text: expasyProvider.expansionHeads[index],
                                                  colors: isSelected ? Colors.white : Colors.black,
                                                  isBold: true,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              //ToDo:Expense Head
                              5.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const CustomText(
                                    text: " Payment Type",
                                    size: 13,
                                    isBold: false,
                                  ),
                                  InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              AlertDialog(
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius
                                                      .circular(15),
                                                ),
                                                title: const CustomText(
                                                  text: "Add New Payment Type",
                                                  colors: Color(0xff212121),
                                                  isBold: true,
                                                  size: 15,
                                                ),
                                                content: ConstrainedBox(
                                                  constraints: const BoxConstraints(maxWidth: 400),
                                                  child: Consumer<
                                                      ExpasyProvider>(
                                                    builder: (context, expasyProvider,
                                                        _) {
                                                      return SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize
                                                              .min,
                                                          children: [
                                                            SizedBox(
                                                              width: 200,
                                                              child: CustomTextField(
                                                                textCapitalization:
                                                                TextCapitalization
                                                                    .words,
                                                                text: "Title Name",
                                                                obsure: false,
                                                                controller: expasyProvider
                                                                    .paymentController,
                                                                readOnly: false,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 20),
                                                            Wrap(
                                                              spacing: 15,
                                                              runSpacing: 15,
                                                              alignment: WrapAlignment
                                                                  .start,
                                                              children: expasyProvider
                                                                  .data
                                                                  .asMap()
                                                                  .entries
                                                                  .map((entry) {
                                                                int index = entry
                                                                    .key;
                                                                Map<String,
                                                                    dynamic> item =
                                                                    entry.value;
                                                                bool isSelected = expasyProvider
                                                                    .selectedPaymentIconIndex ==
                                                                    index;
                                                                return GestureDetector(
                                                                  onTap: () {
                                                                    expasyProvider
                                                                        .selectPaymentIcon(
                                                                        index);
                                                                  },
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                    children: [
                                                                      Container(
                                                                        width: 40,
                                                                        height: 40,
                                                                        padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            10),
                                                                        decoration: BoxDecoration(
                                                                          shape: BoxShape
                                                                              .circle,
                                                                          color: isSelected
                                                                              ? colorsConst.primary
                                                                              : const Color(
                                                                              0xffD9D9D9),
                                                                        ),
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          item['icon'],
                                                                          fit: BoxFit
                                                                              .contain,
                                                                          colorFilter:
                                                                          ColorFilter
                                                                              .mode(
                                                                            isSelected
                                                                                ? Colors
                                                                                .white
                                                                                : const Color(
                                                                                0xff96959A),
                                                                            BlendMode
                                                                                .srcIn,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      expasyProvider
                                                          .paymentController
                                                          .clear();
                                                      expasyProvider
                                                          .clearPaymentIconSelection();
                                                      Navigator.pop(context);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: const Color(
                                                          0xffD9D9D9),
                                                    ),
                                                    child: const CustomText(
                                                      text: "Cancel",
                                                      colors: Color(0xff000000),
                                                      size: 15,
                                                      isBold: false,
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      expasyProvider.paymentMethods;
                                                      String newType = expasyProvider
                                                          .paymentController.text
                                                          .trim();
                                                      if (newType.isNotEmpty) {
                                                        expasyProvider
                                                            .savePaymentType(
                                                            newType);
                                                        expasyProvider
                                                            .paymentController
                                                            .clear();
                                                        expasyProvider
                                                            .clearPaymentIconSelection();
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: colorsConst.primary,
                                                    ),
                                                    child: const CustomText(
                                                      text: "Add",
                                                      colors: Colors.white,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                                    child: const Icon(Icons.add, size: 25),),
                                ],
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    children: expasyProvider.paymentMethods.map((
                                        method) {
                                      final isSelected = expasyProvider
                                          .selectedPaymentType ==
                                          method['label'];
                                      return GestureDetector(
                                        onTap: () {
                                          if (expasyProvider.selectedPaymentType ==
                                              method['label']) {
                                            expasyProvider.setPaymentType("");
                                          } else {
                                            expasyProvider.setPaymentType(
                                                method['label']!);
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.all(5),
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected
                                                    ? colorsConst.primary
                                                    : Colors.grey[300],
                                              ),
                                              child: SvgPicture.asset(
                                                "${method['icon']}",
                                                height: 18,
                                                width: 18,
                                                color: isSelected
                                                    ? Colors.white
                                                    : const Color(0xff96959A),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            CustomText(
                                              text: method['label']!,
                                              colors: isSelected
                                                  ? colorsConst.primary
                                                  : const Color(0xff96959A),
                                              size: 10,
                                              isBold: true,
                                            )
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ), //ToDo:payment Head
                              5.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const CustomText(
                                    text: "Shop Name",
                                    size: 13,
                                    isBold: false,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            CustomAlert(
                                              scrollPhysics: const BouncingScrollPhysics(),
                                              textStyle: const TextStyle(
                                                  overflow: TextOverflow.visible),
                                              titleText: "Add New Shop Head",
                                              hintText: "Shop Name",
                                              controller: expasyProvider
                                                  .shopNameController,
                                              onAddPressed: () {
                                                String newShop =
                                                expasyProvider.shopNameController
                                                    .text.trim();
                                                if (newShop.isNotEmpty) {
                                                  expasyProvider.saveNewShop(
                                                      newShop);
                                                  expasyProvider.shopNameController
                                                      .clear();
                                                  Navigator.pop(context);
                                                }
                                              },
                                              onCancelPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                      );
                                    },
                                    child: const Icon(Icons.add, size: 25),
                                  ),
                                ],
                              ),
                              6.height,
                              SizedBox(
                                  width: screenWidth - 20,
                                  height: 60,
                                  child: CustomDropdownField(
                                     selectedValue: expasyProvider.selectedShop, // auto-selected
                                    items: expasyProvider.shops.toSet().toList(),
                                    hintText: "Select Shop",
                                    onChanged: (newValue) {
                                      if (newValue != null) {
                                        expasyProvider.setShop(newValue);
                                      }
                                    },
                                  )), //ToDo:shopname
                              const CustomText(
                                text: "City",
                                size: 13,
                                isBold: false,
                              ),
                              5.height,
                              SizedBox(
                                width: screenWidth - 20,
                                height: 60,
                                child: CustomDropdownField(
                                  selectedValue: expasyProvider.selectedCity,
                                  items: expasyProvider.cities,
                                  hintText: "Select City",
                                  onChanged: (newValue) {
                                    expasyProvider.setCity(newValue!);
                                    // expasyProvider.setCity(newValue);
                                  },
                                ),
                              ), //ToDo:city
                              MaxLineTextField(text: "Particulars",
                                  controller: expasyProvider.particularsController, maxLine: 3),
                              Column(
                                children: [
                                  ...expasyProvider.itemRows
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final row = entry.value;
                                    final isLast =
                                        index == expasyProvider.itemRows.length - 1;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                CustomTextField(
                                                  textCapitalization:
                                                  TextCapitalization.words,
                                                  // maxLines: 1,
                                                  controller: row['itemController']
                                                  as TextEditingController,
                                                  text: "Item Name",
                                                  // hintColor: Color(0xffA0A0A0),
                                                  readOnly: false,
                                                  obsure: false,
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(
                                                        50),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                CustomTextField(
                                                  textCapitalization:
                                                  TextCapitalization.none,
                                                  controller: row['quantityController']
                                                  as TextEditingController,
                                                  text: "QTY",
                                                  readOnly: false,
                                                  obsure: false,
                                                  keyboardType: const TextInputType.numberWithOptions(decimal: true), // ✅ integer + decimal
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')), // ✅ allow 123 or 123.45
                                                    LengthLimitingTextInputFormatter(50),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                CustomTextField(
                                                  textCapitalization: TextCapitalization.none,
                                                  controller: row['amountController'] as TextEditingController,
                                                  text: "Amount",
                                                  readOnly: false,
                                                  obsure: false,
                                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                  onChanged: (value) {
                                                    expasyProvider.updateTotalAmountWithGST(); // Don't format here
                                                  },
                                                  onEditingComplete: () {
                                                    final value = (row['amountController'] as TextEditingController).text;
                                                    final formatted = expasyProvider.formatIndianCurrency(value);
                                                    (row['amountController'] as TextEditingController).text = formatted;

                                                    expasyProvider.updateTotalAmountWithGST();
                                                  },
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                                    LengthLimitingTextInputFormatter(50),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),

                                          GestureDetector(
                                            onTap: () {
                                              FocusScope.of(context).unfocus();

                                              final itemText = row['itemController']?.text.trim();
                                              final qtyText = row['quantityController']?.text.trim(); // optional
                                              final amtText = row['amountController']?.text.trim();

                                              if (isLast) {
                                                // ✅ Only item + amount required
                                                if (itemText!.isNotEmpty && amtText!.isNotEmpty) {
                                                  expasyProvider.addItemRow();
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text("Please fill Item Name and Amount before adding a new item"),
                                                      duration: Duration(seconds: 2),
                                                      backgroundColor: Colors.redAccent,
                                                    ),
                                                  );
                                                }
                                              } else {
                                                if(expasyProvider.itemRows.length !=1) {
                                                  expasyProvider.removeItemRow(index);
                                                }
                                              }
                                            },
                                            child: Icon(
                                              isLast ? Icons.add : Icons.remove,
                                              size: 25,
                                            ),
                                          ),

                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ), ///ToDo:itemname
                              Wrap(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min, // ✅ prevent unbounded expansion
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Flexible( // ✅ Replaced Expanded with Flexible
                                        fit: FlexFit.loose,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CustomTextField(
                                              textCapitalization: TextCapitalization.none,
                                              readOnly: true,
                                              controller: expasyProvider.amountController,
                                              onChanged: (value) {
                                                expasyProvider.updateTotalAmountWithGST();
                                              },
                                              // suffixIcon: CustomIconbutton(
                                              //   onPressed: () {},
                                              //   icon: SvgPicture.asset(assets.rupees),
                                              // ),
                                              text: "Amount",
                                              obsure: false,
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(50),
                                              ],
                                              keyboardType: TextInputType.number,
                                              width: 180,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Flexible( // ✅ Replaced Expanded with Flexible
                                        fit: FlexFit.loose,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CustomText(
                                              text: "GST",
                                              size: 15,
                                              isBold: true,
                                            ),
                                            // Row(
                                            //   children: [
                                            //     Row(
                                            //       mainAxisSize: MainAxisSize.min,
                                            //       children: [0.0, 0.05].map((gstValue) {
                                            //         return Padding(
                                            //           padding: const EdgeInsets.only(right: 10),
                                            //           child: Row(
                                            //             mainAxisSize: MainAxisSize.min,
                                            //             children: [
                                            //               Radio<double>(
                                            //                 activeColor: colorsConst.primary,
                                            //                 value: gstValue,
                                            //                 groupValue: expasyProvider.selectedGST,
                                            //                 onChanged: (value) => expasyProvider.setGST(value!),
                                            //               ),
                                            //               Text("${(gstValue * 100).toInt()}%"),
                                            //             ],
                                            //           ),
                                            //         );
                                            //       }).toList(),
                                            //     ), // Spacing between rows
                                            //     Row(
                                            //       mainAxisSize: MainAxisSize.min,
                                            //       children: [0.12, 0.18].map((gstValue) {
                                            //         return Padding(
                                            //           padding: const EdgeInsets.only(right: 5),
                                            //           child: Row(
                                            //             mainAxisSize: MainAxisSize.min,
                                            //             children: [
                                            //               Radio<double>(
                                            //                 activeColor: colorsConst.primary,
                                            //                 value: gstValue,
                                            //                 groupValue: expasyProvider.selectedGST,
                                            //                 onChanged: (value) => expasyProvider.setGST(value!),
                                            //               ),
                                            //               Text("${(gstValue * 100).toInt()}%"),
                                            //             ],
                                            //           ),
                                            //         );
                                            //       }).toList(),
                                            //     ),
                                            //   ],
                                            // ),
                                            //  Wrap — items flow to next line when no space
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 6,
                                              children: [
                                                // first group (0% and 5%)
                                                ...[0.0, 0.05].map((gstValue) {
                                                  return SizedBox(
                                                    height: 36,
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Radio<double>(
                                                          activeColor: colorsConst.primary,
                                                          value: gstValue,
                                                          groupValue: expasyProvider.selectedGST,
                                                          onChanged: (value) => expasyProvider.setGST(value!),
                                                        ),
                                                        Text("${(gstValue * 100).toInt()}%"),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(), // second group (12% and 18%)
                                                ...[0.12,0.18].map((gstValue) {
                                                  return SizedBox(
                                                    height: 36,
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Radio<double>(
                                                          activeColor: colorsConst.primary,
                                                          value: gstValue,
                                                          groupValue: expasyProvider.selectedGST,
                                                          onChanged: (value) => expasyProvider.setGST(value!),
                                                        )                 ,
                                                        Text("${(gstValue * 100).toInt()}%"),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomLoadingButton(
                                      callback: (){
                                        expasyProvider.clearFormData();
                                        Navigator.pop(context);
                                      }, isLoading: false,text: "Cancel",
                                      backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: MediaQuery.of(context).size.width*0.4),
                                  CustomLoadingButton(
                                      callback: () async {
                                        expasyProvider.startLoading();
                                        bool isSuccess = await expasyProvider.addExpense(context);
                                        if (isSuccess) {
                                          expasyProvider.updateTotalAmountWithGST();
                                        }
                                      }, isLoading: true,text: "Save",controller: expasyProvider.saveCtr,
                                      backgroundColor: colorsConst.primary,radius: 10, width: MediaQuery.of(context).size.width*0.4),
                                ],
                              ),20.height
                            ]),
                      ),
                    )),
              ),
            ),
          )
          );
    });
  }
}
