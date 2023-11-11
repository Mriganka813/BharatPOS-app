import 'dart:ffi';

import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/pages/checkout.dart';

import '../party.dart';
import '../user.dart';

class OrderInput {
  OrderInput({
    this.id=-1,
    this.orderItems,
    this.modeOfPayment,

    this.party,
    this.user,
    this.createdAt,
    this.reciverName,
    this.businessName,
    this.businessAddress,
    this.gst,
    this.tableNo="-1"
  });

  int ?id;
  List<OrderItemInput>? orderItems;
  String? modeOfPayment;
  Party? party;
  User? user;
  DateTime? createdAt;
  String? reciverName;
  String? businessName;
  String? businessAddress;
  String? gst;
  String tableNo;

  factory OrderInput.fromMap(Map<String, dynamic> json) => OrderInput(
        id:json["id"],
        orderItems: List<OrderItemInput>.from(
          json["orderItems"].map(
            (x) => OrderItemInput.fromMap(x),
          ),
        ),
        modeOfPayment: json["modeOfPayment"],
        party: json["party"],
        user: json["user"],
        createdAt: json["createdAt"],
        reciverName: json['reciverName'],
        businessName: json['businessName'],
        businessAddress: json['businessAddress'],
        gst: json['gst'],
        tableNo: json['tableNo']
      );

  Map<String, dynamic> toMap(OrderType type) => {
        "id":id,
        "orderItems": orderItems
            ?.map((e) =>
                type == OrderType.sale ? e.toSaleMap() : e.toPurchaseMap())
            .toList(),
        "modeOfPayment": modeOfPayment,
        "party": party?.id,
        "user": user?.id,
        "createdAt": createdAt.toString(),
        "reciverName": reciverName,
        "businessName": businessName,
        "businessAddress": businessAddress,
        "gst": gst,
        "tableNo":tableNo
      };
}

class OrderItemInput {
  OrderItemInput({
    this.price = 0,
    this.quantity = 0,
    this.product,
    this.saleSGST,
    this.saleCGST,
    this.baseSellingPrice,
    this.saleIGST,
  });

 double? price;
  int quantity;
  Product? product;
  String? saleSGST;
  String? saleCGST;
  String? baseSellingPrice;
  String? saleIGST;

  factory OrderItemInput.fromMap(Map<String, dynamic> json) => OrderItemInput(
        price: double.parse(json["price"].toString()) ,
        quantity: json["quantity"],
        product: json["product"],
        saleCGST: json["saleCGST"].toString(),
        saleSGST: json["saleSGST"].toString(),
        baseSellingPrice: json["baseSellingPrice"].toString(),
        saleIGST: json["saleIGST"].toString(),
      );

  Map<String, dynamic> toSaleMap() => {
        "price": (product?.sellingPrice ?? 1),
        "quantity": quantity,
        "product": product?.id,
        "saleCGST": product?.salecgst == 'null' ? '0' : product!.salecgst,
        "saleSGST": product?.salesgst == 'null' ? '0' : product!.salesgst,
        "baseSellingPrice": product?.baseSellingPriceGst == 'null'
            ? '0'
            : product!.baseSellingPriceGst,
        "saleIGST": product?.saleigst == 'null' ? '0' : product!.saleigst,
      };
  Map<String, dynamic> toPurchaseMap() => {
        "price": (product?.purchasePrice ?? 1),
        "quantity": quantity,
        "product": product?.id,
      };
}
