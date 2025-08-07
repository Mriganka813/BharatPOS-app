import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:shopos/src/models/expense.dart';
import 'package:shopos/src/models/input/expense_input.dart';
import 'package:shopos/src/services/expense.dart';

part 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseService _expenseService = const ExpenseService();

  // Pagination and search variables
  int _currentPage = 1;
  String _currentKeyword = '';
  bool _hasMoreData = true;
  List<Expense> _allExpenses = [];

  ExpenseCubit() : super(ExpenseInitial());

  ///
  void getExpense() async {
    emit(ExpenseLoading());
    final response = await _expenseService.getAllExpense();
    print("getting expense in expense cubit");
    print(response);
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

  /// New method for search and pagination
  void getExpenseWithSearch({
    String keyword = '',
    int page = 1,
    bool isLoadMore = false,
  }) async {
    if (!isLoadMore) {
      emit(ExpenseLoading());
      _currentPage = 1;
      _allExpenses.clear();
    } else {
      emit(ExpenseLoadingMore(_allExpenses));
    }

    _currentKeyword = keyword;

    try {
      final response = await _expenseService.getAllExpenseAndSearch(
        keyword: keyword,
        page: page,
        limit: 10,
      );

      if ((response.statusCode ?? 400) > 300) {
        emit(ExpenseError('Failed to get expenses'));
        return;
      }

      final newExpenses = List.generate(
        response.data['expenses'].length,
            (int index) => Expense.fromMap(
          response.data['expenses'][index],
        ),
      );

      if (isLoadMore) {
        _allExpenses.addAll(newExpenses);
      } else {
        _allExpenses = newExpenses;
      }

      _currentPage = response.data['page'];
      final totalCount = response.data['totalCount'];
      _hasMoreData = _allExpenses.length < totalCount;

      emit(ExpenseListWithPagination(
        expenses: List.from(_allExpenses),
        currentPage: _currentPage,
        hasMoreData: _hasMoreData,
        totalCount: totalCount,
      ));

    } on DioError catch (err) {
      emit(ExpenseError(err.response?.data['message'] ?? err.message));
    }
  }

  /// Load more expenses
  void loadMoreExpenses() {
    if (_hasMoreData && state is! ExpenseLoadingMore) {
      getExpenseWithSearch(
        keyword: _currentKeyword,
        page: _currentPage + 1,
        isLoadMore: true,
      );
    }
  }

  /// Search expenses
  void searchExpenses(String keyword) {
    getExpenseWithSearch(keyword: keyword, page: 1, isLoadMore: false);
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
    // Refresh current search results instead of getting all expenses
    getExpenseWithSearch(keyword: _currentKeyword, page: 1, isLoadMore: false);
  }
}