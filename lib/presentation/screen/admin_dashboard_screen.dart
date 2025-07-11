import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout/domain/entities/activity%20.dart';
import 'package:scout/presentation/auth_provider.dart';
import 'package:scout/presentation/admin_activity_provider.dart';
// import 'package:image_picker_web/image_picker_web.dart'; // No longer needed
// import 'dart:typed_data'; // No longer needed for raw image bytes

// The AdminDashboardScreen remains mostly the same, as the core logic is in the dialog.
// Just ensure the import for ActivityTranslation is correct if it's used directly here.
// import 'package:scout/domain/entities/activityTranslation.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchActivities();
    });
  }

  Future<void> _fetchActivities() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminActivityProvider = Provider.of<AdminActivityProvider>(
      context,
      listen: false,
    );
    if (authProvider.token != null) {
      await adminActivityProvider.fetchActivities(authProvider.token!);
      if (adminActivityProvider.errorMessage != null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(adminActivityProvider.errorMessage!)),
        );
      }
    }
  }

  void _showAddEditActivityDialog({Activity? activityToEdit}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddEditActivityDialog(
          activityToEdit: activityToEdit,
          onActivitySubmitted:
              _fetchActivities, // Refresh list after submission
        );
      },
    );
  }

  void _confirmDeleteActivity(String activityId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
            'Are you sure you want to delete this activity? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                final adminActivityProvider =
                    Provider.of<AdminActivityProvider>(context, listen: false);
                if (authProvider.token != null) {
                  bool success = await adminActivityProvider.deleteActivity(
                    activityId,
                    authProvider.token!,
                  );
                  if (success) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Activity deleted successfully!'),
                      ),
                    );
                    _fetchActivities(); // Refresh list
                  } else if (adminActivityProvider.errorMessage != null) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(adminActivityProvider.errorMessage!),
                      ),
                    );
                  }
                }
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Welcome, ${authProvider.username ?? 'Admin'}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.logout();
            },
          ),
        ],
      ),
      body: Consumer<AdminActivityProvider>(
        builder: (context, adminActivityProvider, child) {
          if (adminActivityProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (adminActivityProvider.errorMessage != null) {
            return Center(
              child: Text('Error: ${adminActivityProvider.errorMessage!}'),
            );
          } else if (adminActivityProvider.activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No activities found.'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditActivityDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Activity'),
                  ),
                ],
              ),
            );
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddEditActivityDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Activity'),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: adminActivityProvider.activities.length,
                    itemBuilder: (context, index) {
                      final activity = adminActivityProvider.activities[index];
                      // Display EN title for admin, or AR if EN is missing
                      final displayTitle =
                          activity.translations['en']?.title ??
                          activity.translations['ar']?.title ??
                          'No Title';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (activity.pics.isNotEmpty)
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 16.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      // Ensure this URL matches how your backend serves static files
                                      // e.g., 'http://localhost:5000/uploads/image.png'
                                      image: NetworkImage(
                                        activity.pics.first,
                                      ), // Use URL directly
                                      fit: BoxFit.cover,
                                      onError: (exception, stackTrace) =>
                                          const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayTitle,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Date: ${activity.date}'),
                                    const SizedBox(height: 8),
                                    Text(
                                      activity
                                              .translations['en']
                                              ?.description ??
                                          activity
                                              .translations['ar']
                                              ?.description ??
                                          'No Description',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _showAddEditActivityDialog(
                                      activityToEdit: activity,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _confirmDeleteActivity(activity.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

// --- Add/Edit Activity Dialog ---
class AddEditActivityDialog extends StatefulWidget {
  final Activity? activityToEdit;
  final VoidCallback onActivitySubmitted;

  const AddEditActivityDialog({
    super.key,
    this.activityToEdit,
    required this.onActivitySubmitted,
  });

  @override
  State<AddEditActivityDialog> createState() => _AddEditActivityDialogState();
}

class _AddEditActivityDialogState extends State<AddEditActivityDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _titleEnController = TextEditingController();
  final _descriptionEnController = TextEditingController();
  final _titleArController = TextEditingController();
  final _descriptionArController = TextEditingController();

  // List of controllers for image URLs
  final List<TextEditingController> _imageUrlControllers = [];

  bool get _isEditing => widget.activityToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final activity = widget.activityToEdit!;
      _dateController.text = activity.date;
      _titleEnController.text = activity.translations['en']?.title ?? '';
      _descriptionEnController.text =
          activity.translations['en']?.description ?? '';
      _titleArController.text = activity.translations['ar']?.title ?? '';
      _descriptionArController.text =
          activity.translations['ar']?.description ?? '';

      // Populate image URL controllers with existing URLs
      if (activity.pics.isNotEmpty) {
        for (var url in activity.pics) {
          _imageUrlControllers.add(TextEditingController(text: url));
        }
      } else {
        // Start with one empty controller if no existing pics
        _imageUrlControllers.add(TextEditingController());
      }
    } else {
      // For new activity, start with one empty image URL controller
      _imageUrlControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _titleEnController.dispose();
    _descriptionEnController.dispose();
    _titleArController.dispose();
    _descriptionArController.dispose();
    for (var controller in _imageUrlControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addImageUrlField() {
    setState(() {
      _imageUrlControllers.add(TextEditingController());
    });
  }

  void _removeImageUrlField(int index) {
    setState(() {
      _imageUrlControllers[index].dispose(); // Dispose the controller
      _imageUrlControllers.removeAt(index);
      if (_imageUrlControllers.isEmpty) {
        // Ensure at least one field remains
        _imageUrlControllers.add(TextEditingController());
      }
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final adminActivityProvider = Provider.of<AdminActivityProvider>(
        context,
        listen: false,
      );
      String? token = authProvider.token;

      if (token == null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Authentication token not found. Please log in again.',
            ),
          ),
        );
        return;
      }

      // Collect all image URLs from the text controllers, filtering out empty ones
      final List<String> imageUrlsToSubmit = _imageUrlControllers
          .map((controller) => controller.text.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      bool success;
      if (_isEditing) {
        success = await adminActivityProvider.updateActivity(
          activityId: widget.activityToEdit!.id,
          date: _dateController.text,
          titleEn: _titleEnController.text,
          descriptionEn: _descriptionEnController.text,
          titleAr: _titleArController.text,
          descriptionAr: _descriptionArController.text,
          imageUrls: imageUrlsToSubmit, // Send URLs
          token: token,
        );
      } else {
        success = await adminActivityProvider.createActivity(
          date: _dateController.text,
          titleEn: _titleEnController.text,
          descriptionEn: _descriptionEnController.text,
          titleAr: _titleArController.text,
          descriptionAr: _descriptionArController.text,
          imageUrls: imageUrlsToSubmit, // Send URLs
          token: token,
        );
      }

      if (success) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Activity updated successfully!'
                  : 'Activity created successfully!',
            ),
          ),
        );
        widget.onActivitySubmitted(); // Callback to refresh the list
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(); // Close dialog
      } else if (adminActivityProvider.errorMessage != null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(adminActivityProvider.errorMessage!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminActivityProvider = Provider.of<AdminActivityProvider>(context);

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Activity' : 'Add New Activity'),
      // Remove the SizedBox around ListView.builder and put the children directly in Column
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Crucial for dialogs
            children: [
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (e.g., July 15 - 25, 2024)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'English Translation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _titleEnController,
                decoration: const InputDecoration(labelText: 'Title (English)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter English title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionEnController,
                decoration: const InputDecoration(
                  labelText: 'Description (English)',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter English description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Arabic Translation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _titleArController,
                decoration: const InputDecoration(labelText: 'Title (Arabic)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Arabic title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionArController,
                decoration: const InputDecoration(
                  labelText: 'Description (Arabic)',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Arabic description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Image URLs',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // Directly map controllers to TextFormFields inside the Column
              // No ListView.builder here
              ..._imageUrlControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Image URL ${index + 1}',
                            hintText: 'https://example.com/image.jpg',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            // Validate if it's a URL, but allow empty if not needed
                            if (value!.isNotEmpty) {
                              try {
                                final uri = Uri.parse(value);
                                if (!uri.isAbsolute) {
                                  return 'Please enter a valid absolute URL (e.g., starts with http:// or https://)';
                                }
                              } catch (e) {
                                return 'Invalid URL format';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      if (_imageUrlControllers.length >
                          1) // Allow removing if more than one field
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          onPressed: () => _removeImageUrlField(index),
                        ),
                    ],
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _addImageUrlField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add another URL'),
                ),
              ),
              if (_imageUrlControllers.any(
                (controller) => controller.text.isNotEmpty,
              ))
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Total image URLs: ${_imageUrlControllers.where((controller) => controller.text.isNotEmpty).length}',
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: adminActivityProvider.isLoading ? null : _submitForm,
          child: adminActivityProvider.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(_isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
