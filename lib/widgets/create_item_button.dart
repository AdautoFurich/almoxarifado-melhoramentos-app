import 'package:flutter/material.dart';

class CreateItemButton extends StatelessWidget {
  const CreateItemButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: FilledButton.icon(
          key: const ValueKey('show-create-item-form-button'),
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: const Text('Cadastrar item'),
        ),
      ),
    );
  }
}
