import 'package:flutter/widgets.dart';

class AppColors {
  static const primaryBase = Color(0xFF7062AB);
  static const primary50 = Color(0xFFF2F3FB);
  static const secondaryBase = Color(0XFFEF3852);
  static const titleTextColor = Color(0xFF252C22);
  static const errorColor = Color(0xFFFF0000); //(0xFFFF5A5A);
  static const grey50 = Color(0xFFF8F9FD);
  // static const grey100 = Color(0xFFF1F5F9);
  static const grey100 = Color(0xFFF7F9FC);
  // static const grey200 = Color(0xFFE2E8F0);
  static const grey200 = Color(0xFFF0F2F5);
  static const grey300 = Color(0xFFCBD5E1);
  // static const grey400 = Color(0xFF94A3B8);
  static const grey400 = Color(0xFFD0D5DD);
  // static const grey500 = Color(0xFF64748B);
  static const grey500 = Color(0xFF98A2B3);
  // static const grey600 = Color(0xFF475569);
  static const grey600 = Color(0xFF667185);
  static const grey700 = Color(0xFF475367);
  // static const grey900 = Color(0xFF0F172A);
  static const grey900 = Color(0xFF1D2739);
  static const white = Color(0xFFFFFFFF);
  static const green = Color(0xFF0F973D);
  static const dividerColor = Color(0xFF20222C);
  static const grayColor = Color(0xFF676362);
  static const grayNeutral = Color(0xFFF5F5F5);
  static const starColor = Color(0xFFF3A218);

  static const alertSuccessBackgroundColors = Color(0xFFDCFEE8);
  static const alertSuccessTextColor = Color(0xFF1ED760);

  static const alertWarningBackgroundColors = Color(0xFFFFF5D2);
  static const alertWarningTextColor = Color(0xFFE6BB20);

  static const alertDangerBackgroundColors = Color(0xFFFFE1E1);
  static const alertDangerTextColor = Color(0xFFFF0000);

  static Color getStatusBackgroundColor(String status) {
    if(status == "processing") {
      return alertWarningBackgroundColors;
    }
    if(status == "cancelled") {
      return alertDangerBackgroundColors;
    }
    if(status == "completed") {
      return alertSuccessBackgroundColors;
    }
    return grey200;
  }

  static Color getStatusTextColor(String status) {
    if(status == "processing") {
      return alertWarningTextColor;
    }
    if(status == "cancelled") {
      return alertDangerTextColor;
    }
    if(status == "completed") {
      return alertSuccessTextColor;
    }
    return grey500;
  }
}
