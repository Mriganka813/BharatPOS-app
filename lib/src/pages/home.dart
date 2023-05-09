import 'package:firebase_auth/firebase_auth.dart';
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
    final media = MediaQuery.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<HomeCubit, HomeState>(
        bloc: _homeCubit,
        builder: (context, state) {
          if (state is HomeRender) {
            return Scaffold(
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
                          //await const AuthService().signOut();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            SignInPage.routeName,
                            (route) => false,
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
                        HomeCard(
                          icon: const Icon(
                            CustomIcons.product,
                            size: 50,
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
                        HomeCard(
                          icon: const Icon(
                            CustomIcons.person,
                            size: 50,
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
                            size: 50,
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
                            size: 50,
                          ),
                          title: "Reports",
                          onTap: () {
                            Navigator.pushNamed(context, ReportsPage.routeName);
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Create Invoice",
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: media.size.width * 0.15,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                CreatePurchase.routeName,
                              );
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    const Icon(
                                      CustomIcons.arrow_down,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Purchase",
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: media.size.width * 0.15,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, CreateSale.routeName);
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    const Icon(
                                      CustomIcons.arrow_up,
                                      color: ColorsConst.primaryColor,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Sale",
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
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
