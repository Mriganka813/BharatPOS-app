import 'dart:math';

import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/pages/checkout.dart';

import '../party.dart';
import '../user.dart';

class Order {
  Order(
      {this.id = -1,
        this.kotId,
       this.objId,
      this.orderItems,
      this.total,
      this.modeOfPayment,
      this.party,
      this.user,
      this.createdAt,
      this.reciverName,
      this.businessName,
      this.businessAddress,
      this.gst,
      this.invoiceNum,
        this.estimateNum,
      this.tableNo = "-1"});

  String? kotId;
  int? id;
  String? objId;
  List<OrderItemInput>? orderItems;
  String? total;
  List<Map<String,dynamic>>? modeOfPayment;
  Party? party;
  User? user;
  DateTime? createdAt;
  String? reciverName;
  String? businessName;
  String? businessAddress;
  String? gst;
  String? invoiceNum;
  String? estimateNum;
  String tableNo;

  factory Order.fromMap(Map<String, dynamic> json) => Order(
        kotId: json["kotId"].toString(),
        objId: json["_id"].toString(),
        orderItems: List<OrderItemInput>.from(
          json["orderItems"].map(
            (x) => OrderItemInput.fromMap(x),
          ),
        ),
        modeOfPayment:  (json["modeOfPayment"] as List?)?.cast<Map<String, dynamic>>() ?? [],
        id: json['id'],
        party: json["party"] is Map ? Party.fromMap(json["party"]) : null,
        user: json["user"] is Map ? User.fromMMap(json["user"]) : null,
        invoiceNum: json["invoiceNum"],
        estimateNum: json["estimateNum"].toString(),
        createdAt: json["createdAt"] == null || json["createdAt"] == "null" ? DateTime.now() : DateTime.parse(json["createdAt"].toString()),
        total: json['total'].toString() ?? " ",
        businessName: json['businessName'] ?? "",
        businessAddress: json['businessAddress'] ?? "",
        reciverName: json['reciverName'] ?? "",
        gst: json['gst'] ?? "",
        tableNo: json['tableNo'].toString() ?? ""
      );

  factory Order.fromMapForParty(Map<String, dynamic> json) {

    // print("  ${json["_id"]} and ${json["party"]}  ");
    
    
    return Order(
        objId: json["_id"].toString(),
        orderItems: List<OrderItemInput>.from(
          json["orderItems"].map(
            (x) => OrderItemInput.fromMap(x),
          ),
        ),
        modeOfPayment: (json["modeOfPayment"] as List?)?.cast<Map<String, dynamic>>() ?? [],
        id: json["id"],
        party: Party(id: json['_id']),
        user: json["user"] is Map ? User.fromMMap(json["user"]) : null,
        createdAt: json["createdAt"] == null ? DateTime.now() : DateTime.parse(json["createdAt"].toString()),
        total: json['total'].toString() ?? " ",
      );}

  Map<String, dynamic> toMap(OrderType type) => {
        "kotId": kotId,
        "id": id,
        "orderItems": orderItems?.map((e) => type == OrderType.sale ? e.toSaleMap() : e.toPurchaseMap()).toList(),
        "modeOfPayment": modeOfPayment,
        "party": party?.id,
        "user": user?.id,
        "createdAt": createdAt.toString(),
        "reciverName": reciverName,
        "businessName": businessName,
        "businessAddress": businessAddress,
        "gst": gst,
        "tableNo": tableNo
      };
  Map<String, dynamic> toMapForCopy() => {//for making copy of Order
    "id": id,
    "kotId": kotId,
    "orderItems": orderItems?.map((e) => e.toMapCopy()).toList(),
    "modeOfPayment": modeOfPayment,
    "party": party?.id,
    // "user": user?.id,
    // "createdAt": createdAt ?? DateTime.now().toString(),
    "reciverName": reciverName,
    "businessName": businessName,
    "businessAddress": businessAddress,
    "gst": gst,
    "tableNo": tableNo
  };
}

class OrderItemInput {
  OrderItemInput({this.price = 0, this.quantity = 0, this.product, this.saleSGST, this.saleCGST, this.baseSellingPrice, this.saleIGST, this.discountAmt = "0", this.originalbaseSellingPrice = ""});

