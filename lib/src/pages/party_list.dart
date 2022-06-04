import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopos/src/blocs/party/party_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/pages/create_party.dart';
import 'package:shopos/src/pages/party_credit.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';

class PartyListPage extends StatefulWidget {
  static const routeName = '/party_list';
  const PartyListPage({Key? key}) : super(key: key);

  @override
  State<PartyListPage> createState() => _PartyListPageState();
}

class _PartyListPageState extends State<PartyListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PartyCubit _customerPartyCubit;
  late final PartyCubit _supplierPartyCubit;

  ///
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _supplierPartyCubit = PartyCubit();
    _customerPartyCubit = PartyCubit();
    _customerPartyCubit.getCustomerParties();
    _supplierPartyCubit.getSupplierParties();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _supplierPartyCubit.close();
    _customerPartyCubit.close();
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
            final partyType =
                _tabController.index == 0 ? 'customer' : 'supplier';
            final result = await Navigator.pushNamed(
              context,
              CreatePartyPage.routeName,
              arguments: partyType,
            );

            /// TODO fix this
            // if (result is bool) {
            //   if (result) {
            //     _partyCubit.getInitialCreditParties();
            //   }
            // }
          },
          backgroundColor: ColorsConst.primaryColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              controller: _tabController,
              indicatorColor: ColorsConst.primaryColor,
              labelColor: Colors.black,
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 17,
                  ),
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
                    type: PartyType.customer,
                    partyCubit: _customerPartyCubit,
                  ),
                  PartiesListView(
                    type: PartyType.supplier,
                    partyCubit: _supplierPartyCubit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum PartyType {
  customer,
  supplier,
}

class PartiesListView extends StatefulWidget {
  final PartyCubit partyCubit;
  const PartiesListView({
    Key? key,
    required this.type,
    required this.partyCubit,
  }) : super(key: key);

  ///
  final PartyType type;

  @override
  State<PartiesListView> createState() => _PartiesListViewState();
}

class _PartiesListViewState extends State<PartiesListView> {
  ///
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: CustomTextField(
            prefixIcon: Icon(Icons.search),
            hintText: "Search",
          ),
        ),
        const Divider(color: Colors.transparent),
        Expanded(
          child: BlocConsumer<PartyCubit, PartyState>(
            bloc: widget.partyCubit,
            listener: (context, state) {
              if (state is PartyError) {
                locator<GlobalServices>().errorSnackBar(state.message);
              }
            },
            builder: (context, state) {
              if (state is CreditPartiesListRender) {
                final parties = state.parties;
                return ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemCount: parties.length,
                  itemBuilder: (context, index) {
                    final party = parties[index];
                    return ListTile(
                      title: Text(party.name ?? ""),
                      trailing: Text(
                          "${(party.totalCreditAmount ?? 0) - (party.totalSettleAmount ?? 0)}"),
                      onTap: () {
                        _onTapParty(context, party);
                      },
                    );
                  },
                );
              }
              return const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ColorsConst.primaryColor),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onTapParty(BuildContext context, Party party) async {
    Navigator.pushNamed(
      context,
      PartyCreditPage.routeName,
      arguments: ScreenArguments(
        partyId: party.id!,
        partName: party.name!,
        partyContactNo: party.phoneNumber!,
        type: widget.type,
      ),
    );
  }
}
