import 'package:flutter/material.dart';
import 'package:magicstep/src/config/colors.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';
import 'package:magicstep/src/widgets/product_card_horizontal.dart';

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
        floatingActionButton: Container(
          margin: const EdgeInsets.only(
            right: 10,
            bottom: 20,
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/create-product');
            },
            backgroundColor: ColorsConst.primaryColor,
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          children: [
            Text(
              "Products List",
              style: Theme.of(context).textTheme.headline6,
            ),
            const Divider(color: Colors.transparent),
            const CustomTextField(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search',
            ),
            const Divider(color: Colors.transparent),
            ListView.separated(
              physics: const ClampingScrollPhysics(),
              itemCount: 4,
              shrinkWrap: true,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 5);
              },
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
