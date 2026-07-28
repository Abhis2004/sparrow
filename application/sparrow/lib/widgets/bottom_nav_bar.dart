import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 82,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: 68,
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildItem(
                      context,
                      index: 0,
                      icon: Icons.home_rounded,
                      label: 'Home',
                    ),
                  ),
                  Expanded(
                    child: _buildItem(
                      context,
                      index: 1,
                      icon: Icons.folder_outlined,
                      label: 'Incidents',
                    ),
                  ),

                  const SizedBox(width: 60),

                  Expanded(
                    child: _buildItem(
                      context,
                      index: 3,
                      icon: Icons.search_rounded,
                      label: 'Search',
                    ),
                  ),
                  Expanded(
                    child: _buildItem(
                      context,
                      index: 4,
                      icon: Icons.person_outline_rounded,
                      label: 'Profile',
                    ),
                  ),
                ],
              ),
            ),

            /// Floating New Incident Button
            Positioned(
              top: -12,
              child: GestureDetector(
                onTap: () => navigationShell.goBranch(2),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(.30),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);

    final selected = navigationShell.currentIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => navigationShell.goBranch(index),
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}