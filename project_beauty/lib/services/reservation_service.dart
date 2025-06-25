import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReservationService {
  static Future<void> createReservation(DateTime reservationTime) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance.collection('reservations').add({
      'userId': user.uid,
      'timestamp': Timestamp.fromDate(reservationTime),
    });
  }
}
