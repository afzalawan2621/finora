import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/user_status.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/responsive_repo.dart';
import '../../widgets/accounts/credentials_dialog.dart';
import '../../widgets/auth/app_email_field.dart';
import '../../widgets/auth/app_name_field.dart';
import '../../widgets/auth/app_password_field.dart';
import '../../widgets/auth/app_phone_field.dart';
import '../../widgets/common/app_text_widget.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.manager;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateUser() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final newUser = await auth.createUser(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (newUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(
            auth.error ?? 'Failed to create user',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Success — show credentials dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CredentialsDialog(
        fullName: newUser.fullName,
        email: newUser.email,
        password: _passwordController.text,
        role: _selectedRole.name.toUpperCase(),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveRepo(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const AppText(
          'Create User',
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: r.horizontalPadding,
          vertical: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Role selector ───
              const AppText(
                'Select Role',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 1.2,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _roleChip(
                      role: UserRole.manager,
                      icon: Icons.supervisor_account_rounded,
                      label: 'Manager',
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _roleChip(
                      role: UserRole.user,
                      icon: Icons.person_rounded,
                      label: 'User',
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ─── Form ───
              AppNameField(
                label: 'Full Name',
                hint: 'e.g. Ahmed Khan',
                controller: _nameController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Name required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AppEmailField(
                label: 'Email',
                hint: 'user@example.com',
                controller: _emailController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email required';
                  final regex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!regex.hasMatch(v.trim())) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AppPhoneField(
                label: 'Phone',
                hint: '+92 300 1234567',
                controller: _phoneController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone required';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AppPasswordField(
                label: 'Password',
                hint: '••••••••',
                controller: _passwordController,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password required';
                  if (v.length < 6) return 'Minimum 6 characters';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppText(
                        _selectedRole == UserRole.manager
                            ? 'Manager can add data but cannot edit or delete.'
                            : 'User can add data but cannot edit or delete.',
                        fontSize: 11.5,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Create button
              GestureDetector(
                onTap: _isLoading ? null : _handleCreateUser,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        AppText(
                          'Create User',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleChip({
    required UserRole role,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.5)
                : AppColors.inputBorder.withOpacity(0.6),
            width: isSelected ? 1.5 : 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 6),
            AppText(
              label,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isSelected ? color : AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}