import 'package:halalhub_restaurant/core/storage/base_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class Storage {
  Storage(
    this._box,
    // this._boxModel,
  );
  // final Box _boxModel;
  final Box _box;

  @FactoryMethod(preResolve: true)
  static Future<Storage> create() async {
    await Hive.initFlutter();
    // tozalash
    // await Hive.deleteFromDisk();

    final box = await Hive.openBox('storage');
    // final box2 = await Hive.openBox("models");
    return Storage(
      box,
      //  box2,
    );
  }

  BaseStorage<String> get token => BaseStorage(_box, 'token');

  BaseStorage<bool> get onboarded => BaseStorage(_box, 'onboarded');

  BaseStorage<String> get refreshToken => BaseStorage(_box, 'refreshToken');

  BaseStorage<String> get languageCode => BaseStorage(_box, 'languageCode');

  /// EPSON / boshqa ESC/POS WiFi printer — RAW TCP host (masalan `192.168.1.50`).
  BaseStorage<String> get receiptPrinterHost =>
      BaseStorage(_box, 'receiptPrinterHost');
}
