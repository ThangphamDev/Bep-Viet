import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/user_model.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';

class EditProfileDialog extends StatefulWidget {
  final UserModel user;

  const EditProfileDialog({super.key, required this.user});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedRegion;
  late String _selectedSubregion;

  final List<String> _regions = ['BAC', 'TRUNG', 'NAM'];
  final Map<String, List<String>> _subregions = {
    'BAC': [
      'Hà Nội',
      'Hải Phòng',
      'Quảng Ninh',
      'Lào Cai',
      'Điện Biên',
      'Lai Châu',
      'Sơn La',
      'Yên Bái',
      'Tuyên Quang',
      'Hà Giang',
      'Cao Bằng',
      'Bắc Kạn',
      'Thái Nguyên',
      'Lạng Sơn',
      'Bắc Giang',
      'Phú Thọ',
      'Vĩnh Phúc',
      'Bắc Ninh',
      'Hải Dương',
      'Hưng Yên',
      'Thái Bình',
      'Hà Nam',
      'Nam Định',
      'Ninh Bình',
    ],
    'TRUNG': [
      'Thanh Hóa',
      'Nghệ An',
      'Hà Tĩnh',
      'Quảng Bình',
      'Quảng Trị',
      'Thừa Thiên Huế',
      'Đà Nẵng',
      'Quảng Nam',
      'Quảng Ngãi',
      'Bình Định',
      'Phú Yên',
      'Khánh Hòa',
      'Ninh Thuận',
      'Bình Thuận',
      'Kon Tum',
      'Gia Lai',
      'Đắk Lắk',
      'Đắk Nông',
      'Lâm Đồng',
    ],
    'NAM': [
      'TP. Hồ Chí Minh',
      'Bà Rịa - Vũng Tàu',
      'Bình Dương',
      'Bình Phước',
      'Đồng Nai',
      'Tây Ninh',
      'Long An',
      'Đồng Tháp',
      'Tiền Giang',
      'An Giang',
      'Bến Tre',
      'Vĩnh Long',
      'Trà Vinh',
      'Hậu Giang',
      'Kiên Giang',
      'Sóc Trăng',
      'Bạc Liêu',
      'Cà Mau',
      'Cần Thơ',
    ],
  };

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _selectedRegion = widget.user.region ?? 'BAC';
    _selectedSubregion =
        widget.user.subregion ?? _subregions[_selectedRegion]!.first;

    // Ensure subregion is valid for the selected region
    if (!_subregions[_selectedRegion]!.contains(_selectedSubregion)) {
      _selectedSubregion = _subregions[_selectedRegion]!.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chỉnh sửa thông tin',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      Text(
                        'Cập nhật thông tin cá nhân của bạn',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name field
                      Text(
                        'Họ và tên *',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Nhập họ và tên của bạn',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: AppTheme.primaryGreen,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryGreen,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập họ và tên';
                          }
                          if (value.trim().length < 2) {
                            return 'Tên phải có ít nhất 2 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email field (read-only)
                      Text(
                        'Email',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: widget.user.email,
                        enabled: false,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.grey.shade400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),

                      // Region dropdown
                      Text(
                        'Vùng miền *',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedRegion,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                            color: AppTheme.primaryGreen,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryGreen,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: _regions.map((region) {
                          String displayName;
                          switch (region) {
                            case 'BAC':
                              displayName = 'Miền Bắc';
                              break;
                            case 'TRUNG':
                              displayName = 'Miền Trung';
                              break;
                            case 'NAM':
                              displayName = 'Miền Nam';
                              break;
                            default:
                              displayName = region;
                          }
                          return DropdownMenuItem(
                            value: region,
                            child: Text(displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRegion = value!;
                            _selectedSubregion =
                                _subregions[_selectedRegion]!.first;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Subregion dropdown
                      Text(
                        'Tỉnh/Thành phố *',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedSubregion,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.place_outlined,
                            color: AppTheme.primaryGreen,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryGreen,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: _subregions[_selectedRegion]!.map((subregion) {
                          return DropdownMenuItem(
                            value: subregion,
                            child: Text(subregion),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubregion = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Lưu thay đổi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call update profile API through AuthCubit
      await context.read<AuthCubit>().updateProfile(
        name: _nameController.text.trim(),
        region: _selectedRegion,
        subregion: _selectedSubregion,
      );

      if (mounted) {
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Cập nhật thông tin thành công!'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Lỗi: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
