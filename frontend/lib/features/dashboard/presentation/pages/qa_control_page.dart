import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/network/http_client.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/calotex_sidebar.dart';
import '../../../../shared/widgets/calotex_top_bar.dart';
import '../../../../shared/widgets/calotex_gradient_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class _QaControl {
  final String firstControl;
  final String lastControl;
  final String firstSerial;
  final String lastSerial;
  _QaControl(Map<String, dynamic> json)
      : firstControl = json['first_control_id']?.toString() ?? '',
        lastControl = json['last_control_id']?.toString() ?? '',
        firstSerial = json['first_serial_number']?.toString() ?? '',
        lastSerial = json['last_serial_number']?.toString() ?? '';

  int get count {
    try {
      final regW = RegExp(r'^W(\d+)');
      final regAny = RegExp(r'(\d+)');
      final fMatch = regW.firstMatch(firstSerial) ?? regAny.firstMatch(firstSerial);
      final lMatch = lastSerial.isNotEmpty
          ? (regW.firstMatch(lastSerial) ?? regAny.firstMatch(lastSerial))
          : fMatch;
      if (fMatch != null && lMatch != null) {
        final start = int.parse(fMatch.group(1) ?? fMatch.group(0)!);
        final end = int.parse(lMatch.group(1) ?? lMatch.group(0)!);
        return (end >= start) ? (end - start + 1) : 1;
      }
    } catch (_) {}
    return 1;
  }
}

class _QaProduct {
  final String code;
  final String? order;
  final int quantity;
  final List<_QaControl> controls;
  _QaProduct(Map<String, dynamic> json)
      : code = json['product_code']?.toString() ?? '',
        order = json['order_number']?.toString(),
        quantity = (json['quantity'] as num?)?.toInt() ?? 0,
        controls = ((json['controls'] as List<dynamic>?) ?? const [])
            .map((e) => _QaControl(Map<String, dynamic>.from(e as Map)))
            .toList();

  int get totalInspected {
    int sum = 0;
    for (final c in controls) {
      sum += c.count;
    }
    return sum > quantity ? quantity : sum;
  }
}

class QaControlPage extends StatefulWidget {
  const QaControlPage({super.key});

  @override
  State<QaControlPage> createState() => _QaControlPageState();
}

class _QaControlPageState extends State<QaControlPage> {
  final _client = sl<HttpClient>().dio;
  late DateTime _weekDate;
  List<_QaProduct> _products = [];
  bool _loading = true;

  int get _week {
    final thursday = _weekDate.add(const Duration(days: 3));
    final first = DateTime(thursday.year, 1, 4);
    final thursdayOfYearStart = first.add(Duration(days: 4 - first.weekday));
    return 1 + (thursday.difference(thursdayOfYearStart).inDays / 7).floor();
  }

