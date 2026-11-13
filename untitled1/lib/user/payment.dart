import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view_requeststatus.dart';

class PaymentPage extends StatefulWidget {
  final String amount;
  final String worker_id;

  const PaymentPage({super.key, required this.amount, required this.worker_id});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ---------------- PAYMENT CALLBACKS ----------------

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _isProcessing = false;
    _sendData();

    Fluttertoast.showToast(
      msg: "Payment Successful ✅",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _isProcessing = false;

    print("RAZORPAY ERROR CODE: ${response.code}");
    print("RAZORPAY ERROR MESSAGE: ${response.message}");

    Fluttertoast.showToast(
      msg: "Payment Failed ❌",
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _isProcessing = false;
    Fluttertoast.showToast(
      msg: "Wallet: ${response.walletName}",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  // ---------------- OPEN RAZORPAY ----------------

  void _openCheckout() {
    setState(() => _isProcessing = true);

    var options = {
      'key': 'rzp_test_HKCAwYtLt0rwQe',
      'amount': (double.parse(widget.amount) * 100).round(),
      'name': 'MindWell',
      'description': 'Mental Wellness Service Payment',
      'prefill': {'contact': '9876543210', 'email': 'support@mindwell.in'},
      'theme': {'color': '#6A1B9A'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _isProcessing = false;
      Fluttertoast.showToast(
        msg: "Payment initialization failed",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // ---------------- SEND DATA TO BACKEND ----------------

  void _sendData() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? '';
    String lid = sh.getString('lid') ?? '';

    try {
      var response = await http.post(
        Uri.parse('$url/make_payment/'),
        body: {'lid': lid, 'request_id': widget.worker_id,'amount':widget.amount.toString()},
      );

      var data = jsonDecode(response.body);

      if (data['status'] == 'ok') {
        Fluttertoast.showToast(
          msg: 'Payment recorded successfully 🧠',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ViewRequestStatusPage()),
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Payment successful, but server update failed',
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Network error',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    double amount = double.tryParse(widget.amount) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: Column(children: [_header(), Expanded(child: _content(amount))]),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          const Text(
            "MindWell",
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

  Widget _content(double amount) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.2),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFFBA68C8)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "₹${amount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Wellness Service Fee",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                const Text(
                  "MindWell – Mental Wellness Platform",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock, color: Colors.purple),
                    SizedBox(width: 8),
                    Text(
                      "Secure & Confidential Payment",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _openCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon:
              _isProcessing
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.psychology, color: Colors.white),
              label: Text(
                _isProcessing ? "Processing..." : "Pay MindWell Fee",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}