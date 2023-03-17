import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  static FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<void> signOut() async {
    return await _auth.signOut();
  }

  static Stream<User?> get userStream => _auth.authStateChanges();
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email;
  late String _password;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Por favor, digite um e-mail válido';
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    _email = value!;
                  },
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Por favor, digite uma senha válida';
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    _password = value!;
                  },
                ),
                const SizedBox(height: 30.0),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() {
                              _loading = true;
                            });
                            try {
                              await FirebaseService.signIn(_email, _password);
                              Navigator.pushReplacementNamed(context, '/home');
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                _loading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.message!)));
                            }
                          }
                        },
                        child: const Text('Entrar'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}