import 'package:end/helpers/db_helper.dart';
import 'package:end/models/cart_model.dart';
import 'package:end/models/product_model.dart';
import 'package:end/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  DBHelper dbHelper = DBHelper();
  Set<int> addedProductIds = {};

  String searchQuery = '';
  String selectedCategory = '';

  final String cigsIco = 'assets/cigs.svg';
  final String coffeeIco = 'assets/coffee.svg';
  final String drinksIco = 'assets/drinks.svg';
  final String kilosIco = 'assets/kilos.svg';
  final String noodlesIco = 'assets/noodles.svg';
  final String snacksIco = 'assets/snacks.svg';
  final String soapsIco = 'assets/soaps.svg';
  final String othersIco = 'assets/others.svg';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkCartItems();
  }

  Future<void> checkCartItems() async {
    List<Cart> cartItems = await dbHelper.getCartItems();
    if (cartItems.isNotEmpty) {
      setState(() {
        addedProductIds =
            cartItems.map((item) => int.parse(item.productId!)).toSet();
      });
    }
  }

  Widget buildCategoryFilter(String category, String icon) {
    final isSelected = category.toLowerCase() == selectedCategory;
    final color = getColorByCategory(category);
    final backgroundColor = getTextColorByCategory(category);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ChoiceChip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: isSelected
              ? BorderSide(color: backgroundColor, width: 2.0)
              : BorderSide.none,
        ),
        backgroundColor: isSelected ? color : backgroundColor,
        label: Row(
          children: [
            SvgPicture.asset(
              icon,
              color: isSelected ? backgroundColor : Colors.white,
              height: 15,
            ),
            const SizedBox(width: 10.0),
            Text(
              category,
              style: TextStyle(
                color: isSelected
                    ? backgroundColor
                    : Colors.white, // Mengatur warna teks berdasarkan textColor
              ),
            ),
          ],
        ),
        selected: isSelected,
        selectedColor: Colors.transparent,
        onSelected: (selected) {
          setState(() {
            selectedCategory = selected ? category.toLowerCase() : '';
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 246, 252, 1),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11.0),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(132, 181, 255, 0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 9),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    IconlyBroken.search,
                    color: Color.fromRGBO(143, 162, 193, 1),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelText: 'Search',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(143, 162, 193, 1)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildCategoryFilter('Soaps', soapsIco),
                buildCategoryFilter('Drinks', drinksIco),
                buildCategoryFilter('Kilos', kilosIco),
                buildCategoryFilter('Cigs', cigsIco),
                buildCategoryFilter('Noodles', noodlesIco),
                buildCategoryFilter('Snacks', snacksIco),
                buildCategoryFilter('Coffee', coffeeIco),
                buildCategoryFilter('Others', othersIco),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Product List',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(0, 42, 110, 1)),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: dbHelper.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final products = snapshot.data;
                if (products == null || products.isEmpty) {
                  return const Center(child: Text('Produk belum ditambahkan'));
                }
                final filteredProducts = products.where((product) {
                  final name = product.name?.toLowerCase() ?? '';
                  final category = product.category?.toLowerCase() ?? '';
                  return name.contains(searchQuery) &&
                      (selectedCategory.isEmpty ||
                          category == selectedCategory);
                }).toList();
                return Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final isProductAdded =
                          addedProductIds.contains(product.id);
                      final stockTextStyle = product.stock == 0
                          ? TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)
                          : TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500);
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(132, 181, 255, 0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 3), // atur posisi shadow
                              ),
                            ],
                          ),
                          child: Card(
                            elevation:
                                0, // atur elevation Card menjadi 0 agar tidak ada shadow default
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: isProductAdded
                                  ? BorderSide(
                                      color: const Color.fromRGBO(52, 127, 235,
                                          1), // Border color when product is added
                                      width: 2.0,
                                    )
                                  : BorderSide
                                      .none, // Tidak ada border saat product tidak ditambahkan
                            ),
                            child: InkWell(
                              onTap: () async {
                                if (isProductAdded) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      elevation: 0,
                                      backgroundColor:
                                          Color.fromRGBO(252, 220, 220, 1),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      content: Text(
                                        'Produk sudah ada di Keranjang',
                                        style: TextStyle(
                                          color: Color.fromRGBO(255, 72, 72, 1),
                                        ),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  if (product.stock == 0) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          title: const Text(
                                            'Stock is Empty',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromRGBO(
                                                  255, 118, 118, 1),
                                            ),
                                          ),
                                          content: const Text(
                                            'stock is running out please refill stock',
                                            style: TextStyle(
                                              color:
                                                  Color.fromRGBO(0, 42, 110, 1),
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor: Color.fromRGBO(
                                                    52, 127, 235, 1),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadiusDirectional
                                                          .circular(10),
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
                                  } else {
                                    addedProductIds.add(product.id!);
                                    await dbHelper.insert(
                                      Cart(
                                        id: product.id!,
                                        productId: product.id.toString(),
                                        productName: product.name,
                                        subTotal: product.price,
                                        productPrice: product.price,
                                        quantity: 1,
                                        unitTag: product.unit,
                                      ),
                                    );
                                    setState(() {
                                      cart.addTotalPrice(double.parse(
                                          product.price.toString()));
                                      cart.addCounter();
                                    });
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 9),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: getColorByCategory(
                                              product.category),
                                        ),
                                        padding: EdgeInsets.all(6),
                                        child: Text(
                                          product.category ?? '',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: getTextColorByCategory(
                                                product.category),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      product.name ?? '',
                                      style: TextStyle(
                                        color: Color.fromRGBO(0, 42, 110, 1),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Rp. ${product.price ?? 0}K / ${product.unit ?? ''}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color.fromRGBO(0, 42, 110, 0.54),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 17),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${product.stock ?? ''} Items',
                                            style: stockTextStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color getColorByCategory(String? category) {
    switch (category) {
      case 'Soaps':
        return Color.fromRGBO(206, 253, 228, 1);
      case 'Cigs':
        return Color.fromRGBO(255, 205, 217, 1);
      case 'Coffee':
        return Color.fromRGBO(243, 227, 202, 1);
      case 'Snacks':
        return Color.fromRGBO(249, 218, 207, 1);
      case 'Drinks':
        return Color.fromRGBO(210, 228, 255, 1);
      case 'Noodles':
        return Color.fromRGBO(250, 238, 215, 1);
      case 'Kilos':
        return Color.fromRGBO(222, 207, 246, 1);
      case 'Others':
        return Color.fromRGBO(231, 229, 229, 1);
      default:
        return Colors.grey;
    }
  }

  Color getTextColorByCategory(String? category) {
    switch (category) {
      case 'Soaps':
        return Color.fromRGBO(30, 196, 121, 1);
      case 'Cigs':
        return Color.fromRGBO(255, 111, 145, 1);
      case 'Coffee':
        return Color.fromRGBO(193, 156, 102, 1);
      case 'Snacks':
        return Color.fromRGBO(255, 150, 113, 1);
      case 'Drinks':
        return Color.fromRGBO(52, 127, 235, 1);
      case 'Noodles':
        return Color.fromRGBO(251, 188, 71, 1);
      case 'Kilos':
        return Color.fromRGBO(132, 94, 194, 1);
      case 'Others':
        return Color.fromRGBO(166, 168, 172, 1);
      default:
        return Colors.black;
    }
  }
}
