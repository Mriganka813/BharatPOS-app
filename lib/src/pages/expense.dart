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
import 'package:shopos/src/widgets/custom_text_field.dart';
import 'package:shopos/src/widgets/expense_card_horizontal.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pinCode;

import '../models/expense.dart';

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
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ///
  @override
  void initState() {
    super.initState();
    _expenseCubit = ExpenseCubit()..getExpenseWithSearch();

    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _expenseCubit.loadMoreExpenses();
      }
    });
  }

  @override
  void dispose() {
    _expenseCubit.close();
    _scrollController.dispose();
    searchController.dispose();
    pinController.dispose();
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
            // Refresh current search results
            _expenseCubit.getExpenseWithSearch(keyword: searchController.text);
          },
          backgroundColor: Colors.green,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomTextField(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search expenses...',
              onChanged: (String value) async {
                // Add small delay to avoid too many API calls
                await Future.delayed(const Duration(milliseconds: 300));
                  _expenseCubit.searchExpenses(value);
              },
            ),
          ),

          // Expense List
          Expanded(
            child: BlocBuilder<ExpenseCubit, ExpenseState>(
              bloc: _expenseCubit,
              builder: (context, state) {
                if (state is ExpenseLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ColorsConst.primaryColor,
                      ),
                    ),
                  );
                }

                if (state is ExpenseError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(fontSize: 16, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _expenseCubit.getExpenseWithSearch(),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ExpenseListWithPagination || state is ExpenseLoadingMore) {
                  List<Expense> expenses = [];
                  bool hasMoreData = false;
                  bool isLoadingMore = false;

                  if (state is ExpenseListWithPagination) {
                    expenses = state.expenses;
                    hasMoreData = state.hasMoreData;
                  } else if (state is ExpenseLoadingMore) {
                    expenses = state.currentExpenses;
                    isLoadingMore = true;
                    hasMoreData = true;
                  }

                  if (expenses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            searchController.text.isEmpty
                                ? 'No expenses found'
                                : 'No expenses found for "${searchController.text}"',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: expenses.length + (hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show loading indicator at the end if loading more
                      if (index == expenses.length) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorsConst.primaryColor,
                              ),
                            ),
                          ),
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        child: ExpenseCardHorizontal(
                          expense: expenses[index],
                          onDelete: () async {
                            var result = true;
                            bool x = await _pinService.pinStatus();
                            if (x == true) {
                              result = await _showPinDialog() as bool;
                            }
                            if (result!) {
                              _expenseCubit.deleteExpense(expenses[index]);
                            } else {
                              Navigator.pop(context);
                              locator<GlobalServices>()
                                  .errorSnackBar("Incorrect pin");
                            }
                          },
                          onEdit: () async {
                            bool? result = true;
                            bool x = await _pinService.pinStatus();
                            if (x == true) {
                              result = await _showPinDialog() as bool;
                            }
                            if (result!) {
                              await Navigator.pushNamed(
                                context,
                                CreateExpensePage.routeName,
                                arguments: expenses[index].id,
                              );
                              // Refresh current search results
                              _expenseCubit.getExpenseWithSearch(keyword: searchController.text);
                            } else {
                              Navigator.pop(context);
                              locator<GlobalServices>()
                                  .errorSnackBar("Incorrect pin");
                            }
                          },
                        ),
                      );
                    },
                  );
                }

                // Fallback for other states
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorsConst.primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
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