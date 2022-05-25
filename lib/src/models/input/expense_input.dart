class ExpenseFormInput {
  ExpenseFormInput(
      {this.header,
      this.description,
      this.amount,
      this.modeOfPayment,
      this.id});

  String? header;
  String? amount;
  String? description;
  String? modeOfPayment;
  String? id;

  Map<String, dynamic> toMap() => {
        "header": header,
        "description": description,
        "modeOfPayment": modeOfPayment,
        "amount": amount,
        "id": id,
      };
  factory ExpenseFormInput.fromMap(map) => ExpenseFormInput(
        header: map['header'],
        description: map['description'].toString(),
        modeOfPayment: map['modeOfPayment'].toString(),
        amount: map['_amount'],
        id: map['_id'].toString(),
      );
}
