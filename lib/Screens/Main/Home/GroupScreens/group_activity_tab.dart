import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split/Controller/group_activity_organizer.dart';
import 'package:split/Model/group_model.dart';
import 'package:split/Widgets/description_text.dart';

class GroupActivityTab extends StatefulWidget {
  const GroupActivityTab({
    super.key,
    required this.index,
  });

  final int index;

  @override
  State<GroupActivityTab> createState() => _GroupActivityTabState();
}

class _GroupActivityTabState extends State<GroupActivityTab> {
  @override
  Widget build(BuildContext context) {
    List<Group> groups = Provider.of<List<Group>>(context);

    Group groupData = groups[widget.index];
    Map<String, List<Map<String, dynamic>>> organizedActivities =
        organizeActivities(groupData.groupActivity);
    List<String> dates = organizedActivities.keys.toList();

    return SafeArea(
        child: ListView.builder(
      itemCount: dates.length,
      itemBuilder: (context, index) {
        String date = dates[index];
        List<Map<String, dynamic>> dateActivities = organizedActivities[date]!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: dateActivities.length,
                itemBuilder: (context, activityIndex) {
                  String key = dateActivities[activityIndex].keys.first;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.attach_money,
                      size: 18,
                    ),
                    title: DescriptionTextStyle(
                      text: dateActivities[activityIndex][key],
                    ),
                    trailing: Text(date),
                  );
                },
              ),
            ],
          ),
        );
      },
    ));
  }
}
