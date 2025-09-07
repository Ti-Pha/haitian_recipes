import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Connexion avec email et mot de passe
  // Dans votre fichier auth_service.dart

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      // Rejeter l'exception pour que le AuthProvider puisse la capturer
      rethrow;
    }
  }

  // Inscription avec email et mot de passe
  Future<UserModel?> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        UserModel newUser = UserModel(
          userId: user.uid,
          email: email,
          displayName: displayName,
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

        return newUser;
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Récupérer l'utilisateur actuel
  Stream<User?> get currentUser => _auth.authStateChanges();
}
