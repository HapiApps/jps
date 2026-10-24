import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../source/constant/colors_constant.dart';

/// ---------------------------------------------------------------------------
/// Result that the dropdown returns every time the user picks a filter.
/// ---------------------------------------------------------------------------
class DateFilterResult {
  /// "Today", "Yesterday", "Last 7 Days", "This Month", "Custom" ...
  final String type;
  final DateTime start;
  final DateTime end;
  final String dateFormat;

  const DateFilterResult({
    required this.type,
    required this.start,
    required this.end,
    this.dateFormat = 'dd-MM-yyyy',
  });

  /// Formatted strings (default dd-MM-yyyy, same as your providers use)
  String get startDate => DateFormat(dateFormat).format(start);
  String get endDate => DateFormat(dateFormat).format(end);

  bool get isSingleDay =>
      start.year == end.year && start.month == end.month && start.day == end.day;
}

/// ---------------------------------------------------------------------------
/// DateFilterDropdown
///
/// Pill style dropdown: Today / Yesterday / Last 7 Days / This Month / Custom.
/// "Custom" opens a dialog with From Date + To Date.
///
/// Usage:
/// DateFilterDropdown(
///   onChanged: (r) {
///     print("${r.type} ${r.startDate} ${r.endDate}");
///   },
/// )
/// ---------------------------------------------------------------------------
class DateFilterDropdown extends StatefulWidget {
  /// Called whenever a filter is selected (and Apply pressed for Custom).
  final ValueChanged<DateFilterResult> onChanged;

  /// Dropdown values. Supported: Today, Yesterday, Last 7 Days, Last 30 Days,
  /// This Week, This Month, Last 3 months, Custom
  final List<String> types;

  /// Must be one of [types]. Falls back to the first item if not found.
  final String initialType;

  /// Only used when initialType == "Custom"
  final DateTime? initialStart;
  final DateTime? initialEnd;

  /// Output format of startDate / endDate
  final String dateFormat;

  final Color primaryColor;

  /// Show "Thursday, June 11 2026" text on the right side (like the design)
  final bool showDateText;

  /// Calendar limits for Custom
  final DateTime? firstDate;
  final DateTime? lastDate;

  /// Call onChanged once with the initial value (inside first frame)
  final bool emitInitial;

  const DateFilterDropdown({
    super.key,
    required this.onChanged,
    this.types = const [
      "Today",
      "Yesterday",
      "Last 7 Days",
      "This Month",
      "Custom",
    ],
    this.initialType = "Today",
    this.initialStart,
    this.initialEnd,
    this.dateFormat = 'dd-MM-yyyy',
    this.primaryColor = const Color(0xff0B5FB5),
    this.showDateText = true,
    this.firstDate,
    this.lastDate,
    this.emitInitial = false,
  });

  /// Date range for a given type (can also be used outside the widget)
  static DateTimeRange rangeFor(String type) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (type) {
      case "Yesterday":
        final y = today.subtract(const Duration(days: 1));
        return DateTimeRange(start: y, end: y);
      case "Last 7 Days":
        return DateTimeRange(
            start: today.subtract(const Duration(days: 6)), end: today);
      case "Last 30 Days":
        return DateTimeRange(
            start: today.subtract(const Duration(days: 29)), end: today);
      case "This Week":
        final monday = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(
            start: monday, end: monday.add(const Duration(days: 6)));
      case "This Month":
        return DateTimeRange(
            start: DateTime(today.year, today.month, 1), end: today);
      case "Last 3 months":
        return DateTimeRange(
            start: DateTime(today.year, today.month - 3, today.day),
            end: today);
      case "Today":
      default:
        return DateTimeRange(start: today, end: today);
    }
  }

  @override
  State<DateFilterDropdown> createState() => _DateFilterDropdownState();
}

class _DateFilterDropdownState extends State<DateFilterDropdown> {
  late String _type;
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();

    _type = widget.types.contains(widget.initialType)
        ? widget.initialType
        : widget.types.first;

    if (_type == "Custom" &&
        widget.initialStart != null &&
        widget.initialEnd != null) {
      _start = _dateOnly(widget.initialStart!);
      _end = _dateOnly(widget.initialEnd!);
    } else {
      final r = DateFilterDropdown.rangeFor(_type);
      _start = r.start;
      _end = r.end;
    }

