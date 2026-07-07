import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/venue_model.dart';

abstract class VenueRemoteDataSource {
  Stream<List<VenueModel>> getVenues();
  Future<VenueModel> getVenueById(String id);
}

class VenueRemoteDataSourceImpl implements VenueRemoteDataSource {
  final FirebaseFirestore firestore;
  VenueRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _venuesRef => firestore.collection('venues');

  @override
  Stream<List<VenueModel>> getVenues() {
    return _venuesRef
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => VenueModel.fromJson(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<VenueModel> getVenueById(String id) async {
    try {
      final doc = await _venuesRef.doc(id).get();
      if (!doc.exists) {
        throw const ServerException('Venue not found.');
      }
      return VenueModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw const ServerException('Failed to load venue.');
    }
  }
}
