import 'package:shopos/src/models/product.dart';

class OrderItem {
  OrderItem({this.price = 0, this.quantity = 0, this.image, this.product});

  int price;
  int quantity;
  String? image;
  Product? product;

  factory OrderItem.fromMap(Map<String, dynamic> json) => OrderItem(
        price: json["price"] ?? 0,
        quantity: json["quantity"] ?? 1,
        image: json["image"],
        product:
            json["product"] is Map ? Product.fromMap(json["product"]) : null,
      );

  Map<String, dynamic> toMap() => {
        "price": price,
        "quantity": quantity,
        "image": image,
        "product": product,
      };
}
