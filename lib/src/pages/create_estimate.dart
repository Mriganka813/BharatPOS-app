import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/pages/search_result.dart';
import 'package:slidable_button/slidable_button.dart';

import '../models/product.dart';
import '../services/LocalDatabase.dart';
import '../services/global.dart';
import '../services/locator.dart';
import '../services/product.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/product_card_horizontal.dart';
import 'checkout.dart';
import 'create_sale.dart';
class EstimateBillingPageArgs {
  final Order? order;
  // final List<OrderItemInput>? editOrders;
  // final id;

  EstimateBillingPageArgs({this.order});
}
class CreateEstimate extends StatefulWidget {
  CreateEstimate({Key? key, this.args}) : super(key: key);
  static const routeName = '/create_estimate';

  EstimateBillingPageArgs? args;

  @override
  State<CreateEstimate> createState() => _CreateEstimateState();
}

class _CreateEstimateState extends State<CreateEstimate> {
  bool isLoading = false;
  late Order _Order;
  List<OrderItemInput>? newAddedItems = [];
  List<Product> Kotlist = [];

  @override
  void initState() {
    super.initState();
    // _audioCache = AudioCache(
    //   fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    // );

    // _Order = Order(
    //   id: widget.args == null ? 0 : widget.args?.id,
    //   orderItems: widget.args == null ? [] : widget.args?.editOrders,
    // );
    _Order = (widget.args == null ? Order(id: 0, orderItems: []): widget.args?.order)!;
    print("line 53 in create estimate.dart");
    print(_Order.businessName);
    // print(_Order.orderItems?[0].product?.name);

    init();
  }

  List<String> sellingPriceListForShowinDiscountTextBOX = [];

  void init() {
    _Order.orderItems!.forEach((element) {
      sellingPriceListForShowinDiscountTextBOX
          .add(element.product!.baseSellingPriceGst!);
    });
  }

