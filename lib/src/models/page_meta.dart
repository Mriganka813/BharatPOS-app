class PageMeta {
  PageMeta({
    this.currentPage = 0,
    this.nextPage = 0,
    this.count = 0,
  });

  int currentPage;
  int? nextPage;
  int count;

  factory PageMeta.fromMap(Map<String, dynamic> json) => PageMeta(
        currentPage: json["currentPage"] ?? 0,
        nextPage: json["nextPage"],
        count: json["count"],
      );

  Map<String, dynamic> toMap() => {
        "currentPage": currentPage,
        "nextPage": nextPage,
        "count": count,
      };
}
