import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/booking_entity.dart';
import '../entities/booking_status.dart';
import '../repositories/venue_repository.dart';

/// Handles booking creation INCLUDING conflict detection.
/// This is where the doc's "Conflict Detection" workflow step lives.
class CreateBookingUseCase {
  final VenueRepository repository;
  const CreateBookingUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call({
    required String venueId,
    required String venueName,
    required String purpose,
    required DateTime startDate,
    required DateTime endDate,
    required bool isFullDay,
    String? startTime,
    String? endTime,
  }) async {
    // 1. Fetch existing bookings for this venue to check conflicts.
    final existingResult = await repository.getBookingsForVenue(venueId);

    return existingResult.fold((failure) => Left(failure), (
      existingBookings,
    ) async {
      // 2. Build a temporary candidate booking to test overlap against each existing one.
      final candidate = BookingEntity(
        id: '', // not saved yet
        venueId: venueId,
        venueName: venueName,
        studentId: '', // not relevant for overlap check
        studentName: '',
        purpose: purpose,
        startDate: startDate,
        endDate: endDate,
        isFullDay: isFullDay,
        startTime: startTime,
        endTime: endTime,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final hasConflict = existingBookings.any(
        (b) => candidate.overlapsWith(b),
      );

      if (hasConflict) {
        return const Left(
          ServerFailure(
            'This venue is already booked for the selected date/time. Please choose a different slot.',
          ),
        );
      }

      // 3. No conflict — proceed to actually create the booking.
      return repository.createBooking(
        venueId: venueId,
        venueName: venueName,
        purpose: purpose,
        startDate: startDate,
        endDate: endDate,
        isFullDay: isFullDay,
        startTime: startTime,
        endTime: endTime,
      );
    });
  }
}
