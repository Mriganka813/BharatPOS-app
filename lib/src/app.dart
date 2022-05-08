import 'package:flutter/material.dart';
import 'package:magicstep/src/pages/create_expense.dart';
import 'package:magicstep/src/pages/create_party.dart';
import 'package:magicstep/src/pages/create_product.dart';
import 'package:magicstep/src/pages/create_purchase.dart';
import 'package:magicstep/src/pages/expense.dart';
import 'package:magicstep/src/pages/home.dart';
import 'package:magicstep/src/pages/party_list.dart';
import 'package:magicstep/src/pages/products_list.dart';
import 'package:magicstep/src/pages/reports.dart';
import 'package:magicstep/src/pages/sign_in.dart';
import 'package:magicstep/src/pages/sign_up.dart';
import 'package:magicstep/src/pages/splash.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const SplashScreen(),
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) {
            switch (settings.name) {
              case SignInPage.routeName:
                return const SignInPage();
              case SignUpPage.routeName:
                return const SignUpPage();
              case HomePage.routeName:
                return const HomePage();
              case ProductsListPage.routeName:
                return ProductsListPage(
                  isSelecting: settings.arguments as bool?,
                );
              case CreateProduct.routeName:
                return CreateProduct(id: settings.arguments as String?);
              case PartyListPage.routeName:
                return const PartyListPage();
              case ReportsPage.routeName:
                return const ReportsPage();
              case ExpensePage.routeName:
                return const ExpensePage();
              case CreateExpensePage.routeName:
                return const CreateExpensePage();
              case CreatePartyPage.routeName:
                return const CreatePartyPage();
              case CreatePurchasePage.routeName:
                return const CreatePurchasePage();
              default:
                return const SplashScreen();
            }
          },
        );
      },
    );
  }
}
