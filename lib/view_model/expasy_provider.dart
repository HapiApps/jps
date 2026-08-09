import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:master_code/screens/expasy/expasy_screen.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/constant/default_constant.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/expasy/expense_fetch.dart';
import '../model/expasy/fetch_details.dart';
import '../model/expasy/income_obj.dart';
import '../repo/expasy_repo.dart';
import '../screens/common/dashboard.dart';
import '../screens/expasy/home_screen.dart';
import '../source/constant/local_data.dart';
import '../source/utilities/utils.dart';

class ExpasyProvider with ChangeNotifier {
  TextEditingController dateController = TextEditingController(text: "");
  TextEditingController amountController = TextEditingController();
  TextEditingController shopNameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController particularsController = TextEditingController();
  TextEditingController accountController = TextEditingController();
  TextEditingController paymentController = TextEditingController();
  TextEditingController headController = TextEditingController();
  List<Datum> filteredExpensesList = []; //search list
  List<Datum> get filteredExpensesData => filteredExpensesList;
  String formattedDate = "";
  DateTime? _filterSelectedDate;

  DateTime? get filterSelectedDate => _filterSelectedDate;
  final TextEditingController filterDateController = TextEditingController();

  void filterDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _filterSelectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorsConst.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colorsConst.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      filters = "Select Filter";
      selectedMonth = null;

      _filterSelectedDate = pickedDate;
      filterDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      filterExpensesByRange("s_date", pickedDate);
      notifyListeners();
    }
  }

  void clearDateFilter() {
    _filterSelectedDate = null;
    filterDateController.clear();
    filterExpensesByRange('', null);
    notifyListeners();
  }
  DateTime now = DateTime.now();
  DateTime? fromDate;

  bool isDateMatch(DateTime target, String filter, DateTime now) {
    final t = DateTime(target.year, target.month, target.day);

    late DateTime fromDate;
    DateTime? endDate;

    switch (filter) {
      case "Last 7 days":
        fromDate = now.subtract(const Duration(days: 6));
        endDate = DateTime(now.year, now.month, now.day);
        break;

      case "Last 30 days":
        fromDate = now.subtract(const Duration(days: 29));
        endDate = DateTime(now.year, now.month, now.day);
        break;

      case "Yesterday":
        fromDate = DateTime(now.year, now.month, now.day);
        endDate = fromDate;
        break;

      case "This year":
        fromDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31);
        break;

      case "Today":
        fromDate = DateTime(now.year, now.month, now.day);
        endDate = fromDate;
        break;

      case "s_month":
        fromDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0); // last day of selected month
        break;
      case "s_date":
        fromDate = DateTime(now.year, now.month, now.day);
        endDate = fromDate; // last day of selected month
        break;

      default:
        return false;
    }
    final s = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final e = DateTime(endDate!.year, endDate.month, endDate.day);
    return !t.isBefore(s) && !t.isAfter(e);
  }

  void filterExpensesByRange(String filterType, DateTime? m) {
    switch (filterType) {
      case "Last 7 days":
        fromDate = DateTime(fromDate!.year, fromDate!.month, fromDate!.day);
        break;

      case "Last 30 days":
        fromDate = DateTime(fromDate!.year, fromDate!.month, fromDate!.day);
        break;

      case "This year":
        fromDate = DateTime(now.year, 1, 1);
        break;

      case "Today":
        fromDate = DateTime(now.year, now.month, now.day);
        break;

      case "Yesterday":
        fromDate = DateTime(now.year, now.month, now.day - 1);
        break;

      case "s_month":
        if (m != null) fromDate = DateTime(m.year, m.month, 1);
        break;
      case "s_date":
        if (m != null) fromDate = DateTime(m.year, m.month, m.day);
        break;

      default:
        break;
    }

    _expensesList = allExpenses.where((expense) {
      if (expense.date.toString().isNotEmpty) {
        try {
          DateTime expenseDate = DateFormat("dd-MM-yyyy").parse(expense.date.toString());
          return isDateMatch(expenseDate, filterType, fromDate!);
        } catch (e) {
          print("Date parse error: $e (value: ${expense.date})");
          return false;
        }
      }
      return false;
    }).toList();

    _incomeList = [];
    _incomeList = _allIncome.where((income) {
      if (income.date.isNotEmpty) {
        try {
          DateTime incomeDate = DateFormat("dd-MM-yyyy").parse(income.date);
          return isDateMatch(incomeDate, filterType, fromDate!);
        } catch (e) {
          print("Date parse error: $e (value: ${income.date})");
          return false;
        }
      }
      return false;
    }).toList();

    // ✅ calculate total income from server data
    _totalIncomeAmount = 0;
    for (var income in _allIncome) {
      DateTime incomeDate = DateFormat('dd-MM-yyyy').parse(income.date);
      double incomeAmount = double.tryParse(income.income.toString()) ?? 0.0;
      if (isDateMatch(incomeDate, filterType, fromDate!)) {
        _totalIncomeAmount += incomeAmount;
      }
    }
    totalExpenseAmount;

    notifyListeners();
  }

  bool isLoading = false;

  List<ExpenseDetailsObj> _expensesList = [];

  List<ExpenseDetailsObj> get expensesList => _expensesList;
  List<ExpenseDetailsObj> _allExpenses = [];

  List<ExpenseDetailsObj> get allExpenses => _allExpenses;
  void setExpenses(List<ExpenseDetailsObj> data) {
    _allExpenses = data;
    _expensesList = data;
    notifyListeners();
  }

  void setCity(String newValue) async {
    selectCity = newValue;
    // notifyListeners();
  }

