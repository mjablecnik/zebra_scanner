class HandOverInfo {
  final String orderId;
  final String sender;
  final String receiver;
  final String address;
  final String phone;
  final String deliveryType;
  final DateTime date;

  HandOverInfo({
    required this.orderId,
    required this.sender,
    required this.receiver,
    required this.address,
    required this.phone,
    required this.deliveryType,
    required this.date,
  });
}
