import 'dart:async';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/bus_location.dart';
import '../../domain/entities/trip_detail.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../datasources/tracking_remote_data_source.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  TrackingRepositoryImpl({
    TrackingRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
            remoteDataSource ?? TrackingRemoteDataSource();

  final TrackingRemoteDataSource _remoteDataSource;

  @override
  Stream<BusLocation> listenBusLocation({
    required int tripId,
    String? token,
  }) {
    // Los modelos extienden las entidades, así que se pueden usar directamente
    return _remoteDataSource.listenBusLocationStream(
      tripId: tripId,
      token: token,
    );
  }

  @override
  Future<TripDetail> getTripRoute({
    required int tripId,
    String? token,
  }) async {
    try {
      return await _remoteDataSource.fetchTripRoute(
        tripId: tripId,
        token: token,
      );
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unknown(stackTrace);
    }
  }
}

