import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

enum PinMode { setup, login }

class PinScreen extends StatefulWidget {
  final String phone;
  final String? clientName;
  final PinMode mode;

  const PinScreen({
    super.key,
    required this.phone,
    required this.mode,
    this.clientName,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _confirmStep = false;

  Future<void> _submitPin(String pin) async {
    if (pin.length < 5) return;

    if (widget.mode == PinMode.setup && !_confirmStep) {
      setState(() {
        _confirmStep = true;
        _error = null;
      });
      return;
    }

    if (widget.mode == PinMode.setup) {
      if (pin != _pinController.text) {
        setState(() {
          _error = 'PINs do not match. Try again.';
          _confirmStep = false;
          _confirmController.clear();
        });
        return;
      }
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = widget.mode == PinMode.setup
          ? await AuthService.setupPin(widget.phone, pin)
          : await AuthService.loginWithPin(widget.phone, pin);

      if (!mounted) return;
      if (client != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        setState(() => _error = 'Sign in failed. Please try again.');
      }
    } catch (e) {
      setState(() {
        _error = widget.mode == PinMode.setup
            ? 'Could not set PIN. Please try again.'
            : 'Invalid PIN. Please try again.';
      });
      if (widget.mode == PinMode.setup) {
        _confirmStep = false;
        _confirmController.clear();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  PinTheme _pinTheme({bool focused = false, bool submitted = false}) {
    var decoration = BoxDecoration(
      color: submitted ? AppTheme.blue.withOpacity(0.1) : AppTheme.bg700,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: focused
            ? AppTheme.blue
            : submitted
                ? AppTheme.blue.withOpacity(0.5)
                : AppTheme.border,
        width: focused ? 1.5 : 1,
      ),
    );

    return PinTheme(
      width: 52,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      decoration: decoration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSetup = widget.mode == PinMode.setup;
    final title = isSetup
        ? (_confirmStep ? 'Confirm your PIN' : 'Create your PIN')
        : 'Enter your PIN';
    final subtitle = isSetup
        ? (_confirmStep
            ? 'Enter the same 5-digit PIN again to confirm.'
            : 'Set a 5-digit PIN to secure your account.')
        : widget.clientName != null
            ? 'Welcome back, ${widget.clientName}. Enter your 5-digit PIN.'
            : 'Enter your 5-digit PIN to continue.';

    final controller = _confirmStep ? _confirmController : _pinController;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            if (_confirmStep) {
              setState(() {
                _confirmStep = false;
                _confirmController.clear();
                _error = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(title, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Pinput(
                  controller: controller,
                  length: 5,
                  defaultPinTheme: _pinTheme(),
                  focusedPinTheme: _pinTheme(focused: true),
                  submittedPinTheme: _pinTheme(submitted: true),
                  onCompleted: _submitPin,
                  keyboardType: TextInputType.number,
                  obscureText: true,
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
              ElevatedButton(
                onPressed: _loading ? null : () => _submitPin(controller.text),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isSetup
                        ? (_confirmStep ? 'Confirm PIN' : 'Continue')
                        : 'Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
