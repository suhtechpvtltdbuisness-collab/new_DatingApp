import 'package:flutter/material.dart';
import 'package:dating_app/controllers/auth_controller.dart';
import 'package:dating_app/app/app_routes.dart';
import 'package:dating_app/utils/validators.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _profileController = TextEditingController();
  final authController = Get.find<AuthController>();

  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedInterestedIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Title
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 12),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 12),

              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: Validators.validatePhoneNumber,
              ),
              const SizedBox(height: 12),

              // Date of Birth
              InkWell(
                onTap: () => _pickDate(),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Gender
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.wc),
                ),
                items: Gender.values
                    .map(
                      (gender) => DropdownMenuItem(
                        value: gender.name,
                        child: Text(gender.name[0].toUpperCase() + gender.name.substring(1)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Gender is required' : null,
              ),
              const SizedBox(height: 12),

              // Interested In
              DropdownButtonFormField<String>(
                initialValue: _selectedInterestedIn,
                decoration: const InputDecoration(
                  labelText: 'Interested In',
                  prefixIcon: Icon(Icons.favorite),
                ),
                items: Gender.values
                    .map(
                      (gender) => DropdownMenuItem(
                        value: gender.name,
                        child: Text(gender.name[0].toUpperCase() + gender.name.substring(1)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedInterestedIn = value;
                  });
                },
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Interested in is required' : null,
              ),
              const SizedBox(height: 12),

              // Profile
              TextFormField(
                controller: _profileController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Profile Description',
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Tell us about yourself...',
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Profile description is required' : null,
              ),
              const SizedBox(height: 12),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 12),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) => Validators.validateConfirmPassword(
                  value,
                  _passwordController.text,
                ),
              ),
              const SizedBox(height: 24),

              // Error message
              Obx(
                () => authController.errorMessage.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          authController.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Sign up button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authController.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              // For demo, use sample coordinates. In real app, get from location service
                              final coordinates = ['28.4786688', '77.4786688'];
                              
                              authController
                                  .signUp(
                                    name: _nameController.text,
                                    phoneNumber: _phoneController.text,
                                    dob: _selectedDate!.toIso8601String().split('T')[0],
                                    gender: _selectedGender!,
                                    profile: _profileController.text,
                                    interestedIn: _selectedInterestedIn!,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    coordinates: coordinates,
                                  )
                                  .then((success) {
                                if (success) {
                                  AppRoutes.toHome();
                                }
                              });
                            }
                          },
                    child: authController.isLoading.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Sign Up'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _profileController.dispose();
    super.dispose();
  }
}
