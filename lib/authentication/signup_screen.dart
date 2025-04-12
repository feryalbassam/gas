

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gas_on_go/authentication/login_screen.dart';
import 'package:gas_on_go/methods/common_methods.dart';
import 'package:gas_on_go/pages/home_page.dart';
import 'package:gas_on_go/widgets/loading_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  late bool securetext;
  CommonMethods cMethods = CommonMethods();

  // ✅ نوع الحساب
  String _selectedAccountType = 'user';
  final List<String> _accountTypes = ['user', 'driver'];

  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);
    signUpFormValidation();
  }

  signUpFormValidation() {
    if (_usernameController.text.trim().length < 3) {
      cMethods.displaySnackBar(
          'Your name must be at least 4 or more characters.', context);
    } else if (_phoneController.text.trim().length < 7) {
      cMethods.displaySnackBar(
          'Your phone must be at least 8 or more characters.', context);
    } else if (!_emailController.text.contains('@')) {
      cMethods.displaySnackBar('Please write valid email.', context);
    } else if (_passwordController.text.trim().length < 5) {
      cMethods.displaySnackBar(
          'Your password must be at least 6 characters or more.', context);
    } else {
      registerNewUser();
    }
  }

  @override
  void initState() {
    securetext = true;
    super.initState();
  }

  registerNewUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: 'Registering your account...'),
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? userFirebase = userCredential.user;

      if (userFirebase != null) {
        Map<String, dynamic> userDataMap = {
          'name': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'id': userFirebase.uid,
          'blockStatus': 'no',
          'accountType': _selectedAccountType,
          'photoUrl': 'https://i.pravatar.cc/150?img=${DateTime.now().millisecondsSinceEpoch % 70}',
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userFirebase.uid)
            .set(userDataMap);

        DatabaseReference usersRef = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(userFirebase.uid);

        usersRef.set(userDataMap);

        if (!context.mounted) return;
        Navigator.pop(context);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    } catch (errorMsg) {
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Image.asset('assets/gas.png'),
                const Text(
                  'Sign Up',
                  style: TextStyle(
                      color: Color.fromARGB(255, 15, 15, 41),
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      buildTextField(
                          controller: _usernameController,
                          label: 'Name',
                          icon: Icons.person),
                      const SizedBox(height: 10),
                      buildTextField(
                          controller: _phoneController,
                          label: 'Phone',
                          icon: Icons.phone),
                      const SizedBox(height: 10),
                      buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: securetext,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.password),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                securetext = !securetext;
                              });
                            },
                            icon: Icon(
                              securetext
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ✅ Dropdown لاختيار نوع الحساب
                      DropdownButtonFormField<String>(
                        value: _selectedAccountType,
                        items: _accountTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type[0].toUpperCase() + type.substring(1)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAccountType = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Account Type',
                          prefixIcon: Icon(Icons.account_circle),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          checkIfNetworkIsAvailable();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color.fromARGB(255, 15, 15, 41),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 13),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                              color: Color.fromARGB(255, 188, 186, 186),
                              fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: const Text(
                    'Already have an Account? Login Here',
                    style: TextStyle(color: Color.fromARGB(255, 41, 107, 211)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      {required TextEditingController controller,
        required String label,
        required IconData icon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
