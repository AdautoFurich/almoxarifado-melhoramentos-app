import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/item_code_formatters.dart';

class ItemForm extends StatelessWidget {
  const ItemForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.codeController,
    required this.descriptionController,
    required this.locationController,
    required this.quantityController,
    required this.isCodeRegistered,
    required this.isEditing,
    required this.onCancelEditing,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController codeController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final TextEditingController quantityController;
  final bool Function(String code) isCodeRegistered;
  final bool isEditing;
  final VoidCallback onCancelEditing;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ItemFormHeader(isEditing: isEditing, onClose: onCancelEditing),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FormFieldShell(
                    icon: Icons.inventory_2_outlined,
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do item',
                        hintText: 'Digite o nome do item',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          color: Color(0xFF0D6E32),
                          fontWeight: FontWeight.w800,
                        ),
                        hintStyle: TextStyle(color: Color(0xFF7A867D)),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o nome do item';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FormFieldShell(
                    icon: Icons.qr_code_2_outlined,
                    trailing: const _BarcodeHintIcon(),
                    child: TextFormField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'Código do item',
                        hintText: 'Digite o código do item',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          color: Color(0xFF0D6E32),
                          fontWeight: FontWeight.w800,
                        ),
                        hintStyle: TextStyle(color: Color(0xFF7A867D)),
                      ),
                      inputFormatters: const [ItemCodeInputFormatter()],
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => onSubmit(),
                      validator: (value) {
                        final digits =
                            value?.replaceAll(RegExp(r'\D'), '') ?? '';

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
                  ),
                  const SizedBox(height: 10),
                  _FormFieldShell(
                    icon: Icons.place_outlined,
                    child: TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Localização',
                        hintText: 'Ex.: Corredor A, Prateleira 3',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          color: Color(0xFF0D6E32),
                          fontWeight: FontWeight.w800,
                        ),
                        hintStyle: TextStyle(color: Color(0xFF7A867D)),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FormFieldShell(
                    icon: Icons.numbers_outlined,
                    child: TextFormField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        hintText: 'Digite a quantidade em estoque',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          color: Color(0xFF0D6E32),
                          fontWeight: FontWeight.w800,
                        ),
                        hintStyle: TextStyle(color: Color(0xFF7A867D)),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FormFieldShell(
                    icon: Icons.description_outlined,
                    alignIconToTop: true,
                    child: TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição do item',
                        hintText: 'Digite a descrição (opcional)',
                        counterText: '',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          color: Color(0xFF0D6E32),
                          fontWeight: FontWeight.w800,
                        ),
                        hintStyle: TextStyle(color: Color(0xFF7A867D)),
                      ),
                      maxLength: 200,
                      minLines: 2,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: descriptionController,
                      builder: (context, value, _) {
                        return Text(
                          '${value.text.length}/200',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: const Color(0xFF7A867D),
                                fontWeight: FontWeight.w600,
                              ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onSubmit,
                    icon: Icon(isEditing ? Icons.save_outlined : Icons.add),
                    label: Text(
                      isEditing ? 'Salvar alterações' : 'Cadastrar item',
                    ),
                  ),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: onCancelEditing,
                    icon: const Icon(Icons.keyboard_arrow_up),
                    label: Text(isEditing ? 'Cancelar edição' : 'Recolher'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemFormHeader extends StatelessWidget {
  const _ItemFormHeader({required this.isEditing, required this.onClose});

  final bool isEditing;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF0A5B2A), Color(0xFF0D6E32), Color(0xFF075324)],
        ),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_note : Icons.inventory,
                      color: const Color(0xFF0D6E32),
                      size: 22,
                    ),
                  ),
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D6E32),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        isEditing ? Icons.check : Icons.add,
                        color: Colors.white,
                        size: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Editar item' : 'Cadastrar item',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEditing
                          ? 'Atualize os dados do item'
                          : 'Preencha os dados do item',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: isEditing ? 'Cancelar edição' : 'Fechar cadastro',
                onPressed: onClose,
                icon: const Icon(Icons.close),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  fixedSize: const Size(38, 38),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormFieldShell extends StatelessWidget {
  const _FormFieldShell({
    required this.icon,
    required this.child,
    this.trailing,
    this.alignIconToTop = false,
  });

  final IconData icon;
  final Widget child;
  final Widget? trailing;
  final bool alignIconToTop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E8DF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: alignIconToTop
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            margin: EdgeInsets.only(top: alignIconToTop ? 2 : 0),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6F1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF0D6E32), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}

class _BarcodeHintIcon extends StatelessWidget {
  const _BarcodeHintIcon();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 1, height: 38, color: const Color(0xFFE1E7DC)),
        const SizedBox(width: 10),
        const Icon(
          Icons.document_scanner_outlined,
          color: Color(0xFF0D6E32),
          size: 24,
        ),
      ],
    );
  }
}
