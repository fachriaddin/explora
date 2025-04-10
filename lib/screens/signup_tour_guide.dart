import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appwrite/models.dart' as models;
import 'package:uuid/uuid.dart';
import '../../services/appwrite_service.dart';
import 'package:appwrite/appwrite.dart';


class SignUpTourGuideScreen extends StatefulWidget {
  const SignUpTourGuideScreen({super.key});

  @override
  State<SignUpTourGuideScreen> createState() => _SignUpTourGuideScreenState();
}

class _SignUpTourGuideScreenState extends State<SignUpTourGuideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _experienceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();

  XFile? _profileImage;
  XFile? _documentImage;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _isUploadingImages = false;

  Future<void> _pickImage(bool isDocument) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isDocument) {
          _documentImage = pickedFile;
        } else {
          _profileImage = pickedFile;
        }
      });
    }
  }

  Future<String?> _uploadToAppwrite(XFile file, String bucketId) async {
    try {
      final bytes = await file.readAsBytes();
      final fileId = const Uuid().v4();

      final result = await AppwriteService.storage.createFile(
        bucketId: bucketId,
        fileId: fileId,
        file: InputFile.fromBytes(
          bytes: bytes,
          filename: file.name,
        ),
      );

      return result.$id;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_profileImage == null || _documentImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload profile and document images.')),
      );
      return;
    }

    try {
      final userId = const Uuid().v4();

      await AppwriteService.account.create(
        userId: userId,
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final photoId = await _uploadToAppwrite(_profileImage!, 'tour-guide-photos');
      final documentId = await _uploadToAppwrite(_documentImage!, 'tour-guide-assets');

      await AppwriteService.database.createDocument(
        databaseId: '67f77b600033c8cf4277',
        collectionId: '67f77b6e003955589fdc',
        documentId: userId,
        data: {
          'uid': userId,
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'experience': _experienceController.text,
          'description': _descriptionController.text,
          'city': _cityController.text,
          'photo_id': photoId,
          'document_id': documentId,
          'created_at': DateTime.now().toIso8601String(),
          'verified': false,
          'status': 'Pending Verification',
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully signed up as tour guide!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  ImageProvider? _getImageProvider(XFile? file) {
    if (file == null) return null;
    if (kIsWeb) return NetworkImage(file.path);
    return FileImage(File(file.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Sign Up as a Tour Guide'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _pickImage(false),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _getImageProvider(_profileImage),
                  child: _profileImage == null
                      ? const Icon(Icons.camera_alt, color: Colors.white54, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _pickImage(true),
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload KTP/SIM'),
              ),
              const SizedBox(height: 10),
              if (_documentImage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white10),
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: _getImageProvider(_documentImage!)!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              _buildTextField(_nameController, 'Full Name'),
              _buildTextField(_emailController, 'Email', TextInputType.emailAddress),
              _buildTextField(_phoneController, 'Phone Number', TextInputType.phone),
              _buildPasswordField(),
              _buildTextField(_cityController, 'City'),
              _buildTextField(_experienceController, 'Experience (optional)', TextInputType.text, false, false),
              _buildTextField(_descriptionController, 'Description', TextInputType.multiline, true),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      [TextInputType keyboardType = TextInputType.text,
      bool multiline = false,
      bool required = true]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: multiline ? null : 1,
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'Please enter $hint';
          }
          return null;
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter Password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.white54,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }
}
