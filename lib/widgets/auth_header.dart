import 'package:flutter/material.dart';

/// Top bar shown on Login / Register pages (no nav links).
class AuthHeader extends StatelessWidget implements PreferredSizeWidget {
  const AuthHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // ── Logo ──────────────────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D3A8C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.hub_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'UniSphere',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2D3A8C),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // ── Right actions ──────────────────────────────────
            TextButton(
              onPressed: () {},
              child: Text(
                'Help Center',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 4),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Text('🌐', style: TextStyle(fontSize: 13)),
              label: const Text(
                'English',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2D3A8C),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2D3A8C)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
