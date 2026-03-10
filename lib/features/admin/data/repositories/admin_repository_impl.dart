import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../domain/repositories/admin_repository.dart';

/// Implementation of AdminRepository
class AdminRepositoryImpl implements AdminRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  AdminRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(FirestoreCollections.users);

  CollectionReference<Map<String, dynamic>> get _suppliersCollection =>
      _firestore.collection(FirestoreCollections.suppliers);

  @override
  Future<Either<Failure, UserModel>> createOrganizer({
    required String name,
    required String phone,
    String? email,
    required String createdByAdminId,
  }) async {
    try {
      // Check if phone already exists
      final existingUser = await _usersCollection
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        return Left(FirestoreFailure.alreadyExists('User with this phone'));
      }

      // Generate a temporary UID (will be replaced when user first logs in)
      final tempUid = _uuid.v4();

      final newOrganizer = UserModel(
        id: tempUid,
        name: name,
        phone: phone,
        email: email,
        role: UserRole.organizer,
        createdBy: createdByAdminId,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _usersCollection.doc(tempUid).set(newOrganizer.toFirestore());

      return Right(newOrganizer);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, ({UserModel user, SupplierModel supplier})>>
      createSupplier({
    required String name,
    required String phone,
    required String supplierName,
    required String supplierDescription,
    required List<String> services,
    String? category,
    String? email,
    required String createdByAdminId,
  }) async {
    try {
      // Check if phone already exists
      final existingUser = await _usersCollection
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        return Left(FirestoreFailure.alreadyExists('User with this phone'));
      }

      // Generate IDs
      final userUid = _uuid.v4();
      final supplierId = _uuid.v4();

      // Create user document
      final newUser = UserModel(
        id: userUid,
        name: name,
        phone: phone,
        email: email,
        role: UserRole.supplier,
        createdBy: createdByAdminId,
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Create supplier document
      final newSupplier = SupplierModel(
        id: supplierId,
        name: supplierName,
        description: supplierDescription,
        services: services,
        category: category,
        ownerId: userUid,
        ownerName: name,
        contactPhone: phone,
        contactEmail: email,
        createdByAdmin: createdByAdminId,
        isActive: true,
        createdAt: DateTime.now(),
      );

      // Use batch write for atomicity
      final batch = _firestore.batch();

      batch.set(_usersCollection.doc(userUid), newUser.toFirestore());
      batch.set(_suppliersCollection.doc(supplierId), newSupplier.toFirestore());

      await batch.commit();

      return Right((user: newUser, supplier: newSupplier));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateUserRole({
    required String userId,
    required UserRole newRole,
  }) async {
    try {
      await _usersCollection.doc(userId).update({
        'role': newRole.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedDoc = await _usersCollection.doc(userId).get();
      return Right(UserModel.fromFirestore(updatedDoc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deactivateUser(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> activateUser(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getUsers({
    UserRole? roleFilter,
    int limit = 20,
    String? lastUserId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _usersCollection.orderBy('createdAt', descending: true);

      if (roleFilter != null) {
        query = query.where('role', isEqualTo: roleFilter.value);
      }

      if (lastUserId != null) {
        final lastDoc = await _usersCollection.doc(lastUserId).get();
        query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final users = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();

      return Right(users);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getUsersByRole(UserRole role) async {
    try {
      final snapshot = await _usersCollection
          .where('role', isEqualTo: role.value)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      final users = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      return Right(users);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> searchUsers(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // For production, consider using Algolia or ElasticSearch
      final snapshot = await _usersCollection
          .orderBy('name')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(20)
          .get();

      final users = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      return Right(users);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, UserStats>> getUserStats() async {
    try {
      final allUsers = await _usersCollection.get();

      int totalAdmins = 0;
      int totalOrganizers = 0;
      int totalSuppliers = 0;
      int totalExhibitors = 0;
      int activeUsers = 0;
      int inactiveUsers = 0;

      for (final doc in allUsers.docs) {
        final data = doc.data();
        final role = UserRole.fromString(data['role'] ?? 'exhibitor');
        final isActive = data['isActive'] ?? true;

        switch (role) {
          case UserRole.admin:
            totalAdmins++;
            break;
          case UserRole.organizer:
            totalOrganizers++;
            break;
          case UserRole.supplier:
            totalSuppliers++;
            break;
          case UserRole.exhibitor:
            totalExhibitors++;
            break;
        }

        if (isActive) {
          activeUsers++;
        } else {
          inactiveUsers++;
        }
      }

      return Right(UserStats(
        totalUsers: allUsers.docs.length,
        totalAdmins: totalAdmins,
        totalOrganizers: totalOrganizers,
        totalSuppliers: totalSuppliers,
        totalExhibitors: totalExhibitors,
        activeUsers: activeUsers,
        inactiveUsers: inactiveUsers,
      ));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getOrganizers() async {
    return getUsersByRole(UserRole.organizer);
  }

  @override
  Future<Either<Failure, List<UserModel>>> getSupplierUsers() async {
    return getUsersByRole(UserRole.supplier);
  }
}
