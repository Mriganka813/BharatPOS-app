class ExpenseFormInput {
  ExpenseFormInput(
      {this.header,
      this.description,
      this.amount,
      this.modeOfPayment,
      this.id,
      this.createdAt});

  String? header;
  String? amount;
  String? description;
  String? modeOfPayment;
  String? id;
  DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        "header": header,
        "description": description,
        "modeOfPayment": modeOfPayment,
        "amount": amount,
        "id": id,
        "date": createdAt?.toIso8601String()
      };
  factory ExpenseFormInput.fromMap(map) => ExpenseFormInput(
        header: map['header'],
        description: map['description'].toString(),
        modeOfPayment: map['modeOfPayment'].toString(),
        amount: map['amount']?.toString(),
        id: map['_id'].toString(),
      );
}
