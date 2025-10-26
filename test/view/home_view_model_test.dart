import 'package:cpm_auto_click/utils/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  setUp(() {
  });

  test(
      'checkValidGPSDate'
      ' with gpsDate equal null', () {
    final result = checkValidGPSDate(
        gpsDate: null, start: DateTime.now(), end: DateTime.now());

    expect(false, result);
  });

  test(
      'checkValidGPSDate'
      ' with gpsDate >  startDate'
      ' and gpsDate < endDate', () {
    // given
    var gpsDate = DateTime.now();
    var start = DateTime.now().subtract(const Duration(days: 1));
    var end = DateTime.now().add(const Duration(days: 1));

    // when
    final result = checkValidGPSDate(
        gpsDate: gpsDate, start: start, end: end);

    // then
    expect(true, result);
  });

  test(
      'checkValidGPSDate'
      ' with gpsDate = startDate'
      ' and gpsDate = endDate', () {
    // given
    var gpsDate = DateTime.now();
    var start = gpsDate;
    var end = gpsDate;

    // when
    final result = checkValidGPSDate(
        gpsDate: gpsDate, start: start, end: end);

    // then
    expect(true, result);
  });

  test(
      'checkValidGPSDate'
      ' with gpsDate < startDate', () {
    // given
    var gpsDate = DateTime.now().subtract(const Duration(days: 1));
    var start = DateTime.now();
    var end = DateTime.now();

    // when
    final result = checkValidGPSDate(
        gpsDate: gpsDate, start: start, end: end);

    // then
    expect(false, result);
  });

  test(
      'checkValidGPSDate'
      ' with gpsDate > endDate', () {
    // given
    var gpsDate = DateTime.now();
    var start = DateTime.now().subtract(const Duration(days: 2));
    var end = DateTime.now().subtract(const Duration(days: 1));

    // when
    final result = checkValidGPSDate(
        gpsDate: gpsDate, start: start, end: end);

    // then
    expect(false, result);
  });
}
