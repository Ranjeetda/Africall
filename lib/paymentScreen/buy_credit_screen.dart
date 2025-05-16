import 'package:flutter/material.dart';
import 'package:linphonesdk_example/paymentScreen/payment_screen.dart';

import '../resourse/image_paths.dart';

class BuyCreditScreen extends StatefulWidget {
  @override
  _BuyCreditScreen createState() => _BuyCreditScreen();
}

class _BuyCreditScreen extends State<BuyCreditScreen> {
  String? mAmount;
  int? selectedIndex;
  final Color primaryColor = const Color(0xFF0A2342); // dark navy

  @override
  Widget build(BuildContext context) {
    final List<String> amounts = [
      "\$5",
      "\$10",
      "\$15",
      "\$20",
      "\$25",
      "\$50"
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: Text('Buy Credit',style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(ImagePaths.connectLogo, height: 150,width: 150,),
                  const Text(
                    "How to Top-up\nVideo Guide",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.orange, fontSize: 18),
                  ),
                ],
              ),

            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Select a Top Up amount",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: amounts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return InkWell(
                  onTap: () {
                   setState(() {
                     mAmount = amounts[index];
                     selectedIndex = index;
                   });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                    ),
                    child: Text(
                      amounts[index],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.blue : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: ElevatedButton(
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(mAmount),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Center(
                child: Text(
                  "SUBMIT PAYMENT",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Image.asset(
              ImagePaths.paymentMethod,
              height: 50,
              width: 150,
            ),
          ),
        ],
      ),
    );
  }
}
