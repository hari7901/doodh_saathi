  import 'package:firebase_storage/firebase_storage.dart';

Future<List<String>> fetchProductImageUrls() async {
  List<String> imageUrls = [];
  final ListResult result = await FirebaseStorage.instance.ref('products').listAll();
  for (var ref in result.items) {
    String url = await ref.getDownloadURL();
    imageUrls.add(url);
  }
  return imageUrls;
}