import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shopos/src/blocs/specific%20party/specific_party_cubit.dart';
import 'package:shopos/src/blocs/specific%20party/specific_party_state.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/models/specific_party.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';

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
  late SpecificParty _SpecificPartyInput;

  @override
  void initState() {
    super.initState();
    if (widget.args.tabbarNo == 0) {
      _specificpartyCubit = SpecificPartyCubit()
        ..getInitialCreditHistory(widget.args.partyId);
    } else {
      _specificpartyCubit = SpecificPartyCubit()
        ..getInitialpurchasedHistory(widget.args.partyId);
    }
    _SpecificPartyInput = SpecificParty();
  }

  @override
  void dispose() {
    _specificpartyCubit.close();
    super.dispose();
  }

  TextEditingController value = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0,
        title: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.args.partName + "\n" + widget.args.partyContactNo,
                      style: TextStyle(color: Colors.black),
                    ),
                    IconButton(
                        onPressed: () {},
                        splashRadius: 20,
                        icon: const Icon(
                          Icons.more_vert,
                          size: 25,
                          color: Colors.black,
                        ))
                  ],
                ),
              ],
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: SingleChildScrollView(
          reverse: true,
          child: BlocBuilder<SpecificPartyCubit, SpecificPartyState>(
            bloc: _specificpartyCubit,
            builder: (context, state) {
              print(state.toString());
              if (state is SpecificPartyListRender) {
                final specificParties = state.specificparty.reversed.toList();
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: specificParties.length,
                  itemBuilder: (BuildContext context, int index) {
                    final party = specificParties[index];
                    if (party.modeOfPayment == "Credit") {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 15),
                            child: currentdate("${party.createdAt}"),
                          ),
                          ListTile(
                            trailing: Container(
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
                                    "${party.total}",
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (party.modeOfPayment == "Settle") {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 15),
                            child: Container(
                              child: currentdate("${party.createdAt}"),
                            ),
                          ),
                          ListTile(
                            leading: Container(
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
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    "${party.total}",
                                    style: const TextStyle(
                                        color: Colors.green, fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const Text("test");
                  },
                );
              }
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(ColorsConst.primaryColor),
                ),
              );
              ;
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Container(
          height: 120,
          width: double.maxFinite,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            reverse: true,
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text(
                        "Balance Due",
                        textScaleFactor: 1.7,
                      ),
                      Text(
                        "500",
                        textScaleFactor: 1.7,
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 50,
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () {
                          modelOpen(context, "Settle");
                        },
                        child: const Text(
                          "Received",
                          style: TextStyle(
                              color: Color.fromRGBO(32, 150, 82, 100)),
                          textScaleFactor: 1.7,
                        ),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromRGBO(148, 255, 194, 100)),
                        ),
                      ),
                    ),
                    Container(
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
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromRGBO(255, 209, 209, 10)),
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
    print(modeofPayment);

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
                          _SpecificPartyInput.modeOfPayment = modeofPayment;
                          _SpecificPartyInput.total = int.parse(value.text);
                          _SpecificPartyInput.id = widget.args.partyId;
                          _SpecificPartyInput.createdAt = DateTime.now();
                          value.clear();
                        });
                        if (widget.args.tabbarNo == 0) {
                          _specificpartyCubit
                              .updateCreditHistory(_SpecificPartyInput);
                        } else {
                          _specificpartyCubit
                              .updatepurchaseHistory(_SpecificPartyInput);
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
