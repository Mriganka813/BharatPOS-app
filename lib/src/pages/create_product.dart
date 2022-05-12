// ignore_for_file: unused_local_variable

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magicstep/src/blocs/product/product_cubit.dart';
import 'package:magicstep/src/models/input/product_input.dart';
import 'package:magicstep/src/services/product.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_icons.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';

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

  ///
  @override
  void initState() {
    super.initState();
    _formInput = ProductFormInput();
    _productCubit = ProductCubit();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Create Product'),
      ),
      body: Form(
        key: _formKey,
        child: BlocListener<ProductCubit, ProductState>(
          bloc: _productCubit,
          listener: (context, state) {
            if (state is ProductCreated) {
              return Navigator.pop(context);
            }
            if (state is ProductsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          },
          child: BlocBuilder<ProductCubit, ProductState>(
            bloc: _productCubit,
            builder: (context, state) {
              bool isLoading = false;
              if (state is ProductLoading) {
                isLoading = true;
              }
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          "Add Image",
                        ),
                        Image.asset(
                          'assets/images/image_placeholder.png',
                          height: 80,
                          width: 80,
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
                                label: "Inventory",
                                value: _formInput.quantity,
                                inputType: TextInputType.number,
                                onSave: (e) {
                                  _formInput.quantity = e;
                                },
                              ),
                            ),
                          ],
                        ),
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
                              ),
                            ),
                            const VerticalDivider(color: Colors.transparent),
                            IconButton(
                              onPressed: () async {
                                String barcodeScanRes =
                                    await FlutterBarcodeScanner.scanBarcode(
                                  "#000000",
                                  "#000000",
                                  false,
                                  ScanMode.BARCODE,
                                );
                                setState(() {
                                  _formInput.barCode = barcodeScanRes;
                                });
                              },
                              icon: const Icon(CustomIcons.camera),
                            )
                          ],
                        ),
                        const Divider(color: Colors.transparent),
                        const Spacer(),
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
                    ),
                  ),
                  if (isLoading)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
