import 'package:flutter/material.dart';

class CreateItemButton extends StatelessWidget {
  const CreateItemButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final iconSize = isCompact ? 40.0 : 46.0;
        final horizontalPadding = isCompact ? 14.0 : 18.0;
        final titleStyle = Theme.of(context).textTheme.titleMedium;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            key: const ValueKey('show-create-item-form-button'),
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF1D7C3A),
                    Color(0xFF11642C),
                    Color(0xFF0E5A28),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isCompact ? 12 : 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: const Color(0xFF1D7C3A),
                        size: isCompact ? 24 : 28,
                      ),
                    ),
                    SizedBox(width: isCompact ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cadastrar item',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titleStyle?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Adicione um novo item ao almoxarifado',
                            maxLines: isCompact ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 26,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
