class PayslipFailure implements Exception {
  const PayslipFailure(this.message);
  final String message;

  @override
  String toString() => message;
}
