class Party {
  Party({
    this.name,
    this.phoneNumber,
    this.id,
    this.createdAt,
    this.totalCreditAmount,
    this.v,
    this.total,
  });

  String? name;
  String? phoneNumber;
  String? id;
  DateTime? createdAt;
  String? v;
  int? totalCreditAmount;
  int? total;

  factory Party.fromMap(Map<String, dynamic> json) => Party(
        name: json["name"],
        phoneNumber: json["phoneNumber"].toString(),
        id: json["_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        totalCreditAmount: json["totalCreditAmount"],
        total: json["total"],
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
