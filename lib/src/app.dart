import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopos/src/models/order.dart';
import 'package:shopos/src/models/user.dart';
import 'package:shopos/src/pages/change_password.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/pages/create_expense.dart';
import 'package:shopos/src/pages/create_party.dart';
import 'package:shopos/src/pages/create_product.dart';
import 'package:shopos/src/pages/create_purchase.dart';
import 'package:shopos/src/pages/create_sale.dart';
import 'package:shopos/src/pages/expense.dart';
import 'package:shopos/src/pages/forgot_password.dart';
import 'package:shopos/src/pages/home.dart';
import 'package:shopos/src/pages/party_credit.dart';
import 'package:shopos/src/pages/party_list.dart';
import 'package:shopos/src/pages/pdf_preview.dart';
import 'package:shopos/src/pages/products_list.dart';
import 'package:shopos/src/pages/reports.dart';
import 'package:shopos/src/pages/report_table.dart';
import 'package:shopos/src/pages/sign_in.dart';
import 'package:shopos/src/pages/sign_up.dart';
import 'package:shopos/src/pages/splash.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',
      navigatorKey: locator<GlobalServices>().navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      theme: ThemeData(
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: Colors.white),
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarColor: Theme.of(context).scaffoldBackgroundColor,
          ),
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
              // case SignUpPage.routeName:
              //   return const SignUpPage();
              case HomePage.routeName:
                return const HomePage();
              case ProductsListPage.routeName:
                return ProductsListPage(
                  args: settings.arguments as ProductListPageArgs?,
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
                return CreateExpensePage(id: settings.arguments as String?);
              case CreatePartyPage.routeName:
                return CreatePartyPage(
                    args: settings.arguments as CreatePartyArguments);
              case CreateSale.routeName:
                return const CreateSale();
              case CreatePurchase.routeName:
                return const CreatePurchase();
              case CheckoutPage.routeName:
                return CheckoutPage(
                  args: settings.arguments as CheckoutPageArgs,
                );
              case PartyCreditPage.routeName:
                return PartyCreditPage(
                  args: settings.arguments as ScreenArguments,
                );
              case PdfPreviewPage.routeName:
                return PdfPreviewPage(
                  args: settings.arguments as PdfPreviewPageArgs,
                );
              case ChangePassword.routeName:
                return ChangePassword(user: settings.arguments as User?);
              // case Forgotpassword.routeName:
              //   return Forgotpassword();
              case ReportTable.routeName:
                return ReportTable(
                  args: settings.arguments as tableArg,
                );
              default:
                return const SplashScreen();
            }
          },
        );
      },
    );
  }
}
