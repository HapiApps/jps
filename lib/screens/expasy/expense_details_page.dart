import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/screens/expasy/home_screen.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/expasy_provider.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_dropdownfield.dart';
import '../../component/custom_text.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import 'edit_expense_page.dart';

class ExpenseDetailsPage extends StatefulWidget {
  final String expenseId;
  final double? fieldWidth;
  final double? fieldHeight;
  final bool isEditing;
  final List<Map<String, TextEditingController>>? initialItemRows;
  final Map<String, dynamic>? initialData;

  const ExpenseDetailsPage({
    super.key,
    required this.expenseId,
    this.fieldWidth,
    this.fieldHeight,
    this.initialItemRows,
    this.initialData,
    this.isEditing = false,
  });

  @override
  State<ExpenseDetailsPage> createState() => _ExpenseDetailsPageState();
}

class _ExpenseDetailsPageState extends State<ExpenseDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpasyProvider>(
        builder: (context, expenseProvider, _) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size(300, 50),
              child: CustomAppbar(text: constValue.expDetails),
            ),
              backgroundColor: const Color(0xffF9F9F9),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      expenseProvider.isLoading == true
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              height: 420,
                              child: ListView.builder(
                                  shrinkWrap: false,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: expenseProvider.selectedExpense.length,
                                  itemBuilder: (context, index) {
                                    final item = expenseProvider.selectedExpense[index];
                                    return Column(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            IconButton(
                                                onPressed: () {},
                                                icon: SvgPicture.asset(assets.location)),
                                            CustomText(
                                              text: item.city,
                                              colors: const Color(0xff000000),
                                              size: 15,
                                              isBold: false,
                                            ),
                                            const Spacer(),
                                            Row(
                                              children: [
                                                IconButton(
                                                    onPressed: () async {
                                                      await expenseProvider.fetchExpenseById(item.id!);

                                                      if (expenseProvider.selectedExpense.isEmpty) {
                                                        print("No expense found for ID: ${item.id}");
                                                        return;
                                                      }
                                                      final expense =
                                                      expenseProvider.selectedExpense[0]; // 👈 latest API data

                                                      // ✅ Assign old data properly
                                                      final existingData =
                                                      {
                                                        'date': expense.date,
                                                        'user_account': expense.userAccount,
                                                        'expense_head': expense.expenseHead,
                                                        'payment_type': expense.paymentType,
                                                        'shop_name': expense.shopName,
                                                        'city': expense.city,
                                                        'particulars': expense.particulars,
                                                        'amount': expense.amount.toString() ?? '0',
                                                        'gst': expense.gst.toString() ?? '0',
                                                      };
                                                      expenseProvider.dataRows.addAll(existingData);
                                                      print("dataRows.................${expenseProvider.dataRows}");
                                                      expenseProvider.clearItemRows();
                                                      if (expense.expenseList.isNotEmpty) {
                                                        expenseProvider.setItemRowsFromExpenseList(expense.expenseList);
                                                      }

                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => EditExpense(
                                                            isEditing: true,
                                                            initialItemRows: expenseProvider.itemRows,
                                                            initialData: expenseProvider.dataRows,
                                                            expenseId: expense.id,
                                                            item_id: expenseProvider.itemId,
                                                          ),
                                                        ),
                                                      );
                                                    },

                                                    icon: SvgPicture.asset(assets.edit)),
                                                IconButton(
                                                  onPressed: () {
                                                    // utils.showDeleteDialog(context, () {
                                                    //   setState(() {
                                                    //     expenseProvider
                                                    //         .deleteExpenseFromUI(
                                                    //       context: context,
                                                    //       expenseId: item.id.toString(),
                                                    //       userId:
                                                    //           localData.currentUserID,
                                                    //       shouldDelete: true,
                                                    //     );
                                                    //   });
                                                    // },
                                                    //     'Are you sure you want to delete this expense?',
                                                    //     'This action cannot be undone.',
                                                    //     'Delete',
                                                    //     Icons.warning);
                                                  },
                                                  icon: SvgPicture.asset(assets.deleteValue),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      CustomText(
                                        text: "₹ ${item.amount}",
                                        colors: colorsConst.primary,
                                        size: 30,
                                        isBold: true,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: SvgPicture.asset(assets.food),
                                          ),
                                          const SizedBox(width: 8),
                                          CustomText(
                                            text: item.expenseHead,
                                            colors: const Color(0XFF464646),
                                            size: 12,
                                            isBold: false,
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          children: [
                                            8.height,
                                            ExpasyList(iconPath: assets.account,
                                                label: "Account", value:item.userAccount),
                                            12.height,
                                            ExpasyList(
                                              iconPath: assets.calendar,
                                              label: "Date",
                                              value:(item.date.toString().isNotEmpty)
                                                  ? (() {
                                                      try {
                                                        // final dateStr = item.date?.toString() ?? '';
                                                        if (item.date
                                                            .toString()
                                                            .isNotEmpty) {
                                                          final parsedDate =
                                                              DateFormat("dd-MM-yyyy")
                                                                  .parse(item.date.toString());
                                                          return DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .format(parsedDate);
                                                        } else {
                                                          return 'No Date';
                                                        }
                                                      } catch (e) {
                                                        return 'Invalid Date';
                                                      }
                                                    })()
                                                  : '',
                                            ),
                                            12.height,
                                            ExpasyList(
                                                iconPath:assets.moneyBill,
                                                label:"Payment Type",
                                              value:item.paymentType,),
                                            12.height,
                                            ExpasyList(iconPath:assets.cBag,label:"Shop Name", value:item.shopName),
                                            12.height,
                                            ExpasyList(iconPath:assets.bar,
                                                label:"Particulars", value:item.particulars),
                                            12.height,
                                            const DottedDivider(dotColor: Colors.black),
                                          ],
                                        ),
                                      ),
                                      if (expenseProvider.expenseItems.isNotEmpty) ...[
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20.0, vertical: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: CustomText(
                                                  text: 'Item Name',
                                                  colors: Color(0xff464646),
                                                  size: 15,
                                                  isBold: false,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: CustomText(
                                                  text: 'Quantity',
                                                  colors: Color(0xff464646),
                                                  size: 15,
                                                  isBold: false,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: CustomText(
                                                  text: 'Amount',
                                                  colors: Color(0xff464646),
                                                  size: 15,
                                                  isBold: false,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]
                                    ]);
                                  }),
                            ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: expenseProvider.expenseItems.length,
                          itemBuilder: (context, index) {
                            final row = expenseProvider.expenseItems[index];
                            print(jsonEncode(row));
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: CustomText(
                                      text: row.itemName.toString(),
                                      colors: const Color(0xff000000),
                                      isBold: true,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: CustomText(
                                      text: row.qty.toString(),
                                      colors: const Color(0xff000000),
                                      isBold: true,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: CustomText(
                                      text: row.price.toString(),
                                      colors: const Color(0xff000000),
                                      isBold: true,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              );
    });
  }
}
