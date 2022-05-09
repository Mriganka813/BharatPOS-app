// To parse this JSON data, do
//
//     final product = productFromMap(jsonString);

import 'dart:convert';

Product productFromMap(String str) => Product.fromMap(json.decode(str));

String productToMap(Product data) => json.encode(data.toMap());

class Product {
  Product({
    this.name,
    this.sellingPrice,
    this.barCode,
    this.quantity,
    this.user,
    this.id,
    this.purchaseQuantity = 1,
    this.createdAt,
    this.v,
  });

  String? name;
  int? sellingPrice;
  String? barCode;
  int? quantity;
  String? user;
  String? id;
  int purchaseQuantity;
  DateTime? createdAt;
  int? v;

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        name: json["name"],
        sellingPrice: json["sellingPrice"],
        barCode: json["barCode"],
        quantity: json["quantity"],
        user: json["user"],
        id: json["_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "sellingPrice": sellingPrice,
        "barCode": barCode,
        "quantity": quantity,
        "user": user,
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
        "__v": v,
      };
}
