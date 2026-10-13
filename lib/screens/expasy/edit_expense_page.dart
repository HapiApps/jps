import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/component/custom_appbar.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/expasy_provider.dart';
import 'package:provider/provider.dart';
import '../../component/custom_dropdownfield.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../model/expasy/expense_fetch.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/local_data.dart';

class EditExpense extends StatefulWidget {
  final bool isEditing;
  final String? expenseId;
  final String? item_id;
  final List<Map<String, dynamic>>? initialItemRows;
  final Map<String, dynamic> initialData;
  const EditExpense(
      {super.key,
      this.initialItemRows,
      required this.initialData,
      this.isEditing = false,
      this.expenseId,
      this.item_id});

  @override
  State<EditExpense> createState() => _EditExpenseState();
}

class _EditExpenseState extends State<EditExpense> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<ExpasyProvider>(context, listen: false);
      // final expenseProvider =
      //       Provider.of<ExpenseProvider>(context, listen: false);
      //   expenseProvider.fetchExpenseById(widget.expenseId.toString());
      Provider.of<ExpasyProvider>(context, listen: false).initializeUserData();
      if (widget.initialData != null) {
        userProvider.loadInitialData(widget.initialData!);
        final rawList = widget.initialData!['expenseList'];
        if (rawList != null && rawList is List) {
          final convertedList = rawList.map<Map<String, String>>((item) {
            return {
              'item_id': item['item_id'].toString(),
              'item_name': item['item_name'].toString(),
              'qty': item['qty'].toString(),
              'price': item['price'].toString(),
            };
          }).toList();
          userProvider.setItemRowsFromExpenseList(convertedList.cast<ExpenseList>());
        } else {
          print(" expenseList is null or not a List");
        }
      }
    });
  }

  final bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer<ExpasyProvider>(
        builder: (context, expenseProvider, child) {
          return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size(300, 60),
            child: CustomAppbar(text: "Update Expense"),
          ),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        2.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              // <-- Automatically takes half of the row
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    fieldColor: const Color(0xffFFFFFF),
                                    text: "Select Date",
                                    controller: expenseProvider.dateController,
                                    obsure: false,
                                    readOnly: true,
                                    width: screenWidth - 200,
                                    onTap: () {
                                      expenseProvider.selectDate(context);
                                    },
                                    // suffixIcon: IconButton(
                                    //   icon: const Icon(Icons.calendar_today,
                                    //       color: Colors.grey),
                                    //   onPressed: () async {
                                    //     expenseProvider.selectDate(context);
                                    //     FocusScope.of(context).unfocus();
                                    //   },
                                    // ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            // space between the two columns
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: CustomText(
                                            text: "Account",
                                            size: 13,
                                            isBold: false,),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          // showDialog(
                                          //   context: context,
                                          //   builder: (context) => CustomAlert(
                                          //     titleText: "Add New Account Head",
                                          //     hintText: "Account Name",
                                          //     controller: expenseProvider
                                          //         .accountController,
                                          //     onAddPressed: () {
                                          //       String newAccount =
                                          //       expenseProvider
                                          //           .accountController.text
                                          //           .trim();
                                          //       if (newAccount.isNotEmpty) {
                                          //         expenseProvider
                                          //             .saveNewAccount(newAccount);
                                          //         expenseProvider
                                          //             .accountController
                                          //             .clear();
                                          //         Navigator.pop(context);
                                          //       }
                                          //     },
                                          //     onCancelPressed: () =>
                                          //         Navigator.pop(context),
                                          //   ),
                                          // );
                                        },
                                        child: const Icon(Icons.add, size: 25),
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(height: 8),
                                  CustomDropdownField(
                                    selectedValue:
                                    expenseProvider.selectedAccount,
                                    items: expenseProvider.accounts,
                                    hintText: "Select Account",
                                    onChanged: (newValue) {
                                      expenseProvider
                                          .setSelectedAccount(newValue!);
                                    },
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
                                // showDialog(
                                //   context: context,
                                //   builder: (context) => CustomAlert(
                                //     titleText: "Add New Expansion Head",
                                //     hintText: "Title Name",
                                //     controller: expenseProvider.headController,
                                //     onAddPressed: () async {
                                //       String newHead = expenseProvider
                                //           .headController.text
                                //           .trim();
                                //       if (newHead.isNotEmpty) {
                                //         await expenseProvider
                                //             .saveExpansionHead(newHead);
                                //         expenseProvider.headController.clear();
                                //         Navigator.pop(context);
                                //       }
                                //     },
                                //     onCancelPressed: () => Navigator.pop(context),
                                //   ),
                                // );
                              },
                              child: const Icon(Icons.add, size: 25),
                            ),
                          ],
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(
                                expenseProvider.expansionHeads.length, (index) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                                child: Container(
                                  width: 100,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: expenseProvider.selectedHead ==
                                        expenseProvider.expansionHeads[index]
                                        ? colorsConst.primary
                                        : const Color(0xffF7F7F7),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xffE0E0E0),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      expenseProvider.setExpansionHead(
                                          expenseProvider.expansionHeads[index]);
                                    },
                                    borderRadius: BorderRadius.circular(15),
                                    splashColor:
                                    colorsConst.primary.withOpacity(0.5),
                                    highlightColor: Colors.transparent,
                                    child: Center(
                                      child: CustomText(
                                        text: expenseProvider.expansionHeads[index],
                                        colors: expenseProvider.selectedHead ==
                                            expenseProvider.expansionHeads[index]
                                            ? Colors.white
                                            : Colors.black,
                                        isBold: false,
                                        size: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
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
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    title: const CustomText(
                                      text: "Add New Payment Type",
                                      colors: Color(0xff212121),
                                      isBold: true,
                                      size: 15,
                                    ),
                                    content: Consumer<ExpasyProvider>(
                                      builder: (context, userProvider, _) {
                                        return SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: 200,
                                                height: 50,
                                                child: CustomTextField(
                                                  textCapitalization:
                                                  TextCapitalization.words,
                                                  text: "Title Name",
                                                  obsure: false,
                                                  controller: userProvider
                                                      .paymentController,
                                                  readOnly: false,
                                                ),
                                              ),
                                              // const SizedBox(height: 20),
                                              Wrap(
                                                spacing: 15,
                                                runSpacing: 15,
                                                alignment: WrapAlignment.start,
                                                children: expenseProvider.data
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                  int index = entry.key;
                                                  Map<String, dynamic> item =
                                                      entry.value;
                                                  bool isSelected = userProvider
                                                      .selectedPaymentIconIndex ==
                                                      index;
                                                  return GestureDetector(
                                                    onTap: () {
                                                      userProvider
                                                          .selectPaymentIcon(
                                                          index);
                                                    },
                                                    child: Column(
                                                      mainAxisSize:
                                                      MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 40,
                                                          height: 40,
                                                          padding:
                                                          const EdgeInsets
                                                              .all(10),
                                                          decoration:
                                                          BoxDecoration(
                                                            shape:
                                                            BoxShape.circle,
                                                            color: isSelected
                                                                ?colorsConst.primary
                                                                : const Color(
                                                                0xffD9D9D9),
                                                          ),
                                                          child: SvgPicture.asset(
                                                            item['icon'],
                                                            fit: BoxFit.contain,
                                                            colorFilter:
                                                            ColorFilter.mode(
                                                              isSelected
                                                                  ? Colors.white
                                                                  : const Color(
                                                                  0xff96959A),
                                                              BlendMode.srcIn,
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
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          expenseProvider.paymentController.clear();
                                          expenseProvider.clearPaymentIconSelection();
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          const Color(0xffD9D9D9),
                                        ),
                                        child: const CustomText(
                                          text: "Clear",
                                          colors: Color(0xff000000),
                                          size: 15,
                                          isBold: false,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          expenseProvider.paymentMethods;
                                          String newType = expenseProvider
                                              .paymentController.text
                                              .trim();
                                          if (newType.isNotEmpty) {
                                            expenseProvider
                                                .savePaymentType(newType);
                                            expenseProvider.paymentController
                                                .clear();
                                            expenseProvider
                                                .clearPaymentIconSelection();
                                            Navigator.pop(context);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
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
                              child: const Icon(Icons.add, size: 25),
                            ),
                          ],
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: expenseProvider.paymentMethods.map((method) {
                                final isSelected =
                                    expenseProvider.selectedPaymentType ==
                                        method['label'];
                                return GestureDetector(
                                  onTap: () {
                                    if (expenseProvider.selectedPaymentType ==
                                        method['label']) {
                                      expenseProvider.setPaymentType("");
                                    } else {
                                      expenseProvider
                                          .setPaymentType(method['label']!);
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
                        ),
                        //ToDo:payment Head
                        // 5.height,
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
                                // showDialog(
                                //   context: context,
                                //   builder: (context) => CustomAlert(
                                //     scrollPhysics: const BouncingScrollPhysics(),
                                //     textStyle: const TextStyle(
                                //         overflow: TextOverflow.visible),
                                //     titleText: "Add New Shop Head",
                                //     hintText: "Shop Name",
                                //     controller:
                                //     expenseProvider.shopNameController,
                                //     onAddPressed: () {
                                //       String newShop = expenseProvider
                                //           .shopNameController.text
                                //           .trim();
                                //       if (newShop.isNotEmpty) {
                                //         expenseProvider.saveNewShop(newShop);
                                //         expenseProvider.shopNameController
                                //             .clear();
                                //         Navigator.pop(context);
                                //       }
                                //     },
                                //     onCancelPressed: () => Navigator.pop(context),
                                //   ),
                                // );
                              },
                              child: const Icon(Icons.add, size: 25),
                            ),
                          ],
                        ),
                        // 6.height,
                        SizedBox(
                            width: screenWidth - 20,
                            height: 60,
                            child: CustomDropdownField(
                              selectedValue: expenseProvider.shops
                                  .contains(expenseProvider.selectedShop)
                                  ? expenseProvider.selectedShop
                                  : null,
                              items: expenseProvider.shops.toSet().toList(),
                              hintText: "Select Shop",
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  expenseProvider.setShop(newValue);
                                  expenseProvider.saveNewShop;
                                }
                              },
                            )),
                        //ToDo:shopname
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
                            selectedValue: expenseProvider.selectedCity,
                            items: expenseProvider.cities,
                            hintText: "Select City",
                            onChanged: (newValue) {
                              expenseProvider.setCity(newValue!);
                              // userProvider.setCity(newValue);
                            },
                          ),
                        ),
                        //ToDo:city
                        const CustomText(
                          text: "Particulars",
                          size: 13,
                          isBold: false,
                        ),
                        6.height,
                        Container(
                          width: screenWidth - 20,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xffFFFFFF),
                            border: Border.all(color: const Color(0xffD9D9D9)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            cursorColor: Colors.black,
                            controller: expenseProvider.particularsController,
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: "Write your message here...",
                              hintStyle:
                              const TextStyle(color: Color(0xffCFCFCF)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        //ToDo:particulars
                        Column(
                          children: [
                            ...expenseProvider.itemRows
                                .asMap()
                                .entries
                                .map((entry) {
                              final index = entry.key;
                              final row = entry.value;
                              final isLast =
                                  index == expenseProvider.itemRows.length - 1;
                              return Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          CustomTextField(
                                            textCapitalization: TextCapitalization.words,
                                            controller: row['itemController']
                                            as TextEditingController,
                                            text: "Item Name",
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
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          CustomTextField(
                                            textCapitalization:
                                            TextCapitalization.none,
                                            controller: row['quantityController']
                                            as TextEditingController,
                                            text: "QTY",
                                            readOnly: false,
                                            obsure: false,
                                            keyboardType: TextInputType.number,
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
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          CustomTextField(
                                            textCapitalization: TextCapitalization.none,
                                            controller: row['amountController'] as TextEditingController,
                                            text: "Amount",
                                            readOnly: false,
                                            obsure: false,
                                            keyboardType:  TextInputType.number, // Allows decimals
                                            onChanged: (value) {
                                              final formatted = expenseProvider.formatIndianCurrency(value.toString());
                                              (row['amountController'] as TextEditingController).value = TextEditingValue(
                                                text: formatted,
                                                selection: TextSelection.collapsed(offset: formatted.length),
                                              );
                                              expenseProvider.updateTotalAmountWithGST();
                                            },
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(23),
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
                                        final amtText = row['amountController']?.text.trim();

                                        if (isLast) {
                                          if (itemText!.isNotEmpty && amtText!.isNotEmpty) {
                                            expenseProvider.addItemRow();
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Please fill all fields before adding a new item"),
                                                duration: Duration(seconds: 2),
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                          }
                                        } else {
                                          if(expenseProvider.itemRows.length !=1) {
                                            expenseProvider.removeItemRow(index);
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
                        ),
                        ///ToDo:itemname
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            SizedBox(
                              width: screenWidth > 600
                                  ? screenWidth - 400
                                  : double.infinity,
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextField(
                                        textCapitalization:
                                        TextCapitalization.none,
                                        readOnly: true,
                                        controller:
                                        expenseProvider.amountController,
                                        onChanged: (value) {
                                          expenseProvider.updateTotalAmountWithGST();
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
                                  20.width,
                          Flexible(
                            fit: FlexFit.loose,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CustomText(
                                  text: "GST",
                                  size: 15,
                                  isBold: true,
                                ),
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
                                              groupValue: expenseProvider.selectedGST,
                                              onChanged: (value) => expenseProvider.setGST(value!),
                                            ),
                                            Text("${(gstValue * 100).toInt()}%"),
                                          ],
                                        ),
                                      );
                                    }).toList(),

                                    // second group (12% and 18%)
                                    ...[0.12,0.18].map((gstValue) {
                                      return SizedBox(
                                        height: 36,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Radio<double>(
                                              activeColor: colorsConst.primary,
                                              value: gstValue,
                                              groupValue: expenseProvider.selectedGST,
                                              onChanged: (value) => expenseProvider.setGST(value!),
                                            ),
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
                          //TODO GST
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomLoadingButton(
                                callback: (){
                                  if (expenseProvider.isSaveLoading) {
                                    expenseProvider.stopLoading();
                                  }
                                  expenseProvider.clearFormData();
                                  FocusScope.of(context).unfocus();
                                  Navigator.pop(context);
                                }, isLoading: false,text: "Cancel",
                                backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: MediaQuery.of(context).size.width*0.4),
                            CustomLoadingButton(
                                callback: () async {
                                  expenseProvider.startLoading();
                                  print("${widget.isEditing}widget.isEditing...............................");
                                  if (widget.isEditing) {
                                    print("Update Expense");
                                    await expenseProvider.updateExpenseFromUI(
                                      context: context,
                                      expenseId: widget.expenseId.toString(),
                                      userAccount: expenseProvider.selectedAccount,
                                      mobile: localData.storage.read("mobile_number"),
                                      city: expenseProvider.selectedCity ?? '',
                                      shop: expenseProvider.selectedShop ?? '',
                                      expenseHead: expenseProvider.selectedHead,
                                      paymentType: expenseProvider.selectedPaymentType,
                                      particulars: expenseProvider.particularsController.text.trim(),
                                      gst: expenseProvider.selectedGST.toString(),
                                      amount: expenseProvider.amountController.text.trim(),
                                      date: expenseProvider.dateController.text,
                                      userId: localData.storage.read("id"),
                                    );
                                  }
                                  expenseProvider.stopLoading();
                                }, isLoading: true,text: "Save",controller: expenseProvider.saveCtr,
                                backgroundColor: colorsConst.primary,radius: 10, width: MediaQuery.of(context).size.width*0.4),
                          ],
                        ),
                      ]),
                ),
              ),
            ),
          )
          );
        });
  }
}
