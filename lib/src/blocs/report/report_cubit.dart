import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:magicstep/src/models/expense.dart';
import 'package:magicstep/src/models/input/report_input.dart';
import 'package:magicstep/src/models/order.dart';
import 'package:magicstep/src/models/report.dart';
import 'package:magicstep/src/pages/reports.dart';
import 'package:magicstep/src/services/report.dart';
import 'package:meta/meta.dart';

part 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportService _reportService = const ReportService();
  ReportCubit() : super(ReportInitial());

  ///
  void downloadReport(ReportInput input) async {
    emit(ReportLoading());
    final res = await _reportService.getAllReport(input);
    if (input.type == ReportType.sale) {
      _emitSalesReport(res);
    }
    if (input.type == ReportType.purchase) {
      _emitPurchaseReport(res);
    }
    if (input.type == ReportType.expense) {
      _emitExpenseReport(res);
    }
  }

  ///
  void getReport(ReportInput input) async {
    emit(ReportLoading());
    final res = await _reportService.getAllReport(input);
    if (input.type == ReportType.sale) {
      _emitSalesReport(res);
    }
    if (input.type == ReportType.purchase) {
      _emitPurchaseReport(res);
    }
    if (input.type == ReportType.expense) {
      _emitExpenseReport(res);
    }
  }

  _emitSalesReport(Response res, [bool isDownload = false]) {
    final data = res.data['sales'];
    final orders = data.map<Order>((item) => Order.fromMap(item)).toList();
    emit(isDownload
        ? ReportsDownload(orders: orders)
        : ReportsView(orders: orders));
  }

  _emitPurchaseReport(Response res, [bool isDownload = false]) {
    final data = res.data['purchase'];
    final orders =
        List.generate(data.length, (index) => Order.fromMap(data[index]));
    emit(isDownload
        ? ReportsDownload(orders: orders)
        : ReportsView(orders: orders));
  }

  _emitExpenseReport(Response res, [bool isDownload = false]) {
    final data = res.data['expense'];
    final expenses =
        List.generate(data.lenth, (index) => Expense.fromMap(data[index]));
    emit(isDownload
        ? ReportsDownload(expenses: expenses)
        : ReportsView(expenses: expenses));
  }
}
