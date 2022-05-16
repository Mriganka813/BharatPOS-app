import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magicstep/src/blocs/auth/auth_cubit.dart';
import 'package:magicstep/src/config/colors.dart';
import 'package:magicstep/src/pages/home.dart';
import 'package:magicstep/src/pages/sign_up.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';

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
    _authCubit = AuthCubit();
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            bool isLoading = false;
            if (state is AuthLoading) {
              isLoading = true;
            }
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Log in",
                            style:
                                Theme.of(context).textTheme.headline3?.copyWith(
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
                        ),
                        const SizedBox(height: 60),
                        CustomTextField(
                          label: "Email ID",
                          hintText: 'name@company.com',
                          onSave: (e) {
                            _email = e!;
                          },
                        ),
                        const Divider(color: Colors.transparent),
                        Row(
                          children: [
                            Text(
                              "Password",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  ?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              "Forgot Password?",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  ?.copyWith(
                                    color: ColorsConst.primaryColor,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        CustomTextField(
                          onSave: (e) {
                            _password = e!;
                          },
                        ),
                        const SizedBox(height: 5),
                        Row(
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
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  ?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        CustomButton(
                          onTap: () {
                            _formKey.currentState?.save();
                            final isValid =
                                _formKey.currentState?.validate() ?? false;
                            if (!isValid) {
                              return;
                            }
                            _authCubit.signIn(_email, _password, _rememberMe);
                          },
                          title: 'Login',
                        ),
                        const SizedBox(height: 15),
                        const Divider(
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
                          onTap: () {
                            Navigator.pushNamed(context, SignUpPage.routeName);
                          },
                          title: 'Sign Up',
                        ),
                      ],
                    ),
                  ),
                ),

                /// Loading widget
                if (isLoading)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
