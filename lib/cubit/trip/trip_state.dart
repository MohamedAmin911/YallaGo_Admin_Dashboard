import 'package:equatable/equatable.dart';
import 'package:yallago_admin_dashboard/models/trip.dart';

class TripsState extends Equatable {
  final List<Trip> trips;
  final String statusFilter;
  final bool loading;
  final String? error;

  const TripsState({
    required this.trips,
    required this.statusFilter,
    required this.loading,
    this.error,
  });

  factory TripsState.initial() =>
      const TripsState(trips: [], statusFilter: 'all', loading: true);

  TripsState copyWith({
    List<Trip>? trips,
    String? statusFilter,
    bool? loading,
    String? error,
  }) {
    return TripsState(
      trips: trips ?? this.trips,
      statusFilter: statusFilter ?? this.statusFilter,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [trips, statusFilter, loading, error];
}
