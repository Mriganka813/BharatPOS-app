import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:image_cropper/image_cropper.dart';
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
import '../models/product.dart';
import '../services/search_service.dart';
class CreateProductArgs{
  final String? id;
  final bool? isCopy;
  CreateProductArgs({this.id, this.isCopy});
}
class CreateProduct extends StatefulWidget {
  static const String routeName = '/create-product';
  CreateProductArgs? args;
  CreateProduct({Key? key, this.args}) : super(key: key);

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
  List<SubProduct> subProductList=[];
  TextEditingController sellingPriceController = TextEditingController();
  TextEditingController purchasePriceController = TextEditingController();
  TextEditingController gstratePriceController = TextEditingController();
  TextEditingController baseSellingPriceController = TextEditingController();

  final List<TextEditingController> _subProductNames = [];
  final List<TextEditingController> _subProductQuantities = [];
  final List<GlobalKey> _keys = [];
  final ScrollController _scrollController = ScrollController();
  final SearchProductServices searchProductServices = SearchProductServices();
  int includedExcludedRadioButton = 1;

  _addSubProductField() {
    setState(() {
      _subProductNames.add(TextEditingController());
      _subProductQuantities.add(TextEditingController());
      _keys.add(GlobalKey());
      print("----line 62 in create_product---");
      print(_subProductNames.length);
      print(_subProductQuantities.length);
    });
  }

  _removeSubProductField(i) {
    setState(() {
      _subProductNames.removeAt(i);
      _subProductQuantities.removeAt(i);
      _keys.removeAt(i);
    });
  }

  ///
  @override
  void initState() {
    super.initState();
    _formInput = ProductFormInput();
    _productCubit = ProductCubit();
    _picker = ImagePicker();
    _formInput.subProducts =[];
    // _audioCache = AudioCache(
    //   fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    // );
    _fetchProductData();
    _productCubit.gst();
  }

  void _fetchProductData() async {
    ProductFormInput? productInput;
    if (widget.args?.id == null) {
      return;
    }
    try {
      final response = await const ProductService().getProduct(widget.args!.id!);
      print("fetching product data in line 73 in createproduct");
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
      if(widget.args?.isCopy != null && widget.args?.isCopy == true) {
        //if user wants to copy the product
        _formInput.id = null;
        _formInput.name = "${_formInput.name} (copy)";
        _formInput.barCode = null;
        _formInput.image = null;
      }
    });
    setState(() {
      _formInput = productInput!;
    });

