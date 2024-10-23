import 'dart:io';

import 'package:cpm_auto_click/shared/widgets/dialogs/app_alert_dialog.dart';
import 'package:cpm_auto_click/shared/widgets/gap.dart';
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
  File? _excelFile;
  DateTime? _gpsTime;

  @override
  void initState() {
    super.initState();

    _sheetNameTextController = TextEditingController();
    _numberOfTabTextController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _homeViewModel = context.read<HomeViewModel>()..addListener(listener));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('* Mở link trong excel',
                        style: TextStyle(fontSize: 20)),
                    const _NoteForOpenWebInExcel()
                  ],
                ),
                const Gap(ratio: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    MaterialButton(
                      onPressed: () => _handlePickExcelFile(),
                      color: Colors.amber[500],
                      child: const Text("Chọn file excel"),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    MaterialButton(
                      onPressed: _handlePickGPSTime,
                      color: Colors.amber[500],
                      child: const Text("Chọn GPS Time/Ngày"),
                    ),
                    Text('  ${_gpsTime?.toLocal() ?? ''}'),
                  ],
                ),
                const Gap(ratio: 1),
                TextField(
                  controller: _sheetNameTextController,
                  decoration: const InputDecoration(label: Text('Tên sheet')),
                ),
                const Gap(ratio: 1),
                TextField(
                  controller: _numberOfTabTextController,
                  decoration: const InputDecoration(
                    label: Text('Số lượng tab cần mở'),
                  ),
                ),
                const Gap(ratio: 2),
                MaterialButton(
                  onPressed: _handleOpenTabWebInExcel,
                  color: Colors.amber[500],
                  child: const Text("Mở"),
                ),
                const Gap(ratio: 1),
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
    _homeViewModel.removeListener(listener);
    super.dispose();
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
    _gpsTime = await showDatePicker(
      context: context,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2025, 1, 1),
    );

    setState(() {});
  }

  int? parseNumberOfTabWeb(String text) {
    try {
      int value = int.parse(text);
      return value;
    } catch (err) {
      showDialog(
        context: context,
        builder: (context) => const AppAlertDialog(
          content: Text('Số lượng tab không hợp lệ'),
        ),
      );
      return null;
    }
  }

  void _handleOpenTabWebInExcel() {
    var sheetName = _sheetNameTextController.text;
    var numberTab = parseNumberOfTabWeb(_numberOfTabTextController.text);

    if (sheetName.isEmpty ||
        numberTab == null ||
        _gpsTime == null ||
        _excelFile == null) {
      showDialog(
          context: context,
          builder: (context) => const AppAlertDialog(
                content: Text("Dữ liệu nhập không hợp lệ"),
              ));
      return;
    }

    if (numberTab > 50) {
      showDialog(
          context: context,
          builder: (context) => const AppAlertDialog(
                content: Text("Số lượng tab quá nhiều"),
              ));
      return;
    }

    _homeViewModel.openTabWebInExcel(
        excelFile: _excelFile!,
        sheetName: sheetName,
        gpsTime: _gpsTime!,
        numberOfTab: numberTab);
  }

  void listener() {
    var errorMessage = _homeViewModel.errorMessage;

    if (errorMessage != null) {
      showDialog(
        context: context,
        builder: (context) => AppAlertDialog(content: Text(errorMessage)),
      );
    }
  }
}

class _NoteForOpenWebInExcel extends StatelessWidget {
  const _NoteForOpenWebInExcel({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Text(
          '''Kiểm tra vị trí các cột trước khi sử dụng:
        Cột H: Vào web 
        Cột F: Tên NV 
        Cột I: Kết quả thực hiện 
        Cột G: GPS Time / Ngày 

      ''',
          textAlign: TextAlign.start,
        )
      ],
    );
  }
}

extension CheckExcelFile on File {
  bool isExcelFile() {
    final fileExtension = path.split('.').last.toLowerCase();
    return ['xlsx', 'xlsm', 'xlsb', 'xls', 'xltx', 'xltm', 'xlts', 'xlt']
        .contains(fileExtension);
  }
}

extension on File {
  String get name => path.split('/').last.toLowerCase();
}
