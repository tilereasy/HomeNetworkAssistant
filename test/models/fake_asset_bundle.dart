import 'dart:convert';
import 'package:flutter/services.dart';

class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle(this.data);

  final Map<String, dynamic> data;

  @override
  Future<ByteData> load(String key) async {
    final bytes = utf8.encode(json.encode(data));
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return json.encode(data);
  }
}
