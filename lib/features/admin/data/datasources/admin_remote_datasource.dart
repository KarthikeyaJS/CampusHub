import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_role.dart';

abstract class AdminRemoteDataSource {
  Stream<List<UserModel>> getAllUsers();

  Future<UserModel> createUserAccount({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? department,
  });

  Future<void> updateUserRole({
    required String uid,
    required UserRole role,
    String? department,
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;
  AdminRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _usersRef => firestore.collection('users');

  @override
  Stream<List<UserModel>> getAllUsers() {
    return _usersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  @override
  Future<UserModel> createUserAccount({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? department,
  }) async {
    // Creating a Firebase Auth user via the normal client SDK signs the app
    // in as that new user, which would kick the Admin out of their own
    // session. To avoid that, we spin up a throwaway secondary FirebaseApp
    // instance, do the account creation there, then tear it down — the
    // Admin's session on the primary FirebaseAuth.instance is never touched.
    FirebaseApp? tempApp;
    try {
      tempApp = await Firebase.initializeApp(
        name: 'admin_create_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      final credential = await tempAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      final user = UserModel(
        uid: uid,
        email: email,
        name: name,
        role: role,
        department: role == UserRole.departmentStaff ? department : null,
        createdAt: DateTime.now(),
      );

      // Written via the PRIMARY Firestore instance, so this happens while
      // still authenticated as the Admin — required for the security rule
      // that checks the writer's own role.
      await _usersRef.doc(uid).set(user.toJson());

      await tempAuth.signOut();
      return user;
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Failed to create account.');
    } catch (e) {
      throw ServerException('Failed to create account: ${e.toString()}');
    } finally {
      if (tempApp != null) {
        await tempApp.delete();
      }
    }
  }

  @override
  Future<void> updateUserRole({
    required String uid,
    required UserRole role,
    String? department,
  }) async {
    try {
      await _usersRef.doc(uid).update({
        'role': role.value,
        'department': role == UserRole.departmentStaff ? department : null,
      });
    } catch (e) {
      throw const ServerException('Failed to update user.');
    }
  }
}
