class ExpenseItem {
  String? itemName;
  String? quantity;
  String? amount;

  ExpenseItem({this.itemName, this.quantity, this.amount});

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => ExpenseItem(
    itemName: json['item_name'],
    quantity: json['quantity'],
    amount: json['amount'],
  );

  Map<String, dynamic> toJson() => {
    'item_name': itemName,
    'quantity': quantity,
    'amount': amount,
  };
}
