import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:provider/provider.dart';
import 'package:shopos/src/models/KotModel.dart';
import 'package:shopos/src/models/input/order_input.dart';

import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/pages/billing_list.dart';
import 'package:shopos/src/pages/checkout.dart';
// import 'package:shopos/src/pages/products_list.dart';
import 'package:shopos/src/pages/search_result.dart';
import 'package:shopos/src/provider/billing_order.dart';
import 'package:shopos/src/services/LocalDatabase.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';
import 'package:shopos/src/widgets/product_card_horizontal.dart';
import 'package:slidable_button/slidable_button.dart';

import '../services/product.dart';

class BillingPageArgs {
  final String? orderId;
  final List<OrderItemInput>? editOrders;
  final id;

  BillingPageArgs({this.orderId, this.editOrders, this.id});
}

class CreateSale extends StatefulWidget {
  static const routeName = '/create_sale';
  CreateSale({Key? key, this.args}) : super(key: key);

  BillingPageArgs? args;

  @override
  State<CreateSale> createState() => _CreateSaleState();
}

class _CreateSaleState extends State<CreateSale> {
  late OrderInput _orderInput;
  late final AudioCache _audioCache;
  List<OrderItemInput>? newAddedItems = [];
  List<Product> Kotlist = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // _audioCache = AudioCache(
    //   fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    // );

