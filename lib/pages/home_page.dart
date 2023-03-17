import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User _user;

  @override
  void initState() {
    super.initState();
    FirebaseService.userStream.listen((User? user) {
      setState(() {
        _user = user!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Usuário logado com sucesso!'),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () async {
                await FirebaseService.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}