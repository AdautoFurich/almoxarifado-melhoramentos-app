import 'package:flutter/material.dart';

import '../utils/item_code_formatters.dart';

class ItemForm extends StatelessWidget {
  const ItemForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.codeController,
    required this.isCodeRegistered,
    required this.isEditing,
    required this.onCancelEditing,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController codeController;
  final bool Function(String code) isCodeRegistered;
  final bool isEditing;
  final VoidCallback onCancelEditing;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do item',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do item';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Código do item',
                  prefixIcon: Icon(Icons.qr_code_2_outlined),
                ),
                inputFormatters: const [ItemCodeInputFormatter()],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onSubmit(),
                validator: (value) {
                  final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';

                  if (digits.isEmpty) {
                    return 'Informe o código do item';
                  }

                  if (digits.length < 12) {
                    return 'Informe os 12 números do código';
                  }

                  if (isCodeRegistered(value!)) {
                    return 'Já existe um item cadastrado com este código';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onSubmit,
                icon: Icon(isEditing ? Icons.save_outlined : Icons.add),
                label: Text(isEditing ? 'Salvar alterações' : 'Cadastrar item'),
              ),
              if (isEditing) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onCancelEditing,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancelar edição'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
