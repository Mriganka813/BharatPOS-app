import 'package:magicstep/src/pages/reports.dart';

class ReportInput {
  ReportInput({
    this.startDate,
    this.endDate,
    this.type,
  });

  DateTime? startDate;
  DateTime? endDate;
  ReportType? type;

  Map<String, dynamic> toMap() => {
        "start_date": startDate?.toIso8601String(),
        "end_date": endDate?.toIso8601String(),
        "type": type.toString().split('.').last,
      };
}
