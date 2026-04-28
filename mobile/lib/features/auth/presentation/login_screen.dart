import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import 'session_controller.dart';

enum AuthMode { login, register }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthMode _mode = AuthMode.login;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final isRegister = _mode == AuthMode.register;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BrandHeader(),
                    const SizedBox(height: 32),
                    SegmentedButton<AuthMode>(
                      segments: const [
                        ButtonSegment(
                          value: AuthMode.login,
                          icon: Icon(Icons.login_rounded),
                          label: Text('Giriş'),
                        ),
                        ButtonSegment(
                          value: AuthMode.register,
                          icon: Icon(Icons.person_add_alt_1_rounded),
                          label: Text('Kayıt'),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: session.isBusy
                          ? null
                          : (selection) => setState(() => _mode = selection.first),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                        labelText: 'Kullanıcı adı',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 3) {
                          return 'En az 3 karakter girin.';
                        }
                        return null;
                      },
                    ),
                    if (isRegister) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                          labelText: 'E-posta',
                        ),
                        validator: (value) {
                          if (!isRegister) return null;
                          final email = value?.trim() ?? '';
                          if (!email.contains('@') || !email.contains('.')) {
                            return 'Geçerli bir e-posta girin.';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                        labelText: 'Şifre',
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'En az 6 karakter girin.';
                        }
                        return null;
                      },
                    ),
                    if (session.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _ErrorBanner(message: session.errorMessage!),
                    ],
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: session.isBusy ? null : _submit,
                      icon: session.isBusy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(isRegister ? Icons.person_add_alt_1 : Icons.login),
                      label: Text(isRegister ? 'Hesap oluştur' : 'Giriş yap'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final session = context.read<SessionController>();
    try {
      if (_mode == AuthMode.login) {
        await session.login(
          username: _usernameController.text,
          password: _passwordController.text,
        );
      } else {
        await session.register(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    } catch (_) {
      if (!mounted) return;
      FocusScope.of(context).unfocus();
    }
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.explore_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Rehberly',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppTheme.text,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Rotaları keşfet, kaydet ve gezgin rütbeni yükselt.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.mutedText,
              ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.24),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
