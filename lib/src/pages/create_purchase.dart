import 'package:flutter/material.dart';
import 'package:shopos/src/models/input/order_input.dart';
import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/pages/create_product.dart';
import 'package:shopos/src/pages/products_list.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/product_card_horizontal.dart';
import 'package:slidable_button/slidable_button.dart';

class CreatePurchase extends StatefulWidget {
  static const routeName = '/create_purchase';
  const CreatePurchase({Key? key}) : super(key: key);

  @override
  State<CreatePurchase> createState() => _CreatePurchaseState();
}

class _CreatePurchaseState extends State<CreatePurchase> {
  late OrderInput _orderInput;

  @override
  void initState() {
    super.initState();
    _orderInput = OrderInput(
      orderItems: [],
    );
  }

  void _onAdd(OrderItemInput orderItem) {
    setState(() {
      orderItem.quantity += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _orderItems = _orderInput.orderItems ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: _orderItems.isEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
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
                                  orderType: OrderType.purchase,
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
                                _orderInput.orderItems = orderItems;
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
                                    'Add Product',
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
                        Container(
                          height: 230,
                          width: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromARGB(255, 220, 220, 220),
                          ),
                          //color: Color.fromARGB(255, 207, 207, 207),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, CreateProduct.routeName);
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
                                    'Create Product',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600),
                                  ), // <--
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
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
                                        orderType: OrderType.purchase,
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
                                      _orderInput.orderItems = orderItems;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                              Container(
                                height: 50,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Color.fromARGB(255, 220, 220, 220),
                                ),
                                //color: Color.fromARGB(255, 207, 207, 207),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, CreateProduct.routeName);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                            'Create Product',
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
                              )
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
                        invoiceType: OrderType.purchase,
                        orderInput: _orderInput,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
