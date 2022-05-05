class ProductFormInput {
  ProductFormInput({
    this.name,
    this.sellingPrice,
    this.barCode,
    this.quantity,
  });

  String? name;
  int? sellingPrice;
  String? barCode;
  int? quantity;

  Map<String, dynamic> toMap() => {
        "name": name,
        "sellingPrice": sellingPrice,
        "barCode": barCode,
        "quantity": quantity,
      };
}
