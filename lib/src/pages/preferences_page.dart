import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_drop_down.dart';

class DefaultPreferences extends StatefulWidget {
  static const routeName = 'default-preferences';

  const DefaultPreferences();

  @override
  State<DefaultPreferences> createState() => _DefaultPreferencesState();
}

enum DiscountType { percent, amount }

class _DefaultPreferencesState extends State<DefaultPreferences> {
  bool showNamePref = false;
  bool shareButtonSwitch = false;
  bool barcodeButtonSwitch = false;
  bool skipPendingOrderSwitch = false;
  bool autoRefreshPendingOrdersSwitch = false;
  bool showReadySwitch = false;
  bool showInStockSwitch = false;
  bool buzzerSoundPref = false;
  bool isPercentageDiscount = false;
  String? _type;
  // bool multiplePaymentModeSwitch = false;
  String? defaultBillSize;
  String? defaultPurchaseGst;
  String? defaultSaleGst;
  String? defaultKotBillSize;
  late SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    init();

  }



  void init() async {
    prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('share-button-preference')){
      shareButtonSwitch = (await prefs.getBool('share-button-preference'))!;
    }else{//by default it will be false
      await prefs.setBool('share-button-preference', false);
      shareButtonSwitch = false;
    }
    if(prefs.containsKey('buzzer-qr-order-preference')){
      buzzerSoundPref = (await prefs.getBool('buzzer-qr-order-preference'))!;
    }else{//by default it will be false
      await prefs.setBool('buzzer-qr-order-preference', false);
      buzzerSoundPref = false;
    }

    if(prefs.containsKey('show-name-preference')){
      showNamePref = (await prefs.getBool('show-name-preference'))!;
    }else{//by default it will be false
      await prefs.setBool('show-name-preference', false);
      showNamePref = false;
    }

    if(prefs.containsKey('in-stock-button-preference')){
      showInStockSwitch = (await prefs.getBool('in-stock-button-preference'))!;
    }else{//by default it will be false
      await prefs.setBool('in-stock-button-preference', false);
      showInStockSwitch = false;
    }

    if(prefs.containsKey('barcode-button-preference')){
      barcodeButtonSwitch = (await prefs.getBool('barcode-button-preference'))!;
    }else{//by default it will be true
      await prefs.setBool('barcode-button-preference', true);
      barcodeButtonSwitch = true;
    }

    if(prefs.containsKey('pending-orders-preference')){
      skipPendingOrderSwitch = (await prefs.getBool('pending-orders-preference'))!;
    }else{//by default it will be false
      await prefs.setBool('pending-orders-preference', false);
      skipPendingOrderSwitch = false;
    }
    if(prefs.containsKey('refresh-pending-orders-preference')){
      autoRefreshPendingOrdersSwitch = (await prefs.getBool('refresh-pending-orders-preference'))!;
    }else{//by default it will be false
      await prefs.setBool('refresh-pending-orders-preference', false);
      autoRefreshPendingOrdersSwitch = false;
    }

    if(prefs.containsKey('ready-orders-preference')){
      showReadySwitch = (await prefs.getBool('ready-orders-preference'))!;
    }else{//by default it will be false
      await prefs.setBool('ready-orders-preference', false);
      showReadySwitch = false;
    }

    // if(prefs.containsKey('discount-type-preference')){
    //   isPercentageDiscount = (await prefs.getBool('discount-type-preference'))!;
    //   if(isPercentageDiscount) _type = DiscountType.percent;
    // }else{//by default it will be false
    //   await prefs.setBool('discount-type-preference', false);
    //   isPercentageDiscount = false;
    // }
    // if(prefs.containsKey('payment-mode-preference')){
    //   multiplePaymentModeSwitch = (await prefs.getBool('payment-mode-preference'))!;
    // }else{//by default it will be true
    //   await prefs.setBool('payment-mode-preference', true);
    //   multiplePaymentModeSwitch = true;
    // }

    if(prefs.containsKey('discount-type-preference')) {
      _type = (await prefs.getBool('discount-type-preference'))! ? "percent" : "amount";
    }
    if(prefs.containsKey('defaultBill')){
      defaultBillSize = (await prefs.getString('defaultBill'))!;
    }
    if(prefs.containsKey('sale-gst-preference')){
      defaultSaleGst = (await prefs.getBool('sale-gst-preference'))! ? "GST" : "Simple";
    }
    if(prefs.containsKey('purchase-gst-preference')){
      defaultPurchaseGst = (await prefs.getBool('purchase-gst-preference'))! ? "GST" : "Simple";
    }

    if(prefs.containsKey('default')){
      defaultKotBillSize = (await prefs.getString('default'))!;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preferences"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                    children: [
                      // Divider(thickness: 1,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Share invoice before sale'),
                          subtitle: Text('You can share invoice before saving order at checkout'),
                          trailing:  Switch(
                              value: shareButtonSwitch,
                              onChanged: (value) async {
                                setState(() {
                                  shareButtonSwitch = value;
                                });
                                await prefs.setBool('share-button-preference', value);
                              }),
                        ),
                      ),
                      Divider(thickness: 1,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Barcode button'),
                          subtitle: Text('You will get a barcode button which will open your camera and you can scan product barcode to fetch them'),
                          trailing:  Switch(
                              value: barcodeButtonSwitch,
                              onChanged: (value) async {
                                setState(() {
                                  barcodeButtonSwitch = value;
                                });
                                await prefs.setBool('barcode-button-preference', value);
                              }),
                        ),
                      ),
                      Divider(thickness: 1,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Skip pending orders'),
                          subtitle: Text('You will be redirected to checkout after swiping in Sale page'),
                          trailing:  Switch(
                              value: skipPendingOrderSwitch,
                              onChanged: (value) async {
                                setState(() {
                                  skipPendingOrderSwitch = value;
                                });
                                await prefs.setBool('pending-orders-preference', value);
                              }),
                        ),
                      ),
                      Divider(thickness: 1,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Order Ready'),
                          subtitle: Text('Kitchen staff can mark an order ready to notify the staff'),
                          trailing:  Switch(
                              value: showReadySwitch,
                              onChanged: (value) async {
                                setState(() {
                                  showReadySwitch = value;
                                });
                                await prefs.setBool('ready-orders-preference', value);
                              }),
                        ),
                      ),
                      Divider(thickness: 1,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Auto refresh pending orders'),
                          subtitle: Text('Pending orders page will be refreshed in the interval of 30 seconds'),
                          trailing:  Switch(
                              value: autoRefreshPendingOrdersSwitch,
                              onChanged: (value) async {
                                setState(() {
                                  autoRefreshPendingOrdersSwitch = value;
                                });
                                await prefs.setBool('refresh-pending-orders-preference', value);
                              }),
                        ),
                      ),
                      Divider(thickness: 1,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('In stock'),
                          subtitle: Text('You can mark items in/out of stock\n'),
                          trailing:  Switch(
                              value: showInStockSwitch,
                              onChanged: (value) async {
                                setState(() {
                                  showInStockSwitch = value;
                                });
                                await prefs.setBool('in-stock-button-preference', value);
                              }),
                        ),
                      ),
                      Divider(thickness: 1,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Save Name'),
                          subtitle: Text('Save name of user who has created the order'),
                          trailing:  Switch(
                              value: showNamePref,
                              onChanged: (value) async {
                                setState(() {
                                  showNamePref = value;
                                });
                                await prefs.setBool('show-name-preference', value);
                              }),
                        ),
                      ),
                      Divider(thickness: 1,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Notification'),
                          subtitle: Text('Turn this on to get notification when you receive a new order'),
                          trailing:  Switch(
                              value: buzzerSoundPref,
                              onChanged: (value) async {
                                setState(() {
                                  buzzerSoundPref = value;
                                });
                                await prefs.setBool('buzzer-qr-order-preference', value);
                              }),
                        ),
                      ),

                      // Divider(thickness: 1,),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: ListTile(
                      //     title: Text('Multiple payment mode'),
                      //     subtitle: Text('You can add more payment methods in checkout'),
                      //     trailing:  Switch(
                      //         value: multiplePaymentModeSwitch,
                      //         onChanged: (value) async {
                      //           setState(() {
                      //             multiplePaymentModeSwitch = value;
                      //           });
                      //           await prefs.setBool('payment-mode-preference', value);
                      //         }),
                      //   ),
                      // ),
                      Divider(thickness: 1,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Choose a discounting method'),
                          subtitle:  Text('Select which type of discounting you want(percent or amount)'),
                          trailing:  SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: CustomDropDownField(
                              items: const <String> ["percent","amount"],
                              initialValue: _type == 'percent' ? "percent" : "amount",
                              onSelected: (e) async {
                                await prefs.setBool('discount-type-preference', e == "percent");
                                setState(() {});
                              },
                              // validator: (e) {
                              //   if ((e ?? "").isEmpty) {
                              //     return 'Please select a mode of payment';
                              //   }
                              //   return null;
                              // },
                              hintText: "select",
                            ),
                          ),
                        ),
                      ),
                      Divider(thickness: 1,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Sale GST Report'),
                          subtitle:  Text('Select which type of report you want'),
                          trailing:  SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: CustomDropDownField(
                              items: const <String> ["GST","Simple"],
                              initialValue: defaultSaleGst,
                              onSelected: (e) async {
                                defaultSaleGst = e;
                                await prefs.setBool('sale-gst-preference', e == "GST");
                                setState(() {});
                              },
                              // validator: (e) {
                              //   if ((e ?? "").isEmpty) {
                              //     return 'Please select a mode of payment';
                              //   }
                              //   return null;
                              // },
                              hintText: "select",
                            ),
                          ),
                        ),
                      ),
                      Divider(thickness: 1,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Purchase GST Report'),
                          subtitle:  Text('Select which type of report you want'),
                          trailing:  SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: CustomDropDownField(
                              items: const <String> ["GST" , "Simple"],
                              initialValue: defaultPurchaseGst,
                              onSelected: (e) async {
                                defaultPurchaseGst = e;
                                await prefs.setBool('purchase-gst-preference', e == "GST");
                                setState(() {});
                              },
                              // validator: (e) {
                              //   if ((e ?? "").isEmpty) {
                              //     return 'Please select a mode of payment';
                              //   }
                              //   return null;
                              // },
                              hintText: "select",
                            ),
                          ),
                        ),
                      ),
                      Divider(thickness: 1,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Default bill size'),
                          subtitle:  Text('Select which type of bill you want to print in checkout'),
                          trailing:  SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: CustomDropDownField(
                              items: const <String> ["57mm","80mm","A4"],
                              initialValue: defaultBillSize,
                              onSelected: (e) async {
                                defaultBillSize = e;
                                await prefs.setString('defaultBill', e);
                                setState(() {});
                              },
                              // validator: (e) {
                              //   if ((e ?? "").isEmpty) {
                              //     return 'Please select a mode of payment';
                              //   }
                              //   return null;
                              // },
                              hintText: "select",
                            ),
                          ),
                        ),
                      ),
                      Divider(thickness: 1,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Default kot bill size'),
                          subtitle:  Text('Select which type of bill you want to print in kot'),
                          trailing:  SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: CustomDropDownField(
                              items: const <String> ["57mm","80mm"],
                              initialValue: defaultKotBillSize,
                              onSelected: (e) async {
                                defaultKotBillSize = e;
                                await prefs.setString('default', e);
                                setState(() {});
                              },
                              // validator: (e) {
                              //   if ((e ?? "").isEmpty) {
                              //     return 'Please select a mode of payment';
                              //   }
                              //   return null;
                              // },
                              hintText: "select",
                            ),
                          ),
                        ),
                      ),
                      // Divider(thickness: 1,),
                    ]
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}