  @override
  void initState() {
    super.initState();
    // Initialize to the exact Monday of the actual current week
    final now = DateTime.now();
    _weekDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final response = await _client.get(
        '/qa-control',
        queryParameters: {'year': _weekDate.year, 'week': _week},
      );
      final values = response.data['data'] as List<dynamic>? ?? const [];
      if (mounted) {
        setState(() {
          _products = values
              .map((e) => _QaProduct(Map<String, dynamic>.from(e as Map)))
              .toList();
          _loading = false;
        });
      }
    } on DioException catch (error) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.response?.data['message']?.toString() ?? 'Failed to load QA products')),
        );
      }
    }
  }

  Future<void> _addControl(_QaProduct product) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _AddControlDialog(),
    );
    if (result == null) return;
    try {
      await _client.post('/qa-control', data: {
        'product_code': product.code,
        'year': _weekDate.year,
        'calendar_week_kw': _week,
        ...result,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QA Control history saved successfully', style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.accentGreen),
        );
      }
      await _load();
    } on DioException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.response?.data['message']?.toString() ?? 'Failed to save control history'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final user = auth is Authenticated ? auth.user : null;
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Row(children: [
        CalotexSidebar(
          activeRoute: '/qa-control',
          userRole: user?.role ?? '',
          onNavItemTap: (route) {
            if (route == '/logout') {
              context.read<AuthBloc>().add(const LogoutRequested());
            } else if (route != '/qa-control') {
              Navigator.pushReplacementNamed(context, route);
            }
          },
        ),
        Expanded(
          child: Column(children: [
            CalotexTopBar(
              userName: user?.firstName ?? 'User',
              userRole: user?.role ?? '',
              avatar: user?.avatar,
              onProfileTap: () => Navigator.pushNamed(context, '/profile'),
              isPresenting: false,
              onTogglePresentation: () {},
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.cardDecoration(),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Header row with overflow protection
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Quality Assurance (QA) Control', style: AppTheme.heading2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('Monitor inspection runs, serial ranges, and compliance targets', style: AppTheme.bodySmall, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.bgInput,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                onPressed: () { setState(() => _weekDate = _weekDate.subtract(const Duration(days: 7))); _load(); },
                                icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary, size: 18),
                              ),
                              const SizedBox(width: 8),
                              Text('Week $_week / ${_weekDate.year}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 12)),
                              const SizedBox(width: 8),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                onPressed: () { setState(() => _weekDate = _weekDate.add(const Duration(days: 7))); _load(); },
                                icon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _loading
                          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan))
                          : _products.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.fact_check_outlined, color: AppTheme.textMuted, size: 48),
                                      const SizedBox(height: 12),
                                      const Text('No products planned for this week', style: TextStyle(color: AppTheme.textMuted, fontSize: 15)),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: _products.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (_, index) {
                                    final product = _products[index];
                                    final inspected = product.totalInspected;
                                    final planned = product.quantity;
                                    final progress = planned > 0 ? (inspected / planned).clamp(0.0, 1.0) : 0.0;
                                    
                                    // Status Badge computation
                                    final statusLabel = inspected >= planned && planned > 0
                                        ? 'PASSED'
                                        : inspected > 0
                                            ? 'PENDING'
                                            : 'UNINSPECTED';
                                    final statusColor = statusLabel == 'PASSED'
                                        ? AppTheme.accentGreen
                                        : statusLabel == 'PENDING'
                                            ? AppTheme.accentYellow
                                            : AppTheme.textMuted;

                                    return _EnterpriseQaCard(
                                      product: product,
                                      inspected: inspected,
                                      planned: planned,
                                      progress: progress,
                                      statusLabel: statusLabel,
                                      statusColor: statusColor,
                                      onAddControl: () => _addControl(product),
                                    );
                                  },
                                ),
                    ),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _EnterpriseQaCard extends StatefulWidget {
  final _QaProduct product;
  final int inspected;
  final int planned;
  final double progress;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onAddControl;

  const _EnterpriseQaCard({
    required this.product,
    required this.inspected,
    required this.planned,
    required this.progress,
    required this.statusLabel,
    required this.statusColor,
    required this.onAddControl,
  });

  @override
  State<_EnterpriseQaCard> createState() => _EnterpriseQaCardState();
}

