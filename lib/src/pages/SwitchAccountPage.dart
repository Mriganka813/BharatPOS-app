import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopos/src/blocs/auth/auth_cubit.dart';
import 'package:shopos/src/blocs/home/home_cubit.dart';
import 'package:shopos/src/pages/home.dart';
import 'package:shopos/src/pages/sign_in.dart';
import 'package:shopos/src/provider/billing_order.dart';
import 'package:shopos/src/services/auth.dart';
import 'package:shopos/src/widgets/custom_button.dart';

class SwitchAccountPage extends StatefulWidget {
  static const rountName = "Switch_Account";
  @override
  State<SwitchAccountPage> createState() => _SwitchAccountPageState();
}

class _SwitchAccountPageState extends State<SwitchAccountPage> {
  List<Map<String, String>> accountList = [];
  late final AuthCubit _authCubit;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAccounts();
    _authCubit = AuthCubit();
  }

  void getAccounts() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.getKeys().forEach((element) {
      if (element.contains("@"))
        accountList.add({element: pref.getString(element)!});
    });
    setState(() {});
  }

  LogIn(String email, String pass) async {
         final provider = Provider.of<Billing>(context, listen: false);
         provider.removeAll();
    await AuthService().signOut();
    await _authCubit.signIn(email, pass, false);
    HomeCubit().currentUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switch Account"),
        centerTitle: true,
      ),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  for (int i = 0; i < accountList.length; i++)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: ()async {
                         await LogIn(accountList[i].keys.first,
                              accountList[i].values.first);
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            HomePage.routeName,
                            (route) => false,
                          );
                        },
                        
                        leading: CircleAvatar(child: Icon(Icons.person)),
                        title: Text(accountList[i].keys.first),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ),
                    )
                ],
              ),
              Spacer(),
              CustomButton(
                  title: "Add Account",
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      SignInPage.routeName,
                      (route) => false,
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
