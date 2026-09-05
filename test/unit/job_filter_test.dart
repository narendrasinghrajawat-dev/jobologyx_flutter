import 'package:flutter_test/flutter_test.dart';
import 'package:jobologyx_flutter/features/jobs/models/job_filter.dart';

void main() {
  test('JobFilter.toQueryParams always sends page/limit/sort and omits unset optional fields', () {
    const empty = JobFilter();
    final emptyParams = empty.toQueryParams(page: 1, limit: 10);
    expect(emptyParams['page'], 1);
    expect(emptyParams['sort'], 'latest');
    expect(emptyParams.containsKey('jobType'), isFalse);
    expect(emptyParams.containsKey('mine'), isFalse);

    const filled = JobFilter(search: 'flutter', jobType: 'full_time', mine: true);
    final filledParams = filled.toQueryParams(page: 2, limit: 20);
    expect(filledParams['search'], 'flutter');
    expect(filledParams['jobType'], 'full_time');
    expect(filledParams['mine'], 'true');
    expect(filledParams.containsKey('workMode'), isFalse);
  });
}
