import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ConsumingManager {
  static ConsumingManager instance = ConsumingManager._();

  ConsumingManager._();

  final _consumingList = <Consuming>[];

  Future<File> get _file async {
    final dir = await getApplicationSupportDirectory();
    final file = File("${dir.path}${Platform.pathSeparator}consumingList.json");
    await file.create();
    return file;
  }

  Future<bool> init() async {
    final json = await (await _file).readAsString();
    if (json.isNotEmpty) {
      final list = List<Map<String, dynamic>>.from(jsonDecode(json))
          .map((e) => Consuming.fromMap(e));
      _consumingList.addAll(list);
    }
    return true;
  }

  Future<void> add(Consuming consuming) async {
    if (_consumingList.contains(consuming)) return;
    _consumingList.add(consuming);
    final list = _consumingList.map((e) => e.toMap()).toList();
    final json = jsonEncode(list);
    (await _file).writeAsString(json);
  }

  Future<void> remove(Consuming consuming) async {
    if (!_consumingList.contains(consuming)) return;
    _consumingList.remove(consuming);
    final list = _consumingList.map((e) => e.toMap()).toList();
    final json = jsonEncode(list);
    (await _file).writeAsString(json);
  }

  Future<void> removeAll() async {
    _consumingList.clear();
    final list = _consumingList.map((e) => e.toMap()).toList();
    final json = jsonEncode(list);
    (await _file).writeAsString(json);
  }

  List<Consuming> get list => _consumingList;
}

class Consuming {
  final String productId;
  final String serverVerificationData;
  const Consuming({
    required this.productId,
    required this.serverVerificationData,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pid': productId,
      'tk': serverVerificationData,
    };
  }

  factory Consuming.fromMap(Map<String, dynamic> map) {
    return Consuming(
      productId: map['pid'] as String,
      serverVerificationData: map['tk'] as String,
    );
  }

  @override
  bool operator ==(covariant Consuming other) {
    if (identical(this, other)) return true;

    return other.productId == productId &&
        other.serverVerificationData == serverVerificationData;
  }

  @override
  int get hashCode => productId.hashCode ^ serverVerificationData.hashCode;
}
