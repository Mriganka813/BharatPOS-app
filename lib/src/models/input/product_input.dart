import 'dart:convert';

import 'package:image_picker/image_picker.dart';
class SubProduct{
  SubProduct({
    this.name,
    this.quantity,
    this.inventoryId
  });
  String? name;
  String? inventoryId;
  double? quantity;

  Map<String, dynamic> toMap(){
    return {
      "name": name,
      "inventoryId": inventoryId,
      "quantity": quantity
    };
  }
  factory SubProduct.fromMap(map){
    return SubProduct(
      name: map['name'],
      inventoryId: map['inventoryId'],
      quantity: map['quantity'].toDouble()
    );
  }
}
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
    this.mrp,
    this.GSTincluded=true,
    this.subProducts,
    this.unit
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
  String? mrp;
  String? quantity;
  String? image;
  String? sellerName;
  bool? available;
  DateTime? expiryDate;
  String? batchNumber;
  bool ?GSTincluded=true;
  List<SubProduct>? subProducts = [];
  bool gst;
  XFile? imageFile;
  String? unit;


  Map<String, dynamic> toMap() {
        // print('included =$GSTincluded');
        // print(mrp.runtimeType);
        // print(mrp);
        print("in to map");
        print(subProducts.runtimeType);
        print(subProducts);
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
        if (expiryDate != null) 'expiryDate': expiryDate?.toIso8601String(),
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
        "mrp": mrp=="null" || mrp==null? "": mrp,
        "subProducts": subProducts?.map((e)=> e.toMap()).toList(),
        // "subProducts":[{
        //  "product":"653a6406e881cfb206bee15f",
        //  "quantity":0.5
        // },
        // {
        //  "product":"653a6a2ce881cfb206bf06ca",
        //  "quantity":2
        // }
        // ],
        "unit" : unit
      };
  }

  factory ProductFormInput.fromMap(map) {
    print("line 107 in product_input");
    print(map['subProducts']);

    return ProductFormInput(
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
        mrp: map['mrp'].toString(),
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
        unit: map['unit'] ?? "",
        GSTincluded: map['GSTincluded'],
        subProducts: List<SubProduct>.from(
          map["subProducts"].map(
              (e)=> SubProduct.fromMap(e)
          )
        )
    );
  }
}
