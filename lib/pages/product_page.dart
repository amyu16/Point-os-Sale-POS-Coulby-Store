import 'package:end/widgets/add_product.dart';
import 'package:end/widgets/cart.dart';
import 'package:end/widgets/product_list.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: 2, child: ProductListPage()),
          Expanded(flex: 1, child: AddProductPage()),
        ],
      ),
    );
  }
}
