import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SQLite CRUD',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  late Database _database;
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _openDatabase();
  }

  Future<void> _openDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'students.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE students(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER)',
        );
      },
      version: 1,
    );
    _refreshStudents();
  }

  Future<void> _insertStudent() async {
    await _database.insert(
      'students',
      {'name': _nameController.text, 'age': int.parse(_ageController.text)},
    );
    _nameController.clear();
    _ageController.clear();
    _refreshStudents();
  }

  Future<void> _updateStudent(int id) async {
    await _database.update(
      'students',
      {'name': _nameController.text, 'age': int.parse(_ageController.text)},
      where: 'id = ?',
      whereArgs: [id],
    );
    _nameController.clear();
    _ageController.clear();
    _refreshStudents();
  }

  Future<void> _deleteStudent(int id) async {
    await _database.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
    _refreshStudents();
  }

  Future<void> _refreshStudents() async {
    final List<Map<String, dynamic>> students = await _database.query('students');
    setState(() {
      _students = students;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter SQLite CRUD'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextFormField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: 'Age',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Add Student'),
              onPressed: () async {
                await _insertStudent();
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _students.length,
                itemBuilder: (BuildContext context, int index) {
                  final student = _students[index];
                  return ListTile(
                    title: Text(student['name']),
                    subtitle: Text(student['age'].toString()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _nameController.text = student['name'];
                            _ageController.text = student['age'].toString();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {                            return AlertDialog(
                              title: Text('Update Student'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    TextFormField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        labelText: 'Name',
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _ageController,
                                      decoration: InputDecoration(
                                        labelText: 'Age',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Update'),
                                  onPressed: () async {
                                    await _updateStudent(student['id']);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete Student'),
                              content: Text('Are you sure you want to delete this student?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Delete'),
                                  onPressed: () async {
                                    await _deleteStudent(student['id']);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
);

}
}