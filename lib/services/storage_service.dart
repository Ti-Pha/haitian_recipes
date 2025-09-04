import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Uploader une image
  Future<String> uploadImage(File image, String userId) async {
    try {
      // Créer un nom de fichier unique
      String fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Référence vers l'emplacement de stockage
      Reference ref = _storage.ref().child('recipeImages').child(fileName);

      // Metadata pour le fichier
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toString(),
        },
      );

      // Upload du fichier avec metadata
      UploadTask uploadTask = ref.putFile(image, metadata);

      // Attendre la completion de l'upload
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      // Vérifier que l'upload a réussi
      if (snapshot.state == TaskState.success) {
        // Récupérer l'URL de téléchargement
        String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } catch (e) {
      print('Erreur détaillée lors de l\'upload: $e');
      rethrow;
    }
  }

  // Supprimer une image
  Future<void> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        Reference ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
    } catch (e) {
      print('Erreur lors de la suppression: $e');
    }
  }
}
