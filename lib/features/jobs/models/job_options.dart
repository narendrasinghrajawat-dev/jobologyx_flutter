import '../../../core/widgets/app_dropdown.dart';

/// Static option lists shared by the job filter sheet (Phase 3) and the
/// recruiter create/edit job form (Phase 5) — kept in one place so both
/// screens always send the exact same enum values the backend expects.
class JobOptions {
  JobOptions._();

  static const List<AppDropdownOption<String>> jobTypes = [
    AppDropdownOption("full_time", "Full Time"),
    AppDropdownOption("part_time", "Part Time"),
    AppDropdownOption("contract", "Contract"),
    AppDropdownOption("internship", "Internship"),
    AppDropdownOption("freelance", "Freelance"),
  ];

  static const List<AppDropdownOption<String>> workModes = [
    AppDropdownOption("onsite", "On-site"),
    AppDropdownOption("remote", "Remote"),
    AppDropdownOption("hybrid", "Hybrid"),
  ];

  /// The backend stores `experience` as a free-form string, so this is just
  /// a curated, consistent set of values rather than a schema enum.
  static const List<AppDropdownOption<String>> experienceLevels = [
    AppDropdownOption("Entry Level", "Entry Level"),
    AppDropdownOption("1-3 years", "1-3 years"),
    AppDropdownOption("3-5 years", "3-5 years"),
    AppDropdownOption("5-10 years", "5-10 years"),
    AppDropdownOption("10+ years", "10+ years"),
  ];

  /// The backend has no categories endpoint — this is a curated static list
  /// used both to filter and (in Phase 5) to tag a job on creation.
  static const List<AppDropdownOption<String>> categories = [
    AppDropdownOption("Engineering", "Engineering"),
    AppDropdownOption("Design", "Design"),
    AppDropdownOption("Product", "Product"),
    AppDropdownOption("Marketing", "Marketing"),
    AppDropdownOption("Sales", "Sales"),
    AppDropdownOption("Data", "Data"),
    AppDropdownOption("Customer Support", "Customer Support"),
    AppDropdownOption("Operations", "Operations"),
  ];

  static const List<AppDropdownOption<String>> sortOptions = [
    AppDropdownOption("latest", "Newest First"),
    AppDropdownOption("oldest", "Oldest First"),
    AppDropdownOption("salaryHigh", "Salary: High to Low"),
    AppDropdownOption("salaryLow", "Salary: Low to High"),
  ];
}
