import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Column definition for SiltexDataTable.
class SiltexTableColumn {
  final String label;
  final double? flex;
  final bool centerAlign;

  const SiltexTableColumn({
    required this.label,
    this.flex,
    this.centerAlign = false,
  });
}

/// Dark-themed data table with header, rows, and optional pagination.
class SiltexDataTable extends StatelessWidget {
  final List<SiltexTableColumn> columns;
  final List<List<Widget>> rows;
  final int? currentPage;
  final int? totalPages;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final bool showPagination;

  const SiltexDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.currentPage,
    this.totalPages,
    this.onPreviousPage,
    this.onNextPage,
    this.showPagination = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.divider, width: 1)),
          ),
          child: Row(
            children: columns.map((col) {
              return Expanded(
                flex: col.flex != null ? (col.flex! * 10).toInt() : 10,
                child: Text(
                  col.label,
                  textAlign:
                      col.centerAlign ? TextAlign.center : TextAlign.left,
                  style: AppTheme.label,
                ),
              );
            }).toList(),
          ),
        ),

        // Data rows
        ...rows.asMap().entries.map((entry) {
          final isLast = entry.key == rows.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: entry.key.isEven
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.02),
              border: !isLast
                  ? const Border(
                      bottom: BorderSide(color: AppTheme.divider, width: 1))
                  : null,
            ),
            child: Row(
              children: entry.value.asMap().entries.map((cellEntry) {
                final col = columns[cellEntry.key];
                return Expanded(
                  flex: col.flex != null ? (col.flex! * 10).toInt() : 10,
                  child: Align(
                    alignment: col.centerAlign
                        ? Alignment.center
                        : Alignment.centerLeft,
                    child: cellEntry.value,
                  ),
                );
              }).toList(),
            ),
          );
        }),

        // Pagination
        if (showPagination && totalPages != null && totalPages! > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Previous
                _PageButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: currentPage != null && currentPage! > 1
                      ? onPreviousPage
                      : null,
                ),
                const SizedBox(width: 6),
                // Page numbers
                ...List.generate(totalPages!, (i) {
                  final page = i + 1;
                  final isActive = page == currentPage;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _PageButton(
                      label: '$page',
                      isActive: isActive,
                      onTap: isActive ? null : () {},
                    ),
                  );
                }),
                const SizedBox(width: 6),
                // Next
                _PageButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: currentPage != null && currentPage! < totalPages!
                      ? onNextPage
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _PageButton({
    this.label,
    this.icon,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentCyan : AppTheme.bgElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: isActive ? AppTheme.accentCyan : AppTheme.divider,
          ),
        ),
        child: Center(
          child: label != null
              ? Text(
                  label!,
                  style: TextStyle(
                    color: isActive ? Colors.black : AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Icon(
                  icon,
                  color: onTap != null
                      ? AppTheme.textPrimary
                      : AppTheme.textSubtle,
                  size: 16,
                ),
        ),
      ),
    );
  }
}
