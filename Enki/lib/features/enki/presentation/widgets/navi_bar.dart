// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

//import 'package:enki/core/themes/app_colors.dart';

class NaviBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const NaviBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
  return BottomNavigationBar(
  
 
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex, 
        onTap: onTap,
        items: const [ 
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.webhook_sharp),
          label: 'Network'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Account'
          ),
        ],
        // You would typically add an onTap handler to switch tabs
  );
  }



}
