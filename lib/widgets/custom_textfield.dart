import 'package:flutter/material.dart';

customTextField(con) {
  return TextFormField(
    controller: con,
    decoration: InputDecoration(
      labelText: 'Site Name',
      labelStyle: const TextStyle(
        color: Colors.black
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          width: 1.2
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide:  const BorderSide(
          width: 1.6
        ),
      ),
    ),
  );   
}