import 'package:shopos/src/models/order_item.dart';
import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/models/user.dart';

class Order {
  Order({
    this.orderItems,
    this.modeOfPayment,
    this.party,
    this.user,
    this.createdAt = '',
  });

  List<OrderItem>? orderItems;
  String? modeOfPayment;
  Party? party;
  User? user;
  String createdAt;

  factory Order.fromMap(Map<String, dynamic> json) => Order(
        orderItems: List<OrderItem>.from(
          json["orderItems"].map(
            (x) => OrderItem.fromMap(x),
          ),
        ),
        modeOfPayment: json["modeOfPayment"],
        party: json["party"] is Map ? Party.fromMap(json["party"]) : null,
        user: json["user"] is Map ? User.fromMap(json["user"]) : null,
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toMap() => {
        "orderItems": orderItems?.map((e) => e.toMap()).toList(),
        "modeOfPayment": modeOfPayment,
        "party": party,
        "user": user,
        "createdAt": createdAt,
      };
}
