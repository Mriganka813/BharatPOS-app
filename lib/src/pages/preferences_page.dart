import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DefaultPreferences extends StatefulWidget {
  static const routeName = 'default-preferences';

  const DefaultPreferences();

  @override
  State<DefaultPreferences> createState() => _DefaultPreferencesState();
}

class _DefaultPreferencesState extends State<DefaultPreferences> {
  bool shareButtonSwitch = false;
  bool barcodeButtonSwitch = false;
  bool skipPendingOrderSwitch = false;
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

    if(prefs.containsKey('barcode-button-preference')){
      barcodeButtonSwitch = (await prefs.getBool('barcode-button-preference'))!;
    }else{//by default it will be true
      await prefs.setBool('barcode-button-preference', true);
      barcodeButtonSwitch = true;
    }

    if(prefs.containsKey('pending-orders-preference')){
      skipPendingOrderSwitch = (await prefs.getBool('pending-orders-preference'))!;
    }else{//by default it will be true
      await prefs.setBool('pending-orders-preference', false);
      skipPendingOrderSwitch = false;
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
                    // Divider(thickness: 1,),
                  ]
              ),
            ),

          ],
        ),
      ),
    );
  }
}