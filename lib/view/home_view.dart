import 'dart:io';

import 'package:cpm_auto_click/shared/widgets/button/app_button.dart';
import 'package:cpm_auto_click/shared/widgets/dialog/app_alert_dialog.dart';
import 'package:cpm_auto_click/shared/widgets/dialog/app_confirm_dialog.dart';
import 'package:cpm_auto_click/shared/widgets/gap.dart';
import 'package:cpm_auto_click/utils/date_formatter.dart';
import 'package:cpm_auto_click/view/home_view_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late HomeViewModel _homeViewModel;

  late TextEditingController _sheetNameTextController;
  late TextEditingController _numberOfTabTextController;
  late TextEditingController _staffIdTextController;
  late TextEditingController _percentTabsTextEditingController;

  late TextEditingController _colWebTextController;
  late TextEditingController _colStaffIdTextController;
  late TextEditingController _colGPSTextController;
  late TextEditingController _colPlanTextController;

  File? _excelFile;
  DateTimeRange? _gpsRangeTime;

  @override
  void initState() {
    super.initState();

    _sheetNameTextController = TextEditingController(text: 'DATA_DETAILS');
    _numberOfTabTextController = TextEditingController(text: '0');
    _staffIdTextController = TextEditingController();

    _colGPSTextController = TextEditingController(text: 'G');
    _colPlanTextController = TextEditingController(text: 'J');
    _colWebTextController = TextEditingController(text: 'H');
    _colStaffIdTextController = TextEditingController(text: 'E');
    _percentTabsTextEditingController = TextEditingController(text: '0');

    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _homeViewModel = context.read<HomeViewModel>()..addListener(listener));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('* Mở links trong excel',
                    style: TextStyle(fontSize: 20)),
                const Text(
                    'Kiểm tra vị trí các cột trước khi sử dụng:'),
                SizedBox(
                  width: double.infinity,
                  child: GridView(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 5,
                      crossAxisCount: 2,
                    ),
                    children: [
                      _ColumnTextField(
                          label: 'Mã NV: ',
                          controller: _colStaffIdTextController),
                      _ColumnTextField(
                          label: 'GPS Time / Ngày: ',
                          controller: _colGPSTextController),
                      _ColumnTextField(
                          label: 'Vào web: ',
                          controller: _colWebTextController),
                      _ColumnTextField(
                          label: 'Kế hoạch: ',
                          controller: _colPlanTextController)
                    ],
                  ),
                ),
                const Gap(ratio: 1),
                Row(
                  children: [
                    AppButton(
                      onPressed: () => _handlePickExcelFile(),
                      label: "Chọn file excel",
                    ),
                    Expanded(
                      child: Text(
                        '  ${_excelFile?.name ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Gap(ratio: 1),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AppButton(
                      onPressed: _handlePickGPSTime,
                      label: "Chọn GPS Time/Ngày",
                    ),
                    _GPSRangeTime(value: _gpsRangeTime),
                  ],
                ),
                const Gap(ratio: 3),
                TextField(
                  controller: _sheetNameTextController,
                  decoration: const InputDecoration(label: Text('Tên sheet')),
                ),
                const Gap(ratio: 1),
                TextField(
                  controller: _numberOfTabTextController,
                  decoration: const InputDecoration(
                    label: Text('Số links cần mở'),
                  ),
                ),
                const Gap(ratio: 1),
                Wrap(
                  children: [
                    AppButton(
                      onPressed: _handleOpenTabByNumber,
                      label: "Mở theo số lượng links",
                    ),
                    const Gap(direction: GapDirection.horizontal),
                    AppButton(
                      onPressed: _handleOpenTabByPlan,
                      label: "Mở theo kế hoạch",
                    ),
                  ],
                ),
                const Gap(ratio: 3),
                TextField(
                  controller: _staffIdTextController,
                  decoration: const InputDecoration(label: Text('Mã NV')),
                ),
                const Gap(ratio: 1),
                TextField(
                  controller: _percentTabsTextEditingController,
                  decoration: const InputDecoration(
                      label: Text(
                    '% tab muốn mở',
                  )),
                ),
                const Gap(ratio: 1),
                AppButton(
                  onPressed: _handleOpenTabByNameAndPercent,
                  label: "Mở theo mã NV",
                ),
                const Gap(ratio: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sheetNameTextController.dispose();
    _numberOfTabTextController.dispose();
    _colGPSTextController.dispose();
    _colPlanTextController.dispose();
    _colWebTextController.dispose();
    _colStaffIdTextController.dispose();
    _staffIdTextController.dispose();
    _percentTabsTextEditingController.dispose();
    _homeViewModel.removeListener(listener);

    super.dispose();
  }

  void listener() {
    if (_homeViewModel.errorMessage != null) {
      showDialog(
        context: context,
        builder: (context) =>
            AppAlertDialog(content: Text(_homeViewModel.errorMessage!)),
      );
      return;
    }

    if (_homeViewModel.tabs != null) {
      showDialog(
        context: context,
        builder: (context) => AppConfirmDialog(
            content: Text('Xác nhận mở ${_homeViewModel.tabs!.length} tabs')),
      ).then((result) => _homeViewModel.confirmOpenTabs(result as bool?));
    }
  }

  Future<void> _handlePickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    File file = File(result.files.single.path!);
    if (!file.isExcelFile()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AppAlertDialog(
          content: Text("File excel không hợp lệ."),
        ),
      );
      _excelFile = null;

      return;
    } else {
      _excelFile = file;
    }

    setState(() {});
  }

  Future<void> _handlePickGPSTime() async {
    _gpsRangeTime = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2026, 1, 1),
    );

    setState(() {});
  }

  void showWarningOverloadNumberTab() {
    showDialog(
        context: context,
        builder: (context) => const AppAlertDialog(
              content: Text("Số lượng links không hợp lệ"),
            ));
  }

  void showInvalidInputData() {
    showDialog(
        context: context,
        builder: (context) => const AppAlertDialog(
            content: Text("Dữ liệu nhập chưa hợp lệ")));
  }

  String get sheetName => _sheetNameTextController.text;
  int? get numberTab => int.tryParse(_numberOfTabTextController.text) ?? 0;

  int? get colPlan => _colPlanTextController.text.indexColumnInExcel();
  int? get colGPS => _colGPSTextController.text.indexColumnInExcel();
  int? get colWeb => _colWebTextController.text.indexColumnInExcel();
  int? get colStaffId => _colStaffIdTextController.text.indexColumnInExcel();

  void _handleOpenTabByNumber() {
    if (sheetName.isEmpty ||
        numberTab == null ||
        _gpsRangeTime == null ||
        _excelFile == null ||
        colGPS == null ||
        colWeb == null ||
        colStaffId == null) {
      return showInvalidInputData();
    }

    if (numberTab! > 100 || numberTab == 0) {
      return showWarningOverloadNumberTab();
    }

    _homeViewModel.openTabWebInExcelByNumber(
      excelFile: _excelFile!,
      sheetName: sheetName,
      start: _gpsRangeTime!.start,
      end: _gpsRangeTime!.end,
      numberOfTab: numberTab!,
      colGPS: colGPS!,
      colStaffId: colStaffId!,
      colWeb: colWeb!,
    );
  }

  void _handleOpenTabByPlan() {
    if (sheetName.isEmpty ||
        _gpsRangeTime == null ||
        _excelFile == null ||
        colGPS == null ||
        colWeb == null ||
        colStaffId == null ||
        colPlan == null) {
      return showInvalidInputData();
    }

    _homeViewModel.calculateTabWebInExcelByPlan(
      excelFile: _excelFile!,
      sheetName: sheetName,
      start: _gpsRangeTime!.start,
      end: _gpsRangeTime!.end,
      colGPS: colGPS!,
      colStaffId: colStaffId!,
      colPlan: colPlan!,
      colWeb: colWeb!,
    );
  }

  void _handleOpenTabByNameAndPercent() {
    final percentTab =
        int.tryParse(_percentTabsTextEditingController.text) ?? 0;
    final staffId = _staffIdTextController.text;

    if (staffId.isEmpty == true ||
        percentTab == 0 ||
        _gpsRangeTime == null ||
        sheetName.isEmpty ||
        _excelFile == null ||
        colGPS == null ||
        colWeb == null ||
        colStaffId == null) {
      return showInvalidInputData();
    }

    _homeViewModel.openTabByNameAndPercent(
      staffId: staffId,
      percentTab: percentTab,
      excelFile: _excelFile!,
      sheetName: sheetName,
      start: _gpsRangeTime!.start,
      end: _gpsRangeTime!.end,
      colGPS: colGPS!,
      colStaffId: colStaffId!,
      colWeb: colWeb!,
    );
  }
}

