import 'package:shopos/src/models/product.dart';

class OrderItem {
  OrderItem({
    this.price = 0,
    this.quantity = 0,
    this.image,
    this.product,
    this.saleSGST,
    this.saleCGST,
    this.baseSellingPrice,
    this.saleIGST,
  });

  int price;
  int quantity;
  String? image;
  Product? product;
  String? saleSGST;
  String? saleCGST;
  String? baseSellingPrice;
  String? saleIGST;

  factory OrderItem.fromMap(Map<String, dynamic> json) => OrderItem(
        price: json["price"] ?? 0,
        quantity: json["quantity"] ?? 1,
        image: json["image"],
        product:
            json["product"] is Map ? Product.fromMap(json["product"]) : null,
        saleCGST: json["saleCGST"].toString(),
        saleSGST: json["saleSGST"].toString(),
        baseSellingPrice: json["baseSellingPrice"].toString(),
        saleIGST: json["saleIGST"].toString(),
      );

  Map<String, dynamic> toMap() => {
        "price": price,
        "quantity": quantity,
        "image": image,
        "product": product,
      };
}
