import 'package:flutter/material.dart';

class AppConfirmDialog extends StatelessWidget {
  final Widget? content;

  const AppConfirmDialog({super.key, this.content});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: content,
      actions: <Widget>[
        TextButton(
          child: const Text('Không'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        TextButton(
          child: const Text('Có'),
          onPressed: () {
            // Do something upon confirmation
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
