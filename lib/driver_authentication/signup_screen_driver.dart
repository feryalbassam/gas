import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gas_on_go/driver_authentication/login_screen_driver.dart';
import 'package:gas_on_go/methods/common_methods.dart';
import 'package:gas_on_go/driver_pages/dashboard.dart';
import 'package:gas_on_go/welcome/welcome_page.dart';
import 'package:gas_on_go/widgets/loading_dialog.dart';

class SignUpScreenDriver extends StatefulWidget {
  const SignUpScreenDriver({super.key});

  @override
  State<SignUpScreenDriver> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreenDriver> {
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
          'Your name must be at least 4 0r more characters.', context);
    } else if (_phoneController.text.trim().length < 7) {
      cMethods.displaySnackBar(
          'Your phone must be at least 8 0r more characters.', context);
    } else if (!_emailController.text.contains('@')) {
      cMethods.displaySnackBar('Please write valid email.', context);
    } else if (_passwordController.text.trim().length < 5) {
      cMethods.displaySnackBar(
          'Your password must be at least 6 characters or more.', context);
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
        .child('driver')
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
    };
    usersRef.set(driverDataMap);

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Dashboard()));
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
                Image.asset('assets/man.png'),
                const Text(
                  'Sign Up',
                  style: TextStyle(
                      color: Color.fromARGB(255, 15, 15, 41),
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                // Text fields
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Color.fromARGB(255, 188, 186, 186),
                          ),
                          labelText: 'Name',
                          labelStyle: const TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 195, 193, 193),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 195, 193, 193),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 195, 193, 193),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 188, 186, 186),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: Color.fromARGB(255, 188, 186, 186),
                          ),
                          labelText: 'Phone',
                          labelStyle: const TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 195, 193, 193),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 195, 193, 193),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 195, 193, 193),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 188, 186, 186),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Color.fromARGB(255, 188, 186, 186),
                          ),
                          labelText: 'Email',
                          labelStyle: const TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 195, 193, 193),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 195, 193, 193),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 195, 193, 193),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 188, 186, 186),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: securetext,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.password,
                            color: Color.fromARGB(255, 188, 186, 186),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                securetext = !securetext;
                              });
                            },
                            icon: securetext == true
                                ? const Icon(
                                    Icons.visibility_off,
                                    color: Color.fromARGB(255, 188, 186, 186),
                                  )
                                : const Icon(
                                    Icons.visibility,
                                    color: Color.fromARGB(255, 188, 186, 186),
                                  ),
                          ),
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 195, 193, 193),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 195, 193, 193),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 195, 193, 193),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 188, 186, 186),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _truckNumberontroller,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.numbers,
                            color: Color.fromARGB(255, 188, 186, 186),
                          ),
                          labelText: 'Truck Number',
                          labelStyle: const TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 195, 193, 193),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 195, 193, 193),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 195, 193, 193),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 188, 186, 186),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          checkIfNetworkIsAvailable();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 15, 15, 41),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.only(
                              left: 40, right: 40, top: 13, bottom: 13),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color.fromARGB(255, 188, 186, 186),
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreenDriver(),
                      ),
                    );
                  },
                  child: Text(
                    'Already have an Account? Login Here',
                    style: TextStyle(color: Color.fromARGB(255, 41, 107, 211)),
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
