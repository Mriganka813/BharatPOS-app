import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:shopos/src/models/input/order_input.dart';
import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/pages/products_list.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/product_card_horizontal.dart';
import 'package:slidable_button/slidable_button.dart';

import '../services/product.dart';

class CreateSale extends StatefulWidget {
  static const routeName = '/create_sale';
  const CreateSale({Key? key}) : super(key: key);

  @override
  State<CreateSale> createState() => _CreateSaleState();
}

class _CreateSaleState extends State<CreateSale> {
  late OrderInput _orderInput;
  late final AudioCache _audioCache;

  @override
  void initState() {
    super.initState();
    // _audioCache = AudioCache(
    //   fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    // );
    _orderInput = OrderInput(
      orderItems: [],
    );
  }

  void _onAdd(OrderItemInput orderItem) {
    final qty = orderItem.quantity + 1;
    final availableQty = orderItem.product?.quantity ?? 0;
    if (qty > availableQty) {
      locator<GlobalServices>().infoSnackBar("Quantity not available");
      return;
    }
    setState(() {
      orderItem.quantity += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _orderItems = _orderInput.orderItems ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: _orderItems.isEmpty
                  ? Center(
                      child: Container(
                        height: 230,
                        width: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color.fromARGB(255, 220, 220, 220),
                        ),
                        //color: Color.fromARGB(255, 207, 207, 207),
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              ProductsListPage.routeName,
                              arguments: const ProductListPageArgs(
                                isSelecting: true,
                                orderType: OrderType.sale,
                              ),
                            );
                            if (result == null && result is! List<Product>) {
                              return;
                            }
                            final orderItems = (result as List<Product>)
                                .map((e) => OrderItemInput(
                                      product: e,
                                      quantity: 1,
                                      price: 0,
                                    ))
                                .toList();
                            setState(() {
                              _orderInput.orderItems?.addAll(orderItems);
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  // <-- Icon
                                  Icons.add_box_outlined,
                                  size: 40.0,
                                ),
                                Text(
                                  'Add Manually',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600),
                                ), // <--
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromARGB(255, 220, 220, 220),
                              ),
                              //color: Color.fromARGB(255, 207, 207, 207),
                              child: InkWell(
                                onTap: () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    ProductsListPage.routeName,
                                    arguments: const ProductListPageArgs(
                                      isSelecting: true,
                                      orderType: OrderType.sale,
                                    ),
                                  );
                                  if (result == null &&
                                      result is! List<Product>) {
                                    return;
                                  }
                                  final orderItems = (result as List<Product>)
                                      .map((e) => OrderItemInput(
                                            product: e,
                                            quantity: 1,
                                            price: 0,
                                          ))
                                      .toList();
                                  setState(() {
                                    _orderInput.orderItems?.addAll(orderItems);
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        // <-- Icon
                                        Icons.add_box_outlined,
                                        size: 20.0,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          'Add Product',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ), // <--
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                        ListView.separated(
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _orderItems.length,
                          itemBuilder: (context, index) {
                            final _orderItem = _orderItems[index];
                            final product = _orderItems[index].product!;
                            return ProductCardPurchase(
                              type: "purchase",
                              product: product,
                              onAdd: () {
                                _onAdd(_orderItem);
                              },
                              onDelete: () {
                                setState(
                                  () {
                                    _orderItem.quantity == 1
                                        ? _orderInput.orderItems
                                            ?.removeAt(index)
                                        : _orderItem.quantity -= 1;
                                  },
                                );
                              },
                              productQuantity: _orderItem.quantity,
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const Divider(color: Colors.transparent);
                          },
                        ),
                      ],
                    ),
            ),
            const Divider(color: Colors.transparent),
            SizedBox(
              width: 400,
              child: SlidableButton(
                  width: double.maxFinite,
                  buttonWidth: 80.0,
                  color: Colors.green,
                  isRestart: true,
                  buttonColor: Colors.white24,
                  dismissible: false,
                  label: const Center(
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Swipe to continue",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  height: 80,
                  onChanged: (position) {
                    if (position == SlidableButtonPosition.right) {
                      if (_orderItems.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              "Please select products before continuing",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.pushNamed(
                        context,
                        CheckoutPage.routeName,
                        arguments: CheckoutPageArgs(
                          invoiceType: OrderType.sale,
                          orderInput: _orderInput,
                        ),
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

  ///
  Future<void> _searchProductByBarcode() async {
    locator<GlobalServices>().showBottomSheetLoader();
    final barcode = await FlutterBarcodeScanner.scanBarcode(
      "#000000",
      "Cancel",
      false,
      ScanMode.BARCODE,
    );
    const _type = FeedbackType.success;
    Vibrate.feedback(_type);
    // await _audioCache.play('audio/beep.mp3');
    try {
      /// Fetch product by barcode
      final res = await const ProductService().getProductByBarcode(barcode);
      final product = Product.fromMap(res.data['inventory']);
      final order = OrderItemInput(product: product, quantity: 1, price: 0);
      final hasProduct =
          _orderInput.orderItems?.any((e) => e.product?.id == product.id);

      /// Check if product already exists
      if (hasProduct ?? false) {
        final i = _orderInput.orderItems
            ?.indexWhere((e) => e.product?.id == product.id);

        /// Increase quantity if product already exists
        setState(() {
          _orderInput.orderItems![i!].quantity += 1;
        });
      } else {
        setState(() {
          _orderInput.orderItems?.add(order);
        });
      }
    } catch (_) {}
    Navigator.pop(context);
  }
}
