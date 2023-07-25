import 'package:dio/dio.dart';
import 'package:shopos/src/models/input/expense_input.dart';
import 'package:shopos/src/services/api_v1.dart';

class ExpenseService {
  const ExpenseService();

  Future<Response> createExpense(ExpenseFormInput input) async {
    final response =
        await ApiV1Service.postRequest('/add/expense', data: input.toMap());
    return response;
  }

  ///
  Future<Response> updateExpense(ExpenseFormInput input) async {
    final response = await ApiV1Service.putRequest(
      '/update/expense/${input.id}',
      data: input.toMap(),
    );
    return response;
  }

  ///
  Future<Response> getAllExpense() async {
    final response = await ApiV1Service.getRequest('/expense/all');
    return response;
  }

  ///
  Future<Response> getExpenseById(String id) async {
    final response = await ApiV1Service.getRequest('/expense/$id');
    return response;
  }

  ///

  Future<Response> deleteExpense(String id) async {
    final response = await ApiV1Service.deleteRequest('/del/expense/$id');
    return response;
  }
}
