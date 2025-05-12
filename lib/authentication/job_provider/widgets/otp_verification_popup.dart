import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/authentication/job_provider/providers/auth_provider.dart';

class OtpVerificationPopup extends ConsumerStatefulWidget {
  final String email;
  // Changed callback type to return Future<String?> where null means success 
  // and non-null is an error message
  final Future<String?> Function(String) onVerified;

  const OtpVerificationPopup({
    super.key,
    required this.email,
    required this.onVerified,
  });

  @override
  ConsumerState<OtpVerificationPopup> createState() => _OtpVerificationPopupState();
}

class _OtpVerificationPopupState extends ConsumerState<OtpVerificationPopup> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _timeLeft = 180; // 3 minutes in seconds
  bool _isRequestingNewCode = false;
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatTimeLeft() {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')} minutes";
  }

  Future<void> _verifyOtp() async {
    String otp = _controllers.map((controller) => controller.text).join();
    if (otp.length == 6) {
      setState(() {
        _isVerifying = true;
        _errorMessage = null;
      });

      try {
        // Call the onVerified callback with the OTP which now returns a Future<String?>
        // If it returns null, verification was successful
        // If it returns a string, that's an error message
        final errorMessage = await widget.onVerified(otp);
        
        if (mounted) {
          if (errorMessage != null) {
            // Error occurred - show error message and allow retry
            setState(() {
              _isVerifying = false;
              _errorMessage = errorMessage;
              
              // Reset OTP fields to allow retry
              for (var controller in _controllers) {
                controller.clear();
              }
              if (_focusNodes.isNotEmpty) {
                _focusNodes[0].requestFocus();
              }
            });
          }
          // If no error message, the dialog will be closed by the parent
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isVerifying = false;
            _errorMessage = 'Error verifying OTP: $e';
          });
        }
      }
    } else {
      setState(() {
        _errorMessage = 'Please enter the complete 6-digit code.';
      });
    }
  }

  Future<void> _requestNewCode() async {
    if (_timeLeft > 0) return; // Don't allow if timer is still running
    
    setState(() {
      _isRequestingNewCode = true;
      _errorMessage = null;
    });

    try {
      // Use the API service to resend OTP
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.resendOtp(widget.email);

      if (result['success']) {
        // Reset timer
        setState(() {
          _timeLeft = 180;
          _isRequestingNewCode = false;
        });
        _startTimer();

        // Clear all fields
        for (var controller in _controllers) {
          controller.clear();
        }

        // Set focus to first field
        if (_focusNodes.isNotEmpty) {
          _focusNodes[0].requestFocus();
        }

        // Show a snackbar to confirm
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A new verification code has been sent.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _isRequestingNewCode = false;
          _errorMessage = result['message'] ?? 'Failed to resend code';
        });
      }
    } catch (e) {
      setState(() {
        _isRequestingNewCode = false;
        _errorMessage = 'Error requesting new code: $e';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add a close button row at the top
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const Text(
                'OTP verification',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please enter a verification code sent to ${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Error message if any
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),

              // OTP input fields with responsive width
              LayoutBuilder(builder: (context, constraints) {
                double fieldWidth = (constraints.maxWidth - 50) / 6;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: fieldWidth,
                      height: 50,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0xFFEA60A7), width: 2),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            // When deleting, go back
                            _focusNodes[index - 1].requestFocus();
                          }

                          // If all fields are filled, auto-verify
                          if (index == 5 && value.isNotEmpty) {
                            String otp = _controllers
                                .map((controller) => controller.text)
                                .join();
                            if (otp.length == 6) {
                              _verifyOtp();
                            }
                          }

                          // Clear error message when typing
                          if (_errorMessage != null) {
                            setState(() {
                              _errorMessage = null;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA60A7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Timer text
              Text(
                'OTP expires in: ${_formatTimeLeft()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 8),

              // Request another code - now conditionally clickable
              GestureDetector(
                onTap: _isRequestingNewCode || _timeLeft > 0 ? null : _requestNewCode,
                child: _isRequestingNewCode
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEA60A7)),
                        ),
                      )
                    : Text(
                        'Request another verification code?',
                        style: TextStyle(
                          color: _timeLeft <= 0
                              ? const Color(0xFFEA60A7)
                              : Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
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