class ProductFormInput {
  ProductFormInput({
    this.name,
    this.sellingPrice,
    this.barCode,
    this.id,
    this.purchasePrice,
    this.quantity,
  });

  String? name;
  String? id;
  String? purchasePrice;
  String? sellingPrice;
  String? barCode;
  String? quantity;

  Map<String, dynamic> toMap() => {
        "name": name,
        'purchasePrice': purchasePrice,
        "sellingPrice": sellingPrice,
        "barCode": barCode,
        "quantity": quantity,
        "id": id,
      };
  factory ProductFormInput.fromMap(map) => ProductFormInput(
        name: map['name'],
        purchasePrice: map['purchasePrice'].toString(),
        sellingPrice: map['sellingPrice'].toString(),
        barCode: map['barCode'].toString(),
        quantity: map['quantity'].toString(),
        id: map['_id'].toString(),
      );
}
