import 'package:flutter/material.dart';

import '../models/network_device.dart';
import '../services/app_controller.dart';
import 'device_form_screen.dart';

class EditDeviceScreen extends StatelessWidget {
  const EditDeviceScreen({
    super.key,
    required this.controller,
    required this.device,
  });

  final AppController controller;
  final NetworkDevice device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать устройство')),
      body: DeviceFormView(
        initialDevice: device,
        isAdmin: true,
        createdBy: controller.currentUser!.login,
      ),
    );
  }
}
