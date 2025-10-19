import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/family_member_card.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/add_member_dialog.dart';

class FamilyProfilePage extends StatefulWidget {
  const FamilyProfilePage({super.key});

  @override
  State<FamilyProfilePage> createState() => _FamilyProfilePageState();
}

class _FamilyProfilePageState extends State<FamilyProfilePage> {
  final List<FamilyMember> _familyMembers = [
    FamilyMember(
      id: '1',
      name: 'Nguyễn Văn A',
      age: 35,
      role: 'Bố',
      allergies: ['Hải sản', 'Đậu phộng'],
      dietaryRestrictions: ['Không cay'],
      healthConditions: ['Huyết áp cao'],
    ),
    FamilyMember(
      id: '2',
      name: 'Trần Thị B',
      age: 32,
      role: 'Mẹ',
      allergies: ['Sữa'],
      dietaryRestrictions: ['Ăn chay'],
      healthConditions: ['Tiểu đường'],
    ),
    FamilyMember(
      id: '3',
      name: 'Nguyễn Văn C',
      age: 8,
      role: 'Con',
      allergies: ['Trứng'],
      dietaryRestrictions: [],
      healthConditions: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Hồ sơ gia đình'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/premium'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMemberDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Family Overview Card
          Container(
            margin: const EdgeInsets.all(AppConfig.defaultPadding),
            padding: const EdgeInsets.all(AppConfig.largePadding),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppConfig.defaultPadding + 4),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConfig.smallPadding + 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppConfig.smallPadding + 4,
                        ),
                      ),
                      child: const Icon(
                        Icons.family_restroom,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppConfig.defaultPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hồ sơ gia đình thông minh',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: AppConfig.smallPadding / 2),
                          Text(
                            '${_familyMembers.length} thành viên • 3 cảnh báo hoạt động • 2 báo cáo tuần',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConfig.smallPadding,
                        vertical: AppConfig.smallPadding / 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppConfig.smallPadding,
                        ),
                      ),
                      child: Text(
                        'Premium',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConfig.largePadding),
                Row(
                  children: [
                    Expanded(
                      child: _buildFamilyStat(
                        'Thành viên',
                        '${_familyMembers.length}',
                        Colors.white,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildFamilyStat('Cảnh báo', '3', Colors.white),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildFamilyStat(
                        'Điểm sức khỏe',
                        '8.2',
                        Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Family Members List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConfig.defaultPadding,
              ),
              itemCount: _familyMembers.length,
              itemBuilder: (context, index) {
                final member = _familyMembers[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppConfig.smallPadding + 4,
                  ),
                  child: FamilyMemberCard(
                    member: member,
                    onTap: () => _showMemberDetails(member),
                    onEdit: () => _editMember(member),
                    onDelete: () => _deleteMember(member),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMemberDialog(),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Thêm thành viên',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMemberDialog(
        onSave: (member) {
          setState(() {
            _familyMembers.add(member);
          });
        },
      ),
    );
  }

  void _showMemberDetails(FamilyMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMemberDetailsSheet(member),
    );
  }

  Widget _buildMemberDetailsSheet(FamilyMember member) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Member Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                        child: Text(
                          member.name.split(' ').last[0],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              '${member.age} tuổi • ${member.role}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editMember(member),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Allergies Section
                  if (member.allergies.isNotEmpty) ...[
                    _buildInfoSection(
                      title: 'Dị ứng',
                      icon: Icons.warning_amber,
                      color: AppTheme.warningColor,
                      items: member.allergies,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Dietary Restrictions
                  if (member.dietaryRestrictions.isNotEmpty) ...[
                    _buildInfoSection(
                      title: 'Hạn chế ăn uống',
                      icon: Icons.restaurant,
                      color: AppTheme.infoColor,
                      items: member.dietaryRestrictions,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Health Conditions
                  if (member.healthConditions.isNotEmpty) ...[
                    _buildInfoSection(
                      title: 'Tình trạng sức khỏe',
                      icon: Icons.health_and_safety,
                      color: AppTheme.errorColor,
                      items: member.healthConditions,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => Chip(
                  label: Text(item),
                  backgroundColor: color.withOpacity(0.1),
                  labelStyle: TextStyle(color: color),
                  side: BorderSide(color: color.withOpacity(0.3)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _editMember(FamilyMember member) {
    // TODO: Implement edit member
  }

  void _deleteMember(FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thành viên'),
        content: Text('Bạn có chắc muốn xóa ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _familyMembers.remove(member);
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }
}

class FamilyMember {
  final String id;
  final String name;
  final int age;
  final String role;
  final List<String> allergies;
  final List<String> dietaryRestrictions;
  final List<String> healthConditions;

  FamilyMember({
    required this.id,
    required this.name,
    required this.age,
    required this.role,
    required this.allergies,
    required this.dietaryRestrictions,
    required this.healthConditions,
  });
}
