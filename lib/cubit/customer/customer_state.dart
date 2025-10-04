import 'package:equatable/equatable.dart';
import 'package:yallago_admin_dashboard/models/customer.dart';

class CustomerState extends Equatable {
  final String tab;
  final List<Customer> items;
  final bool loading;
  final String? error;

  const CustomerState({
    required this.tab,
    required this.items,
    required this.loading,
    this.error,
  });

  factory CustomerState.initial() =>
      const CustomerState(tab: 'all', items: [], loading: true);

  CustomerState copyWith({
    String? tab,
    List<Customer>? items,
    bool? loading,
    String? error,
  }) {
    return CustomerState(
      tab: tab ?? this.tab,
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [tab, items, loading, error];
}
