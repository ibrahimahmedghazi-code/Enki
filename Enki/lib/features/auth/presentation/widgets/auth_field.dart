import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  // Is it a password so use should not show it as plain text
  final bool isObscureText;
  const AuthField({super.key, required this.hintText, required this.controller, this.isObscureText= false});

  final OutlineInputBorder _border = const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(
      color: Color.fromARGB(255, 150, 150, 150), // A standard border color
      width: 1.5,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(

        controller: controller,
        decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.all(22),
        border: _border,
        enabledBorder: _border,
        focusedBorder: _border.copyWith(
          borderSide: const BorderSide(color: Colors.amber, width: 2),
        ),

        errorBorder: _border.copyWith(
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
// Check if user do not lift the field empty
      validator: (value){
        if(value!.isEmpty){
          return "$hintText is missing !";
        }
          return null;
      },
      obscureText: isObscureText,
    );
  }
}
