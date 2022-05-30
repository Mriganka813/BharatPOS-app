import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopos/src/blocs/party/party_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/pages/create_party.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';

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
    _partyCubit = PartyCubit()..getInitialCreditParties();
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
                      if (state is CreditPartiesListRender) {
                        final salesParties = state.saleParties;
                        final purchaseParties = state.purchaseParties;
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
                                  PartiesListView(parties: salesParties),
                                  PartiesListView(parties: purchaseParties),
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

class PartiesListView extends StatelessWidget {
  const PartiesListView({
    Key? key,
    required this.parties,
  }) : super(key: key);

  final List<Party> parties;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) {
        return const Divider(color: Colors.transparent);
      },
      itemCount: parties.length,
      itemBuilder: (context, index) {
        final party = parties[index];
        return ListTile(
          title: Text(party.name ?? ""),
          trailing: Text("${party.totalCreditAmount}"),
        );
      },
    );
  }
}
