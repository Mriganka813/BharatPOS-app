import 'dart:convert';

import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shopos/src/models/input/product_input.dart';

class Product {
  Product({
    this.name,
    required this.sellingPrice,
    this.barCode,
    this.quantity,
    required this.purchasePrice,
    this.user,
    this.id,
    this.image,
    this.createdAt,
    this.v,
    this.salecgst,
    this.saleigst,
    this.hsn,
    this.salesgst,
    this.purchasecgst,
    this.purchaseigst,
    this.purchasesgst,
    this.gstRate,
    this.baseSellingPriceGst,
    this.basePurchasePriceGst,
    this.sellerName,
    this.batchNumber,
    this.expiryDate,
    this.mrp,
    this.quantityToBeSold,
  });

  String? name;
  double? sellingPrice;
  String? barCode;
  double? quantity=0;
  String? user;
  String? image;
  String? id;
  DateTime? createdAt;
  int? v;
  String? hsn;
  double? mrp;
  double purchasePrice;
  String? gstRate;
  String? salesgst;
  String? salecgst;
  String? saleigst;
  String? baseSellingPriceGst;
  String? purchasesgst;
  String? purchasecgst;
  String? purchaseigst;
  String? basePurchasePriceGst;
  String? sellerName;
  String? batchNumber;
  DateTime? expiryDate;
  double? quantityToBeSold;
  num i=0;
  
  factory Product.fromMap(Map<String, dynamic> json){ 
    

    if(json['quantity'] is int)
    {
      // print("${json["name"]} have int quantity");
    }
    else
    {
      // print("${json["name"]} have double quantity(${json['quantity']})");
    }
    // print('hsn =${json['hsn']}');
    // print("line 70 in product.dart");
    // print(json);
    // print(json['mrp'].toString());
    return Product(
      name: json["name"],
      sellingPrice:json["sellingPrice"]==null?0.0: double.parse(json["sellingPrice"].toString()) ,
      barCode: json["barCode"],
      // quantity:  json['quantity']??0,
      quantity:  json['quantity']!= null? json['quantity'].toDouble() : 0.0,
      purchasePrice:json['purchasePrice']==null?0.0: double.parse(json['purchasePrice'].toString()),
      user: json["user"],
      image: json['image'],
      id: json["_id"],
      hsn: json["hsn"],
      mrp: json["mrp"] == null ? null : json["mrp"].toDouble(),
      createdAt: DateTime.parse(json["createdAt"]),
      v: json["__v"],
      gstRate: json['GSTRate'].toString(),
      salecgst: json['saleCGST'].toString(),
      saleigst: json['saleIGST'].toString(),
      salesgst: json['saleSGST'].toString(),
      baseSellingPriceGst: json['baseSellingPrice'].toString(),
      purchasecgst: json['purchaseCGST'].toString(),
      purchaseigst: json['purchaseIGST'].toString(),
      purchasesgst: json['purchaseSGST'].toString(),
      basePurchasePriceGst: json['basePurchasePrice'].toString(),
      // subProducts: List<SubProduct>.from(
      //     jsonDecode(json["subProducts"]).map(
      //             (e)=> SubProduct.fromMap(e)
      //     )
      // ),
      sellerName: json['sellerName'].toString(),
      batchNumber: json['batchNumber'] ?? null,
      quantityToBeSold: json['quantityToBeSold'] is int ? json['quantityToBeSold'].toDouble() : json['quantityToBeSold'] ,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse((json['expiryDate']).toString().substring(0, 10))
          : null);
          
          
      }

