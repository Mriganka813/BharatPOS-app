class SpecificParty {
  SpecificParty({
    this.name,
    this.contactno,
    this.dueAmount,
    this.credit,
    this.settle,
    this.id,
    this.createdAt,
    this.v,
  });

  String? name;
  int? dueAmount;
  String? contactno;
  String? credit;
  String? settle;
  String? id;
  DateTime? createdAt;
  int? v;

  factory SpecificParty.fromMap(Map<String, dynamic> json) => SpecificParty(
        name: json["name"],
        dueAmount: json["dueAmount"],
        contactno: json["contactno"],
        credit: json["credit"],
        settle: json["settle"],
        id: json["_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "dueAmount": dueAmount,
        "contactno": contactno,
        "credit": credit,
        "settle": settle,
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
        "__v": v,
      };
}
