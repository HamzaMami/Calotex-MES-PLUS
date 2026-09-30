import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/calotex_sidebar.dart';
import '../../../../shared/widgets/calotex_top_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/export_planning_bloc.dart';
import '../bloc/export_planning_event.dart';
import '../bloc/export_planning_state.dart';
import '../widgets/export_plan_upload_form.dart';

class ExportPlanningPage extends StatefulWidget {
  const ExportPlanningPage({super.key});

  @override
  State<ExportPlanningPage> createState() => _ExportPlanningPageState();
}

class _ExportPlanningPageState extends State<ExportPlanningPage> {
  String? _selectedWeek;

  @override
  void initState() {
    super.initState();
    context.read<ExportPlanningBloc>().add(const LoadExportPlans());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final user = auth is Authenticated ? auth.user : null;
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalotexSidebar(
            activeRoute: '/export-planning',
            userRole: user?.role ?? '',
            onNavItemTap: (route) {
              if (route == '/logout') {
                context.read<AuthBloc>().add(const LogoutRequested());
                Navigator.pushReplacementNamed(context, '/login');
              } else if (route != '/export-planning') {
                Navigator.pushReplacementNamed(context, route);
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                CalotexTopBar(
                  userName: user?.firstName ?? 'User',
                  userRole: StringUtils.formatRole(user?.role ?? ''),
                  avatar: user?.avatar,
                  onProfileTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                Expanded(child: _body()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return BlocConsumer<ExportPlanningBloc, ExportPlanningState>(
      listener: (context, state) {
        if (state is ExportPlanningSuccess) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
          context.read<ExportPlanningBloc>().add(const LoadExportPlans());
        }
      },
      builder: (context, state) {
        final plans = state is ExportPlanningLoaded
            ? state.plans
            : state is ExportPlanningSuccess
                ? state.plans
                : state is ExportPlanningLoading
                    ? state.plans
                    : <dynamic>[];
        final weeks = plans
            .map((plan) => '${plan.year}-${plan.calendarWeekKw}')
            .toSet()
            .toList()
          ..sort((a, b) {
            final aParts = a.split('-').map(int.parse).toList();
            final bParts = b.split('-').map(int.parse).toList();
            return aParts[0] != bParts[0]
                ? aParts[0].compareTo(bParts[0])
                : aParts[1].compareTo(bParts[1]);
          });
        final currentWeek = _currentWeekKey();
        final selectedWeek = weeks.contains(_selectedWeek)
            ? _selectedWeek!
            : weeks.contains(currentWeek)
                ? currentWeek
                : weeks.isNotEmpty
                    ? weeks.first
                    : null;
        final visiblePlans = selectedWeek == null
            ? <dynamic>[]
            : plans
                .where((plan) =>
                    '${plan.year}-${plan.calendarWeekKw}' == selectedWeek)
                .toList();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('Export Planning', style: AppTheme.heading1),
                const Spacer(),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: () => context.read<ExportPlanningBloc>().add(const LoadExportPlans()),
                  icon: const Icon(Icons.refresh),
                ),
              ]),
              const SizedBox(height: 6),
              Text('Manage weekly export quantities and destinations.',
                  style: AppTheme.bodySmall),
              const SizedBox(height: AppTheme.spacingMd),
              if (state is ExportPlanningError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(state.message,
                      style: const TextStyle(color: AppTheme.accentRed)),
                ),
              const ExportPlanUploadForm(),
              const SizedBox(height: AppTheme.spacingLg),
              Row(
                children: [
                  Text('Current plan', style: AppTheme.heading2),
                  const Spacer(),
                  if (weeks.isNotEmpty)
                    DropdownButton<String>(
                      value: selectedWeek,
                      dropdownColor: AppTheme.bgCard,
                      items: weeks.map((week) {
                          final parts = week.split('-');
                          final year = int.parse(parts[0]);
                          final kw = int.parse(parts[1]);
                          return DropdownMenuItem<String>(
                            value: week,
                            child: Text('KW $kw ($year)'),
                          );
                        }).toList(),
                      onChanged: (week) => setState(() {
                        _selectedWeek = week;
                      }),
                    ),
                  const SizedBox(width: 12),
                  if (visiblePlans.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: selectedWeek == null
                          ? null
                          : () {
                              final parts = selectedWeek.split('-');
                              final year = int.parse(parts[0]);
                              final week = int.parse(parts[1]);
                              _confirmClearWeek(context, year, week);
                            },
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: const Text('Clear plan'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (state is ExportPlanningLoading && visiblePlans.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (visiblePlans.isEmpty)
                const Text('No export plan rows found.',
                    style: TextStyle(color: AppTheme.textMuted))
              else
                _table(context, visiblePlans.cast()),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmClearWeek(
    BuildContext context,
    int year,
    int week,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear selected work week?'),
        content: Text(
          'Delete only KW $week ($year)? Other uploaded weeks will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Clear week'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ExportPlanningBloc>().add(
            ClearExportPlans(year: year, week: week),
          );
    }
  }

  String _currentWeekKey() {
    final now = DateTime.now();
    final thursday = now.add(Duration(days: 4 - now.weekday));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final week = 1 + thursday.difference(firstThursday).inDays ~/ 7;
    return '${thursday.year}-$week';
  }

  Widget _table(BuildContext context, List<dynamic> plans) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('KW')),
          DataColumn(label: Text('Year')),
          DataColumn(label: Text('Order number')),
          DataColumn(label: Text('Product')),
          DataColumn(label: Text('Quantity')),
          DataColumn(label: Text('Destination')),
        ],
        rows: plans.map((plan) => DataRow(cells: [
              DataCell(Text('${plan.calendarWeekKw}')),
              DataCell(Text('${plan.year}')),
              DataCell(Text(plan.orderNumber ?? '-')),
              DataCell(Text(plan.productCode)),
              DataCell(Text('${plan.quantity}')),
              DataCell(Text(plan.destination)),
            ])).toList(),
      ),
    );
  }
}
