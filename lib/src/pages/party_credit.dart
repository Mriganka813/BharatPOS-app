import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shopos/src/blocs/specific%20party/specific_party_cubit.dart';
import 'package:shopos/src/blocs/specific%20party/specific_party_state.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/pages/party_list.dart';

class ScreenArguments {
  final String partyId;
  final String partName;
  final String partyContactNo;
  final PartyType type;

  ScreenArguments({
    required this.partyId,
    required this.partName,
    required this.partyContactNo,
    required this.type,
  });
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

  @override
  void initState() {
    super.initState();
    _specificpartyCubit = SpecificPartyCubit();
    widget.args.type == PartyType.customer
        ? _specificpartyCubit.getInitialCreditHistory(widget.args.partyId)
        : _specificpartyCubit.getInitialpurchasedHistory(widget.args.partyId);
    _specificPartyInput = Party();
  }

  @override
  void dispose() {
    _specificpartyCubit.close();
    super.dispose();
  }

  TextEditingController value = TextEditingController();
  int balance_edit = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0,
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     splashRadius: 20,
        //     icon: const Icon(
        //       Icons.more_vert,
        //       size: 25,
        //       color: Colors.black,
        //     ),
        //   ),
        // ],
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
                  final order = orders[index];
                  return Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: currentdate(order.createdAt),
                        ),
                      ),
                      Align(
                        alignment: order.modeOfPayment == "Settle"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: SizedBox(
                          height: 50,
                          width: 111,
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
        elevation: 0,
        child: Container(
          height: 120,
          width: double.maxFinite,
          decoration: const BoxDecoration(color: Colors.white),
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
                    if (state is SpecificPartyListRender) {
                      balance = state.partyDetails.balance ?? 0;
                      // print(balance);
                    }
                    balance = balance + balance_edit;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
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
                          )
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

  modelOpen(context, String modeofPayment) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Enter Amount",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        controller: value,
                        decoration: const InputDecoration(hintText: "₹"),
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _specificPartyInput.modeOfPayment = modeofPayment;
                          _specificPartyInput.total = int.parse(value.text);
                          _specificPartyInput.id = widget.args.partyId;
                          _specificPartyInput.createdAt = DateTime.now();

                          if (_specificPartyInput.modeOfPayment == "Settle") {
                            balance_edit = balance_edit - int.parse(value.text);
                          } else {
                            balance_edit = balance_edit + int.parse(value.text);
                          }
                          value.clear();
                        });
                        if (widget.args.type == PartyType.customer) {
                          _specificpartyCubit
                              .updateCreditHistory(_specificPartyInput);
                        } else {
                          _specificpartyCubit
                              .updatepurchaseHistory(_specificPartyInput);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text("Confirm"))
                ],
              ),
            ),
          );
        });
  }

  currentdate(String dates) {
    DateTime d = DateTime.parse(dates);
    // var dt = DateTime.now();
    var datereq = DateFormat.MMMM().format(d);
    return Text(
      d.day.toString() + " " + datereq + ", " + d.year.toString(),
      style: const TextStyle(color: Colors.black45),
    );
  }
}
