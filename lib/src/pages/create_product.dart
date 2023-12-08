import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopos/src/models/input/product_input.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/services/product.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_icons.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';
import 'package:shopos/src/widgets/custom_text_field2.dart';
import 'package:switcher/core/switcher_size.dart';
import 'package:switcher/switcher.dart';
import 'package:shopos/src/widgets/custom_date_picker.dart';
// import 'package:intl/intl.dart';

import '../blocs/product/product_cubit.dart';

class CreateProduct extends StatefulWidget {
  static const String routeName = '/create-product';
  final String? id;
  const CreateProduct({Key? key, this.id}) : super(key: key);

  @override
  State<CreateProduct> createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  late final ProductCubit _productCubit;
  final _formKey = GlobalKey<FormState>();
  late ProductFormInput _formInput;
  final AudioCache _audioCache = AudioCache();
  late final ImagePicker _picker;
  bool _showLoader = false;
  bool gstSwitch = false;

  TextEditingController sellingPriceController = TextEditingController();
  TextEditingController purchasePriceController = TextEditingController();
  TextEditingController gstratePriceController = TextEditingController();
  TextEditingController baseSellingPriceController = TextEditingController();

  int includedExcludedRadioButton = 1;

  ///
  @override
  void initState() {
    super.initState();
    _formInput = ProductFormInput();
    _productCubit = ProductCubit();
    _picker = ImagePicker();
    // _audioCache = AudioCache(
    //   fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    // );
    _fetchProductData();
    _productCubit.gst();
  }

  void _fetchProductData() async {
    ProductFormInput? productInput;
    if (widget.id == null) {
      return;
    }
    try {
      final response = await const ProductService().getProduct(widget.id!);
      print(response.toString());
      productInput = ProductFormInput.fromMap(response.data['inventory']);
    } on DioError catch (err) {
      log(err.message.toString());
    }
    if (productInput == null) {
      return;
    }
    setState(() {
      _formInput = productInput!;
    });

    if (_formInput.GSTincluded != null) if (_formInput.GSTincluded!) {
      includedExcludedRadioButton = 1;
      print("it is 1");
    } else {
      includedExcludedRadioButton = 2;
      print("it is 2");
    }

    print("gstttt");
    print(_formInput.gstRate);
    print(_formInput.gst);
    if (_formInput.gstRate != null &&
        _formInput.gstRate != "null" &&
        _formInput.gstRate != "") {
      _formInput.gst = true;
      print("kkkk");
      print(_formInput.gst);
      gstSwitch = true;
    }
    sellingPriceController.text = _formInput.sellingPrice as String;
    print("testttt=${_formInput.sellingPrice}");

    purchasePriceController.text = _formInput.purchasePrice != "null"
        ? _formInput.purchasePrice as String
        : "";
    setState(() {});

    gstratePriceController.text =
        _formInput.gstRate != "null" ? _formInput.gstRate as String : "";
    purchasePriceController.text =
        _formInput.purchasePrice != "null" && _formInput.purchasePrice != ""
            ? _formInput.purchasePrice!
            : "0";

    baseSellingPriceController.text =
        _formInput.baseSellingPriceGst != "null" &&
                _formInput.baseSellingPriceGst != ""
            ? _formInput.baseSellingPriceGst!
            : "0";
    if (_formInput.purchasePrice != "null" && _formInput.purchasePrice != "") {
      purchasePriceController.text = _formInput.purchasePrice!;
    } else {
      purchasePriceController.text = "0";
      _formInput.purchasePrice = "0";
      setState(() {});
    }

    calculate();
  }

  @override
  void dispose() {
    _productCubit.close();
    _audioCache.clearAll();
    super.dispose();
  }

