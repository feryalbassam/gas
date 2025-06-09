import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gas_on_go/seller_authentication/login_screen_seller.dart';
import '../methods/common_methods.dart';
import '../seller_pages/sellerdashboard.dart';
import '../welcome/welcome_page.dart';
import '../widgets/loading_dialog.dart';

class SignUpScreenSeller extends StatefulWidget {
  const SignUpScreenSeller({super.key});

  @override
  State<SignUpScreenSeller> createState() => _SignUpScreenSellerState();
}

class _SignUpScreenSellerState extends State<SignUpScreenSeller> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _truckNumberontroller = TextEditingController();
  late bool securetext;
  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);
    signUpFormValidation();
  }

  signUpFormValidation() {
    if (_usernameController.text.trim().length < 3) {
      cMethods.displaySnackBar(
          'Your name must be at least 3 or more characters.', context);
    } else if (_phoneController.text.trim().length != 10) {
      cMethods.displaySnackBar(
          'Phone number must be exactly 10 digits.', context);
    } else if (!_emailController.text.contains('@')) {
      cMethods.displaySnackBar('Please write a valid email.', context);
    } else if (_passwordController.text.trim().length < 8) {
      cMethods.displaySnackBar(
          'Your password must be at least 8 characters or more.', context);
    } else if (_truckNumberontroller.text.trim().isEmpty) {
      cMethods.displaySnackBar('Please enter your truck number.', context);
    } else {
      registerNewDriver();
    }
  }

  @override
  void initState() {
    securetext = true;
    super.initState();
  }

  registerNewDriver() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: 'Registering your account...'),
    );

    final User? userFirebase = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    )
            .catchError((errorMsg) {
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    }))
        .user;

    if (!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference usersRef = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(userFirebase!.uid);

    Map driverTruckInfo = {
      'truckNumber': _truckNumberontroller.text.trim(),
    };

    Map driverDataMap = {
      'truck_details': driverTruckInfo,
      'name': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'id': userFirebase.uid,
      'blockStatus': 'no',
      'password': _passwordController.text.trim(),
    };

    usersRef.set(driverDataMap);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userFirebase.uid)
        .set({
      'role': 'seller',
      'name': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Sellerdashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Image.asset('assets/man.png'),
                const Text(
                  'Sign Up',
                  style: TextStyle(
                      color: Color(0xFF0F0F29),
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.grey),
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.phone, color: Colors.grey),
                          labelText: 'Phone',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.grey),
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: securetext,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              securetext
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                securetext = !securetext;
                              });
                            },
                          ),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _truckNumberontroller,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.numbers, color: Colors.grey),
                          labelText: 'Truck Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => checkIfNetworkIsAvailable(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F0F29),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreenSeller()),
                    );
                  },
                  child: const Text(
                    'Already have an Account? Login Here',
                    style: TextStyle(color: Color(0xFF296BD3)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
