import 'package:bepviet_mobile/core/services/family_service.dart';
import 'package:bepviet_mobile/core/models/family_model.dart';

/// Test file để kiểm tra việc thêm thành viên gia đình
/// Chạy: dart test_add_family_member.dart
void main() async {
  print('🧪 Testing Add Family Member...\n');

  final familyService = FamilyService();

  try {
    // Test 1: Kiểm tra kết nối API
    print('📡 Test 1: Testing API connection...');
    final isConnected = await familyService.testConnection();
    if (!isConnected) {
      print('❌ API connection failed. Please check:');
      print('   - Backend server is running');
      print('   - API endpoints are accessible');
      print('   - Network connection is stable');
      return;
    }
    print('✅ API connection successful\n');

    // Test 2: Lấy danh sách family profiles
    print('📋 Test 2: Getting family profiles...');
    final profiles = await familyService.getUserFamilyProfiles();
    print('✅ Found ${profiles.length} family profiles');

    if (profiles.isEmpty) {
      print('⚠️  No family profiles found. Creating one first...');

      // Tạo family profile mới
      final newProfile = await familyService.createFamilyProfile(
        name: 'Test Family ${DateTime.now().millisecondsSinceEpoch}',
        note: 'Test family for member testing',
      );
      print(
        '✅ Created family profile: ${newProfile.name} (ID: ${newProfile.id})',
      );

      // Sử dụng profile vừa tạo
      final familyId = newProfile.id;
      print('📝 Using family profile: $familyId\n');
    } else {
      // Sử dụng profile đầu tiên
      final familyId = profiles.first.id;
      print('📝 Using existing family profile: $familyId\n');
    }

    // Test 3: Thêm thành viên mới
    print('👥 Test 3: Adding new family member...');
    final newMember = await familyService.addFamilyMember(
      familyId: profiles.isNotEmpty ? profiles.first.id : 'test_family_id',
      name: 'Test Member ${DateTime.now().millisecondsSinceEpoch}',
      age: 25,
      dietaryRestrictions: 'Vegetarian',
      allergies: 'Peanuts, Shellfish',
    );

    print('✅ Successfully added family member:');
    print('   - ID: ${newMember.id}');
    print('   - Name: ${newMember.name}');
    print('   - Age: ${newMember.age}');
    print(
      '   - Dietary Restrictions: ${newMember.dietaryRestrictions ?? 'None'}',
    );
    print('   - Allergies: ${newMember.allergies ?? 'None'}');

    print('\n🎉 All tests completed successfully!');
    print('\n💡 If you still see issues:');
    print('   1. Check backend server logs');
    print('   2. Verify database connection');
    print('   3. Check JWT authentication');
    print('   4. Verify API endpoints are working');
  } catch (e) {
    print('❌ Test failed with error: $e');
    print('\n🔍 Debugging steps:');
    print('   1. Check if backend server is running');
    print('   2. Verify API endpoints in backend');
    print('   3. Check database connection');
    print('   4. Verify authentication setup');
    print('   5. Check network connectivity');
  }
}
