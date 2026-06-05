import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String? devCode; // Only in development

  const OTPScreen({super.key, required this.phone, this.devCode});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _pinController = TextEditingController();
  bool _loading = false;
  String? _error;
  int _resendSeconds = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto-fill in dev mode
    if (widget.devCode != null) {
      _pinController.setText(widget.devCode!);
    }
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
        _startResendTimer();
      }
    });
  }

  Future<void> _verify(String code) async {
    if (code.length < 6) return;
    setState(() { _loading = true; _error = null; });

    try {
      final client = await AuthService.verifyOTP(widget.phone, code);
      if (!mounted) return;
      if (client != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        setState(() => _error = 'Invalid code. Please try again.');
      }
    } catch (e) {
      setState(() => _error = 'Invalid or expired code. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    await AuthService.requestOTP(widget.phone);
    setState(() => _resendSeconds = 60);
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: AppTheme.bg700,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppTheme.blue, width: 1.5),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppTheme.blue.withOpacity(0.1),
        border: Border.all(color: AppTheme.blue.withOpacity(0.5)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              Text('Check your SMS', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to ${widget.phone.replaceRange(4, 7, '***')}',
                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
              ),

              // Dev mode hint
              if (widget.devCode != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.amber.withOpacity(0.3)),
                  ),
                  child: Text(
                    '🛠 Dev mode — code: ${widget.devCode}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.amber),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // PIN input
              Center(
                child: Pinput(
                  controller: _pinController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  onCompleted: _verify,
                  keyboardType: TextInputType.number,
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppTheme.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Verify button
              ElevatedButton(
                onPressed: _loading ? null : () => _verify(_pinController.text),
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Verify Code'),
              ),

              const SizedBox(height: 24),

              // Resend
              Center(
                child: _resendSeconds > 0
                    ? Text(
                        'Resend code in ${_resendSeconds}s',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary),
                      )
                    : GestureDetector(
                        onTap: _resend,
                        child: const Text(
                          'Resend code',
                          style: TextStyle(fontSize: 13, color: AppTheme.blue, fontWeight: FontWeight.w600),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
