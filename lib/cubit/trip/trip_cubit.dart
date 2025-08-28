import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yallago_admin_dashboard/cubit/trip/trip_state.dart';
import 'package:yallago_admin_dashboard/repo/trip_repo.dart';

class TripsCubit extends Cubit<TripsState> {
  final TripsRepository repo;
  StreamSubscription? _sub;

  TripsCubit(this.repo) : super(TripsState.initial());

  void start() {
    _listen();
  }

  void setStatus(String status) {
    emit(state.copyWith(statusFilter: status, loading: true, error: null));
    _listen();
  }

  void _listen() {
    _sub?.cancel();
    _sub = repo
        .listen(status: state.statusFilter)
        .listen(
          (data) {
            emit(state.copyWith(trips: data, loading: false, error: null));
          },
          onError: (e) {
            emit(state.copyWith(loading: false, error: e.toString()));
          },
        );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
