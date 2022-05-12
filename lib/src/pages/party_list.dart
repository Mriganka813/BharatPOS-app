import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magicstep/src/blocs/party/party_cubit.dart';
import 'package:magicstep/src/config/colors.dart';
import 'package:magicstep/src/pages/create_party.dart';
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
    _partyCubit = PartyCubit()..getMyParties();
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
      body: BlocBuilder<PartyCubit, PartyState>(
        bloc: _partyCubit,
        builder: (context, state) {
          if (state is PartyListRender) {
            return DefaultTabController(
              length: 2,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomTextField(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search",
                    ),
                    const SizedBox(height: 10),
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
                          ListView.separated(
                            shrinkWrap: true,
                            separatorBuilder: (context, index) {
                              return const Divider(color: Colors.transparent);
                            },
                            itemCount: state.parties.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(state.parties[index].name ?? ""),
                                trailing: const Text("0"),
                              );
                            },
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            separatorBuilder: (context, index) {
                              return const Divider(color: Colors.transparent);
                            },
                            itemCount: state.parties.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(state.parties[index].name ?? ""),
                                trailing: const Text("0"),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(ColorsConst.primaryColor),
            ),
          );
        },
      ),
    );
  }
}
