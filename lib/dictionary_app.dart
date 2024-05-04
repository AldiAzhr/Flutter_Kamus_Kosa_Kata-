// dictionary_app.dart

import 'package:flutter/material.dart';
import 'package:kamus_app/database/db_helper.dart';
import 'package:kamus_app/word.dart';

class DictionaryApp extends StatefulWidget {
  @override
  _DictionaryAppState createState() => _DictionaryAppState();
}

class _DictionaryAppState extends State<DictionaryApp> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _originalWordController = TextEditingController();
  final TextEditingController _translatedWordController = TextEditingController();
  late List<Word> _words = [];
  late List<Word> _searchResult = [];
  bool _showNoResult = false;

  @override
  void initState() {
    super.initState();
    _refreshWords();
  }

  void _refreshWords() async {
    List<Word> words = await DatabaseHelper.getAllWords();
    setState(() {
      _words = words.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(seconds: 1),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Text(
                'Kamus Kosa Kata',
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  onChanged: _searchWord,
                  decoration: InputDecoration(
                    labelText: 'Cari Kosa Kata',
                    hintText: 'Cari Sebuah Kosa Kata....',
                    prefixIcon: Icon(Icons.search, color: Colors.indigo),
                    suffixIcon: _originalWordController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.red),
                            onPressed: () {
                              _originalWordController.clear();
                              _searchWord('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          _showNoResult
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Tidak ada kosa kata yang anda cari',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : SizedBox(),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResult.length != 0 || _originalWordController.text.isNotEmpty
                  ? _searchResult.length
                  : _words.length,
              itemBuilder: (context, index) {
                final word = _searchResult.length != 0 || _originalWordController.text.isNotEmpty
                    ? _searchResult[index]
                    : _words[index];
                return Card(
                  elevation: 2.0,
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(word.originalWord, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(word.translatedWord),
                    onTap: () {
                      _deleteConfirmationDialog(word.id);
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteConfirmationDialog(word.id);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddWordDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _showAddWordDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Tambah Kosa Kata Baru',
            style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _originalWordController,
                  decoration: InputDecoration(labelText: 'Kosa Kata Bahasa Inggris'),
                ),
                TextField(
                  controller: _translatedWordController,
                  decoration: InputDecoration(labelText: 'Translate Indonsia'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _addWord();
                Navigator.of(context).pop();
              },
              child: Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addWord() async {
    if (_originalWordController.text.isEmpty || _translatedWordController.text.isEmpty) {
      return;
    }

    Word newWord = Word(
      originalWord: _originalWordController.text,
      translatedWord: _translatedWordController.text,
    );

    await DatabaseHelper.insertWord(newWord);

    _originalWordController.clear();
    _translatedWordController.clear();

    _refreshWords();
  }

  void _searchWord(String query) {
    _searchResult.clear();
    _showNoResult = true;

    if (query.isNotEmpty) {
      _words.forEach((word) {
        if (word.originalWord.toLowerCase().contains(query.toLowerCase()) ||
            word.translatedWord.toLowerCase().contains(query.toLowerCase())) {
          _searchResult.add(word);
          _showNoResult = false;
        }
      });
    } else {
      _showNoResult = false;
    }

    setState(() {});
  }

  void _deleteConfirmationDialog(int? id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus'),
          content: Text('Apakah kamu serius ingin menghapus kosa kata ini ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _deleteWord(id);
                Navigator.of(context).pop();
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _deleteWord(int? id) async {
    if (id != null) {
      await DatabaseHelper.deleteWord(id);
      _refreshWords();
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kamus Kosa Kata',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      home: DictionaryApp(),
    );
  }
}
