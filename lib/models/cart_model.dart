class Cart {
  int id;
  String productId;
  String productName;
  int subTotal;
  int productPrice;
  int quantity;
  String unitTag;

  Cart({
    required this.id,
    required this.productId,
    required this.productName,
    required this.subTotal,
    required this.productPrice,
    required this.quantity,
    required this.unitTag,
  });

  // Konversi objek Cart menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'subTotal': subTotal,
      'productPrice': productPrice,
      'quantity': quantity,
      'unitTag': unitTag,
    };
  }

  // Konversi Map menjadi objek Cart
  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id'],
      productId: map['productId'],
      productName: map['productName'],
      subTotal: map['subTotal'],
      productPrice: map['productPrice'],
      quantity: map['quantity'],
      unitTag: map['unitTag'],
    );
  }
}