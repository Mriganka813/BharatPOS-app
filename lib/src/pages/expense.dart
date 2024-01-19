import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopos/src/blocs/expense/expense_cubit.dart';
import 'package:shopos/src/blocs/report/report_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/pages/create_expense.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/services/set_or_change_pin.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/expense_card_horizontal.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pinCode;

class ExpensePage extends StatefulWidget {
  static const String routeName = '/expense';
  const ExpensePage({Key? key}) : super(key: key);

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  late final ExpenseCubit _expenseCubit;
  PinService _pinService = PinService();
  late final ReportCubit _reportCubit;
  final TextEditingController pinController = TextEditingController();

  ///
  @override
  void initState() {
    super.initState();
    _expenseCubit = ExpenseCubit()..getExpense();
  }

  @override
  void dispose() {
    _expenseCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense"),
        centerTitle: true,
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
          right: 10,
          bottom: 20,
        ),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.pushNamed(context, CreateExpensePage.routeName);
            _expenseCubit.getExpense();
          },
          backgroundColor: Colors.green,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          BlocBuilder<ExpenseCubit, ExpenseState>(
            bloc: _expenseCubit,
            builder: (context, state) {
              if (state is ExpenseListRender) {
                // print("line 76 in expense page");
                // print(state.expense.toString());
                state.expense.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
                return ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  itemCount: state.expense.length,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 5);
                  },
                  itemBuilder: (context, index) {
                    return ExpenseCardHorizontal(
                      expense: state.expense[index],
                      onDelete: () async {
                        var result = true;

                        if (await _pinService.pinStatus()==true) {
                          result = await _showPinDialog() as bool;
                        }
                        if (result!) {
                          _expenseCubit.deleteExpense(state.expense[index]);
                        } else {
                          Navigator.pop(context);
                          locator<GlobalServices>()
                              .errorSnackBar("Incorrect pin");
                        }
                      },
                      onEdit: () async {
                        var result = true;

                        if (await _pinService.pinStatus()==true) {
                          result = await _showPinDialog() as bool;
                        }
                        if (result!) {
                          await Navigator.pushNamed(
                            context,
                            CreateExpensePage.routeName,
                            arguments: state.expense[index].id,
                          );
                          _expenseCubit.getExpense();
                        } else {
                          Navigator.pop(context);
                          locator<GlobalServices>()
                              .errorSnackBar("Incorrect pin");
                        }
                      },
                    );
                  },
                );
              }
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ColorsConst.primaryColor,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<bool?> _showPinDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              content: pinCode.PinCodeTextField(
                autoDisposeControllers: false,
                appContext: context,
                length: 6,
                obscureText: true,
                obscuringCharacter: '*',
                blinkWhenObscuring: true,
                animationType: pinCode.AnimationType.fade,
                keyboardType: TextInputType.number,
                pinTheme: pinCode.PinTheme(
                  shape: pinCode.PinCodeFieldShape.underline,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 40,
                  fieldWidth: 30,
                  inactiveColor: Colors.black45,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  selectedColor: Colors.black45,
                  disabledColor: Colors.black,
                  activeFillColor: Colors.white,
                ),
                cursorColor: Colors.black,
                controller: pinController,
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
              ),
              title: Text('Enter your pin'),
              actions: [
                Center(
                    child: CustomButton(
                        title: 'Verify',
                        onTap: () async {
                          bool status = await _pinService.verifyPin(
                              int.parse(pinController.text.toString()));
                          if (status) {
                            pinController.clear();
                            Navigator.of(ctx).pop(true);
                          } else {
                            Navigator.of(ctx).pop(false);
                            pinController.clear();

                            return;
                          }
                        }))
              ],
            ));
  }
}
