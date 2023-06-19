class Report {
  static int _lastId = 0; // Track the last assigned id
  int id;
  String cartName;
  int totalItems;
  double totalPrice;
  String timestamp;

  Report({
    required this.cartName,
    required this.totalItems,
    required this.totalPrice,
    required this.timestamp,
  }) : id = ++_lastId; // Assign the next id value and increment _lastId

  // Convert Report object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cartName': cartName,
      'totalItems': totalItems,
      'totalPrice': totalPrice,
      'timestamp': timestamp,
    };
  }

  // Convert Map to Report object
  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      cartName: map['cartName'],
      totalItems: map['totalItems'],
      totalPrice: map['totalPrice'],
      timestamp: map['timestamp'],
    );
  }
}
