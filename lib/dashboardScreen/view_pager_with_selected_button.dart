import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linphonesdk_example/dashboardScreen/home_screen.dart';
import 'package:linphonesdk_example/resourse/Utils.dart';
import 'package:linphonesdk_example/resourse/app_colors.dart';
import 'package:provider/provider.dart';

import '../callLogScreen/call_log_screen.dart';
import '../contactScreen/contacts_page.dart';
import '../moreScreen/more_screen.dart';
import '../provider/flash_message_provider.dart';
import '../resourse/image_paths.dart';

class ViewPagerWithSelectedButton extends StatefulWidget {
  @override
  _ViewPagerWithSelectedButtonState createState() =>
      _ViewPagerWithSelectedButtonState();
}

class _ViewPagerWithSelectedButtonState extends State<ViewPagerWithSelectedButton> {
   final PageController _pageController = PageController();
  int _selectedIndex = 0;


  String? _selectedContact;
  DateTime? _refreshTime;


  void _onContactSelected(String contactName) {
    setState(() {
      _selectedContact = contactName;
      _refreshTime = DateTime.now();
      Utils.contactNumber='00'+contactName;
    });

    _pageController.jumpToPage(0); // Go to Home
  }

   List<Widget> get _pages => [
     HomeScreen(
       contactName: _selectedContact,
       refreshTrigger: _refreshTime,
     ),
     ContactsPage(onContactSelected: _onContactSelected),
     CallLogScreen(),
     MoreScreen(),
   ];


   @override
  Widget build(BuildContext context) {
    
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Africall Exit App'),
            content: Text('Do you really want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Stay in app
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Exit app
                child: Text('Yes'),
              ),
            ],
          ),
        );
        return shouldExit;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ImagePaths.backGround),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40), // 👈 Enough space for status bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () => _pageController.jumpToPage(0),
                      child: _topIcon(Icons.dialpad, "Dialpad", 0),
                    ),
                    InkWell(
                      onTap: () => _pageController.jumpToPage(1),
                      child: _topIcon(Icons.contacts, "Contacts", 1),
                    ),
                    InkWell(
                      onTap: () => _pageController.jumpToPage(2),
                      child: _topIcon(Icons.history, "Call logs", 2),
                    ),
                    InkWell(
                      onTap: () => _pageController.jumpToPage(3),
                      child: _topIcon(Icons.menu, "More", 3),
                    ),
                  ],
                ),
              ),
      
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: _pages,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom widget to display the icon with selected/deselected state
  Widget _topIcon(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;  // Check if this button is selected

    return  Container(
      width: 80, // equal width
      height: 80, // equal height
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.black : Colors.amber,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.amber : AppColors.black,
            size: 30,
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.amber : AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

  }

}