///////////Todo:date

  DateTime? _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  DateTime? get selectedDate => _selectedDate;


  void handleDateInput(String value) {
    try {
      DateTime parsedDate;
      if (value.contains('/')) {
        parsedDate = DateFormat("MM/dd/yyyy").parseStrict(value);
      } else if (value.contains('-')) {
        parsedDate = DateFormat("dd-MM-yyyy").parseStrict(value);
      } else {
        throw const FormatException("Unrecognized format");
      }

      _selectedDate = parsedDate;
      dateController.text = DateFormat("dd-MM-yyyy").format(parsedDate);

      notifyListeners();
    } catch (e) {
      print("Invalid pasted date: $e");
    }
  }

  DateTime? selectedMonth;
  void setMonthFilter(DateTime month) {
    //clear values
    filters = "Select Filter";
    _filterSelectedDate = null;
    filterDateController.clear();

    selectedMonth = month;
    filterExpensesByRange('s_month', month);
    notifyListeners();
  }

  void clearMonthFilter() {
    selectedMonth = null;
    // Optionally refresh data to default (e.g., all)
    filterExpensesByRange('', null);
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate:  DateTime.now(),
      // lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorsConst.primary,
              onPrimary: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colorsConst.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = DateFormat('dd-MM-yyyy').format(picked);

      // Update provider and text controller
      setSelectedDate(picked); // Custom method you'll define
      dateController.text = formatted;
    }
  }

  Future<void> setDate(DateTime newDate) async {
    _selectedDate = newDate;
    DateFormat.MMMMd().format(DateTime.now());
    dateController.text = DateFormat("dd-MM-yyyy").format(newDate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDate', dateController.text);
    notifyListeners();
  }

  void loadSelectedDateFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedDate = prefs.getString('selectedDate');
    if (savedDate != null) {
      dateController.text = savedDate;
      _selectedDate = DateFormat("dd-MM-yyyy").parse(savedDate);
    }
    notifyListeners();
  }

  Future<void> saveSelectedDateToPrefs() async {
    if (_selectedDate != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedDate', _selectedDate!.toIso8601String());
    }
  }

  void updateExpense(int index, newItem) {
    if (index >= 0 && index < expensesList.length) {
      expensesList[index] = newItem;
      notifyListeners();
    }
  }

  void deleteExpense(int index) {
    expensesList.removeAt(index);
    notifyListeners();
  }

  double get totalExpenseAmount {
    double total = 0;
    for (var item in _expensesList) {
      total += double.tryParse(item.amount.toString()) ?? 0;
    }
    return total;
  }

  bool _isSaveLoading = false;
  bool get isSaveLoading => _isSaveLoading;
  void startLoading() {
    _isSaveLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isSaveLoading = false;
    notifyListeners();
  }

  Future<void> saveExpansionHead(String head) async {
    if (!expansionHead.contains(head)) {
      expansionHead.add(head);
      selectHead = head;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('expansionHeads', expansionHead);
      await prefs.setString('selectedExpansionHead', selectHead);
      notifyListeners();
    }
  }

  void setExpansionHead(String newHead) async {
    selectHead = newHead;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedExpansionHead', selectHead);
    notifyListeners();
  }

  Future<void> loadExpansionHead() async {
    final prefs = await SharedPreferences.getInstance();
    expansionHead =
        prefs.getStringList('expansionHeads') ?? ['Food', 'Travel', 'Shopping'];
    selectHead = prefs.getString('selectedExpansionHead') ?? '';
    notifyListeners();
  }

  //////////////todo:selectedExpense.....................

  List<ExpenseDetailsObj> _selectedExpense = [];

  List<ExpenseDetailsObj> get selectedExpense => _selectedExpense;

  bool _isExpenseDetailLoading = false;

  bool get isExpenseDetailLoading => _isExpenseDetailLoading;

  void loadInitialData(Map<String, dynamic> data) {
    try {
      dateController.text = data['date']?.toString() ?? '';
      _selectedAccount = data['user_account']?.toString() ?? '';

      final head = data['expense_head']?.toString();
      selectHead =
      (head != null && expansionHead.contains(head))
          ? head
          : expansionHead.first;
      final payment = data['payment_type']?.toString();
      selectPaymentType =
      (payment != null && paymentTypes.contains(payment))
          ? payment
          : paymentTypes.first;

      final shop = data['shop_name']?.toString();
      selectShop =
      (shop != null && shops.contains(shop)) ? shop : null;

      final city = data['city']?.toString();
      selectCity =
      (city != null && city.contains(city)) ? city : null;

      particularsController.text = data['particulars']?.toString() ?? '';
      amountController.text = data['amount']?.toString() ?? '';
      _selectedGST = double.tryParse(data['gst']?.toString() ?? '0.0') ?? 0.0;

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error in loadInitialData: $e\n$stackTrace');
    }
  }

  List<ExpenseList> _expenseItems = [];

  List<ExpenseList> get expenseItems => _expenseItems;
  var itemId;
