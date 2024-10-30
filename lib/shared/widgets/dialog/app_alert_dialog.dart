import 'package:flutter/material.dart';

class AppAlertDialog extends StatelessWidget {
  final Widget? content;

  const AppAlertDialog({super.key, this.content});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: content,
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
