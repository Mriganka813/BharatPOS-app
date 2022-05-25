import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Party'),
        ),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(
            right: 10,
            bottom: 20,
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, CreatePartyPage.routeName);
            },
            backgroundColor: ColorsConst.primaryColor,
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        body: DefaultTabController(
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
                      ListView(
                        shrinkWrap: true,
                        children: const [],
                      ),
                      Container(),
                    ],
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
