import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yallago_admin_dashboard/cubit/driver%20tracking/driver_tracking_state.dart';
import 'package:yallago_admin_dashboard/models/driver.dart';
import 'package:yallago_admin_dashboard/repo/driver_tracking_repo.dart';

class DriversTrackingCubit extends Cubit<DriversTrackingState> {
  final DriversTrackingRepository repo;
  StreamSubscription? _sub;

  DriversTrackingCubit(this.repo) : super(DriversTrackingState.initial());

  void start() {
    _sub?.cancel();
    emit(state.copyWith(loading: true, error: null));

    // Use one of the repo calls:
    // _sub = repo.listenRecentLocations(window: const Duration(minutes: 10)).listen(_onData, onError: _onError);
    _sub = repo.listenAllWithLocation().listen(_onData, onError: _onError);
  }

  void _onData(List<Driver> drivers) {
    final filtered = _filter(drivers, state.query);
    emit(
      state.copyWith(
        all: drivers,
        visible: filtered,
        loading: false,
        error: null,
      ),
    );
  }

  List<Driver> _filter(List<Driver> list, String q) {
    final query = q.trim().toLowerCase();

    // Base: only online + has location
    Iterable<Driver> base = list.where(
      (d) => d.isOnline && d.currentLocation != null,
    );

    // Apply search if present (by id or name)
    if (query.isNotEmpty) {
      base = base.where((d) {
        final name = (d.fullName).toLowerCase();
        final id = d.id.toLowerCase();
        return name.contains(query) || id.contains(query);
      });
    }

    return base.toList();
  }

  void _onError(Object e) =>
      emit(state.copyWith(loading: false, error: e.toString()));

  void setQuery(String q) {
    final filtered = _filter(state.all, q);
    emit(state.copyWith(query: q, visible: filtered));
  }

  void clearQuery() => setQuery('');

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
