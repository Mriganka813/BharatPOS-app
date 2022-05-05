// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magicstep/src/blocs/product/product_cubit.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_icons.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';

class CreateProduct extends StatefulWidget {
  static const String routeName = '/create-product';
  const CreateProduct({Key? key}) : super(key: key);

  @override
  State<CreateProduct> createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  late final ProductCubit _productCubit;
  final _formKey = GlobalKey<FormState>();

  ///
  @override
  void initState() {
    super.initState();
    _productCubit = ProductCubit();
  }

  @override
  void dispose() {
    _productCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: BlocBuilder<ProductCubit, ProductState>(
            bloc: _productCubit,
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Create Product',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Add Image",
                      ),
                      Image.asset(
                        'assets/images/image_placeholder.png',
                        height: 80,
                        width: 80,
                      ),
                      const Divider(color: Colors.transparent),
                      const CustomTextField(
                        label: "Name",
                      ),
                      const Divider(color: Colors.transparent),
                      Row(
                        children: const [
                          Expanded(
                            child: CustomTextField(
                              label: "Selling Price",
                              inputType: TextInputType.number,
                            ),
                          ),
                          VerticalDivider(color: Colors.transparent),
                          Expanded(
                            child: CustomTextField(
                              label: "Inventory",
                              inputType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: CustomTextField(
                              label: "Barcode",
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
                            },
                            icon: const Icon(CustomIcons.camera),
                          )
                        ],
                      ),
                      const Divider(color: Colors.transparent),
                      Align(
                        alignment: Alignment.centerRight,
                        child: CustomButton(
                          title: "Save",
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
