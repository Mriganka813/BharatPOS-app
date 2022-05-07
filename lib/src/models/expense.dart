class Expense {
  Expense({
    this.header,
    this.description,
    this.amount,
    this.modeOfPayment,
  });

  String? header;
  String? description;
  int? amount;
  String? modeOfPayment;

  factory Expense.fromMap(Map<String, dynamic> json) => Expense(
        header: json["header"],
        description: json["description"],
        amount: json["amount"] ?? "",
        modeOfPayment: json["modeOfPayment"],
      );

  Map<String, dynamic> toMap() => {
        "header": header,
        "description": description,
        "amount": amount.toString(),
        "modeOfPayment": modeOfPayment,
      };
}
