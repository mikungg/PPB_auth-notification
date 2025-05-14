import 'package:app_auth_firebase_ppb/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:app_auth_firebase_ppb/sevices/notification_service.dart';
import 'package:app_auth_firebase_ppb/sevices/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  void logout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  void openNoteBox([String? docID]) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: 'Enter title'),
                ),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your note',
                  ),
                  maxLines: 5,
                ),
              ],
            ),
            actions: [
              OutlinedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 186, 160, 255),
                  ),
                ),
                onPressed: () {
                  if (docID == null) {
                    // add new note
                    firestoreService.addNote(
                      titleController.text,
                      textController.text,
                    );
                  } else {
                    // update existing note
                    firestoreService.updateNote(
                      docID,
                      titleController.text,
                      textController.text,
                    );
                  }
                  titleController.clear();
                  textController.clear();
                  Navigator.pop(context);
                },
                child: Text(docID == null ? 'Add' : 'Update'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Notes'),
              centerTitle: true,
              backgroundColor: const Color.fromARGB(255, 186, 160, 255),
            ),
            drawer: Drawer(
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(snapshot.data?.email ?? ''),
                    accountEmail: Text(''),
                    currentAccountPicture: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications Settings'),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, 'home');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () => logout(context),
                  ),
                ],
              ),
            ),
            body: Center(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                children: [
                  StreamBuilder(
                    stream: firestoreService.getNotes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final notes = snapshot.data!.docs;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return Card(
                              child: ListTile(
                                title: Text(note['title']),
                                subtitle: Text(note['note']),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        titleController.text = note['title'];
                                        textController.text = note['note'];
                                        openNoteBox(note.id);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        firestoreService.deleteNote(note.id);
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {},
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ],
              ),
              // child: ListView(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   children: [
              //     // Placeholder for the notification buttons
              //     Text('Logged in as ${snapshot.data?.email}'),
              //     OutlinedButton(
              //       onPressed: () => logout(context),
              //       child: const Text('Logout'),
              //     ),
              //     OutlinedButton(
              //       onPressed: () async {
              //         await NotificationService.createNotification(
              //           id: 1,
              //           title: 'Default Notification',
              //           body: 'This is the body of the notification',
              //           summary: 'Small summary',
              //         );
              //       },
              //       child: const Text('Default Notification'),
              //     ),
              //     OutlinedButton(
              //       onPressed: () async {
              //         await NotificationService.createNotification(
              //           id: 2,
              //           title: 'Notification with Summary',
              //           body: 'This is the body of the notification',
              //           summary: 'Small summary',
              //           notificationLayout: NotificationLayout.Inbox,
              //         );
              //       },
              //       child: const Text('Notification with Summary'),
              //     ),
              //     OutlinedButton(
              //       onPressed: () async {
              //         await NotificationService.createNotification(
              //           id: 3,
              //           title: 'Progress Bar Notification',
              //           body: 'This is the body of the notification',
              //           summary: 'Small summary',
              //           notificationLayout: NotificationLayout.ProgressBar,
              //         );
              //       },
              //       child: const Text('Progress Bar Notification'),
              //     ),
              //     OutlinedButton(
              //       onPressed: () async {
              //         await NotificationService.createNotification(
              //           id: 4,
              //           title: 'Message Notification',
              //           body: 'This is the body of the notification',
              //           summary: 'Small summary',
              //           notificationLayout: NotificationLayout.Messaging,
              //         );
              //       },
              //       child: const Text('Message Notification'),
              //     ),
              //     OutlinedButton(
              //       onPressed: () async {
              //         await NotificationService.createNotification(
              //           id: 5,
              //           title: 'Big Image Notification',
              //           body: 'This is the body of the notification',
              //           summary: 'Small summary',
              //           notificationLayout: NotificationLayout.BigPicture,
              //           bigPicture: 'https://picsum.photos/300/200',
              //         );
              //       },
              //       child: const Text('Big Image Notification'),
              //     ),
              //     OutlinedButton(
              //       onPressed: () async {
              //         await NotificationService.createNotification(
              //           id: 5,
              //           title: 'Action Button Notification',
              //           body: 'This is the body of the notification',
              //           payload: {'navigate': 'true'},
              //           actionButtons: [
              //             NotificationActionButton(
              //               key: 'action_button',
              //               label: 'Click me',
              //               actionType: ActionType.Default,
              //             ),
              //           ],
              //         );
              //       },
              //       child: const Text('Action Button Notification'),
              //     ),
              //     OutlinedButton(
              //       onPressed: () async {
              //         await NotificationService.createNotification(
              //           id: 5,
              //           title: 'Scheduled Notification',
              //           body: 'This is the body of the notification',
              //           scheduled: true,
              //           interval: const Duration(seconds: 5),
              //         );
              //       },
              //       child: const Text('Scheduled Notification'),
              //     ),
              //   ],
              // ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                openNoteBox();
              },
              child: const Icon(Icons.add),
            ),
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
