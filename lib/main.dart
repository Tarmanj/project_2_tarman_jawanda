import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Selector App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Random Selector'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _options = [];
  String _currentOption = '';

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  void _addOption() async {
    setState(() {
      _options.add(_currentOption);
      _currentOption = '';
    });
    await _saveOptions();
  }

  void _selectRandomOption() async {
    if (_options.isNotEmpty) {
      final random = Random();
      final selectedIndex = random.nextInt(_options.length);
      setState(() {
        _currentOption = _options[selectedIndex];
      });
      await _saveOptions();
      Timer(Duration(milliseconds: 500), () {
        setState(() {});
      });
    }
  }

  Future<void> _saveOptions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('options', _options);
  }

  Future<void> _loadOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final options = prefs.getStringList('options') ?? [];
    setState(() {
      _options = options;
    });
  }

  void _deleteOption(int index) async {
    setState(() {
      _options.removeAt(index);
    });
    await _saveOptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => _currentOption = value,
              decoration: InputDecoration(
                labelText: 'Enter an option',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addOption,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _options.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_options[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteOption(index),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedOpacity(
              opacity: _currentOption.isEmpty ? 0.0 : 1.0,
              duration: Duration(milliseconds: 500),
              child: Text(
                _currentOption.isEmpty
                    ? 'No option selected yet.'
                    : _currentOption,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectRandomOption,
        tooltip: 'Select Random Option',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
