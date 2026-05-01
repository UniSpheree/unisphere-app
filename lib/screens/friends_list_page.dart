import 'package:flutter/material.dart';

import 'chat_page.dart';
import '../widgets/header.dart';
import '../widgets/app_footer.dart';

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
      backgroundColor: const Color(0xFFF0F2F8),
      body: Column(
        children: [
          AppHeader(),
          Expanded(
            child: ListView.separated(
              itemCount: friends.length,
              separatorBuilder: (context, i) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final friend = friends[i];
                final friendName = friend['name']!;
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(friendName),
                  subtitle: Text(friend['status']!),
                  trailing: IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(friendName: friendName),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}
