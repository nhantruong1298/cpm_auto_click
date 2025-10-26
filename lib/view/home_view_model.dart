import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:cpm_auto_click/utils/date_formatter.dart';
import 'package:cpm_auto_click/view/home_view_state.dart';
import 'package:excel/excel.dart';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/common.dart';

class HomeViewModel with ChangeNotifier {
  HomeViewState _state = HomeViewInitial();
  HomeViewState get state => _state;

  Future<Sheet?> _getExcelSheet(File excelFile, String sheetName) async {
    // This is a compute-intensive operation, so we run it in a separate isolate.
    return await compute(_getExcelSheetIsolate, {
      'bytes': excelFile.readAsBytesSync(),
      'sheetName': sheetName,
    });
  }

  // This must be a top-level function or a static method to be used with compute.
  static Sheet? _getExcelSheetIsolate(Map<String, Object> params) {
    final excel = Excel.decodeBytes(params['bytes'] as List<int>);
    return excel.sheets[params['sheetName'] as String];
  }

  Future<void> openTabWebInExcelByNumber({
    required File excelFile,
    required String sheetName,
    required DateTime start,
    required DateTime end,
    required int numberOfTab,
    required int colGPS,
    required int indexColWeb,
    required int indexColStaffId,
  }) async {
    _state = HomeViewLoading();
    notifyListeners();

    try {
      final sheet = await _getExcelSheet(excelFile, sheetName);

      if (sheet == null) {
        _state = const HomeViewError('Không tìm thấy file');
        return notifyListeners();
      }

      //get rows within date range
      final rows = sheet.rows.where((row) {
        final gpsDate = DateFormatter.parse(
            ((row[colGPS]?.value as TextCellValue?)?.value.text ?? '').trim());

        return checkValidGPSDate(gpsDate: gpsDate, start: start, end: end);
      }).toList();

      // Group rows by staff id
      final groupRows = rows.groupListsBy(
          (cols) => (cols[indexColStaffId]?.value as TextCellValue).value.text);

      final tabs = _getRandomTabsByNumber(
        groupRows: groupRows,
        numberOfTab: numberOfTab,
        indexColWeb: indexColWeb,
      );

      _state = HomeViewSuccess(tabs, showConfirmOpenTabs: false);
      notifyListeners();
    } catch (error) {
      _state = HomeViewError(error.toString());
      notifyListeners();
    }
  }

  List<String> _getRandomTabsByNumber({
    required Map<String?, List<List<Data?>>> groupRows,
    required int numberOfTab,
    required int indexColWeb,
  }) {
    String? getRandomTab(List<List<Data?>> rows) {
      final randomIndex = Random().nextInt(rows.length);

      final hyperlink =
          (rows[randomIndex][indexColWeb]?.value as FormulaCellValue).formula;

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
      _state = HomeViewError('Không thể mở tab: $uri');
      notifyListeners();
    }
  }

  Future<void> onOpenTabs(List<String> tabs) async {
    try {
      if (tabs.isNotEmpty) {
        await Future.forEach(
            tabs, (tab) async => await _launchUrl(Uri.parse(tab)));
      }
    } catch (error) {
      _state = HomeViewError(error.toString());
      notifyListeners();
    }
  }

  Future<void> openTabByNameAndPercent(
      {required String staffId,
      required int percentTab,
      required File excelFile,
      required String sheetName,
      required DateTime start,
      required DateTime end,
      required int colGPS,
      required int colStaffId,
      required int indexColWeb}) async {
    _state = HomeViewLoading();
    notifyListeners();

    try {
      final sheet = await _getExcelSheet(excelFile, sheetName);

      if (sheet == null) {
        _state = const HomeViewError('Không tìm thấy file');
        return notifyListeners();
      }

      final rows = sheet.rows.where((cols) {
        final gpsDate = DateFormatter.parse(
            ((cols[colGPS]?.value as TextCellValue?)?.value.text ?? '').trim());

        return checkValidGPSDate(gpsDate: gpsDate, start: start, end: end);
      }).toList();

      // group by name staff
      final originalGroups = rows.groupListsBy(
        (cols) => (cols[colStaffId]?.value as TextCellValue).value.text,
      );

      final normalizedStaffId = staffId.trim().toLowerCase();

      final staffEntry = originalGroups.entries.firstWhereOrNull(
          (e) => (e.key ?? '').trim().toLowerCase() == normalizedStaffId);

      if (staffEntry == null || staffEntry.value.isEmpty) {
        throw Exception('Không tìm thấy mã NV.');
      }

      final tabs = _getRandomTabsByNumber(
        groupRows: {staffEntry.key: staffEntry.value},
        numberOfTab: (percentTab * staffEntry.value.length / 100).round(),
        indexColWeb: indexColWeb,
      );

      _state = HomeViewSuccess(tabs);
      notifyListeners();
    } catch (error) {
      _state = HomeViewError(error.toString());
      notifyListeners();
    }
  }
}
