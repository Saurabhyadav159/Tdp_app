// import 'package:flutter/material.dart';
// import 'package:poster/features/dashboard/presentation/profile.dart';
// import '../../../config/colors.dart';
// import '../../../notifications/presentation/notification_screen.dart';
// import '../home/presentation/home.dart';
// import 'SecretScreen.dart';
// import 'downloads.dart';
//
// class Dashboard extends StatefulWidget {
//   const Dashboard({super.key});
//
//   @override
//   State<Dashboard> createState() => _DashboardState();
// }
//
// class _DashboardState extends State<Dashboard> {
//   int _selectedIndex = 0;
//
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     FileSelectionScreen(),
//     ProfileScreen(),
//   ];
//
//   // Define your icon paths for selected and unselected states
//   final List<Map<String, String>> _navIcons = [
//     {
//       'selected': 'assets/home_selected.png', // Make sure these assets exist
//       'unselected': 'assets/home.png',
//     },
//     {
//       'selected': 'assets/downloads_selected.png',
//       'unselected': 'assets/downloads.png',
//     },
//     {
//       'selected': 'assets/profile_selected.png',
//       'unselected': 'assets/profile.png',
//     },
//   ];
//
//   Future<bool> _onWillPop() async {
//     bool? exit = await showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => _buildExitConfirmation(),
//     );
//     return exit ?? false;
//   }
//
//   Widget _buildExitConfirmation() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Text(
//             "Exit Alert",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Are you sure you want to exit?",
//             style: TextStyle(fontSize: 16),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.of(context).pop(true),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text("Yes"),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.of(context).pop(false),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.black,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     side: const BorderSide(color: Colors.black),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text("No"),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: SharedColors.dialogBorderColor,
//         appBar: AppBar(
//           backgroundColor: SharedColors.buttonTextColor,
//           actions: [
//             IconButton(
//               iconSize: 20,
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(builder: (_) => SecretScreen()),
//                 );
//               },
//               icon: const Icon(Icons.search, color: SharedColors.primary),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(builder: (_) => const NotificationScreen()),
//                 );
//               },
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: SharedColors.primaryDark,
//                     border: Border.all(
//                       color: SharedColors.buttonBorderColor,
//                       width: 0.5,
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                   alignment: Alignment.center,
//                   child: const Icon(
//                     Icons.notifications_outlined,
//                     color: SharedColors.buttonBorderColor,
//                     size: 16,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         body: SafeArea(
//           child: _screens[_selectedIndex],
//         ),
//         bottomNavigationBar: Container(
//           height: 75,
//           decoration: BoxDecoration(
//             color: SharedColors.buttonTextColor,
//             border: Border(
//               top: BorderSide(
//                 color: Colors.grey.shade300,
//                 width: 0.5,
//               ),
//             ),
//           ),
//           child: BottomNavigationBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             items: [
//               _buildBottomNavItem(0, "Home"),
//               _buildBottomNavItem(1, "Downloads"),
//               _buildBottomNavItem(2, "Profile"),
//             ],
//             currentIndex: _selectedIndex,
//             selectedItemColor: SharedColors.primary,
//             unselectedItemColor: Colors.black,
//             showSelectedLabels: false,
//             showUnselectedLabels: false,
//             onTap: (value) {
//               setState(() {
//                 _selectedIndex = value;
//               });
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   BottomNavigationBarItem _buildBottomNavItem(int index, String label) {
//     final isSelected = _selectedIndex == index;
//     final iconPath = isSelected
//         ? _navIcons[index]['selected']!
//         : _navIcons[index]['unselected']!;
//
//     return BottomNavigationBarItem(
//       icon: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: isSelected ? SharedColors.primary : Colors.transparent,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Image.asset(
//           iconPath,
//           width: 20,
//           height: 20,
//           color: isSelected ? Colors.white : null, // Optional: force white color when selected
//         ),
//       ),
//       label: label,
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:poster/features/dashboard/presentation/profile.dart';
import '../../../config/colors.dart';
import '../../../notifications/presentation/notification_screen.dart';
import '../home/presentation/home.dart';
import 'SecretScreen.dart';
import 'downloads.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  bool _isNotificationClicked = false;
  final List<GlobalKey<RefreshIndicatorState>> _refreshIndicatorKeys = [
    GlobalKey<RefreshIndicatorState>(),
    GlobalKey<RefreshIndicatorState>(),
    GlobalKey<RefreshIndicatorState>(),
  ];

  final List<Widget> _screens = [
    const HomeScreen(), // HomeScreen must internally pass `context` to `getBanners(context: context)`
    FileSelectionScreen(),
    ProfileScreen(),
  ];

  // Wrapped screens with RefreshIndicator
  List<Widget> get _refreshableScreens => [
    RefreshIndicator(
      key: _refreshIndicatorKeys[0],
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() {});
      },
      child: _screens[0],
    ),
    RefreshIndicator(
      key: _refreshIndicatorKeys[1],
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() {});
      },
      child: _screens[1],
    ),
    RefreshIndicator(
      key: _refreshIndicatorKeys[2],
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() {});
      },
      child: _screens[2],
    ),
  ];

  final List<Map<String, String>> _navIcons = [
    {'selected': 'assets/home_selected.png', 'unselected': 'assets/home.png'},
    {'selected': 'assets/downloads_selected.png', 'unselected': 'assets/downlode.png'},
    {'selected': 'assets/profile_selected.png', 'unselected': 'assets/profiles.png'},
  ];

  final String _notificationIcon = 'assets/alarm.png';
  final String _notificationIconClicked = 'assets/notification_selected.png';
  final String _searchIcon = 'assets/search.png';

  Future<bool> _onWillPop() async {
    bool? exit = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildExitConfirmation(),
    );
    return exit ?? false;
  }

  Widget _buildExitConfirmation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Exit Alert", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Are you sure you want to exit?", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Yes"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("No"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: SharedColors.dialogBorderColor,
        appBar: AppBar(
          backgroundColor: SharedColors.buttonTextColor,
          actions: [
            IconButton(
              iconSize: 20,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => SecretScreen()));
              },
              icon: Image.asset(
                _searchIcon,
                width: 20,
                height: 20,
                color: SharedColors.primary,
              ),
            ),
            IconButton(
              iconSize: 20,
              onPressed: () {
                setState(() => _isNotificationClicked = true);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                ).then((_) => setState(() => _isNotificationClicked = false));
              },
              icon: Image.asset(
                _isNotificationClicked ? _notificationIconClicked : _notificationIcon,
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: _refreshableScreens,
          ),
        ),
        bottomNavigationBar: Container(
          height: 75,
          decoration: BoxDecoration(
            color: SharedColors.buttonTextColor,
            border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: [
              _buildBottomNavItem(0, "Home"),
              _buildBottomNavItem(1, "Downloads"),
              _buildBottomNavItem(2, "Profile"),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: SharedColors.primary,
            unselectedItemColor: Colors.black,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: (value) {
              if (_selectedIndex == value) {
                _refreshIndicatorKeys[value].currentState?.show();
              }
              setState(() => _selectedIndex = value);
            },
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(int index, String label) {
    final isSelected = _selectedIndex == index;
    final iconPath = isSelected ? _navIcons[index]['selected']! : _navIcons[index]['unselected']!;

    return BottomNavigationBarItem(
      icon: Image.asset(iconPath, width: 24, height: 24, color: isSelected ? SharedColors.primary : Colors.grey),
      label: label,
    );
  }
}
