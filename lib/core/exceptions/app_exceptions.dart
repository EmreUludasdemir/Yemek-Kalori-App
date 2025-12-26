/// Base exception class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalError});

  factory NetworkException.noConnection() =>
      NetworkException('İnternet bağlantısı yok', code: 'NO_CONNECTION');

  factory NetworkException.timeout() =>
      NetworkException('Bağlantı zaman aşımına uğradı', code: 'TIMEOUT');

  factory NetworkException.serverError() =>
      NetworkException('Sunucu hatası', code: 'SERVER_ERROR');
}

/// Authentication exceptions
class AuthException extends AppException {
  AuthException(super.message, {super.code, super.originalError});

  factory AuthException.invalidCredentials() =>
      AuthException('Geçersiz kullanıcı adı veya şifre', code: 'INVALID_CREDENTIALS');

  factory AuthException.userNotFound() =>
      AuthException('Kullanıcı bulunamadı', code: 'USER_NOT_FOUND');

  factory AuthException.emailAlreadyExists() =>
      AuthException('Bu e-posta zaten kullanımda', code: 'EMAIL_EXISTS');

  factory AuthException.weakPassword() =>
      AuthException('Şifre çok zayıf', code: 'WEAK_PASSWORD');

  factory AuthException.sessionExpired() =>
      AuthException('Oturumunuz sona erdi', code: 'SESSION_EXPIRED');

  factory AuthException.unauthorized() =>
      AuthException('Bu işlem için yetkiniz yok', code: 'UNAUTHORIZED');
}

/// Data/Database exceptions
class DataException extends AppException {
  DataException(super.message, {super.code, super.originalError});

  factory DataException.notFound(String entity) =>
      DataException('$entity bulunamadı', code: 'NOT_FOUND');

  factory DataException.createFailed(String entity) =>
      DataException('$entity oluşturulamadı', code: 'CREATE_FAILED');

  factory DataException.updateFailed(String entity) =>
      DataException('$entity güncellenemedi', code: 'UPDATE_FAILED');

  factory DataException.deleteFailed(String entity) =>
      DataException('$entity silinemedi', code: 'DELETE_FAILED');

  factory DataException.invalidData() =>
      DataException('Geçersiz veri', code: 'INVALID_DATA');
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException(super.message, {super.code, this.fieldErrors, super.originalError});

  factory ValidationException.required(String field) =>
      ValidationException('$field zorunludur', code: 'REQUIRED');

  factory ValidationException.invalidFormat(String field) =>
      ValidationException('$field formatı geçersiz', code: 'INVALID_FORMAT');

  factory ValidationException.tooShort(String field, int minLength) =>
      ValidationException(
        '$field en az $minLength karakter olmalı',
        code: 'TOO_SHORT',
      );

  factory ValidationException.tooLong(String field, int maxLength) =>
      ValidationException(
        '$field en fazla $maxLength karakter olabilir',
        code: 'TOO_LONG',
      );

  factory ValidationException.outOfRange(String field, num min, num max) =>
      ValidationException(
        '$field $min ile $max arasında olmalı',
        code: 'OUT_OF_RANGE',
      );
}

/// File/Storage exceptions
class StorageException extends AppException {
  StorageException(super.message, {super.code, super.originalError});

  factory StorageException.uploadFailed() =>
      StorageException('Dosya yüklenemedi', code: 'UPLOAD_FAILED');

  factory StorageException.downloadFailed() =>
      StorageException('Dosya indirilemedi', code: 'DOWNLOAD_FAILED');

  factory StorageException.deleteFailed() =>
      StorageException('Dosya silinemedi', code: 'DELETE_FAILED');

  factory StorageException.fileTooLarge(int maxSize) =>
      StorageException(
        'Dosya çok büyük (Max: ${maxSize}MB)',
        code: 'FILE_TOO_LARGE',
      );

  factory StorageException.invalidFileType() =>
      StorageException('Geçersiz dosya türü', code: 'INVALID_FILE_TYPE');

  factory StorageException.permissionDenied() =>
      StorageException('Depolama izni reddedildi', code: 'PERMISSION_DENIED');
}

/// Image processing exceptions
class ImageException extends AppException {
  ImageException(super.message, {super.code, super.originalError});

  factory ImageException.pickCancelled() =>
      ImageException('Fotoğraf seçimi iptal edildi', code: 'PICK_CANCELLED');

  factory ImageException.compressionFailed() =>
      ImageException('Fotoğraf sıkıştırılamadı', code: 'COMPRESSION_FAILED');

  factory ImageException.cropCancelled() =>
      ImageException('Kırpma iptal edildi', code: 'CROP_CANCELLED');

  factory ImageException.invalidImage() =>
      ImageException('Geçersiz fotoğraf', code: 'INVALID_IMAGE');
}

/// Cache exceptions
class CacheException extends AppException {
  CacheException(super.message, {super.code, super.originalError});

  factory CacheException.readFailed() =>
      CacheException('Önbellekten okunamadı', code: 'READ_FAILED');

  factory CacheException.writeFailed() =>
      CacheException('Önbelleğe yazılamadı', code: 'WRITE_FAILED');

  factory CacheException.clearFailed() =>
      CacheException('Önbellek temizlenemedi', code: 'CLEAR_FAILED');
}

/// Permission exceptions
class PermissionException extends AppException {
  PermissionException(super.message, {super.code, super.originalError});

  factory PermissionException.cameraDenied() =>
      PermissionException('Kamera izni reddedildi', code: 'CAMERA_DENIED');

  factory PermissionException.photoDenied() =>
      PermissionException('Fotoğraf izni reddedildi', code: 'PHOTO_DENIED');

  factory PermissionException.notificationDenied() =>
      PermissionException('Bildirim izni reddedildi', code: 'NOTIFICATION_DENIED');

  factory PermissionException.locationDenied() =>
      PermissionException('Konum izni reddedildi', code: 'LOCATION_DENIED');
}

/// Rate limit exception
class RateLimitException extends AppException {
  final int retryAfterSeconds;

  RateLimitException(
    super.message, {
    required this.retryAfterSeconds,
    super.code,
    super.originalError,
  });

  factory RateLimitException.tooManyRequests({int retryAfter = 60}) =>
      RateLimitException(
        'Çok fazla istek gönderildi. Lütfen bekleyin.',
        retryAfterSeconds: retryAfter,
        code: 'TOO_MANY_REQUESTS',
      );
}

/// Unknown/Unexpected exception
class UnknownException extends AppException {
  UnknownException(super.message, {super.code, super.originalError});

  factory UnknownException.unexpected([String? details]) =>
      UnknownException(
        'Beklenmeyen bir hata oluştu${details != null ? ': $details' : ''}',
        code: 'UNEXPECTED',
      );
}
