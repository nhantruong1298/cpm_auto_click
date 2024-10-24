import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:cpm_auto_click/model/plan.dart';
import 'package:excel/excel.dart';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeViewModel with ChangeNotifier {
  String? errorMessage;

  //*Column G (GPS Time/Ngày)
  final columnG = 6;

  //*Column H (Vào web)
  final columnH = 7;

  // //*Column I (Kết quả thực hiện)
  // final columnI = 8;

  //*Column F (tên NV)
  final columnF = 5;

  //*Column J (Kế hoạch)
  final columnJ = 9;

  String _parseDateToString(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date).toString();
  }

  Sheet? _getExcelSheet(File excelFile, String sheetName) {
    var excel = Excel.decodeBytes(excelFile.readAsBytesSync());
    return excel.sheets[sheetName];
  }

  Future<void> openTabWebInExcelByNumber({
    required File excelFile,
    required String sheetName,
    required DateTime gpsTime,
    required int numberOfTab,
  }) async {
    var sheet = _getExcelSheet(excelFile, sheetName);

    if (sheet == null) {
      errorMessage = 'Tên sheet không tồn tại';
      return notifyListeners();
    }

    final gpsTimeString = _parseDateToString(gpsTime);

    final selectRows = sheet.rows.where((columns) {
      final validGPSTimeCol =
          (columns[columnG]?.value as TextCellValue).value.text?.trim() ==
              gpsTimeString;

      return validGPSTimeCol;
    }).toList();

    final groupRows = selectRows.groupListsBy(
        (columns) => (columns[columnF]?.value as TextCellValue).value.text);

    final tabs = _getRandomTabsByNumber(groupRows, numberOfTab);
    await Future.forEach(tabs, (tab) async => await _launchUrl(Uri.parse(tab)));
  }

  List<String> _getRandomTabsByNumber(
    Map<String?, List<List<Data?>>> groupRows,
    int numberOfTab,
  ) {
    String? getRandomTab(List<List<Data?>> rows) {
      final randomIndex = Random().nextInt(rows.length);

      final hyperlink =
          (rows[randomIndex][columnH]?.value as FormulaCellValue).formula;

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
      errorMessage = 'Could not launch $uri';
      notifyListeners();
    }
  }

  List<String> _getRandomTabsByPlan(Map<String?, List<List<Data?>>> groupRows) {
    List<List<Data?>> selectedRows = [];

    groupRows.forEach((_, rows) {
      String plan = '';

      try {
        plan = (rows.first[columnJ]?.value as TextCellValue?)?.value.text ?? '';
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

      final numberOfTabs = (ratio * rows.length).ceil();

      final randomRows = List.of(rows);
      randomRows.shuffle();

      selectedRows.addAll(randomRows.take(numberOfTabs));
    });

    return selectedRows.map((row) {
      final hyperlink = (row[columnH]?.value as FormulaCellValue).formula;

      final url = (hyperlink
          .split('"')
          .firstWhereOrNull((element) => element.contains('https')));

      return url ?? '';
    }).toList();
  }

  Future<void> openTabWebInExcelByPlan({
    required File excelFile,
    required String sheetName,
    required DateTime gpsTime,
  }) async {
    var sheet = _getExcelSheet(excelFile, sheetName);

    if (sheet == null) {
      errorMessage = 'Tên sheet không tồn tại';
      return notifyListeners();
    }

    final gpsTimeString = _parseDateToString(gpsTime);

    final selectRows = sheet.rows.where((columns) {
      final validGPSTimeCol =
          ((columns[columnG]?.value as TextCellValue?)?.value.text ?? '')
                  .trim() ==
              gpsTimeString;

      return validGPSTimeCol;
    }).toList();

    final groupRows = selectRows.groupListsBy(
        (columns) => (columns[columnF]?.value as TextCellValue).value.text);

    final tabs = _getRandomTabsByPlan(groupRows);

    await Future.forEach(tabs, (tab) async => await _launchUrl(Uri.parse(tab)));
  }
}
