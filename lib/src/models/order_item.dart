import 'package:magicstep/src/models/product.dart';

class OrderItem {
  OrderItem({
    this.price,
    this.quantity,
    this.image,
    this.product,
  });

  String? price;
  int? quantity;
  String? image;
  Product? product;

  factory OrderItem.fromMap(Map<String, dynamic> json) => OrderItem(
        price: json["price"],
        quantity: json["quantity"],
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
