import 'package:flutter/material.dart';
import 'package:end/helpers/db_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RemoveProductPage extends StatefulWidget {
  const RemoveProductPage({Key? key}) : super(key: key);

  @override
  _RemoveProductPageState createState() => _RemoveProductPageState();
}

class _RemoveProductPageState extends State<RemoveProductPage> {
  final DBHelper _dbHelper = DBHelper();
  final _productIdController = TextEditingController();

  final String barcodeIco = 'assets/barcode.svg';

  void _removeProduct(BuildContext context) async {
    int productId = int.tryParse(_productIdController.text) ?? 0;

    if (productId == 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text('Error',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(255, 118, 118, 1))),
            content: const Text('Invalid Product ID',
                style: TextStyle(color: Color.fromRGBO(0, 42, 110, 1))),
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
      return;
    }

    bool isProductExists = await _dbHelper.isProductExists(productId);

    if (!isProductExists) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text('Error',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(255, 118, 118, 1))),
            content: const Text('Product ID not found',
                style: TextStyle(color: Color.fromRGBO(0, 42, 110, 1))),
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
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Confirmation',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(0, 42, 110, 1))),
          content: const Text('Are you sure you want to remove this product?',
              style: TextStyle(color: Color.fromRGBO(0, 42, 110, 1))),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Color.fromRGBO(255, 224, 224, 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(10))),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel',
                  style: TextStyle(
                    color: Color.fromRGBO(253, 122, 122, 1),
                  )),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Color.fromRGBO(52, 127, 235, 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(10))),
              onPressed: () async {
                await _dbHelper.deleteProduct(productId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    elevation: 0,
                    backgroundColor: Color.fromRGBO(200, 255, 209, 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    content: Text(
                      'Product removed successfully',
                      style: TextStyle(
                        color: Color.fromRGBO(36, 180, 0, 1),
                      ),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _productIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 246, 252, 1),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(50, 20, 50, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            const Text(
              'Remove Product',
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
              child: TextField(
                controller: _productIdController,
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
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () => _removeProduct(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8), // Ubah nilai sesuai dengan tingkat kebulatan yang Anda inginkan
                ),
                fixedSize: Size(500, 50),
                backgroundColor: Colors.red,
              ),
              child: const Text('Remove'),
            ),
          ],
        ),
      ),
    );
  }
}
