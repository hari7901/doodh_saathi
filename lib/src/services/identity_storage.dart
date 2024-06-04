import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;

class FirebaseStorageService {
  Future<String?> uploadFile(File file) async {
    try {
      String fileName = Path.basename(file.path);
      firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref().child('identity_proofs/$fileName');

      firebase_storage.UploadTask uploadTask = ref.putFile(file);
      await uploadTask;
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }
}
