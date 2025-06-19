import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _places = [
    'Paris',
    'London',
    'New York',
    'Tokyo',
    'São Paulo',
  ];
  List<String> _filtered = [];
  String _result = '';

  void _onSearchChanged(String value) {
    setState(() {
      _filtered = _places
          .where((p) => p.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  Future<void> _fetchPlace(String place) async {
    final uri = Uri.parse(
        'https://recommendations.odsy.to/places/${Uri.encodeComponent(place)}');
    try {
      final response = await http.get(uri);
      setState(() {
        if (response.statusCode == 200) {
          _result = response.body;
        } else {
          _result = 'Erro: ${response.statusCode}';
        }
      });
    } catch (e) {
      setState(() {
        _result = 'Erro: $e';
      });
    }
  }

  Widget _buildSuggestions() {
    return Column(
      children: _filtered
          .map(
            (p) => ListTile(
              title: Text(p),
              onTap: () {
                _searchController.text = p;
                _filtered.clear();
                _fetchPlace(p);
              },
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: 'Buscar destino'),
              onChanged: _onSearchChanged,
            ),
            _buildSuggestions(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_result),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

