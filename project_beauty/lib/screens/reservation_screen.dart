import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchReservations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .doc(user.uid)
        .collection('reservations')
        .get();

    final reservations = snapshot.docs.map((doc) => doc.data()).toList();

    // ✅ Сортираме ръчно по дата и час
    reservations.sort((a, b) {
      final aDateTime = DateFormat('yyyy-MM-dd HH:mm').parse('${a['date']} ${a['time']}');
      final bDateTime = DateFormat('yyyy-MM-dd HH:mm').parse('${b['date']} ${b['time']}');
      return aDateTime.compareTo(bDateTime);
    });

    return reservations;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF895D50);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Моите резервации',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Нямате запазени часове.'),
            );
          }
          final reservations = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              final procedure = reservation['procedure'];
              final String dateStr = reservation['date']; // '2025-06-19'
              final String timeStr = reservation['time']; // '19:30'
              final DateTime reservationDateTime = DateFormat('yyyy-MM-dd HH:mm').parse('$dateStr $timeStr');
              final bool isPast = reservationDateTime.isBefore(DateTime.now());

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isPast ? Colors.grey.shade200 : Colors.brown.shade50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(
                    isPast ? Icons.history : Icons.schedule,
                    color: primaryColor,
                  ),
                  title: Text(
                    procedure,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPast ? Colors.grey : Colors.black,
                      decoration: isPast ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    '${reservationDateTime.day.toString().padLeft(2, '0')}.${reservationDateTime.month.toString().padLeft(2, '0')}.${reservationDateTime.year} в ${reservationDateTime.hour.toString().padLeft(2, '0')}:${reservationDateTime.minute.toString().padLeft(2, '0')} ч.',
                    style: TextStyle(
                      color: isPast ? Colors.grey : Colors.black,
                    ),
                  ),
                  trailing: isPast
                      ? const Text(
                    'Минал час',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
