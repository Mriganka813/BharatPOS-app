import 'dart:async';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shopos/src/pages/billing_list.dart';

class BluetoothPrinterList extends StatefulWidget {
  static const routeName = '/bluetooth-printers';
  const BluetoothPrinterList({
    Key? key,
    required this.bluetoothArgs,
  }) : super(key: key);

  final BluetoothArgs bluetoothArgs;

  @override
  State<BluetoothPrinterList> createState() => _BluetoothPrinterListState();
}

class _BluetoothPrinterListState extends State<BluetoothPrinterList> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  List<BluetoothDevice> _devices = [];
  String _deviceMsg = "";

  @override
  void initState() {
    super.initState();
    getpermission();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initPrinter();
    });
  }

  Future<void> initPrinter() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    if (!mounted) return;

    bluetoothPrint.scanResults.listen((val) {
      if (!mounted) return;

      setState(() {
        _devices = val;
        if (_devices.isEmpty) {
          _deviceMsg = "No devices found";
        }
      });
    });
  }

  void getpermission() async {
    try {
      await Permission.bluetoothConnect.request();
      if (await Permission.bluetooth.request().isDenied) {
        Navigator.of(context).pop();
      }

      await Permission.location.request();
      if (await Permission.location.request().isDenied) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Future<void> getBluetooth() async {
  //   final List bluetooths = await BluetoothThermalPrinter.getBluetooths ?? [];
  //   if (!mounted) return;
  //   print("Print ${bluetooths}");
  //   setState(() {
  //     if (!mounted) return;
  //     _devices = bluetooths;
  //     if (_devices.isEmpty) {
  //       _deviceMsg = "No devices found";
  //     }
  //   });
  // }

  // Function to print PDF via Bluetooth
  Future<void> printPdfViaBluetooth(BluetoothDevice device) async {
    if (device != null && device.address != null) {
      await bluetoothPrint.connect(device);

      Map<String, dynamic> config = Map();
      List<LineText> list = [];

      String dateFormat() => DateFormat('MMM d, y hh:mm:ss a')
          .format(widget.bluetoothArgs.dateTime);

      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "KOT",
        weight: 2,
        width: 2,
        height: 2,
        align: LineText.ALIGN_CENTER,
        linefeed: 1,
      ));

      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: dateFormat(),
        weight: 1,
        align: LineText.ALIGN_CENTER,
        linefeed: 1,
      ));

      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Table',
        weight: 1,
        width: 2,
        height: 2,
        align: LineText.ALIGN_CENTER,
        linefeed: 1,
      ));

      list.add(LineText(
        content: 'Item',
        type: LineText.TYPE_TEXT,
        weight: 0,
        align: LineText.ALIGN_LEFT,
      ));

      list.add(LineText(
        content: 'Qty',
        type: LineText.TYPE_TEXT,
        weight: 0,
        align: LineText.ALIGN_RIGHT,
        linefeed: 1,
      ));

      for (var i = 0;
          i < widget.bluetoothArgs.orderInput.orderItems!.length;
          i++) {
        list.add(LineText(
          content: widget.bluetoothArgs.orderInput.orderItems![i].product!.name,
          type: LineText.TYPE_TEXT,
          weight: 0,
          align: LineText.ALIGN_LEFT,
        ));

        list.add(LineText(
          content: widget.bluetoothArgs.orderInput.orderItems![i].quantity
              .toString(),
          type: LineText.TYPE_TEXT,
          weight: 0,
          align: LineText.ALIGN_RIGHT,
          linefeed: 1,
        ));
      }
      await bluetoothPrint.printReceipt(config, list);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Printer page"),
        ),
        backgroundColor: Colors.white,
        body: _devices.isNotEmpty
            ? ListView.builder(
                itemBuilder: (context, position) {
                  return ListTile(
                    onTap: () {
                      //  _startPrint(_devices[position]);
                      printPdfViaBluetooth(_devices[position]);
                    },
                    leading: Icon(Icons.print),
                    title: Text(_devices[position].name!),
                    subtitle: Text(_devices[position].address!),
                  );
                },
                itemCount: _devices.length,
              )
            : Center(
                child: Text(
                  _deviceMsg ?? 'Ops something went wrong!',
                  style: TextStyle(fontSize: 24),
                ),
              ));
  }
}