    _orderInput = OrderInput(
      id: widget.args!.id,
      orderItems: widget.args == null ? [] : widget.args?.editOrders,
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

  _onSubtotalChange(Product product, String? localSellingPrice) async {
    product.baseSellingPriceGst = localSellingPrice;
    double newGStRate = (double.parse(product.baseSellingPriceGst!) *
        double.parse(product.gstRate == 'null' ? '0' : product.gstRate!) /
        100);
    product.saleigst = newGStRate.toStringAsFixed(2);

    product.salecgst = (newGStRate / 2).toStringAsFixed(2);
    print(product.salecgst);

    product.salesgst = (newGStRate / 2).toStringAsFixed(2);
    print(product.salesgst);

    product.sellingPrice =
        double.parse(product.baseSellingPriceGst!.toString()) + newGStRate;
    print(product.sellingPrice);
  }

  _onTotalChange(Product product, String? discountedPrice) {
    product.sellingPrice = double.parse(discountedPrice!);
    print(product.gstRate);

    double newBasePrice = (product.sellingPrice! * 100.0) /
        (100.0 +
            double.parse(product.gstRate == 'null' ? '0.0' : product.gstRate!));

    print(newBasePrice);

    product.baseSellingPriceGst = newBasePrice.toString();

    double newGst = product.sellingPrice! - newBasePrice;

    print(newGst);

    product.saleigst = newGst.toStringAsFixed(2);

    product.salecgst = (newGst / 2).toStringAsFixed(2);
    print(product.salecgst);

    product.salesgst = (newGst / 2).toStringAsFixed(2);
    print(product.salesgst);
  }

  void insertToDatabase(Billing provider) async {
    int id = await DatabaseHelper()
        .InsertOrderInput(_orderInput, provider, newAddedItems!);
    List<KotModel> kotItemlist = [];
    var tempMap = CountNoOfitemIsList(Kotlist);
    Kotlist.forEach((element) {
      var model = KotModel(id, element.name!, tempMap['${element.id}'], "no");
      kotItemlist.add(model);
    });

    DatabaseHelper().insertKot(kotItemlist);
  }

  @override
  Widget build(BuildContext context) {
    final _orderItems = _orderInput.orderItems ?? [];
    final provider = Provider.of<Billing>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Expanded(
                    child: _orderItems.isEmpty
                        ? const Center(
                            child: Text(
                              'No products added yet',
                            ),
                          )
                        : ListView.separated(
                            physics: const ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _orderItems.length,
                            itemBuilder: (context, index) {
                              final _orderItem = _orderItems[index];
                              final product = _orderItems[index].product!;

                              return GestureDetector(
                                onLongPress: () {
                                  showDialog(
                                      useSafeArea: true,
                                      useRootNavigator: true,
                                      context: context,
                                      builder: (ctx) {
                                        String? localSellingPrice;
                                        String? discountedPrice;

                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AlertDialog(
                                              content: Column(
                                                children: [
                                                  CustomTextField(
                                                    inputType:
                                                        TextInputType.number,
                                                    onChanged: (val) {
                                                      localSellingPrice = val;
                                                    },
                                                    hintText: 'Enter subtotal',
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text('or'),
                                                  ),
                                                  CustomTextField(
                                                    inputType:
                                                        TextInputType.number,
                                                    onChanged: (val) {
                                                      discountedPrice = val;
                                                    },
                                                    hintText: 'Enter total',
                                                    validator: (val) {
                                                      if (val!.isNotEmpty &&
                                                          localSellingPrice!
                                                              .isNotEmpty) {
                                                        return 'Do not fill both fields';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                Center(
                                                  child: CustomButton(
                                                      title: 'Submit',
                                                      onTap: () {
                                                        print(
                                                            localSellingPrice);
                                                        print(discountedPrice);

                                                        // if ((localSellingPrice !=
                                                        //             null ||
                                                        //         localSellingPrice!
                                                        //             .isNotEmpty) &&
                                                        //     (discountedPrice != null ||
                                                        //         discountedPrice!
                                                        //             .isNotEmpty)) {
                                                        //   return;
                                                        // }

                                                        if (localSellingPrice !=
                                                                null &&
                                                            localSellingPrice!
                                                                .isNotEmpty) {
                                                          _onSubtotalChange(
                                                              product,
                                                              localSellingPrice);
                                                          setState(() {});
                                                        } else if (discountedPrice !=
                                                            null) {
                                                          print(
                                                              's$discountedPrice');

                                                          _onTotalChange(
                                                              product,
                                                              discountedPrice);

                                                          setState(() {});
                                                        }

                                                        Navigator.of(ctx).pop();
                                                      }),
                                                )
                                              ],
                                            ),
                                          ],
                                        );
                                      });
                                },
                                child: ProductCardPurchase(
                                  type: "sale",
                                  product: product,
                                  onAdd: () {
                                    Kotlist.add(_orderInput
                                        .orderItems![index].product!);
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

                                
                                      for (int i = 0; i < Kotlist.length; i++) {
                                        if (Kotlist[i].id ==
                                            _orderInput.orderItems![index]
                                                .product!.id) {
                                          Kotlist.removeAt(i);
                                          break;
                                        }
                                      }

                                          if (widget.args!.orderId == null)
                                          
                                    setState(() {});
                                  },
                                  productQuantity: _orderItem.quantity,
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const Divider(color: Colors.transparent);
                            },
                          ),
                  ),
                  const Divider(color: Colors.transparent),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        title: "Add manually",
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            SearchProductListScreen.routeName,
                            arguments: ProductListPageArgs(
                                isSelecting: true,
                                orderType: OrderType.sale,
                                productlist: _orderInput.orderItems!),
                          );
                          if (result == null && result is! List<Product>) {
                            return;
                          }

                          var temp = result as List<Product>;

                          Kotlist.addAll(temp);

                          var tempMap = CountNoOfitemIsList(temp);
                          final orderItems = temp
                              .map((e) => OrderItemInput(
                                    product: e,
                                    quantity: tempMap["${e.id}"],
                                    price: 0,
                                  ))
                              .toList();

                          var tempOrderitems = _orderInput.orderItems;

                          for (int i = 0; i < tempOrderitems!.length; i++) {
                            for (int j = 0; j < orderItems.length; j++) {
                              if (tempOrderitems[i].product!.id ==
                                  orderItems[j].product!.id) {
                                tempOrderitems[i].product!.quantity =
                                    tempOrderitems[i].product!.quantity! -
                                        orderItems[j].quantity;
                                tempOrderitems[i].quantity =
                                    tempOrderitems[i].quantity +
                                        orderItems[j].quantity;
                                orderItems.removeAt(j);
                              }
                            }
                          }

                          _orderInput.orderItems = tempOrderitems;

                          setState(() {
                            _orderInput.orderItems?.addAll(orderItems);
                            newAddedItems!.addAll(orderItems);
                          });
                        },
                      ),
                      // const VerticalDivider(
                      //   color: Colors.transparent,
                      //   width: 10,
                      // ),
                      CustomButton(
                        title: "Scan barcode",
                        onTap: () async {
                          _searchProductByBarcode();
                        },
                        type: ButtonType.outlined,
                      ),
                    ],
                  ),
                  const Divider(color: Colors.transparent),
                  HorizontalSlidableButton(
                    width: double.maxFinite,
                    buttonWidth: 100.0,
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    height: 50,
                    onChanged: (position) {
                      if (position == SlidableButtonPosition.end) {
                        // if (_orderItems.isEmpty) {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(
                        //       backgroundColor: Colors.red,
                        //       content: Text(
                        //         "Please select products before continuing",
                        //         style: TextStyle(color: Colors.white),
                        //       ),
                        //     ),
                        //   );
                        //   return;
                        // }

                        if (_orderItems.isNotEmpty) {
                          print('orderid: ${widget.args?.orderId}');

                          insertToDatabase(provider);
                        }

                        Navigator.pushNamed(
                            context, BillingListScreen.routeName,
                            arguments: OrderType.sale);

                        // Navigator.pushNamed(
                        //   context,
                        //   CheckoutPage.routeName,
                        //   arguments: CheckoutPageArgs(
                        //     invoiceType: OrderType.sale,
                        //     orderInput: _orderInput,
                        //   ),
                        // );
                      }
                    },
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
    //await _audioCache.play('audio/beep.mp3');
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

  Map CountNoOfitemIsList(List<Product> temp) {
    var tempMap = {};

    for (int i = 0; i < temp.length; i++) {
      int count = 1;
      if (!tempMap.containsKey("${temp[i].id}")) {
        for (int j = i + 1; j < temp.length; j++) {
          if (temp[i].id == temp[j].id) {
            count++;
            print("count =$count");
          }
        }
        tempMap["${temp[i].id}"] = count;
      }
    }

    for (int i = 0; i < temp.length; i++) {
      for (int j = i + 1; j < temp.length; j++) {
        if (temp[i].id == temp[j].id) {
          temp.removeAt(j);
          j--;
        }
      }
    }

    return tempMap;
  }
}
