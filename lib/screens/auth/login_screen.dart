import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../utils/session.dart';
import 'register_screen.dart';
import '../main_screen.dart';

// ── Màu sắc theo Stitch design token ────────────────────────
class _AppColors {
  static const primary                 = Color(0xFF1B6969);
  static const surface                 = Color(0xFFF6FAF9);
  static const surfaceContainerHighest = Color(0xFFD9E5E4);
  static const surfaceContainerHigh    = Color(0xFFE1EAE9);
  static const onSurface               = Color(0xFF2A3434);
  static const onSurfaceVariant        = Color(0xFF566161);
  static const secondary               = Color(0xFF4A6463);
  static const outline                 = Color(0xFF727D7C);
  static const outlineVariant          = Color(0xFFA9B4B3);
  static const primaryContainer        = Color(0xFFA8EFEE);
  static const secondaryContainer      = Color(0xFFCCE8E7);
}

// ════════════════════════════════════════════════════════════
// Màn hình Đăng nhập
// ════════════════════════════════════════════════════════════
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 768;
          return isWide ? const _WideLayout() : const _NarrowLayout();
        },
      ),
    );
  }
}

// ── Layout rộng (tablet/desktop): 2 cột ─────────────────────
class _WideLayout extends StatelessWidget {
  const _WideLayout();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _LeftPanel()),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: const _LoginForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Layout hẹp (điện thoại): 1 cột ─────────────────────────
class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 16),
            Text(
              'Đăng nhập',
              style: TextStyle(
                color: _AppColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 32),
            _LoginForm(),
          ],
        ),
      ),
    );
  }
}

// ── Panel trái ───────────────────────────────────────────────
class _LeftPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE7F0EF),
      child: Stack(
        children: [
          Positioned(
            bottom: -96, left: -96,
            child: Container(
              width: 384, height: 384,
              decoration: BoxDecoration(
                color: _AppColors.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -96, right: -96,
            child: Container(
              width: 256, height: 256,
              decoration: BoxDecoration(
                color: _AppColors.secondaryContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nơi ẩn náu \nTài chính của bạn.',
                  style: TextStyle(
                    color: _AppColors.primary,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Trải nghiệm sự an tâm từ việc quản lý tài chính rõ ràng. '
                  'Theo dõi tài sản tăng trưởng trong một không gian được thiết kế cho sự bình yên trong tâm trí.',
                  style: TextStyle(
                    color: _AppColors.secondary,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _AppColors.primary.withValues(alpha: 0.15),
                          _AppColors.primaryContainer.withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 80,
                        color: _AppColors.primary,
                      ),
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
// Form đăng nhập
// ════════════════════════════════════════════════════════════
class _LoginForm extends StatefulWidget {
  const _LoginForm();
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
    final regex = RegExp(r'^[\w.+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(v.trim())) return 'Email không đúng định dạng';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final user = await DBHelper.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    setState(() => _loading = false);
    if (!mounted) return;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email hoặc mật khẩu không đúng'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    await Session.save(user.id!);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chào mừng trở lại',
            style: TextStyle(
              color: _AppColors.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhập thông tin của bạn để truy cập bảng điều khiển.',
            style: TextStyle(color: _AppColors.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 40),

          // Email
          const _FieldLabel('ĐỊA CHỈ EMAIL'),
          const SizedBox(height: 8),
          _StitchTextField(
            controller: _emailCtrl,
            hint: 'name@example.com',
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 24),

          // Mật khẩu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _FieldLabel('MẬT KHẨU'),
              Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  color: _AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _StitchTextField(
            controller: _passwordCtrl,
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscure,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(
                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: _AppColors.outline,
                size: 20,
              ),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 32),

          // Nút đăng nhập
          SizedBox(
            width: double.infinity,
            height: 56,
            child: _GradientButton(
              label: 'Đăng nhập',
              onPressed: _loading ? null : _login,
              loading: _loading,
            ),
          ),
          const SizedBox(height: 48),

          // Footer
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Chưa có tài khoản? ',
                  style: TextStyle(color: _AppColors.onSurfaceVariant, fontSize: 14),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text(
                    'Đăng ký ngay',
                    style: TextStyle(
                      color: _AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: _AppColors.primary,
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
// Shared UI widgets
// ════════════════════════════════════════════════════════════

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _AppColors.secondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _StitchTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _StitchTextField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  State<_StitchTextField> createState() => _StitchTextFieldState();
}

class _StitchTextFieldState extends State<_StitchTextField> {
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
      style: const TextStyle(color: _AppColors.onSurface, fontSize: 15),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: _AppColors.outlineVariant),
        filled: true,
        fillColor: _focused
            ? _AppColors.surfaceContainerHigh
            : _AppColors.surfaceContainerHighest,
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
          borderSide: const BorderSide(color: _AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        prefixIcon: Icon(widget.prefixIcon, color: _AppColors.outline, size: 20),
        suffixIcon: widget.suffixIcon,
        errorStyle: const TextStyle(fontSize: 12, height: 1.4),
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
            color: isDisabled ? _AppColors.outlineVariant : null,
            borderRadius: BorderRadius.circular(999),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: _AppColors.primary.withValues(alpha: 0.25),
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
