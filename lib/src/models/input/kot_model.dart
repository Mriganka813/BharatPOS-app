class Kot
{
  String? id;
  String? kotId;
  List<Item>? items;
  DateTime? dateTime;

  Kot({this.id, this.kotId,this.dateTime, this.items});

  Map<String,dynamic> toMap(){
    return {
      'id': id,
      'kotId': kotId,
      'dateTime': dateTime.toString(),
      'item': items?.map((item) => item.toMap()).toList()
    };
  }
  factory Kot.fromMap(Map<String, dynamic> json) => Kot(
      id: json['_id'],
      kotId: json['kotId'],
      items: List<Item>.from(
        json['item'].map(
            (e) => Item.fromMap(e)
        )
      ),
      dateTime: json['dateTime']
  );


}

class Item{
  Item({
    this.name,
    this.quantity,
    this.salesgst,
    this.salecgst,
    this.saleigst,
    this.baseSellingPrice,
    this.discountAmt,
    this.createdAt
});
  String? name;
  double? quantity;
  String? salesgst;
  String? salecgst;
  String? saleigst;
  String? baseSellingPrice;
  String? discountAmt;
  DateTime? createdAt;

  Map<String, dynamic> toMap(){
    return{
      'name' : name.toString(),
      'quantity': quantity,
      // 'salesgst': saleigst == 'null' ? '0' : saleigst,
      // 'salecgst': salecgst == 'null' ? '0' : salecgst,
      // 'saleigst': saleigst == 'null' ? '0' : saleigst,
      // 'baseSellingPrice': baseSellingPrice,
      // 'discountAmt': discountAmt,
      'createdAt': createdAt.toString()
    };
  }
  factory Item.fromMap(Map<String, dynamic> json) => Item(
    name: json['name'].toString(),
    quantity: json['quantity'].toDouble(),
    // salesgst: json['salesgst'] == null || json['salesgst'] == 'null' ? '0' : json['salesgst'],
    // salecgst: json['salecgst'] == null || json['salecgst'] == 'null' ? '0' : json['salecgst'],
    // saleigst: json['saleigst'] == null || json['saleigst'] == 'null' ? '0' : json['saleigst'],
    // baseSellingPrice: json['baseSellingPrice'].toString(),
    // discountAmt: json['discountAmt'].toString(),
    createdAt: DateTime.parse(json['createdAt'])

  );


}