import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:shopos/src/models/expense.dart';
import 'package:shopos/src/models/input/expense_input.dart';
import 'package:shopos/src/services/expense.dart';

part 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseService _expenseService = const ExpenseService();
  ExpenseCubit() : super(ExpenseInitial());

  ///
  void getExpense() async {
    emit(ExpenseLoading());
    final response = await _expenseService.getAllExpense();
    // print(response);
    if ((response.statusCode ?? 400) > 300) {
      emit(ExpenseError('Failed to get expenses'));
      return;
    }
    final expenses = List.generate(
      response.data['allExpense'].length,
      (int index) => Expense.fromMap(
        response.data['allExpense'][index],
      ),
    );
    emit(ExpenseListRender(expenses));
  }

  ///
  void createExpense(ExpenseFormInput expense) async {
    emit(ExpenseLoading());
    try {
      final response = expense.id == null
          ? await _expenseService.createExpense(expense)
          : await _expenseService.updateExpense(expense);
      if ((response.statusCode ?? 400) > 300) {
        emit(ExpenseError(response.data['message']));
        return;
      }
    } on DioError catch (err) {
      emit(ExpenseError(err.response?.data['message'] ?? err.message));
    }
    emit(ExpenseCreated());
  }

  ///
  void deleteExpense(Expense expense) async {
    try {
      final response =
          await _expenseService.deleteExpense(expense.id.toString());
      if ((response.statusCode ?? 400) > 300) {
        emit(ExpenseError(response.data['message']));
        return;
      }
    } on DioError catch (err) {
      emit(ExpenseError(err.message.toString()));
    }
    getExpense();
  }
}