class _EnterpriseQaCardState extends State<_EnterpriseQaCard> {
  bool _hovered = false;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: _hovered ? AppTheme.accentCyan.withValues(alpha: 0.5) : AppTheme.divider,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: [
            if (_hovered)
              BoxShadow(
                color: AppTheme.accentCyan.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            // ── 2-Row Column Header Layout (100% Overflow-Proof) ──
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Icon + Product Code + Order Badge + Status Badge
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppTheme.bgInput,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: const Icon(Icons.precision_manufacturing_rounded, color: AppTheme.accentCyan, size: 15),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.product.code,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13.5, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                          ),
                          child: Text('Order #${widget.product.order ?? 'N/A'}', style: const TextStyle(color: AppTheme.accentBlue, fontSize: 9.5, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                            border: Border.all(color: widget.statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            widget.statusLabel,
                            style: TextStyle(color: widget.statusColor, fontSize: 9, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Bottom Row: Batch count + Progress Bar + Add Button + Chevron
                    Row(
                      children: [
                        Text('${widget.product.controls.length} batch(es) recorded', style: AppTheme.bodySmall.copyWith(fontSize: 10.5)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                '${widget.inspected} / ${widget.planned}',
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 10.5, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: widget.progress,
                                    backgroundColor: AppTheme.bgInput,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      widget.progress >= 1.0 ? AppTheme.accentGreen : AppTheme.accentCyan,
                                    ),
                                    minHeight: 4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        CalotexGradientButton(
                          label: '+ Add',
                          width: 70,
                          height: 28,
                          fontSize: 12,
                          onPressed: widget.onAddControl,
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          color: AppTheme.textMuted,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Control History List
            if (_expanded) ...[
              const Divider(height: 1, color: AppTheme.divider),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppTheme.bgInput,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppTheme.radiusMd)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Inspection History & Serial Ranges', style: TextStyle(color: AppTheme.textPrimary, fontSize: 11.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    if (widget.product.controls.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('No control runs recorded yet for this product.', style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5)),
                      )
                    else
                      ...widget.product.controls.map((control) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: AppTheme.accentGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Structured Data Pills
                              Flexible(
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    _DataTag(
                                      label: 'Control ID',
                                      value: '${control.firstControl}${control.lastControl.isNotEmpty && control.lastControl != control.firstControl ? ' - ${control.lastControl}' : ''}',
                                    ),
                                    _DataTag(
                                      label: 'Serial Range',
                                      value: '${control.firstSerial}${control.lastSerial.isNotEmpty && control.lastSerial != control.firstSerial ? ' to ${control.lastSerial}' : ''}',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                                  border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3)),
                                ),
                                child: const Text(
                                  'PASSED',
                                  style: TextStyle(
                                    color: AppTheme.accentGreen,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                tooltip: 'Copy Serial Range',
                                icon: const Icon(Icons.copy_rounded, size: 14, color: AppTheme.textMuted),
                                onPressed: () {
                                  final text = '${control.firstSerial} to ${control.lastSerial.isNotEmpty ? control.lastSerial : control.firstSerial}';
                                  Clipboard.setData(ClipboardData(text: text));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Copied to clipboard!', style: TextStyle(color: Colors.white)), duration: Duration(seconds: 1)),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DataTag extends StatelessWidget {
  final String label;
  final String value;

  const _DataTag({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.bgInput,
        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(color: AppTheme.textMuted, fontSize: 9.5, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 10.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _AddControlDialog extends StatefulWidget {
  const _AddControlDialog();
  @override
  State<_AddControlDialog> createState() => _AddControlDialogState();
}

class _AddControlDialogState extends State<_AddControlDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstControl = TextEditingController();
  final _lastControl = TextEditingController();
  final _firstSerial = TextEditingController();
  final _lastSerial = TextEditingController();

  @override
  void dispose() {
    _firstControl.dispose();
    _lastControl.dispose();
    _firstSerial.dispose();
    _lastSerial.dispose();
    super.dispose();
  }

  String? _control(String? value) => value == null || value.isEmpty || RegExp(r'^\d{5}$').hasMatch(value) ? null : 'Use exactly 5 digits';
  String? _serial(String? value) => value == null || value.isEmpty || RegExp(r'^W\d{9}$').hasMatch(value) ? null : 'Use W followed by 9 digits (e.g. W000000001)';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.bgCard,
      title: const Text('Add QA Control History', style: TextStyle(color: AppTheme.textPrimary)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                controller: _firstControl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: AppTheme.inputDecoration(hint: 'First control ID (5 digits)'),
                validator: _control,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastControl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: AppTheme.inputDecoration(hint: 'Last control ID (optional)'),
                validator: _control,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _firstSerial,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: AppTheme.inputDecoration(hint: 'First serial number (W followed by 9 digits)'),
                validator: _serial,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastSerial,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: AppTheme.inputDecoration(hint: 'Last serial number (optional)'),
                validator: _serial,
              ),
            ]),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 6),
            CalotexGradientButton(
              label: 'Save',
              width: 95,
              height: 34,
              fontSize: 13,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context, {
                    'first_control_id': _firstControl.text.trim(),
                    'last_control_id': _lastControl.text.trim(),
                    'first_serial_number': _firstSerial.text.trim(),
                    'last_serial_number': _lastSerial.text.trim(),
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
