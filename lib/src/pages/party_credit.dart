import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shopos/src/blocs/home/home_cubit.dart';
import 'package:shopos/src/blocs/report/report_cubit.dart';
import 'package:shopos/src/blocs/specific%20party/specific_party_cubit.dart';
import 'package:shopos/src/blocs/specific%20party/specific_party_state.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/models/order.dart';
import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/models/user.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/services/set_or_change_pin.dart';
import 'package:shopos/src/services/user.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pinCode;
import 'package:url_launcher/url_launcher.dart';

class ScreenArguments {
  final String partyId;
  final String partName;
  final String partyContactNo;
  final int tabbarNo;

  ScreenArguments(
      this.partyId, this.partName, this.partyContactNo, this.tabbarNo);
}

class PartyCreditPage extends StatefulWidget {
  final ScreenArguments args;
  static const routeName = '/party_credit';

  ///
  const PartyCreditPage({Key? key, required this.args}) : super(key: key);

  @override
  State<PartyCreditPage> createState() => _PartyCreditPageState();
}

class _PartyCreditPageState extends State<PartyCreditPage> {
  late final SpecificPartyCubit _specificpartyCubit;
  late Party _specificPartyInput;
  PinService _pinService = PinService();
  late final ReportCubit _reportCubit;
  final TextEditingController pinController = TextEditingController();

  User ?user;
  @override
  void initState() {
    super.initState();
    _specificpartyCubit = SpecificPartyCubit();
    fetchdata();
    _specificPartyInput = Party();
    _reportCubit = ReportCubit();
  }

  void fetchdata()async {
    widget.args.tabbarNo == 0
        ? _specificpartyCubit.getInitialCreditHistory(widget.args.partyId)
        : _specificpartyCubit.getInitialpurchasedHistory(widget.args.partyId);


        final response = await UserService.me();
   user = User.fromMap(response.data['user']);
   setState(() {
     
   });
  }

  @override
  void dispose() {
    _specificpartyCubit.close();
    _reportCubit.close();
    super.dispose();
  }

  void sort(List<Order> o) {
    for (int i = 0; i < o.length; i++) {
      for (int j = i + 1; j < o.length; j++) {
        String dateString = o[i].createdAt!;

        DateTime dateTimei = DateTime.parse(dateString);

        String dateStringj = o[j].createdAt!;

        DateTime dateTimej = DateTime.parse(dateStringj);

        if (dateTimej.isBefore(dateTimei)) {
          var temp = o[i];
          o[i] = o[j];
          o[j] = temp;
        }
      }
    }
  }

  TextEditingController value = TextEditingController();

