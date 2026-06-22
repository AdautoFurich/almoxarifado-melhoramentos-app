import 'dart:io';

import 'package:flutter/material.dart';

import '../models/inventory_item.dart';

class ItemDetailsPage extends StatelessWidget {
  const ItemDetailsPage({super.key, required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do item')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DetailsHeader(item: item),
                  const SizedBox(height: 14),
                  _DetailsSection(
                    title: 'Dados do item',
                    icon: Icons.assignment_outlined,
                    children: [
                      _DetailTile(label: 'Nome', value: item.name),
                      _DetailTile(label: 'Código', value: item.code),
                      _DetailTile(
                        label: 'Descrição',
                        value: item.description.isEmpty
                            ? 'Sem descrição cadastrada.'
                            : item.description,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _PhotoSection(photoPath: item.photoPath),
                  const SizedBox(height: 14),
                  _HistorySection(history: item.history),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF0A5B2A), Color(0xFF14763A)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF0D6E32),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.code,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2F6F3E)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1F2A21),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF667065),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1F2A21),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({required this.photoPath});

  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        photoPath != null &&
        photoPath!.isNotEmpty &&
        File(photoPath!).existsSync();

    return _DetailsSection(
      title: 'Foto',
      icon: Icons.photo_camera_outlined,
      children: [
        Container(
          height: 170,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9F4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: hasPhoto
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(photoPath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.image_not_supported_outlined,
                      color: Color(0xFF7A867D),
                      size: 38,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhuma foto cadastrada.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF667065),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.history});

  final List<String> history;

  @override
  Widget build(BuildContext context) {
    final entries = history.isEmpty
        ? const ['Sem movimentações registradas.']
        : history;

    return _DetailsSection(
      title: 'Histórico',
      icon: Icons.history_outlined,
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2F6F3E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF1F2A21),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
