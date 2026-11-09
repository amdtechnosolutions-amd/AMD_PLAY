import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../network/api_endpoints.dart';

/// Secure storage service wrapping FlutterSecureStorage for auth tokens and session data.
class StorageService extends GetxService {
  late final FlutterSecureStorage _secureStorage;
  final Map<String, String> _cache = {};

  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyTenantId = 'tenant_id';
  static const String keyBranchId = 'branch_id';
  static const String keyStudentId = 'student_id';
  static const String keyUserRole = 'user_role';
  static const String keyUserName = 'user_name';
  static const String keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String keyUserJson = 'user_profile';

  Future<StorageService> init() async {
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      webOptions: WebOptions(dbName: 'sports_academy_secure', publicKey: 'sports_academy_pub_key'),
    );
    try {
      final all = await _secureStorage.readAll();
      _cache.addAll(all);

      // Auto-sanitize legacy debug mock sessions (e.g. AMD Superadmin dummy registration)
      final storedName = _cache[keyUserName]?.toUpperCase() ?? '';
      final storedJson = _cache[keyUserJson] ?? '';
      final isLegacyMockSession = storedName == 'AMD' ||
          storedName == 'GUEST PLAYER' ||
          storedJson.contains('9876543210') ||
          storedJson.contains('admin@amdtechno.in') ||
          storedJson.contains('6ad67f8a21c35f3cf2139ef8');

      if (isLegacyMockSession) {
        _cache.clear();
        try {
          await _secureStorage.deleteAll();
        } catch (_) {}
      }
    } catch (_) {}
    return this;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (accessToken.isNotEmpty) {
      _cache[keyAccessToken] = accessToken;
      await _secureStorage.write(key: keyAccessToken, value: accessToken);
    }
    if (refreshToken.isNotEmpty) {
      _cache[keyRefreshToken] = refreshToken;
      await _secureStorage.write(key: keyRefreshToken, value: refreshToken);
    }
  }

  Future<void> saveUserName(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) return;
    _cache[keyUserName] = clean;
    await _secureStorage.write(key: keyUserName, value: clean);
  }

  Future<void> saveUserSession({
    required String accessToken,
    required String refreshToken,
    String? tenantId,
    String? branchId,
    String? studentId,
    String? role,
    String? userName,
    String? userJson,
  }) async {
    if (accessToken.isNotEmpty) {
      _cache[keyAccessToken] = accessToken;
      await _secureStorage.write(key: keyAccessToken, value: accessToken);
    }
    if (refreshToken.isNotEmpty) {
      _cache[keyRefreshToken] = refreshToken;
      await _secureStorage.write(key: keyRefreshToken, value: refreshToken);
    }
    if (tenantId != null && tenantId.isNotEmpty) {
      _cache[keyTenantId] = tenantId;
      await _secureStorage.write(key: keyTenantId, value: tenantId);
    }
    if (branchId != null && branchId.isNotEmpty) {
      _cache[keyBranchId] = branchId;
      await _secureStorage.write(key: keyBranchId, value: branchId);
    }
    if (studentId != null && studentId.isNotEmpty) {
      _cache[keyStudentId] = studentId;
      await _secureStorage.write(key: keyStudentId, value: studentId);
    }
    if (role != null && role.isNotEmpty) {
      _cache[keyUserRole] = role;
      await _secureStorage.write(key: keyUserRole, value: role);
    }
    if (userName != null && userName.trim().isNotEmpty) {
      _cache[keyUserName] = userName.trim();
      await _secureStorage.write(key: keyUserName, value: userName.trim());
    }
    if (userJson != null && userJson.isNotEmpty) {
      _cache[keyUserJson] = userJson;
      await _secureStorage.write(key: keyUserJson, value: userJson);
    }
  }

  Future<String?> getAccessToken() async {
    if (_cache.containsKey(keyAccessToken) && _cache[keyAccessToken]!.isNotEmpty) {
      return _cache[keyAccessToken];
    }
    try {
      final val = await _secureStorage.read(key: keyAccessToken);
      if (val != null && val.isNotEmpty) _cache[keyAccessToken] = val;
      return val;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    if (_cache.containsKey(keyRefreshToken) && _cache[keyRefreshToken]!.isNotEmpty) {
      return _cache[keyRefreshToken];
    }
    try {
      final val = await _secureStorage.read(key: keyRefreshToken);
      if (val != null && val.isNotEmpty) _cache[keyRefreshToken] = val;
      return val;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTenantId(String tenantId) async {
    final clean = tenantId.trim();
    if (clean.isEmpty) return;
    _cache[keyTenantId] = clean;
    try {
      await _secureStorage.write(key: keyTenantId, value: clean);
    } catch (_) {}
  }

  Future<String?> getTenantId() async {
    String? val;
    if (_cache.containsKey(keyTenantId) && _cache[keyTenantId]!.isNotEmpty) {
      val = _cache[keyTenantId];
    } else {
      try {
        val = await _secureStorage.read(key: keyTenantId);
        if (val != null && val.isNotEmpty) _cache[keyTenantId] = val;
      } catch (_) {}
    }
    // Auto-migrate stale local dev tenant ID to live tenant ID in production
    if (ApiEndpoints.isProduction && (val == null || val.isEmpty || val == ApiEndpoints.localTenantId)) {
      val = ApiEndpoints.liveTenantId;
      _cache[keyTenantId] = val;
      try {
        await _secureStorage.write(key: keyTenantId, value: val);
      } catch (_) {}
    }
    return val;
  }

  Future<String?> getStudentId() async {
    if (_cache.containsKey(keyStudentId) && _cache[keyStudentId]!.isNotEmpty) {
      return _cache[keyStudentId];
    }
    try {
      final val = await _secureStorage.read(key: keyStudentId);
      if (val != null && val.isNotEmpty) _cache[keyStudentId] = val;
      return val;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getUserRole() async {
    if (_cache.containsKey(keyUserRole) && _cache[keyUserRole]!.isNotEmpty) {
      return _cache[keyUserRole];
    }
    try {
      final val = await _secureStorage.read(key: keyUserRole);
      if (val != null && val.isNotEmpty) _cache[keyUserRole] = val;
      return val;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getUserName() async {
    if (_cache.containsKey(keyUserName) && _cache[keyUserName]!.isNotEmpty) {
      return _cache[keyUserName];
    }
    try {
      final val = await _secureStorage.read(key: keyUserName);
      if (val != null && val.isNotEmpty) _cache[keyUserName] = val;
      return val;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getUserJson() async {
    if (_cache.containsKey(keyUserJson) && _cache[keyUserJson]!.isNotEmpty) {
      return _cache[keyUserJson];
    }
    try {
      final val = await _secureStorage.read(key: keyUserJson);
      if (val != null && val.isNotEmpty) _cache[keyUserJson] = val;
      return val;
    } catch (_) {
      return null;
    }
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    _cache[keyHasSeenOnboarding] = value.toString();
    await _secureStorage.write(key: keyHasSeenOnboarding, value: value.toString());
  }

  Future<bool> hasSeenOnboarding() async {
    if (_cache.containsKey(keyHasSeenOnboarding)) {
      return _cache[keyHasSeenOnboarding] == 'true';
    }
    try {
      final val = await _secureStorage.read(key: keyHasSeenOnboarding);
      if (val != null) _cache[keyHasSeenOnboarding] = val;
      return val == 'true';
    } catch (_) {
      return false;
    }
  }

  Future<void> clearAll() async {
    _cache.clear();
    await _secureStorage.deleteAll();
  }
}
