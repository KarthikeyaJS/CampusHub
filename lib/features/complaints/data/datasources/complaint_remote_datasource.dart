import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../domain/entities/complaint_category.dart';
import '../models/complaint_model.dart';
import '../../domain/entities/complaint_status.dart';

abstract class ComplaintRemoteDataSource {
  Future<ComplaintModel> createComplaint({
    required String title,
    String? description,
    required ComplaintCategory category,
    String? location,
    required List<String> imagePaths,
  });

  Stream<List<ComplaintModel>> getMyComplaints(String studentId);

  Future<ComplaintModel> getComplaintById(String id);
}

class ComplaintRemoteDataSourceImpl implements ComplaintRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final CloudinaryService cloudinaryService;

  ComplaintRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.cloudinaryService,
  });

  CollectionReference get _complaintsRef => firestore.collection('complaints');

  @override
  Future<ComplaintModel> createComplaint({
    required String title,
    String? description,
    required ComplaintCategory category,
    String? location,
    required List<String> imagePaths,
  }) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw const AuthException(
          'You must be logged in to submit a complaint.',
        );
      }

      // 1. Fetch student's name from their user profile
      final userDoc = await firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final studentName = (userDoc.data()?['name'] as String?) ?? 'Unknown';

      // 2. Upload images to Cloudinary (if any provided)
      List<String> imageUrls = [];
      if (imagePaths.isNotEmpty) {
        final files = imagePaths.map((path) => File(path)).toList();
        imageUrls = await cloudinaryService.uploadImages(files);
      }

      // 3. Build complaint document
      final now = DateTime.now();
      final docRef = _complaintsRef.doc(); // auto-generates an ID

      final complaint = ComplaintModel(
        id: docRef.id,
        studentId: currentUser.uid,
        studentName: studentName,
        title: title,
        description: description,
        category: category,
        assignedDepartment: category.assignedDepartment,
        location: location,
        imageUrls: imageUrls,
        status: ComplaintStatus.pendingReview,
        createdAt: now,
        updatedAt: now,
      );

      // 4. Save to Firestore
      await docRef.set(complaint.toJson());

      return complaint;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to submit complaint: ${e.toString()}');
    }
  }

  @override
  Stream<List<ComplaintModel>> getMyComplaints(String studentId) {
    return _complaintsRef
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ComplaintModel.fromJson(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<ComplaintModel> getComplaintById(String id) async {
    try {
      final doc = await _complaintsRef.doc(id).get();
      if (!doc.exists) {
        throw const ServerException('Complaint not found.');
      }
      return ComplaintModel.fromJson(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    } catch (e) {
      throw ServerException('Failed to load complaint.');
    }
  }
}
