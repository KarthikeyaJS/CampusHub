import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/venue_entity.dart';
import '../entities/booking_entity.dart';

abstract class VenueRepository {
  /// Fetches all active venues (Admin-managed, read-only from mobile app).
  Stream<List<VenueEntity>> getVenues();

  Future<Either<Failure, VenueEntity>> getVenueById(String id);

  /// Fetches all non-rejected/cancelled bookings for a venue —
  /// used to check for conflicts before submitting a new request.
  Future<Either<Failure, List<BookingEntity>>> getBookingsForVenue(
    String venueId,
  );

  Future<Either<Failure, BookingEntity>> createBooking({
    required String venueId,
    required String venueName,
    required String purpose,
    required DateTime startDate,
    required DateTime endDate,
    required bool isFullDay,
    String? startTime,
    String? endTime,
  });

  /// Real-time stream of the current student's own bookings.
  Stream<List<BookingEntity>> getMyBookings(String studentId);
}
