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
    this.cgst,
    this.igst,
    this.sgst,
    this.gstRate,
    this.baseSellingPriceGst,
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
  String? sgst;
  String? cgst;
  String? igst;
  String? baseSellingPriceGst;

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
        cgst: json['CGST'].toString(),
        igst: json['IGST'].toString(),
        sgst: json['SGST'].toString(),
        baseSellingPriceGst: json['netSellingPrice'].toString(),
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
        "SGST": sgst,
        "CGST": cgst,
        "IGST": igst,
        "netSellingPrice": baseSellingPriceGst
      };
}
