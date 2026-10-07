class ExpenseDetailsObj {
  String id;
  String expenseHead;
  String paymentType;
  String shopName;
  String amount;
  String createdTs;
  String active;
  String userAccount;
  String city;
  String particulars;
  String gst;
  String? date;
  List<ExpenseList> expenseList;

  ExpenseDetailsObj({
    required this.id,
    required this.expenseHead,
    required this.paymentType,
    required this.shopName,
    required this.amount,
    required this.createdTs,
    required this.active,
    required this.userAccount,
    required this.city,
    required this.particulars,
    required this.gst,
    this.date,
    required this.expenseList,
  });

  factory ExpenseDetailsObj.fromJson(Map<String, dynamic> json) =>
      ExpenseDetailsObj(
        id: json["id"],
        expenseHead: json["expense_head"],
        paymentType: json["payment_type"],
        shopName: json["shop_name"],
        amount: json["amount"],
        createdTs: json["created_ts"],
        active: json["active"],
        userAccount: json["user_account"],
        city: json["city"],
        particulars: json["particulars"],
        gst: json["gst"],
        date: json["date"],
        expenseList: List<ExpenseList>.from(
            json["expenseList"].map((x) => ExpenseList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "expense_head": expenseHead,
        "payment_type": paymentType,
        "shop_name": shopName,
        "amount": amount,
        "created_ts": createdTs,
        "active": active,
        "user_account": userAccount,
        "city": city,
        "particulars": particulars,
        "gst": gst,
        "date": date,
        "expenseList": List<dynamic>.from(expenseList.map((x) => x.toJson())),
      };
}

class ExpenseList {
  String itemName;
  String qty;
  String price;
  String itemId;

  ExpenseList({
    required this.itemName,
    required this.qty,
    required this.price,
    required this.itemId
  });

  factory ExpenseList.fromJson(Map<String, dynamic> json) => ExpenseList(
        itemId: json["item_id"],
        itemName: json["item_name"],
        qty: json["qty"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "item_id": itemId,
        "item_name": itemName,
        "qty": qty,
        "price": price,
      };
}