class _GPSRangeTime extends StatelessWidget {
  final DateTimeRange? value;
  const _GPSRangeTime({this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox();

    final start = DateFormatter.format(value!.start);
    final end = DateFormatter.format(value!.end);

    return (start == end) ? Text('  $start') : Text('  $start  ->  $end ');
  }
}

class _ColumnTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _ColumnTextField({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        SizedBox(
          width: 50,
          child: TextField(
            controller: controller,
            onChanged: (text) {
              controller.text = text.trim().toUpperCase();
            },
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(),
          ),
        ),
      ],
    );
  }
}

extension on File {
  bool isExcelFile() {
    final fileExtension = path.split('.').last.toLowerCase();
    return ['xlsx', 'xlsm', 'xlsb', 'xls', 'xltx', 'xltm', 'xlts', 'xlt']
        .contains(fileExtension);
  }
}

extension on File {
  String get name => path.split('/').last.toLowerCase();
}

extension on String {
  int? indexColumnInExcel() {
    const mapIndex = {
      'A': 0,
      'B': 1,
      'C': 2,
      'D': 3,
      'E': 4,
      'F': 5,
      'G': 6,
      'H': 7,
      'I': 8,
      'J': 9,
      'K': 10,
      'L': 11,
      'M': 12,
      'N': 13,
      'O': 14,
      'P': 15,
      'Q': 16,
      'R': 17,
      'S': 18,
      'T': 19,
      'U': 20,
      'V': 21,
      'W': 22,
      'X': 23,
      'Y': 24,
      'Z': 25
    };
    return mapIndex[this];
  }
}

// extension on int {
//   int? tryParse(String text) {
//     try {
//       int value = int.parse(text);
//       return value;
//     } catch (err) {
//       return null;
//     }
//   }
// }
