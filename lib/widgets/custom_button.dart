import 'package:flutter/material.dart';

customButton(String text, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      padding: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2.0,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      animationDuration: const Duration(milliseconds: 200),
      shadowColor: Colors.transparent,
      side: BorderSide.none,
    ), 
    child: Text(
      text,
      // style: TextStyle(
      //   color: Colors.white,
      //   fontSize: 14.0,
      //   fontWeight: fontWeight,
      // ),
    )
  );
} 