  void _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (cntxt) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(cntxt);
                        _pickImage(ImageSource.camera);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Center(
                            child: Icon(
                              Icons.camera,
                              size: 60,
                            ),
                          ),
                          Divider(color: Colors.transparent),
                          Text('Camera')
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(cntxt);
                        _pickImage(ImageSource.gallery);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Center(
                            child: Icon(
                              Icons.photo_rounded,
                              size: 60,
                            ),
                          ),
                          Divider(color: Colors.transparent),
                          Text('Album')
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.transparent),
            ],
          ),
        );
      },
    );
  }

  void _pickImage(ImageSource source) async {
    final XFile? image =
        await _picker.pickImage(source: source, imageQuality: 20);
    if (image == null) {
      return;
    }
    setState(() {
      _formInput.imageFile = image;
    });
  }

  void calculate() {
    if (_formInput.gstRate != null && _formInput.gst) {
      int rate = int.parse(_formInput.gstRate!);

// selling price
      if (_formInput.sellingPrice != null && includedExcludedRadioButton == 1) {
        print("gggggggggg");
        double oldsp = double.parse(_formInput.sellingPrice!);
        double basesp = (oldsp * 100 / (100 + rate));

        String salesgst = ((oldsp - basesp) / 2).toStringAsFixed(2);
        String salecgst = ((oldsp - basesp) / 2).toStringAsFixed(2);
        String saleigst = (oldsp - basesp).toStringAsFixed(2);
        setState(() {
          _formInput.salesgst = salesgst.toString();
          _formInput.salecgst = salecgst.toString();
          _formInput.saleigst = saleigst.toString();
          _formInput.baseSellingPriceGst = basesp.toStringAsFixed(2).toString();
        });

        baseSellingPriceController.text = basesp.toStringAsFixed(2).toString();
      }
      if (includedExcludedRadioButton == 2) {
        double bsp = double.parse(_formInput.baseSellingPriceGst!);
        double gstRate = double.parse(_formInput.gstRate!);

        double gstAmt = (bsp * (gstRate / 100));
        _formInput.sellingPrice = (bsp + gstAmt).toString();

        double oldsp = double.parse(_formInput.sellingPrice!);

        String salesgst = ((oldsp - bsp) / 2).toStringAsFixed(2);
        String salecgst = ((oldsp - bsp) / 2).toStringAsFixed(2);
        String saleigst = (oldsp - bsp).toStringAsFixed(2);

        _formInput.salesgst = salesgst.toString();
        _formInput.salecgst = salecgst.toString();
        _formInput.saleigst = saleigst.toString();

        print(
            "Seeling price changed by changing bsp:${_formInput.sellingPrice}");

        sellingPriceController.text =
            (bsp + gstAmt).toStringAsFixed(2).toString();

        setState(() {});
      }

// purchase price
      if (_formInput.purchasePrice != null) {
        int oldpp = int.parse(_formInput.purchasePrice!);
        double basepp = (oldpp * 100 / (100 + rate));
        String purchasecgst = ((oldpp - basepp) / 2).toStringAsFixed(2);
        String purchasesgst = ((oldpp - basepp) / 2).toStringAsFixed(2);
        String purchaseigst = (oldpp - basepp).toStringAsFixed(2);

        setState(() {
          _formInput.purchasesgst = purchasesgst.toString();
          _formInput.purchasecgst = purchasecgst.toString();
          _formInput.purchaseigst = purchaseigst.toString();
          _formInput.basePurchasePriceGst =
              basepp.toStringAsFixed(2).toString();
        });
      }

      print("pruchase");
      print(_formInput.basePurchasePriceGst);
    }

    var temp = _formInput;
    _formInput = temp;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("sellingggggggPrice:");
    print(gstSwitch);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Product'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      "Add Image",
                      style: Theme.of(context).textTheme.headline6?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                    const Divider(color: Colors.transparent),
                    GestureDetector(
                      onTap: () {
                        _showImagePickerOptions();
                      },
                      child: SizedBox(
                        height: 160,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Stack(
                            children: [
                              _formInput.image != "null" &&
                                      _formInput.image != null
                                  ? CachedNetworkImage(
                                      imageUrl: _formInput.image!,
                                      fit: BoxFit.fill,
                                    )
                                  : _formInput.imageFile == null
                                      ? Image.asset(
                                          'assets/images/image_placeholder.png',
                                          height: 80,
                                          width: 80,
                                        )
                                      : Image.file(
                                          File(_formInput.imageFile!.path),
                                          fit: BoxFit.contain,
                                        ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "Name",
                      value: _formInput.name,
                      onChanged: (e) {
                        _formInput.name = e;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "Batch number",
                      value: _formInput.batchNumber,
                      onChanged: (e) {
                        _formInput.batchNumber = e;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField2(
                            readonly:
                                includedExcludedRadioButton == 2 ? true : false,
                            controller: sellingPriceController,
                            label: "Selling Price",
                            value: _formInput.sellingPrice,
                            inputType: TextInputType.number,
                            onChanged: (e) {
                              if (e.isNotEmpty &&
                                  includedExcludedRadioButton == 1) {
                                _formInput.sellingPrice = e;
                                calculate();
                              }
                            },
                            validator: (e) {
                              if (e!.contains(",")) {
                                return '(,) characters are not allowed';
                              }
                              if (e.isEmpty) {
                                return "Please enter selling price";
                              }
                              return null;
                            },
                          ),
                        ),
                        const VerticalDivider(color: Colors.transparent),
                        Expanded(
                          child: CustomTextField2(
                            controller: purchasePriceController,
                            label: "Purchase Price",
                            value: _formInput.purchasePrice != "null" &&
                                    _formInput.purchasePrice != ""
                                ? _formInput.purchasePrice
                                : "0",
                            inputType: TextInputType.number,
                            onChanged: (e) {
                              _formInput.purchasePrice = e;
                              calculate();
                              print("pppppppooooppp");
                              print(gstSwitch);
                            },
                            validator: (e) {
                              if (e!.contains(",")) {
                                return '(,) characters are not allowed';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.transparent),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Switch(
                            value: gstSwitch,
                            onChanged: (value) {
                              setState(() {
                                gstSwitch = value;
                                _formInput.gst = true;
                              });
                            }),
                        VerticalDivider(),
                        !gstSwitch
                            ? Text(
                                "GST Details",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    ?.copyWith(
                                        color: Colors.black12,
                                        fontWeight: FontWeight.normal),
                              )
                            : Text(
                                "GST Details",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                              )
                      ],
                    ),
                    Visibility(
                      visible: gstSwitch,
                      child: Column(
                        children: [
                          const Divider(color: Color.fromRGBO(0, 0, 0, 0)),
                          Row(
                            children: [
                              RadioMenuButton(
                                  value: 1,
                                  groupValue: includedExcludedRadioButton,
                                  onChanged: (val) {
                                    _formInput.GSTincluded = true;
                                    sellingPriceController.text =
                                        baseSellingPriceController.text;
                                    _formInput.sellingPrice =
                                        baseSellingPriceController.text;

                                    baseSellingPriceController.text = "";
                                    setState(() {
                                      includedExcludedRadioButton = 1;
                                    });
                                    calculate();
                                  },
                                  child: Text("Included")),
                              RadioMenuButton(
                                  value: 2,
                                  groupValue: includedExcludedRadioButton,
                                  onChanged: (val) {
                                    _formInput.GSTincluded = false;
                                    baseSellingPriceController.text =
                                        sellingPriceController.text;
                                    _formInput.baseSellingPriceGst =
                                        sellingPriceController.text;
                                    //  sellingPriceController.text="";

                                    setState(() {
                                      includedExcludedRadioButton = 2;
                                    });
                                    calculate();
                                  },
                                  child: Text("Excluded"))
                            ],
                          ),
                          SizedBox(
                            height: 50,
                          ),

                          CustomTextField2(
                            controller: gstratePriceController,
                            label: "GST Rate (%)",
                            value: _formInput.gstRate != "null"
                                ? _formInput.gstRate
                                : "0",
                            inputType: TextInputType.number,
                            onChanged: (e) {
                              _formInput.gstRate = e;

                              setState(() {});
                              calculate();
                            },
                            validator: (e) {
                              if (!gstSwitch && e == "") return "Enter Rate";
                            },
                          ),
                          const Divider(color: Colors.transparent),
                          Row(
                            children: [
                              // Expanded(
                              //   child: CustomTextField(
                              //     readonly: true,
                              //     label: "SGST",
                              //     value: _formInput.salesgst,
                              //     onChanged: (e) {
                              //       _formInput.salesgst = e;
                              //     },
                              //     validator: (e) => null,
                              //   ),
                              // ),
                              // VerticalDivider(),
                              // Expanded(
                              //   child: CustomTextField(
                              //     readonly: true,
                              //     label: "CGST",
                              //     value: _formInput.salecgst,
                              //     onChanged: (e) {
                              //       _formInput.salecgst = e;
                              //     },
                              //     validator: (e) => null,
                              //   ),
                              // ),
                              // VerticalDivider(),
                              // Expanded(
                              //   child: CustomTextField(
                              //     readonly: true,
                              //     label: "IGST",
                              //     value: _formInput.saleigst,
                              //     onChanged: (e) {
                              //       _formInput.saleigst = e;
                              //     },
                              //     validator: (e) => null,
                              //   ),
                              // ),
                            ],
                          ),
                          // const Divider(color: Colors.transparent),
                          CustomTextField2(
                            controller: baseSellingPriceController,
                            readonly:
                                includedExcludedRadioButton == 1 ? true : false,
                            label: "Base Selling Price",
                            value: _formInput.baseSellingPriceGst == "null"
                                ? "0"
                                : _formInput.baseSellingPriceGst,
                            onChanged: (e) {
                              if (includedExcludedRadioButton == 2) {
                                _formInput.baseSellingPriceGst = e;

                                setState(() {});
                                calculate();
                              }
                            },
                            validator: (e) => null,
                          ),
                          const Divider(color: Colors.transparent),
                          CustomTextField(
                            readonly: true,
                            label: "Base Purchase Price",
                            value: _formInput.basePurchasePriceGst == "null"
                                ? "0"
                                : _formInput.basePurchasePriceGst,
                            onChanged: (e) {
                              _formInput.basePurchasePriceGst = e;
                            },
                            validator: (e) => null,
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.transparent),
                    CustomDatePicker(
                      label: 'Expiry Date',
                      hintText: 'Select expiry date',
                      onChanged: (DateTime value) {
                        setState(() {
                          _formInput.expiryDate = value;
                          print(value);
                        });
                      },
                      onSave: (DateTime? value) {},
                      value: _formInput.expiryDate != null
                          ? _formInput.expiryDate
                          : null,
                      validator: (DateTime? value) => null,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365 * 3)),
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "HSN",
                      value: _formInput.hsn == "null" ? " " : _formInput.hsn,
                      onChanged: (e) {
                        _formInput.hsn = e;
                      },
                      validator: (e) => null,
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "Quantity",
                      value: _formInput.quantity != null
                          ? _formInput.quantity
                          : "",
                      inputType: TextInputType.number,
                      onChanged: (e) {
                        _formInput.quantity = e;
                      },
                      validator: (e) {
                        if (e!.contains(".") || e.contains(",")) {
                          return '(. ,) characters are not allowed';
                        }
                        if (e.isNotEmpty) if (int.parse(e) > 99999) {
                          return 'Maximum value is 99999';
                        }
                        return null;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: "Barcode",
                            value: _formInput.barCode != "null"
                                ? _formInput.barCode
                                : "",
                            onChanged: (e) {
                              _formInput.barCode = e;
                            },
                            validator: (e) => null,
                          ),
                        ),
                        const VerticalDivider(color: Colors.transparent),
                        IconButton(
                          onPressed: () async {
                            _scanBarode();
                            // Check if the device can vibrate
                          },
                          icon: const Icon(CustomIcons.camera),
                        )
                      ],
                    ),
                    const Divider(color: Colors.transparent, height: 40),
                    CustomButton(
                      title: "Save",
                      onTap: () {
                        _formKey.currentState?.save();

                        print(_formInput.purchasePrice);

                        if (_formInput.purchasePrice == null ||
                            _formInput.purchasePrice == "null" ||
                            _formInput.purchasePrice == "") {
                          _formInput.purchasePrice = "0";
                        }

                        if (_formKey.currentState?.validate() ?? false) {
                          print(_formInput.available);
                          print(_formInput.expiryDate);
                          print(_formInput.batchNumber);

                          _productCubit.createProduct(_formInput);
                          print("Barcode:");
                          print(_formInput.barCode);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ))));
  }

  Future<void> _scanBarode() async {
    final res = await FlutterBarcodeScanner.scanBarcode(
      "#000000",
      "#000000",
      false,
      ScanMode.BARCODE,
    );
    if (res.isEmpty) {
      return;
    }
    const _type = FeedbackType.success;
    Vibrate.feedback(_type);
    // await _audioCache.play('audio/beep.mp3');
    setState(() {
      _formInput.barCode = res;
    });
  }
}
