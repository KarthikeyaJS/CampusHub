import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/complaint_entity.dart';
import '../entities/complaint_category.dart';

abstract class ComplaintRepository {
  /// Creates a new complaint. imagePaths are local file paths to upload
  /// to Cloudinary first; resulting URLs get saved with the complaint.
  Future<Either<Failure, ComplaintEntity>> createComplaint({
    required String title,
    String? description,
    required ComplaintCategory category,
    String? location,
    required List<String> imagePaths,
  });

  /// Real-time stream of complaints submitted by the current student.
  Stream<List<ComplaintEntity>> getMyComplaints(String studentId);

  /// Fetches a single complaint by id (for detail screen).
  Future<Either<Failure, ComplaintEntity>> getComplaintById(String id);
}
