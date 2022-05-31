class SpecificParty {
  SpecificParty({
    this.modeOfPayment,
    this.total,
    this.id,
    this.createdAt,
    this.v,
  });

  String? modeOfPayment;
  int? total;
  String? id;
  DateTime? createdAt;
  int? v;

  factory SpecificParty.fromMap(Map<String, dynamic> json) => SpecificParty(
        modeOfPayment: json["modeOfPayment"],
        total: json["total"],
        id: json["_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toMap() => {
        "modeOfPayment": modeOfPayment,
        "amount": total,
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
        "__v": v,
      };
}
