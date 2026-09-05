/// Bundles every `GET /jobs` query param so the provider can hold one
/// object instead of a pile of loose fields. `toQueryParams()` drops empty
/// values so Dio never sends `location=` etc.
class JobFilter {
  const JobFilter({
    this.search = "",
    this.location = "",
    this.jobType,
    this.workMode,
    this.category,
    this.experience,
    this.salaryMin,
    this.salaryMax,
    this.sort = "latest",
    this.mine = false,
  });

  final String search;
  final String location;
  final String? jobType;
  final String? workMode;
  final String? category;
  final String? experience;
  final num? salaryMin;
  final num? salaryMax;
  final String sort;

  /// Recruiter-only: scopes the listing to jobs they created, any status.
  final bool mine;

  bool get hasActiveFilters =>
      location.isNotEmpty ||
      jobType != null ||
      workMode != null ||
      category != null ||
      experience != null ||
      salaryMin != null ||
      salaryMax != null;

  JobFilter copyWith({
    String? search,
    String? location,
    String? jobType,
    bool clearJobType = false,
    String? workMode,
    bool clearWorkMode = false,
    String? category,
    bool clearCategory = false,
    String? experience,
    bool clearExperience = false,
    num? salaryMin,
    bool clearSalaryMin = false,
    num? salaryMax,
    bool clearSalaryMax = false,
    String? sort,
    bool? mine,
  }) {
    return JobFilter(
      search: search ?? this.search,
      location: location ?? this.location,
      jobType: clearJobType ? null : (jobType ?? this.jobType),
      workMode: clearWorkMode ? null : (workMode ?? this.workMode),
      category: clearCategory ? null : (category ?? this.category),
      experience: clearExperience ? null : (experience ?? this.experience),
      salaryMin: clearSalaryMin ? null : (salaryMin ?? this.salaryMin),
      salaryMax: clearSalaryMax ? null : (salaryMax ?? this.salaryMax),
      sort: sort ?? this.sort,
      mine: mine ?? this.mine,
    );
  }

  /// Resets every filter field but keeps the current search text and sort —
  /// matches the filter sheet's "Clear" action, which only touches filters.
  JobFilter clearFilterFields() => JobFilter(search: search, sort: sort, mine: mine);

  Map<String, dynamic> toQueryParams({required int page, required int limit}) {
    final params = <String, dynamic>{"page": page, "limit": limit, "sort": sort};
    if (search.isNotEmpty) params["search"] = search;
    if (location.isNotEmpty) params["location"] = location;
    if (jobType != null) params["jobType"] = jobType;
    if (workMode != null) params["workMode"] = workMode;
    if (category != null) params["category"] = category;
    if (experience != null) params["experience"] = experience;
    if (salaryMin != null) params["salaryMin"] = salaryMin;
    if (salaryMax != null) params["salaryMax"] = salaryMax;
    if (mine) params["mine"] = "true";
    return params;
  }
}
