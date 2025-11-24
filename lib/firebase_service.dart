// services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zottz_otone/firebase_datamodel.dart';


class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'users';

  // Add new user information
  Future<void> addUserInformation(UserInformation userInfo) async {
    try {
      await _firestore
          .collection(_collectionName)
          .add(userInfo.toMap());
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  // Get all usernames
  Future<List<String>> getAllUsernames() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('userName')
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['userName'] as String)
          .toList();
    } catch (e) {
      throw Exception('Failed to load usernames: $e');
    }
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userName', isEqualTo: username)
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw Exception('Failed to check username: $e');
    }
  }

  // Get user information by username
  Future<UserInformation?> getUserByUsername(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userName', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return UserInformation.fromMap(doc.id, doc.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user exercise data
  Future<void> updateUserExerciseData({
    required String username,
    required int scissorCount,
    required int pencilCount,
    required int pincherCount,
    required int buttonCount,
    required int timer,
  }) async {
    try {
      final user = await getUserByUsername(username);
      if (user != null) {
        String currentDate = DateTime.now().toIso8601String().split('T').first;
        
        // Create updated user information
        UserInformation updatedUser = UserInformation(
          id: user.id,
          userName: user.userName,
          userAge: user.userAge,
          scissor: user.scissor + scissorCount,
          pencil: user.pencil + pencilCount,
          pincher: user.pincher + pincherCount,
          button: user.button + buttonCount,
          sessionDate: currentDate,
          timer: user.timer + timer,
          createdAt: user.createdAt,
        );

        // Update in Firebase
        await _firestore
            .collection(_collectionName)
            .doc(user.id)
            .update(updatedUser.toMap());
      }
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(String username) async {
    try {
      final user = await getUserByUsername(username);
      if (user != null) {
        return {
          'totalScissor': user.scissor,
          'totalPencil': user.pencil,
          'totalPincher': user.pincher,
          'totalButton': user.button,
          'totalTime': user.timer,
          'lastSession': user.sessionDate,
        };
      }
      return {};
    } catch (e) {
      throw Exception('Failed to get user statistics: $e');
    }
  }

  // Get all users with their data (for admin purposes)
  Future<List<UserInformation>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserInformation.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  // Delete user by username
  Future<void> deleteUser(String username) async {
    try {
      final user = await getUserByUsername(username);
      if (user != null && user.id != null) {
        await _firestore.collection(_collectionName).doc(user.id).delete();
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}