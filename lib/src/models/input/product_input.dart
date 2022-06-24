import 'package:image_picker/image_picker.dart';

class ProductFormInput {
  ProductFormInput({
    this.name,
    this.sellingPrice,
    this.barCode,
    this.id,
    this.purchasePrice,
    this.quantity,
    this.image,
    this.gst = false,
    this.cgst,
    this.igst,
    this.sgst,
    this.gstRate,
    this.netSellingPriceGst,
    this.imageFile,
  });

  String? name;
  String? id;
  String? purchasePrice;
  String? sellingPrice;
  String? gstRate;
  String? sgst;
  String? cgst;
  String? igst;
  String? netSellingPriceGst;
  String? barCode;
  String? quantity;
  String? image;
  bool gst;
  XFile? imageFile;

  Map<String, dynamic> toMap() => {
        "name": name,
        if (purchasePrice != "") 'purchasePrice': purchasePrice,
        "sellingPrice": sellingPrice,
        if (barCode != "") "barCode": barCode,
        "quantity": quantity,
        "id": id,
        if (gst) "GSTRate": gstRate,
        if (gst) "SGST": sgst,
        if (gst) "CGST": cgst,
        if (gst) "IGST": igst,
        if (gst) "condition": gst,
        if (gst) "netSellingPrice": netSellingPriceGst
      };
  factory ProductFormInput.fromMap(map) => ProductFormInput(
        name: map['name'],
        purchasePrice: map['purchasePrice'].toString(),
        sellingPrice: map['sellingPrice'].toString(),
        barCode: map['barCode'].toString(),
        quantity: map['quantity'].toString(),
        image: map['image'].toString(),
        id: map['_id'].toString(),
        gstRate: map['GSTRate'].toString(),
        cgst: map['CGST'].toString(),
        igst: map['IGST'].toString(),
        sgst: map['SGST'].toString(),
        netSellingPriceGst: map['netSellingPrice'].toString(),
      );
}
