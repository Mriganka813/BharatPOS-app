import 'package:shopos/src/models/order_item.dart';
import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/models/user.dart';

class Order {
  Order({
    this.orderItems,
    this.modeOfPayment,
    this.party,
    this.user,
    this.total = 0,
    this.id,
    this.createdAt = '',
  });

  List<OrderItem>? orderItems;
  String? modeOfPayment;
  Party? party;
  User? user;
  int? total;
  String? id;
  String createdAt;

  factory Order.fromMap(Map<String, dynamic> json) => Order(
        orderItems: List<OrderItem>.from(
          json["orderItems"].map(
            (x) => OrderItem.fromMap(x),
          ),
        ),
        modeOfPayment: json["modeOfPayment"],
        id: json["_id"],
        party: json["party"] is Map ? Party.fromMap(json["party"]) : null,
        user: json["user"] is Map ? User.fromMMap(json["user"]) : null,
        createdAt: json["createdAt"],
        total: json['total'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        "orderItems": orderItems?.map((e) => e.toMap()).toList(),
        "modeOfPayment": modeOfPayment,
        "party": party,
        "user": user,
        "_id": id,
        "createdAt": createdAt,
      };
}