    if (_formInput.GSTincluded != null) if (_formInput.GSTincluded!) {
      includedExcludedRadioButton = 1;
    } else {
      includedExcludedRadioButton = 2;
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

    for(int i = 0;i < _formInput.subProducts!.length;i++){

      _subProductNames.add(TextEditingController());
      _subProductQuantities.add(TextEditingController());
      _keys.add(GlobalKey());
      _subProductNames[i].text= _formInput.subProducts?[i].name ?? "";
      _subProductQuantities[i].text = _formInput.subProducts?[i].quantity.toString() ?? "";
    }
    print("end of fetch product data and _forminput.image is ${_formInput.image} and runtime type is ${_formInput.image.runtimeType}");
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
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 20);
    if (image == null) return; //if photo is null then it will return else---
    File? croppedFile = await ImageCropper().cropImage(//Image Cropper
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        // CropAspectRatioPreset.ratio3x2,
        // CropAspectRatioPreset.original,
        // CropAspectRatioPreset.ratio4x3,
        // CropAspectRatioPreset.ratio16x9
      ],

      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop Your Photo',
          toolbarColor: Colors.white,
          toolbarWidgetColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),

    );

    setState(() {
      _formInput.imageFile = XFile(croppedFile!.path);
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
            controller: _scrollController,
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
                                  ? _formInput.imageFile == null
                                      ? CachedNetworkImage(
                                         imageUrl: _formInput.image!,
                                         fit: BoxFit.fill,
                                       )
                                      : Image.file(
                                          File(_formInput.imageFile!.path),
                                          fit: BoxFit.contain,
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
                                    if (includedExcludedRadioButton == 2) {
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
                                    }
                                  },
                                  child: Text("Included")),
                              RadioMenuButton(
                                  value: 2,
                                  groupValue: includedExcludedRadioButton,
                                  onChanged: (val) {
                                    if (includedExcludedRadioButton == 1) {
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
                                    }
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
                      label: "MRP",
                      value: _formInput.mrp == "null" ? " " : _formInput.mrp,
                      inputType: TextInputType.numberWithOptions(signed: false, decimal: true),
                      onChanged: (e) {
                        _formInput.mrp = e;
                      },
                      validator: (e) => null,
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "Quantity",
                      value: _formInput.quantity != null
                          ? _formInput.quantity
                          : "",
                      inputType: TextInputType.numberWithOptions(signed: false, decimal: true),
                      onChanged: (e) {
                        _formInput.quantity = e;
                      },
                      validator: (e) {
                        if (e!.contains(",")) {
                          return '(,) character are not allowed';
                        }
                        if (e.isNotEmpty) if (double.parse(e) > 99999.0) {
                          return 'Maximum value is 99999';
                        }
                        return null;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "Unit",
                      value: _formInput.unit,
                      onChanged: (e){
                        _formInput.unit = e;
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
                    Column(
                      children: [
                        for (int i = 0; i < _subProductNames.length; i++)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, bottom: 8),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("Sub Product ${i + 1}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      IconButton(
                                        onPressed: () => _removeSubProductField(i),
                                        icon: Icon(Icons.delete),
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                  TypeAheadFormField<Product>(
                                    key: _keys[i],
                                    textFieldConfiguration: TextFieldConfiguration(
                                      controller: _subProductNames[i],
                                      decoration: InputDecoration(
                                          label: Text("Name"),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(10))),
                                    ),
                                    suggestionsCallback: (String pattern) {
                                      Scrollable.ensureVisible(_keys[i].currentContext!, duration: Duration(microseconds: 500),curve: Curves.easeInOut,);
                                      if (int.tryParse(pattern.trim()) != null) {
                                        return Future.value([]);
                                      }
                                      return _searchSubProducts(pattern);
                                    },
                                    itemBuilder: (context, subProduct) {
                                      return ListTile(
                                        leading: const Icon(Icons.shopping_cart),
                                        title: Text(subProduct.name ?? ""),
                                        onTap: () {
                                          _subProductNames[i].text = subProduct.name!;
                                          FocusScope.of(context).unfocus();
                                        },
                                      );
                                    },
                                    onSuggestionSelected: (Product subProduct) {

                                      _subProductNames[i].text = subProduct.name!;
                                      FocusScope.of(context).unfocus();
                                    },
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: _subProductQuantities[i],
                                    keyboardType:
                                    TextInputType.numberWithOptions(
                                        signed: false, decimal: true),
                                    decoration: InputDecoration(
                                        label: Text("Quantity"),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(10))),
                                    validator: (e) {
                                      if (e!.contains(",")) {
                                        return '(,) character are not allowed';
                                      }
                                      if (e.isNotEmpty) if (double.parse(e) >
                                          99999.0) {
                                        return 'Maximum value is 99999';
                                      }
                                      return null;
                                    },
                                  )
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                    const Divider(color: Colors.transparent),
                    //Add subProduct button
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      InkWell(
                        onTap: (){
                          setState(() {
                            _addSubProductField();
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                            );
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 18, right: 20, top: 8, bottom: 8),
                          decoration: ShapeDecoration(
                            // color: const Color(0xFF1E232C),
                            color: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.black,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Sub Products',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ]),
                    const Divider(color: Colors.transparent, height: 40),
                    CustomButton(
                      title: "Save",
                      onTap: () async {
                        _formKey.currentState?.save();

                        print(_formInput.purchasePrice);

                        if (_formInput.purchasePrice == null ||
                            _formInput.purchasePrice == "null" ||
                            _formInput.purchasePrice == "") {
                          _formInput.purchasePrice = "0";
                        }
                        print("saving the product and _subProduct.length is ${_subProductNames.length}");
                        for (int i = 0; i < _subProductNames.length; i++){
                          List<Product> prodList = await searchProductServices.searchproduct(_subProductNames[i].text.toString());
                          for(int j = 0;j<prodList.length;j++){
                            SubProduct subProduct = SubProduct();
                            print("executing line 877----");
                            if(prodList.elementAt(j).name==_subProductNames[i].text.toString()){
                              subProduct.name = prodList.elementAt(j).name.toString();
                              subProduct.inventoryId = prodList.elementAt(j).id.toString();
                              subProduct.quantity = double.parse(_subProductQuantities[i].text);
                              print("line 901 in create product");
                              print(subProduct.name);
                              print(subProduct.inventoryId);
                              print(subProduct.quantity);
                              // var newSubProduct = {"inventoryId": prodList.elementAt(j).id.toString(),
                              //   "name": prodList.elementAt(j).name.toString(),
                              //   "quantity": _subProductQuantities[i].text.toString()};
                              // print(newSubProduct);
                              subProductList.add(subProduct);
                              _formInput.subProducts = (subProductList);
                            }
                          }
                        }
                        print(subProductList);
                        _formInput.subProducts = (subProductList);
                        print("line 887");
                        print(_formInput.subProducts);
                        if (_formKey.currentState?.validate() ?? false) {
                          print(_formInput.available);
                          print(_formInput.expiryDate);
                          print(_formInput.batchNumber);
                          print("line 889 in createProduct.dart----");
                          print(_formInput.subProducts.toString());
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
  Future<Iterable<Product>> _searchSubProducts(String pattern) async {
    if (pattern.isEmpty) {
      return [];
    }
    List<Product> prodList = await searchProductServices.searchproduct(pattern);
    return prodList;
  }
}
