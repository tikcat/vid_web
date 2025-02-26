import 'package:flutter/material.dart';

class MyTextStyle {

  static TextStyle getTextStyleByWeight(double weight, Color fontColor,
      {required double fontSize,
      String fontFamily = "Roboto",
      FontStyle fontStyle = FontStyle.normal}) {
    switch (weight) {
      case 100:
        {
          return textStyle100Weight(fontColor,
              fontSize: fontSize, fontFamily: fontFamily, fontStyle: fontStyle);
        }
      case 300:
        {
          return textStyle300Weight(fontColor,
              fontSize: fontSize, fontFamily: fontFamily, fontStyle: fontStyle);
        }
      case 400:
        {
          return textStyle400Weight(fontColor,
              fontSize: fontSize, fontFamily: fontFamily, fontStyle: fontStyle);
        }
      case 500:
        {
          return textStyle500Weight(fontColor,
              fontSize: fontSize, fontFamily: fontFamily, fontStyle: fontStyle);
        }
      case 600:
        {
          return textStyle600Weight(fontColor,
              fontSize: fontSize, fontFamily: fontFamily, fontStyle: fontStyle);
        }
      case 700:
        {
          return textStyle700Weight(fontColor,
              fontSize: fontSize, fontFamily: fontFamily, fontStyle: fontStyle);
        }
      case 900:
        {
          return textStyle900Weight(fontColor,
              fontSize: fontSize, fontFamily: fontFamily, fontStyle: fontStyle);
        }
      default:
        {
          return textStyle500Weight(fontColor,
              fontSize: fontSize, fontFamily: fontFamily, fontStyle: fontStyle);
        }
    }
  }

  static TextStyle _generateTextStyle(
      {Color fontColor = const Color(0xFF000000),
      required double fontSize,
      String fontFamily = "Roboto",
      FontStyle fontStyle = FontStyle.normal,
      FontWeight fontWeight = FontWeight.normal}) {
    return TextStyle(
      color: fontColor,
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontStyle: fontStyle,
      fontWeight: fontWeight,
    );
  }

  static TextStyle textStyle100Weight(Color fontColor,
      {required double fontSize,
      String fontFamily = "Roboto",
      FontStyle fontStyle = FontStyle.normal}) {
    return _generateTextStyle(
        fontColor: fontColor,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w100,
        fontStyle: fontStyle);
  }

  static TextStyle textStyle300Weight(Color fontColor,
      {required double fontSize,
      String fontFamily = "Roboto",
      FontStyle fontStyle = FontStyle.normal}) {
    return _generateTextStyle(
        fontColor: fontColor,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w300,
        fontStyle: fontStyle);
  }

  static TextStyle textStyle400Weight(Color fontColor,
      {required double fontSize,
      String fontFamily = "Roboto",
      FontStyle fontStyle = FontStyle.normal}) {
    return _generateTextStyle(
        fontColor: fontColor,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontStyle: fontStyle);
  }

  static TextStyle textStyle500Weight(Color fontColor,
      {required double fontSize,
      String fontFamily = "Roboto",
      FontStyle fontStyle = FontStyle.normal}) {
    return _generateTextStyle(
        fontColor: fontColor,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        fontStyle: fontStyle);
  }

  static TextStyle textStyle600Weight(Color fontColor,
      {required double fontSize,
      String fontFamily = "Roboto",
      FontStyle fontStyle = FontStyle.normal}) {
    return _generateTextStyle(
        fontColor: fontColor,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontStyle: fontStyle);
  }

  static TextStyle textStyle700Weight(Color fontColor,
      {required double fontSize,
      String fontFamily = "Roboto",
      FontStyle fontStyle = FontStyle.normal}) {
    return _generateTextStyle(
        fontColor: fontColor,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontStyle: fontStyle);
  }

  static TextStyle textStyle900Weight(Color fontColor,
      {required double fontSize,
      String fontFamily = "Roboto",
      FontStyle fontStyle = FontStyle.normal}) {
    return _generateTextStyle(
        fontColor: fontColor,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w900,
        fontStyle: fontStyle);
  }
}
