import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TextForm extends StatelessWidget {
  const TextForm({
    super.key,
    required TextEditingController this.formController,
    required this.icon,
    required this.label,
  });

  final String icon;
  final String label;
  final TextEditingController formController;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        controller: formController,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          prefixIcon: Transform.scale(
            child: SvgPicture.asset(
              icon,
              height: 5,
              color: Color.fromRGBO(143, 162, 193, 1),
            ),
            scale: 0.4,
          ),
          labelText: label,
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
    );
  }
}
