import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:resmart/widgets/policy_dialogs.dart';

class RegistrationDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onRegister;

  const RegistrationDialog({super.key, required this.onRegister});

  static Future<void> show(
      BuildContext context, Function(Map<String, dynamic>) onRegister) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit Registration?'),
              content: const Text('Are you sure you want to exit?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        },
        child: RegistrationDialog(onRegister: onRegister),
      ),
    );
  }

  @override
  State<RegistrationDialog> createState() => _RegistrationDialogState();
}

class _RegistrationDialogState extends State<RegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _dateOfBirth;
  bool _agreedToTerms = false;
  final _scrollController = ScrollController();

  void _handleRegister() {
    if (_formKey.currentState!.validate() && _agreedToTerms) {
      final userData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'username': _usernameController.text,
        'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
        'dateOfBirth': _dateOfBirth?.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };
      widget.onRegister(userData);
      Navigator.pop(context);
    }
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
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
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a username';
                              }
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone Number (Optional)',
                              helperText: 'Can be added later',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _showDatePicker,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Date of Birth (Optional)',
                                helperText: 'Can be added later',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                _dateOfBirth != null
                                    ? DateFormat('MMM d, yyyy')
                                        .format(_dateOfBirth!)
                                    : 'Select Date',
                                style: textTheme.bodyLarge,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Checkbox(
                                value: _agreedToTerms,
                                onChanged: (value) {
                                  setState(() => _agreedToTerms = value!);
                                },
                              ),
                              Expanded(
                                child: Wrap(
                                  children: [
                                    const Text('I agree to the '),
                                    InkWell(
                                      onTap: () =>
                                          PolicyDialogs.showPrivacyDialog(
                                              context),
                                      child: Text(
                                        'Privacy Policy',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    const Text(' and '),
                                    InkWell(
                                      onTap: () =>
                                          PolicyDialogs.showTermsDialog(
                                              context),
                                      child: Text(
                                        'Terms and Conditions',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            // test: Actual implimentation needed
                            onPressed: _agreedToTerms ? _handleRegister : null,
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return colorScheme.primary.withOpacity(0.3);
                                }
                                return colorScheme.primary;
                              }),
                              foregroundColor: MaterialStateProperty.all(
                                  colorScheme.onPrimary),
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
                          ),
                        ],
                      ),
                    ),
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
