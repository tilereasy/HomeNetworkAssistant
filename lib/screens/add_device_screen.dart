import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import 'device_form_screen.dart';

class AddDeviceScreen extends StatelessWidget {
  const AddDeviceScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить устройство')),
      body: DeviceFormView(
        isAdmin: controller.isAdmin,
        createdBy: controller.currentUser!.login,
      ),
    );
  }
}
