import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yallago_admin_dashboard/cubit/customer/customer_state.dart';
import 'package:yallago_admin_dashboard/repo/customer_repo.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomersRepository repo;
  StreamSubscription? _sub;

  CustomerCubit(this.repo) : super(CustomerState.initial());

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
