import 'package:flutter/material.dart';
import 'package:minhas_anotacoes/model/notes.dart';
import '../helper/anotation_helper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final AnotationHelper _db = AnotationHelper();
  List<Notes> _notes = <Notes>[];

  _showRegisterScreen({Notes? note}) {
    var textSaveUpdate = '';
    if (note == null) {
      _titleController.text = '';
      _descriptionController.text = '';
      textSaveUpdate = 'Salvar';
    } else {
      _titleController.text = note.title ?? '';
      _descriptionController.text = note.description ?? '';
      textSaveUpdate = 'Atualizar';
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('$textSaveUpdate anotação'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  controller: _titleController,
                  decoration: const InputDecoration(
                      labelText: 'Título', hintText: 'Digite o título...'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Digite a descrição...'),
                ),
              ],
            ),
            actions: [
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar')),
              FlatButton(
                  onPressed: () {
                    // somthing
                    _saveUpdateNote(selectedNote: note);
                    Navigator.pop(context);
                  },
                  child: Text(textSaveUpdate)),
            ],
          );
        });
  }

  _getNotes() async {
    List listOfNotes = await _db.getNotes();

    List<Notes> temporaryNotes = <Notes>[];
    for (var item in listOfNotes) {
      Notes _notes = Notes.fromMap(item);
      temporaryNotes.add(_notes);
    }

    setState(() {
      _notes = temporaryNotes;
    });
    temporaryNotes = [];
  }

  _saveUpdateNote({Notes? selectedNote}) async {
    String title = _titleController.text;
    String description = _descriptionController.text;

    if (selectedNote == null) {
      // save
      Notes _notes = Notes(title, description, DateTime.now().toString());
      await _db.saveAnotation(_notes);
    } else {
      // update
      selectedNote.title = title;
      selectedNote.description = description;
      selectedNote.date = DateTime.now().toString();
      await _db.updateAnotation(selectedNote);
    }

    _titleController.clear();
    _descriptionController.clear();
    _getNotes();
  }

  _removeNote(int id) {
    _db.removeAnotation(id);
    _getNotes();
  }

  _formatDate(String date) {
    initializeDateFormatting('pt_BR');
    var formater = DateFormat.yMd('pt_BR');

    DateTime convertedDate = DateTime.parse(date);
    var formatedDate = formater.format(convertedDate);

    return formatedDate;
  }

  @override
  void initState() {
    super.initState();
    _getNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas anotações'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            final note = _notes[index];
            return Card(
              child: ListTile(
                key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                title: Text(note.title.toString()),
                subtitle: Text(
                    '${_formatDate(note.date.toString())} -- ${note.description.toString()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showRegisterScreen(note: note);
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.edit,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeNote(note.id!),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () {
          _showRegisterScreen();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
