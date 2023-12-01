// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shopos/src/app.dart';
import 'package:shopos/src/blocs/home/home_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/pages/create_purchase.dart';
import 'package:shopos/src/pages/create_sale.dart';
import 'package:shopos/src/pages/expense.dart';
import 'package:shopos/src/pages/online_order_list.dart';

import 'package:shopos/src/pages/party_list.dart';
import 'package:shopos/src/pages/privacy_policy.dart';
// import 'package:shopos/src/pages/products_list.dart';
import 'package:shopos/src/pages/reports.dart';
import 'package:shopos/src/pages/search_result.dart';
import 'package:shopos/src/pages/set_pin.dart';
import 'package:shopos/src/pages/sign_in.dart';
import 'package:shopos/src/pages/terms_conditions.dart';
import 'package:shopos/src/provider/billing_order.dart';
import 'package:shopos/src/services/LocalDatabase.dart';
import 'package:shopos/src/services/auth.dart';
import 'package:shopos/src/services/background_service.dart';
import 'package:shopos/src/services/set_or_change_pin.dart';
import 'package:shopos/src/services/user.dart';
import 'package:shopos/src/widgets/custom_button.dart';
// import 'package:shopos/src/widgets/bulk_upload.dart';
import 'package:shopos/src/widgets/custom_icons.dart';
// import 'package:switcher/switcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const routeName = '/home';
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _homeCubit;

  bool shopOpen = true;

  final PinService _pinService = PinService();
  final TextEditingController pinController = TextEditingController();

  ///
  @override
  void initState() {
    // _checkUpdate();
    _homeCubit = HomeCubit()..currentUser();
    super.initState();
    initializeService();
      
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
              appBar: AppBar(
                // toolbarHeight: MediaQuery.of(context).size.height * 0.07,
                title: Text(state.user.businessName ?? ""),
                actions: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 30,
                        child: Switch(
                            activeColor: Colors.green,
                            value: shopOpen,
                            onChanged: (bool status) async {
                              await UserService.shopStatus();
                              shopOpen = status;
                              setState(() {});
                            }),
                      ),
                      Text(
                        shopOpen ? 'Online' : 'Offline',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                ],
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
                        subtitle: Text(
                          state.user.email ?? "",
                          textScaleFactor: 1.2,
                        ),
                      ),
                      Divider(),
                      // ListTile(
                      //   leading: Icon(Icons.upload_file),
                      //   title: Text("Bulk Product Upload",
                      //       style: TextStyle(color: Colors.black)),
                      //   onTap: () async {
                      //     await launchUrl(
                      //       Uri.parse(
                      //           'http://65.0.7.20:8001/api/v1/renderweblogin'),
                      //       mode: LaunchMode.externalApplication,
                      //     );
                      //     Navigator.pop(context);
                      //   },
                      // ),
                      ListTile(
                        leading: Icon(Icons.lock),
                        title: Title(
                            color: Colors.black, child: Text("Set/Change pin")),
                        onTap: () async {
                          bool status = await _pinService.pinStatus();
                          print(status);
                          Navigator.of(context).pushNamed(SetPinPage.routeName,
                              arguments: status);
                        },
                      ),
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
                      ListTile(
                        leading: Icon(Icons.policy_outlined),
                        title: Title(
                            color: Colors.black, child: Text("Privacy Policy")),
                        onTap: () {
                          Navigator.pushNamed(
                              context,
                              PrivacyPolicyPage
                                  .routeName); // Navigate to the PrivacyPolicyPage
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.control_point),
                        title: Title(
                            color: Colors.black,
                            child: Text("Terms and Conditions")),
                        onTap: () {
                          Navigator.pushNamed(
                              context,
                              TermsAndConditionsPage
                                  .routeName); // Navigate to the PrivacyPolicyPage
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title:
                            Title(color: Colors.black, child: Text("Logout")),
                        onTap: () async {
                          await const AuthService().signOut();
                          // final provider =
                          //     Provider.of<Billing>(context, listen: false);
                          // provider.removeAll();
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
                        crossAxisCount: 2,
                        childAspectRatio: 1,
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
                              SearchProductListScreen.routeName,
                              arguments: ProductListPageArgs(
                                  isSelecting: false,
                                  orderType: OrderType.sale,
                                  productlist: []),
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
                    OnlineStoreWidget(
                      activeOrders: 5,
                      onTap: () {
                        Navigator.pushNamed(context, ReportsPage.routeName);
                      },
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Create Invoice",
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
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
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, CreateSale.routeName,
                                  arguments: BillingPageArgs(
                                      id: -1, orderId: "", editOrders: []));
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

  Future<bool?> showRestartAppDialouge() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              content: Text('App needed to restart'),
              title: Text('Alert'),
              actions: [
                Center(
                    child: CustomButton(
                        title: 'ok',
                        onTap: () async {
                          Navigator.of(context).pop();
                          //await DatabaseHelper().deleteTHEDatabase();
                          // runApp(MyApp());
                        }))
              ],
            ));
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

class OnlineStoreWidget extends StatelessWidget {
  final int activeOrders;
  final VoidCallback onTap;

  const OnlineStoreWidget({
    Key? key,
    this.activeOrders = 0,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, OnlineOrderList.routeName);
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0), // Add vertical padding
          child: Row(
            children: [
              SizedBox(width: 20.0),
              Icon(
                Icons.storefront_rounded,
                size: 50.0,
                color: ColorsConst.primaryColor,
              ),
              SizedBox(width: 35.0),
              Text(
                "Online Store",
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
