import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:intl/intl.dart';
import 'app_colors.dart';


class Utils {
  static BuildContext? _loaderContext;
  static late BuildContext _loadingDialoContext;
  static bool _isLoaderShowing = false;
  static bool _isLoadingDialogShowing = false;
  static late Timer toastTimer;
  static late String marqueeValue ;
  static late String contactNumber ;
  static late List<Contact> contacts = [];


//  Checks
  static bool isNotEmpty(String s) {
    return s != null && s.trim().isNotEmpty;
  }

  static bool isEmpty(String s) {
    return !isNotEmpty(s);
  }

  static bool isListNotEmpty(List<dynamic> list) {
    return list != null && list.isNotEmpty;
  }

  //  Views
  static void showToast1(BuildContext context, String message) {
    showCustomToast(context, message);
  }

  static void showSuccessMessage(BuildContext context, String message) {
    showCustomToast(context, message, bgColor: AppColors.snackBarGreen);
  }

  static void showNeutralMessage(BuildContext context, String message) {
    showCustomToast(context, message, bgColor: AppColors.snackBarColor);
  }

  static void showErrorMessage(BuildContext context, String message) {
    showCustomToast(context, message, bgColor: AppColors.snackBarRed);
  }

  static void showValidationMessage(BuildContext context, String message) {
    showCustomToast(context, message);
  }

