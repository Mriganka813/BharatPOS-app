import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shopos/src/blocs/checkout/checkout_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/models/input/order_input.dart';
import 'package:shopos/src/models/user.dart';
import 'package:shopos/src/pages/create_party.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/services/party.dart';
import 'package:shopos/src/services/user.dart';
import 'package:shopos/src/utils.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_drop_down.dart';
import 'package:shopos/src/widgets/invoice_template.dart';
import 'package:whatsapp_share2/whatsapp_share2.dart';

import '../models/party.dart';

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
  late final TextEditingController _typeAheadController;

  ///
  @override
  void initState() {
    super.initState();
    _checkoutCubit = CheckoutCubit();
    _typeAheadController = TextEditingController();
  }

  @override
  void dispose() {
    _checkoutCubit.close();
    _typeAheadController.dispose();
    super.dispose();
  }

  ///
  void _viewPdf(User user) async {
    final targetPath = await getExternalCacheDirectories();
    const targetFileName = "example_pdf_file";
    final htmlContent = invoiceTemplate(
      date: DateTime.now(),
      companyName: user.businessName ?? "",
      order: widget.args.orderInput,
      user: user,
      headers: ["Name", "Qty", "Price", "Amt"],
      total: totalPrice() ?? "",
    );
    final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
      htmlContent,
      targetPath!.first.path,
      targetFileName,
    );
    final input = _typeAheadController.value.text.trim();
    if (input.length == 10 && int.tryParse(input) != null) {
      await WhatsappShare.shareFile(
        text: 'Invoice',
        phone: '91$input',
        filePath: [generatedPdfFile.path],
      );
      return;
    }

    final party = widget.args.orderInput.party;
    if (party == null) {
      final path = generatedPdfFile.path;
      await Share.shareFiles([path], mimeTypes: ['application/pdf']);
      return;
    }
    final isValidPhoneNumber = Utils.isValidPhoneNumber(party.phoneNumber);
    if (!isValidPhoneNumber) {
      locator<GlobalServices>()
          .infoSnackBar("Invalid phone number: ${party.phoneNumber ?? ""}");
      return;
    }
    await WhatsappShare.shareFile(
      text: 'Invoice',
      phone: '91${party.phoneNumber ?? ""}',
      filePath: [generatedPdfFile.path],
    );
  }

  Future<Iterable<Party>> _searchParties(String pattern) async {
    if (pattern.isEmpty) {
      return [];
    }
    final type =
        widget.args.invoiceType == OrderType.sale ? "customer" : "supplier";

    try {
      final response =
          await const PartyService().getSearch(pattern, type: type);
      final data = response.data['allParty'] as List<dynamic>;
      return data.map((e) => Party.fromMap(e));
    } catch (err) {
      log(err.toString());
      return [];
    }
  }

  ///
  String? totalPrice() {
    return widget.args.orderInput.orderItems?.fold<int>(
      0,
      (acc, curr) {
        if (widget.args.invoiceType == OrderType.purchase) {
          return (curr.quantity * (curr.product?.purchasePrice ?? 1)) + acc;
        }
        return (curr.quantity * (curr.product?.sellingPrice ?? 1)) + acc;
      },
    ).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    const Divider(color: Colors.transparent),
                    TypeAheadFormField<Party>(
                      validator: (value) {
                        final isEmpty = (value == null || value.isEmpty);
                        final isCredit =
                            widget.args.orderInput.modeOfPayment == "Credit";
                        if (isEmpty && isCredit) {
                          return "Please select a party for credit order";
                        }
                        return null;
                      },
                      debounceDuration: const Duration(milliseconds: 500),
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _typeAheadController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: "Party",
                          suffixIcon: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                CreatePartyPage.routeName,
                                arguments: widget.args.invoiceType ==
                                        OrderType.purchase
                                    ? 'customer'
                                    : 'supplier',
                              );
                            },
                            child: const Icon(Icons.add_circle_outline_rounded),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      suggestionsCallback: (String pattern) {
                        if (int.tryParse(pattern.trim()) != null) {
                          return Future.value([]);
                        }
                        return _searchParties(pattern);
                      },
                      itemBuilder: (context, party) {
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(party.name ?? ""),
                        );
                      },
                      onSuggestionSelected: (Party party) {
                        setState(() {
                          widget.args.orderInput.party = party;
                        });
                        _typeAheadController.text = party.name ?? "";
                      },
                    ),
                    const Divider(color: Colors.transparent, height: 5),
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
                      validator: (e) {
                        if ((e ?? "").isEmpty) {
                          return 'Please select a mode of payment';
                        }
                        return null;
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
    } catch (_) {}
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
