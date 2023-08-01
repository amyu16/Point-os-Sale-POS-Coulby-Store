import 'package:end/helpers/db_helper.dart';
import 'package:end/pages/product_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:end/models/cart_model.dart';
import 'package:end/models/product_model.dart';
import 'package:end/providers/cart_provider.dart';
import 'package:end/controller/main_warapper_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:end/models/report_model.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  DBHelper? dbHelper = DBHelper();
  TextEditingController paymentController = TextEditingController();
  double change = 0.0;

  @override
  void initState() {
    super.initState();
  }

  void goToProductTab() {
    MainWrapperController controller = Get.find<MainWrapperController>();
    controller.goToTab(0);
  }

  void _removeCartItem(Cart item, CartProvider cartProvider) {
    cartProvider.removeItem(item);
    cartProvider.resetCounter();
    cartProvider.updateTotalPrice();
  }

  Future<void> _deleteAllItems(CartProvider cartProvider) async {
    cartProvider.clearCart();
    cartProvider.resetTotalPrice();
    cartProvider.resetCounter();
    cartProvider.updateTotalPrice();
  }

  final String assetName = 'assets/Line 1.svg';

  void _checkout(double totalPrice, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Checkout',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(0, 42, 110, 1)),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter payment amount:',
                style: TextStyle(color: Color.fromRGBO(0, 42, 110, 1)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromRGBO(229, 232, 243, 1),
                  ),
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    controller: paymentController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Color.fromRGBO(255, 224, 224, 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(10))),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color.fromRGBO(253, 122, 122, 1),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Color.fromRGBO(52, 127, 235, 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(10))),
              onPressed: () async {
                double paymentAmount = double.parse(paymentController.text);
                if (paymentAmount >= totalPrice) {
                  // Generate a formatted timestamp using current device's locale
                  String formattedDate =
                      DateFormat.yMd().format(DateTime.now());
                  int totalCartItems = await dbHelper!.getCartItemsCount();

                  Report report = Report(
                    cartName: 'Cart', // Concatenate id with 'Cart'
                    totalItems: totalCartItems,
                    totalPrice: totalPrice,
                    timestamp: formattedDate,
                  );

                  //pemanggilan fungsi update stock
                  List<Cart> cartItems = await dbHelper!.getCartItems()!;
                  for (Cart item in cartItems) {
                    int productId = int.parse(item.productId);
                    await dbHelper?.updateProductStock(
                        productId, item.quantity);
                  }

                  //menghapus seluruh cart
                  await _deleteAllItems(cartProvider);
                  setState(() {
                    change = paymentAmount - totalPrice;
                  });
                  await dbHelper?.insertReport(report);

                  Navigator.pop(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Insufficient Payment'),
                        content:
                            const Text('The payment amount is not enough.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Pay'),
            ),
          ],
        );
      },
    );
  }

  void _incrementQuantity(Cart item, CartProvider cartProvider) async {
    Product product = await dbHelper!.getProductById(int.parse(item.productId));

    setState(() {
      if (item.quantity < product.stock) {
        cartProvider.incrementQuantity(item);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: const Text(
                'Maximum Stock Reached',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(255, 118, 118, 1),
                ),
              ),
              content: const Text(
                'You have reached the maximum stock limit for this item.',
                style: TextStyle(
                  color: Color.fromRGBO(0, 42, 110, 1),
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Color.fromRGBO(52, 127, 235, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _decrementQuantity(Cart item, CartProvider cartProvider) {
    setState(() {
      cartProvider.decrementQuantity(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: 80,
      //   leading: IconButton(
      //     icon: Icon(color: Color.fromRGBO(0, 42, 110, 1), Icons.arrow_back),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      //   backgroundColor: Colors.white,
      //   title: Text(
      //       style: TextStyle(
      //           color: Color.fromRGBO(0, 42, 110, 1),
      //           fontWeight: FontWeight.bold,
      //           fontSize: 24),
      //       'Cart'),
      //   elevation: 0,
      // ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Container(
          margin: const EdgeInsets.only(right: 20),
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -2),
                color: Color.fromRGBO(132, 181, 255, 0.3),
                blurRadius: 30,
              )
            ],
            color: Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 40, bottom: 20),
                child: Text(
                    style: TextStyle(
                        color: Color.fromRGBO(0, 42, 110, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                    'Cart'),
              ),
              Expanded(
                child: FutureBuilder<List<Cart>>(
                  future: dbHelper?.getCartItems(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final cartItems = snapshot.data!;
                      final bool hasItems = cartItems.isNotEmpty;

                      return ListView.builder(
                        itemCount: cartItems.length + 1,
                        itemBuilder: (context, index) {
                          if (index == cartItems.length) {
                            return ListTile();
                          }

                          Cart item = cartItems[index];

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Card(
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(9),
                                          color:
                                              Color.fromRGBO(52, 127, 235, 1)),
                                      alignment: Alignment.center,
                                      height: 50,
                                      width: 50,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          (index + 1).toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 30,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName.toString(),
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    0, 42, 110, 1),
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "Rp. ${item.productPrice} /${item.unitTag}",
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    117, 140, 177, 1),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            _removeCartItem(item, cartProvider);
                                          },
                                          icon: Icon(
                                              color: Color.fromRGBO(
                                                  255, 118, 118, 1),
                                              Icons.delete),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              alignment: Alignment.center,
                                              height: 35,
                                              width: 35,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Color.fromRGBO(
                                                      210, 228, 255, 1)),
                                              child: IconButton(
                                                onPressed: () {
                                                  _decrementQuantity(
                                                      item, cartProvider);
                                                },
                                                icon: const Icon(
                                                    color: Color.fromRGBO(
                                                        52, 127, 235, 1),
                                                    size: 20,
                                                    Icons.remove),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 12,
                                            ),
                                            Text(
                                              item.quantity.toString(),
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    0, 42, 110, 1),
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 12,
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              height: 35,
                                              width: 35,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Color.fromRGBO(
                                                      210, 228, 255, 1)),
                                              child: IconButton(
                                                onPressed: () {
                                                  _incrementQuantity(
                                                      item, cartProvider);
                                                },
                                                icon: const Icon(
                                                    color: Color.fromRGBO(
                                                        52, 127, 235, 1),
                                                    size: 20,
                                                    Icons.add),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal:',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(0, 42, 110, 1),
                              ),
                            ),
                            Text(
                              'Rp. ${cartProvider.getTotalPrice().toStringAsFixed(0)}K',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(0, 42, 110, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: SvgPicture.asset(assetName,
                            semanticsLabel: 'A red up arrow'),
                      ),
                      if (change > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Change:',
                                style: TextStyle(
                                  color: Color.fromRGBO(117, 140, 177, 1),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'RP ${change.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color.fromRGBO(117, 140, 177, 1),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          double totalPrice = cartProvider.getTotalPrice();
                          if (totalPrice > 0) {
                            _checkout(totalPrice, cartProvider);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // Ubah nilai sesuai dengan tingkat kebulatan yang Anda inginkan
                          ),
                          fixedSize: Size(500, 50),
                          backgroundColor: Color.fromRGBO(52, 127, 235, 1),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
