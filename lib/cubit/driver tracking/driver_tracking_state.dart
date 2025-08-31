import 'package:equatable/equatable.dart';
import 'package:yallago_admin_dashboard/models/driver.dart';

class DriversTrackingState extends Equatable {
  final bool loading;
  final String? error;

  final List<Driver> all; // all streamed drivers (online + active)
  final List<Driver> visible; // filtered by query
  final String query; // search text

  const DriversTrackingState({
    required this.loading,
    required this.error,
    required this.all,
    required this.visible,
    required this.query,
  });

  factory DriversTrackingState.initial() => const DriversTrackingState(
    loading: true,
    error: null,
    all: [],
    visible: [],
    query: '',
  );

  DriversTrackingState copyWith({
    bool? loading,
    String? error,
    List<Driver>? all,
    List<Driver>? visible,
    String? query,
  }) {
    return DriversTrackingState(
      loading: loading ?? this.loading,
      error: error,
      all: all ?? this.all,
      visible: visible ?? this.visible,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [loading, error, all, visible, query];
}
