import 'package:cloud_firestore/cloud_firestore.dart';

class DummyFaultService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to simulate a fault
  Future<void> simulateFault() async {
    try {
      await _firestore.collection('faults').add({
        'pairName': 'Pole A & B',
        'location': 'Main Street',
        'status': 'fault',
        'timestamp': FieldValue.serverTimestamp(),
        'notified': false,
      });
      print("Fault added to Firestore");
    } catch (e) {
      print("Error adding fault: $e");
    }
  }
  
  // Simulate multiple faults
  Future<void> simulateMultipleFaults() async {
    for (int i = 0; i < 3; i++) {
      await simulateFault();
    }
  }
}
