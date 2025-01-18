// email_user_register.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resmart/widgets/policy_dialogs.dart';
import 'package:resmart/features/login/widgets/email_input_screen.dart';

class RegistrationDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onRegister;
  final String email;
  const RegistrationDialog({
    super.key,
    required this.onRegister,
    required this.email,
  });

  static Future<void> show(BuildContext context, String email,
      Function(Map<String, dynamic>) onRegister) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          DateTime now = DateTime.now();
          if (context.mounted && 
              Navigator.of(context).userGestureInProgress) {
            return false;
          }
          
          if (_lastBackPress == null || 
              now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
            _lastBackPress = now;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Press back again to exit'),
                duration: Duration(seconds: 2),
              ),
            );
            return false;
          }
          return true;
        },
        child: RegistrationDialog(
          onRegister: onRegister,
          email: email,
        ),
      ),
    );
  }

  static DateTime? _lastBackPress;

  @override
  State<RegistrationDialog> createState() => _RegistrationDialogState();
}


class _RegistrationDialogState extends State<RegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _scrollController = ScrollController();


  bool _agreedToTerms = false;
  String? _phoneError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_validateForm);
    _lastNameController.addListener(_validateForm);
    _usernameController.addListener(_validateForm);
  }

  void _validateForm() {
    if (_formKey.currentState != null) {
      _formKey.currentState!.validate();
    }
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_validateForm);
    _lastNameController.removeListener(_validateForm);
    _usernameController.removeListener(_validateForm);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  bool _isFormValid() {
    return _formKey.currentState?.validate() == true &&
        _agreedToTerms &&
        _phoneError == null &&
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _usernameController.text.length > 4;
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate() &&
        _agreedToTerms &&
        _phoneError == null) {
      setState(() => _isLoading = true);


      final userData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'username': _usernameController.text,
        'email': widget.email,
        'createdAt': DateTime.now().toIso8601String(),
      };

      try {
        widget.onRegister(userData);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildEmailField() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Email: ${widget.email}',
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the existing widget
            WidgetsBinding.instance.addPostFrameCallback((_) {
              EmailInputDialog.show(context, (email) {
                debugPrint('Email submitted: $email');
                // Handle email submission
              });
            });
          },
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 2),
          ),
          child: const Text('edit'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? helperText,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isLoading,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildTermsCheckbox() {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: _isLoading
              ? null
              : (value) {
                  setState(() => _agreedToTerms = value!);
                },
        ),
        Expanded(
          child: Wrap(
            children: [
              const Text('I agree to the '),
              InkWell(
                onTap: _isLoading
                    ? null
                    : () => PolicyDialogs.showPrivacyDialog(context),
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: _isLoading
                        ? Theme.of(context).disabledColor
                        : colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text(' and '),
              InkWell(
                onTap: _isLoading
                    ? null
                    : () => PolicyDialogs.showTermsDialog(context),
                child: Text(
                  'Terms and Conditions',
                  style: TextStyle(
                    color: _isLoading
                        ? Theme.of(context).disabledColor
                        : colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: (!_isLoading && _isFormValid()) ? _handleRegister : null,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.primary.withOpacity(0.3);
          }
          return colorScheme.primary;
        }),
        foregroundColor: MaterialStateProperty.all(colorScheme.onPrimary),
        minimumSize: MaterialStateProperty.all(
          const Size(double.infinity, 45),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      child: const Text('Register'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close,
                              color: colorScheme.onSurface),
                          onPressed: () => Navigator.maybePop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Create Your Account',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildEmailField(),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _firstNameController,
                                label: 'First Name',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your first name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _lastNameController,
                                label: 'Last Name',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your last name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _usernameController,
                                label: 'Username',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  if (value.length < 5) {
                                    return 'Username must be at least 5 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              _buildTermsCheckbox(),
                              const SizedBox(height: 24),
                              _buildRegisterButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