  Map<String, dynamic> toMap() { 
        print('hsn =$hsn');
        print('line 107 mrp is $mrp');
        print("created at in line 118 is ${createdAt?.toIso8601String()}");
    return
    {
        
        "name": name,
        "sellingPrice": sellingPrice,
        "barCode": barCode,
        "image": image,
        "quantity": quantity,
        "user": user,
        "hsn":hsn,
        "mrp":mrp,
        "_id": id,
        'purchasePrice': purchasePrice,
        "createdAt": createdAt?.toIso8601String(),
        "__v": v,
        "GSTRate": gstRate,
        "saleSGST": salesgst,
        "saleCGST": salecgst,
        "saleIGST": saleigst,
        "baseSellingPrice": baseSellingPriceGst,
        "purchaseSGST": purchasesgst,
        "purchaseCGST": purchasecgst,
        "purchaseIGST": purchaseigst,
        "basePurchasePrice": basePurchasePriceGst,
        "sellerName": sellerName,
        "batchNumber": batchNumber,
        "expiryDate": expiryDate,
        "quantityToBeSold": quantityToBeSold
        // "subProducts": subProducts?.map((e) => e.toMap()).toList(),
      };

  }
  // Map<String, dynamic> toMapForBilling() {
  //       print('hsn =$hsn');
  //       print('line 107 mrp is $mrp');
  //       print("created at in line 154 is ${baseSellingPriceGst} and ${baseSellingPriceGst.runtimeType}");
  //   return
  //   {
  //
  //     "name": name,
  //     "sellingPrice": sellingPrice,
  //     "barCode": barCode,
  //     "image": image,
  //     "quantity": quantity,
  //     "user": user,
  //     "hsn":hsn,
  //     if(mrp != null) "mrp":mrp,
  //     "_id": id,
  //     'purchasePrice': purchasePrice,
  //     "createdAt": createdAt?.toString(),
  //     "__v": v,
  //     "GSTRate": (gstRate == null || gstRate == "null") ? "0" : gstRate,
  //     "saleSGST": (salesgst == null || salesgst == "null") ? "0" : salesgst,
  //     "saleCGST":(salecgst == null || salecgst == "null") ? "0" : salecgst,
  //     "saleIGST": (saleigst == null || saleigst == "null") ? "0" : saleigst,
  //     "baseSellingPrice": (baseSellingPriceGst == null || baseSellingPriceGst == "null") ? "0" : baseSellingPriceGst,
  //     "purchaseSGST": (purchasesgst == null || purchasesgst == "null") ? "0" : purchasesgst,
  //     "purchaseCGST":(purchasecgst == null || purchasecgst == "null") ? "0" : purchasecgst,
  //     "purchaseIGST":(purchaseigst == null || purchaseigst == "null") ? "0" : purchaseigst,
  //     "basePurchasePrice": (baseSellingPriceGst == null || baseSellingPriceGst == "null") ? "0" : basePurchasePriceGst,
  //     "sellerName": sellerName,
  //     "batchNumber": batchNumber,
  //     "quantityToBeSold": quantityToBeSold
  //       // "subProducts": subProducts?.map((e) => e.toMap()).toList(),
  //     };
  //
  // }
  Map<String, dynamic> toMapForBilling() {
        print('hsn =$hsn');
        print('line 107 mrp is $mrp');
        print("created at in line 154 is ${baseSellingPriceGst} and ${baseSellingPriceGst.runtimeType}");
    return
    {

      "name": name,
      "sellingPrice": sellingPrice,
      "barCode": barCode,
      "image": image,
      "quantity": quantity,
      "user": user,
      "hsn":hsn,
      if(mrp != null && mrp!="null") "mrp":mrp,
      "_id": id,
      'purchasePrice': purchasePrice,
      "createdAt": createdAt?.toString(),
      "__v": v,
      if(gstRate != null && gstRate != "null") "GSTRate": gstRate,
      if(salesgst != null && salesgst != "null") "saleSGST": salesgst,
      if(salecgst != null && salecgst != "null") "saleCGST": salecgst,
      if(saleigst != null && saleigst != "null") "saleIGST": saleigst,
      if(baseSellingPriceGst != null && baseSellingPriceGst != "null") "baseSellingPrice": baseSellingPriceGst,
      if (purchasesgst != null && purchasesgst != "null") "purchaseSGST": purchasesgst,
      if (purchasecgst != null && purchasecgst != "null") "purchaseCGST": purchasecgst,
      if (purchaseigst != null && purchaseigst != "null") "purchaseIGST": purchaseigst,
      if (basePurchasePriceGst != null && basePurchasePriceGst != "null") "basePurchasePrice": basePurchasePriceGst,
      "sellerName": sellerName,
      "batchNumber": batchNumber,
      "quantityToBeSold": quantityToBeSold
        // "subProducts": subProducts?.map((e) => e.toMap()).toList(),
      };

  }
  // String toJson(){
  //   return jsonEncode(subProducts);
  // }
  // static List<SubProduct> fromJson(String json) {
  //   List<dynamic> decoded = jsonDecode(json);
  //   return decoded.map((map) => SubProduct.fromMap(map)).toList();
  // }
}
