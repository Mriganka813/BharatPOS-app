import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:magicstep/src/models/product.dart';

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? "",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 2),
                    Text('${product.quantity} pcs'),
                    // const SizedBox(height: 2),
                    // Text(color),
                    const SizedBox(height: 2),
                    Text('Purchase Price ${product.purchasePrice}'),
                    const SizedBox(height: 2),
                    Text('Sale Price ${product.sellingPrice}'),
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
  const ProductCardPurchase({
    Key? key,
    required this.product,
    required this.onAdd,
    required this.productQuantity,
    required this.onDelete,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? "",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 10),
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
                          child: Text("$productQuantity"),
                        ),
                        IconButton(
                          onPressed: () {
                            onDelete();
                          },
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // const SizedBox(height: 2),
                    // Text(color),
                    const SizedBox(height: 2),
                    Text('Purchase Price ${product.purchasePrice}'),
                    const SizedBox(height: 2),
                    Text('Sale Price ${product.sellingPrice}'),
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
