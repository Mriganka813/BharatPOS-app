import 'package:image_picker/image_picker.dart';

class ProductFormInput {
  ProductFormInput(
      {this.name,
      this.sellingPrice,
      this.barCode,
      this.id,
      this.purchasePrice,
      this.quantity,
      this.image,
      this.gst = false,
      this.salecgst,
      this.saleigst,
      this.salesgst,
      this.purchasecgst,
      this.purchaseigst,
      this.purchasesgst,
      this.gstRate,
      this.baseSellingPriceGst,
      this.basePurchasePriceGst,
      this.imageFile,
      this.expirydate = ""});

  String? name;
  String? id;
  String? purchasePrice;
  String? sellingPrice;
  String? gstRate;
  String? salesgst;
  String? salecgst;
  String? saleigst;
  String? purchasesgst;
  String? purchasecgst;
  String? purchaseigst;
  String? baseSellingPriceGst;
  String? basePurchasePriceGst;
  String? barCode;
  String? quantity;
  String? image;
  String? expirydate;
  bool gst;
  XFile? imageFile;

  Map<String, dynamic> toMap() => {
        "name": name,
        if (purchasePrice != "" && purchasePrice != 'null')
          'purchasePrice': purchasePrice,
        "sellingPrice": sellingPrice,
        if (barCode != "" && barCode != 'null') "barCode": barCode,
        "quantity": quantity,
        "id": id,
        if (expirydate != "" && expirydate != 'null') "expiryDate": expirydate,
        if (gst) "GSTRate": gstRate,
        if (gst) "saleSGST": salesgst,
        if (gst) "saleCGST": salecgst,
        if (gst) "saleIGST": saleigst,
        if (gst) "purchaseSGST": purchasesgst,
        if (gst) "purchaseCGST": purchasecgst,
        if (gst) "purchaseIGST": purchaseigst,
        if (gst) "condition": gst,
        if (gst) "baseSellingPrice": baseSellingPriceGst,
        if (gst) "basePurchasePrice": basePurchasePriceGst
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
        salecgst: map['saleCGST'].toString(),
        saleigst: map['saleIGST'].toString(),
        salesgst: map['saleSGST'].toString(),
        purchasecgst: map['purchaseCGST'].toString(),
        purchaseigst: map['purchaseIGST'].toString(),
        purchasesgst: map['purchaseSGST'].toString(),
        baseSellingPriceGst: map['baseSellingPrice'].toString(),
        basePurchasePriceGst: map['basePurchasePrice'].toString(),
      );
}
