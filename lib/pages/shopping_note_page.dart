import 'package:flutter/material.dart';
import 'package:cookpedia_app/utils/database_helper.dart'; // Adjust path if necessary
import 'package:cookpedia_app/models/notes_model.dart';    // Adjust path if necessary
import 'add_note_page.dart'; // Import the AddNotePage

class ShoppingNotePage extends StatefulWidget {
  final int? currentUserId;

  const ShoppingNotePage({super.key, this.currentUserId});

  @override
  State<ShoppingNotePage> createState() => _ShoppingNotePageState();
}

class _ShoppingNotePageState extends State<ShoppingNotePage> {
  final dbHelper = DatabaseHelper.instance;
  List<Note> _notes = [];
  bool _isLoading = true;
  String _appBarTitle = "Shopping Notes";

  @override
  void initState() {
    super.initState();
    _updateTitleAndLoadNotes();
  }

  @override
  void didUpdateWidget(covariant ShoppingNotePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUserId != oldWidget.currentUserId) {
      _updateTitleAndLoadNotes();
    }
  }

  void _updateTitleAndLoadNotes() {
    if (widget.currentUserId != null) {
      _appBarTitle = "My Shopping Notes";
    } else {
      _appBarTitle = "Shopping Notes (No User Selected)";
    }
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    if (widget.currentUserId == null) {
      if (mounted) {
        setState(() {
          _notes = [];
          _isLoading = false;
        });
      }
      print('No currentUserId provided to ShoppingNotePage. Displaying no user-specific notes.');
      return;
    }

    try {
      final notes = await dbHelper.getNotesForUser(widget.currentUserId!);
      if (mounted) {
        setState(() {
          _notes = notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notes: ${e.toString()}')),
        );
        print('Error loading notes for user ${widget.currentUserId}: $e');
      }
    }
  }

  void _navigateToAddNotePage() async {
    if (widget.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot add note: No user selected.')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNotePage(currentUserId: widget.currentUserId!),
      ),
    );

    if (result == true && mounted) {
      _loadNotes();
    }
  }

  Future<void> _deleteNote(int id) async {
    try {
      await dbHelper.deleteNote(id);
      _loadNotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting note: ${e.toString()}')),
        );
        print('Error deleting note: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.currentUserId == null
          ? const Center(
        child: Text(
          "No user selected to display notes.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      )
          : _notes.isEmpty
          ? Center(
        child: Text(
          "No notes found for this user. Tap '+' to add one!",
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadNotes,
        child: ListView.builder(
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            final note = _notes[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 16.0, right: 0.0, top: 8.0, bottom: 8.0), // Adjust padding
                title: Text(
                  note.foodName ?? "No Title",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: (note.createdAt != null) // Subtitle will only show created date now
                    ? Padding(
                  padding: const EdgeInsets.only(top: 4.0), // Add some space if date is shown
                  child: Text(
                    "Created: ${note.createdAt!.substring(0, 10)}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                )
                    : null, // No subtitle if no date
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // Important for Row in trailing
                  children: <Widget>[
                    if (note.measure != null && note.measure!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          note.measure!,
                          style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                        ),
                      ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Delete Note"),
                              content: Text(
                                  "Are you sure you want to delete '${note.foodName ?? 'this note'}'?"),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    if (note.id != null) {
                                      _deleteNote(note.id!);
                                    }
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
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(note.foodName ?? "Note Detail"),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Item: ${note.foodName ?? 'N/A'}"),
                            const SizedBox(height: 8),
                            Text("Measure: ${note.measure ?? 'N/A'}"),
                            // User ID display removed for brevity, can be added back if needed
                            // const SizedBox(height: 8),
                            // Text("User ID: ${note.userId}"),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        )
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: widget.currentUserId != null
          ? FloatingActionButton(
        onPressed: _navigateToAddNotePage,
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}