  void _onAdd(OrderItemInput orderItem) {
    final qty = orderItem.quantity + 1;
    double discountForOneItem =
        double.parse(orderItem.discountAmt) / orderItem.quantity;
    orderItem.discountAmt =
        (double.parse(orderItem.discountAmt) + discountForOneItem)
            .toStringAsFixed(2);
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
          _Order.orderItems?.any((e) => e.product?.id == product.id);

      /// Check if product already exists
      if (hasProduct ?? false) {
        final i =
            _Order.orderItems?.indexWhere((e) => e.product?.id == product.id);

        /// Increase quantity if product already exists
        setState(() {
          _Order.orderItems![i!].quantity += 1;
        });
      } else {
        setState(() {
          _Order.orderItems?.add(order);
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

  void OnDelete(OrderItemInput _orderItem, index) {
    double discountForOneItem =
        double.parse(_orderItem.discountAmt) / _orderItem.quantity;
    _orderItem.discountAmt =
        (double.parse(_orderItem.discountAmt) - discountForOneItem)
            .toStringAsFixed(2);
    setState(
      () {
        _orderItem.quantity == 1
            ? _Order.orderItems?.removeAt(index)
            : _orderItem.quantity -= 1;
      },
    );
  }

  void _onAddManually(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      SearchProductListScreen.routeName,
      arguments: ProductListPageArgs(
          isSelecting: true,
          orderType: OrderType.estimate,
          productlist: _Order.orderItems!),
    );
    if (result == null && result is! List<Product>) {
      return;
    }

    var temp = result as List<Product>;

    temp.forEach((element) {
      sellingPriceListForShowinDiscountTextBOX
          .add(element.sellingPrice.toString());
    });

    Kotlist.addAll(temp);

    var tempMap = CountNoOfitemIsList(temp);
    final orderItems = temp
        .map((e) => OrderItemInput(
              product: e,
              quantity: tempMap["${e.id}"].toDouble(),
              price: 0,
            ))
        .toList();

    orderItems.forEach((element) {
      sellingPriceListForShowinDiscountTextBOX
          .add(element.product!.sellingPrice.toString());
    });

    var tempOrderitems = _Order.orderItems;

    for (int i = 0; i < tempOrderitems!.length; i++) {
      for (int j = 0; j < orderItems.length; j++) {
        if (tempOrderitems[i].product!.id == orderItems[j].product!.id) {
          tempOrderitems[i].product!.quantity =
              tempOrderitems[i].product!.quantity! - orderItems[j].quantity;
          tempOrderitems[i].quantity =
              tempOrderitems[i].quantity + orderItems[j].quantity;
          orderItems.removeAt(j);
        }
      }
    }

    _Order.orderItems = tempOrderitems;

    setState(() {
      _Order.orderItems?.addAll(orderItems);
      newAddedItems!.addAll(orderItems);
    });
  }

  void showaddDiscountDialouge(
      double basesellingprice, List<OrderItemInput> _orderItems, int index) {
    final _orderItem = _orderItems[index];

    double discount = double.parse(_orderItem.discountAmt);
    final product = _orderItems[index].product!;
    showDialog(
        useSafeArea: true,
        useRootNavigator: true,
        context: context,
        builder: (ctx) {
          String? localSellingPrice;
          String? discountedPrice;

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AlertDialog(
                content: Column(
                  children: [
                    Text(
                      "Discount",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                        inputType: TextInputType.number,
                        onChanged: (val) {
                          localSellingPrice = val;
                        },
                        hintText:
                            'Enter Taxable Value   (${_orderItem.product!.baseSellingPriceGst != "null" ? basesellingprice + discount : sellingPriceListForShowinDiscountTextBOX[index]})'),
                    _orderItem.product!.baseSellingPriceGst != "null"
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('or'),
                          )
                        : SizedBox.shrink(),
                    _orderItem.product!.baseSellingPriceGst != "null"
                        ? CustomTextField(
                            inputType: TextInputType.number,
                            onChanged: (val) {
                              discountedPrice = val;
                            },
                            hintText:
                                'Enter total value   (${sellingPriceListForShowinDiscountTextBOX[index]})',
                            validator: (val) {
                              if (val!.isNotEmpty &&
                                  localSellingPrice!.isNotEmpty) {
                                return 'Do not fill both fields';
                              }
                              return null;
                            },
                          )
                        : SizedBox.shrink(),
                  ],
                ),
                actions: [
                  Center(
                    child: CustomButton(
                        title: 'Submit',
                        onTap: () {
                          if (localSellingPrice != null) {
                            print(localSellingPrice);
                            print(discountedPrice);
                            if (_orderItem.product!.baseSellingPriceGst ==
                                "null") {
                              discount = (_orderItem.product!.sellingPrice! +
                                      double.parse(_orderItem.discountAmt) -
                                      double.parse(localSellingPrice!)
                                          .toDouble()) *
                                  _orderItem.quantity;
                            } else {
                              discount = (double.parse(_orderItem
                                          .product!.baseSellingPriceGst!) +
                                      double.parse(_orderItem.discountAmt) -
                                      double.parse(localSellingPrice!)
                                          .toDouble()) *
                                  _orderItem.quantity;
                            }
                            _orderItems[index].discountAmt =
                                discount.toStringAsFixed(2);
                            setState(() {});
                          }

                          if (localSellingPrice != null &&
                              localSellingPrice!.isNotEmpty) {
                            _onSubtotalChange(product, localSellingPrice);
                            setState(() {});
                          } else if (discountedPrice != null) {
                            print('s$discountedPrice');

                            double realBaseSellingPrice = double.parse(
                                _orderItem.product!.baseSellingPriceGst!);

                            _onTotalChange(product, discountedPrice);
                            print(
                                "realbase selling price=${realBaseSellingPrice}");
                            print("discount=${discount}");
                            discount = (realBaseSellingPrice +
                                    discount -
                                    double.parse(_orderItem
                                        .product!.baseSellingPriceGst!)) *
                                _orderItem.quantity;
                            _orderItems[index].discountAmt =
                                discount.toStringAsFixed(2);

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
  }

  @override
  Widget build(BuildContext context) {
    final _orderItems = _Order.orderItems ?? [];
    return Scaffold(
        appBar: AppBar(
          title: const Text('Estimates'),
          centerTitle: true,
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
                                separatorBuilder: (context, index) {
                                  return const Divider(
                                      color: Colors.transparent);
                                },
                                itemBuilder: (context, index) {
                                  var basesellingprice = 0.0;
                                  if (_orderItems[index].product!.baseSellingPriceGst != null && _orderItems[index].product!.baseSellingPriceGst != "null")
                                    basesellingprice = double.parse(_orderItems[index].product!.baseSellingPriceGst!);
                                  return GestureDetector(
                                    onLongPress: () {
                                      showaddDiscountDialouge(basesellingprice, _orderItems, index);
                                    },
                                    child: ProductCardPurchase(
                                      type: "estimate",
                                      product: _orderItems[index].product!,
                                      discount: _orderItems[index].discountAmt,
                                      onAdd: () {
                                        //TODO: to check this function for misbehavior of onAdd onRemove in estimates page
                                        Kotlist.add(_Order.orderItems![index].product!);
                                        _onAdd(_orderItems[index]);
                                      },
                                      onDelete: () {
                                        OnDelete(_orderItems[index], index);
                                      },
                                      productQuantity: _orderItems[index].quantity,
                                    ),
                                  );
                                },
                              )),
                    const Divider(color: Colors.transparent),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomButton(
                          title: "Add manually",
                          onTap: () async {
                            _onAddManually(context);
                          },
                        ),
                        CustomButton(
                          title: "Scan barcode",
                          onTap: () async {
                            _searchProductByBarcode();
                          },
                          type: ButtonType.outlined,
                        ),
                      ],
                    ),
                    const Divider(color: Color.fromRGBO(0, 0, 0, 0)),
                    HorizontalSlidableButton(
                      width: double.maxFinite,
                      buttonWidth: 50,
                      color: Colors.green,
                      isRestart: true,
                      buttonColor: Colors.green,
                      dismissible: false,
                      label: const Center(
                          child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.black,
                        ),
                      )),
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
                          if (_orderItems.isNotEmpty) {
                            print("line 499 in create estimate");
                            print(_Order.businessName);
                            Navigator.pushNamed(
                              context,
                              CheckoutPage.routeName,
                              arguments: CheckoutPageArgs(
                                  invoiceType: OrderType.estimate,
                                  orderId: "0",
                                  order: _Order),
                            );
                          } else {
                            locator<GlobalServices>()
                                .errorSnackBar("No Products added");
                          }
                        }
                      },
                    ),
                  ],
                ),
              ));
  }
}
