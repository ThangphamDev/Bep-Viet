import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/presentation/features/premium/pages/family_profile_page.dart';

class EditMemberDialog extends StatefulWidget {
  final FamilyMember member;
  final Function(FamilyMember) onSave;

  const EditMemberDialog({
    super.key,
    required this.member,
    required this.onSave,
  });

  @override
  State<EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends State<EditMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _customAllergiesController;
  late final TextEditingController _customDietaryRestrictionsController;
  late final TextEditingController _customHealthConditionsController;
  String _selectedRole = 'Bố';
  late final List<String> _selectedAllergies;
  late final List<String> _selectedDietaryRestrictions;
  late final List<String> _selectedHealthConditions;

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
  void initState() {
    super.initState();
    // Initialize with existing member data
    _nameController = TextEditingController(text: widget.member.name);
    _ageController = TextEditingController(text: widget.member.age.toString());
    _customAllergiesController = TextEditingController(
      text: widget.member.customAllergies,
    );
    _customDietaryRestrictionsController = TextEditingController(
      text: widget.member.customDietaryRestrictions,
    );
    _customHealthConditionsController = TextEditingController(
      text: widget.member.customHealthConditions,
    );

    // Initialize selected role and lists with existing data
    _selectedRole = _roles.contains(widget.member.role)
        ? widget.member.role
        : 'Bố';
    _selectedAllergies = List.from(widget.member.allergies);
    _selectedDietaryRestrictions = List.from(widget.member.dietaryRestrictions);
    _selectedHealthConditions = List.from(widget.member.healthConditions);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _customAllergiesController.dispose();
    _customDietaryRestrictionsController.dispose();
    _customHealthConditionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Chỉnh sửa thành viên',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppConfig.defaultPadding),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên thành viên *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên thành viên';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConfig.defaultPadding),

                      // Age field
                      TextFormField(
                        controller: _ageController,
                        decoration: const InputDecoration(
                          labelText: 'Tuổi *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tuổi';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age < 0 || age > 120) {
                            return 'Tuổi không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConfig.defaultPadding),

                      // Role dropdown
                      DropdownButtonFormField<String>(
                        value: _roles.contains(_selectedRole)
                            ? _selectedRole
                            : _roles.first,
                        decoration: const InputDecoration(
                          labelText: 'Vai trò trong gia đình',
                          border: OutlineInputBorder(),
                        ),
                        items: _roles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                      const SizedBox(height: AppConfig.defaultPadding),

                      // Allergies section
                      _buildSectionTitle('Dị ứng thực phẩm'),
                      const SizedBox(height: AppConfig.smallPadding),
                      _buildChipSection(
                        _allergies,
                        _selectedAllergies,
                        AppTheme.errorColor,
                      ),
                      const SizedBox(height: AppConfig.smallPadding),
                      TextFormField(
                        controller: _customAllergiesController,
                        decoration: const InputDecoration(
                          labelText: 'Dị ứng khác (nếu có)',
                          hintText: 'Nhập các dị ứng khác...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppConfig.defaultPadding),

                      // Dietary restrictions section
                      _buildSectionTitle('Chế độ ăn đặc biệt'),
                      const SizedBox(height: AppConfig.smallPadding),
                      _buildChipSection(
                        _dietaryRestrictions,
                        _selectedDietaryRestrictions,
                        AppTheme.primaryGreen,
                      ),
                      const SizedBox(height: AppConfig.smallPadding),
                      TextFormField(
                        controller: _customDietaryRestrictionsController,
                        decoration: const InputDecoration(
                          labelText: 'Chế độ ăn khác (nếu có)',
                          hintText: 'Nhập chế độ ăn đặc biệt khác...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppConfig.defaultPadding),

                      // Health conditions section
                      _buildSectionTitle('Tình trạng sức khỏe'),
                      const SizedBox(height: AppConfig.smallPadding),
                      _buildChipSection(
                        _healthConditions,
                        _selectedHealthConditions,
                        AppTheme.warningColor,
                      ),
                      const SizedBox(height: AppConfig.smallPadding),
                      TextFormField(
                        controller: _customHealthConditionsController,
                        decoration: const InputDecoration(
                          labelText: 'Tình trạng sức khỏe khác (nếu có)',
                          hintText: 'Nhập tình trạng sức khỏe đặc biệt...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            const SizedBox(height: AppConfig.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: AppConfig.defaultPadding),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveMember,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Lưu thay đổi'),
                  ),
                ),
              ],
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

  Widget _buildChipSection(
    List<String> items,
    List<String> selectedItems,
    Color color,
  ) {
    return _buildMultiSelectChips(items, selectedItems, (item) {
      setState(() {
        if (selectedItems.contains(item)) {
          selectedItems.remove(item);
        } else {
          selectedItems.add(item);
        }
      });
    }, color);
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
      // Combine selected and custom items
      final allAllergies = List<String>.from(_selectedAllergies);
      if (_customAllergiesController.text.trim().isNotEmpty) {
        allAllergies.addAll(
          _customAllergiesController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
      }

      final allDietaryRestrictions = List<String>.from(
        _selectedDietaryRestrictions,
      );
      if (_customDietaryRestrictionsController.text.trim().isNotEmpty) {
        allDietaryRestrictions.addAll(
          _customDietaryRestrictionsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
      }

      final updatedMember = FamilyMember(
        id: widget.member.id,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        role: _selectedRole,
        allergies: allAllergies,
        dietaryRestrictions: allDietaryRestrictions,
        healthConditions: _selectedHealthConditions,
        customAllergies: _customAllergiesController.text.trim(),
        customDietaryRestrictions: _customDietaryRestrictionsController.text
            .trim(),
        customHealthConditions: _customHealthConditionsController.text.trim(),
      );

      widget.onSave(updatedMember);
      Navigator.pop(context);
    }
  }
}
