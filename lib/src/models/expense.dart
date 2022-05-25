class Expense {
  Expense({
    this.header,
    this.description,
    this.amount,
    this.modeOfPayment,
    this.id,
    this.createdAt,
    this.v,
  });

  String? header;
  int? amount;
  String? description;
  String? modeOfPayment;
  String? id;
  DateTime? createdAt;
  int? v;

  factory Expense.fromMap(Map<String, dynamic> json) => Expense(
        header: json["header"],
        amount: json["amount"],
        description: json["description"],
        modeOfPayment: json["modeOfPayment"],
        id: json["_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toMap() => {
        "header": header,
        "amount": amount,
        "description": description,
        "modeOfPayment": modeOfPayment,
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
        "__v": v,
      };
}
