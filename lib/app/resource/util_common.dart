import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';

class UtilCommon {


  static String convertDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String convertDateTimeYMD(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String convertEEEDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String getWeekdayName(DateTime date) {
    const weekdays = [
      '',
      'Thứ 2',
      'Thứ 3', 
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ nhật'
    ];
    return weekdays[date.weekday];
  }

  static String getMonthName(int month) {
    const months = [
      '',
      'tháng 1',
      'tháng 2',
      'tháng 3',
      'tháng 4',
      'tháng 5',
      'tháng 6',
      'tháng 7',
      'tháng 8',
      'tháng 9',
      'tháng 10',
      'tháng 11',
      'tháng 12'
    ];
    return months[month];
  }

  static String formatDateTimeVietnamese(DateTime date) {
    return '${getWeekdayName(date)}, ${date.day} ${getMonthName(date.month)} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static DateTime combineDateTimeAndTimeOfDay(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  static String formatMoney(double amount) {
    final NumberFormat formatter = NumberFormat('#,###');
    return '${formatter.format(amount)} VNĐ';
  }

  static BoxDecoration shadowBox(BuildContext context,
      {double radiusBorder = 10,
      Color? colorBg,
      Color? colorSd,
      bool isActive = false}) {
    colorSd = colorSd ?? ColorsManager.bgLight2;
    colorBg = colorBg ??
        (isActive ? ColorsManager.scaffoldBg : ColorsManager.bgLight2);
    return BoxDecoration(
      borderRadius:
          BorderRadius.circular(UtilsReponsive.height(radiusBorder, context)),
      color: colorBg,
      boxShadow: !isActive
          ? null
          : [
              BoxShadow(
                color: colorSd,
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
    );
  }
}
