import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File image, String authorId) async {
    try {
      final imageRef = _storage
          .ref()
          .child('recipes')
          .child(authorId)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await imageRef.putFile(image);

      final downloadUrl = await imageRef.getDownloadURL();
      print('Image uploaded. Download URL: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Erreur détaillée lors de l\'upload: $e');
      rethrow;
    }
  }
}
