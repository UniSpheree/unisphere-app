import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final isFirst = currentPage <= 0;
    final isLast = currentPage >= totalPages - 1;

    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;

          final status = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF4F46E5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Page ${currentPage + 1} of $totalPages',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          );

          final controls = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PagerButton(
                label: 'Previous',
                icon: Icons.chevron_left_rounded,
                enabled: !isFirst,
                onPressed: onPrevious,
                inverse: false,
              ),
              const SizedBox(width: 10),
              _PagerButton(
                label: 'Next',
                icon: Icons.chevron_right_rounded,
                enabled: !isLast,
                onPressed: onNext,
                inverse: true,
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                status,
                const SizedBox(height: 12),
                controls,
              ],
            );
          }

          return Row(
            children: [
              status,
              const Spacer(),
              controls,
            ],
          );
        },
      ),
    );
  }
}

class _PagerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  final bool inverse;

  const _PagerButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onPressed,
    required this.inverse,
  });

  @override
  Widget build(BuildContext context) {
    final background = enabled
        ? (inverse ? const Color(0xFF4F46E5) : const Color(0xFFF8FAFC))
        : const Color(0xFFF3F4F6);
    final foreground = enabled
        ? (inverse ? Colors.white : const Color(0xFF111827))
        : const Color(0xFF9CA3AF);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled
                  ? (inverse ? const Color(0xFF4F46E5) : const Color(0xFFD1D5DB))
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
