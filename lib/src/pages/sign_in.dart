import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/new_version.dart';
import 'package:shopos/src/blocs/auth/auth_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/pages/home.dart';
import 'package:shopos/src/pages/sign_up.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';
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
    //_checkUpdate();
    _authCubit = AuthCubit();
  }

  // Future<void> _checkUpdate() async {
  //   final newVersion = NewVersion(androidId: "com.shopos.magicstep");
  //   final status = await newVersion.getVersionStatus();
  //   if (status!.canUpdate) {
  //     newVersion.showUpdateDialog(
  //         context: context, versionStatus: status, allowDismissal: false);
  //   }
  // }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   elevation: 0,
      // ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
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
            return Scaffold(
              backgroundColor: Color.fromARGB(255, 194, 213, 225),
              body: Form(
                key: _formKey,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 600,
                        width: 500,
                        child: Card(
                          color: Colors.transparent,
                          elevation: 15,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(35.0),
                                      child: Text(
                                        "Shoppo",
                                        style: GoogleFonts.roboto(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w400,
                                            color: Color.fromARGB(
                                                255, 50, 75, 239)),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 70, right: 70, top: 25),
                                    child: CustomTextField(
                                      label: "Email ID",
                                      hintText: 'name@company.com',
                                      onSave: (e) {
                                        _email = e!;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 70, right: 70, top: 10),
                                    child: CustomTextField(
                                      label: "Password",
                                      onSave: (e) {
                                        _password = e!;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 65.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Transform.scale(
                                          scale: 0.8,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                            side: const BorderSide(
                                              color: ColorsConst.primaryColor,
                                              width: 1,
                                            ),
                                            fillColor:
                                                MaterialStateProperty.all(
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
                                        ),
                                        Text(
                                          "Remember me",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              ?.copyWith(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                      height: 40,
                                      width: 328,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color:
                                              Color.fromARGB(255, 39, 82, 252)),
                                      child: FlatButton(
                                          onPressed: () {
                                            _formKey.currentState?.save();
                                            final isValid = _formKey
                                                    .currentState
                                                    ?.validate() ??
                                                false;
                                            if (!isValid) {
                                              return;
                                            }
                                            _authCubit.signIn(
                                                _email, _password, _rememberMe);
                                          },
                                          child: Text("Log In",
                                              style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontSize: 15)))),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 25.0),
                                    child: Container(
                                        height: 60,
                                        width: 200,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.transparent),
                                        child: InkWell(
                                            onTap: () {
                                              launch(
                                                  "https://play.google.com/store/apps/details?id=com.shopos.magicstep");
                                            },
                                            child: Image.asset(
                                                "assets/icon/playstore.png"))),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 100.0, top: 25),
                            child: SizedBox(
                              height: 550,
                              // width: 500,
                              child: Card(
                                color: Colors.transparent,
                                elevation: 20,
                                child: Image.asset("assets/icon/pic2.png"),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 600,
                            //width: 500,
                            child: Card(
                              color: Colors.transparent,
                              elevation: 0,
                              child: Image.asset("assets/icon/pic1.png"),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
