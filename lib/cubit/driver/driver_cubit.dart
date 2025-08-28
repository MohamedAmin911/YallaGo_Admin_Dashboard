import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yallago_admin_dashboard/cubit/driver/driver_state.dart';
import 'package:yallago_admin_dashboard/repo/driver_repo.dart';

class DriversCubit extends Cubit<DriversState> {
  final DriversRepository repo;
  StreamSubscription? _sub;

  DriversCubit(this.repo) : super(DriversState.initial());

  void setTab(String tab) {
    emit(state.copyWith(tab: tab, loading: true, error: null));
    _listen();
  }

  void _listen() {
    _sub?.cancel();
    _sub = repo
        .listen(state.tab)
        .listen(
          (data) {
            emit(state.copyWith(items: data, loading: false, error: null));
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
