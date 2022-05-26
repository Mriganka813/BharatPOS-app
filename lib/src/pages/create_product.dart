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
import 'package:magicstep/src/models/input/product_input.dart';
import 'package:magicstep/src/services/global.dart';
import 'package:magicstep/src/services/locator.dart';
import 'package:magicstep/src/services/product.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_icons.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';

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
  late final AudioCache _audioCache;
  late final ImagePicker _picker;
  bool _showLoader = false;

  ///
  @override
  void initState() {
    super.initState();
    _formInput = ProductFormInput();
    _productCubit = ProductCubit();
    _picker = ImagePicker();
    _audioCache = AudioCache(
      fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    );
    _fetchProductData();
  }

  void _fetchProductData() async {
    ProductFormInput? productInput;
    if (widget.id == null) {
      return;
    }
    try {
      final response = await const ProductService().getProduct(widget.id!);
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
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) {
      return;
    }
    setState(() {
      _formInput.imageFile = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: BlocListener<ProductCubit, ProductState>(
            bloc: _productCubit,
            listener: (context, state) {
              if (state is! ProductLoading && _showLoader) {
                setState(() {
                  _showLoader = false;
                });
                Navigator.pop(context);
              }
              if (state is ProductCreated) {
                return Navigator.pop(context);
              }
              if (state is ProductLoading) {
                if (!_showLoader) {
                  setState(() {
                    _showLoader = true;
                  });
                  locator<GlobalServices>().showBottomSheetLoader();
                }
              }
            },
            child: BlocBuilder<ProductCubit, ProductState>(
              bloc: _productCubit,
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      onSave: (e) {
                        _formInput.name = e;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: "Selling Price",
                            value: _formInput.sellingPrice,
                            inputType: TextInputType.number,
                            onSave: (e) {
                              _formInput.sellingPrice = e;
                            },
                          ),
                        ),
                        const VerticalDivider(color: Colors.transparent),
                        Expanded(
                          child: CustomTextField(
                            label: "Purchase Price",
                            value: _formInput.purchasePrice,
                            inputType: TextInputType.number,
                            onSave: (e) {
                              _formInput.purchasePrice = e;
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "Quantity",
                      value: _formInput.quantity,
                      inputType: TextInputType.number,
                      onSave: (e) {
                        _formInput.quantity = e;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: "Barcode",
                            value: _formInput.barCode,
                            onSave: (e) {
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomButton(
                        title: "Save",
                        onTap: () {
                          _formKey.currentState?.save();
                          if (_formKey.currentState?.validate() ?? false) {
                            _productCubit.createProduct(_formInput);
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
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
    await _audioCache.play('audio/beep.mp3');
    setState(() {
      _formInput.barCode = res;
    });
  }
}
