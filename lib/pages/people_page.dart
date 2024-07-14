import 'package:Galaxy/provider/people_provider.dart';
import 'package:Galaxy/views/forms/add_person.dart';
import 'package:Galaxy/views/overview/people_overview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  PeoplePageState createState() => PeoplePageState();
}

class PeoplePageState extends State<PeoplePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _selectedIndex = 0;
        Provider.of<PeopleProvider>(context, listen: false).refreshPeople();
        _checkAndShowBanner();
      }
    });
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _checkAndShowBanner() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool bannerShown = prefs.getBool('bannerShown') ?? false;
    if (!bannerShown && mounted) {
      _showMaterialBanner();
      await prefs.setBool('bannerShown', true);
    }
  }

  void _showMaterialBanner() {
    if (mounted) {
      _clearMaterialBanner();
      ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
        padding: const EdgeInsets.all(16),
        leading: const Icon(Icons.info, color: Colors.black, size: 32),
        backgroundColor: Colors.white,
        content: const Text(
            'All details are stored on your phone or cloud of your choice and not on our servers.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => _clearMaterialBanner(),
          )
        ],
      ));
    }
  }

  void _clearMaterialBanner() {
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    PeopleProvider peopleProvider = Provider.of<PeopleProvider>(context);
    final personList = peopleProvider.personList;
    return Scaffold(
      body: _selectedIndex == 0
          ? PeopleOverview(personList: personList)
          : const AddPersonView(),
      bottomNavigationBar: PeopleNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class PeopleNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const PeopleNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final peopleProvider = Provider.of<PeopleProvider>(context);

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemTapped,
      destinations: <NavigationDestination>[
        NavigationDestination(
          selectedIcon: const Icon(Icons.people),
          icon: const Icon(Icons.people_alt_outlined),
          label: 'All People (${peopleProvider.personList.length})',
        ),
        const NavigationDestination(
          selectedIcon: Icon(Icons.person_add_rounded),
          icon: Icon(Icons.person_add_outlined),
          label: 'Add New',
        ),
      ],
    );
  }
}
