import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_cv/Models/course_info_model.dart';
import 'package:final_cv/services/database.dart';
import 'package:final_cv/Screens/common_screen_widgets.dart';
import 'package:final_cv/Screens/sign_in_page.dart';

class AccountPage extends StatefulWidget {
  final FirebaseAuth auth;
  // User? user;
  final Database database;
  final List<Course> allCourses;
  final bool isTeacher;
  final Function onUpdate;

  AccountPage({
    super.key,
    required this.auth,
    // this.user,
    required this.database,
    required this.allCourses,
    required this.isTeacher,
    required this.onUpdate
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? user = FirebaseAuth.instance.currentUser;
  void reload(){
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Account',
          style: TextStyle(
            fontSize: 25, // Increase font size for better visibility
            fontWeight: FontWeight.bold, // Added font weight for better readability
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor, // A slightly deeper shade of blue
        elevation: 4.0, // Increased elevation for a subtle shadow effect
      ),
      drawer: MyNavigationDrawer(
        isTeacher: widget.isTeacher,
        auth: widget.auth,
        user: user!,
        database: Database(user: user!),
        allCourses: widget.allCourses,
        currentPage: "Account",
        onUpdate: widget.onUpdate,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AccountCard(user: user!, isTeacher: widget.isTeacher),
            const SizedBox(height: 10),
            AccountPersonalInfo(user: user!, isTeacher: widget.isTeacher, refreshAccountPage: reload),
            const SizedBox(height: 15),
            AccountLogoutCard(auth: widget.auth, context: context),
            AccountDeleteCard(auth: widget.auth, database: widget.database, context: context),
          ],
        ),
      ),
    );
  }
}

class AccountCard extends StatelessWidget {
  final User user;
  final bool isTeacher;

  const AccountCard({super.key, required this.user, required this.isTeacher});


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Increased vertical margin for more space
      elevation: 2, // Slightly higher elevation for a more pronounced shadow effect
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(5), // Added padding inside the card for a more spacious layout
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5), // Adjust the content padding within ListTile
          leading: CircleAvatar(
            radius: 25, // Maintain the same radius for the avatar
            backgroundImage: NetworkImage(user.photoURL ?? ''),
            backgroundColor: Colors.grey[200],
          ),
          title: Text(
            user.displayName == null || user.displayName == "" ? 'User' : user.displayName!,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Increased font size for better visibility
          ),
        ),
      ),
    );
  }
}

class AccountPersonalInfo extends StatefulWidget {
  final User user;
  final bool isTeacher;
  final Function refreshAccountPage;

  const AccountPersonalInfo({super.key, required this.user, required this.isTeacher, required this.refreshAccountPage});

  @override
  State<AccountPersonalInfo> createState() => _AccountPersonalInfoState();
}

class _AccountPersonalInfoState extends State<AccountPersonalInfo> {
  bool isNameUpdating = false;
  @override
  Widget build(BuildContext context) {
    String newName = '';
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
              ),
              const Divider(height: 20, thickness: 1),
              TextButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Change Name', style: TextStyle(fontSize: 18),),
                style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.transparent)),
                onPressed: isNameUpdating ? null: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('New Name'),
                        content: TextField(
                          onChanged: (value) {
                            setState(() {
                              newName = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Enter New Name',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                isNameUpdating = true;
                              });
                              Navigator.of(context).pop();
                              await widget.user.updateDisplayName(newName);
                              await widget.refreshAccountPage();
                              await Database(user: widget.user).updateUserNameInDatabase(newName);
                              setState(() {
                                isNameUpdating = false;
                              });
                            },
                            child: const Text('Submit'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const Divider(height: 20, thickness: 1),
              TextButton.icon(
                icon: const Icon(Icons.email),
                label: Text(widget.user.email!, style: const TextStyle(fontSize: 16, color: Colors.grey),),
                style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.transparent)),
                onPressed: () {
                  // will do nothing 
                },
              ),
              const Divider(height: 20, thickness: 1),
              TextButton.icon(
                icon: const Icon(Icons.supervised_user_circle),
                label: Text(widget.isTeacher ? "Teacher" : "Student", style: const TextStyle(fontSize: 16, color: Colors.grey),),
                style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.transparent)),
                onPressed: () {
                  // will do nothing
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountLogoutCard extends StatelessWidget {
  final FirebaseAuth auth;
  final BuildContext context;

  const AccountLogoutCard({super.key, required this.auth, required this.context});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Log Out'),
              content: const Text('Confirm Log out?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    auth.signOut();
                    Navigator.pop(context, true);
                    Navigator.pop(context, true);
                    Navigator.pop(context, true);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInPage()));
                  },
                  child: const Text('Log Out'),
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: const Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.exit_to_app, color: Colors.red),
                SizedBox(width: 10),
                Text(
                  'Log Out',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccountDeleteCard extends StatelessWidget {
  final FirebaseAuth auth;
  final Database database;
  final BuildContext context;

  const AccountDeleteCard({super.key, required this.auth, required this.database, required this.context});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Account'),
              content: const Text('Confirm Delete your account?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async{
                    await database.deleteUser();
                    auth.signOut();
                    Navigator.pop(context, true);
                    Navigator.pop(context, true);
                    Navigator.pop(context, true);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInPage()));
                  },
                  child: const Text('Delete Account'),
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: const Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_forever, color: Colors.red),
                const SizedBox(width: 10),
                Text(
                  'Delete Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
