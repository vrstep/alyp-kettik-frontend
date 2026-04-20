import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = Get.find<AuthController>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  bool _showCurrentPw = false;
  bool _showNewPw = false;
  bool _showConfirmPw = false;

  @override
  void initState() {
    super.initState();
    final user = _auth.user.value;
    _nameCtrl = TextEditingController(text: user?['name'] as String? ?? '');
    _emailCtrl = TextEditingController(text: user?['email'] as String? ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final currentUser = _auth.user.value;
    final newName = _nameCtrl.text.trim();
    final newEmail = _emailCtrl.text.trim();

    if (newName.isEmpty) {
      Get.snackbar('Error', 'Name cannot be empty');
      return;
    }
    if (newEmail.isEmpty) {
      Get.snackbar('Error', 'Email cannot be empty');
      return;
    }

    // Only send fields that actually changed
    String? nameToSend =
        newName != (currentUser?['name'] as String? ?? '') ? newName : null;
    String? emailToSend =
        newEmail != (currentUser?['email'] as String? ?? '') ? newEmail : null;

    if (nameToSend == null && emailToSend == null) {
      Get.snackbar('Info', 'No changes to save',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12));
      return;
    }

    await _auth.updateProfile(name: nameToSend, email: emailToSend);
  }

  Future<void> _changePassword() async {
    final currentPw = _currentPwCtrl.text;
    final newPw = _newPwCtrl.text;
    final confirmPw = _confirmPwCtrl.text;

    if (currentPw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      Get.snackbar('Error', 'Please fill in all password fields');
      return;
    }
    if (newPw.length < 6) {
      Get.snackbar('Error', 'New password must be at least 6 characters');
      return;
    }
    if (newPw != confirmPw) {
      Get.snackbar('Error', 'New passwords do not match');
      return;
    }

    final success = await _auth.changePassword(currentPw, newPw);
    if (success) {
      _currentPwCtrl.clear();
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Obx(() {
        final loading = _auth.isLoading.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile Info Section ──
              _sectionHeader('Personal Information'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameCtrl,
                label: 'Full Name',
                icon: Icons.person_outline_rounded,
                enabled: !loading,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: !loading,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : _saveProfile,
                  icon: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    loading ? 'Saving...' : 'Save Changes',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 36),
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 20),

              // ── Change Password Section ──
              _sectionHeader('Change Password'),
              const SizedBox(height: 12),
              _buildPasswordField(
                controller: _currentPwCtrl,
                label: 'Current Password',
                visible: _showCurrentPw,
                onToggle: () =>
                    setState(() => _showCurrentPw = !_showCurrentPw),
                enabled: !loading,
              ),
              const SizedBox(height: 14),
              _buildPasswordField(
                controller: _newPwCtrl,
                label: 'New Password',
                visible: _showNewPw,
                onToggle: () => setState(() => _showNewPw = !_showNewPw),
                enabled: !loading,
              ),
              const SizedBox(height: 14),
              _buildPasswordField(
                controller: _confirmPwCtrl,
                label: 'Confirm New Password',
                visible: _showConfirmPw,
                onToggle: () =>
                    setState(() => _showConfirmPw = !_showConfirmPw),
                enabled: !loading,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: loading ? null : _changePassword,
                  icon: Icon(Icons.lock_outline_rounded,
                      color: Colors.orange.shade700),
                  label: Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.orange.shade300, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(Icons.lock_outline_rounded, color: Colors.orange.shade400),
        suffixIcon: IconButton(
          icon: Icon(
            visible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey.shade500,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
