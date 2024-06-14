import 'package:flutter/material.dart';
import 'package:notes_app/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];

  bool _isLoading = true;

  void _refreshData() async {
    final data = await DatabaseHelper.getAllData();
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

  Future<void> _addData() async {
    await DatabaseHelper.createData(
        _titleController.text, _descController.text);
    _refreshData();
  }

  Future<void> _updateData(int id) async {
    await DatabaseHelper.updateData(
        id, _titleController.text, _descController.text);
    _refreshData();
  }

  void _deletedata(int id) async {
    await DatabaseHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        margin: EdgeInsets.all(15),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        content: Text('Note Deleted')));
    _refreshData();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void showBottomSheet(int? id) async {
    //If id is not null it will update data other wise it will add new data.
    //When edit icon is pressed then id will be given to bottomsheet function.
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descController.text = existingData['desc'];
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
                  border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  hintText: 'Title'),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  hintText: 'Description'),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addData();
                  }
                  if (id != null) {
                    await _updateData(id);
                  }

                  _titleController.text = '';
                  _descController.text = '';

                  Navigator.of(context).pop();
                  print('Data Added');
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    id == null ? 'Add Note' : 'Update',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECEAF4),
      appBar: AppBar(
        title: Text('Notes App'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allData.length,
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(right: 5, left: 0, bottom: 2, top: 5),
                    child: Text(
                      _allData[index]['title'],
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(right: 5, left: 0, bottom: 2, top: 5),
                    child: Text(_allData[index]['desc']),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          showBottomSheet(_allData[index]['id']);
                        },
                        icon: Icon(Icons.edit, color: Colors.indigo),
                      ),
                      IconButton(
                        onPressed: () {
                          _deletedata(_allData[index]['id']);
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
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
