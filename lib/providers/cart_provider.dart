import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:end/helpers/db_helper.dart';
import 'package:end/models/cart_model.dart';

class CartProvider with ChangeNotifier {
  
  DBHelper db = DBHelper();
  int _counter = 0;
  int get counter => _counter;

  double _totalPrice = 0.0;
  double get totalPrice => _totalPrice;

  late List<Cart> _cart;
  List<Cart> get cart => _cart;

  CartProvider() {
    getData();
  }

  Future<void> getData() async {
    _cart = await db.getCartList(); // Await the Future<List<Cart>> result
    updateTotalPrice();
  }

  Future<void> _setPrefItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cart_item', _counter);
    await prefs.setDouble('total_price', _totalPrice);
    notifyListeners();
  }

  Future<void> _getPrefItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('cart_item') ?? 0;
    _totalPrice = prefs.getDouble('total_price') ?? 0;
    notifyListeners();
  }

  void addCounter() {
    _counter++;
    _setPrefItems();
    notifyListeners();
  }

  void incrementQuantity(Cart item) {
    item.quantity++;
    item.subTotal = item.productPrice * item.quantity; // Perbarui subtotal
    db.update(item); // Perbarui item di database
    updateTotalPrice(); // Perbarui total harga
    _setPrefItems();
    notifyListeners();
  }

  void decrementQuantity(Cart item) {
    if (item.quantity > 1) {
      item.quantity--;
      item.subTotal = item.productPrice * item.quantity; // Perbarui subtotal
      db.update(item); // Perbarui item di database
      updateTotalPrice(); // Perbarui total harga
      _setPrefItems();
      notifyListeners();
    }
  }

  Future<void> updateTotalPrice() async {
    List<Cart> cartItems = await db.getCartList();
    double total = 0.0;
    for (var item in cartItems) {
      item.subTotal = item.productPrice * item.quantity; // Perbarui subtotal
      total += item.subTotal!;
    }
    _totalPrice = total;
    _setPrefItems();
    notifyListeners();
  }

  void removeCounter() {
    if (_counter > 0) {
      _counter--;
      _setPrefItems();
      notifyListeners();
    }
  }

  int getCounter() {
    _getPrefItems();
    return _counter;
  }

  void addTotalPrice(double productPrice) {
    _totalPrice += productPrice;
    _setPrefItems();
    notifyListeners();
  }

  double getTotalPrice() {
    return _totalPrice;
  }

  void removeItem(Cart item) {
    db.delete(item.id!);
    getData();
    _setPrefItems();
    notifyListeners();
  }

  void resetTotalPrice() {
    _totalPrice = 0;
    _setPrefItems();
    notifyListeners();
  }

  void resetCounter() {
    _counter = 0;
    _setPrefItems();
    notifyListeners();
  }

  void clearCart() {
    db.clearCart();
    getData();
    _setPrefItems();
    notifyListeners();
  }
}
