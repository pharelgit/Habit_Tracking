import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? habitList = prefs.getString('habits');
    if (habitList != null) {
      List<dynamic> decodedList = jsonDecode(habitList);
      setState(() {
        habits = decodedList.map((item) => Habit(title: item['title'], isCompleted: item['isCompleted'])).toList();
      });
    }
  }

  void _saveHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> habitList = habits.map((habit) => {'title': habit.title, 'isCompleted': habit.isCompleted}).toList();
    prefs.setString('habits', jsonEncode(habitList));
  }

  void _addNewHabit(String title) {
    setState(() {
      habits.add(Habit(title: title));
      _saveHabits();
    });
  }

  void _removeHabit(int index) {
    setState(() {
      habits.removeAt(index);
      _saveHabits();
    });
  }

  void _confirmRemoveHabit(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          title: Text('Confirmer la suppression'),
          content: Text('Voulez-vous vraiment supprimer cette habitude ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () {
                _removeHabit(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleHabitCompletion(int index) {
    setState(() {
      habits[index].isCompleted = !habits[index].isCompleted;
      _saveHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi d Habitudes'),
      ),
      body: Container(
        color: Colors.blue[50], // Change background color
        child: ListView.builder(
          itemCount: habits.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 15),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                title: Text(
                  habits[index].title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: habits[index].isCompleted,
                      onChanged: (bool? value) {
                        _toggleHabitCompletion(index);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _confirmRemoveHabit(index);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddHabitDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddHabitDialog() {
    String habitTitle = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          title: Text('Ajouter une nouvelle habitude'),
          content: Container(
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                habitTitle = value;
              },
              decoration: InputDecoration(
                hintText: 'Saisir le nom de l habitude',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () {
                _addNewHabit(habitTitle);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void main() => runApp(MaterialApp(home: HomeScreen()));
