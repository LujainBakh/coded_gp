import 'package:coded_gp/core/common/utils/validation_utils.dart';
import 'package:coded_gp/core/common/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:coded_gp/core/config/theme/app_colors.dart';
import 'package:coded_gp/core/common/widgets/custom_button.dart';
// ignore: unused_import
import 'package:coded_gp/features/auth/controllers/auth.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:coded_gp/features/home/views/screens/homescreen.dart';
import 'package:coded_gp/main_screen.dart';

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

  Future<void> handleSignIn() async {
    // Validate inputs first
    validateInputs();
    if (!isValid) return;

    setState(() => isLoading = true);

    try {
      // Attempt sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Add fade transition
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Add debug print to see the error code
      print('Firebase Auth Error Code: ${e.code}');

      String errorMessage = 'An error occurred. Please try again.';

      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = 'Incorrect email or password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

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

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/coded_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    constraints: const BoxConstraints(maxWidth: 400),
                    margin: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth > 400
                          ? (constraints.maxWidth - 400) / 2
                          : 0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: constraints.maxHeight * 0.10),
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
                          hintText: 'Enter your university email',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          errorText: emailError,
                          backgroundColor: isDark
                              ? AppColors.kDarkFieldColor
                              : AppColors.kLightFieldColor,
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
                          isPassword: true,
                          controller: passwordController,
                          errorText: passwordError,
                          backgroundColor: isDark
                              ? AppColors.kDarkFieldColor
                              : AppColors.kLightFieldColor,
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
                          onPressed: handleSignIn,
                          isLoading: isLoading,
                          isDisabled: !isValid,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
