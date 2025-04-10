import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class AppwriteService {
  static final client = Client()
    ..setEndpoint('http://cloud.appwrite.io/v1') // Ganti jika pakai emulator/device
    ..setProject('67f7771d00013eb112a6');

  static final account = Account(client);
  static final database = Databases(client);
  static final storage = Storage(client);
}
