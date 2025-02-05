import 'package:coded_gp/core/common/utils/validation_utils.dart';
import 'package:coded_gp/core/common/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:coded_gp/core/config/theme/app_colors.dart';
import 'package:coded_gp/core/common/widgets/custom_button.dart';
import 'package:coded_gp/features/auth/controllers/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  String? emailError;
  String? passwordError;

  void validateInputs() {
    setState(() {
      emailError = ValidationUtils.validateEmail(emailController.text);
      passwordError = ValidationUtils.validatePassword(passwordController.text);
    });
  }

  bool get isValid => emailError == null && passwordError == null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Row(
                children: [
                  Image.asset(
                    'assets/images/splash/Duck-01.png',
                    height: 60,
                    width: 60,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome! Glad to see you',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.kWhiteColor
                                    : AppColors.kBlackColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.kWhiteColor
                                    : AppColors.kTextLightColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // email field
              CustomTextField(
                label: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                errorText: emailError,
                onChanged: (_) => validateInputs(),
                onFieldSubmitted: (_) {
                  validateInputs();
                  FocusScope.of(context).unfocus();
                },
              ),
              const SizedBox(height: 16),

              // password field
              CustomTextField(
                label: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                controller: passwordController,
                errorText: passwordError,
                onChanged: (_) => validateInputs(),
                onFieldSubmitted: (_) {
                  validateInputs();
                  FocusScope.of(context).unfocus();
                },
              ),
              const SizedBox(height: 16),

              // sign in button
              CustomButton(
                text: 'Sign In',
                onPressed: () {},
                isLoading: isLoading,
                isDisabled: !isValid,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