//Todo API Call For Expense :
  Future<void> fetchExpenseById(String expenseId) async {
    _isExpenseDetailLoading = true;
    notifyListeners();
    // try {
      final response = await ExpenseService.getExpenseById(expenseId);
      if (response.isNotEmpty) {
        _selectedExpense = response;
        _expenseItems = _selectedExpense[0].expenseList;
        log("Expense Id Fetched: ${_selectedExpense.length}");
        log("Expense  Fetched: ${jsonEncode(response)}");
        itemId = response[0].expenseList[0].itemId;
        log("itemId  Fetched: ${itemId}");
      } else {
        _selectedExpense = [];
      }
    // } catch (e) {
    //   log("getExpenses Error: $e");
    // }
    // finally
    {
      isLoading = false;
      // _isExpenseDetailLoading = false;
      notifyListeners();
    }
  }
  Future<void> fetchAllExpense() async {
    _isExpenseDetailLoading = true;
    notifyListeners();
    try {
      final response = await ExpenseService.getExpenses();
      if (response.isNotEmpty) {
           _allExpenses = response;
        _expensesList = _allExpenses;
        log("Expense Id Fetched: ${_allExpenses.length}");
        log("Expense  Fetched: ${jsonEncode(response)}");
        itemId = response[0].expenseList[0].itemId;
        log("itemId  Fetched: ${itemId}");

           _totalExpenses = 0;
           for (var income in _allExpenses) {
             double expenseAmount = double.tryParse(income.amount.toString()) ?? 0.0;
             _totalExpenses += expenseAmount;
           }
      } else {
        _expensesList = [];
      }
    } catch (e) {
      log("getExpenses Error: $e");
    } finally {
      isLoading = false;
      // _isExpenseDetailLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateExpenseFromUI({
    required BuildContext context,
    required String expenseId,
    required String userAccount,
    required String mobile,
    required String city,
    required String shop,
    required String expenseHead,
    required String paymentType,
    required String particulars,
    required String gst,
    required String amount,
    required String date,
    required String userId,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final expenseList = getUpdateExpenseList();
      print("➡️ Before API Call - expenseList: ${jsonEncode(expenseList)}");
      final response = await expenseService.updateExpense(
        expenseId: expenseId,
        userAccount: userAccount,
        mobile: localData.storage.read("mobile_number"),
        city: city,
        shop: shop,
        expenseHead: expenseHead,
        paymentType: paymentType,
        particulars: particulars,
        gst: gst,
        amount: amount,
        date: date,
        userId: userId,
        expenseList: expenseList,
      );

      if (response["message"].toString().toLowerCase() == "ok") {
        _expenseErrorMessage = "Updated Successfully";
        utils.showSuccessToast(context: context, text: _expenseErrorMessage);
        fetchExpenseById(expenseId);
        saveCtr.reset();
        tabController?.animateTo(1);
        Navigator.pop(context);
      }
    } catch (e, stack) {
      print("❌ Exception in updateExpenseFromUI: $e");
      print("❌ Stacktrace: $stack");
      utils.showErrorToast(context: context);
      saveCtr.reset();
      _expenseErrorMessage = "Update failed: $e";
    } finally {
      isLoading = false;
      saveCtr.reset();
      utils.showErrorToast(context: context);
      notifyListeners();
    }
  }


  TabController? tabController;

  void updateTotalAmountWithGST() {
    double total = 0.0;

    for (var row in itemRows) {
      final amountText = (row['amountController'] as TextEditingController).text
          .replaceAll(",", "")
          .trim();
      if (amountText.isNotEmpty) {
        total += double.tryParse(amountText) ?? 0.0;
      }
    }

    final totalWithGST = total + (total * selectedGST);

    // ✅ Keep exact decimal entered (no rounding)
    amountController.text = totalWithGST.toString();

    notifyListeners();
  }

  String formatIndianCurrency(String value) {
    if (value.isEmpty) return '';

    // Remove unwanted characters (like commas, spaces)
    value = value.replaceAll(RegExp(r'[^0-9.]'), '');

    // Parse safely
    double? number = double.tryParse(value);
    if (number == null) return value;

    // Use Indian numbering system (without forcing .00 for integers)
    final formatter = NumberFormat.currency(
      locale: "en_IN",
      symbol: "",
      decimalDigits: number == number.roundToDouble() ? 0 : 2,
    );

    return formatter.format(number).trim();
  }


//TODO Shop.............................................d

  double _externalExpenseAmount = 0.0;
  double get balanceAmount => _totalIncomeAmount - _externalExpenseAmount;

// 1. Update external expense
  void updateTotalExpenseFromOutside(double amount) {
    _externalExpenseAmount = amount;
    saveBalanceAmountToPrefs(balanceAmount); // Automatically save balance
    notifyListeners();
  }
// 5. Load balance from SharedPreferences (optional)
  Future<void> loadBalanceAmountFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBalance = prefs.getDouble('balanceAmount');
    if (savedBalance != null) {
      _externalExpenseAmount = _totalIncomeAmount - savedBalance;
      notifyListeners();
    }
  }
// 4. Save balance locally
  Future<void> saveBalanceAmountToPrefs(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balanceAmount', amount);
  }
  double get totalIncomeAmount => _totalIncomeAmount;
  void setShop(String newShop) async {
    selectShop = newShop;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedShop', selectShop!);
    notifyListeners();
  }

  Future<void> saveNewShop(String newShop) async {
    if (!shop.contains(newShop)) {
      shop.add(newShop);
      shops.sort();
      print(shops);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('shops', shops);
    }
    setShop(newShop);
    notifyListeners();
  }

  void loadShops() async {
    final prefs = await SharedPreferences.getInstance();
    shops = prefs.getStringList('shops') ??
        [
          'Asirvatham Store',
          'Saravana Stores',
          'Pothys',
          'RMKV Silks',
          'The Chennai Silks',
          'Jayachandran Textiles',
          'Vasanth & Co',
          'Mega Mart'
        ];
    shops.sort();
    notifyListeners();
  }
