import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:app_auth_firebase_ppb/sevices/notification_service.dart';
import 'package:app_auth_firebase_ppb/sevices/firestore_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirestoreService firestoreService = FirestoreService();
  bool notificationsEnabled = true;
  TimeOfDay? selectedTime;

  void toggleNotifications(String docID, bool value, TimeOfDay time) async {
    setState(() {
      notificationsEnabled = value;
    });

    if (notificationsEnabled) {
      if (docID.isEmpty) {
        await firestoreService.addReminder(value, time);
      } else {
        await firestoreService.updateReminder(docID, value, time);
      }
    } else {
      AwesomeNotifications().cancelAll();
      await firestoreService.updateReminder(docID, value, time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Settings'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 186, 160, 255),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, 'home');
          },
        ),
      ),
      body: StreamBuilder(
        stream: firestoreService.getReminder(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // No reminder set yet
            return settingsBody(context, null, null, null);
          }
          // Use the latest reminder
          final doc = snapshot.data!.docs.first;
          final data = doc.data() as Map<String, dynamic>;
          final bool toggle = data['toggle'] ?? true;
          final timeMap = data['time'];
          TimeOfDay? time;
          if (timeMap != null && timeMap is Map) {
            time = TimeOfDay(
              hour: timeMap['hour'] ?? 0,
              minute: timeMap['minute'] ?? 0,
            );
          }
          return settingsBody(context, toggle, time, doc.id);
        },
      ),
    );
  }

  // Helper widget for the settings UI
  Widget settingsBody(
    BuildContext context,
    bool? toggle,
    TimeOfDay? time,
    String? docID,
  ) {
    notificationsEnabled = toggle ?? false;
    selectedTime = time ?? TimeOfDay.now();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade400, width: 0.7),
            ),
          ),
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: 18,
            right: 18,
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text(
                'Enable Notifications',
                style: TextStyle(fontSize: 21),
              ),
              Switch(
                value: notificationsEnabled,
                onChanged: (value) async {
                  toggleNotifications(docID ?? '', value, selectedTime!);
                },
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selectedTime != null
                    ? 'Reminder Time: ${selectedTime!.format(context)}'
                    : 'No time selected',
                style: const TextStyle(fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedTime = picked;
                    });

                    await firestoreService.updateReminder(
                      docID!,
                      notificationsEnabled,
                      selectedTime!,
                    );
                  }
                },
              ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed:
              notificationsEnabled
                  ? () async {
                    await NotificationService.createNotification(
                      id: 1,
                      title: 'Check your notes!!',
                      body: 'Don\'t forget to check your notes today',
                      scheduled: true,
                      time: selectedTime,
                    );
                    if (selectedTime != null) {
                      await firestoreService.updateReminder(
                        docID!,
                        notificationsEnabled,
                        selectedTime!,
                      );
                    }
                  }
                  : null,
          child: const Text('Set Notification', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
