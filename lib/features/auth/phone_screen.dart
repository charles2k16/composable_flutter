import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import 'pin_screen.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _continue() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() => _error = 'Enter a valid phone number');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await AuthService.checkPhone(phone);
      if (!mounted) return;

      final hasPin = result['hasPin'] == true;
      final name = result['name'] as String?;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PinScreen(
            phone: phone,
            clientName: name,
            mode: hasPin ? PinMode.login : PinMode.setup,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString().contains('No account found')
            ? 'No account found. Contact Composables IT Consult.'
            : 'Could not verify phone. Check your connection.';
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
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your registered phone number to access your installment account.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                ),
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
                onFieldSubmitted: (_) => _continue(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _continue,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue'),
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 13, color: AppTheme.textTertiary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Call 0540571511',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.blue,
                        fontWeight: FontWeight.w600,
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
