import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'core/constants/enums.dart';
import 'firebase_options.dart';
import 'shared/models/user_model.dart';
import 'shared/models/event_model.dart';
import 'shared/models/supplier_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MaterialApp(home: SeedDataScreen()));
}

class SeedDataScreen extends StatefulWidget {
  const SeedDataScreen({super.key});

  @override
  State<SeedDataScreen> createState() => _SeedDataScreenState();
}

class _SeedDataScreenState extends State<SeedDataScreen> {
  bool _isLoading = false;
  String _status = 'Ready to seed. Click the button to start.';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Future<void> _seedDatabase() async {
    setState(() {
      _isLoading = true;
      _status = 'Seeding database...';
    });

    try {
      // 1. Seed Users
      setState(() => _status = 'Adding Users...');
      
      final String adminId = _uuid.v4();
      final adminUser = UserModel(
        id: adminId,
        name: 'Admin User',
        phone: '+201010000000',
        role: UserRole.admin,
        email: 'admin@candoo.app',
        profileImage: 'https://i.pravatar.cc/150?u=admin',
        createdBy: 'system',
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(adminId).set(adminUser.toFirestore());

      final String organizerId = _uuid.v4();
      final organizerUser = UserModel(
        id: organizerId,
        name: 'Mohammed Ali Organizer',
        phone: '+201210000000',
        role: UserRole.organizer,
        email: 'organizer@candoo.app',
        profileImage: 'https://i.pravatar.cc/150?u=organizer',
        createdBy: adminId,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(organizerId).set(organizerUser.toFirestore());

      // 2. Seed Events (Exhibitions)
      setState(() => _status = 'Adding Events...');
      final String event1Id = _uuid.v4();
      final event1 = EventModel(
        id: event1Id,
        title: 'TechX Egypt 2026',
        description: 'The largest technology exhibition in Egypt featuring AI, Web3, and startup pitches.',
        location: 'Cairo International Convention Centre',
        address: 'El-Nasr Rd, Al Estad, Nasr City, Cairo',
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 33)),
        tags: ['technology', 'ai', 'startups', 'egypt'],
        images: ['https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&q=80'],
        interestedCount: 300,
        boothCount: 50,
        organizerId: organizerId,
        organizerName: organizerUser.name,
        status: EventStatus.published,
        category: 'Technology',
        createdAt: DateTime.now(),
      );
      await _firestore.collection('events').doc(event1Id).set(event1.toFirestore());

      final String event2Id = _uuid.v4();
      final event2 = EventModel(
        id: event2Id,
        title: 'Candoo Global Trade Fair',
        description: 'A massive networking event for suppliers, decorators, and event planners.',
        location: 'Dubai World Trade Centre',
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        tags: ['trade', 'exhibition', 'business'],
        images: ['https://images.unsplash.com/photo-1551818255-e6e10975bc17?w=800&q=80'],
        interestedCount: 1200,
        boothCount: 150,
        organizerId: organizerId,
        organizerName: organizerUser.name,
        status: EventStatus.published,
        category: 'Business',
        createdAt: DateTime.now(),
      );
      await _firestore.collection('events').doc(event2Id).set(event2.toFirestore());

      // 3. Seed Suppliers
      setState(() => _status = 'Adding Suppliers...');
      final String supplier1Id = _uuid.v4();
      final supplier1 = SupplierModel(
        id: supplier1Id,
        name: 'Alpha Decorations',
        description: 'Premium booth decorators for high-end technology and trade exhibitions.',
        services: [SupplierCategories.decoration, SupplierCategories.furniture],
        category: SupplierCategories.decoration,
        images: ['https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=80'],
        ownerId: adminId,
        ownerName: 'Admin',
        contactEmail: 'contact@alphadecor.com',
        contactPhone: '+201111111111',
        rating: 4.8,
        reviewCount: 34,
        createdByAdmin: adminId,
        isVerified: true,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('suppliers').doc(supplier1Id).set(supplier1.toFirestore());

      final String supplier2Id = _uuid.v4();
      final supplier2 = SupplierModel(
        id: supplier2Id,
        name: 'TechSound A/V',
        description: 'Audio, visual equipments, microphones and big screens for event booths.',
        services: [SupplierCategories.audioVisual],
        category: SupplierCategories.audioVisual,
        images: ['https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?w=800&q=80'],
        ownerId: adminId,
        ownerName: 'Admin',
        contactEmail: 'sales@techsound.app',
        rating: 4.5,
        reviewCount: 12,
        createdByAdmin: adminId,
        isVerified: true,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('suppliers').doc(supplier2Id).set(supplier2.toFirestore());

      // End
      setState(() {
        _isLoading = false;
        _status = 'Database seeded successfully! You can now close this window and run the main app.';
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Error seeding database: $e';
      });
      print('Error during seeding: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Candoo Data Seeder')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _seedDatabase,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Start Seeding Data', style: TextStyle(fontSize: 18)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
