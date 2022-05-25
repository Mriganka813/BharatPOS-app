import 'package:flutter/material.dart';
import 'package:magicstep/src/pages/create_expense.dart';
import 'package:magicstep/src/pages/create_party.dart';
import 'package:magicstep/src/pages/create_product.dart';
import 'package:magicstep/src/pages/create_purchase.dart';
import 'package:magicstep/src/pages/expense.dart';
import 'package:magicstep/src/pages/home.dart';
import 'package:magicstep/src/pages/party_list.dart';
import 'package:magicstep/src/pages/pdf_preview.dart';
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
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return MaterialApp(
      // Providing a restorationScopeId allows the Navigator built by the
      // MaterialApp to restore the navigation stack when a user leaves and
      // returns to the app after it has been killed while running in the
      // background.
      restorationScopeId: 'app',
      debugShowCheckedModeBanner: false,

      // Provide the generated AppLocalizations to the MaterialApp. This
      // allows descendant Widgets to display the correct translations
      // depending on the user's locale.
      // localizationsDelegates: const [
      //   AppLocalizations.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('en', ''), // English, no country code
      // ],

      // Use AppLocalizations to configure the correct application title
      // depending on the user's locale.
      //
      // The appTitle is defined in .arb files found in the localization
      // directory.
      initialRoute: SplashScreen.routeName,
      // onGenerateTitle: (BuildContext context) =>
      //     AppLocalizations.of(context)!.appTitle,

      // Define a light and dark color theme. Then, read the user's
      // preferred ThemeMode (light, dark, or system default) from the
      // SettingsController to display the correct theme.
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          titleTextStyle: const TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      // darkTheme: ThemeData.dark(),
      // themeMode: settingsController.themeMode,

      ///
      home: const SplashScreen(),

      // Define a function to handle named routes in order to support
      // Flutter web url navigation and deep linking.
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
                  isSelecting: settings.arguments as bool,
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
                return CreateExpensePage(
                  id: routeSettings.arguments as String?,
                );
              case CreatePartyPage.routeName:
                return const CreatePartyPage();
              case CreatePurchasePage.routeName:
                return const CreatePurchasePage();
              case PdfPreviewPage.routeName:
                return PdfPreviewPage(pdfPath: settings.arguments as String);
              default:
                return const SplashScreen();
            }
          },
        );
      },
    );
  }
}
