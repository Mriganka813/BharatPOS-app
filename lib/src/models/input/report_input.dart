import 'package:shopos/src/pages/reports.dart';

class ReportInput {
  ReportInput({
    this.startDate,
    this.endDate,
    this.type,
  });

  DateTime? startDate;
  DateTime? endDate;
  ReportType? type;

  Map<String, dynamic> toMap() {
    final endDateString = (endDate)
        ?.add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1))
        .toIso8601String();

    return {
      "start_date": startDate?.toUtc().toIso8601String(),
      "end_date": endDateString,
      "type": type.toString().split('.').last,
    };
  }
}
