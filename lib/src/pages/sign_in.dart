import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopos/src/blocs/auth/auth_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/pages/home.dart';
import 'package:shopos/src/provider/billing_order.dart';
import 'package:shopos/src/services/LocalDatabase.dart';
// import 'package:shopos/src/pages/sign_up.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';
import 'package:shopos/src/widgets/custom_text_field2.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);
  static const routeName = '/sign-in';

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late final AuthCubit _authCubit;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  @override
  void initState() {
    super.initState();
    // _checkUpdate();
    _authCubit = AuthCubit();
    // getDataFromDatabase();
  }

  getDataFromDatabase() async {
    try {
      final provider = Provider.of<Billing>(context);
      var data = await DatabaseHelper().getOrderItems();
      print("kkkkkk=");


      provider.removeAll();

      data.forEach((element) {
        provider.addSalesBill(element, element.id.toString());
      });
    } catch (e) {
      // showRestartAppDialouge();
    }
  }

  Future<void> _checkUpdate() async {
    final newVersion = NewVersion(androidId: "com.shopos.magicstep");
    final status = await newVersion.getVersionStatus();
    if (status!.canUpdate) {
      newVersion.showUpdateDialog(context: context, versionStatus: status, allowDismissal: false);
    }
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        bloc: _authCubit,
        listener: (context, state) {
          if (state is SignInSucces) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              HomePage.routeName,
              (route) => false,
            );
          }
          if (state is AuthError) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     backgroundColor: Colors.red,
            //     content: Text(
            //       state.message,
            //       style: const TextStyle(color: Colors.white),
            //     ),
            //   ),
            // );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          bloc: _authCubit,
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(ColorsConst.primaryColor),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /*    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Log in",
                        style: Theme.of(context).textTheme.headline3?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Enter your credentials to access your account",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),*/

                    const SizedBox(height: 100),
                    Container(
                      width: 200,
                        height: 100,
                        child: SvgPicture.asset(
                            "assets/icon/BharatPos.svg",
                          fit: BoxFit.cover,
                        )),
                    const SizedBox(height: 60),
                    CustomTextField2(
                      enabledBorderWidth: 0.3,
                      focusedBorderWidth: 1,
                      controller: TextEditingController(),
                      hintText: 'name@company.com',
                      onSave: (e) {
                        _email = e!;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    const SizedBox(height: 5),
                    CustomTextField2(
                      enabledBorderWidth: 0.3,
                      focusedBorderWidth: 1,
                      controller: TextEditingController(),
                      hintText: "Password",
                      onSave: (e) {
                        _password = e!;
                      },
                      obsecureText: true,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          "      ",
                          style: Theme.of(context).textTheme.headline6?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                        const Spacer(),
                        /* GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/forgotPassword',
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style:
                                Theme.of(context).textTheme.headline6?.copyWith(
                                      color: const Color.fromARGB(255, 1, 2, 3),
                                      fontWeight: FontWeight.normal,
                                    ),
                          ),
                        ),*/
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    /*   Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: const BorderSide(
                            width: 1,
                          ),
                          fillColor: MaterialStateProperty.all(
                            ColorsConst.primaryColor,
                          ),
                          onChanged: (val) {
                            if (val == null) {
                              return;
                            }
                            setState(() {
                              _rememberMe = val;
                            });
                          },
                        ),
                        
                        Text(
                          "Remember me",
                          style:
                              Theme.of(context).textTheme.headline6?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),*/
                    const SizedBox(height: 5),
                    CustomButton(
                      onTap: () {
                        _formKey.currentState?.save();
                        final isValid = _formKey.currentState?.validate() ?? false;
                        if (!isValid) {
                          return;
                        }
                        _authCubit.signIn(_email, _password, _rememberMe);
                      },
                      title: 'Login',
                    ),
                    const SizedBox(height: 15),
                    /*   const Divider(
                      color: Colors.black,
                    ),
                    const SizedBox(height: 15),
                    const Center(
                      child: Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 15),
                   CustomButton(
                      onTap: () async {
                        await launchUrl(
                          Uri.parse('https://getcube.shop/signup'),
                          mode: LaunchMode.externalApplication,
                        );
                        Navigator.pop(context);
                      },
                      title: 'Sign Up',
                    ),*/
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Future<bool?> showRestartAppDialouge() {
  //   return showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (ctx) => AlertDialog(
  //             content: Text('App needed to restart'),
  //             title: Text('Alert'),
  //             actions: [
  //               Center(
  //                   child: CustomButton(
  //                       title: 'ok',
  //                       onTap: () async {
  //                         Navigator.of(context).pop();
  //                         await DatabaseHelper().deleteTHEDatabase();
  //                       }))
  //             ],
  //           ));
  // }
}
