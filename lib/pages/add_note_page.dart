// lib/pages/add_note_page.dart
import 'package:flutter/material.dart';
import 'package:cookpedia_app/utils/database_helper.dart'; // Adjust path if necessary
import 'package:cookpedia_app/models/notes_model.dart';    // Adjust path if necessary

class AddNotePage extends StatefulWidget {
  final int currentUserId; // Add this parameter

  const AddNotePage({
    super.key,
    required this.currentUserId, // Make it required
  });

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper.instance;

  // TextEditingControllers for each field (User ID controller removed)
  final _foodNameController = TextEditingController();
  final _measureController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    // _userIdController.dispose(); // Removed
    _foodNameController.dispose();
    _measureController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      // Use widget.currentUserId directly
      final userId = widget.currentUserId;

      final note = NoteModel(
        userId: userId,
        foodName: _foodNameController.text,
        measure: _measureController.text,
        // Assuming createdAt and updatedAt are handled by DB DEFAULT CURRENT_TIMESTAMP
        // If not, set them:
        createdAt: DateTime.now().toIso8601String(),
        // updatedAt: DateTime.now().toIso8601String(),
      );

      try {
        await dbHelper.createNote(note);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note saved successfully!')),
          );
          Navigator.pop(context, true); // Pop with a result to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving note: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Shopping Note"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // TextFormField for User ID is removed
              // You can display the currentUserId if needed for confirmation (optional)
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 16.0),
              //   child: Text("Adding note for User ID: ${widget.currentUserId}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              // ),
              TextFormField(
                controller: _foodNameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name / Item',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Apples, Chicken Breast',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the food name or item';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _measureController,
                decoration: const InputDecoration(
                  labelText: 'Quantity / Measure',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 1 kg, 2 packs, 500g',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity or measure';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), // Added SizedBox for consistency
              ElevatedButton(
                onPressed: _isSaving ? null : _saveNote,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isSaving
                    ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}