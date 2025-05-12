// lib/authentication/job_seeker/widgets/otp_verification_popup.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/utils/form_validation.dart';
import 'package:kozi/authentication/job_seeker/providers/auth_provider.dart';

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
  final List<bool> _hasError = List.generate(6, (_) => false);

  Timer? _timer;
  int _timeLeft = 180; // 3 minutes in seconds
  String? _errorMessage;
  bool _isVerifying = false;
  bool _isResending = false;

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
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  bool _validateOtp() {
    bool isValid = true;
    
    // Check if all digits are filled
    for (int i = 0; i < 6; i++) {
      if (_controllers[i].text.isEmpty) {
        setState(() {
          _hasError[i] = true;
        });
        isValid = false;
      } else {
        setState(() {
          _hasError[i] = false;
        });
      }
    }
    
    if (!isValid) {
      setState(() {
        _errorMessage = 'Please enter the complete 6-digit code';
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }
    
    return isValid;
  }

  Future<void> _verifyOtp() async {
    // Validate OTP first
    if (!_validateOtp()) {
      return;
    }
    
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });
    
    try {
      String otp = _controllers.map((controller) => controller.text).join();
      
      // Call the onVerified callback and wait for error (if any)
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
            
            // Reset error state for all fields
            for (int i = 0; i < _hasError.length; i++) {
              _hasError[i] = false;
            }
          });
        }
        // If no error message is returned, the dialog will be closed by the parent
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorMessage = 'Error verifying OTP: $e';
          
          // Reset fields for retry on error
          for (var controller in _controllers) {
            controller.clear();
          }
          if (_focusNodes.isNotEmpty) {
            _focusNodes[0].requestFocus();
          }
        });
      }
    }
  }

  Future<void> _requestNewCode() async {
    // Only allow requesting a new code if timer has expired
    if (_timeLeft > 0) {
      return;
    }
    
    setState(() {
      _isResending = true;
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
        });
        _startTimer();
        
        // Clear all fields
        for (var controller in _controllers) {
          controller.clear();
        }
        
        // Reset error states
        for (int i = 0; i < _hasError.length; i++) {
          _hasError[i] = false;
        }
        
        // Set focus to first field
        if (_focusNodes.isNotEmpty) {
          _focusNodes[0].requestFocus();
        }
        
        // Show a snackbar to confirm
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A new verification code has been sent.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to request new code.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error requesting new code: $e';
      });
    } finally {
      setState(() {
        _isResending = false;
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
                'OTP Verification',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please enter the verification code sent to ${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

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
                            borderSide: BorderSide(
                              color: _hasError[index] 
                                  ? ValidationColors.errorRed
                                  : Colors.grey[300]!,
                              width: _hasError[index] ? 2.0 : 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _hasError[index]
                                  ? ValidationColors.errorRed
                                  : const Color(0xFFEA60A7),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: _hasError[index]
                              ? ValidationColors.errorRedLight
                              : Colors.white,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          // Clear error state when user types
                          if (_hasError[index]) {
                            setState(() {
                              _hasError[index] = false;
                              _errorMessage = null;
                            });
                          }
                          
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }

                          // Auto-verify if all fields are filled
                          if (index == 5 && value.isNotEmpty) {
                            bool allFilled = true;
                            for (var controller in _controllers) {
                              if (controller.text.isEmpty) {
                                allFilled = false;
                                break;
                              }
                            }
                            
                            if (allFilled) {
                              _verifyOtp();
                            }
                          }
                        },
                      ),
                    ),
                  ),
                );
              }),

              // Error message if any
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ValidationColors.errorRedLight,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: ValidationColors.errorRedBorder,
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: ValidationColors.errorRed,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

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
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                      'Verify',
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
                'Code expires in: ${_formatTimeLeft()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 8),

              // Request another code - conditionally clickable
              GestureDetector(
                onTap: (_timeLeft <= 0 && !_isResending) ? _requestNewCode : null,
                child: _isResending
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEA60A7)),
                      ),
                    )
                  : Text(
                    'Request another verification code',
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