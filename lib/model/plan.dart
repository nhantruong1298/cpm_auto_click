class Plan {
  static const Plan red =  Plan._('đỏ');
  static const Plan yellow =  Plan._('vàng');
  static const Plan green = Plan._('xanh');

  const Plan._(this.text);
  final String text;
}
