import 'package:flutter/material.dart';

import '../utils/mock_backend.dart';
import 'create_event_screen.dart';
import 'event_details_screen.dart';
import '../widgets/header.dart';
import '../widgets/app_footer.dart';

class MyEventsPage extends StatelessWidget {
  const MyEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockBackend().currentUser;

    Widget bodyContent;
    if (!(user?.isOrganiser ?? false)) {
      bodyContent = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_outline, color: Color(0xFF4F46E5)),
                  const SizedBox(height: 16),
                  const Text(
                    'My events is organiser only',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Switch your profile role to Organiser to manage created events here.',
                    style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    child: const Text('Open profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      bodyContent = AnimatedBuilder(
        animation: MockBackend(),
        builder: (context, _) {
          final email = MockBackend().currentUser?.email;
          final myEvents = MockBackend().events
              .where((event) => event['organizerEmail']?.toString() == email)
              .toList();

          if (myEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'You have no events',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateEventScreen(),
                        ),
                      );
                    },
                    child: const Text('Create Event'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final event = myEvents[index];
              return Card(
                child: ListTile(
                  title: Text(event['title']?.toString() ?? 'Untitled Event'),
                  subtitle: Text(
                    '${event['date'] ?? ''} • ${event['location'] ?? ''}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailsScreen(event: event),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CreateEventScreen(existingEvent: event),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        onPressed: () async {
                          await MockBackend().deleteEvent(
                            event['id'].toString(),
                          );
                        },
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: myEvents.length,
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: Column(
        children: [
          AppHeader(showBackButton: true),
          Expanded(child: bodyContent),
          const AppFooter(),
        ],
      ),
      floatingActionButton: user?.isOrganiser ?? false
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEventScreen(),
                  ),
                );
              },
              label: const Text('Create Event'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }
}