    if (widget.emitInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _emit();
      });
    }
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void _emit() {
    widget.onChanged(DateFilterResult(
      type: _type,
      start: _start,
      end: _end,
      dateFormat: widget.dateFormat,
    ));
  }

  Future<void> _onSelect(String value) async {
    if (value == "Custom") {
      final range = await _showCustomDialog();
      if (range == null) return; // cancelled -> keep previous filter
      setState(() {
        _type = "Custom";
        _start = range.start;
        _end = range.end;
      });
      _emit();
      return;
    }

    final r = DateFilterDropdown.rangeFor(value);
    setState(() {
      _type = value;
      _start = r.start;
      _end = r.end;
    });
    _emit();
  }

  /// -------------------------------------------------------------------------
  /// CUSTOM: From Date + To Date dialog
  /// -------------------------------------------------------------------------
  Future<DateTimeRange?> _showCustomDialog() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final first = widget.firstDate != null
        ? _dateOnly(widget.firstDate!)
        : DateTime(2020);
    final last =
    widget.lastDate != null ? _dateOnly(widget.lastDate!) : today;

    DateTime from = _type == "Custom" ? _start : today;
    DateTime to = _type == "Custom" ? _end : today;

    // keep inside limits
    if (from.isAfter(last)) from = last;
    if (to.isAfter(last)) to = last;
    if (from.isBefore(first)) from = first;

    final fmt = DateFormat(widget.dateFormat);

    return showDialog<DateTimeRange>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            final invalid = to.isBefore(from);

            Future<void> pick(bool isFrom) async {
              final initial = isFrom ? from : to;
              final picked = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: first,
                lastDate: last,
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: widget.primaryColor,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked == null) return;
              setLocal(() {
                if (isFrom) {
                  from = _dateOnly(picked);
                  // from > to aana, to-va from-ku maathidu
                  if (to.isBefore(from)) to = from;
                } else {
                  to = _dateOnly(picked);
                }
              });
            }

            Widget dateBox(String label, DateTime value, bool isFrom) {
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff7E7E7E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => pick(isFrom),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                fmt.format(value),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(Icons.calendar_today_outlined,
                                size: 16, color: widget.primaryColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              backgroundColor: Colors.white,
              title: const Text(
                "Custom Date",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        dateBox("From Date", from, true),
                        const SizedBox(width: 12),
                        dateBox("To Date", to, false),
                      ],
                    ),
                    if (invalid) ...[
                      const SizedBox(height: 10),
                      const Text(
                        "To Date must be after From Date",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: invalid
                      ? null
                      : () => Navigator.of(dialogContext)
                      .pop(DateTimeRange(start: from, end: to)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Apply",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _dateText() {
    final same = _start.year == _end.year &&
        _start.month == _end.month &&
        _start.day == _end.day;
    if (same) {
      return DateFormat('EEEE, MMMM d yyyy').format(_start);
    }
    final f = DateFormat('dd MMM yyyy');
    return "${f.format(_start)} - ${f.format(_end)}";
  }

  @override
  Widget build(BuildContext context) {
    final pill = PopupMenuButton<String>(
      onSelected: _onSelect,
      offset: const Offset(0, 56),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => widget.types.map((t) {
        final selected = t == _type;
        return PopupMenuItem<String>(
          value: t,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  t,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: selected ? widget.primaryColor : Colors.black,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check, size: 18, color: widget.primaryColor),
            ],
          ),
        );
      }).toList(),
      child: Container(
        height: 40,
        padding: const EdgeInsets.fromLTRB(8, 0, 14, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: widget.primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: SvgPicture.asset("assets/images/calender_icon.svg"),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _type,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorsConst.appBlack,
              ),
            ),
            const SizedBox(width: 20),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: ColorsConst.textGrey),
          ],
        ),
      ),
    );

    if (!widget.showDateText) return pill;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        pill,
        const SizedBox(width: 10),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              _dateText(),
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xff14151F),
              ),
            ),
          ),
        ),
      ],
    );
  }
}