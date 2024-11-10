import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../db_helper/db_helper.dart';
import '../model/note.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Get Data and Refresh data from database
  void _refreshData() async {
    final data = await DBHelper.queryAll();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Create a new note
  Future<void> _createData() async {
    final newNote = Note(
      title: _titleController.text,
      description: _descriptionController.text,
      createdAt: DateTime.now(),
    );
    await DBHelper.insertData(newNote);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Note Added Successfully"),
      ),
    );
    _refreshData();
  }

// Search a Note
  void _searchByTitle() async {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      final results = await DBHelper.searchByTitle(query);
      setState(() {
        _allData = results;
      });
    } else {
      _refreshData();
    }
  }

  // Update an existing note
  Future<void> _editData(int id) async {
    final editNote = Note(
      id: id,
      title: _titleController.text,
      description: _descriptionController.text,
      createdAt: DateTime.now(),
    );

    await DBHelper.updateData(editNote);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Note Updated Successfully"),
      ),
    );
    _refreshData();
  }

// Delete an existing note
  void _deleteData(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Note"),
          content: Text("Do you want to delete this note?"),
          actions: [
            ElevatedButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Yes"),
              onPressed: () async {
                Navigator.of(context).pop();
                await DBHelper.delete(id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text("Note Deleted Successfully"),
                  ),
                );
                _refreshData();
              },
            ),
          ],
        );
      },
    );
  }

  // Show modal bottom sheet for adding/editing/viewing notes
  void showBottomSheet(int? id, {bool isViewMode = false}) async {
    if (id != null) {
      final currentData =
      _allData.firstWhere((element) => element['id'] == id);
      _titleController.text = currentData['title'];
      _descriptionController.text = currentData['description'];
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Title",
              ),
              readOnly: isViewMode,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Description",
              ),
              readOnly: isViewMode,
              maxLines: isViewMode ? null : 5,
            ),
            SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (!isViewMode)
                    ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await _createData();
                        } else {
                          await _editData(id);
                        }

                        _titleController.text = "";
                        _descriptionController.text = "";

                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          id == null ? "Save Note" : "Update Note",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _titleController.clear();
                      _descriptionController.clear();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Close"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF2F4C02),
        title: Text("My Simple Note",
            style: TextStyle(color: Colors.white),
      ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _searchByTitle(),
              decoration: InputDecoration(
                hintText: 'Search notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),


      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )

          : ListView.builder(
        itemCount: _allData.length,
        itemBuilder: (context, index) => Card(
          color: Color(0xFFB0F39A),
          margin: EdgeInsets.all(15),
          child: ListTile(
            title: Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                _allData[index]['title'],
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),

            subtitle: Text(_allData[index]['description']

                .length > 15
                ? _allData[index]['description'].substring(0, 15) + '...'
                : _allData[index]['description'],),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    showBottomSheet(_allData[index]['id'], isViewMode: true, );
                  },
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Color(0xFF8CC304),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showBottomSheet(_allData[index]['id']);
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Color(0xFF347A06),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _deleteData(_allData[index]['id']);
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
