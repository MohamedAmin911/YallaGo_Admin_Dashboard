import 'package:equatable/equatable.dart';
import '../../models/driver.dart';

class DriversState extends Equatable {
  final String tab;
  final List<Driver> items;
  final bool loading;
  final String? error;

  const DriversState({
    required this.tab,
    required this.items,
    required this.loading,
    this.error,
  });

  factory DriversState.initial() =>
      const DriversState(tab: 'pending_approval', items: [], loading: true);

  DriversState copyWith({
    String? tab,
    List<Driver>? items,
    bool? loading,
    String? error,
  }) {
    return DriversState(
      tab: tab ?? this.tab,
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [tab, items, loading, error];
}
