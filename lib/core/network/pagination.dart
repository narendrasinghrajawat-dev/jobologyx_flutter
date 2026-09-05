/// The `{ page, limit, total, totalPages }` shape returned alongside every
/// paginated list endpoint (jobs, applications, admin lists) — one shared
/// type instead of redefining it per feature.
class Pagination {
  const Pagination({required this.page, required this.limit, required this.total, required this.totalPages});

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json["page"] as int,
      limit: json["limit"] as int,
      total: json["total"] as int,
      totalPages: json["totalPages"] as int,
    );
  }
}
