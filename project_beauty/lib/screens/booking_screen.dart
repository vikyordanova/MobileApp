import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final List<Map<String, String>> _procedures = [
    {'name': 'Подстригване', 'price': '35–40–45'},
    {'name': 'Сешоар', 'price': '30–35–40'},
    {'name': 'Подстригване + сешоар', 'price': '40–45–50'},
    {'name': 'Боядисване на цяла коса', 'price': '70–110'},
    {'name': 'Боядисване на корен', 'price': '60–70'},
    {'name': 'Кичури + сешоар + матиране', 'price': 'от 150'},
    {'name': 'Балеаж + сешоар + матиране', 'price': 'от 150'},
    {'name': 'Пигментиране', 'price': 'от 60'},
    {'name': 'Тониране', 'price': 'от 60'},
    {'name': 'Боядисване Air touch', 'price': 'от 170'},
    {'name': 'Боядисване с Иноа', 'price': 'от 80'},
    {'name': 'Боядисване с мажирел', 'price': 'от 70'},
    {'name': 'Обезцветяване на корен', 'price': 'от 110'},
    {'name': 'Официални прически', 'price': 'от 60'},
    {'name': 'Маша', 'price': 'от 40'},
  ];

  final List<String> _timeOptions = List.generate(9, (index) {
    final hour = 10 + index; // От 10 до 18 включително
    return '${hour.toString().padLeft(2, '0')}:00';
  });


  Map<String, String>? selectedProcedure;
  DateTime? selectedDate;
  String? selectedTime;

  final Color primaryColor = const Color(0xFF895D50);

  void _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      selectableDayPredicate: (DateTime day) {
        return day.weekday != DateTime.sunday;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF895D50),
              onPrimary: Colors.white,
              onSurface: Color(0xFF895D50),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF895D50),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> _saveBooking() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не сте влезли в акаунта.')),
        );
        return;
      }

      final bookingData = {
        'procedure': selectedProcedure?['name'],
        'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
        'time': selectedTime,
        'timestamp': Timestamp.now(),
        'userId': user.uid,
      };

      final snapshot = await FirebaseFirestore.instance
          .collection('global_reservations')
          .where('date', isEqualTo: bookingData['date'])
          .where('time', isEqualTo: bookingData['time'])
          .get();

      if (snapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Този час вече е запазен!')),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(user.uid)
          .collection('reservations')
          .add(bookingData);

      await FirebaseFirestore.instance
          .collection('global_reservations')
          .add(bookingData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Успешно запазихте час!')),
      );

      setState(() {
        selectedProcedure = null;
        selectedDate = null;
        selectedTime = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Възникна грешка при запазването.')),
      );
    }
  }

  Widget _buildTimeDropdown() {
    return Container(
      width: 160,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedTime,
          hint: const Text(
            'Избери час',
            style: TextStyle(color: Colors.white),
          ),
          dropdownColor: Colors.white,
          iconEnabledColor: Colors.white,
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
          onChanged: (String? newValue) {
            setState(() {
              selectedTime = newValue;
            });
          },
          selectedItemBuilder: (context) {
            return _timeOptions.map((time) {
              return Align(
                alignment: Alignment.center,
                child: Text(
                  textAlign: TextAlign.center,
                  selectedTime ?? 'Избери час',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            }).toList();
          },
          items: _timeOptions.map((String time) {
            return DropdownMenuItem<String>(
              value: time,
              child: Text(
                time,
                style: TextStyle(color: primaryColor),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Запази час', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/color_bar.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.white60, BlendMode.lighten),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Каква процедура желаете?',
                    style: TextStyle(
                      fontFamily: 'Playfair',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButton<Map<String, String>>(
                      value: selectedProcedure,
                      hint: const Text('Избери процедура'),
                      isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: (newValue) {
                        setState(() => selectedProcedure = newValue);
                      },
                      items: _procedures.map((procedure) {
                        return DropdownMenuItem<Map<String, String>>(
                          value: procedure,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(procedure['name']!)),
                              Text(
                                procedure['price']!,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _pickDate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          fixedSize: const Size(160, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          selectedDate != null
                              ? DateFormat('dd.MM.yyyy').format(selectedDate!)
                              : 'Избери дата',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      _buildTimeDropdown(),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (selectedProcedure != null &&
                          selectedDate != null &&
                          selectedTime != null)
                          ? _saveBooking
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Запази',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '*Неделя - почивен ден*',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: primaryColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
