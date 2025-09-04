import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // Initialiser l'état d'authentification
  void initialize() {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        // Récupérer les données utilisateur depuis Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          _currentUser = UserModel.fromMap(
            userDoc.data() as Map<String, dynamic>,
          );
        } else {
          // Créer un document utilisateur s'il n'existe pas
          _currentUser = UserModel(
            userId: firebaseUser.uid,
            email: firebaseUser.email!,
            displayName:
                firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
          );

          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .set(_currentUser!.toMap());
        }
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  // Connexion
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();

        if (userDoc.exists) {
          _currentUser = UserModel.fromMap(
            userDoc.data() as Map<String, dynamic>,
          );
        }
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  // Inscription
  Future<bool> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    _setLoading(true);
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        UserModel newUser = UserModel(
          userId: result.user!.uid,
          email: email,
          displayName: displayName,
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(newUser.toMap());

        _currentUser = newUser;
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
