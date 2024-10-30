import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:cpm_auto_click/model/plan.dart';
import 'package:cpm_auto_click/utils/date_formatter.dart';
import 'package:excel/excel.dart';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeViewModel with ChangeNotifier {
  String? errorMessage;
  List<String>? tabs;

  Sheet? _getExcelSheet(File excelFile, String sheetName) {
    var excel = Excel.decodeBytes(excelFile.readAsBytesSync());
    return excel.sheets[sheetName];
  }

  bool checkValidGPSDate(
      {required DateTime? gpsDate,
      required DateTime start,
      required DateTime end}) {
    if (gpsDate == null) return false;

    return gpsDate.compareTo(start) >= 0 && gpsDate.compareTo(end) <= 0;
  }

  Future<void> openTabWebInExcelByNumber({
    required File excelFile,
    required String sheetName,
    required DateTime start,
    required DateTime end,
    required int numberOfTab,
    required int colGPS,
    required int colWeb,
    required int colNameStaff,
  }) async {
    final sheet = _getExcelSheet(excelFile, sheetName);

    if (sheet == null) {
      errorMessage = 'Tên sheet không tồn tại';
      return notifyListeners();
    }

    try {
      final selectRows = sheet.rows.where((cols) {
        final gpsDate = DateFormatter.parse(
            ((cols[colGPS]?.value as TextCellValue?)?.value.text ?? '').trim());

        return checkValidGPSDate(gpsDate: gpsDate, start: start, end: end);
      }).toList();

      // Group staff by name
      final staffGroup = selectRows.groupListsBy(
          (cols) => (cols[colNameStaff]?.value as TextCellValue).value.text);

      final tabs = _getRandomTabsByNumber(
        staffGroup,
        numberOfTab,
        colWeb: colWeb,
      );
      await Future.forEach(
          tabs, (tab) async => await _launchUrl(Uri.parse(tab)));
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  List<String> _getRandomTabsByNumber(
    Map<String?, List<List<Data?>>> groupRows,
    int numberOfTab, {
    required int colWeb,
  }) {
    String? getRandomTab(List<List<Data?>> rows) {
      final randomIndex = Random().nextInt(rows.length);

      final hyperlink =
          (rows[randomIndex][colWeb]?.value as FormulaCellValue).formula;

      final url = (hyperlink
          .split('"')
          .firstWhereOrNull((element) => element.contains('https')));

      return url;
    }

    Set<String> result = <String>{};
    final targetTabs = (numberOfTab / groupRows.keys.length).round();

    //*get random tab for each group and add to result
    for (int index = 0; index < groupRows.keys.length; index++) {
      final rows = groupRows.entries.elementAt(index).value;

      for (int countTargetTab = 0;
          countTargetTab < targetTabs;
          countTargetTab++) {
        final tab = getRandomTab(rows);

        if (tab != null && !result.contains(tab)) {
          result.add(tab);
        }
      }
    }

    //*get additional tab and add to result to satisfy quantity conditions
    while (result.length < numberOfTab) {
      final randomIndex = Random().nextInt(groupRows.keys.length);
      final tab = getRandomTab(groupRows.entries.elementAt(randomIndex).value);

      if (tab != null && !result.contains(tab)) {
        result.add(tab);
      }
    }

    return result.toList();
  }

  Future<void> _launchUrl(Uri uri) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!await launchUrl(uri, webOnlyWindowName: '_self')) {
      errorMessage = 'Không thể mở tab: $uri';
      notifyListeners();
    }
  }

  List<String> _getRandomTabsByPlan(
    Map<String?, List<List<Data?>>> staffGroup, {
    required int indexColPlan,
    required int indexColWeb,
  }) {
    List<List<Data?>> selectedRows = [];

    // get rows for each staff
    staffGroup.forEach((_, rows) {
      String plan = '';

      try {
        plan =
            (rows.first[indexColPlan]?.value as TextCellValue?)?.value.text ??
                '';
        plan = plan.toLowerCase().trim();
      } catch (_) {
        plan = '';
      }

      final ratio = switch (plan) {
        Plan.green => 0.1,
        Plan.yellow => 0.15,
        Plan.red => 0.20,
        _ => 0.0
      };

      final numberOfTabs = (ratio * rows.length).round();

      final randomRows = List.of(rows);
      randomRows.shuffle();

      selectedRows.addAll(randomRows.take(numberOfTabs));
    });

    return selectedRows.map((row) {
      final hyperlink = (row[indexColWeb]?.value as FormulaCellValue).formula;

      final url = (hyperlink
          .split('"')
          .firstWhereOrNull((element) => element.contains('https')));

      return url ?? '';
    }).toList();
  }

  Future<void> calculateTabWebInExcelByPlan({
    required File excelFile,
    required String sheetName,
    required DateTime start,
    required DateTime end,
    required int colGPS,
    required int colWeb,
    required int colNameStaff,
    required int colPlan,
  }) async {
    final sheet = _getExcelSheet(excelFile, sheetName);

    if (sheet == null) {
      errorMessage = 'Tên sheet không tồn tại';
      return notifyListeners();
    }

    try {
      final selectRows = sheet.rows.where((cols) {
        final gpsDate = DateFormatter.parse(
            ((cols[colGPS]?.value as TextCellValue?)?.value.text ?? '').trim());

        return checkValidGPSDate(gpsDate: gpsDate, start: start, end: end);
      }).toList();

      // group by name staff
      final staffGroup = selectRows.groupListsBy(
          (cols) => (cols[colNameStaff]?.value as TextCellValue).value.text);

      tabs = _getRandomTabsByPlan(
        staffGroup,
        indexColPlan: colPlan,
        indexColWeb: colWeb,
      );

      showConfirmOpenTabs();
    } catch (error) {
      errorMessage = error.toString();
      tabs = null;
      notifyListeners();
    }
  }

  void showConfirmOpenTabs() {
    errorMessage = null;
    notifyListeners();
  }

  Future<void> confirmOpenTabs(bool? result) async {
    if (result ?? false) {
      await Future.forEach(
          tabs!, (tab) async => await _launchUrl(Uri.parse(tab)));
    }
  }

  Future<void> openTabByNameAndPercent(
      {required String nameStaff,
      required int percentTab,
      required File excelFile,
      required String sheetName,
      required DateTime start,
      required DateTime end,
      required int colGPS,
      required int colNameStaff,
      required int colWeb}) async {
    final sheet = _getExcelSheet(excelFile, sheetName);

    if (sheet == null) {
      errorMessage = 'Tên sheet không tồn tại';
      return notifyListeners();
    }

    try {
      final selectRows = sheet.rows.where((cols) {
        final gpsDate = DateFormatter.parse(
            ((cols[colGPS]?.value as TextCellValue?)?.value.text ?? '').trim());

        return checkValidGPSDate(gpsDate: gpsDate, start: start, end: end);
      }).toList();

      // group by name staff
      final staffGroup = selectRows.groupListsBy(
          (cols) => (cols[colNameStaff]?.value as TextCellValue).value.text);

      // remove another staff
      staffGroup.removeWhere((key, _) =>
          key!.toLowerCase().toString() != nameStaff.toLowerCase().toString());

      if (staffGroup.isEmpty) {
        throw 'Không tìm thấy tên nhân viên.';
      }

      final staffData = staffGroup.entries.toList().first.value;

      tabs = _getRandomTabsByNumber(
        staffGroup,
        (percentTab * staffData.length / 100).round(),
        colWeb: colWeb,
      );

      showConfirmOpenTabs();
    } catch (error) {
      errorMessage = error.toString();
      tabs = null;
      notifyListeners();
    }
  }
}
