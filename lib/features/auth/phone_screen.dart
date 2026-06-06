import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import 'otp_screen.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _requestOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() => _error = 'Enter a valid phone number');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final result = await AuthService.requestOTP(phone);
      if (!mounted) return;

      // In dev, show the code
      final devCode = result['devCode'];

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OTPScreen(phone: phone, devCode: devCode),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString().contains('No account found')
            ? 'No account found. Contact 可组合业务咨询 IT Consult.'
            : 'Failed to send OTP. Check your connection.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Composables ',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: 'IT',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Installment Tracker',
                style: TextStyle(fontSize: 13, color: AppTheme.textTertiary),
              ),

              const SizedBox(height: 56),

              // Welcome text
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your registered phone number to access your installment account.',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
              ),

              const SizedBox(height: 36),

              // Phone input
              const Text(
                'Phone Number',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                style: const TextStyle(fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: '0244 123 456',
                  counterText: '',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('🇬🇭', style: TextStyle(fontSize: 20)),
                  ),
                  errorText: _error,
                ),
                onChanged: (_) => setState(() => _error = null),
                onFieldSubmitted: (_) => _requestOTP(),
              ),

              const SizedBox(height: 24),

              // Send OTP button
              ElevatedButton(
                onPressed: _loading ? null : _requestOTP,
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Send Verification Code'),
              ),

              const SizedBox(height: 32),

              // Support
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 13, color: AppTheme.textTertiary),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {}, // launch phone call
                      child: const Text(
                        'Call 0540571511',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
