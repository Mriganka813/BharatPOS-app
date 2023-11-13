import 'package:pin_code_fields/pin_code_fields.dart';

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
  });

  String? name;
  double? sellingPrice;
  String? barCode;
  int? quantity=0;
  String? user;
  String? image;
  String? id;
  DateTime? createdAt;
  int? v;
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
  num i=0;
  factory Product.fromMap(Map<String, dynamic> json){ 

    if(json['quantity'] is int)
    {
      print("${json["name"]} have int quantity");
    }
    else
    {
      print("${json["name"]} have double quantity(${json['quantity']})");
    }
    
    
    return Product(
      name: json["name"],
      sellingPrice:json["sellingPrice"]==null?0.0: double.parse(json["sellingPrice"].toString()) ,
      barCode: json["barCode"],
      quantity:  json['quantity'],
      purchasePrice:json['purchasePrice']==null?0.0: double.parse(json['purchasePrice'].toString()),
      user: json["user"],
      image: json['image'],
      id: json["_id"],
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
      sellerName: json['sellerName'].toString(),
      batchNumber: json['batchNumber'] ?? null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse((json['expiryDate']).toString().substring(0, 10))
          : null);
          
          
      }

  Map<String, dynamic> toMap() => {
        
        "name": name,
        "sellingPrice": sellingPrice,
        "barCode": barCode,
        "image": image,
        "quantity": quantity,
        "user": user,
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
      };
}
