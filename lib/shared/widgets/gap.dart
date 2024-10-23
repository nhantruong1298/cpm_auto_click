import 'package:flutter/material.dart';

enum GapDirection { vertical, horizontal }

class Gap extends StatelessWidget {
  final double ratio;
  final GapDirection direction;

  const Gap({
    super.key,
    this.ratio = 1,
    this.direction = GapDirection.vertical,
  }) : assert(ratio >= 0);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: direction == GapDirection.horizontal ? ratio * 16 : null,
      height: direction == GapDirection.vertical ? ratio * 16 : null,
    );
  }
}
