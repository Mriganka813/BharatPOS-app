import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:magicstep/src/config/colors.dart';
import 'package:magicstep/src/models/product.dart';
import 'package:magicstep/src/widgets/custom_drop_down.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/invoice_template.dart';

class CheckoutPage extends StatefulWidget {
  final List<Product> products;
  static const routeName = '/checkout';
  const CheckoutPage({
    Key? key,
    this.products = const [],
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  ///
  void viewPdf() async {
    final targetPath = await getTemporaryDirectory();
    const targetFileName = "example_pdf_file";
    final htmlContent = invoiceTemplate(
      companyName: "Sharma city mart",
      products: widget.products,
      headers: ["ID", "Name", "Qty", "Price", "Amt"],
      total: totalPrice(),
    );
    final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
      htmlContent,
      targetPath.path,
      targetFileName,
    );
    OpenFile.open(generatedPdfFile.path);
  }

  ///
  String totalPrice() {
    return widget.products.fold(0, (acc, prod) {
      final price = (prod.purchaseQuantity * (prod.sellingPrice ?? 0));
      return (acc as int) + price;
    }).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("${widget.products.length} products"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Center(
              child: Text(
                totalPrice(),
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 10.0,
          bottom: 20,
          left: 20,
          right: 30,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomTextField(
                suffixIcon: Icon(Icons.add_circle_outline_rounded),
              ),
              const Divider(color: Colors.transparent),
              CustomDropDownField(
                items: const <String>[
                  "Cash",
                  "Credit",
                  "Bank Transfer",
                ],
                onSelected: (e) {},
                hintText: "Select mode of payment",
              ),
              const Divider(color: Colors.transparent),
              const Text("Amount Recieved"),
              const Divider(color: Colors.transparent),
              CustomTextField(
                initialValue: totalPrice(),
                inputType: TextInputType.phone,
                onSave: (e) {},
              ),
              const Divider(color: Colors.transparent),
              const Text("Change/Balance"),
              const Divider(color: Colors.transparent),
              CustomTextField(
                inputType: TextInputType.phone,
                initialValue: "0",
                onSave: (e) {},
              ),
              const Spacer(),
              Row(
                children: [
                  TextButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: ColorsConst.primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      viewPdf();
                    },
                    child: const Text(
                      "Share",
                      style: TextStyle(
                        color: ColorsConst.primaryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: ColorsConst.primaryColor,
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
