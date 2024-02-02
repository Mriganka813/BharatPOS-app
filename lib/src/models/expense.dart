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
  double? amount;
  String? description;
  String? modeOfPayment;
  String? id;
  DateTime? createdAt;
  int? v;

  factory Expense.fromMap(Map<String, dynamic> json) {

    // print("line 22 in expense.dart");
    // print(json["header"]);
    // print(json['createdAt'].runtimeType);
    // print(json['date'].runtimeType);
    // if(json['date']!=null){
    //   print(json['date']);
    // }
   return Expense(
     header: json["header"],
     amount: json["amount"].toDouble(),
     description: json["description"],
     modeOfPayment: json["modeOfPayment"],
     id: json["_id"],
     createdAt: DateTime.parse(json["date"]==null ? json["createdAt"] : json["date"]),
     v: json["__v"],
   );
  }

  Map<String, dynamic> toMap() => {
        "header": header,
        "amount": amount,
        "description": description,
        "modeOfPayment": modeOfPayment,
        "_id": id,
        "date": createdAt?.toIso8601String(),
        "__v": v,
      };
}
