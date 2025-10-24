import 'package:bepviet_mobile/core/services/api_service.dart';
import 'package:bepviet_mobile/core/models/family_model.dart';

class FamilyService {
  static final FamilyService _instance = FamilyService._internal();
  factory FamilyService() => _instance;
  FamilyService._internal();

  final ApiService _apiService = ApiService();

  /// Lấy danh sách family profiles của user
  Future<List<FamilyProfileModel>> getUserFamilyProfiles() async {
    try {
      final response = await _apiService.getUserFamilyProfiles();
      return response.map((data) => FamilyProfileModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get family profiles: $e');
    }
  }

  /// Tạo family profile mới
  Future<FamilyProfileModel> createFamilyProfile({
    required String name,
    String? note,
  }) async {
    try {
      final response = await _apiService.createFamilyProfile({
        'name': name,
        'note': note,
      });

      // Tạo FamilyProfileModel từ response
      return FamilyProfileModel(
        id: response['id']?.toString() ?? '',
        name: name,
        note: note,
      );
    } catch (e) {
      throw Exception('Failed to create family profile: $e');
    }
  }

  /// Thêm thành viên vào family profile
  Future<FamilyMemberModel> addFamilyMember({
    required String familyId,
    required String name,
    required int age,
    String? dietaryRestrictions,
    String? allergies,
  }) async {
    try {

      final response = await _apiService.addFamilyMember(familyId, {
        'name': name,
        'age': age,
        'dietary_restrictions': dietaryRestrictions,
        'allergies': allergies,
      });


      // Handle backend response structure
      final memberData = response['data'] ?? response;

      return FamilyMemberModel(
        id:
            memberData['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        familyId: familyId,
        name: name,
        age: age,
        dietaryRestrictions: dietaryRestrictions,
        allergies: allergies,
      );
    } catch (e) {
      throw Exception('Failed to add family member: $e');
    }
  }

  /// Lấy thông tin chi tiết của một family profile
  Future<FamilyProfileModel?> getFamilyProfileById(String familyId) async {
    try {
      final profiles = await getUserFamilyProfiles();
      return profiles.firstWhere(
        (profile) => profile.id == familyId,
        orElse: () => throw Exception('Family profile not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Cập nhật family profile
  Future<FamilyProfileModel> updateFamilyProfile({
    required String familyId,
    String? name,
    String? note,
  }) async {
    try {
      // Note: Backend chưa có endpoint update, có thể cần implement
      // Hiện tại chỉ có thể tạo mới
      throw Exception('Update family profile not implemented yet');
    } catch (e) {
      throw Exception('Failed to update family profile: $e');
    }
  }

  /// Xóa family profile
  Future<void> deleteFamilyProfile(String familyId) async {
    try {
      // Note: Backend chưa có endpoint delete, có thể cần implement
      throw Exception('Delete family profile not implemented yet');
    } catch (e) {
      throw Exception('Failed to delete family profile: $e');
    }
  }

  /// Test kết nối API
  Future<bool> testConnection() async {
    try {
      await _apiService.getUserFamilyProfiles();
      return true;
    } catch (e) {
      return false;
    }
  }
}
