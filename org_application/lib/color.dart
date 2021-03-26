import 'package:flutter/material.dart';

class LightThemeColors {
  final backgroundColor = Color(0xFFDCDCDC);
  final logoColor = Color(0xFF0099FF);
  final textColor = Color(0xFF121212);

  Color getBackgroundColor(){
    return backgroundColor;
  }

  Color getLogoColor(){
    return logoColor;
  }

  Color getTextColor(){
    return textColor;
  }
}

class DarkThemeColors {
  final backgroundColor = Color(0xFF121212);
  final logoColor = Color(0xFF0099FF);
  final textColor = Color(0xFFDCDCDC);

  Color getBackgroundColor(){
    return backgroundColor;
  }

  Color getLogoColor(){
    return logoColor;
  }

  Color getTextColor(){
    return textColor;
  }
}