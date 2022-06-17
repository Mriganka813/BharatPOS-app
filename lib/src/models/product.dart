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
      };
}
