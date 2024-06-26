import 'dart:math';

import 'package:flutter/material.dart';
import 'package:galaxy/pages/accounts_page.dart';
import 'package:galaxy/pages/achivements_page.dart';
import 'package:galaxy/pages/assets_page.dart';
import 'package:galaxy/pages/documents_page.dart';
import 'package:galaxy/pages/expenses_page.dart';
import 'package:galaxy/pages/my_universe_page.dart';
import 'package:galaxy/pages/people_page.dart';
import 'package:galaxy/pages/vehicles_page.dart';
import 'package:galaxy/widget/navigation_drawer_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flip_card/flip_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _addCounter = 0;
  int _shareCounter = 0;
  final PageController _pageController = PageController();

  void _incrementAddCounter() {
    setState(() {
      _addCounter++;
    });
  }

  void _incrementShareCounter() {
    setState(() {
      _shareCounter++;
    });
  }

  Widget _buildCarouselCard(String title, String subtitle, IconData icon, Widget? page, Color backColor) {
    return Card(
      elevation: 50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: InkWell(
        onTap: () {
          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                color: backColor,
              ),
              child: Center(
                child: Icon(icon, size: 80, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, String title, IconData icon, Widget? page, Color backColor, String stats, int duration) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      // speed: duration * 100,
      autoFlipDuration: Duration(milliseconds: duration * 100),
      front: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          onTap: () {
            if (page != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: backColor),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
      back: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: backColor.withOpacity(0.7),
        child: Center(
          child: Text(
            stats,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      drawer: const NavigationDrawerWidget(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 250,
              child: PageView(
                controller: _pageController,
                children: [
                  _buildCarouselCard('People Galaxy', 'Manage your contacts', Icons.people, const PeoplePage(), Colors.amberAccent),
                  _buildCarouselCard('Documents Galaxy', 'Organize your files', Icons.picture_as_pdf, const DocumentsPage(), Colors.blueAccent),
                  _buildCarouselCard('Accounts Galaxy', 'Track your finances', Icons.account_balance, const AccountsPage(), Colors.redAccent),
                  _buildCarouselCard('Vehicles Galaxy', 'Maintain your vehicles', Icons.directions_car_rounded, const VehiclesPage(), Colors.purpleAccent),
                  _buildCarouselCard('Assets Galaxy', 'Manage your properties', Icons.real_estate_agent, const AssetsPage(), Colors.greenAccent),
                  _buildCarouselCard('Expenses Galaxy', 'Track your expenses', Icons.attach_money_rounded, const ExpensesPage(), Colors.pinkAccent),
                  _buildCarouselCard('Achievements Galaxy', 'Record your milestones', Icons.workspace_premium_rounded, const AchivementsPage(), Colors.orangeAccent),
                  _buildCarouselCard('My Universe Galaxy', 'Explore your universe', Icons.auto_awesome_sharp, const MyUniversePage(), Colors.indigoAccent),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SmoothPageIndicator(
              controller: _pageController,
              count: 8,
              effect: const WormEffect(
                dotColor: Colors.grey,
                activeDotColor: Colors.black,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              children: [
                _buildGridCard(context, 'People', Icons.people, const PeoplePage(), Colors.amberAccent, 'Total People: 50', Random().nextInt(5) + 1),
                _buildGridCard(context, 'Documents', Icons.picture_as_pdf, const DocumentsPage(), Colors.blueAccent, 'Total Documents: 120', Random().nextInt(5) + 1),
                _buildGridCard(context, 'Accounts', Icons.account_balance, const AccountsPage(), Colors.redAccent, 'Total Accounts: 10', Random().nextInt(5) + 1),
                _buildGridCard(context, 'Vehicles', Icons.directions_car_rounded, const VehiclesPage(), Colors.purpleAccent, 'Total Vehicles: 5', Random().nextInt(5) + 1),
                _buildGridCard(context, 'Assets', Icons.real_estate_agent, const AssetsPage(), Colors.greenAccent, 'Total Assets: 15', Random().nextInt(5) + 1),
                _buildGridCard(context, 'Expenses', Icons.attach_money_rounded, const ExpensesPage(), Colors.pinkAccent, 'Total Expenses: \$2000', Random().nextInt(5) + 1),
                _buildGridCard(context, 'Achievements', Icons.workspace_premium_rounded, const AchivementsPage(), Colors.orangeAccent, 'Total Achievements: 20', Random().nextInt(5) + 1),
                _buildGridCard(context, 'My Universe', Icons.auto_awesome_sharp, const MyUniversePage(), Colors.indigoAccent, 'Total Items: 100', Random().nextInt(5) + 1),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'You have added this many number of items:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            Text(
              '$_addCounter',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'You have shared this many number of items:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            Text(
              '$_shareCounter',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        verticalDirection: VerticalDirection.down,
        children: [
          FloatingActionButton(
            onPressed: _incrementAddCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _incrementShareCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.share_sharp),
          ),
        ],
      ),
    );
  }
}
