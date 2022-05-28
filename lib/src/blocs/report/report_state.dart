part of 'report_cubit.dart';

@immutable
abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportListRender extends ReportState {
  final List<Report> report;
  ReportListRender(this.report);
}

class ReportLoading extends ReportState {}

class ReportCreated extends ReportState {}

class ReportSuccess extends ReportState {}

class ReportsView extends ReportState {
  final List<Expense>? expenses;
  final List<Order>? orders;
  ReportsView({
    this.expenses,
    this.orders,
  });
}

class ReportsDownload extends ReportState {
  final List<Expense>? expenses;
  final List<Order>? orders;
  ReportsDownload({
    this.expenses,
    this.orders,
  });
}

class ReportCreationFailed extends ReportState {}

class ReportError extends ReportState {
  final String message;
  ReportError(this.message);
}
