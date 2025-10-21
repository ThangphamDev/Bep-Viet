import 'package:bepviet_mobile/core/services/family_service.dart';
import 'package:bepviet_mobile/core/models/family_model.dart';

/// Test file để kiểm tra tích hợp Family API
/// Chạy: dart test_family_integration.dart
void main() async {
  print('🧪 Testing Family API Integration...\n');

  final familyService = FamilyService();

  try {
    // Test 1: Lấy danh sách family profiles
    print('📋 Test 1: Getting user family profiles...');
    final profiles = await familyService.getUserFamilyProfiles();
    print('✅ Successfully retrieved ${profiles.length} family profiles');

    for (var profile in profiles) {
      print('   - Profile: ${profile.name} (ID: ${profile.id})');
      if (profile.note != null) {
        print('     Note: ${profile.note}');
      }
      print('     Members: ${profile.memberCount}');
    }

    // Test 2: Tạo family profile mới
    print('\n📝 Test 2: Creating new family profile...');
    final newProfile = await familyService.createFamilyProfile(
      name: 'Test Family ${DateTime.now().millisecondsSinceEpoch}',
      note: 'Test family created via integration test',
    );
    print(
      '✅ Successfully created family profile: ${newProfile.name} (ID: ${newProfile.id})',
    );

    // Test 3: Thêm thành viên vào family profile
    print('\n👥 Test 3: Adding family member...');
    final newMember = await familyService.addFamilyMember(
      familyId: newProfile.id,
      name: 'Test Member',
      age: 25,
      dietaryRestrictions: 'Vegetarian',
      allergies: 'Peanuts, Shellfish',
    );
    print(
      '✅ Successfully added family member: ${newMember.name} (ID: ${newMember.id})',
    );
    print('   Age: ${newMember.age}');
    print(
      '   Dietary Restrictions: ${newMember.dietaryRestrictions ?? 'None'}',
    );
    print('   Allergies: ${newMember.allergies ?? 'None'}');

    // Test 4: Lấy thông tin chi tiết family profile
    print('\n🔍 Test 4: Getting family profile details...');
    final profileDetails = await familyService.getFamilyProfileById(
      newProfile.id,
    );
    if (profileDetails != null) {
      print('✅ Successfully retrieved family profile details');
      print('   Name: ${profileDetails.name}');
      print('   Note: ${profileDetails.note ?? 'No note'}');
      print('   Member Count: ${profileDetails.memberCount}');
    } else {
      print('❌ Failed to retrieve family profile details');
    }

    print('\n🎉 All tests completed successfully!');
  } catch (e) {
    print('❌ Test failed with error: $e');
    print('\n💡 Make sure:');
    print('   - Backend server is running');
    print('   - API endpoints are accessible');
    print('   - Authentication is properly configured');
  }
}
