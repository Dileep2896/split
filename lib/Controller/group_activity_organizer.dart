import 'package:intl/intl.dart';
import 'package:split/Controller/date_converter.dart';

Map<String, List<Map<String, dynamic>>> organizeActivities(
    List<dynamic> activities) {
  Map<String, List<Map<String, dynamic>>> organized = {};

  for (var activity in activities) {
    String dateString = formatDateTime(DateTime.parse(activity.keys.first));

    if (!organized.containsKey(dateString)) {
      organized[dateString] = [];
    }
    organized[dateString]!.add(activity);
  }

  var sortedKeys = organized.keys.toList(growable: false)
    ..sort((k1, k2) => compareDates(k1, k2));

  Map<String, List<Map<String, dynamic>>> sortedMap = {
    for (var key in sortedKeys) key: organized[key]!
  };

  // Sort each list of activities by DateTime in descending order
  sortedMap.forEach((key, list) {
    list.sort((a, b) {
      DateTime dateA = DateFormat("yyyy-MM-dd HH:mm:ss").parse(a.keys.first);
      DateTime dateB = DateFormat("yyyy-MM-dd HH:mm:ss").parse(b.keys.first);
      return dateB.compareTo(dateA); // For descending order
    });
  });

  return sortedMap;
}

int compareDates(String k1, String k2) {
  DateTime now = DateTime.now();
  DateTime aWeekAgo = now.subtract(const Duration(days: 7));

  if (k1 == 'Today' && k2 != 'Today') return -1;
  if (k2 == 'Today' && k1 != 'Today') return 1;
  if (k1 == 'Yesterday' && k2 != 'Yesterday') return -1;
  if (k2 == 'Yesterday' && k1 != 'Yesterday') return 1;

  // Parsing the dates and comparing them
  DateTime date1 = DateFormat('yyyy-MM-dd').parse(k1, true);
  DateTime date2 = DateFormat('yyyy-MM-dd').parse(k2, true);

  // Check if the dates are within a week from today
  if (date1.isAfter(aWeekAgo) && date2.isAfter(aWeekAgo)) {
    return date2.compareTo(date1);
  }
  if (date1.isAfter(aWeekAgo)) return -1;
  if (date2.isAfter(aWeekAgo)) return 1;

  return date2.compareTo(date1);
}
