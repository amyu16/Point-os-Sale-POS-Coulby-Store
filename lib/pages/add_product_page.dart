import 'package:flutter/material.dart';
import 'package:end/helpers/db_helper.dart';
import 'package:end/controller/main_warapper_controller.dart';
import 'package:end/models/product_model.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'remove_product_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  final _idController = TextEditingController();
  final _stockController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();

  final DBHelper _dbHelper = DBHelper();
  String _selectedCategory = 'Soaps'; // Updated initialization

  final String barcodeIco = 'assets/barcode.svg';
  final String cubeIco = 'assets/cube.svg';
  final String cubesIco = 'assets/cubes.svg';
  final String dollarIco = 'assets/dollar.svg';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void goToProductTab() {
    MainWrapperController controller = Get.find<MainWrapperController>();
    controller.goToTab(1); // Menggunakan index 1 untuk pergi ke tab produk
  }

  void _addProduct(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      int id = int.tryParse(_idController.text) ?? 0;
      String name = _nameController.text;
      int price = int.tryParse(_priceController.text) ?? 0;
      String unit = _unitController.text;
      int stock = int.tryParse(_stockController.text) ?? 0;

      if (id == 0 || price == 0 || stock == 0 || name.isEmpty || unit.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: const Text(
                'Missing Information',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(255, 118, 118, 1)),
              ),
              content: const Text(
                'Please fill in all the fields.',
                style: TextStyle(color: Color.fromRGBO(0, 42, 110, 1)),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Color.fromRGBO(52, 127, 235, 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusDirectional.circular(10))),
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
        Product product = Product(
          id: id,
          name: name,
          price: price,
          unit: unit,
          stock: stock,
          category: _selectedCategory,
        );

        bool isProductExists = await _dbHelper.checkProductExists(id);

        if (isProductExists) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: const Text(
                  'Product Already Exists',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 118, 118, 1)),
                ),
                content: const Text(
                  'A product with the same ID already exists.',
                  style: TextStyle(color: Color.fromRGBO(0, 42, 110, 1)),
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color.fromRGBO(52, 127, 235, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadiusDirectional.circular(10))),
                    onPressed: () {
                      Navigator.of(context).pop();
                      goToProductTab();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          await _dbHelper.insertProduct(product);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 0,
              backgroundColor: Color.fromRGBO(200, 255, 209, 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              content: Text(
                'Product added successfully',
                style: TextStyle(
                  color: Color.fromRGBO(36, 180, 0, 1),
                ),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          goToProductTab();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 246, 252, 1),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Color.fromRGBO(244, 246, 252, 1),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 100, right: 100, top: 20),
              child: Container(
                height: 30,
                color: Colors.white,
                child: TabBar(
                  unselectedLabelColor: Color.fromRGBO(143, 162, 193, 1),
                  labelColor: Colors.black,
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(132, 181, 255, 0.3),
                        blurRadius: 8,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                  indicatorWeight: 1,
                  tabs: const [
                    Tab(text: 'Add'),
                    Tab(text: 'Remove'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(50, 20, 50, 0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20.0),
                    const Text(
                      'Add Product',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(0, 42, 110, 1)),
                    ),
                    const SizedBox(height: 25.0),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11.0),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(132, 181, 255, 0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 9))
                          ]),
                      child: TextFormField(
                        controller: _idController,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          prefixIcon: Transform.scale(
                            child: SvgPicture.asset(
                              barcodeIco,
                              height: 5,
                              color: Color.fromRGBO(143, 162, 193, 1),
                            ),
                            scale: 0.4,
                          ),
                          labelText: 'Product ID',
                          labelStyle: TextStyle(
                              color: Color.fromRGBO(143, 162, 193, 1),
                              fontWeight: FontWeight.w500),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11.0),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(132, 181, 255, 0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 9))
                          ]),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          prefixIcon: Transform.scale(
                            child: SvgPicture.asset(
                              cubeIco,
                              height: 5,
                              color: Color.fromRGBO(143, 162, 193, 1),
                            ),
                            scale: 0.4,
                          ),
                          labelText: 'Product Name',
                          labelStyle: TextStyle(
                              color: Color.fromRGBO(143, 162, 193, 1),
                              fontWeight: FontWeight.w500),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11.0),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(132, 181, 255, 0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 9))
                          ]),
                      child: TextFormField(
                        controller: _stockController,
                        decoration: InputDecoration(
                          prefixIcon: Transform.scale(
                            child: SvgPicture.asset(
                              cubesIco,
                              height: 5,
                              color: Color.fromRGBO(143, 162, 193, 1),
                            ),
                            scale: 0.4,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: 'Product Stock',
                          labelStyle: TextStyle(
                              color: Color.fromRGBO(143, 162, 193, 1),
                              fontWeight: FontWeight.w500),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11.0),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(132, 181, 255, 0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 9))
                          ]),
                      child: TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          prefixIcon: Transform.scale(
                            child: SvgPicture.asset(
                              dollarIco,
                              height: 5,
                              color: Color.fromRGBO(143, 162, 193, 1),
                            ),
                            scale: 0.4,
                          ),
                          labelText: 'Product Price',
                          labelStyle: TextStyle(
                              color: Color.fromRGBO(143, 162, 193, 1),
                              fontWeight: FontWeight.w500),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11.0),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(132, 181, 255, 0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 9))
                          ]),
                      child: TextFormField(
                        controller: _unitController,
                        decoration: InputDecoration(
                          prefixIcon: Transform.scale(
                            child: SvgPicture.asset(
                              barcodeIco,
                              height: 5,
                              color: Color.fromRGBO(143, 162, 193, 1),
                            ),
                            scale: 0.4,
                          ),
                          labelText: 'Product Unit',
                          labelStyle: TextStyle(
                              color: Color.fromRGBO(143, 162, 193, 1),
                              fontWeight: FontWeight.w500),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11.0),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(132, 181, 255, 0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 9))
                          ]),
                      child: DropdownButtonFormField<String>(
                        style: TextStyle(
                            color: Color.fromRGBO(143, 162, 193, 1),
                            fontWeight: FontWeight.w500),
                        value: _selectedCategory,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                        items: <String>[
                          'Soaps',
                          'Cigs',
                          'Coffee',
                          'Snacks',
                          'Drinks',
                          'Noodles',
                          'Kilos',
                          'Others'
                        ].map<DropdownMenuItem<String>>(
                          (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          },
                        ).toList(),
                        borderRadius: BorderRadius.circular(11),
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: 'Product Category',
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8), // Ubah nilai sesuai dengan tingkat kebulatan yang Anda inginkan
                        ),
                        fixedSize: Size(500, 50),
                        backgroundColor: Color.fromRGBO(52, 127, 235, 1),
                      ),
                      onPressed: () => _addProduct(context),
                      child: const Text('Add Product'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const RemoveProductPage(),
        ],
      ),
    );
  }
}
