

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/worker/view_acceptwork.dart';
import 'package:untitled1/worker/view_payment.dart';
import 'package:untitled1/worker/view_rejectwork.dart';
import 'package:untitled1/worker/view_request.dart';
import 'package:untitled1/worker/view_review.dart';
import 'package:untitled1/worker/view_workdetails.dart';
import 'package:untitled1/viewnotification.dart';
import '../login.dart';
import '../password.dart';
import 'add_workdetails.dart';
import 'view_workerprofile.dart';

class WorkerHomePage extends StatelessWidget {
  const WorkerHomePage({super.key});

  static const Color bgColor = Color(0xFF0D0D12);
  static const Color cardColor = Color(0xFF17171F);
  static const Color purple = Color(0xFF7C3AED);
  static const Color lightPurple = Color(0xFFA855F7);
  static const Color deepPurple = Color(0xFF4C1D95);
  static const Color whiteText = Colors.white;
  static const Color subText = Color(0xFFB8B8C2);
  static const Color borderColor = Color(0xFF2A2A35);

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? url = prefs.getString('url');
    await prefs.clear();
    if (url != null) {
      await prefs.setString('url', url);
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MyLoginPage(title: "Login"),
      ),
          (route) => false,
    );
  }

  Widget menuCard(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [purple, lightPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: purple.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: whiteText,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget actionButton(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: whiteText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.black,
      title: const Text(
        "Work Bridge",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ViewNotificationPage(),
            ),
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: () => logout(context),
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
        ),
      ],
    );
  }

  Widget buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF000000), Color(0xFF2E1065), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: const Column(
        children: [
          Icon(Icons.workspace_premium_rounded, size: 60, color: Colors.white),
          SizedBox(height: 12),
          Text(
            "Welcome Worker",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),


        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildTopHeader(),
              const SizedBox(height: 18),

              const SizedBox(height: 22),

              sectionTitle("Quick Actions"),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    actionButton(
                      context,
                      "Add Work Details",
                      Icons.add_circle_outline_rounded,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkerAddWorkPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    actionButton(
                      context,
                      "View My Work",
                      Icons.work_outline_rounded,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkerViewWorkPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              sectionTitle("Dashboard Menu"),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.05,
                  children: [
                    menuCard(
                      context,
                      Icons.person_outline_rounded,
                      "My Profile",
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkerProfilePage(),
                          ),
                        );
                      },
                    ),
                    menuCard(
                      context,
                      Icons.business_center_outlined,
                      "Manage Work",
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkerViewWorkPage(),
                          ),
                        );
                      },
                    ),
                    menuCard(
                      context,
                      Icons.mark_email_unread_outlined,
                      "View Request",
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkerViewRequests(),
                          ),
                        );
                      },
                    ),
                    menuCard(
                      context,
                      Icons.check_circle_outline_rounded,
                      "View Accept Work",
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AcceptedWorkPage(),
                          ),
                        );
                      },
                    ),
                    menuCard(
                      context,
                      Icons.cancel_outlined,
                      "View Reject Work",
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RejectedWorkPage(),
                          ),
                        );
                      },
                    ),
                    menuCard(
                      context,
                      Icons.lock_outline_rounded,
                      "Change Password",
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const changepassword(title: ''),
                          ),
                        );
                      },
                    ),
                    menuCard(
                      context,
                      Icons.account_balance_wallet_outlined,
                      "View Payment",
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkerViewPaymentsPage(),
                          ),
                        );
                      },
                    ),
                    menuCard(
                      context,
                      Icons.reviews_outlined,
                      "View Review",
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkerViewReviewsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}