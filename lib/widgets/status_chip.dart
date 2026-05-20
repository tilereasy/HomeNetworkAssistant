import 'package:flutter/material.dart';

import '../models/network_device.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final DeviceStatus status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_label(status)),
      backgroundColor: _color(status).withValues(alpha: 0.14),
      side: BorderSide(color: _color(status).withValues(alpha: 0.3)),
      labelStyle: TextStyle(color: _color(status), fontWeight: FontWeight.w600),
    );
  }

  static String _label(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.active:
        return 'Активно';
      case DeviceStatus.inactive:
        return 'Неактивно';
      case DeviceStatus.issue:
        return 'Проблема';
      case DeviceStatus.pending:
        return 'Ожидает';
      case DeviceStatus.rejected:
        return 'Отклонено';
    }
  }

  static Color _color(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.active:
        return Colors.green;
      case DeviceStatus.inactive:
        return Colors.grey;
      case DeviceStatus.issue:
        return Colors.orange;
      case DeviceStatus.pending:
        return Colors.blue;
      case DeviceStatus.rejected:
        return Colors.red;
    }
  }
}
