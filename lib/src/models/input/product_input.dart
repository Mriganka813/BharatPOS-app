import 'package:image_picker/image_picker.dart';

class  ProductFormInput {
  ProductFormInput({
    this.name,
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
    this.sellerName,
    this.available = true,
    this.expiryDate,
    this.batchNumber,
    this.hsn,
    this.GSTincluded=true
  });

  String? name;
  String? id;
  String? purchasePrice;
  String? sellingPrice;
  String? gstRate;
  String? salesgst;
  String? salecgst;
  String? saleigst;
  String? hsn;
  String? purchasesgst;
  String? purchasecgst;
  String? purchaseigst;
  String? baseSellingPriceGst;
  String? basePurchasePriceGst;
  String? barCode;
  String? quantity;
  String? image;
  String? sellerName;
  bool? available;
  DateTime? expiryDate;
  String? batchNumber;
  bool ?GSTincluded=true;

  bool gst;
  XFile? imageFile;

  Map<String, dynamic> toMap() { 
        print('included =$GSTincluded');
    return 
    {
        "name": name,
        if (purchasePrice != "" && purchasePrice != 'null')
          'purchasePrice': purchasePrice,
        "sellingPrice": sellingPrice,
        if (barCode != "" && barCode != 'null') "barCode": barCode,
        "quantity": quantity,
        "hsn":hsn,
        "id": id,
        if (expiryDate != null) 'expiryDate': expiryDate,
        if (gst) "GSTRate": gstRate,
        if (gst) "saleSGST": salesgst,
        if (gst) "saleCGST": salecgst,
        if (gst) "saleIGST": saleigst,
        if (gst) "purchaseSGST": purchasesgst,
        if (gst) "purchaseCGST": purchasecgst,
        if (gst) "purchaseIGST": purchaseigst,
        if (gst) "condition": gst,
        if (gst) "baseSellingPrice": baseSellingPriceGst,
        if (gst) "basePurchasePrice": basePurchasePriceGst,
        "sellerName": sellerName,
        "available": available ?? true,
        if(gst) "GSTincluded":GSTincluded==null?true:GSTincluded, 
        if (batchNumber != null) "batchNumber": batchNumber,
      };
  }

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
      hsn: map['hsn'].toString(),
      purchasecgst: map['purchaseCGST'].toString(),
      purchaseigst: map['purchaseIGST'].toString(),
      purchasesgst: map['purchaseSGST'].toString(),
      baseSellingPriceGst: map['baseSellingPrice'].toString(),
      basePurchasePriceGst: map['basePurchasePrice'].toString(),
      sellerName: map['sellerName'].toString(),
      available: map['available'] ?? true,
      batchNumber: map['batchNumber'] != null ? map['batchNumber'] : null,
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse((map['expiryDate']).toString().substring(0, 10))
          : null,
          
          GSTincluded: map['GSTincluded']
          );
      
}
