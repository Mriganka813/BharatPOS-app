import 'package:shopos/src/models/consumer_adrress.dart';

class OnlineOrder {
  ConsumerAddress? addresses;
  String? orderId;
  List<Items>? items;
  String? consumer;
  String? createdAt;
  int? iV;

  OnlineOrder(
      {this.addresses,
      this.orderId,
      this.items,
      this.consumer,
      this.createdAt,
      this.iV});

  OnlineOrder.fromJson(Map<String, dynamic> json) {
    addresses = json['addresses'] != null
        ? new ConsumerAddress.fromJson(json['addresses'])
        : null;
    orderId = json['_id'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    consumer = json['consumer'];
    createdAt = json['createdAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.addresses != null) {
      data['addresses'] = this.addresses!.toJson();
    }
    data['_id'] = this.orderId;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    data['consumer'] = this.consumer;
    data['createdAt'] = this.createdAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Items {
  String? productId;
  String? productName;
  int? productPrice;
  String? productImage;
  int? quantity;
  String? status;
  String? sellerId;
  String? sellerName;
  String? sId;

  Items(
      {this.productId,
      this.productName,
      this.productPrice,
      this.productImage,
      this.quantity,
      this.status,
      this.sellerId,
      this.sellerName,
      this.sId});

  Items.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    productName = json['productName'];
    productPrice = json['productPrice'];
    productImage = json['productImage'];
    quantity = json['quantity'];
    status = json['status'];
    sellerId = json['sellerId'];
    sellerName = json['sellerName'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productId'] = this.productId;
    data['productName'] = this.productName;
    data['productPrice'] = this.productPrice;
    data['productImage'] = this.productImage;
    data['quantity'] = this.quantity;
    data['status'] = this.status;
    data['sellerId'] = this.sellerId;
    data['sellerName'] = this.sellerName;
    data['_id'] = this.sId;
    return data;
  }
}
