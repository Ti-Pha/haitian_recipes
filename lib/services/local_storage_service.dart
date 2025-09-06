import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // Obtenir le repertoire de documents de l'application
  Future<Directory> get _appDocumentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  // Sauvegarder une image localement
  Future<String> saveImageLocally(File imageFile, String fileName) async {
    try {
      final Directory appDocDir = await _appDocumentsDirectory;
      final String imagePath = path.join(appDocDir.path, fileName);

      // Copier le fichier vers le repertoire de l'application
      final File savedImage = await imageFile.copy(imagePath);

      return savedImage.path;
    } catch (e) {
      print('Erreur lors de la sauvegarde locale: $e');
      rethrow;
    }
  }

  // Charger une image a partir du stockage local
  Future<File> loadImageFromLocal(String imagePath) async {
    try {
      return File(imagePath);
    } catch (e) {
      print('Erreur lors du chargement local: $e');
      rethrow;
    }
  }

  // Dans LocalStorageService
  Future<void> cleanupOrphanedImages(List<String> usedImagePaths) async {
    try {
      final List<String> allSavedImages = await getAllSavedImages();

      for (String imagePath in allSavedImages) {
        if (!usedImagePaths.contains(imagePath)) {
          await deleteLocalImage(imagePath);
          print('Image orpheline supprimée: $imagePath');
        }
      }
    } catch (e) {
      print('Erreur lors du nettoyage des images orphelines: $e');
    }
  }

  // Vérifier si une image existe localement
  Future<bool> imageExists(String imagePath) async {
    try {
      return await File(imagePath).exists();
    } catch (e) {
      return false;
    }
  }

  // Supprimer une image localement
  Future<void> deleteLocalImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      print('Erreur lors de la suppression locale: $e');
    }
  }

  // Obtenir tous les fichiers d'images sauvegardes
  Future<List<String>> getAllSavedImages() async {
    try {
      final Directory appDocDir = await _appDocumentsDirectory;
      final List<FileSystemEntity> files = appDocDir.listSync();

      return files
          .where(
            (file) =>
                file.path.endsWith('.jpg') ||
                file.path.endsWith('.png') ||
                file.path.endsWith('.jpeg'),
          )
          .map((file) => file.path)
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des images: $e');
      return [];
    }
  }
}
