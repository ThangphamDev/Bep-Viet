import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/presentation/features/premium/pages/family_profile_page.dart';

class AddMemberDialog extends StatefulWidget {
  final Function(FamilyMember) onSave;

  const AddMemberDialog({super.key, required this.onSave});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedRole = 'Bố';
  final List<String> _selectedAllergies = [];
  final List<String> _selectedDietaryRestrictions = [];
  final List<String> _selectedHealthConditions = [];

  final List<String> _roles = ['Bố', 'Mẹ', 'Con', 'Ông', 'Bà', 'Khác'];
  final List<String> _allergies = [
    'Hải sản',
    'Đậu phộng',
    'Sữa',
    'Trứng',
    'Lúa mì',
    'Đậu nành',
    'Hạt cây',
  ];
  final List<String> _dietaryRestrictions = [
    'Ăn chay',
    'Không cay',
    'Ít muối',
    'Không đường',
    'Keto',
    'Paleo',
  ];
  final List<String> _healthConditions = [
    'Tiểu đường',
    'Huyết áp cao',
    'Tim mạch',
    'Dạ dày',
    'Thận',
    'Gan',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.largePadding - 4),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConfig.largePadding - 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConfig.largePadding - 4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: AppConfig.smallPadding + 4),
                  Text(
                    'Thêm thành viên gia đình',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConfig.largePadding - 4),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info
                      _buildSectionTitle('Thông tin cơ bản'),
                      const SizedBox(height: AppConfig.defaultPadding),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          hintText: 'Nhập họ và tên',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập họ và tên';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConfig.defaultPadding),

                      // Age and Role
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Tuổi',
                                hintText: '0',
                                prefixIcon: Icon(Icons.cake),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập tuổi';
                                }
                                final age = int.tryParse(value);
                                if (age == null || age < 0 || age > 120) {
                                  return 'Tuổi không hợp lệ';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppConfig.defaultPadding),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Vai trò',
                                prefixIcon: Icon(Icons.family_restroom),
                              ),
                              items: _roles
                                  .map(
                                    (role) => DropdownMenuItem(
                                      value: role,
                                      child: Text(role),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConfig.largePadding),

                      // Allergies
                      _buildSectionTitle('Dị ứng'),
                      const SizedBox(height: AppConfig.smallPadding + 4),
                      _buildMultiSelectChips(_allergies, _selectedAllergies, (
                        allergy,
                      ) {
                        setState(() {
                          if (_selectedAllergies.contains(allergy)) {
                            _selectedAllergies.remove(allergy);
                          } else {
                            _selectedAllergies.add(allergy);
                          }
                        });
                      }, AppTheme.errorColor),
                      const SizedBox(height: AppConfig.largePadding),

                      // Dietary Restrictions
                      _buildSectionTitle('Hạn chế ăn uống'),
                      const SizedBox(height: AppConfig.smallPadding + 4),
                      _buildMultiSelectChips(
                        _dietaryRestrictions,
                        _selectedDietaryRestrictions,
                        (restriction) {
                          setState(() {
                            if (_selectedDietaryRestrictions.contains(
                              restriction,
                            )) {
                              _selectedDietaryRestrictions.remove(restriction);
                            } else {
                              _selectedDietaryRestrictions.add(restriction);
                            }
                          });
                        },
                        AppTheme.infoColor,
                      ),
                      const SizedBox(height: AppConfig.largePadding),

                      // Health Conditions
                      _buildSectionTitle('Tình trạng sức khỏe'),
                      const SizedBox(height: AppConfig.smallPadding + 4),
                      _buildMultiSelectChips(
                        _healthConditions,
                        _selectedHealthConditions,
                        (condition) {
                          setState(() {
                            if (_selectedHealthConditions.contains(condition)) {
                              _selectedHealthConditions.remove(condition);
                            } else {
                              _selectedHealthConditions.add(condition);
                            }
                          });
                        },
                        AppTheme.warningColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(AppConfig.largePadding - 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppConfig.largePadding - 4),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: AppConfig.smallPadding + 4),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveMember,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Thêm'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildMultiSelectChips(
    List<String> options,
    List<String> selected,
    Function(String) onTap,
    Color color,
  ) {
    return Wrap(
      spacing: AppConfig.smallPadding,
      runSpacing: AppConfig.smallPadding,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return GestureDetector(
          onTap: () => onTap(option),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConfig.smallPadding + 4,
              vertical: AppConfig.smallPadding,
            ),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppConfig.largePadding - 4),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Icon(Icons.check, size: 16, color: color)
                else
                  Icon(Icons.add, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: AppConfig.smallPadding / 2),
                Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? color : Colors.grey.shade700,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _saveMember() {
    if (_formKey.currentState!.validate()) {
      final member = FamilyMember(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        role: _selectedRole,
        allergies: _selectedAllergies,
        dietaryRestrictions: _selectedDietaryRestrictions,
        healthConditions: _selectedHealthConditions,
      );

      widget.onSave(member);
      Navigator.pop(context);
    }
  }
}
