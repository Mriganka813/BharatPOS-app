import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopos/src/models/product.dart';

class ProductCardHorizontal extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? reduceQuantity;
  final VoidCallback? addQuantity;
  final int selectQuantity;
  final bool? isSelecting;
  const ProductCardHorizontal({
    Key? key,
    required this.product,
    required this.onDelete,
    required this.onEdit,
    this.isSelecting = false,
    this.addQuantity,
    this.reduceQuantity,
    this.selectQuantity = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: product.image != null
                      ? CachedNetworkImage(
                          imageUrl: product.image!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset('assets/images/image_placeholder.png'),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2.25,
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        child: Text(
                          product.name ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    ),
                    Divider(color: Colors.black54),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Available'),
                        Text('${product.quantity}'),
                      ],
                    ),
                    Visibility(
                      visible: product.gstRate != "null",
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Price'),
                              Text('₹ ${product.baseSellingPriceGst}'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('GST @${product.gstRate}%'),
                              Text('₹ ${product.saleigst}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Net Sell Price'),
                        Text('₹ ${product.sellingPrice}'),
                      ],
                    ),

                    // previous version (will use after sometime)
                    // Text('${product.quantity} pcs'),
                    // // const SizedBox(height: 2),
                    // // Text(color),
                    // const SizedBox(height: 2),
                    // product.purchasePrice != 0
                    //     ? Text('Purchase Price ${product.purchasePrice}')
                    //     : Container(),
                    // const SizedBox(height: 2),
                    // Text('Sale Price ${product.sellingPrice}'),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PopupMenuButton<int>(
                    child: const Icon(Icons.more_vert_rounded),
                    onSelected: (int e) {
                      if (e == 0) {
                        onEdit();
                      } else if (e == 1) {
                        onDelete();
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuItem<int>>[
                        const PopupMenuItem<int>(
                          value: 0,
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<int>(
                          value: 1,
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      ];
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ProductCardPurchase extends StatelessWidget {
  final Product product;
  final int productQuantity;
  final VoidCallback onAdd;
  final VoidCallback onDelete;
  final String? type;
  const ProductCardPurchase(
      {Key? key,
      required this.product,
      required this.onAdd,
      required this.productQuantity,
      required this.onDelete,
      this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double baseSellingPrice = 0;
    double Sellinggstvalue = 0;
    int SellingPrice = 0;

    double basePurchasePrice = 0;
    double Purchasegstvalue = 0;
    int PurchasePrice = 0;

    if (type == "sale") {
      if (product.gstRate != "null") {
        baseSellingPrice = double.parse(
            (double.parse(product.baseSellingPriceGst!) * productQuantity)
                .toStringAsFixed(2));
        Sellinggstvalue = double.parse(
            (double.parse(product.saleigst!) * productQuantity)
                .toStringAsFixed(2));
      }
      if (product.gstRate == "null") {
        baseSellingPrice = double.parse((product.sellingPrice * productQuantity)
            .toDouble()
            .toStringAsFixed(2));
      }
      SellingPrice = product.sellingPrice * productQuantity;
    }

    if (type == "purchase") {
      if (product.purchasePrice != 0 && product.gstRate != "null") {
        basePurchasePrice = double.parse(
            (double.parse(product.basePurchasePriceGst!) * productQuantity)
                .toStringAsFixed(2));
        Purchasegstvalue = double.parse(
            (double.parse(product.purchaseigst!) * productQuantity)
                .toStringAsFixed(2));
      } else {
        basePurchasePrice = double.parse(
            (product.purchasePrice * productQuantity)
                .toDouble()
                .toStringAsFixed(2));
      }
      PurchasePrice = product.purchasePrice * productQuantity;
    }
    return SizedBox(
      height: 200,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: product.image != null
                        ? Container(
                            height: 120,
                            child: CachedNetworkImage(
                              imageUrl: product.image!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset('assets/images/image_placeholder.png'),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          onAdd();
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text(
                          "$productQuantity",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          onDelete();
                        },
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                      ),
                    ],
                  ),
                  // Text('Available : ${product.quantity ?? 0}'),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2.25,
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            child: Text(
                              product.name ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.black54,
                    ),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Item Subtotal'),
                        type == "sale"
                            ? Text('₹ ${baseSellingPrice}')
                            : Text('₹ ${basePurchasePrice}'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            'Tax GST @${product.gstRate == "null" ? "0" : product.gstRate}%'),
                        type == "sale"
                            ? Text('₹ ${Sellinggstvalue}')
                            : Text('₹ ${Purchasegstvalue}'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount @0%'),
                        Text('₹ 0'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(
                      color: Colors.black54,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Item Total'),
                        type == "sale"
                            ? Text(
                                '₹ ${SellingPrice}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            : Text(
                                '₹ ${PurchasePrice}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                      ],
                    ),
                    // const SizedBox(height: 10),

                    // // const SizedBox(height: 2),
                    // // Text(color),
                    // const SizedBox(height: 2),
                    // Text('Purchase Price ${product.purchasePrice}'),
                    // const SizedBox(height: 2),
                    // Text('Sale Price ${product.sellingPrice}'),
                    // const SizedBox(height: 2),
                    // Text('Qty ${product.quantity ?? 0}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
