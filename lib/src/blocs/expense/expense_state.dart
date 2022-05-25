part of 'expense_cubit.dart';

@immutable
abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseListRender extends ExpenseState {
  final List<Expense> expense;
  ExpenseListRender(this.expense);
}

class ExpenseLoading extends ExpenseState {}

class ExpenseCreated extends ExpenseState {}

class ExpenseSuccess extends ExpenseState {}

class ExpenseCreationFailed extends ExpenseState {}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}
