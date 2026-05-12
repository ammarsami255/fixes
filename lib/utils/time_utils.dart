import 'package:flutter/material.dart';

class TimeUtils {
  static String formatTime12Hour(DateTime? timestamp) {
    if (timestamp == null) return '';
    final hour = timestamp.hour;
    final minute = timestamp.minute;
    final isPm = hour >= 12;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = isPm ? 'م' : 'ص';
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  static String formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastSeen);

    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} يوم';
    } else {
      return formatTime12Hour(lastSeen);
    }
  }

  static String getPresenceStatus({
    required bool isOnline,
    DateTime? lastSeen,
  }) {
    if (isOnline) {
      return 'متصل الآن';
    } else if (lastSeen != null) {
      return 'آخر ظهور ${formatLastSeen(lastSeen)}';
    } else {
      return 'غير متصل';
    }
  }
}