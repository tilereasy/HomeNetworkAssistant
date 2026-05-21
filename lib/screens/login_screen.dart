import 'package:flutter/material.dart';

import '../services/app_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.refreshBackendStatus();
    });
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFCCFBF1), Color(0xFFF4F7F5)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, _) {
                    return Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.router_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Home Network Assistant',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            const SizedBox(height: 12),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  widget.controller.backendChecking
                                      ? Icons.sync
                                      : widget.controller.backendAvailable
                                          ? Icons.cloud_done_outlined
                                          : Icons.cloud_off_outlined,
                                  color: widget.controller.backendChecking
                                      ? Colors.orange
                                      : widget.controller.backendAvailable
                                          ? Colors.green
                                          : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.controller.backendChecking
                                        ? 'Проверяем соединение с backend...'
                                        : widget.controller.backendAvailable
                                            ? 'Соединение с backend есть'
                                            : 'Backend недоступен',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Проверить соединение',
                                  onPressed: widget.controller.backendChecking
                                      ? null
                                      : () => widget.controller.refreshBackendStatus(),
                                  icon: const Icon(Icons.refresh),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _loginController,
                              decoration: const InputDecoration(
                                labelText: 'Логин',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Введите логин' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Пароль',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Введите пароль'
                                  : null,
                            ),
                            if (widget.controller.loginError != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                widget.controller.loginError!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _submitting ? null : _submit,
                                child: _submitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Войти'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.controller.login(
        _loginController.text.trim(),
        _passwordController.text.trim(),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
