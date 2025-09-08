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

  void initialize() {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          _currentUser = UserModel.fromMap(
            userDoc.data() as Map<String, dynamic>,
            userDoc.id,
          );
        } else {
          _currentUser = UserModel(
            userId: firebaseUser.uid,
            email: firebaseUser.email!,
            displayName:
                firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
            favoriteRecipes: [],
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

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
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

        if (userDoc.exists && userDoc.data() != null) {
          _currentUser = UserModel.fromMap(
            userDoc.data() as Map<String, dynamic>,
            userDoc.id,
          );
        }
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'user-not-found') {
        _errorMessage = "Aucun utilisateur trouvé pour cet email.";
      } else if (e.code == 'wrong-password') {
        _errorMessage = "Mot de passe incorrect.";
      } else {
        _errorMessage = "Une erreur est survenue. Veuillez réessayer.";
      }
      notifyListeners();
      return false;
    } catch (e) {
      _setLoading(false);
      _errorMessage = "Une erreur inattendue est survenue.";
      notifyListeners();
      return false;
    }
  }

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
          favoriteRecipes: [],
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

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> updateUserProfile({String? displayName}) async {
    if (currentUser == null) return;

    try {
      await _firestore.collection('users').doc(currentUser!.userId).update({
        'displayName': displayName,
      });

      _currentUser = currentUser!.copyWith(displayName: displayName);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      rethrow;
    }
  }

  Future<void> toggleFavorite(String recipeId) async {
    if (_currentUser == null) return;

    List<String> updatedFavorites = List.from(_currentUser!.favoriteRecipes);

    if (updatedFavorites.contains(recipeId)) {
      updatedFavorites.remove(recipeId);
    } else {
      updatedFavorites.add(recipeId);
    }

    try {
      await _firestore.collection('users').doc(_currentUser!.userId).update({
        'favoriteRecipes': updatedFavorites,
      });

      _currentUser = _currentUser!.copyWith(favoriteRecipes: updatedFavorites);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating favorites: $e');
      }
    }
  }

  Future<void> removeFavoriteFromUser(String userId, String recipeId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favoriteRecipes': FieldValue.arrayRemove([recipeId]),
      });
      print('Recette $recipeId retirée des favoris de l\'utilisateur $userId');
    } catch (e) {
      if (kDebugMode) {
        print(
          'Erreur lors de la suppression du favori pour l\'utilisateur $userId: $e',
        );
      }
    }
  }

  bool isFavorite(String recipeId) {
    return _currentUser?.favoriteRecipes.contains(recipeId) ?? false;
  }
}
