import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

@injectable
class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Galereyadan bitta rasm tanlash
  Future<XFile?> pickImageFromGallery({int? imageQuality, double? maxWidth, double? maxHeight}) async {
    return await _picker.pickImage(source: ImageSource.gallery, imageQuality: imageQuality ?? 85, maxWidth: maxWidth, maxHeight: maxHeight);
  }

  /// Kameradan rasm olish
  Future<XFile?> pickImageFromCamera({int? imageQuality, double? maxWidth, double? maxHeight, CameraDevice preferredCameraDevice = CameraDevice.rear}) async {
    return await _picker.pickImage(source: ImageSource.camera, imageQuality: imageQuality ?? 85, maxWidth: maxWidth, maxHeight: maxHeight, preferredCameraDevice: preferredCameraDevice);
  }

  /// Galereyadan bir nechta rasm tanlash
  Future<List<XFile>> pickMultipleImages({int? imageQuality, double? maxWidth, double? maxHeight}) async {
    return await _picker.pickMultiImage(imageQuality: imageQuality ?? 85, maxWidth: maxWidth, maxHeight: maxHeight);
  }

  /// Galereyadan video tanlash
  Future<XFile?> pickVideoFromGallery() async {
    return await _picker.pickVideo(source: ImageSource.gallery);
  }

  /// Kameradan video yozish
  Future<XFile?> recordVideo() async {
    return await _picker.pickVideo(source: ImageSource.camera);
  }

  /// Rasm yoki video tanlash (bitta)
  Future<XFile?> pickMedia() async {
    return await _picker.pickMedia();
  }

  /// Rasm va video aralash tanlash
  Future<List<XFile>> pickMultipleMedia() async {
    return await _picker.pickMultipleMedia();
  }

  /// Bottom sheet orqali galereya yoki kamera tanlash
  Future<XFile?> showPickerDialog({required Future<XFile?> Function() onGallery, required Future<XFile?> Function() onCamera}) async {
    // Bu metodni UI qatlamida BottomSheet bilan birgalikda ishlatish tavsiya etiladi
    // Quyida to'g'ridan-to'g'ri chaqiruv uchun misol
    return await onGallery();
  }

  /// Android uchun — ilovani qayta ishga tushganda yo'qolgan ma'lumotni olish
  Future<void> retrieveLostData({required Function(List<XFile> files) onSuccess, required Function(dynamic error) onError}) async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) return;

    if (response.files != null) {
      onSuccess(response.files!);
    } else {
      onError(response.exception);
    }
  }
}
