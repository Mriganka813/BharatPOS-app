class Party {
  Party(
      {this.name,
      this.phoneNumber,
      this.id,
      this.createdAt,
      this.totalCreditAmount,
      this.totalSettleAmount,
      this.v,
      this.total,
      this.type,
      this.balance,
      this.address,
      this.modeOfPayment});

  String? name;
  String? phoneNumber;
  String? id;
  String? modeOfPayment;
  String? address;
  DateTime? createdAt;
  String? type;
  String? v;
  int? totalCreditAmount;
  int? totalSettleAmount;
  int? total;
  int? balance;

  factory Party.fromMap(Map<String, dynamic> json) => Party(
        name: json["name"],
        phoneNumber: json["phoneNumber"].toString(),
        id: json["_id"],
        type: json['type'],
        createdAt: DateTime.parse(json["createdAt"]),
        totalCreditAmount: json["totalCreditAmount"],
        totalSettleAmount: json['totalSettleAmount'],
        balance: json['balance'] ?? 0,
        total: json["total"],
        address: json["address"],
        v: json["__v"].toString(),
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "phoneNumber": phoneNumber,
        "_id": id,
        'type': type,
        "createdAt": createdAt?.toIso8601String(),
        "modeOfPayment": modeOfPayment,
        "amount": total,
        "total": total,
        "address": address,
        "balance": balance,
        "__v": v,
      };
}
