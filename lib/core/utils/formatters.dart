/// Text formatting helpers shared across job/application/admin list screens.
class Formatters {
  Formatters._();

  /// "job_seeker" -> "Job Seeker", "full_time" -> "Full Time".
  static String snakeCaseToTitle(String value) {
    if (value.isEmpty) return value;
    return value.split("_").map((word) => word.isEmpty ? word : "${word[0].toUpperCase()}${word.substring(1)}").join(" ");
  }

  /// Compact salary like "$50k" / "$1.2M" — falls back to the raw number for
  /// small values so it doesn't read oddly for e.g. hourly rates.
  static String compactCurrency(num value) {
    if (value <= 0) return "0";
    if (value >= 1000000) return "\$${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M";
    if (value >= 1000) return "\$${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k";
    return "\$${value.toStringAsFixed(0)}";
  }

  /// "$50k - $80k", or a single-sided range, or "Salary not disclosed".
  static String salaryRange(num min, num max) {
    if (min <= 0 && max <= 0) return "Salary not disclosed";
    if (min <= 0) return "Up to ${compactCurrency(max)}";
    if (max <= 0) return "From ${compactCurrency(min)}";
    return "${compactCurrency(min)} - ${compactCurrency(max)}";
  }

  /// "Just now" / "3h ago" / "5d ago" / "Mar 12, 2026" for anything older
  /// than a month — no dependency needed for something this small.
  static String relativeDate(DateTime? date) {
    if (date == null) return "";
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inHours < 1) return "${diff.inMinutes}m ago";
    if (diff.inDays < 1) return "${diff.inHours}h ago";
    if (diff.inDays < 30) return "${diff.inDays}d ago";
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }
}