  static void showCustomToast(BuildContext context, String message,
      {Color bgColor = AppColors.primaryColor}) {
    showToast(message,
        context: context,
        fullWidth: true,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14,color: Colors.white),
        animation: StyledToastAnimation.slideFromTopFade,
        reverseAnimation: StyledToastAnimation.slideToTopFade,
        position:
        const StyledToastPosition(align: Alignment.topCenter, offset: 0.0),
        startOffset: const Offset(0.0, -3.0),
        backgroundColor: bgColor,
        reverseEndOffset: const Offset(0.0, -3.0),
        duration: const Duration(seconds: 3),
        animDuration: const Duration(seconds: 1),
        curve: Curves.fastLinearToSlowEaseIn,
        reverseCurve: Curves.fastOutSlowIn);
  }

  static void showErrorToast(BuildContext context, String message,
      {Color bgColor = AppColors.snackBarRed}) {
    showToast(message,
        context: context,
        fullWidth: true,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        animation: StyledToastAnimation.slideFromTopFade,
        reverseAnimation: StyledToastAnimation.slideToTopFade,
        position:
        const StyledToastPosition(align: Alignment.topCenter, offset: 0.0),
        startOffset: const Offset(0.0, -3.0),
        backgroundColor: AppColors.snackBarRed,
        reverseEndOffset: const Offset(0.0, -3.0),
        duration: const Duration(seconds: 3),
        animDuration: const Duration(seconds: 1),
        curve: Curves.fastLinearToSlowEaseIn,
        reverseCurve: Curves.fastOutSlowIn);
  }


  static void hideLoader() {
    if (_isLoaderShowing) {
      Navigator.pop(_loaderContext!);
      _loaderContext ??= null;
    }
  }



  static Widget buildLoader() {
    return const SpinKitSpinningLines(
      size: 80,
      color: AppColors.primaryColor,
    );
  }

  static void showLoadingDialog(BuildContext context) {
    if (!_isLoadingDialogShowing) {
      _isLoadingDialogShowing = true;
      _loadingDialoContext = context;
      showDialog(
          context: _loadingDialoContext,
          barrierDismissible: false,
          builder: (context) {
            return const SpinKitSpinningLines(
              color: AppColors.primaryColor,
            );
          })
          .then((value) => {
        _isLoadingDialogShowing = false,
        print('LoadingDialog hidden!')
      });
    }
  }


  static void hideLoadingDialog() {
    if (_isLoadingDialogShowing) {
      Navigator.pop(_loadingDialoContext);
      _loadingDialoContext == null;
    }
  }

  static void hideKeyBoard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  static ThemeData getAppThemeData() {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      canvasColor: Colors.transparent,
      brightness: Brightness.light,
    );
  }

  static DateTime convertDateFromString(String strDate) {
    DateTime date = DateTime.parse(strDate);
    // var formatter = new DateFormat('yyyy-MM-dd');
    return date;
  }

  static String getDeviceType() {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else if (Platform.isMacOS) {
      return 'MacOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else {
      return 'Unknown';
    }
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Regular expression for validating email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String validateGetdayOfMonthFromDate(String dateString) {
    // Parse the date string into a DateTime object
    DateTime date = DateTime.parse(dateString!);
    // Get the day of the month
    int dayOfMonth = date.day;
    return dayOfMonth.toString();
  }

  static String validateGetDayFromDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    DateFormat formatter = DateFormat('EEE');
    String dayName = formatter.format(date);
    return dayName.toString();
  }

  static String validateTimeStampChange(String createdAtString) {
    DateTime createdAt = DateTime.parse(createdAtString);
    String formattedDate = DateFormat('yyyy/MM/dd').format(createdAt);
    return formattedDate;
  }

  static String validateTotalHours(String clockIn,String clockOut) {
    if(clockIn!='--'&&clockOut!='--') {
      DateTime clockInTime = DateTime.parse(
          "2024-09-14 $clockIn"); // Date part can be anything, just for parsing
      DateTime clockOutTime = DateTime.parse("2024-09-14 $clockOut");
      if (clockOutTime.isBefore(clockInTime)) {
        clockOutTime = clockOutTime.add(const Duration(days: 1)); // Add 1 day
      }
      Duration difference = clockOutTime.difference(clockInTime);
      int totalHours = difference.inHours;
      int totalMinutes = difference.inMinutes % 60;
      return totalHours.toString();
    }
    return '--';
  }


  static String getShortMonthName(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String shortMonth = DateFormat.MMM().format(dateTime);
    String shortDate = DateFormat.d().format(dateTime);
    return shortDate +' '+ shortMonth;
  }

  static String getCurrentFormattedDate() {
    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    return formattedDate;
  }
  static String getCurrentYear() {
    DateTime currentDate = DateTime.now();
    String shortYear = DateFormat.y().format(currentDate);
    return shortYear;
  }

  static String getCurrentMonth() {
    DateTime currentDate = DateTime.now();
    String monthNumber = currentDate.month.toString().padLeft(2, '0');
    return monthNumber;
  }
  static String formattedDate(String mdate) {
    DateTime dateTime = DateTime.parse(mdate);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  }

  /*static String convertDate(String inputDate) {
    DateTime parsedDate = DateTime.parse(inputDate);
    DateTime convertedDate = DateTime.utc(
      parsedDate.year,
      parsedDate.month,
      31,
      0, 0, 0, 0, 0,
    );
    return convertedDate.toIso8601String();
  }*/

  static DateTime convertDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateTime.utc(parsedDate.year, parsedDate.month, parsedDate.day);
  }

  static String calculateTotalHours(String clockInTime, String clockOutTime) {
    String totalHours="---";
    if(clockInTime!=''&&clockOutTime!='') {
      DateTime currentDate = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

      DateTime clockIn = DateTime.parse("${formattedDate} $clockInTime");
      DateTime clockOut = DateTime.parse("${formattedDate} $clockOutTime");
      Duration difference = clockOut.difference(clockIn);

      int hours = difference.inHours;
      int minutes = difference.inMinutes.remainder(60);
      int seconds = difference.inSeconds % 60;

      totalHours = hours.toString() + ':' + minutes.toString() + ':' + seconds.toString();
    }
    return totalHours;
  }



  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }


  static String getMonthName(int monthNumber) {
    // List of month names
    const List<String> monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    // Validate the month number and return the corresponding month name
    if (monthNumber >= 1 && monthNumber <= 12) {
      return monthNames[monthNumber - 1];
    } else {
      throw ArgumentError('Invalid month number: $monthNumber. Must be between 1 and 12.');
    }
  }

  static Map<String, dynamic>? decodeJwtWithoutVerification(String token) {
    try {
      // Split the token into its parts
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT');
      }

      // Decode the payload
      final payloadBase64 = parts[1];
      final normalized = base64Url.normalize(payloadBase64);
      final payloadString = utf8.decode(base64Url.decode(normalized));

      // Convert the payload string into a Map
      final payload = json.decode(payloadString) as Map<String, dynamic>;

      return payload;
    } catch (e) {
      print('Error decoding JWT without verification: $e');
      return null;
    }
  }

  static String formatDate(int timestamp) {
    try {
      if (timestamp <= 0) {
        return 'Unknown time';
      }
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateFormat('MM/d/yyyy').format(dateTime);
    } catch (e) {
      print('Error formatting timestamp: $e');
      return 'Invalid time';
    }
  }

  static String formatTimes(int timestamp) {
    try {
      if (timestamp <= 0) {
        return 'Unknown time';
      }
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      print('Error formatting timestamp: $e');
      return 'Invalid time';
    }
  }

  static String formatDuration(int seconds) {
    if (seconds <= 0) {
      return '0s';
    }

    final hours = seconds ~/ 3600; // Integer division to get hours
    final remainingSecondsAfterHours = seconds % 3600;
    final minutes = remainingSecondsAfterHours ~/ 60; // Integer division to get minutes
    final remainingSeconds = remainingSecondsAfterHours % 60; // Remaining seconds

    final parts = <String>[];
    if (hours > 0) {
      parts.add('${hours} Hrs');
    }
    if (minutes > 0) {
      parts.add('${minutes} Min');
    }
    if (remainingSeconds > 0 || (hours == 0 && minutes == 0)) {
      parts.add('${remainingSeconds} Sec');
    }

    return parts.join(' ');
  }

  static String formatTimestampDate(int timestampMillis) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
    return DateFormat('yyyy-MM-dd').format(dt);
  }
  static String formatTimestamp(int timestampMillis) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
    return DateFormat('HH:mm').format(dt);
  }

}
