
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/user/send_complaint.dart';
import 'package:untitled1/user/send_review.dart';
import 'package:untitled1/user/view_complaint.dart';
import 'package:untitled1/user/view_nearbyworkers.dart';
import 'package:untitled1/viewnotification.dart';
import 'package:untitled1/user/view_payment.dart';
import 'package:untitled1/user/view_requeststatus.dart';
import 'package:untitled1/user/view_review.dart';
import 'package:untitled1/user/view_workers.dart';
import 'profile.dart';
import 'package:untitled1/login.dart';
import 'package:untitled1/password.dart';

/// Centralized theme colors – now in green!
class AppTheme {
  static const Color primary = Color(0xFF0B1F3A);      // Rich green
  static const Color primaryDark = Color(0xFF1E3A8A); // Darker green for gradient
  static const Color background = Color(0xFF1B2A41);
  static const Color cardShadow = Colors.black12;
}

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  /// Logout with confirmation dialog
  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    await prefs.clear();
    if (url != null) {
      await prefs.setString('url', url);
    }

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyLoginPage(title: "Login")),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ViewNotificationPage()),
          ),
        ),
        title: const Text(
          "User Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 20),
            _buildGrid(context),
          ],
        ),
      ),
    );
  }

  /// Welcome card with green gradient
  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(blurRadius: 10, color: AppTheme.cardShadow, offset: Offset(0, 4))
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome User 👋",
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            "Manage all your services easily",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// Responsive grid of feature cards
  Widget _buildGrid(BuildContext context) {
    // Determine crossAxisCount based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 400 ? 2 : screenWidth < 600 ? 3 : 4;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.1,
      ),
      children: [
        _buildCard(
          context,
          "Profile",
          Icons.person,
          Colors.teal,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfilePage())),
        ),
        _buildCard(
          context,
          "Nearby Workers",
          Icons.location_on,
          Colors.blue,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewNearbyWorkers())),
        ),
        _buildCard(
          context,
          "View All Works",
          Icons.work,
          Colors.green,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserViewWorkPage())),
        ),
        _buildCard(
          context,
          "Request Status",
          Icons.assignment,
          Colors.indigo,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewRequestStatusPage())),
        ),
        _buildCard(
          context,
          "Payment",
          Icons.payment,
          Colors.purple,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewPaymentHistoryPage())),
        ),
        _buildCard(
          context,
          "Send Complaint",
          Icons.report_problem,
          Colors.orange,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => SendComplaintPage())),
        ),
        _buildCard(
          context,
          "View Complaint",
          Icons.visibility,
          Colors.deepOrange,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewComplaintPage())),
        ),
        _buildCard(
          context,
          "Send Review",
          Icons.star,
          Colors.amber,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => SendReviewPage())),
        ),
        _buildCard(
          context,
          "View Review",
          Icons.reviews,
          Colors.brown,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewReviewPage())),
        ),
        _buildCard(
          context,
          "Change Password",
          Icons.lock,
          Colors.red,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => changepassword(title: ""))),
        ),
      ],
    );
  }

  /// Individual feature card with ripple effect
  Widget _buildCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: Offset(0, 3))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
