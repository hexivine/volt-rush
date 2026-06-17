import 'dart:io';
import 'dart:typed_data';

/// Helper for loading and caching game assets.
class ImageHelper {
  static final Map<String, Uint8List> _cache = {};

  /// Load image bytes from asset path with caching
  static Future<Uint8List> loadAsset(String path) async {
    if (_cache.containsKey(path)) {
      return _cache[path]!;
    }

    final file = File(path);
    final bytes = await file.readAsBytes();
    _cache[path] = bytes;
    return bytes;
  }

  /// Clear the image cache
  static void clearCache() {
    _cache.clear();
  }

  /// Get cache size in bytes
  static int get cacheSizeBytes {
    return _cache.values.fold(0, (sum, bytes) => sum + bytes.length);
  }
}
