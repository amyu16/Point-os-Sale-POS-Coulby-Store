import 'package:end/controller/main_warapper_controller.dart';
import 'package:end/pages/add_product_page.dart';
import 'package:end/pages/cart_page.dart';
import 'package:end/pages/order_page.dart';
import 'package:end/pages/product_list_page.dart';
import 'package:flutter/material.dart';
import 'package:end/pages/report_page.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:end/providers/cart_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainWrapper extends StatelessWidget {
  MainWrapper({Key? key}) : super(key: key);

  final MainWrapperController controller = Get.put(MainWrapperController());

  final String assetName = 'assets/logo.svg';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0),
          child: AppBar(
            backgroundColor: Color.fromRGBO(244, 246, 252, 1),
            elevation: 0,
            title: Row(
              children: [
                SvgPicture.asset(height: 25, assetName),
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Coulby Store",
                  style: TextStyle(
                      color: Color.fromRGBO(0, 42, 110, 1),
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CartPage()),
                        );
                      },
                      icon: const Icon(
                        IconlyBroken.bag,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 9,
                    right: 7,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Consumer<CartProvider>(
                        builder: (context, cart, _) {
                          return Text(
                            '${cart.counter}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.centerLeft,
        children: [
          PageView(
            onPageChanged: controller.animateToTab,
            controller: controller.pageController,
            physics: const BouncingScrollPhysics(),
            children: [
              OrderPage(),
              AddProductPage(),
              ReportPage(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              margin: const EdgeInsets.only(left: 15),
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, -2),
                    color: Color.fromRGBO(132, 181, 255, 0.3),
                    blurRadius: 30,
                  )
                ],
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Obx(
                () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _bottomAppBarItem(context,
                        icon: IconlyBold.buy,
                        inactiveIcon: IconlyBroken.buy,
                        page: 0,
                        text: 'Order'),
                    SizedBox(
                      height: 40,
                    ),
                    _bottomAppBarItem(context,
                        icon: IconlyBold.category,
                        inactiveIcon: IconlyBroken.category,
                        page: 1,
                        text: 'Product'),
                    SizedBox(
                      height: 40,
                    ),
                    _bottomAppBarItem(context,
                        icon: IconlyBold.chart,
                        inactiveIcon: IconlyBroken.chart,
                        page: 2,
                        text: 'Report'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomAppBarItem(
    BuildContext context, {
    required IconData icon,
    required IconData inactiveIcon,
    required int page,
    required String text,
  }) {
    return ZoomTapAnimation(
      onTap: () => controller.goToTab(page),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              controller.currentPage.value == page ? icon : inactiveIcon,
              color: controller.currentPage.value == page
                  ? const Color.fromRGBO(52, 127, 235, 1)
                  : const Color.fromRGBO(143, 162, 193, 1),
              size: 30,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: controller.currentPage.value == page
                    ? const Color.fromRGBO(52, 127, 235, 1)
                    : const Color.fromRGBO(143, 162, 193, 1),
              ),
            )
          ],
        ),
      ),
    );
  }
}
