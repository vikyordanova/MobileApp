import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  final _commentController = TextEditingController();
  int _rating = 5;
  File? _selectedImage;
  bool _isSubmitting = false;
  final Color primaryColor = const Color(0xFF895D50);

  void _openSalonLocation() async {
    final Uri googleMapUrl = Uri.parse(
      'geo:42.6977,23.3219?q=42.6977,23.3219(Салон HairTime)',
    );

    final Uri fallbackWebUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=42.6977,23.3219',
    );

    // Проверяваме дали има приложение, което може да отвори geo URI
    if (await canLaunchUrl(googleMapUrl)) {
      await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(fallbackWebUrl)) {
      await launchUrl(fallbackWebUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Не може да се отвори нито едно приложение за карти.')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не е избрано изображение.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Грешка при избора на изображение.')),
      );
    }
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _rating == 0) return;

    setState(() => _isSubmitting = true);

    String? imageUrl;
    if (_selectedImage != null) {
      try {
        // Запазваме само path локално и го ползваме като визуализация или обработка, без Firebase Storage
        imageUrl = _selectedImage!.path;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Грешка при обработката на изображението.')),
        );
        setState(() => _isSubmitting = false);
        return;
      }
    }

    final review = {
      'userId': user.uid,
      'comment': _commentController.text,
      'rating': _rating,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('reviews').add(review);

    setState(() {
      _commentController.clear();
      _rating = 5;
      _selectedImage = null;
      _isSubmitting = false;
    });
  }

  Future<void> _deleteReview(String id) async {
    await FirebaseFirestore.instance.collection('reviews').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: const Text('За нас', style: TextStyle(color: Colors.white)),
            backgroundColor: primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Остави ревю',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Playfair',
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Напиши мнение...',
                      hintStyle: TextStyle(color: primaryColor.withOpacity(0.6)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                    style: TextStyle(color: primaryColor),
                  ),
                  const SizedBox(height: 12),
                  Text('Твоята оценка:',
                      style: TextStyle(
                        fontFamily: 'Playfair',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      )),
                  Row(
                    children: List.generate(
                      5,
                          (index) => IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: primaryColor,
                        ),
                        onPressed: () => setState(() => _rating = index + 1),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text('Направи снимка'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Публикувай',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Всички ревюта',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Playfair',
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 300,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('reviews')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            final docId = docs[index].id;

                            return Card(
                              color: Colors.brown.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: data['imageUrl'] != null
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(data['imageUrl']),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                    : const Icon(Icons.chat_bubble_outline, color: Colors.brown),
                                title: Text(
                                  data['comment'] ?? '',
                                  style: TextStyle(color: primaryColor),
                                ),
                                subtitle: Text(
                                  'Оценка: ${data['rating']} ⭐',
                                  style: TextStyle(color: primaryColor.withOpacity(0.8)),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.black),
                                  onPressed: () => _deleteReview(docId),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

        ),
        // 📍 Фиксиран бутон долу вдясно за локацията
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            tooltip: 'Локация на салона',
            onPressed: _openSalonLocation,
            backgroundColor: primaryColor,
            child: const Icon(Icons.location_on, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
