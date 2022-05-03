import 'package:flutter/material.dart';
import 'package:magicstep/src/config/colors.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';

class ProductsListPage extends StatelessWidget {
  const ProductsListPage({Key? key}) : super(key: key);

  ///
  static const routeName = '/products-list';
  static const imgAddress =
      'https://png.pngitem.com/pimgs/s/127-1273781_samsung-9f-hd-png-download.png';

  ///
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: ColorsConst.primaryColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          children: [
            const CustomTextField(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search',
            ),
            ListView.builder(
              physics: const ClampingScrollPhysics(),
              itemCount: 4,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return const ProductCardHorizontal(
                  img: imgAddress,
                  color: 'Black',
                  productName: 'Samsung M52',
                  salePrice: '200',
                  purchasePrice: '200',
                  quantity: '10',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
