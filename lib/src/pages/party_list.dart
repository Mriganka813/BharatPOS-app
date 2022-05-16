import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magicstep/src/blocs/party/party_cubit.dart';
import 'package:magicstep/src/config/colors.dart';
import 'package:magicstep/src/models/order.dart';
import 'package:magicstep/src/pages/create_party.dart';
import 'package:magicstep/src/services/global.dart';
import 'package:magicstep/src/services/locator.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';

class PartyListPage extends StatefulWidget {
  static const routeName = '/party_list';
  const PartyListPage({Key? key}) : super(key: key);

  @override
  State<PartyListPage> createState() => _PartyListPageState();
}

class _PartyListPageState extends State<PartyListPage> {
  late final PartyCubit _partyCubit;

  ///
  @override
  void initState() {
    super.initState();
    _partyCubit = PartyCubit()..getOrders();
  }

  @override
  void dispose() {
    _partyCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Party'),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
          right: 10,
          bottom: 20,
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final result =
                await Navigator.pushNamed(context, CreatePartyPage.routeName);
            if (result is bool && result) {
              _partyCubit.getMyParties();
            }
          },
          backgroundColor: ColorsConst.primaryColor,
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
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const CustomTextField(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search",
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: BlocBuilder<PartyCubit, PartyState>(
                    bloc: _partyCubit,
                    builder: (context, state) {
                      if (state is OrdersListRender) {
                        final salesOrders = state.salesOrders;
                        final purchaseOrders = state.purchaseOrders;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TabBar(
                              indicatorColor: ColorsConst.primaryColor,
                              labelColor: Colors.black,
                              labelStyle: Theme.of(context).textTheme.bodyLarge,
                              // <-- Your TabBar
                              tabs: const [
                                Tab(
                                  text: "Sale",
                                ),
                                Tab(
                                  text: "Purchase",
                                ),
                              ],
                            ),
                            const Divider(),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  SalesOrderList(
                                    salesOrders: salesOrders,
                                  ),
                                  PurchaseOrderList(
                                    purchaseOrders: purchaseOrders,
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
      ),
    );
  }
}

class PurchaseOrderList extends StatelessWidget {
  const PurchaseOrderList({
    Key? key,
    required this.purchaseOrders,
  }) : super(key: key);

  final List<Order> purchaseOrders;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) {
        return const Divider(color: Colors.transparent);
      },
      itemCount: purchaseOrders.length,
      itemBuilder: (context, index) {
        final order = purchaseOrders[index];
        return ListTile(
          title: Text(order.party?.name ?? order.modeOfPayment ?? ''),
          trailing: const Text("0"),
        );
      },
    );
  }
}

class SalesOrderList extends StatelessWidget {
  const SalesOrderList({
    Key? key,
    required this.salesOrders,
  }) : super(key: key);

  final List<Order> salesOrders;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) {
        return const Divider(color: Colors.transparent);
      },
      itemCount: salesOrders.length,
      itemBuilder: (context, index) {
        final order = salesOrders[index];

        return ListTile(
          title: Text(order.party?.name ?? order.modeOfPayment ?? ''),
          trailing: const Text("0"),
        );
      },
    );
  }
}