//////////////////////////TODO:Payment..........................................

  int selectedPaymentIconIndex = -1;

  void setPaymentType(String newType) async {
    selectPaymentType = newType;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'selectedPaymentType', selectPaymentType);
    notifyListeners();
  }

  Future<void> savePaymentType(String type) async {
    if (!paymentTypes.contains(type) &&
        selectedPaymentIconIndex != -1) {
      final iconPath = data[selectedPaymentIconIndex]['icon'];
      paymentTypes.add(type);
      paymentMethods.add({'label': type, 'icon': iconPath});
      selectPaymentType = type;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('paymentTypes', paymentTypes);
      List<String> paymentMethodJson =
      paymentMethods.map((e) => jsonEncode(e)).toList();
      await prefs.setStringList('paymentMethods', paymentMethodJson);

      await prefs.setString(
          'selectedPaymentType', selectPaymentType);
      notifyListeners();
    }
  }
  String? selectCity = "";
  List<String> city = [
    'Tuticorin',
    'Chennai',
    'Coimbatore',
    'Erode',
    'Madurai',
    'Tirunelveli',
    'Vellore'
  ];

  String? get selectedCity => selectCity;

  List<String> get cities => city;



  List <dynamic> month=[
    {
      "name": "January",
      "short": "Jan",
      "number": 1,
      "days": 31
    } ,
    {
      "name": "February",
      "short": "Feb",
      "number": 2,
      "days": 28
    }  ,
    {
      "name": "March",
      "short": "Mar",
      "number": 3,
      "days": 31
    } ,
    {
      "name": "April",
      "short": "Apr",
      "number": 4,
      "days": 30
    },
    {
      "name": "May",
      "short": "May",
      "number": 5,
      "days": 31
    },
    {
      "name": "June",
      "short": "Jun",
      "number": 6,
      "days": 30
    },
    {
      "name": "July",
      "short": "Jul",
      "number": 7,
      "days": 31
    },
    {
      "name": "August",
      "short": "Aug",
      "number": 8,
      "days": 31
    },
    {
      "name": "September",
      "short": "Sep",
      "number": 9,
      "days": 30
    },
    {
      "name": "October",
      "short": "Oct",
      "number": 10,
      "days": 31
    },
    {
      "name": "November",
      "short": "Nov",
      "number": 11,
      "days": 30
    },
    {
      "name": "December",
      "short": "Dec",
      "number": 12,
      "days": 31
    }

  ];



  String? selectShop = "";
  List<String> shops = [
    "Millers Super Market",
    "Asirvatham Store",
    "Saravana Stores",
    "Pothys",
    "RMKV Silks",
    "The Chennai Silks",
    "Jayachandran Textiles",
    "Vasanth & Co",
    "Mega Mart"
  ];

  // Getter
  String? get selectedShop => selectShop;

  // Setter
  set selectedShop(String? value) {
    selectShop = value;
  }

  // Optional: getter for shops
  List<String> get shop => shops;


  String selectHead = "";

  String get selectedHead => selectHead;

  List<String> expansionHead = ['Food', 'Travel', 'Shopping', 'Milk', 'Salary', 'Snacks'];

  List<String> get expansionHeads => expansionHead;

//////////////////TODO:Payment...............

  String selectPaymentType = "";

  String get selectedPaymentType => selectPaymentType;

  List<String> paymentTypes = ['Cash', 'Credit', 'UPI', 'Bank'];

  List<String> get paymentType => paymentTypes;
  List<Map<String, dynamic>> get paymentMethod => paymentMethods;

  late List<Map<String, dynamic>> paymentMethods = [
    {'icon': 'assets/images/expasy/moneybagnew.svg', 'label': 'Cash'},
    {'icon': 'assets/images/expasy/credit.svg', 'label': 'Credit'},
    {'icon': 'assets/images/expasy/upi.svg', 'label': 'UPI'},
    {'icon': 'assets/images/expasy/account_balance.svg', 'label': 'Bank'},
  ];

  List<Map<String, dynamic>> data = [
    {
      "icon": "assets/images/expasy/credit.svg",
      "title": "Credit Card",
    },
    {
      "icon": "assets/images/expasy/upi_pay.svg",
      "title": "UPI Pay",
    },
    {
      "icon": "assets/images/expasy/debit_card.svg",
      "title": "Debit Card",
    },
    {
      "icon": "assets/images/expasy/cheque.svg",
      "title": "Cheque",
    },
    {
      "icon": "assets/images/expasy/pay_pal.svg",
      "title": "PayPal",
    },
    {
      "icon": "assets/images/expasy/google_pay.svg",
      "title": "Google Pay",
    },
    {
      "icon": "assets/images/expasy/phonepe.svg",
      "title": "PhonePe",
    },
    {
      "icon": "assets/images/expasy/amazon_pay.svg",
      "title": "Amazon Pay",
    },
    {
      "icon": "assets/images/expasy/apple_pay_brands.svg",
      "title": "Apple Pay",
    },
    {
      "icon": "assets/images/expasy/bag.svg",
      "title": "Bag",
    },
    {
      "icon": "assets/images/expasy/calendar_icon.svg",
      "title": "Calendar",
    },
    {
      "icon": "assets/images/expasy/wallet-solid.svg",
      "title": "Wallet",
    },
    {
      "icon": "assets/images/expasy/brands_solid.svg",
      "title": "Brands",
    },
    {
      "icon": "assets/images/expasy/hourglass_solid.svg",
      "title": "Hourglass",
    },
    {
      "icon": "assets/images/expasy/cash_register_solid.svg",
      "title": "Cash Register",
    },
    {
      "icon": "assets/images/expasy/mobile.svg",
      "title": "Mobile",
    },
    {
      "icon": "assets/images/expasy/ellipsis_solid.svg",
      "title": "Ellipsis",
    },
  ];
  Future<void> loadSavedPaymentTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTypes = prefs.getStringList('paymentTypes');
    final selectedType = prefs.getString('selectedPaymentType');
    final savedMethodsJson = prefs.getStringList('paymentMethods');

    if (savedTypes != null) {
      paymentTypes = savedTypes;
    }
    if (savedMethodsJson != null) {
      paymentMethods = savedMethodsJson
          .map((e) => Map<String, String>.from(jsonDecode(e)))
          .toList();
    }
    if (selectedType != null) {
      selectPaymentType = selectedType;
    }
    notifyListeners();
  }

  String selectedPaymentLabel = "";

  void selectPaymentIcon(int index) {
    if (selectedPaymentIconIndex == index) {
      selectedPaymentIconIndex = -1;
      selectedPaymentLabel = "";
      paymentController.clear();
    } else {
      selectedPaymentIconIndex = index;
      selectedPaymentLabel = data[index]['title'];
      paymentController.text = selectedPaymentLabel;
    }
    notifyListeners();
  }

  void clearPaymentIconSelection() {
    selectedPaymentIconIndex = -1;
    selectedPaymentLabel = "";
    paymentController.clear();
    notifyListeners();
  }
