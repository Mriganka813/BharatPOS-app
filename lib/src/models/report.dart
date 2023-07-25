class Report {
  Report({
    this.reportName,
    this.startDate,
    this.endDate,
    this.id,
    this.createdAt,
  });

  String? reportName;
  String? startDate;
  String? endDate;
  String? id;
  DateTime? createdAt;

  factory Report.fromMap(Map<String, dynamic> json) => Report(
        reportName: json["reportName"],
        startDate: json["startDate"],
        endDate: json["endDate"],
        id: json["_id"],
        createdAt: DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toMap() => {
        "reportName": reportName,
        "startDate": startDate,
        "endDate": endDate,
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
      };
}
