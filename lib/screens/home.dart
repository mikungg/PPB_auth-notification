import 'package:app_auth_firebase_ppb/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
                      Navigator.pushReplacementNamed(context, 'notification');
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
