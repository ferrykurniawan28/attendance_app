part of 'services.dart';

class StorageService {
  static final _client = Supabase.instance.client;

  /// Uploads a file to the specified bucket and returns the public URL.
  static Future<String?> uploadFile({
    required File file,
    required String bucket,
    required String fileName,
  }) async {
    try {
      final storage = _client.storage.from(bucket);
      await storage.upload(
        fileName,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl = storage.getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  /// Deletes a file from the specified bucket
  static Future<bool> deleteFile({
    required String bucket,
    required String fileName,
  }) async {
    try {
      await _client.storage.from(bucket).remove([fileName]);
      return true;
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }

  /// You could add more methods here, e.g., fetchFileUrl, rename, etc.
}
