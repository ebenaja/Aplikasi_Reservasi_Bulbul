import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ImagePickerHelper {
  /// Menampilkan dialog pilihan sumber gambar
  /// Returns: File gambar atau null jika dibatalkan
  static Future<File?> pickImageWithOptions(BuildContext context) async {
    File? selectedImage;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Pilih Sumber Gambar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              
              // OPSI 1: Galeri / Google Foto
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.blue),
                ),
                title: const Text("Galeri/Google Foto"),
                subtitle: const Text("Pilih dari penyimpanan atau cloud"),
                onTap: () async {
                  Navigator.pop(context);
                  selectedImage = await _pickFromGallery();
                },
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              const Divider(),

              // OPSI 2: Kamera
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.green),
                ),
                title: const Text("Ambil Foto"),
                subtitle: const Text("Gunakan kamera HP"),
                onTap: () async {
                  Navigator.pop(context);
                  selectedImage = await _pickFromCamera();
                },
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ],
          ),
        );
      },
    );

    return selectedImage;
  }

  /// Mengambil gambar dari Galeri (termasuk Google Foto)
  static Future<File?> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      print("Error Pick Gallery: $e");
    }
    return null;
  }

  /// Mengambil gambar dari Kamera
  static Future<File?> _pickFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      print("Error Pick Camera: $e");
    }
    return null;
  }

  /// Shortcut: Langsung buka galeri tanpa dialog
  static Future<File?> pickImageSimple() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      print("Error Pick Simple: $e");
    }
    return null;
  }
}
