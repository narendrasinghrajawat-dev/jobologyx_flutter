import 'package:flutter_test/flutter_test.dart';
import 'package:jobologyx_flutter/core/utils/formatters.dart';

void main() {
  test('Formatters formats snake_case labels and salary ranges correctly', () {
    expect(Formatters.snakeCaseToTitle('job_seeker'), 'Job Seeker');
    expect(Formatters.snakeCaseToTitle('full_time'), 'Full Time');

    expect(Formatters.salaryRange(50000, 80000), '\$50k - \$80k');
    expect(Formatters.salaryRange(0, 100000), 'Up to \$100k');
    expect(Formatters.salaryRange(0, 0), 'Salary not disclosed');
  });
}
