import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yallago_admin_dashboard/cubit/payouts/payouts_state.dart';
import 'package:yallago_admin_dashboard/models/payout_request.dart';
import 'package:yallago_admin_dashboard/repo/payouts_repo.dart';

class PayoutsCubit extends Cubit<PayoutsState> {
  final PayoutsRepository repo;
  StreamSubscription? _sub;

  PayoutsCubit(this.repo) : super(PayoutsState.initial());

  void start() {
    _sub?.cancel();
    emit(state.copyWith(loading: true, error: null));
    // Stream ALL payouts, not only pending
    _sub = repo.listenAll().listen(_onData, onError: _onError);
  }

  void _onData(List<PayoutRequest> list) {
    final visible = _filter(list, state.filter, state.query);
    emit(
      state.copyWith(all: list, visible: visible, loading: false, error: null),
    );
  }

  void _onError(Object e) {
    emit(state.copyWith(loading: false, error: e.toString()));
  }

  void setFilter(PayoutFilter filter) {
    final visible = _filter(state.all, filter, state.query);
    emit(state.copyWith(filter: filter, visible: visible));
  }

  void setQuery(String q) {
    final visible = _filter(state.all, state.filter, q);
    emit(state.copyWith(query: q, visible: visible));
  }

  List<PayoutRequest> _filter(
    List<PayoutRequest> list,
    PayoutFilter f,
    String q,
  ) {
    final query = q.trim().toLowerCase();
    Iterable<PayoutRequest> base = list;

    if (f != PayoutFilter.all) {
      base = base.where((p) => (p.status.toLowerCase()) == f.name);
    }
    if (query.isNotEmpty) {
      base = base.where((p) {
        final driver = (p.driverName).toLowerCase();
        final uid = (p.driverUid).toLowerCase();
        final acct = (p.driverStripeAccountId).toLowerCase();
        final tId = (p.transferId ?? '').toLowerCase();
        final poId = (p.payoutId ?? '').toLowerCase();
        return driver.contains(query) ||
            uid.contains(query) ||
            acct.contains(query) ||
            tId.contains(query) ||
            poId.contains(query);
      });
    }
    return base.toList();
  }

  Future<void> approve(
    PayoutRequest r,
    String adminUid, {
    bool createBankPayout = true,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await repo.approvePayout(
        req: r,
        adminUid: adminUid,
        alsoCreateBankPayout: createBankPayout,
      );
      // stream will refresh
      emit(state.copyWith(loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> reject(
    String payoutId,
    String adminUid, {
    String? reason,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await repo.rejectPayout(
        payoutId: payoutId,
        adminUid: adminUid,
        reason: reason,
      );
      // stream will refresh
      emit(state.copyWith(loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
