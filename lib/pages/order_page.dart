import 'package:end/pages/add_product_page.dart';
import 'package:end/pages/cart_page.dart';
import 'package:end/pages/product_list_page.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: 2, child: ProductListPage()),
          Expanded(flex: 1, child: CartPage()),
        ],
      ),
    );
  }
}