//version life fun
  String serverVersion ="";
  String get currentVersion => serverVersion;
  void storeData(String version){
    notifyListeners();
    serverVersion = version;
    notifyListeners();
  }

  bool activeVersion = false;
  bool get versionActive => activeVersion;
  bool availableUpdate = false;
  bool get updateAvailable => availableUpdate;
  bool _isExpenseValid = false;
  String _expenseErrorMessage = "";

///ToDo:adexpense...................
  Future<bool> addExpense(BuildContext context) async {
    String? _accounts = selectedAccount;
    String _head = selectedHead ?? '';
    String _payments = selectedPaymentType;
    String? _shops = selectedShop;
    String? _cities = selectedCity;
    _isExpenseValid = false;
    bool isSuccess = false;
    if (dateController.text.isEmpty) {
      utils.showWarningToast(context, text: "Please enter the Date.");
    } else if (_accounts.isEmpty || _accounts == 'Select Account') {
      utils.showWarningToast(context, text: "Please select an account");
    } else if (_head.isEmpty || _head == 'Select Head') {
      utils.showWarningToast(context, text: "Please select an Expense Head");
    } else if (_payments.isEmpty || _payments == 'Select Payment') {
      utils.showWarningToast(context, text: "Please select a Payment Type");
    } 
    else {
      if(getExpenseList().isNotEmpty){
        final response = await expenseService.insertExpense(
          mobile: localData.storage.read("mobile_number"),
          userAccount: _accounts.toString(),
          city: _cities.toString(),
          shop: _shops.toString(),
          expenseHead: _head.toString(),
          paymentType: _payments.toString(),
          particulars: particularsController.text.trim().isNotEmpty
              ? particularsController.text.trim()
              : '',
          gst: _selectedGST.toString(),
          amount: amountController.text.trim().replaceAll(',', ''),
          date: dateController.text,
          userId: localData.storage.read("id"),
          expenseList: getExpenseList(),
        );
        if (response["ResponseCode"] == "200") {
          utils.showSuccessToast(context: context, text: "Inserted Successfully");
          clearFormData();
          tabController?.animateTo(1);
          Navigator.pop(context);
          fetchAllExpense();
          saveCtr.reset();
        } else {
          utils.showErrorToast(context:context);
          saveCtr.reset();
        }
      }else{
        utils.showWarningToast(context, text: "Please fill Item Name and Amount before adding a new item");
        saveCtr.reset();
      }
      notifyListeners();
    }
    return isSuccess;
  }


  String _selectedAccount = "";
  List<String> _accounts = [];

  List<String> get accounts => _accounts;

  String get selectedAccount => _selectedAccount;

  Future<void> initializeUserData() async {
    await loadAccounts();
    await loadSelectedAccount();

  }

  Future<void> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    _accounts = prefs.getStringList('accounts') ?? [];

    if (_accounts.isEmpty) {
      _accounts = ['Saving', 'Credit', 'Cash', 'Bank'];
      await prefs.setStringList('accounts', _accounts);
    }

    notifyListeners();
  }

  Future<void> loadSelectedAccount() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedAccount = prefs.getString('selectedAccount') ?? '';
    notifyListeners();
  }

  Future<void> setSelectedAccount(String newValue) async {
    _selectedAccount = newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAccount', _selectedAccount);
    notifyListeners();
  }

  Future<void> saveNewAccount(String newAccount) async {
    final prefs = await SharedPreferences.getInstance();

    if (!_accounts.contains(newAccount)) {
      _accounts.add(newAccount);
      await prefs.setStringList('accounts', _accounts);
    }

    await setSelectedAccount(newAccount);
  }

  /////////////////////////Todo.Gst....................
  double _selectedGST = 0.0;

  double get selectedGST => _selectedGST;

  void setGST(double value) {
    _selectedGST = value;
    updateTotalAmountWithGST();
    notifyListeners();
  }



  /////////////////////////Todo.items....................

  List<Map<String, dynamic>> itemRows = [];
  Map<String, dynamic> dataRows = {};
  void setItemRows(List<Map<String, TextEditingController>> rows) {
    itemRows = rows
        .map((row) => {
      'itemController':
      TextEditingController(text: row['itemController']?.text.trim()),
      'quantityController':
      TextEditingController(text: row['quantityController']?.text.trim()),
      'amountController':
      TextEditingController(text: row['amountController']?.text.trim()),
    })
        .toList();
    notifyListeners();
  }
  /// புதிய row add பண்ண
  void addItemRow({String? itemId, String? itemName, String? qty, String? price}) {
    itemRows.add({
      'item_id': itemId ?? "",
      'itemController': TextEditingController(text: itemName ?? ""),
      'quantityController': TextEditingController(text: qty ?? ""),
      'amountController': TextEditingController(text: price ?? ""),
    });
   updateTotalAmountWithGST();

    notifyListeners();
  }

  /// எல்லா rows clear பண்ண
  void clearItemRows() {
    for (var row in itemRows) {
      (row['itemController'] as TextEditingController).dispose();
      (row['quantityController'] as TextEditingController).dispose();
      (row['amountController'] as TextEditingController).dispose();
    }
    itemRows.clear();
    notifyListeners();
  }

  /// பழைய items-ஐ load பண்ணும் போது (Update Page)
  void setItemRowsFromExpenseList(List<ExpenseList> items) {
    clearItemRows();
    for (var item in items) {
      addItemRow(
        itemId: item.itemId,
        itemName: item.itemName,
        qty: item.qty,
        price: item.price,
      );
    }
  }

  /// Row remove பண்ண
  void removeItemRow(int index) {
    (itemRows[index]['itemController'] as TextEditingController).dispose();
    (itemRows[index]['quantityController'] as TextEditingController).dispose();
    (itemRows[index]['amountController'] as TextEditingController).dispose();
    itemRows.removeAt(index);
   updateTotalAmountWithGST();
    notifyListeners();
  }

  /// Add செய்ய API க்கு போகும் data
  List<Map<String, String>> getExpenseList() {
    return itemRows.where((row) {
      final itemName = (row['itemController'] as TextEditingController).text.trim();
      final price = (row['amountController'] as TextEditingController).text.trim();
      return itemName.isNotEmpty && price.isNotEmpty;
    }).map((row) {
      final qty = (row['quantityController'] as TextEditingController).text.trim();
      return {
        "item_name": (row['itemController'] as TextEditingController).text.trim(),
        "qty": qty.isNotEmpty ? qty : "0",
        "price": (row['amountController'] as TextEditingController).text.trim(),
      };
    }).toList();
  }

  /// Update செய்ய API க்கு போகும் data
  List<Map<String, String>> getUpdateExpenseList() {
    return itemRows.where((row) {
      final itemName = (row['itemController'] as TextEditingController).text.trim();
      final price = (row['amountController'] as TextEditingController).text.trim();
      return itemName.isNotEmpty && price.isNotEmpty;
    }).map((row) {
      final qty = (row['quantityController'] as TextEditingController).text.trim();
      return {
        "item_id": (row['item_id'] ?? "").toString(),
        "item_name": (row['itemController'] as TextEditingController).text.trim(),
        "qty": qty.isNotEmpty ? qty : "0",
        "price": (row['amountController'] as TextEditingController).text.trim(),
      };
    }).toList();
  }

  List<Map<String, TextEditingController>> _dynamicRows = [
    {
      'itemController': TextEditingController(),
      'quantityController': TextEditingController(),
      'amountController': TextEditingController(),
    },
  ];


  void clearFormData() {
    _selectedAccount = 'Select Account';
    selectCity = 'Select City';
    selectShop = 'Select Shop';
    selectHead = 'Select Head';
    selectPaymentType = 'Select Payment';
    _selectedGST = 0;
    _selectedDate = null;
    particularsController.text = '';
    amountController.text = '';
    dateController.clear();
    for (var row in itemRows) {
      (row['itemController'] as TextEditingController).clear();
      (row['quantityController'] as TextEditingController).clear();
      (row['amountController'] as TextEditingController).clear();
    }
    itemRows.clear();
    itemRows.add({
      'itemController': TextEditingController(),
      'quantityController': TextEditingController(),
      'amountController': TextEditingController(),
    });

    notifyListeners();
  }

  ////Todo:delete
  Future<void> deleteExpenseFromUI({
    required BuildContext context,
    required String expenseId,
    required String userId,
    required bool shouldDelete,
  }) async {
    notifyListeners();
    try {
      final response = await expenseService.deleteExpense(
        expenseId: expenseId
      );
      print("response $response");
      Map<String, dynamic> outResponse = response;
      if (outResponse["status_code"].toString() == "200" &&
          outResponse["message"].toString().toLowerCase() == "ok") {
        expensesList.removeWhere((expense) => expense.id == expenseId);
        _allExpenses.removeWhere((expense) => expense.id == expenseId);
        _totalExpenses = 0;
        for (var income in _allExpenses) {
          double expenseAmount = double.tryParse(income.amount.toString()) ?? 0.0;
          _totalExpenses += expenseAmount;
        }
        Navigator.pop(context);
        notifyListeners();
        // await fetchExpense();
        if (shouldDelete) {
          saveCtr.reset();
          utils.showSuccessToast(context: context, text: constValue.deleted);
          Navigator.pop(context);
          notifyListeners();
        }
      } else {
        saveCtr.reset();
        utils.showErrorToast(context: context);
        _expenseErrorMessage =
        "Delete failed: ${response["message"] ?? "Unknown error"}";
      }
    } catch (e) {
      saveCtr.reset();
      utils.showErrorToast(context: context);
      _expenseErrorMessage = "Delete failed: $e";
      print("Delete failed: $e");
    } finally {
      notifyListeners();
    }
  }

  /////TODO:date.....................................

  DateTime? _selectedNewDate;

  DateTime? get selectedNewDate => _selectedNewDate;
  TextEditingController dateControllerNew = TextEditingController(text: "");
  Future<void> setDates(DateTime newDate) async {
    _selectedNewDate = newDate;
    dateControllerNew.text = DateFormat("dd-MM-yyyy").format(newDate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDate', dateControllerNew.text);
    notifyListeners();
  }
  TextEditingController accountControllerNew = TextEditingController();
  String _selectedNewAccount = "";
  List<String> _newaccounts = [];

  List<String> get newaccounts => _newaccounts;

  String get selectedNewAccount => _selectedNewAccount;

  Future<void> initializeUserDataNew() async {
    await loadAccountsNew();
    // await loadSelectedAccount();
  }

  Future<void> loadAccountsNew() async {
    final prefs = await SharedPreferences.getInstance();
    _newaccounts = prefs.getStringList('newaccounts') ?? [];

    if (_newaccounts.isEmpty) {
      _newaccounts = ['Saving', 'Credit', 'Cash', 'Bank'];
      await prefs.setStringList('newaccounts', _newaccounts);
    }

    notifyListeners();
  }

  Future<void> loadSelectedAccountNew() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedNewAccount = prefs.getString('selectedNewAccount') ?? '';
    notifyListeners();
  }
  Future<void> setSelectedAccountNew(String newValue) async {
    _selectedNewAccount = newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedNewAccount', _selectedNewAccount);
    notifyListeners();
  }

  Future<void> saveNewAccountNew(String newSaveAccount) async {
    final prefs = await SharedPreferences.getInstance();

    if (!_newaccounts.contains(newSaveAccount)) {
      _newaccounts.add(newSaveAccount);
      await prefs.setStringList('newaccounts', _newaccounts);
    }

    await setSelectedAccountNew(newSaveAccount);
  }


  //Simple Expense
  void saveSimpleExpense() {
    final amount = amountController.text.trim();
    final account = selectedNewAccount;
    final shop = selectShop;
    final city = selectCity;
    final head = selectHead;
    final payment = selectPaymentType;
    final date = selectedNewDate;

    // 1. Validate required fields here if needed

    // 2. Save to your database or service
    print("Saving Expense => Amount: $amount, Account: $account, Shop: $shop, City: $city, Head: $head, Payment: $payment, Date: $date");

    // 3. Clear after saving
    clearSimpleExpenseForm();
  }

  void clearSimpleExpenseForm() {
    amountController.clear();
    accountControllerNew.clear();
    shopNameController.clear();
    headController.clear();
    paymentController.clear();
    dateControllerNew.clear();

    _selectedNewAccount = "";
    _selectedNewDate;
    selectShop = null;
    selectCity = null;
    selectHead = "";
    selectPaymentType = "";

    notifyListeners();
  }

  bool saveSimpleExpenses(BuildContext context) {
    final amount = amountController.text.trim();
    final account = selectedNewAccount;
    final shop = selectShop;
    final city = selectCity;
    final head = selectHead;
    final payment = selectPaymentType;
    final date = selectedNewDate;

    // 1. Validate required fields
    if (amount.isEmpty ||
        account == "" ||
        shop == "" ||
        city == "" ||
        head.isEmpty ||
        payment.isEmpty ||
        date == "") {
      utils.showWarningToast(context, text: "Please fill all fields");

      return false;
    }

    // 2. Save action
    print("Saving Expense => Amount: $amount, Account: $account, Shop: $shop, City: $city, Head: $head, Payment: $payment, Date: $date");

    // 3. Clear after saving
    clearSimpleExpenseForm();

    // ✅ Show success SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Expense saved successfully"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    return true;
  }
  double get filteredExpenseAmount {
    if (filterDateController.text.isEmpty) {
      return totalExpenseAmount; // all expenses
    }

    return _expensesList
        .where((e) => e.date == filterDateController.text) // adjust date format if needed
        .fold(0.0, (sum, e) => sum + (double.tryParse(e.amount.toString()) ?? 0.0));
  }

  List dropFilter =["Today", "Yesterday", "Last 7 days","Last 30 days","This year"];
  dynamic filters;

