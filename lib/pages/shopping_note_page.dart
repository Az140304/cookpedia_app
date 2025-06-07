// lib/pages/shopping_note_page.dart

import 'package:flutter/material.dart';
import 'package:cookpedia_app/utils/database_helper.dart';
import 'package:cookpedia_app/models/notes_model.dart';
import 'package:cookpedia_app/utils/notification_service.dart';
import 'package:cookpedia_app/utils/reminder_settings_manager.dart';
import 'add_note_page.dart';
import 'edit_note_page.dart';

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
  bool _remindersEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettingsAndNotes();
  }

  void _loadSettingsAndNotes() async {
    final remindersOn = await ReminderSettingsManager.areRemindersEnabled();
    if (mounted) {
      setState(() {
        _remindersEnabled = remindersOn;
      });
    }
    _updateTitleAndLoadNotes();
  }

  void _updateTitleAndLoadNotes() {
    _appBarTitle = widget.currentUserId != null
        ? "My Shopping Notes"
        : "Shopping Notes (No User)";
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    if (widget.currentUserId == null) {
      if (mounted) setState(() => _notes = []);
    } else {
      try {
        final notes = await dbHelper.getNotesForUser(widget.currentUserId!);
        if (mounted) setState(() => _notes = notes);
      } catch (e) {
        // Handle error
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _onReminderToggle(bool isEnabled) async {
    setState(() {
      _remindersEnabled = isEnabled;
    });
    await ReminderSettingsManager.setRemindersEnabled(isEnabled);

    if (isEnabled) {
      // If toggled on, start the repeating reminder.
      await NotificationService().startRepeatingReminder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Reminders enabled.'),
          backgroundColor: Colors.green,
        ));
      }
    } else {
      // If toggled off, cancel all reminders.
      await NotificationService().cancelAllReminders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Reminders disabled.'),
          backgroundColor: Colors.orange,
        ));
      }
    }
  }

  void _deleteNote(int id) async {
    await dbHelper.deleteNote(id);
    _loadNotes();

    // Check if reminders need to be stopped.
    final remainingNotes = await dbHelper.getNotesForUser(widget.currentUserId!);
    if (remainingNotes.isEmpty) {
      await NotificationService().cancelAllReminders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('List empty. Reminders stopped.'),
          backgroundColor: Colors.blueAccent,
        ));
      }
    }
  }

  void _navigateToAddNotePage() async {
    if (widget.currentUserId == null) return;
    final wasEmpty = _notes.isEmpty;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              AddNotePage(currentUserId: widget.currentUserId!)),
    );
    if (result == true && mounted) {
      await _loadNotes();
      // If the list was empty and now has an item, start reminders.
      if (wasEmpty && _notes.isNotEmpty) {
        await NotificationService().startRepeatingReminder();
      }
    }
  }

  void _navigateToEditNotePage(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditNotePage(noteToEdit: note)),
    );
    if (result == true && mounted) {
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF8B1E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          if (widget.currentUserId != null)
            SwitchListTile(
              title: const Text("Enable Reminders"),
              value: _remindersEnabled,
              onChanged: _onReminderToggle,
              activeColor: const Color(0xFFFF8B1E),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                ? const Center(child: Text("No notes yet. Tap '+' to add one!"))
                : RefreshIndicator(
              onRefresh: _loadNotes,
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Card(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: ListTile(
                      title: Text(note.foodName ?? "No Title"),
                      subtitle: Text(note.measure ?? ""),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _navigateToEditNotePage(note),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteNote(note.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.currentUserId != null
          ? FloatingActionButton(
        onPressed: _navigateToAddNotePage,
        tooltip: 'Add Note',
        backgroundColor: const Color(0xFFFF8B1E),
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}