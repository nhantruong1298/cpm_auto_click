import 'package:cpm_auto_click/view/home_view.dart';
import 'package:cpm_auto_click/view/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showSemanticsDebugger: false,
      debugShowCheckedModeBanner: false,
      title: 'Tools',
      

      home: ChangeNotifierProvider(
        create: (_) => HomeViewModel(),
        child: const HomeView(),
      ),
    );
  }
}
