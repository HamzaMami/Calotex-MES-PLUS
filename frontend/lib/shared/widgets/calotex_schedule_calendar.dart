import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum CalendarEventType { technical, quality, export_ }

class CalendarEvent {
  final DateTime date;
  final CalendarEventType type;
  final String title;

  const CalendarEvent({
    required this.date,
    required this.type,
    required this.title,
  });
}

/// Interactive monthly calendar widget styled with the CALOTEX dark theme.
/// Shows fixed recurring event bars for Technical, Quality Control, and Export events.
class CalotexScheduleCalendar extends StatefulWidget {
  final VoidCallback? onChangeSchedule;

  const CalotexScheduleCalendar({
    super.key,
    this.onChangeSchedule,
  });

  @override
  State<CalotexScheduleCalendar> createState() => _CalotexScheduleCalendarState();
}

class _CalotexScheduleCalendarState extends State<CalotexScheduleCalendar> {
  late DateTime _displayedMonth;
  final DateTime _today = DateTime.now();
  static const _monthShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(_today.year, _today.month, 1);
  }

  Color _eventColor(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.technical:
        return AppTheme.accentOrange;
      case CalendarEventType.quality:
        return AppTheme.accentCyan;
      case CalendarEventType.export_:
        return AppTheme.accentGreen;
    }
  }

  /// Generates recurring events for the displayed month based on day-of-week rules.
  List<CalendarEvent> _generateEvents(int year, int month) {
    final List<CalendarEvent> events = [];
    final daysInMonth = DateTime(year, month + 1, 0).day;
    int mondayCount = 0;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final weekday = date.weekday;

      // Technical team meeting: 1st, 3rd, and 4th Mondays
      if (weekday == DateTime.monday) {
        mondayCount++;
        if (mondayCount == 1 || mondayCount == 3 || mondayCount == 4) {
          events.add(CalendarEvent(
            date: date,
            type: CalendarEventType.technical,
            title: 'Technical team meeting',
          ));
        }
      }

      // Quality Control: Every Thursday and Friday
      if (weekday == DateTime.thursday || weekday == DateTime.friday) {
        events.add(CalendarEvent(
          date: date,
          type: CalendarEventType.quality,
          title: 'Quality Control',
        ));
      }

      // Export: Every Saturday
      if (weekday == DateTime.saturday) {
        events.add(CalendarEvent(
          date: date,
          type: CalendarEventType.export_,
          title: 'Export',
        ));
      }
    }
    return events;
  }

  void _goToToday() {
    setState(() {
      _displayedMonth = DateTime(_today.year, _today.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final events = _generateEvents(year, month);

    // Calendar grid computation
    final firstWeekday = DateTime(year, month, 1).weekday; // 1=Mon…7=Sun
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final daysInPrevMonth = DateTime(year, month, 0).day;
    final leadingCells = firstWeekday - 1;
    final totalCells = leadingCells + daysInMonth;
    final trailingCells = (7 - (totalCells % 7)) % 7;

    // Build flat list of day cells
    final cells = <_DayCell>[];

    // Previous month trailing days (greyed out)
    for (int i = leadingCells - 1; i >= 0; i--) {
      final d = daysInPrevMonth - i;
      cells.add(_DayCell(
        day: d,
        isCurrentMonth: false,
        date: DateTime(year, month - 1, d),
        events: const [],
      ));
    }

    // Current month
    final eventsMap = <int, List<CalendarEvent>>{};
    for (final e in events) {
      eventsMap.putIfAbsent(e.date.day, () => []).add(e);
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      cells.add(_DayCell(
        day: day,
        isCurrentMonth: true,
        date: date,
        isToday: date.year == _today.year &&
            date.month == _today.month &&
            date.day == _today.day,
        events: eventsMap[day] ?? const [],
      ));
    }

    // Next month leading days (greyed out)
    for (int i = 1; i <= trailingCells; i++) {
      cells.add(_DayCell(
        day: i,
        isCurrentMonth: false,
        date: DateTime(year, month + 1, i),
        events: const [],
      ));
    }

    // Group into weeks
    final weeks = <List<_DayCell>>[];
    for (int i = 0; i < cells.length; i += 7) {
      weeks.add(cells.sublist(i, i + 7));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Controls row ──────────────────────────────────────────
        Row(
          children: [
            _CalendarChip(label: 'Today', onTap: _goToToday),
            const SizedBox(width: 8),
            _MonthYearDropdown(
              value: _monthShort[month - 1],
              items: _monthShort,
              onChanged: (val) {
                final idx = _monthShort.indexOf(val);
                if (idx >= 0) {
                  setState(() => _displayedMonth = DateTime(year, idx + 1, 1));
                }
              },
            ),
            const SizedBox(width: 8),
            _MonthYearDropdown(
              value: '$year',
              items: [for (int y = 2020; y <= 2035; y++) '$y'],
              onChanged: (val) {
                setState(
                    () => _displayedMonth = DateTime(int.parse(val), month, 1));
              },
            ),
            const Spacer(),
            GestureDetector(
              onTap: widget.onChangeSchedule,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.bgElevated,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    const Text(
                      'Change Schedule',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Legend ────────────────────────────────────────────────
        Row(
          children: [
            Text('Legend:', style: AppTheme.bodySmall),
            const SizedBox(width: 10),
            _LegendItem(
                color: AppTheme.accentOrange, label: 'Technical team meeting'),
            const SizedBox(width: 14),
            _LegendItem(color: AppTheme.accentCyan, label: 'Quality Control'),
            const SizedBox(width: 14),
            _LegendItem(color: AppTheme.accentGreen, label: 'Export'),
          ],
        ),
        const SizedBox(height: 12),

        // ── Calendar grid ─────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.divider, width: 1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Weekday header
              Container(
                decoration: const BoxDecoration(
                  color: AppTheme.bgElevated,
                  border: Border(bottom: BorderSide(color: AppTheme.divider)),
                ),
                child: Row(
                  children: _weekDays.map((day) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            day,
                            style: AppTheme.label.copyWith(fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Week rows
              ...weeks.asMap().entries.map((entry) {
                final isLastWeek = entry.key == weeks.length - 1;
                return Container(
                  decoration: BoxDecoration(
                    border: !isLastWeek
                        ? const Border(
                            bottom: BorderSide(color: AppTheme.divider))
                        : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: entry.value.asMap().entries.map((cellEntry) {
                      final isLastCol = cellEntry.key == 6;
                      return Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: !isLastCol
                                ? const Border(
                                    right: BorderSide(color: AppTheme.divider))
                                : null,
                          ),
                          child: _buildDayCell(cellEntry.value),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(_DayCell cell) {
    final isToday = cell.isToday;

    return SizedBox(
      height: 76,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date number
            Container(
              width: 26,
              height: 26,
              decoration: isToday
                  ? const BoxDecoration(
                      color: AppTheme.accentCyan,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Center(
                child: Text(
                  '${cell.day}',
                  style: TextStyle(
                    color: isToday
                        ? Colors.black
                        : cell.isCurrentMonth
                            ? AppTheme.textPrimary
                            : AppTheme.textSubtle,
                    fontSize: 13,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Event bars (up to 2)
            ...cell.events.take(2).map(
                  (e) => Container(
                    width: double.infinity,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 3),
                    decoration: BoxDecoration(
                      color: _eventColor(e.type),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

// ── Supporting private classes ─────────────────────────────────────────────

class _DayCell {
  final int day;
  final bool isCurrentMonth;
  final DateTime date;
  final bool isToday;
  final List<CalendarEvent> events;

  const _DayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.date,
    this.isToday = false,
    required this.events,
  });
}

class _CalendarChip extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;

  const _CalendarChip({required this.label, this.onTap});

  @override
  State<_CalendarChip> createState() => _CalendarChipState();
}

class _CalendarChipState extends State<_CalendarChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _hovered
                ? AppTheme.accentCyan.withValues(alpha: 0.15)
                : AppTheme.accentCyan.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: _hovered
                  ? AppTheme.accentCyan.withValues(alpha: 0.5)
                  : AppTheme.accentCyan.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: AppTheme.accentCyan,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthYearDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _MonthYearDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          dropdownColor: AppTheme.bgElevated,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.textMuted,
            size: 16,
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTheme.bodySmall.copyWith(fontSize: 11)),
      ],
    );
  }
}
