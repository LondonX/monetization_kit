import 'dart:convert';

class LoadResult {
  final String? adKey;
  final Map<String, dynamic>? error;
  const LoadResult({
    required this.adKey,
    required this.error,
  });

  String? errorJson() {
    if (error == null) return null;
    return jsonEncode(error);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'adKey': adKey,
      'error': error,
    };
  }

  factory LoadResult.fromMap(Map<String, dynamic> map) {
    return LoadResult(
      adKey: map['adKey'] != null ? map['adKey'] as String : null,
      error:
          map['error'] != null ? Map<String, dynamic>.from(map['error']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LoadResult.fromJson(String source) =>
      LoadResult.fromMap(json.decode(source) as Map<String, dynamic>);
}
