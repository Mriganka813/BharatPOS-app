import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magicstep/src/blocs/expense/expense_cubit.dart';
import 'package:magicstep/src/config/colors.dart';
import 'package:magicstep/src/pages/create_expense.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';
import 'package:magicstep/src/widgets/expense_card_horizontal.dart';

class ExpensePage extends StatefulWidget {
  static const String routeName = '/expense';
  const ExpensePage({Key? key}) : super(key: key);

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  late final ExpenseCubit _expenseCubit;

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
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
          right: 10,
          bottom: 20,
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, CreateExpensePage.routeName);
            _expenseCubit.getExpense();
          },
          backgroundColor: ColorsConst.primaryColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        shrinkWrap: true,
        children: [
          const CustomTextField(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search',
          ),
          const Divider(color: Colors.transparent),
          BlocBuilder<ExpenseCubit, ExpenseState>(
            bloc: _expenseCubit,
            builder: (context, state) {
              if (state is ExpenseListRender) {
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
                      onDelete: () {
                        _expenseCubit.deleteExpense(state.expense[index]);
                      },
                      onEdit: () async {
                        await Navigator.pushNamed(
                          context,
                          CreateExpensePage.routeName,
                          arguments: state.expense[index].id,
                        );
                        _expenseCubit.getExpense();
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
        ],
      ),
    );
  }
}
