import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:magicstep/src/blocs/checkout/checkout_cubit.dart';
import 'package:magicstep/src/config/colors.dart';
import 'package:magicstep/src/models/input/order_input.dart';
import 'package:magicstep/src/models/user.dart';
import 'package:magicstep/src/services/global.dart';
import 'package:magicstep/src/services/locator.dart';
import 'package:magicstep/src/services/user.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_drop_down.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';
import 'package:magicstep/src/widgets/invoice_template.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

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
  void _viewPdf(User user) async {
    final targetPath = await getTemporaryDirectory();
    const targetFileName = "example_pdf_file";
    final htmlContent = invoiceTemplate(
      companyName: user.businessName ?? "",
      order: widget.args.orderInput,
      headers: ["ID", "Name", "Qty", "Price", "Amt"],
      total: totalPrice() ?? "",
    );
    final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
      htmlContent,
      targetPath.path,
      targetFileName,
    );
    OpenFile.open(generatedPdfFile.path);
  }

  ///
  String? totalPrice() {
    return widget.args.orderInput.orderItems?.fold<int>(
      0,
      (acc, curr) {
        return (curr.quantity * (curr.product?.sellingPrice ?? 1)) + acc;
      },
    ).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: BlocListener<CheckoutCubit, CheckoutState>(
        bloc: _checkoutCubit,
        listener: (context, state) {
          if (state is CheckoutSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Order was created successfully',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
            Future.delayed(const Duration(milliseconds: 400), () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            });
          }
        },
        child: BlocBuilder<CheckoutCubit, CheckoutState>(
          bloc: _checkoutCubit,
          builder: (context, state) {
            if (state is CheckoutLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ColorsConst.primaryColor,
                  ),
                ),
              );
            }
            return Padding(
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
                      isLoading: true,
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
                          onTap: () {
                            _onTapShare();
                          },
                          type: ButtonType.outlined,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            _onTapSubmit();
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
            );
          },
        ),
      ),
    );
  }

  void _onTapShare() async {
    locator<GlobalServices>().showBottomSheetLoader();
    try {
      final res = await UserService.me();
      if ((res.statusCode ?? 400) < 300) {
        final user = User.fromMap(res.data['user']);
        _viewPdf(user);
      }
    } catch (err) {}
    Navigator.pop(context);
  }

  void _onTapSubmit() async {
    _formKey.currentState?.save();
    if (_formKey.currentState?.validate() ?? false) {
      widget.args.invoiceType == OrderType.purchase
          ? _checkoutCubit.createPurchaseOrder(widget.args.orderInput)
          : _checkoutCubit.createSalesOrder(widget.args.orderInput);
    }
  }
}
