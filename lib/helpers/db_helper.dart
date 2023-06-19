import 'dart:async';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:end/models/cart_model.dart';
import 'package:end/models/product_model.dart';
import 'package:end/models/report_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initDatabase();
    return _db;
  }

  Future<Database> initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'cart.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS cart (
          id INTEGER PRIMARY KEY,
          productId TEXT UNIQUE,
          productName TEXT,
          subTotal INTEGER,
          productPrice INTEGER,
          quantity INTEGER,
          unitTag TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS products (
          id INTEGER PRIMARY KEY,
          name TEXT,
          price INTEGER,
          unit TEXT,
          stock INTEGER,
          category TEXT
        )
      ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS report(
        id INTEGER PRIMARY KEY,
        cartName TEXT,
        totalItems INTEGER,
        totalPrice REAL,
        timestamp TEXT
      )
      ''');
    } catch (e) {
      print('Error creating tables: $e');
    }
  }

  Future<Cart> insert(Cart cart) async {
    try {
      var dbClient = await db;
      if (dbClient != null) {
        List<Map<String, dynamic>> result = await dbClient.query(
          'cart',
          where: 'productId = ?',
          whereArgs: [cart.productId],
          limit: 1,
        );

        if (result.isNotEmpty) {
          await dbClient.update(
            'cart',
            cart.toMap(),
            where: 'productId = ?',
            whereArgs: [cart.productId],
          );
        } else {
          await dbClient.insert('cart', cart.toMap());
        }
      }
    } catch (e) {
      print('Error inserting cart item: $e');
    }
    return cart;
  }

  Future<void> update(Cart item) async {
    final dbClient = await db;
    await dbClient?.update(
      'cart',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<List<Cart>> getCartList() async {
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult =
        await dbClient!.query('cart');
    return queryResult.map((e) => Cart.fromMap(e)).toList();
  }

  Future<int> delete(int id) async {
    try {
      var dbClient = await db;
      if (dbClient != null) {
        return await dbClient.delete(
          'cart',
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } catch (e) {
      print('Error deleting cart item: $e');
    }
    return 0;
  }

  Future<int> insertProduct(Product product) async {
    try {
      var dbClient = await db;
      if (dbClient != null) {
        return await dbClient.insert('products', product.toMap());
      }
    } catch (e) {
      print('Error inserting product: $e');
    }
    return 0;
  }

  Future<bool> isProductExists(int productId) async {
    var dbClient = await db;
    List<Map> result = await dbClient!.query(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty;
  }

  Future<List<Product>> getProducts() async {
    try {
      var dbClient = await db;
      if (dbClient != null) {
        final List<Map<String, dynamic>> maps =
            await dbClient.query('products');
        return List.generate(maps.length, (index) {
          return Product(
              id: maps[index]['id'],
              name: maps[index]['name'],
              price: maps[index]['price'],
              unit: maps[index]['unit'],
              category: maps[index]['category'],
              stock: maps[index]['stock']);
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
    return [];
  }

  Future<List<Cart>> getCartItems() async {
    try {
      var dbClient = await db;
      if (dbClient != null) {
        final List<Map<String, dynamic>> maps = await dbClient.query('cart');
        return List.generate(maps.length, (index) {
          return Cart(
            id: maps[index]['id'],
            productId: maps[index]['productId'],
            productName: maps[index]['productName'],
            subTotal: maps[index]['subTotal'],
            productPrice: maps[index]['productPrice'],
            quantity: maps[index]['quantity'],
            unitTag: maps[index]['unitTag'],
          );
        });
      }
    } catch (e) {
      print('Error fetching cart items: $e');
    }
    return [];
  }

  Future<int> deleteProduct(int id) async {
    final dbClient = await db;
    return await dbClient!.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalPrice() async {
    final dbClient = await db;
    final result = await dbClient?.rawQuery('SELECT SUM(subTotal) FROM cart');

    if (result != null && result.isNotEmpty) {
      final firstValue = result.first.values.first;

      if (firstValue != null && firstValue is int) {
        final total = firstValue as double;
        return total;
      } else {
        return 0;
      }
    } else {
      throw Exception('Hasil query tidak valid atau kosong.');
    }
  }

  Future<int> clearCart() async {
    try {
      var dbClient = await db;
      if (dbClient != null) {
        return await dbClient.delete('cart');
      }
    } catch (e) {
      print('Error clearing cart: $e');
    }
    return 0;
  }

  Future<bool> checkProductExists(int id) async {
    final dbClient = await db;
    final result = await dbClient!.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future<Report> insertReport(Report report) async {
    try {
      var dbClient = await db;
      if (dbClient != null) {
        await dbClient.insert('report', report.toMap());
      }
    } catch (e) {
      print('Error inserting transaction: $e');
    }
    return report;
  }

  Future<List<Report>> getReport() async {
    try {
      var dbClient = await db;
      if (dbClient != null) {
        final List<Map<String, dynamic>> maps = await dbClient.query('report');
        return List.generate(maps.length, (index) {
          return Report(
            cartName: maps[index]['cartName'],
            totalItems: maps[index]['totalItems'],
            totalPrice: maps[index]['totalPrice'],
            timestamp: maps[index]['timestamp'],
          );
        });
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }
    return [];
  }

  Future<void> deleteReport(int id) async {
    try {
      var dbClient = await db;
      if (dbClient != null) {
        await dbClient.delete(
          'report',
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }

  Future<int> getCartItemsCount() async {
    final dbClient = await db;
    final count = Sqflite.firstIntValue(
        await dbClient!.rawQuery('SELECT COUNT(*) FROM cart'));
    return count ?? 0;
  }

Future<void> updateProductStock(int productId, int quantity) async {
  final dbClient = await db;

  // Mendapatkan jumlah stok saat ini
  final List<Map<String, dynamic>> productData = await dbClient!.query(
    'products',
    where: 'id = ?',
    whereArgs: [productId],
  );

  if (productData.isNotEmpty) {
    final int currentStock = productData.first['stock'] as int;
    if (currentStock >= quantity) {
      // Mengurangi jumlah stok berdasarkan quantity yang dibeli
      final int newStock = currentStock - quantity;

      // Memperbarui jumlah stok di database
      await dbClient.update(
        'products',
        {'stock': newStock},
        where: 'id = ?',
        whereArgs: [productId],
      );
    } else {
      print('Insufficient stock for product ID: $productId');
    }
  } else {
    print('Product not found for ID: $productId');
  }
}

Future<Product> getProductById(int productId) async {
  final dbClient = await db;
  List<Map<String, dynamic>> result = await dbClient!.query(
    'products',
    where: 'id = ?',
    whereArgs: [productId],
  );

  if (result.isNotEmpty) {
    return Product.fromMap(result.first);
  } else {
    throw Exception('Product not found');
  }
}


}
