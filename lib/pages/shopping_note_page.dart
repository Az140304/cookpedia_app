import 'package:flutter/material.dart';
import 'package:cookpedia_app/utils/database_helper.dart'; // Adjust path if necessary
import 'package:cookpedia_app/models/notes_model.dart';    // Adjust path if necessary
import 'add_note_page.dart'; // Import the AddNotePage

class ShoppingNotePage extends StatefulWidget {
  const ShoppingNotePage({super.key, int? currentUserId});

  @override
  State<ShoppingNotePage> createState() => _ShoppingNotePageState();
}

class _ShoppingNotePageState extends State<ShoppingNotePage> {
  final dbHelper = DatabaseHelper.instance;
  List<Note> _allNotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    if (!mounted) return; // Check if the widget is still mounted
    setState(() {
      _isLoading = true;
    });
    try {
      final notes = await dbHelper.getAllNotes();
      if (mounted) { // Check again before updating state
        setState(() {
          _allNotes = notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) { // Check again before updating state
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notes: ${e.toString()}')),
        );
        print('Error loading all notes: $e');
      }
    }
  }

  void _navigateToAddNotePage() async {
    // TODO: Replace '1' with the actual current logged-in user's ID.
    // This ID should ideally come from your SessionManager or app's auth state.
    // For example, if HomePage holds the loggedInUserId, it could pass it to ShoppingNotePage,
    // or ShoppingNotePage could fetch it from SessionManager if appropriate for its context.
    // Since ShoppingNotePage currently shows ALL notes, we'll use a placeholder for now.
    // If your app structure has a logged-in user context, use that ID.
    // Example: int currentUserIdFromSession = await SessionManager.getUserId(); (if you implement getUserId)
    // For now, let's assume a placeholder or that ShoppingNotePage receives it somehow.
    const int placeholderCurrentUserId = 1; // Replace with actual user ID logic

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNotePage(currentUserId: placeholderCurrentUserId), // Pass the userId
      ),
    );

    if (result == true && mounted) {
      _loadNotes();
    }
  }



  Future<void> _deleteNote(int id) async {
    try {
      await dbHelper.deleteNote(id);
      // No need to call setState here directly for isLoading
      // _loadAllNotes will handle its own loading state and refresh the list.
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
        title: const Text("All Shopping Notes"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allNotes.isEmpty
          ? const Center(
        child: Text(
          "No notes found. Tap '+' to add one!",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      )
          : RefreshIndicator( // Optional: Add pull-to-refresh
        onRefresh: _loadNotes,
        child: ListView.builder(
          itemCount: _allNotes.length,
          itemBuilder: (context, index) {
            final note = _allNotes[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  note.foodName ?? "No Title", // Assuming 'foodName' in your Note model
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      note.measure ?? "No content", // Assuming 'content' in your Note model
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Measure: ${note.measure ?? 'N/A'}", // Assuming 'measure' in your Note model
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "User ID: ${note.userId}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    if (note.createdAt != null)
                      Text(
                        "Created: ${note.createdAt!.substring(0, 10)}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                  ],
                ),
                trailing: IconButton(
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
                isThreeLine: true,
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
                            const SizedBox(height: 8),
                            Text("User ID: ${note.userId}"),
                            if (note.createdAt != null) Text("Created: ${note.createdAt}"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddNotePage,
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}