import 'package:flutter/material.dart';

import '../models/network_project.dart';
import '../models/router_settings.dart';
import '../services/app_controller.dart';
import '../widgets/empty_state.dart';

class ProjectSelectionScreen extends StatelessWidget {
  const ProjectSelectionScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.data.projects.isEmpty) {
      return const EmptyState(
        title: 'Нет проектов',
        subtitle: 'Создайте первый проект домашней сети.',
        icon: Icons.home_work_outlined,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: controller.data.projects.map((project) {
        final isSelected = project.id == controller.currentProject.id;
        return Card(
          child: ListTile(
            title: Text(project.name),
            subtitle: Text(
              '${project.propertyType} · ${project.roomCount} комнат · ${project.provider}\n${project.description}',
            ),
            isThreeLine: true,
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.chevron_right),
            onTap: () => controller.selectProject(project.id),
          ),
        );
      }).toList(),
    );
  }
}

class ProjectCreateDialog extends StatefulWidget {
  const ProjectCreateDialog({super.key, required this.controller});

  final AppController controller;

  @override
  State<ProjectCreateDialog> createState() => _ProjectCreateDialogState();
}

class _ProjectCreateDialogState extends State<ProjectCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _providerController = TextEditingController();
  final _routerController = TextEditingController();
  String _propertyType = 'Квартира';
  double _roomCount = 4;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _providerController.dispose();
    _routerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новый проект'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Название'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Введите название проекта' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _propertyType,
                decoration: const InputDecoration(labelText: 'Тип помещения'),
                items: const ['Квартира', 'Дом', 'Офис', 'Общежитие']
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) => setState(() => _propertyType = value!),
              ),
              const SizedBox(height: 12),
              Text('Количество комнат: ${_roomCount.round()}'),
              Slider(
                value: _roomCount,
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (value) => setState(() => _roomCount = value),
              ),
              TextFormField(
                controller: _providerController,
                decoration: const InputDecoration(labelText: 'Провайдер'),
              ),
              TextFormField(
                controller: _routerController,
                decoration: const InputDecoration(labelText: 'Основной роутер'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () async {
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }
            final projectId = widget.controller.nextProjectId();
            await widget.controller.createProject(
              NetworkProject(
                id: projectId,
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim().isEmpty
                    ? 'Новый проект домашней сети'
                    : _descriptionController.text.trim(),
                propertyType: _propertyType,
                roomCount: _roomCount.round(),
                provider: _providerController.text.trim().isEmpty
                    ? 'Провайдер не указан'
                    : _providerController.text.trim(),
                primaryRouterName: _routerController.text.trim().isEmpty
                    ? 'Основной роутер'
                    : _routerController.text.trim(),
              ),
              RouterSettings(
                projectId: projectId,
                ssid: 'NewProjectWiFi',
                password: 'change-me',
                band: '5 GHz',
                channel: '36',
                dhcpEnabled: true,
                dhcpRange: '192.168.1.100 - 192.168.1.200',
                guestNetworkEnabled: true,
                hiddenSsid: false,
                maxDevices: 40,
              ),
            );
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Создать'),
        ),
      ],
    );
  }
}
