class Party {
  Party({
    this.name,
    this.phoneNumber,
    this.id,
    this.createdAt,
    this.totalCreditAmount,
    this.v,
  });

  String? name;
  String? phoneNumber;
  String? id;
  DateTime? createdAt;
  String? v;
  int? totalCreditAmount;

  factory Party.fromMap(Map<String, dynamic> json) => Party(
        name: json["name"],
        phoneNumber: json["phoneNumber"].toString(),
        id: json["_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        totalCreditAmount: json["totalCreditAmount"],
        v: json["__v"].toString(),
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "phoneNumber": phoneNumber,
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
        "__v": v,
      };
}
