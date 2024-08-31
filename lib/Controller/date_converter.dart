import 'package:intl/intl.dart';

String formatDateTime(DateTime dateTime) {
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(const Duration(days: 1));
  DateTime aWeekAgo = today.subtract(const Duration(days: 7));

  if (dateTime.compareTo(today) >= 0 && dateTime.compareTo(now) < 0) {
    return "Today";
  } else if (dateTime.compareTo(yesterday) >= 0 &&
      dateTime.compareTo(today) < 0) {
    return "Yesterday";
  } else if (dateTime.compareTo(aWeekAgo) >= 0) {
    // Return the weekday name if the date is within the past week
    return DateFormat('EEEE').format(dateTime);
  } else {
    // Return the actual date if older than a week
    return DateFormat('yMMMd').format(dateTime); // e.g., "Jan 12, 2022"
  }
}
