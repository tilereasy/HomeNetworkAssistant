import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            title: Text('Home Network Assistant'),
            subtitle: Text(
              'Приложение для учёта устройств, заявок пользователей, проектов сети и настроек домашнего роутера.',
            ),
          ),
        ),
      ],
    );
  }
}
