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
  });

  String? name;
  int sellingPrice;
  String? barCode;
  int? quantity;
  String? user;
  String? image;
  String? id;
  DateTime? createdAt;
  int? v;
  int purchasePrice;
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

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        name: json["name"],
        sellingPrice: json["sellingPrice"] ?? 0,
        barCode: json["barCode"],
        quantity: json["quantity"],
        purchasePrice: json['purchasePrice'] ?? 0,
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
      );

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
      };
}
