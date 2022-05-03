import 'package:flutter/material.dart';
import 'package:magicstep/src/pages/products_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const routeName = '/home';
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GridView(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              padding: const EdgeInsets.all(10),
              children: [
                HomeCard(
                  icon: const Icon(Icons.bookmark),
                  title: "Products",
                  onTap: () {
                    Navigator.pushNamed(context, ProductsListPage.routeName);
                  },
                ),
                HomeCard(
                  icon: const Icon(Icons.bookmark),
                  title: "Products",
                  onTap: () {},
                ),
                HomeCard(
                  icon: const Icon(Icons.bookmark),
                  title: "Products",
                  onTap: () {},
                ),
                HomeCard(
                  icon: const Icon(Icons.bookmark),
                  title: "Products",
                  onTap: () {},
                ),
              ],
            ),
            const Text("Sharma City mart"),
            const Spacer(),
            const Text("Create Invoice"),
            Row(
              children: const [
                Expanded(
                  child: Card(
                    child: Icon(Icons.arrow_circle_up_rounded),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Icon(Icons.arrow_circle_down_rounded),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  final String title;
  const HomeCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: icon,
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
