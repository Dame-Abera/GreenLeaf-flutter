import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user.dart';
import 'package:intl/intl.dart'; // For date formatting

class UserDetailPage extends ConsumerWidget {
  final User user;

  const UserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty
                    ? NetworkImage(user.profileImage!) as ImageProvider
                    : const AssetImage('assets/plant_placeholder.jpg'), // Placeholder
                child: (user.profileImage == null || user.profileImage!.isEmpty)
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Name:', '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim()),
            _buildDetailRow('Email:', user.email),
            _buildDetailRow('Birthdate:', user.birthdate != null ? DateFormat('yyyy-MM-dd').format(user.birthdate!) : 'N/A'),
            _buildDetailRow('Gender:', user.gender ?? 'N/A'),
            _buildDetailRow('Phone Number:', user.phoneNumber ?? 'N/A'),
            _buildDetailRow('Account Status:', user.isActive ? 'Active' : 'Inactive'),
            _buildDetailRow('Role:', user.isSuperuser ? 'Superuser' : (user.isStaff ? 'Staff' : 'Regular User')),
            
            const SizedBox(height: 32),
            // TODO: Add Edit/Deactivate/Delete buttons for admin actions
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
} 