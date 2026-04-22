import 'package:flutter/material.dart';

import '../widgets/header.dart';
import 'chat_page.dart';
import 'calendar_page.dart';
import 'my_events_page.dart';
import 'friends_list_page.dart';

class ProfilePage extends StatefulWidget {
  final ImageProvider? image;
  const ProfilePage({Key? key, this.image}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'John Doe';
  String description = 'A short description about the user goes here.';
  String email = 'john.doe@email.com';
  String university = 'Sample University';
  bool isOrganiser = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(88),
        child: AppHeader(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile info
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.indigo.shade100,
                        backgroundImage: widget.image,
                        child: widget.image == null
                            ? const Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.indigo,
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.email,
                            size: 18,
                            color: Colors.indigo,
                          ),
                          const SizedBox(width: 6),
                          Text(email, style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.school,
                            size: 18,
                            color: Colors.indigo,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            university,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Role: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(isOrganiser ? 'Organiser' : 'Attendee'),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isOrganiser = !isOrganiser;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isOrganiser
                                  ? Colors.orange
                                  : Colors.indigo,
                              foregroundColor: Colors.white,
                              minimumSize: Size(0, 32),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: Text(
                              isOrganiser
                                  ? 'Switch to Attendee'
                                  : 'Switch to Organiser',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          final nameController = TextEditingController(
                            text: name,
                          );
                          final descController = TextEditingController(
                            text: description,
                          );
                          final emailController = TextEditingController(
                            text: email,
                          );
                          final universityController = TextEditingController(
                            text: university,
                          );
                          final emailFormKey = GlobalKey<FormState>();
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  width: 400,
                                  padding: const EdgeInsets.all(32),
                                  child: Form(
                                    key: emailFormKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Edit Profile',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        TextField(
                                          controller: nameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Name',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextField(
                                          controller: descController,
                                          decoration: const InputDecoration(
                                            labelText: 'Description',
                                            border: OutlineInputBorder(),
                                          ),
                                          minLines: 2,
                                          maxLines: 4,
                                        ),
                                        const SizedBox(height: 20),
                                        TextField(
                                          controller: emailController,
                                          decoration: const InputDecoration(
                                            labelText: 'Email',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextField(
                                          controller: universityController,
                                          decoration: const InputDecoration(
                                            labelText: 'University',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 28),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            const SizedBox(width: 12),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  name = nameController.text;
                                                  description =
                                                      descController.text;
                                                  email = emailController.text;
                                                  university =
                                                      universityController.text;
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Save'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                // Buttons
                SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Friends',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FriendsListPage(),
                                ),
                              );
                            },
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                      Container(
                        height: 220,
                        width: 260,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                              leading: const CircleAvatar(
                                backgroundColor: Colors.indigo,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: const Text(
                                'Jane Smith',
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: const Text('Online'),
                              trailing: IconButton(
                                icon: const Icon(Icons.message),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ChatPage(
                                        friendName: 'Jane Smith',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              minLeadingWidth: 0,
                            ),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                              leading: const CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: const Text(
                                'John App',
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: const Text('Offline'),
                              trailing: IconButton(
                                icon: const Icon(Icons.message),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ChatPage(
                                        friendName: 'John App',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              minLeadingWidth: 0,
                            ),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                              leading: const CircleAvatar(
                                backgroundColor: Colors.purple,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: const Text(
                                'Emily Doe',
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: const Text('Online'),
                              trailing: IconButton(
                                icon: const Icon(Icons.message),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ChatPage(
                                        friendName: 'Emily Doe',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              minLeadingWidth: 0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CalendarPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo.shade50,
                                foregroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Events Calendar'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (isOrganiser)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MyEventsPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo.shade50,
                                  foregroundColor: Colors.indigo,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('My Events'),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
