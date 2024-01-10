import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pinCode;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shopos/src/blocs/party/party_cubit.dart';
import 'package:shopos/src/blocs/report/report_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/pages/create_party.dart';
import 'package:shopos/src/pages/party_credit.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/services/party.dart';
import 'package:shopos/src/services/set_or_change_pin.dart';
import 'package:shopos/src/widgets/custom_button.dart';
// import 'package:shopos/src/widgets/custom_text_field.dart';

class PartyListPage extends StatefulWidget {
  static const routeName = '/party_list';
  const PartyListPage({Key? key}) : super(key: key);

  @override
  State<PartyListPage> createState() => _PartyListPageState();
}

class _PartyListPageState extends State<PartyListPage>
    with SingleTickerProviderStateMixin {
  late final PartyCubit _partyCubit;
  late final TabController _tabController;
  late final TextEditingController _typeAheadController;

  ///
  @override
  void initState() {
    super.initState();
    _partyCubit = PartyCubit()..getInitialCreditParties();
    _tabController = TabController(length: 2, vsync: this);
    _typeAheadController = TextEditingController();
  }

  @override
  void dispose() {
    _partyCubit.close();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Party'),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
          right: 10,
          bottom: 20,
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final partyType =
                _tabController.index == 0 ? 'customer' : 'supplier';
            final result = await Navigator.pushNamed(
                context, CreatePartyPage.routeName,
                arguments: CreatePartyArguments("", "", "", "", partyType));
            if (result is bool) {
              if (result) {
                _partyCubit.getInitialCreditParties();
              }
            }
          },
          backgroundColor: Colors.green,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
      body: BlocListener<PartyCubit, PartyState>(
        bloc: _partyCubit,
        listener: (context, state) {
          if (state is PartyError) {
            locator<GlobalServices>().errorSnackBar(state.message);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              // const CustomTextField(
              //   prefixIcon: Icon(Icons.search),
              //   hintText: "Search",
              // ),
              TypeAheadFormField<Party>(
                debounceDuration: const Duration(milliseconds: 500),
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _typeAheadController,
                  autofocus: true,
                  decoration: InputDecoration(
                    fillColor: Color(0xffEAEAEA),
                    filled: true,
                    hintText: "Search",
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
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
                    onTap: () {
                      Navigator.pushNamed(context, PartyCreditPage.routeName,
                          arguments: ScreenArguments(party.id!, party.name!,
                              party.phoneNumber!, _tabController.index));
                    },
                  );
                },
                onSuggestionSelected: (Party party) {
                  _typeAheadController.text = party.name ?? "";
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<PartyCubit, PartyState>(
                  bloc: _partyCubit,
                  builder: (context, state) {
                    // print(state.toString());
                    if (state is CreditPartiesListRender) {
                      final salesParties = state.saleParties;
                      final purchaseParties = state.purchaseParties;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabBar(
                            controller: _tabController,
                            indicatorColor: ColorsConst.primaryColor,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black,
                            labelStyle: Theme.of(context).textTheme.bodyLarge,
                            indicator: MyTabIndicator(),
                            indicatorPadding: EdgeInsets.all(5),
                            // <-- Your TabBar
                            tabs: const [
                              Tab(
                                
                                text: "Customer",
                                
                              ),
                              Tab(
                                text: "Supplier",
                              ),
                            ],
                          ),
                          const Divider(),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                PartiesListView(
                                  parties: salesParties,
                                  tabno: 0,
                                  partyCubit: _partyCubit,
                                ),
                                PartiesListView(
                                  parties: purchaseParties,
                                  tabno: 1,
                                  partyCubit: _partyCubit,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation(ColorsConst.primaryColor),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Iterable<Party>> _searchParties(String pattern) async {
    if (pattern.isEmpty) {
      return [];
    }

    final type = _tabController.index == 0 ? 'customer' : 'supplier';

    try {
      final response =
          await const PartyService().getSearch(pattern, type: type);
      final data = response.data['allParty'] as List<dynamic>;
      return data.map((e) => Party.fromMap(e));
    } catch (err) {
      // print(err.toString());
      return [];
    }
  }
}

class PartiesListView extends StatefulWidget {
  PartiesListView({
    Key? key,
    required this.parties,
    required this.tabno,
    required this.partyCubit,
  }) : super(key: key);

  final List<Party> parties;
  final int tabno;

  final PartyCubit partyCubit;

  @override
  State<PartiesListView> createState() => _PartiesListViewState();
}

class _PartiesListViewState extends State<PartiesListView> {
  PinService _pinService = PinService();

  late final ReportCubit _reportCubit;

  final TextEditingController pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) {
        return const Divider();
      },
      itemCount: widget.parties.length,
      itemBuilder: (context, index) {
        final party = widget.parties[index];
        return ListTile(
          title: Row(
            children: [
              Image.asset("assets/images/teamwork.png",height: 40,),
              SizedBox(width: 10,),
              Text(party.name ?? ""),
            ],
          ),
          trailing: party.balance! >= 0
              ? Text(
                  " ₹ ${ party.balance!.toStringAsFixed(2)}",
                  style: TextStyle(color: const Color.fromRGBO(244, 67, 54, 1)),
                )
              : Text(
                  " ₹ ${party.balance!.abs().toStringAsFixed(2)}",
                  style: TextStyle(color: Colors.green),
                ), //here when api will be fixed then we will get the correct value
          onTap: () async {
            print("line 278 in partylist");
            await Navigator.pushNamed(context, PartyCreditPage.routeName,
                arguments: ScreenArguments(
                    party.id!, party.name!, party.phoneNumber!, widget.tabno));
            widget.partyCubit.getInitialCreditParties();
          },
          onLongPress: () {
            showModal(party, context, widget.tabno);
          },
        );
      },
    );
  }

  showModal(Party _party, context, int tabno) {
    final String _partyType;
    tabno == 0 ? _partyType = "customer" : _partyType = "supplier";
    Alert(
        context: context,
        style: AlertStyle(
          isButtonVisible: false,
          animationType: AnimationType.grow,
        ),
        content: Column(
          children: [
            ListTile(
              title: const Text("Edit"),
              onTap: () async {
                var result = true;

                if (await _pinService.pinStatus()==true) {
                  result = await _showPinDialog() as bool;
                }
                if (result == true) {
                  await Navigator.pushNamed(context, CreatePartyPage.routeName,
                      arguments: CreatePartyArguments(_party.id!, _party.name!,
                          _party.phoneNumber!, _party.address!, _partyType));
                  Navigator.pop(context);
                  widget.partyCubit.getInitialCreditParties();
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
                if (result == true) {
                  widget.partyCubit.deleteParty(_party);
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


class MyTabIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _MyBoxPainter(this, onChanged);
  }
}

class _MyBoxPainter extends BoxPainter {
  final MyTabIndicator decoration;

  _MyBoxPainter(this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size!;
    final Paint paint = Paint();
    paint.color = Colors.blue; // Set your desired tab background color here
    canvas.drawRect(rect, paint);
  }
}