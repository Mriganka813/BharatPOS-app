import 'package:flutter/material.dart';
import 'package:magicstep/src/blocs/checkout/checkout_cubit.dart';
import 'package:magicstep/src/config/colors.dart';
import 'package:magicstep/src/models/input/order_input.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_drop_down.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';

enum OrderType { purchase, sale }

class CheckoutPageArgs {
  final OrderType invoiceType;
  final OrderInput orderInput;
  const CheckoutPageArgs({
    required this.invoiceType,
    required this.orderInput,
  });
}

class CheckoutPage extends StatefulWidget {
  final CheckoutPageArgs args;
  static const routeName = '/checkout';
  const CheckoutPage({
    Key? key,
    required this.args,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  late CheckoutCubit _checkoutCubit;
  @override
  void initState() {
    super.initState();
    _checkoutCubit = CheckoutCubit();
  }

  @override
  void dispose() {
    _checkoutCubit.close();
    super.dispose();
  }

  ///
  void viewPdf() async {
    // final targetPath = await getTemporaryDirectory();
    // const targetFileName = "example_pdf_file";
    // final htmlContent = invoiceTemplate(
    //   companyName: "Sharma city mart",
    //   products: ),
    //   headers: ["ID", "Name", "Qty", "Price", "Amt"],
    //   total: totalPrice(),
    // );
    // final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
    //   htmlContent,
    //   targetPath.path,
    //   targetFileName,
    // );
    // OpenFile.open(generatedPdfFile.path);
  }

  ///
  String totalPrice() {
    return "";
    // return widget.args.orderInput.orderItems?.fold(0, (acc, orderItem) {
    //   final price = (orderItem.quantity * (orderItem.price ?? 0));
    //   return (acc as int) + price;
    // }).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "${widget.args.orderInput.orderItems?.fold<int>(0, (acc, item) => item.quantity + acc)} products",
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Center(
              child: Text(
                "₹ ${totalPrice()}",
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
              CustomTextField(
                label: "Party",
                suffixIcon: const Icon(Icons.add_circle_outline_rounded),
                hintText: "Optional",
                validator: (e) => null,
              ),
              const Divider(color: Colors.transparent, height: 20),
              CustomDropDownField(
                items: const <String>[
                  "Cash",
                  "Credit",
                  "Bank Transfer",
                ],
                onSelected: (e) {
                  setState(() {
                    widget.args.orderInput.modeOfPayment = e;
                  });
                },
                hintText: "Mode of payment",
              ),
              const Divider(color: Colors.transparent, height: 30),
              const Text("Amount Recieved"),
              const Divider(color: Colors.transparent),
              Center(
                child: Text(
                  "₹ ${totalPrice()}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
              const Divider(color: Colors.transparent),
              const Spacer(),
              Row(
                children: [
                  CustomButton(
                    title: "Share",
                    onTap: () {},
                    type: ButtonType.outlined,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _formKey.currentState?.save();
                      if (_formKey.currentState?.validate() ?? false) {
                        viewPdf();
                      }
                      _checkoutCubit.createSalesOrder(widget.args.orderInput);
                    },
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
