import 'package:equatable/equatable.dart';
import 'package:yallago_admin_dashboard/models/payout_request.dart';

enum PayoutFilter { all, pending, approved, paid, rejected, failed }

extension PayoutFilterX on PayoutFilter {
  String get label {
    switch (this) {
      case PayoutFilter.all:
        return 'All';
      case PayoutFilter.pending:
        return 'Pending';
      case PayoutFilter.approved:
        return 'Approved';
      case PayoutFilter.paid:
        return 'Paid';
      case PayoutFilter.rejected:
        return 'Rejected';
      case PayoutFilter.failed:
        return 'Failed';
    }
  }
}

class PayoutsState extends Equatable {
  final bool loading;
  final String? error;

  final List<PayoutRequest> all;
  final List<PayoutRequest> visible;
  final PayoutFilter filter;
  final String query;

  const PayoutsState({
    required this.loading,
    required this.error,
    required this.all,
    required this.visible,
    required this.filter,
    required this.query,
  });

  factory PayoutsState.initial() => const PayoutsState(
    loading: true,
    error: null,
    all: [],
    visible: [],
    filter: PayoutFilter.all,
    query: '',
  );

  PayoutsState copyWith({
    bool? loading,
    String? error,
    List<PayoutRequest>? all,
    List<PayoutRequest>? visible,
    PayoutFilter? filter,
    String? query,
  }) {
    return PayoutsState(
      loading: loading ?? this.loading,
      error: error,
      all: all ?? this.all,
      visible: visible ?? this.visible,
      filter: filter ?? this.filter,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [loading, error, all, visible, filter, query];
}
