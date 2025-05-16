import 'package:flutter/material.dart';


class TermCondition extends StatefulWidget {
  @override
  _TermCondition createState() => _TermCondition();
}

class _TermCondition extends State<TermCondition> {

  final Color primaryColor = const Color(0xFF0A2342);
  final Color accentColor = Colors.amber;

  @override
  void initState() {
    super.initState();
  }
  Future<void> _handleBackButton() async {
    Navigator.of(context).pop();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Terms & Condition",style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: _handleBackButton,
        ),
      ),
      body: SafeArea(

        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '''1: These are the terms under which Africall Connect (Pvt) Limited (“Africall”, “us”, “we”) provide the ability to make calls to international numbers to Zimbabwe using our App (“Africall”).

2: If you have any queries, please contact us by phoning our Customer Services on +4474 584 3955 or emailing us on info@africallconnect.com. We’ve put some FAQs on our website too which you might find helpful for answering any questions you have.

3: AfriCall is an App that lets you make international calls to Zimbabwe from anywhere in the world at destination local rates. To use the service, the AfriCall App will use internet connection (Wi-Fi/Cellular Data) to make calls.

4: Your Africall Calling credit is valid while you still have the original credit you’ve paid for. Once you’ve recharged your account with credit, if you then don’t make a call for any period of 90 days, you’ll lose any remaining credit on your account.

5: Each time you use your Africall App, your remaining credit will be reduced by the charges for making a call to the number that you call and the amount of time you spend on the phone to that number. The charges to call all numbers are calculated by us using the call rates for Africall.

6: All calls using an Africall App are charged by the minute, rounded up to the nearest minute.

7: Call Rates are subject to change at any time. We do our best to make sure that Call Rates are correct and up to date. Check our website at www.africallconnect.com/rates for the latest rates.

8: If someone uses your Africall App without your permission, we can’t refund you any of the credit they use.

9: We’ll use the reasonable skill and care of a competent service provider to make the Africall calling services available. However, we can’t guarantee that they will always be fault-free. Some things will be out of our control, like overseas operators and the services of such network operators can be affected by things that we can’t control.

10: If we are in breach of these Terms & Conditions, we will only be responsible for any losses that you suffer as a result to the extent that they are a foreseeable consequence to both of us at the time you credit the Africall App, up to the price you paid for recharging your Africall account.

11: By using the service, you acknowledge that we are not responsible for providing (or maintaining) the equipment that you use to access the Africall calling Services or the national or international telecommunications networks which your calls travel across.

12: You must not use your Africall App for any unlawful or fraudulent purpose, to make any communication which is, or is intended to be, malicious, fraudulent or hoax (including to the emergency services), otherwise illegal or in any way which may damage or affect the operation of the Africall calling Services or any other telecommunications system.

13: If you give your phone to another person then when they use the Africall App to make calls, they will be subject to these Terms & Conditions.

14: We shall not be responsible for any breach of these Terms & Conditions caused by circumstances beyond our reasonable control.

15: These terms and conditions are governed by English law, and are subject to the jurisdiction of the English courts.

16: We will treat your data in line with our Privacy Policy''',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0E213D),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
