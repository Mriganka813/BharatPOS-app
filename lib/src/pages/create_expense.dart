import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopos/src/blocs/expense/expense_cubit.dart';
import 'package:shopos/src/blocs/product/product_cubit.dart';
import 'package:shopos/src/models/input/expense_input.dart';
import 'package:shopos/src/services/expense.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_drop_down.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';

class CreateExpensePage extends StatefulWidget {
  static const String routeName = '/create_expense';
  final String? id;
  const CreateExpensePage({Key? key, this.id}) : super(key: key);

  @override
  State<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  late final ExpenseCubit _expenseCubit;
  final _formKey = GlobalKey<FormState>();
  late ExpenseFormInput _formInput;

  @override
  void initState() {
    super.initState();
    _formInput = ExpenseFormInput();
    _expenseCubit = ExpenseCubit();
    _fetchExpenseData();
  }

  void _fetchExpenseData() async {
    ExpenseFormInput? expenseInput;
    if (widget.id == null) {
      return;
    }
    try {
      final response = await const ExpenseService().getExpenseById(widget.id!);
      expenseInput = ExpenseFormInput.fromMap(response.data['expense']);
    } on DioError catch (err) {
      log(err.message.toString());
    }
    if (expenseInput == null) {
      return;
    }
    setState(() {
      _formInput = expenseInput!;
    });
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
        title: const Text("Create Expense"),
        centerTitle: true,
      ),
      body: Form(
          key: _formKey,
          child: BlocListener<ExpenseCubit, ExpenseState>(
            bloc: _expenseCubit,
            listener: (context, state) {
              if (state is ExpenseCreated) {
                return Navigator.pop(context, true);
              }
              if (state is ExpenseError) {
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
            child: BlocBuilder<ExpenseCubit, ExpenseState>(
              bloc: _expenseCubit,
              builder: (context, state) {
                bool isLoading = false;
                if (state is ProductLoading) {
                  isLoading = true;
                }
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: 'Header',
                            value: _formInput.header,
                            onSave: (e) {
                              _formInput.header = e;
                            },
                          ),
                          const Divider(color: Colors.transparent),
                          CustomTextField(
                            label: 'Amount',
                            value: _formInput.amount,
                            inputType: TextInputType.phone,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                            ],
                            onSave: (e) {
                              _formInput.amount = e;
                              _formInput.createdAt = DateTime.now();
                            },
                          ),
                          const Divider(color: Colors.transparent),
                          CustomTextField(
                            label: 'Description',
                            hintText: "Optional",
                            value: _formInput.description,
                            validator: (e) => null,
                            onSave: (e) {
                              _formInput.description = e;
                            },
                          ),
                          const Divider(color: Colors.transparent, height: 20),
                          CustomDropDownField(
                            items: const ['Cash', 'Bank Transfer'],
                            onSelected: (e) {
                              _formInput.modeOfPayment = e;
                            },
                            initialValue: _formInput.modeOfPayment,
                            hintText: 'Mode of Payment',
                          ),
                          const Spacer(),
                          CustomButton(
                            title: 'Save',
                            onTap: () {
                              _formKey.currentState?.save();
                              if (_formKey.currentState?.validate() ?? false) {
                                _expenseCubit.createExpense(_formInput);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
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
          )),
    );
  }
}
