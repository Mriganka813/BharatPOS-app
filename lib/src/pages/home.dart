import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magicstep/src/blocs/home/home_cubit.dart';
import 'package:magicstep/src/pages/products_list.dart';
import 'package:magicstep/src/pages/sign_in.dart';
import 'package:magicstep/src/services/auth.dart';
import 'package:magicstep/src/widgets/custom_icons.dart';

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
    _homeCubit = HomeCubit()..currentUser();
    super.initState();
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<HomeCubit, HomeState>(
          bloc: _homeCubit,
          builder: (context, state) {
            if (state is HomeRender) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          state.user.businessName ?? "",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () async {
                            await const AuthService().clearCookies();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              SignInPage.routeName,
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.logout),
                        ),
                      ],
                    ),
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
                          icon: const Icon(CustomIcons.product),
                          title: "Products",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              ProductsListPage.routeName,
                            );
                          },
                        ),
                        HomeCard(
                          icon: const Icon(Icons.bookmark),
                          title: "Party",
                          onTap: () {},
                        ),
                        HomeCard(
                          icon: const Icon(Icons.bookmark),
                          title: "Income Exprense",
                          onTap: () {},
                        ),
                        HomeCard(
                          icon: const Icon(Icons.bookmark),
                          title: "Reports",
                          onTap: () {},
                        ),
                      ],
                    ),
                    const Text("Sharma City mart"),
                    const Spacer(),
                    const Text("Create Invoice"),
                    Row(
                      children: const [
                        Expanded(
                          child: Card(
                            child: Icon(Icons.arrow_circle_up_rounded),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            child: Icon(Icons.arrow_circle_down_rounded),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: icon,
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
