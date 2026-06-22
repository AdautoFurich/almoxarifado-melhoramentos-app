import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ItemPhotoService {
  ItemPhotoService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<String?> pickAndStore(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1600,
    );

    if (image == null) {
      return null;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final photosDirectory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}item_photos',
    );
    await photosDirectory.create(recursive: true);

    final extension = _fileExtension(image.path);
    final fileName = 'item_${DateTime.now().microsecondsSinceEpoch}$extension';
    final destination = File(
      '${photosDirectory.path}${Platform.pathSeparator}$fileName',
    );

    await File(image.path).copy(destination.path);
    return destination.path;
  }

  Future<void> deletePhoto(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }

    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _fileExtension(String path) {
    final fileName = path.split(RegExp(r'[/\\]')).last;
    final dotIndex = fileName.lastIndexOf('.');

    return dotIndex == -1 ? '.jpg' : fileName.substring(dotIndex).toLowerCase();
  }
}
