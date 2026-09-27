import 'dart:async';

import 'package:flutter/material.dart';
import 'package:calotex_app/features/dashboard/domain/entities/dashboard_entities.dart';
import '../../../../shared/theme/app_theme.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients) return;
      final items = widget.products.isEmpty ? 1 : widget.products.length;
      final next = (_currentPage + 1) % items;
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
    final items = widget.products.isEmpty
        ? [
            ProductEntity(
              id: 0,
              name: 'test',
              finalApproval: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          ]
        : widget.products;

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
              itemCount: items.length,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.precision_manufacturing_outlined,
                          size: 140,
                          color: AppTheme.accentRed.withValues(alpha: 0.7),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (i) {
            final isSelected = _currentPage == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isSelected ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accentBlue : AppTheme.textMuted,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
