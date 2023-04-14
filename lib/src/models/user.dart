// To parse this JSON data, do
//
//     final user = userFromMap(jsonString);

class User {
  User(
      {this.email,
      this.password,
      this.address,
      this.role,
      this.businessName,
      this.businessType,
      this.phoneNumber,
      this.id,
      this.createdAt,
      this.updatedAt,
      this.v,
      this.type});

  String? email;
  String? password;
  String? address;
  String? role;
  String? businessName;
  String? businessType;
  int? phoneNumber;
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? type;

  factory User.fromMap(Map<String, dynamic> json) => User(
      email: json["email"],
      password: json["password"],
      address: json["address"],
      role: json["role"],
      businessName: json["businessName"],
      businessType: json["businessType"],
      phoneNumber: json["phoneNumber"],
      id: json["_id"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      v: json["__v"],
      type: json["taxFile"]);

//extracting taxfile detail from json
  factory User.fromMMap(Map<String, dynamic> json) =>
      User(id: json["_id"], type: json["taxFile"]);

  Map<String, dynamic> toMap() => {
        "email": email,
        "password": password,
        "address": address,
        "role": role,
        "businessName": businessName,
        "businessType": businessType,
        "phoneNumber": phoneNumber,
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}