  String balanceToShareOnWhatsapp="";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.args.partName),
            Text(
              widget.args.partyContactNo,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [GestureDetector(
          onTap: (){_launchUrl(user!.businessName!, widget.args.partyContactNo);},
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset("assets/images/whats.png",height: 25,width: 25,),
          ))],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: BlocBuilder<SpecificPartyCubit, SpecificPartyState>(
          bloc: _specificpartyCubit,
          builder: (context, state) {
            if (state is SpecificPartyListRender) {
              final orders = state.specificparty;

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                reverse: true,
                itemCount: orders.length,
                itemBuilder: (BuildContext context, int index) {
                  sort(orders);
                  final order = orders[index];

                  return Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: currentdate(order.createdAt!),
                        ),
                      ),
                      Align(
                        alignment: order.modeOfPayment == "Settle"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: SizedBox(
                          height: 50,
                          width: 111,
                          child: GestureDetector(
                            onLongPress: () async {
                              HapticFeedback.vibrate();
                              await openEditModal(
                                  order.id!,
                                  order.total!,
                                  order.createdAt!,
                                  order.modeOfPayment!,
                                  context);
                            },
                            child: Card(
                              clipBehavior: Clip.hardEdge,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.black, width: 0.5),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "${order.total}",
                                  style: TextStyle(
                                    color: order.modeOfPayment == "Settle"
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(ColorsConst.primaryColor),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 100,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          height: 120,
          width: double.maxFinite,
          decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black12))),
          child: SingleChildScrollView(
            reverse: true,
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BlocBuilder<SpecificPartyCubit, SpecificPartyState>(
                  bloc: _specificpartyCubit,
                  builder: (context, state) {

                    int balance = 0;
                    int negbalance = 0;
                  
                    if (state is SpecificPartyListRender) {
             
                      balance = state.partyDetails.balance ?? 0;
                      negbalance = balance * -1;
                     
                      Future.delayed(Duration(seconds: 3),(){
                          balanceToShareOnWhatsapp=balance.toString();
                          setState(() {
                            
                          });
                      });
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: balance >= 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text(
                                  "Balance Due",
                                  textScaleFactor: 1.7,
                                ),
                                Text(
                                  "$balance",
                                  textScaleFactor: 1.7,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text(
                                  "Balance Advance",
                                  textScaleFactor: 1.7,
                                ),
                                Text(
                                  "$negbalance",
                                  textScaleFactor: 1.7,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () {
                          modelOpen(context, "Settle");
                        },
                        child: const Text(
                          "Received",
                          style: TextStyle(
                            color: Color.fromRGBO(32, 150, 82, 100),
                          ),
                          textScaleFactor: 1.7,
                        ),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all(
                            const Color.fromRGBO(148, 255, 194, 100),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () {
                          modelOpen(context, "Credit");
                        },
                        child: const Text(
                          "Given",
                          style: TextStyle(color: Colors.red),
                          textScaleFactor: 1.7,
                        ),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all(
                            const Color.fromRGBO(255, 209, 209, 10),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

 /* Future<Widget> ShowShareDialog(String name,String number)async
  {
    TextEditingController controller =TextEditingController();
      return await  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            backgroundColor: Colors.white,
                            title: Column(children: [
                              Text(
                                "Enter Whatsapp numer\n(10-digit number only)",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins-Regular",
                                    color: Colors.black),
                              )
                            ]),
                            content: TextField(
                              autofocus: true,
                              controller: controller,
                              decoration: InputDecoration(
                                hintText: "Enter 10-digit number",
                                enabledBorder: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                  
                                      _launchUrl(
                                      controller.text
                                      );
                                  },
                                  child: Text("Yes")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Cancel"))
                            ],
                          ));
  }

  */


Future<void> _launchUrl(String name,String mobile) async {

  String Message="Dear customer, your credit balance with ${name} is rupees $balanceToShareOnWhatsapp. Please pay the amount as soon as possible. Thank you for your business.%0A%0A*Powered by BharatPOS*";
  

  final Uri _url = Uri.parse(
      'https://wa.me/${mobile}?text=$Message'); 

  if (await canLaunchUrl(_url)) {
    await launchUrl(_url, mode: LaunchMode.externalApplication);
  } else {
    throw Exception('Could not launch $_url');
  }
}

// add settle and credit
  modelOpen(context, String modeofPayment) {
    return showModalBottomSheet(
        isScrollControlled: true,
        elevation: 5,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.black12))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text("Add Amount",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black38),
                            borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          controller: value,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                              hintText: "₹",
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 10,
                              ),
                              border: InputBorder.none),
                        ),
                      ),
                    ),
                    CustomButton(
                      onTap: () {
                        setState(() {
                          _specificPartyInput.modeOfPayment = modeofPayment;
                          _specificPartyInput.total = int.parse(value.text);
                          _specificPartyInput.id = widget.args.partyId;
                          _specificPartyInput.createdAt = DateTime.now();

                          value.clear();
                        });
                        if (widget.args.tabbarNo == 0) {
                          _specificpartyCubit
                              .updateCreditHistory(_specificPartyInput);
                        } else {
                          _specificpartyCubit
                              .updatepurchaseHistory(_specificPartyInput);
                        }
                        Navigator.pop(context);
                      },
                      title: "Confirm",
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

// update settle and credit model
  modelOpenUpdate(context, String id, int amount, String type) {
    String newtotal = amount.toString();
    return showModalBottomSheet(
        barrierColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.black12))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text("Enter Amount",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25)),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black)),
                        child: TextFormField(
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            initialValue: amount.toString(),
                            decoration: const InputDecoration(
                              hintText: "₹",
                            ),
                            onChanged: (e) {
                              setState(() {
                                newtotal = e;
                              });
                            }),
                      ),
                    ),
                    CustomButton(
                      onTap: () {
                        int amountnew = int.parse(newtotal);
                        widget.args.tabbarNo == 0
                            ? _specificpartyCubit.updateAmountCustomer(
                                Party(id: id, total: amountnew),
                                widget.args.partyId)
                            : _specificpartyCubit.updateAmountSupplier(
                                Party(id: id, total: amountnew),
                                widget.args.partyId);

                        Navigator.pop(context);
                      },
                      title: "Confirm",
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

// edit credit or settle
  openEditModal(String id, int total, String createdAt, String type, context) {
    Alert(
        style: const AlertStyle(
          animationType: AnimationType.grow,
          isButtonVisible: false,
        ),
        context: context,
        content: Column(
          children: [
            ListTile(
              title: const Text("Edit"),
              onTap: () async {
                var result = true;

                if (await _pinService.pinStatus()==true) {
                  result = await _showPinDialog() as bool;
                }
                if (result!) {
                  Navigator.pop(context);
                  await modelOpenUpdate(context, id, total, type);
                } else {
                  Navigator.pop(context);
                  locator<GlobalServices>().errorSnackBar("Incorrect pin");
                }
              },
            ),
            ListTile(
              title: const Text("Delete"),
              onTap: () async {
                var result = true;

                if (await _pinService.pinStatus()==true) {
                  result = await _showPinDialog() as bool;
                }
                if (result!) {
                  widget.args.tabbarNo == 0
                      ? _specificpartyCubit.deleteCustomerExpense(
                          Party(id: id), widget.args.partyId)
                      : _specificpartyCubit.deleteSupplierExpense(
                          Party(id: id), widget.args.partyId);
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context);
                  locator<GlobalServices>().errorSnackBar("Incorrect pin");
                }
              },
            ),
          ],
        )).show();
  }

  currentdate(String dates) {
    DateTime d = DateTime.parse(dates);
    var datereq = DateFormat.MMMM().format(d);
    return Text(
      d.day.toString() + " " + datereq + ", " + d.year.toString(),
      style: const TextStyle(color: Colors.black45),
    );
  }

  Future<bool?> _showPinDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              content: pinCode.PinCodeTextField(
                autoDisposeControllers: false,
                appContext: context,
                length: 6,
                obscureText: true,
                obscuringCharacter: '*',
                blinkWhenObscuring: true,
                animationType: pinCode.AnimationType.fade,
                keyboardType: TextInputType.number,
                pinTheme: pinCode.PinTheme(
                  shape: pinCode.PinCodeFieldShape.underline,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 40,
                  fieldWidth: 30,
                  inactiveColor: Colors.black45,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  selectedColor: Colors.black45,
                  disabledColor: Colors.black,
                  activeFillColor: Colors.white,
                ),
                cursorColor: Colors.black,
                controller: pinController,
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
              ),
              title: Text('Enter your pin'),
              actions: [
                Center(
                    child: CustomButton(
                        title: 'Verify',
                        onTap: () async {
                          bool status = await _pinService.verifyPin(
                              int.parse(pinController.text.toString()));
                          print(status);
                          if (status) {
                            pinController.clear();
                            Navigator.of(ctx).pop(true);
                          } else {
                            Navigator.of(ctx).pop(false);
                            pinController.clear();

                            return;
                          }
                        }))
              ],
            ));
  }

}