RoundedLoadingButtonController saveCtr=RoundedLoadingButtonController();

  Future<void> createIncome({
    required BuildContext context,
    required String income,
    required String reason,
    required String date,
    required String userId,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await expenseService.insertIncome(
        income: income,
        reason: reason,
        date: date,
        userId: userId,
      );

      print(" After API Call - response: $response");

      if (response["ResponseCode"].toString().toLowerCase() == "200") {
        utils.showSuccessToast(context: context, text: "Insert Income Successfully");
        tabController?.animateTo(0);
        saveCtr.reset();
        fetchIncome();
        incomeTypeController.clear();
        incomeDateController.clear();
        incomeReasonController.clear();
        Navigator.pop(context);
      }
    } catch (e, stack) {
      print(" Exception in Insert Income: $e");
      print(" Stacktrace: $stack");
      utils.showErrorToast(context:context);
      saveCtr.reset();
    } finally {
      isLoading = false;
      saveCtr.reset();
      notifyListeners();
    }
  }
  var income ;
  double _totalIncomeAmount = 0.0, _mainBalance = 0.0, _totalExpenses = 0.0;
  List<IncomeData> _allIncome = [], _incomeList = [];

  double get mainBalance => _mainBalance;
  double get totalExpenses => _totalExpenses;
  List<IncomeData> get incomeList => _incomeList;
  Future<void> loadIncomes(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    String? incomeListJson = prefs.getString("${userId}_incomeList");
    if (incomeListJson != null) {
      _incomeList = List<Map<String, dynamic>>.from(jsonDecode(incomeListJson)).cast<IncomeData>();
    } else {
      _incomeList = [];
    }

    // ✅ Same key
    _totalIncomeAmount = prefs.getDouble("${userId}_totalIncomeAmount") ?? 0.0;

    notifyListeners();
  }


  String _incomeReason = "";
  double _incomeAmount = 0.0;
  String _incomeDate = "";

  // ✅ Getters
  // double get totalIncomeAmount => _totalIncomeAmount;
  String get incomeReason => _incomeReason;

  double get incomeAmount => _incomeAmount;

  String get incomeDate => _incomeDate;
  Future<void> loadIncomeAmountFromPrefs(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    _incomeReason = prefs.getString('${userId}_incomeReason') ?? "";
    _incomeAmount =
        double.tryParse(prefs.getString('${userId}_incomeAmount') ?? "0") ?? 0;
    _incomeDate = prefs.getString('${userId}_incomeDate') ?? "";

    // ✅ Use same key everywhere
    _totalIncomeAmount =
        prefs.getDouble('${userId}_totalIncomeAmount') ?? 0.0;

    print("Loaded income for $userId -> "
        "Reason: $_incomeReason, "
        "Amount: $_incomeAmount, "
        "Date: $_incomeDate, "
        "Total: $_totalIncomeAmount");

    notifyListeners();
  }

  Future<void> fetchIncome() async {
    isLoading = true;
    notifyListeners();
    try {
      IncomeObj response = await ExpenseService.getExpensesIncome();
      if (response.responseCode == "200") {
        _allIncome = response.response;
        _incomeList = response.response;

        // ✅ calculate total income from server data
        _mainBalance = _allIncome.fold(
          0.0,
              (sum, item) => sum + (double.tryParse(item.income) ?? 0.0),
        );
        if(selectedMonth != null) {
          filterExpensesByRange("s_month", selectedMonth);
        } else if(filterDateController.text != "Select Date"  && filterDateController.text != "") {
          filterExpensesByRange("s_date", DateFormat('dd-MM-yyyy').parse(filterDateController.text));
        } else {
          filterExpensesByRange(filters, selectedMonth);
        }
      } else {
        _allIncome = [];
        _mainBalance = 0.0;
      }
    } catch (e) {
      print("❌ getExpenses Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> updateIncome(BuildContext context, IncomeData updatedData) async {
    try {
      final response = await ExpenseService.updateIncome(
        id: updatedData.id,
        income: updatedData.income,
        date: updatedData.date,
        userId: updatedData.userId,
        reason: updatedData.reason,
      );

      if (response["ResponseCode"] == "200") {
        // update local list
        final index = _allIncome.indexWhere((i) => i.id == updatedData.id);
        if (index != -1) {
          _allIncome[index] = updatedData;
        }
        _mainBalance = _allIncome.fold(0.0, (sum, item) => sum + (double.tryParse(item.income) ?? 0.0),);
        if(selectedMonth != null) {
          filterExpensesByRange("s_month", selectedMonth);
        } else if(filterDateController.text != "Select Date"  && filterDateController.text != "") {
          filterExpensesByRange("s_date", DateFormat('dd-MM-yyyy').parse(filterDateController.text));
        } else {
          filterExpensesByRange(filters, selectedMonth);
        }
        saveCtr.reset();
        notifyListeners();
        tabController?.animateTo(1);
        utils.showSuccessToast(context: context, text: "Income updated successfully");
        Navigator.pop(context);
      }
    } catch (e) {
      saveCtr.reset();
      utils.showErrorToast(context: context);
    }
  }
  Future<void> deleteIncome(BuildContext context, String id, String userId) async {
    try {
      final response = await ExpenseService.deleteIncome(id: id,
          userId: userId
      );
      // ✅ Accept both response styles
      final isSuccess =response["message"].toString().toLowerCase() == "ok";

      if (isSuccess) {
        _allIncome.removeWhere((i) => i.id == id);
        _mainBalance = _allIncome.fold(0.0, (sum, item) => sum + (double.tryParse(item.income) ?? 0.0),);
        saveCtr.reset();
        if(selectedMonth != null) {
          filterExpensesByRange("s_month", selectedMonth);
        } else if(filterDateController.text != "Select Date"  && filterDateController.text != "") {
          filterExpensesByRange("s_date", DateFormat('dd-MM-yyyy').parse(filterDateController.text));
        } else {
          filterExpensesByRange(filters, selectedMonth);
        }
        notifyListeners();
        utils.showSuccessToast(context: context, text: "Income deleted successfully");
        Navigator.pop(context);
      } else {
        saveCtr.reset();
        utils.showErrorToast(context: context);
        throw Exception("Delete failed: ${response["ResponseMsg"] ?? response["message"] ?? "Unknown error"}");
      }
    } catch (e) {
      saveCtr.reset();
      utils.showErrorToast(context: context);
    }
  }

  int selectedIndex = 0;

  int get selected => selectedIndex;

  final TextEditingController incomeDateController = TextEditingController();
  final TextEditingController incomeReasonController = TextEditingController();
  TextEditingController incomeTypeController = TextEditingController();

  void onItemTapped(int index, VoidCallback action) {
    notifyListeners();
    selectedIndex = index;
    action();
    notifyListeners();
  }
  String formattedAmount(dynamic amount) {
    if (amount == null) return "₹ 0.00";

    final doubleValue = (amount is String)
        ? double.tryParse(amount) ?? 0.0
        : (amount is int)
        ? amount.toDouble()
        : (amount as double);

    // Check if it has decimals
    final hasDecimals = doubleValue % 1 != 0;

    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: hasDecimals ? 2 : 0,
    ).format(doubleValue);
  }

}
