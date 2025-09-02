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

    // Use the simple stream first (no orderBy)
    _sub = repo.listenOnlineWithLocation().listen(_onData, onError: _onError);

    // If you want to try the ordered one after creating index:
    // _sub = repo.listenOnlineWithLocationOrdered().listen(_onData, onError: _onError);
  }

  void _onData(List<Driver> drivers) {
    // Debug: confirm streaming
    // print(drivers.map((d) => '${d.id}:${d.currentLocation?.latitude},${d.currentLocation?.longitude}').take(3).join(' | '));

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
    Iterable<Driver> base = list.where(
      (d) => d.isOnline && d.currentLocation != null,
    );
    if (query.isNotEmpty) {
      base = base.where((d) {
        final name = (d.fullName).toLowerCase();
        final id = d.id.toLowerCase();
        return name.contains(query) || id.contains(query);
      });
    }
    return base.toList();
  }

  void _onError(Object e) {
    // Surface the error so you can see if it’s "FAILED_PRECONDITION: index required" etc.
    // print('[drivers stream error] $e');
    emit(state.copyWith(loading: false, error: e.toString()));
  }

  void setQuery(String q) =>
      emit(state.copyWith(query: q, visible: _filter(state.all, q)));
  void clearQuery() => setQuery('');

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
