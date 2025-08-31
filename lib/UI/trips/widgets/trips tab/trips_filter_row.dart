import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/pill_button.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/surface_card.dart';
import 'package:yallago_admin_dashboard/cubit/trip/trip_cubit.dart';
import 'package:yallago_admin_dashboard/cubit/trip/trip_state.dart';

class TripsFilterRow extends StatefulWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchSubmitted;

  const TripsFilterRow({
    super.key,
    required this.searchController,
    required this.onSearchSubmitted,
  });

  @override
  State<TripsFilterRow> createState() => _TripsFilterRowState();
}

class _TripsFilterRowState extends State<TripsFilterRow> {
  DateTimeRange? _range;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                PillButton(
                  label:
                      _range == null
                          ? 'Select Date Range'
                          : '${DateFormat('yyyy-MM-dd').format(_range!.start)} → ${DateFormat('yyyy-MM-dd').format(_range!.end)}',
                  onPressed: () async {
                    final today = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(today.year - 1),
                      lastDate: DateTime(today.year + 1),
                      initialDateRange:
                          _range ??
                          DateTimeRange(
                            start: DateTime(today.year, today.month, today.day),
                            end: DateTime(today.year, today.month, today.day),
                          ),
                    );
                    if (picked != null) {
                      setState(() => _range = picked);
                    }
                  },
                ),
                const SizedBox(width: 12),
                Shortcuts(
                  shortcuts: {
                    LogicalKeySet(LogicalKeyboardKey.space):
                        const DoNothingAndStopPropagationIntent(),
                  },
                  child: BlocBuilder<TripsCubit, TripsState>(
                    buildWhen: (p, c) => p.statusFilter != c.statusFilter,
                    builder: (context, state) {
                      return Container(
                        height: 34,
                        decoration: BoxDecoration(
                          border: Border.all(color: AdminColors.lightGray),
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.statusFilter,
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('Status'),
                              ),
                              DropdownMenuItem(
                                value: 'searching',
                                child: Text('Searching'),
                              ),
                              DropdownMenuItem(
                                value: 'in_progress',
                                child: Text('Ongoing'),
                              ),
                              DropdownMenuItem(
                                value: 'completed',
                                child: Text('Completed'),
                              ),
                              DropdownMenuItem(
                                value: 'canceled',
                                child: Text('Canceled'),
                              ),
                              DropdownMenuItem(
                                value: 'paid',
                                child: Text('Paid'),
                              ),
                            ],
                            onChanged:
                                (v) =>
                                    v != null
                                        ? context.read<TripsCubit>().setStatus(
                                          v,
                                        )
                                        : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 360,
          child: SurfaceCard(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: widget.searchController,
                decoration: const InputDecoration(
                  hintText: 'Search by Trip ID, Rider, Driver...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onSubmitted: widget.onSearchSubmitted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
