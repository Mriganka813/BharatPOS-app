import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:shopos/src/models/KotModel.dart';
import 'package:shopos/src/models/input/order_input.dart';
import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/models/user.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/provider/billing_order.dart';
import 'package:shopos/src/services/user.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'database.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE  Product(
         
            
          
            
            name TEXT,
            sellingPrice  REAL,
            barCode TEXT,
            quantity INTEGER,
            user TEXT,
            image TEXT,
            _id  TEXT,
            createdAt TEXT,
            __v INTEGER,
            purchasePrice INTEGER,
            GSTRate TEXT,
            saleSGST TEXT,
            saleCGST TEXT,
            saleIGST TEXT,
            baseSellingPrice TEXT,
            purchaseSGST TEXT,
            purchaseCGST TEXT,
            purchaseIGST TEXT,
            basePurchasePrice TEXT,
            sellerName TEXT,
            batchNumber TEXT,
            expiryDate TEXT,
            hsn TEXT
          )
        ''');


          db.execute('''
          CREATE TABLE  SubProduct(
         
            
          
            subId Text,
            name TEXT,
            sellingPrice  REAL,
            barCode TEXT,
            quantity INTEGER,
            user TEXT,
            image TEXT,
            _id  TEXT,
            createdAt TEXT,
            __v INTEGER,
            purchasePrice INTEGER,
            GSTRate TEXT,
            saleSGST TEXT,
            saleCGST TEXT,
            saleIGST TEXT,
            baseSellingPrice TEXT,
            purchaseSGST TEXT,
            purchaseCGST TEXT,
            purchaseIGST TEXT,
            basePurchasePrice TEXT,
            sellerName TEXT,
            batchNumber TEXT,
            expiryDate TEXT,
            hsn TEXT
          )
        ''');

        db.execute('''
          CREATE TABLE OrderItemInput(
            id INTEGER PRIMARY KEY,
            OIID Integer,
            price INTEGER ,
            quantity INTEGER,
            product TEXT,
            saleSGST TEXT,
            saleCGST TEXT,
            baseSellingPrice TEXT,
            saleIGST TEXT,
            discountAmt Text
          
           
          )
        ''');

        db.execute('''
          CREATE TABLE OrderInput(
            id INTEGER PRIMARY KEY,
            userId Text,
             
             modeOfPayment Text,
             party Text,
             user Text,
             createdAt Text,
             reciverName Text,
             businessName Text,
             businessAddress Text,
             gst Text,
             tableNo Text
          )
        ''');

        db.execute('''
          CREATE TABLE Kot(
            orderId INTEGER,
            name Text,
            qty INTEGER,
            isPrinted Text
          )
        ''');
      },
    );
  }

  Future<int> InsertOrderInput(OrderInput input, Billing provider,
      List<OrderItemInput> newAddeditems) async {
    final response = await UserService.me();
    final user = User.fromMap(response.data['user']);

    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    var map = input.toMap(OrderType.sale);

    //As we cant edit the data fetched from database because it is immutable we made a tempMap
    Map<String, dynamic> tempMap = {};
    tempMap.addAll(map);
    tempMap.remove(
        "orderItems"); //removed this because we are not inserting all items to this table instead we store the id as OIID in OrderItemInput table of each OrderItem
    tempMap['party'] =
        " "; //  given Empty String because we do not want to store it actually and its a Party type cant store it so replaced with  " "
    tempMap['user'] = " "; //   same reason as above

    //First time all OrderInput will have id -1 when we enter that into table only it changes
    if (input.id == -1) {
      tempMap.remove(
          "id"); // It is removed becasue, when inserting the item it should autoincrement the id, but we give id in the map, it will ovverrite and id  will be -1
    }
    tempMap["userId"] = user.id;

    //to change the actual null to string null to remove problems related to null
    tempMap.forEach((key, value) {
      if (value == -1) {
        tempMap[key] = "null";
      }
    });

    //Insert if the OrderInput is new and else update
    if (input.id == -1) {
      await db.insert(
        'OrderInput',
        tempMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      db.update('OrderInput', tempMap, where: 'id = ?', whereArgs: [input.id]);
    }

    final result = await db.rawQuery('SELECT MAX(id) as maxId FROM OrderInput');
    int highestId;

    //get Highest id that meanse id of the last entered item to store that in OrderitemInput as OIID
    if (input.id == -1) {
      highestId =
          result.first['maxId'] == null ? 0 : result.first['maxId'] as int;
      input.id = highestId;
      provider.addSalesBill(
        input,
        input.id.toString(),
      );
    } else {
      //if we udpating alreay existing item
      highestId = input.id!;
    }

    insertOrderItemsInput(input.orderItems!, newAddeditems, highestId);
    return highestId;
  }

  void insertOrderItemsInput(List<OrderItemInput> data,
      List<OrderItemInput> newOrderItemsData, int id) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    var curr = data;

    data = newOrderItemsData.isEmpty ? data : newOrderItemsData;

    for (int i = 0; i < data.length; i++) {
      var map = data[i].toSaleMap();
      map['product'] = data[i].product!.id;
      map['OIID'] = id;

      map.remove("originalbaseSellingPrice");

      //case when we dont add new product but incresed the quatitiy so we just update
      //so when OrderItemsData is empty that means we increased or decresed the quatity oru such updates
      //of current OrderInput

      // so when  there is items in newOrderItemsData that means new OrderInput are there to input
      if (!newOrderItemsData.isEmpty) {
        await db.insert(
          'OrderItemInput',
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await db.update(
        'OrderItemInput',
        map,
        where: 'product = ? AND OIID = ?',
        whereArgs: [map['product'], map['OIID']],
      );

      await insertProductItems(data[i].product!);
    }

    // this for loop is implemented to work in a situation like when we  both increase the qty and added new product to OrderInput
    //so in above code we only insert the new items as newOrderItemInput have some contents( because variable data becomes newOrderIteminput)

    // so in order to update all entire data of the OrderInput we do this
    for (int i = 0; i < curr.length; i++) {
      var map = curr[i].toSaleMap();
      map['product'] = curr[i].product!.id;
      map['OIID'] = id;
      map.remove("originalbaseSellingPrice");

      await db.update(
        'OrderItemInput',
        map,
        where: 'product = ? AND OIID = ?',
        whereArgs: [map['product'], map['OIID']],
      );
    }
  }

  insertProductItems(Product data) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    var map = data.toMap();
    map['createdAt'] = map["createdAt"].toString();
    map['expiryDate'] = map["expiryDate"].toString();

    await db.insert(
      'Product',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<OrderInput>> getOrderItems() async {
       final response = await UserService.me();
    final user = User.fromMap(response.data['user']);
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> OrderItemInputData =
        await db.query('OrderItemInput');
    final List<Map<String, dynamic>> OrderInputData =
        await db.query('OrderInput',  where: 'userId=?', whereArgs: [user.id]);

    List<OrderInput> list = [];

    for (int j = 0; j < OrderInputData.length; j++) {
      Map<String, dynamic> t = {};

      t.addAll(OrderInputData[j]);
      print("data=");
      print(t);

      List<OrderItemInput> plist = [];

      for (int i = 0; i < OrderItemInputData.length; i++) {
        print(OrderItemInputData[i]['OIID'].toString() +
            "&" +
            OrderInputData[j]['id'].toString());
        if (OrderItemInputData[i]['OIID'] == OrderInputData[j]['id']) {
          plist.addAll(await convertListOfMaptoListofOrderItemInput(
              OrderItemInputData[i]));
        }
      }

      t['orderItems'] = [];
      t['party'] = Party();
      t['user'] = User();
      t['createdAt'] = DateTime.now();

      OrderInput orderInputObject = OrderInput.fromMap(t);
      orderInputObject.orderItems = plist;

      list.add(orderInputObject);
    }

    return list;
  }

  Future<List<OrderItemInput>> convertListOfMaptoListofOrderItemInput(
      Map<String, dynamic> OrderItemInputData) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    List<OrderItemInput> list = [];

    Map<String, dynamic> Otemp = {};
    Otemp.addAll(OrderItemInputData);

    final List<Map<String, dynamic>> Productdata = await db.query('Product');
    print("product data: $Productdata ");

    Productdata.forEach((ele) {
      Map<String, dynamic> t = {};
      t.addAll(ele);
      if (ele["expiryDate"] == "null") {
        t["expiryDate"] = null;
      }
      if (ele['_id'] == Otemp['product']) {
        Otemp['product'] = Product.fromMap(t);
      }
    });

    Otemp.remove("OIID");

    list.add(OrderItemInput.fromMap(Otemp));

    return list;
  }

  deleteOrderItemInput(OrderInput input) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.delete("OrderInput", where: "id = ?", whereArgs: [input.id]);
    await db.delete("OrderItemInput", where: "OIID = ?", whereArgs: [input.id]);
  }

  insertKot(List<KotModel> list) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    for (int i = 0; i < list.length; i++) {
      List<Map<String, dynamic>> result = await db.query(
        'Kot',
        columns: ['qty'],
        where: 'orderId =? AND isPrinted=? AND name=?',
        whereArgs: [list[i].orderId, "no", list[i].name],
      );
      print(list[i].name);

      print("result");
      print(result);

      if (result.isNotEmpty) {
        int qty = result.first['qty'];
        db.execute(
            "update Kot set qty=${qty + list[i].qty} where orderId=${list[i].orderId} and isPrinted='no' and name='${list[i].name}'");
        print("check qty");
        print(list);
      } else {
        var map = list[i].toMap();
        await db.insert(
          'Kot',
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        print("exception");
      }
    }
  }

  updateKot(int id) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    db.execute("update Kot set isPrinted='yes' where orderId=$id");
  }

  Future<List<Map<String, dynamic>>> getKotData(int id) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> data = await db.query("Kot",
        where: 'isPrinted=? AND orderId=?', whereArgs: ["no", id]);

    print(data);

    return data;
  }

  deleteKot(
    int id,
    String itemName,
  ) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    print("${id} and $itemName");

    List<Map<String, dynamic>> result = await db.query(
      'Kot',
      columns: ['qty'],
      where: 'orderId =? AND isPrinted=? AND name=?',
      whereArgs: [id, "no", itemName],
    );

    int qty = result.first['qty'] as int;

    if (qty > 1) {
      qty = qty - 1;
      db.execute(
          "update Kot set qty=$qty where orderId=$id and isPrinted='no' and name='$itemName'");
    } else {
      db.execute(
          "delete from Kot  where orderId=$id and isPrinted='no' and name='$itemName'");
    }
  }

  updateTableNo(String tablNo, int id) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    db.execute("update OrderInput set tableNo='$tablNo' where id=$id");
  }

  deleteTHEDatabase() async {
    String path = join(await getDatabasesPath(), 'database.db');
    await deleteDatabase(path);
    print('Database cleared.');
  }

  /*Future<bool>  checkIfNewColumnsAreAdded() async {
    final Database db = await database;

    // Run a query to get the table information
    List<Map<String, dynamic>> orderItemInputcolumns =
        await db.rawQuery('PRAGMA table_info(OrderItemInput)');
        

        if(orderItemInputcolumns.length<10)
        {
          print("lessssssssssssssssssssss");
            return true;
            
        }
    List<Map<String, dynamic>> productcolumns =
        await db.rawQuery('PRAGMA table_info(Product)');

        if(productcolumns.length<23)
        {
          return true;
        }
    List<Map<String, dynamic>> orderInputcolumns =
        await db.rawQuery('PRAGMA table_info(OrderInput)');
        if(orderInputcolumns.length<20)
        {
            return true;
        }
    List<Map<String, dynamic>> kotcolumns =
        await db.rawQuery('PRAGMA table_info(Kot)');
        if(kotcolumns.length<4)
        {
            return true;
        }

        return false;

    // Return the number of columns
 
  }*/
}
