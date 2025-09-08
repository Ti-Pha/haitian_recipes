import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Future<Directory> get _appDocumentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  Future<String> saveImageLocally(File imageFile, String fileName) async {
    try {
      final Directory appDocDir = await _appDocumentsDirectory;
      final String imagePath = path.join(appDocDir.path, fileName);

      final File savedImage = await imageFile.copy(imagePath);

      return savedImage.path;
    } catch (e) {
      print('Error while saving images: $e');
      rethrow;
    }
  }

  Future<File> loadImageFromLocal(String imagePath) async {
    try {
      return File(imagePath);
    } catch (e) {
      print('Error loading: $e');
      rethrow;
    }
  }

  Future<void> cleanupOrphanedImages(List<String> usedImagePaths) async {
    try {
      final List<String> allSavedImages = await getAllSavedImages();

      for (String imagePath in allSavedImages) {
        if (!usedImagePaths.contains(imagePath)) {
          await deleteLocalImage(imagePath);
          print('Image deleted: $imagePath');
        }
      }
    } catch (e) {
      print('Error cleaning images: $e');
    }
  }

  Future<bool> imageExists(String imagePath) async {
    try {
      return await File(imagePath).exists();
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteLocalImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      print('Error while deleting: $e');
    }
  }

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
      print('Error while retrieving images: $e');
      return [];
    }
  }
}
