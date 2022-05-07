import 'package:flutter/material.dart';
import 'package:magicstep/src/widgets/custom_button.dart';

class CreatePurchasePage extends StatefulWidget {
  static const routeName = '/create_purchase';
  const CreatePurchasePage({Key? key}) : super(key: key);

  @override
  State<CreatePurchasePage> createState() => _CreatePurchasePageState();
}

class _CreatePurchasePageState extends State<CreatePurchasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    title: "Add manually",
                    onTap: () async {
                      final result = await Navigator.pushNamed(
                          context, CreatePurchasePage.routeName,
                          arguments: true);
                      if (result == null) {
                        return;
                      }
                    },
                  ),
                ),
                const VerticalDivider(color: Colors.transparent),
                Expanded(
                  child: CustomButton(
                    title: "Scan barcode",
                    onTap: () {},
                    type: ButtonType.outlined,
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
