import 'package:magicstep/src/models/product.dart';

import '../party.dart';
import '../user.dart';

class OrderInput {
  OrderInput({
    this.orderItems,
    this.modeOfPayment,
    this.party,
    this.user,
    this.createdAt,
  });

  List<OrderItemInput>? orderItems;
  String? modeOfPayment;
  Party? party;
  User? user;
  DateTime? createdAt;

  factory OrderInput.fromMap(Map<String, dynamic> json) => OrderInput(
        orderItems: List<OrderItemInput>.from(
          json["orderItems"].map(
            (x) => OrderItemInput.fromMap(x),
          ),
        ),
        modeOfPayment: json["modeOfPayment"],
        party: json["party"],
        user: json["user"],
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toMap() => {
        "orderItems": orderItems?.map((e) => e.toMap()).toList(),
        "modeOfPayment": modeOfPayment,
        "party": party?.id,
        "user": user?.id,
        "createdAt": createdAt.toString(),
      };
}

class OrderItemInput {
  OrderItemInput({
    this.price = 0,
    this.quantity = 0,
    this.product,
  });

  int? price;
  int quantity;
  Product? product;

  factory OrderItemInput.fromMap(Map<String, dynamic> json) => OrderItemInput(
        price: json["price"],
        quantity: json["quantity"],
        product: json["product"],
      );

  Map<String, dynamic> toMap() => {
        "price": price,
        "quantity": quantity,
        "product": product?.id,
      };
}
