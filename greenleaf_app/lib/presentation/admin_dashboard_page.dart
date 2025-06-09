import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/user_provider.dart'; // Import the user provider
import '../domain/user.dart'; // Import the User model
import 'home_page.dart'; // Import HomePage
import 'profile_page.dart'; // Import ProfilePage

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  late TextEditingController _searchController;
  String _searchQuery = '';
  int _selectedIndex = 0; // Added for bottom navigation

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Fetch users when the Admin Dashboard initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    // Filter users based on search query
    final filteredUsers = _searchQuery.isEmpty
        ? userState.users
        : userState.users.where((user) {
            final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.toLowerCase();
            final email = user.email.toLowerCase();
            final query = _searchQuery.toLowerCase();
            return fullName.contains(query) || email.contains(query);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Users'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: userState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : userState.error != null
                    ? Center(child: Text('Error: ${userState.error}', style: TextStyle(color: Colors.red)))
                    : filteredUsers.isEmpty
                        ? const Center(child: Text('No users found.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              return _userCard(user);
                            },
                          ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
            } else if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      ),
    );
  }

  Widget _userCard(User user) {
    Color roleColor;
    if (user.isSuperuser || user.isStaff) {
      roleColor = Colors.green; // ADMIN or STAFF will be green
    } else {
      roleColor = Colors.deepPurple; // Regular USER will be deep purple
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Further minimized vertical padding
        child: Row(
          children: [
            CircleAvatar(
              radius: 20, // Slightly smaller avatar
              backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty
                  ? NetworkImage(user.profileImage!) as ImageProvider
                  : const AssetImage('assets/plant_placeholder.jpg'),
              child: (user.profileImage == null || user.profileImage!.isEmpty)
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim().isEmpty
                        ? '${user.email}'
                        : '${user.firstName ?? ''} ${user.lastName ?? ''}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), // Slightly smaller font
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 11, color: Colors.grey), // Slightly smaller font
                  ),
                ],
              ),
            ),
            Chip(
              label: Text(user.isSuperuser ? 'ADMIN' : (user.isStaff ? 'STAFF' : 'USER')),
              backgroundColor: roleColor,
              labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
} 