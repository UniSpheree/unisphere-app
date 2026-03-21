import 'package:flutter/material.dart';
import 'package:unisphere_app/widgets/header.dart';

class ViewEventScreen extends StatelessWidget {
  const ViewEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(),
      body: const Center(
        child: Text('Event details coming soon'),
      ),
    );
  }
}


