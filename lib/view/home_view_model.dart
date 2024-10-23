import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:excel/excel.dart';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeViewModel with ChangeNotifier {
  String? errorMessage;

  Future<void> openTabWebInExcel({
    required File excelFile,
    required String sheetName,
    required DateTime gpsTime,
    required int numberOfTab,
  }) async {
    var excel = Excel.decodeBytes(excelFile.readAsBytesSync());

    if (!excel.sheets.containsKey(sheetName)) {
      errorMessage = 'Tên sheet không tồn tại';
      notifyListeners();
      return;
    }

    final gpsTimeString = DateFormat('yyyy-MM-dd').format(gpsTime).toString();

    final sheet = excel.sheets[sheetName];
    final selectRows = sheet!.rows.where((columns) {
      //*Check column G (GPS Time/Ngày)
      const columnG = 6;
      final validGPSTimeCol =
          (columns[columnG]?.value as TextCellValue).value.text?.trim() ==
              gpsTimeString;

      //*Check column I (Kết quả thực hiện)
      const columnI = 8;
      final validResultCol =
          (columns[columnI]?.value as TextCellValue).value.text?.trim() ==
              'Thành công';

      return validGPSTimeCol && validResultCol;
    }).toList();

    //*Group by column F (tên NV)
    const columnF = 5;
    final groupRows = selectRows.groupListsBy(
        (columns) => (columns[columnF]?.value as TextCellValue).value.text);

    final tabs = _getRandomTabs(groupRows, numberOfTab);
    await Future.forEach(tabs, (tab) async => await _launchUrl(Uri.parse(tab)));
  }

  List<String> _getRandomTabs(
    Map<String?, List<List<Data?>>> groupRows,
    int numberOfTab,
  ) {
    String? getRandomTab(List<List<Data?>> rows) {
      //*Index of column H (Nơi chứ URL)
      const columnH = 7;
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
    await Future.delayed(const Duration(milliseconds: 200));
    if (!await launchUrl(uri, webOnlyWindowName: '_self')) {
      errorMessage = 'Could not launch $uri';
      notifyListeners();
    }
  }
}
