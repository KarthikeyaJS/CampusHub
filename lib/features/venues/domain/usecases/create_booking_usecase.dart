import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/booking_entity.dart';
import '../entities/booking_status.dart';
import '../repositories/venue_repository.dart';

/// Handles booking creation INCLUDING conflict detection.
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
    final existingResult = await repository.getBookingsForVenue(venueId);

    return existingResult.fold(
      (failure) => Future.value(
        Left(failure),
      ), // was: `Left(failure)` — type mismatch with async branch below
      (existingBookings) async {
        final candidate = BookingEntity(
          id: '',
          venueId: venueId,
          venueName: venueName,
          studentId: '',
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
      },
    );
  }
}