  double? price;
  double quantity;
  Product? product;
  // double mrp;
  String? saleSGST;
  String? saleCGST;
  String? baseSellingPrice;
  String? saleIGST;
  String discountAmt = "0";
  String originalbaseSellingPrice = "";

  factory OrderItemInput.fromMap(Map<String, dynamic> json) => OrderItemInput(
      price: double.parse(json['price'].toString()) ?? 0,
      quantity: json['quantity']!= null? json['quantity'].toDouble() : 0.0,
      // mrp: json['mrp']!= null && json['mrp']!="null"? double.parse(json['mrp']) : 0.0,
      product: json["product"] is Map ? Product.fromMap(json["product"]) : null,
      saleCGST: json["saleCGST"].toString(),
      saleSGST: json["saleSGST"].toString(),
      baseSellingPrice: json["baseSellingPrice"].toString(),
      saleIGST: json["saleIGST"].toString(),
      discountAmt: json['discountAmt'].toString(),
      originalbaseSellingPrice:
          json["originalbaseSellingPrice"] == null || json["originalbaseSellingPrice"] == "null" ? "0.0" : double.parse(json["originalbaseSellingPrice"].toString()).toStringAsFixed(2));

  factory OrderItemInput.fromMapForLocalDatabase(Map<String, dynamic> json){
    print("line 126 in order.dart");
    // print(json);
    print(json["product"] is Map);
    return OrderItemInput(
      price: double.parse(json['price'].toString()) ?? 0,
      quantity: json['quantity']!= null? json['quantity'].toDouble() : 0.0,
      // mrp: json['mrp']!= "null" && json['mrp']!=null ? json['mrp'] : 0.0,
      product: json["product"] is Map ? Product.fromMap(json["product"]) : null,
      saleCGST: json["saleCGST"].toString(),
      saleSGST: json["saleSGST"].toString(),
      baseSellingPrice: json["baseSellingPrice"].toString(),
      saleIGST: json["saleIGST"].toString(),
      discountAmt: json['discountAmt'].toString(),
    );
  }

  Map<String, dynamic> toMapCopy(){//for making copy of OrderItemInput
    Map<String,dynamic> map= {
      "price": (product?.sellingPrice ?? 1),
      "quantity": quantity,
      "product": product!.toMapForBilling(),
      "saleCGST": product?.salecgst == 'null' ? '0' : product!.salecgst,
      "saleSGST": product?.salesgst == 'null' ? '0' : product!.salesgst,
      "baseSellingPrice": product?.baseSellingPriceGst == 'null' ? '0' : product!.baseSellingPriceGst,
      "saleIGST": product?.saleigst == 'null' ? '0' : product!.saleigst,
      "discountAmt": discountAmt,
      "originalbaseSellingPrice": (double.parse(product!.baseSellingPriceGst! == "null" ? '0' : product!.baseSellingPriceGst!) + double.parse(discountAmt!)).toString()};

    return map;
  }
  Map<String, dynamic> toSaleMap() {
        print("line 138 in order.dart tosalemap ");
        print(product);
    Map<String,dynamic> map= {
      "price": (product?.sellingPrice ?? 1),
      "quantity": quantity,
      "product": product?.id,
      "saleCGST": product?.salecgst == 'null' ? '0' : product!.salecgst,
      "saleSGST": product?.salesgst == 'null' ? '0' : product!.salesgst,
      "baseSellingPrice": product?.baseSellingPriceGst == 'null' ? '0' : product!.baseSellingPriceGst,
      "saleIGST": product?.saleigst == 'null' ? '0' : product!.saleigst,
      "discountAmt": discountAmt,
      "originalbaseSellingPrice": (double.parse(product!.baseSellingPriceGst! == "null" ? '0' : product!.baseSellingPriceGst!) + double.parse(discountAmt!)).toString()};
      return map;
  }

  Map<String, dynamic> toSaleReturnMap() => {
        "price": (product?.sellingPrice ?? 1),
        "quantity": quantity,
        "product": product?.id,
        "_id": "657442744ee866a10928da95",
      };
  Map<String, dynamic> toPurchaseMap() => {
        "price": (product?.purchasePrice ?? 1),
        "discount": 0,
        "quantity": quantity,
        "product": product?.id,
      };
}
