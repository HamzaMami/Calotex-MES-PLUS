import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/dashboard_entities.dart';

class ProductAssemblyPanel extends StatefulWidget {
  final List<ProductEntity> products;
  const ProductAssemblyPanel({super.key, required this.products});

  @override
  State<ProductAssemblyPanel> createState() => _ProductAssemblyPanelState();
}

class _ProductAssemblyPanelState extends State<ProductAssemblyPanel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.products.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (widget.products.isEmpty) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients) return;
      final next = (_currentPage + 1) % widget.products.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Products Assembly', style: AppTheme.heading3),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.bgInput,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.divider),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.view_in_ar_rounded,
                      size: 56,
                      color: AppTheme.textMuted,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No Assembly Products',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Registered products will appear here',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Products Assembly', style: AppTheme.heading3),
        const SizedBox(height: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.products.length,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              itemBuilder: (context, index) {
                final item = widget.products[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.bgInput,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: item.productPhoto != null &&
                                item.productPhoto!.isNotEmpty
                            ? Image.network(
                                item.productPhoto!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.precision_manufacturing_rounded,
                                    size: 110,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.precision_manufacturing_rounded,
                                  size: 110,
                                  color: AppTheme.accentCyan.withValues(alpha: 0.25),
                                ),
                              ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.productCode,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    if (item.technicalMilestone != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.technicalMilestone!,
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: AppTheme.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.products.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.products.length, (i) {
              final isSelected = _currentPage == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isSelected ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppTheme.accentCyan : AppTheme.textMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
      ],
    );
  }
}
