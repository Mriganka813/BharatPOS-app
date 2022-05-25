import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:magicstep/src/models/expense.dart';
import 'package:magicstep/src/models/input/expense_input.dart';
import 'package:magicstep/src/services/expense.dart';
import 'package:meta/meta.dart';

part 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseService _expenseService = const ExpenseService();
  ExpenseCubit() : super(ExpenseInitial());

  ///
  void getExpense() async {
    emit(ExpenseLoading());
    final response = await _expenseService.getAllExpense();
    if ((response.statusCode ?? 400) > 300) {
      emit(ExpenseError('Failed to get products'));
      return;
    }
    final expenses = List.generate(
      response.data['expenses'].length,
      (int index) => Expense.fromMap(
        response.data['expenses'][index],
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
  void deleteProduct(Expense expense) async {
    try {
      final response =
          await _expenseService.deleteExpense(expense.id.toString());
      if ((response.statusCode ?? 400) > 300) {
        emit(ExpenseError(response.data['message']));
        return;
      }
    } on DioError catch (err) {
      emit(ExpenseError(err.message));
    }
    getExpense();
  }
}
