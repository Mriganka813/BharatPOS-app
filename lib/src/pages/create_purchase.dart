import 'package:flutter/material.dart';

class CreatePurchase extends StatefulWidget {
  static const routeName = '/create_purchase';
  const CreatePurchase({Key? key}) : super(key: key);

  @override
  State<CreatePurchase> createState() => _CreatePurchaseState();
}

class _CreatePurchaseState extends State<CreatePurchase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBar(
        title: const Text("Purchase"),
      ),
    );
  }
}
