part of 'expense_cubit.dart';

@immutable
abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseListRender extends ExpenseState {
  final List<Expense> expense;
  ExpenseListRender(this.expense);
}
class ExpenseLoadingMore extends ExpenseState {
  final List<Expense> currentExpenses;
  ExpenseLoadingMore(this.currentExpenses);
}
class ExpenseListWithPagination extends ExpenseState {
  final List<Expense> expenses;
  final int currentPage;
  final bool hasMoreData;
  final int totalCount;

  ExpenseListWithPagination({
    required this.expenses,
    required this.currentPage,
    required this.hasMoreData,
    required this.totalCount,
  });
}
class ExpenseLoading extends ExpenseState {}

class ExpenseCreated extends ExpenseState {}

class ExpenseSuccess extends ExpenseState {}

class ExpenseCreationFailed extends ExpenseState {}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}
