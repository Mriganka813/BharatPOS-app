import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
// import 'package:magicstep/src/models/expense.dart';
// import 'package:magicstep/src/models/input/expense_input.dart';
import 'package:magicstep/src/models/report.dart';
// import 'package:magicstep/src/services/expense.dart';
import 'package:magicstep/src/services/report.dart';
import 'package:meta/meta.dart';

// import '../../models/report.dart';

part 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportService _reportService = const ReportService();
  ReportCubit() : super(ReportInitial());

  ///
  void getReport() async {
    emit(ReportLoading());
    final response = await _reportService.getAllReport();
    // print(response);
    if ((response.statusCode ?? 400) > 300) {
      emit(ReportError('Failed to get reports'));
      return;
    }
    final reports = List.generate(
      response.data['report'].length,
      (int index) => Report.fromMap(
        response.data['report'][index],
      ),
    );
    emit(ReportListRender(reports));
  }
}
