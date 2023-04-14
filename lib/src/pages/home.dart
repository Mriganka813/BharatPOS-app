import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_version/new_version.dart';
import 'package:shopos/src/blocs/home/home_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/pages/create_purchase.dart';
import 'package:shopos/src/pages/create_sale.dart';
import 'package:shopos/src/pages/expense.dart';
import 'package:shopos/src/pages/party_list.dart';
import 'package:shopos/src/pages/products_list.dart';
import 'package:shopos/src/pages/reports.dart';
import 'package:shopos/src/pages/sign_in.dart';
import 'package:shopos/src/services/auth.dart';
import 'package:shopos/src/widgets/custom_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const routeName = '/home';
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _homeCubit;

  ///
  @override
  void initState() {
    // _checkUpdate();
    _homeCubit = HomeCubit()..currentUser();
    super.initState();
  }

  Future<void> _checkUpdate() async {
    final newVersion = NewVersion(androidId: "com.shopos.magicstep");
    final status = await newVersion.getVersionStatus();
    if (status!.canUpdate) {
      newVersion.showUpdateDialog(
          context: context, versionStatus: status, allowDismissal: false);
    }
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<HomeCubit, HomeState>(
        bloc: _homeCubit,
        builder: (context, state) {
          if (state is HomeRender) {
            return Scaffold(
              backgroundColor: Color.fromARGB(96, 168, 199, 223),
              appBar: AppBar(
                title: Text(state.user.businessName ?? ""),
              ),
              drawer: Drawer(
                child: SafeArea(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.business_outlined,
                          color: Colors.black,
                        ),
                        title: Title(
                          color: Colors.black,
                          child: Text(
                            state.user.businessName ?? "",
                            textScaleFactor: 1.4,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        subtitle: Text(state.user.address ?? ""),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.security_outlined),
                        title: Title(
                            color: Colors.black,
                            child: Text("Change Password")),
                        onTap: () async {
                          await Navigator.pushNamed(context, 'changepassword',
                              arguments: state.user);
                          Navigator.pop(context);
                        },
                      ),
                      Divider(
                        color: Colors.transparent,
                      ),
                      ListTile(
                        leading: Icon(Icons.policy_outlined),
                        title: Title(
                            color: Colors.black, child: Text("Privacy Policy")),
                        onTap: () async {
                          await launchUrl(
                            Uri.parse(
                                'http://64.227.172.99:5000/privacy-policy'),
                            mode: LaunchMode.externalApplication,
                          );
                          Navigator.pop(context);
                        },
                      ),
                      Divider(
                        color: Colors.transparent,
                      ),
                      ListTile(
                        leading: Icon(Icons.control_point),
                        title: Title(
                            color: Colors.black,
                            child: Text("Terms and Conditions")),
                        onTap: () async {
                          await launchUrl(
                            Uri.parse(
                                'http://64.227.172.99:5000/terms-and-condition'),
                            mode: LaunchMode.externalApplication,
                          );
                          Navigator.pop(context);
                        },
                      ),
                      Divider(
                        color: Colors.transparent,
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title:
                            Title(color: Colors.black, child: Text("Logout")),
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignInPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GridView(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 2,
                      ),
                      padding: const EdgeInsets.all(10),
                      children: [
                        SizedBox(
                          child: HomeCard(
                            icon: const Icon(
                              CustomIcons.product,
                              size: 80,
                              color: ColorsConst.primaryColor,
                            ),
                            title: "Products",
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ProductsListPage.routeName,
                              );
                            },
                          ),
                        ),
                        HomeCard(
                          icon: const Icon(
                            CustomIcons.person,
                            size: 80,
                            color: ColorsConst.primaryColor,
                          ),
                          title: "Party",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              PartyListPage.routeName,
                            );
                          },
                        ),
                        HomeCard(
                          icon: const Icon(
                            CustomIcons.report_svg,
                            color: ColorsConst.primaryColor,
                            size: 80,
                          ),
                          title: "Expense",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              ExpensePage.routeName,
                            );
                          },
                        ),
                        HomeCard(
                          icon: const Icon(
                            CustomIcons.growth_graph,
                            color: ColorsConst.primaryColor,
                            size: 80,
                          ),
                          title: "Reports",
                          onTap: () {
                            Navigator.pushNamed(context, ReportsPage.routeName);
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 200,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Create Invoice",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 80.0,
                          width: 400,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                CreatePurchase.routeName,
                              );
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            padding: EdgeInsets.all(0.0),
                            child: Ink(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30.0)),
                              child: Container(
                                // constraints: BoxConstraints(
                                //     maxWidth: 300.0, minHeight: 50.0),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15, top: 8, bottom: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Purchase",
                                        style: TextStyle(fontSize: 30),
                                        // Theme.of(context)
                                        //   .textTheme
                                        //   .headline6,

                                        textAlign: TextAlign.center,
                                      ),
                                      Icon(
                                        CustomIcons.arrow_down,
                                        color: Colors.red,
                                        size: 60,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 80.0,
                          width: 400,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, CreateSale.routeName);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            padding: EdgeInsets.all(0.0),
                            child: Ink(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30.0)),
                              child: Container(
                                // constraints: BoxConstraints(
                                //     maxWidth: 300.0, minHeight: 50.0),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15, top: 8, bottom: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Sales",
                                        style: TextStyle(fontSize: 30),
                                        textAlign: TextAlign.center,
                                      ),
                                      Icon(
                                        CustomIcons.arrow_up,
                                        color: ColorsConst.primaryColor,
                                        size: 60,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              color: ColorsConst.primaryColor,
            ),
          );
        },
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  final String title;
  const HomeCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: icon,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
