import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainWrapperController extends GetxController{
 late PageController pageController;

  /// variable for changing index of bottom Appbar
  RxInt currentPage = 0.obs;

  void goToTab(int page){
    currentPage.value = page;
    pageController.jumpToPage(page);
  }

  void animateToTab(int page){
    currentPage.value = page;
    pageController.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }


 @override
 void onInit(){
  pageController = PageController(initialPage: 0);
  super.onInit();
 }

 @override
 void onClose(){
  pageController.dispose();
  super.onClose();
 }
}