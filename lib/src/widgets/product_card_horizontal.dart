import 'package:flutter/material.dart';

class ProductCardHorizontal extends StatelessWidget {
  final String productName;
  final String img;
  final String quantity;
  final String color;
  final String purchasePrice;
  final String salePrice;

  const ProductCardHorizontal({
    Key? key,
    required this.color,
    required this.img,
    required this.productName,
    required this.purchasePrice,
    required this.quantity,
    required this.salePrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            img,
            height: 200,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 2),
                  Text('$quantity pcs'),
                  const SizedBox(height: 2),
                  Text(color),
                  const SizedBox(height: 2),
                  Text('Purchase Price $purchasePrice'),
                  const SizedBox(height: 2),
                  Text('Sale Price $salePrice'),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.more_vert),
            ),
          )
        ],
      ),
    );
  }
}
