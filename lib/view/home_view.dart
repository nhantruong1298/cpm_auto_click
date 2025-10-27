import 'dart:io';

import 'package:cpm_auto_click/shared/widgets/button/app_button.dart';
import 'package:cpm_auto_click/shared/widgets/dialog/app_alert_dialog.dart';
import 'package:cpm_auto_click/shared/widgets/gap.dart';
import 'package:cpm_auto_click/utils/date_formatter.dart';
import 'package:cpm_auto_click/view/home_view_model.dart';
import 'package:cpm_auto_click/view/home_view_state.dart';
import 'package:cpm_auto_click/view/widgets/loading_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/widgets/dialog/app_confirm_dialog.dart';

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

  File? _excelFile;
  DateTimeRange? _gpsRangeTime;

  @override
  void initState() {
    super.initState();

    _sheetNameTextController = TextEditingController(text: 'DATA_DETAILS');
    _staffIdTextController = TextEditingController(text: '');
    _numberOfTabTextController = TextEditingController(text: '10');
    _percentTabsTextEditingController = TextEditingController(text: '10');

    _colGPSTextController = TextEditingController(text: 'U');
    _colWebTextController = TextEditingController(text: 'AB');
    _colStaffIdTextController = TextEditingController(text: 'O');

    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _homeViewModel = context.read<HomeViewModel>()..addListener(listener));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeViewModel>().state;

    return Scaffold(
      body: LoadingView(
        isLoading: state is HomeViewLoading,
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
                            childAspectRatio: 5, crossAxisCount: 2),
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
                    ],
                  ),
                ),
                const Gap(ratio: 1),
                Row(
                  children: [
                    AppButton(
                        onPressed: () => _handlePickExcelFile(),
                        label: "Chọn file excel"),
                    Expanded(
                      child: Text('  ${_excelFile?.name ?? ''}',
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const Gap(ratio: 1),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppButton(
                      onPressed: _handlePickGPSTime,
                      label: "Chọn GPS Time/Ngày",
                    ),
                    _GPSRangeTime(value: _gpsRangeTime)
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
                  decoration:
                      const InputDecoration(label: Text('% tab muốn mở')),
                ),
                const Gap(ratio: 1),
                AppButton(
                    onPressed: _handleOpenTabByNameAndPercent,
                    label: "Mở theo mã NV"),
                const Gap(ratio: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void listener() {
    switch (_homeViewModel.state) {
      case HomeViewSuccess():
        {
          final state = _homeViewModel.state as HomeViewSuccess;
          final tabs = state.tabs;
          if (!state.showConfirmOpenTabs) {
            _homeViewModel.onOpenTabs(tabs);
            return;
          }

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AppConfirmDialog(
              content:
                  Text('Bạn có chắc chắn muốn mở ${tabs.length} tab không?'),
            ),
          ).then((confirmed) {
            if (confirmed == true) {
              _homeViewModel.onOpenTabs(tabs);
            }
          });
          break;
        }
      case HomeViewError():
        {
          final message = (_homeViewModel.state as HomeViewError).message;
          showDialog(
            context: context,
            builder: (context) => AppAlertDialog(content: Text(message)),
          );
          break;
        }
      default:
        break;
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
      indexColStaffId: colStaffId!,
      indexColWeb: colWeb!,
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
      indexColWeb: colWeb!,
    );
  }

  @override
  void dispose() {
    _sheetNameTextController.dispose();
    _numberOfTabTextController.dispose();
    _colGPSTextController.dispose();
    _colWebTextController.dispose();
    _colStaffIdTextController.dispose();
    _colStaffIdTextController.dispose();
    _percentTabsTextEditingController.dispose();
    _homeViewModel.removeListener(listener);

    super.dispose();
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
            onChanged: (text) {},
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
      'Z': 25,
      'AA': 26,
      'AB': 27,
      'AC': 28,
      'AD': 29,
      'AE': 30,
      'AF': 31,
      'AG': 32,
      'AH': 33,
      'AI': 34,
      'AJ': 35,
      'AK': 36,
      'AL': 37,
      'AM': 38,
      'AN': 39,
      'AO': 40,
      'AP': 41,
      'AQ': 42,
      'AR': 43,
      'AS': 44,
      'AT': 45,
      'AU': 46,
      'AV': 47,
      'AW': 48,
      'AX': 49,
      'AY': 50,
      'AZ': 51,
      'BA': 52,
      'BB': 53,
      'BC': 54,
      'BD': 55,
      'BE': 56,
      'BF': 57,
      'BG': 58,
      'BH': 59,
      'BI': 60,
      'BJ': 61,
      'BK': 62,
      'BL': 63,
      'BM': 64,
      'BN': 65,
      'BO': 66,
      'BP': 67,
      'BQ': 68,
      'BR': 69,
      'BS': 70,
      'BT': 71,
      'BU': 72,
      'BV': 73,
      'BW': 74,
      'BX': 75,
      'BY': 76,
      'BZ': 77,
      'CA': 78,
      'CB': 79,
      'CC': 80,
      'CD': 81,
      'CE': 82,
      'CF': 83,
      'CG': 84,
      'CH': 85,
      'CI': 86,
      'CJ': 87,
      'CK': 88,
      'CL': 89,
      'CM': 90,
      'CN': 91,
      'CO': 92,
      'CP': 93,
      'CQ': 94,
      'CR': 95,
      'CS': 96,
      'CT': 97,
      'CU': 98,
      'CV': 99,
      'CW': 100,
      'CX': 101,
    };
    return mapIndex[trim().toUpperCase()];
  }
}
