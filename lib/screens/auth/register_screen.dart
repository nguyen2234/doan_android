import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/user.dart';

// ── Màu sắc theo Stitch design token ────────────────────────
class _C {
  static const primary                 = Color(0xFF1B6969);
  static const surface                 = Color(0xFFF6FAF9);
  static const surfaceContainerLowest  = Color(0xFFFFFFFF);
  static const surfaceContainerLow     = Color(0xFFEEF5F4);
  static const surfaceContainerHighest = Color(0xFFD9E5E4);
  static const surfaceContainerHigh    = Color(0xFFE1EAE9);
  static const onSurface               = Color(0xFF2A3434);
  static const onSurfaceVariant        = Color(0xFF566161);
  static const outline                 = Color(0xFF727D7C);
  static const outlineVariant          = Color(0xFFA9B4B3);
  static const secondary               = Color(0xFF4A6463);
  static const primaryContainer        = Color(0xFFA8EFEE);
  static const secondaryContainer      = Color(0xFFCCE8E7);
  static const error                   = Color(0xFFA83836);
}

// ════════════════════════════════════════════════════════════
// Màn hình Đăng ký
// ════════════════════════════════════════════════════════════
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _nameCtrl         = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _passwordCtrl     = TextEditingController();
  final _confirmPassCtrl  = TextEditingController();
  bool _loading           = false;
  bool _obscure           = true;
  bool _obscureConfirm    = true;
  bool _agreedTerms       = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Validators ──────────────────────────────────────────
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập họ tên';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
    final regex = RegExp(r'^[\w.+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(v.trim())) return 'Email không đúng định dạng';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (v.length < 8) return 'Mật khẩu tối thiểu 8 ký tự';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Mật khẩu phải chứa ít nhất 1 chữ số';
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (v != _passwordCtrl.text) return 'Mật khẩu xác nhận không khớp';
    return null;
  }

  // ── Business logic ──────────────────────────────────────
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    // ignore: avoid_print
    print('Validation Passed');

    if (!_agreedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng đồng ý với Điều khoản Dịch vụ'),
          backgroundColor: _C.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final existing = await DBHelper.getUserByEmail(_emailCtrl.text.trim());
    if (existing != null) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email đã được sử dụng'),
          backgroundColor: _C.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final user = User(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      createdAt: DateTime.now().toIso8601String(),
    );
    await DBHelper.insertUser(user);
    setState(() => _loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🎉 Đăng ký thành công! Vui lòng đăng nhập'),
        backgroundColor: _C.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  // ── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 768;
          return isWide ? _buildWideLayout() : _buildNarrowLayout();
        },
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(child: _LeftPanel(onLoginTap: () => Navigator.pop(context))),
        Expanded(
          child: Container(
            color: _C.surfaceContainerLowest,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: _buildForm(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.spa, color: _C.primary, size: 24),
                SizedBox(width: 8),
                Text(
                  'Đăng ký',
                  style: TextStyle(
                    color: _C.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tạo tài khoản',
            style: TextStyle(
              color: _C.onSurface,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bắt đầu hành trình hướng tới sự an tâm tài chính ngay hôm nay.',
            style: TextStyle(color: _C.onSurfaceVariant, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 40),

          // Họ và tên
          const _FieldLabel('HỌ VÀ TÊN'),
          const SizedBox(height: 8),
          _SanctuaryField(
            controller: _nameCtrl,
            hint: 'VD: Nguyễn Văn A',
            prefixIcon: Icons.person_outline,
            validator: _validateName,
          ),
          const SizedBox(height: 24),

          // Email
          const _FieldLabel('ĐỊA CHỈ EMAIL'),
          const SizedBox(height: 8),
          _SanctuaryField(
            controller: _emailCtrl,
            hint: 'name@example.com',
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 24),

          // Mật khẩu
          const _FieldLabel('MẬT KHẨU'),
          const SizedBox(height: 8),
          _SanctuaryField(
            controller: _passwordCtrl,
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscure,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(
                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: _C.outline, size: 20,
              ),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 6),
          const Text(
            'Tối thiểu 8 ký tự và ít nhất 1 chữ số.',
            style: TextStyle(
              color: _C.onSurfaceVariant,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),

          // Xác nhận mật khẩu
          const _FieldLabel('XÁC NHẬN MẬT KHẨU'),
          const SizedBox(height: 8),
          _SanctuaryField(
            controller: _confirmPassCtrl,
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirm,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
              child: Icon(
                _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: _C.outline, size: 20,
              ),
            ),
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 24),

          // Checkbox điều khoản
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20, height: 20,
                child: Checkbox(
                  value: _agreedTerms,
                  activeColor: _C.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: const BorderSide(color: _C.outlineVariant),
                  onChanged: (v) => setState(() => _agreedTerms = v ?? false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _agreedTerms = !_agreedTerms),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: _C.onSurfaceVariant, fontSize: 13, height: 1.5),
                      children: [
                        TextSpan(text: 'Tôi đồng ý với '),
                        TextSpan(
                          text: 'Điều khoản Dịch vụ',
                          style: TextStyle(color: _C.primary, fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: ' và '),
                        TextSpan(
                          text: 'Chính sách Bảo mật',
                          style: TextStyle(color: _C.primary, fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Nút tạo tài khoản
          SizedBox(
            width: double.infinity,
            height: 56,
            child: _GradientButton(
              label: 'Tạo tài khoản',
              onPressed: _loading ? null : _register,
              loading: _loading,
            ),
          ),
          const SizedBox(height: 40),

          // Footer
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Đã có tài khoản? ',
                  style: TextStyle(color: _C.onSurfaceVariant, fontSize: 14),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      color: _C.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: _C.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Panel trái
// ════════════════════════════════════════════════════════════
class _LeftPanel extends StatelessWidget {
  final VoidCallback onLoginTap;
  const _LeftPanel({required this.onLoginTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.surfaceContainerLow,
      child: Stack(
        children: [
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 256, height: 256,
              decoration: BoxDecoration(
                color: _C.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -60, left: -60,
            child: Container(
              width: 192, height: 192,
              decoration: BoxDecoration(
                color: _C.primaryContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.spa, color: _C.primary, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Sanctuary',
                          style: TextStyle(
                            color: _C.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'A calm space for \nyour future growth.',
                      style: TextStyle(
                        color: _C.onSurface,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Join thousands of mindful investors who treat their finances with the care they deserve. No clutter, just clarity.',
                      style: TextStyle(color: _C.onSurfaceVariant, fontSize: 15, height: 1.6),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5, (_) => const Icon(Icons.star, color: Color(0xFFFFB800), size: 18),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: onLoginTap,
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: _C.onSurfaceVariant,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(text: 'Đã có tài khoản? '),
                              TextSpan(
                                text: 'Đăng nhập',
                                style: TextStyle(
                                  color: _C.primary,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: _C.primaryContainer,
                            child: const Icon(Icons.person, color: _C.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Elena Rodriguez',
                                style: TextStyle(
                                  color: _C.onSurface,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'THÀNH VIÊN TỪ 2023',
                                style: TextStyle(
                                  color: _C.onSurfaceVariant,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Shared UI components
// ════════════════════════════════════════════════════════════

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _C.secondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SanctuaryField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _SanctuaryField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  State<_SanctuaryField> createState() => _SanctuaryFieldState();
}

class _SanctuaryFieldState extends State<_SanctuaryField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focus,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: const TextStyle(color: _C.onSurface, fontSize: 15),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: _C.outlineVariant),
        filled: true,
        fillColor: _focused ? _C.surfaceContainerHigh : _C.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _C.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _C.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _C.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        prefixIcon: Icon(widget.prefixIcon, color: _C.outline, size: 20),
        suffixIcon: widget.suffixIcon,
        errorStyle: const TextStyle(color: _C.error, fontSize: 12, height: 1.4),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const _GradientButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    return Material(
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isDisabled
                ? null
                : const LinearGradient(
                    colors: [Color(0xFF1B6969), Color(0xFF005C5C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isDisabled ? _C.outlineVariant : null,
            borderRadius: BorderRadius.circular(999),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: _C.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
