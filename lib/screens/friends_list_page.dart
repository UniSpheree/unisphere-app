import 'package:flutter/material.dart';

class FriendsListPage extends StatelessWidget {
  const FriendsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy friends list
    final friends = [
      {'name': 'Jane Smith', 'status': 'Online'},
      {'name': 'John Appleseed', 'status': 'Offline'},
      {'name': 'Emily Doe', 'status': 'Online'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('All Friends')),
      body: ListView.separated(
        itemCount: friends.length,
        separatorBuilder: (context, i) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final friend = friends[i];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(friend['name']!),
            subtitle: Text(friend['status']!),
            trailing: IconButton(
              icon: const Icon(Icons.message),
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }
}
