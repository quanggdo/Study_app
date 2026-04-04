import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:student_academic_assistant/core/providers/user_provider.dart';
import 'package:student_academic_assistant/features/auth/viewmodels/auth_viewmodel.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studyTimeController = TextEditingController();
  Uint8List? _selectedImageBytes;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        _nameController.text = user.displayName;
        _studyTimeController.text = user.targetStudyTime.toString();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studyTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Chọn ảnh đại diện',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                title: const Text('Chụp ảnh'),
                subtitle: const Text('Sử dụng camera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                title: const Text('Thư viện ảnh'),
                subtitle: const Text('Chọn từ bộ sưu tập'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final studyTime = int.tryParse(_studyTimeController.text.trim()) ?? 120;

    final success =
        await ref.read(authNotifierProvider.notifier).updateProfile(
              displayName: _nameController.text.trim(),
              targetStudyTime: studyTime,
              photoBytes: _selectedImageBytes,
            );

    if (mounted) {
      if (success) {
        setState(() {
          _isSaving = false;
          _hasChanges = false;
          _selectedImageBytes = null; // Clear local bytes → UI falls back to NetworkImage from provider
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Cập nhật hồ sơ thành công!'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cập nhật thất bại. Vui lòng thử lại.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }


  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Gradient Header with Avatar ──
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              if (_hasChanges)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: _isSaving ? null : _saveProfile,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded, color: Colors.white),
                    label: Text(
                      _isSaving ? 'Đang lưu...' : 'Lưu',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ).animate().fadeIn().slideX(begin: 0.1),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.tertiary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: _buildAvatarContent(user.photoUrl),
                                ),
                              ),
                            ),
                            // Camera badge
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  size: 18,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .scale(begin: const Offset(0.8, 0.8)),
                      const SizedBox(height: 14),
                      Text(
                        user.displayName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Profile Form ──
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section: Personal Info
                        _buildSectionTitle(context, 'Thông tin cá nhân',
                            Icons.person_outline_rounded),

                        const SizedBox(height: 16),

                        // Display Name
                        _buildTextField(
                          controller: _nameController,
                          label: 'Họ và tên',
                          icon: Icons.badge_rounded,
                          onChanged: (_) => _markChanged(),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Vui lòng nhập họ và tên';
                            }
                            if (val.trim().length < 2) {
                              return 'Tên phải có ít nhất 2 ký tự';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),

                        const SizedBox(height: 16),

                        // Email (read-only)
                        _buildTextField(
                          initialValue: user.email,
                          label: 'Email',
                          icon: Icons.email_rounded,
                          readOnly: true,
                          helperText: 'Email không thể thay đổi',
                        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05),

                        const SizedBox(height: 32),

                        // Section: Study Preferences
                        _buildSectionTitle(
                            context, 'Cài đặt học tập', Icons.school_rounded),

                        const SizedBox(height: 16),

                        // Target Study Time
                        _buildTextField(
                          controller: _studyTimeController,
                          label: 'Thời gian học mục tiêu (phút/ngày)',
                          icon: Icons.timer_rounded,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _markChanged(),
                          helperText:
                              'Mặc định: 120 phút. Đặt mục tiêu phù hợp với bạn.',
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Vui lòng nhập thời gian';
                            }
                            final minutes = int.tryParse(val.trim());
                            if (minutes == null || minutes < 10 || minutes > 720) {
                              return 'Thời gian phải từ 10 đến 720 phút';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.05),

                        const SizedBox(height: 32),

                        // Section: Account actions
                        _buildSectionTitle(
                            context, 'Tài khoản', Icons.settings_rounded),

                        const SizedBox(height: 16),

                        // Change Password
                        _buildActionTile(
                          context,
                          icon: Icons.lock_outline_rounded,
                          title: 'Đổi mật khẩu',
                          subtitle: 'Cập nhật mật khẩu bảo mật',
                          onTap: () => context.push('/change-password'),
                          color: colorScheme.primaryContainer,
                          iconColor: colorScheme.onPrimaryContainer,
                        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.05),

                        const SizedBox(height: 12),

                        // Logout
                        _buildActionTile(
                          context,
                          icon: Icons.logout_rounded,
                          title: 'Đăng xuất',
                          subtitle: 'Đăng xuất khỏi tài khoản',
                          onTap: () => _showLogoutDialog(context, ref),
                          color: colorScheme.errorContainer,
                          iconColor: colorScheme.onErrorContainer,
                        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.05),

                        const SizedBox(height: 28),

                        // Save button (bottom)
                        if (_hasChanges)
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton.icon(
                              onPressed: _isSaving ? null : _saveProfile,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save_rounded),
                              label: Text(
                                _isSaving ? 'Đang lưu...' : 'Lưu thay đổi',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──

  Widget _buildAvatarContent(String? photoUrl) {
    // 1. Show locally selected image (preview before save)
    if (_selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    }

    // 2. Show network image from Firebase Storage
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.white.withOpacity(0.2),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white.withOpacity(0.7),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Avatar load error: $error');
          return Container(
            color: Colors.white.withOpacity(0.2),
            child: Icon(
              Icons.person_rounded,
              size: 50,
              color: Colors.white.withOpacity(0.8),
            ),
          );
        },
      );
    }

    // 3. Default icon
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: Icon(
        Icons.person_rounded,
        size: 50,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    required IconData icon,
    bool readOnly = false,
    String? helperText,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(
        color: readOnly
            ? colorScheme.onSurface.withOpacity(0.5)
            : colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperMaxLines: 2,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: readOnly
            ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
            : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: colorScheme.outline.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    required Color iconColor,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).logout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
