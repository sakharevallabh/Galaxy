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
              height: 300, // Adjust height to prevent overflow
              child: PageView(
                controller: _pageController,
                children: [
                  _buildCard(context, 'People', Icons.people, const PeoplePage(), Colors.amberAccent),
                  _buildCard(context, 'Documents', Icons.picture_as_pdf, const DocumentsPage(), Colors.blueAccent),
                  _buildCard(context, 'Accounts', Icons.account_balance, const AccountsPage(), Colors.redAccent),
                  _buildCard(context, 'Vehicles', Icons.directions_car_rounded, const VehiclesPage(), Colors.purpleAccent),
                  _buildCard(context, 'Assets', Icons.real_estate_agent, const AssetsPage(), Colors.greenAccent),
                  _buildCard(context, 'Expenses', Icons.attach_money_rounded, const ExpensesPage(), Colors.pinkAccent),
                  _buildCard(context, 'Achievements', Icons.workspace_premium_rounded, const AchivementsPage(), Colors.orangeAccent),
                  _buildCard(context, 'My Universe', Icons.auto_awesome_sharp, const MyUniversePage(), Colors.indigoAccent),
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

  Widget _buildCard(BuildContext context, String title, IconData icon, Widget? page, Color backColor) {
    return Card(
      elevation: 50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
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
              height: 200, // Adjusted height to fit within the PageView
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36.0),
                  topRight: Radius.circular(36.0),
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/images/Background.png'),
                  fit: BoxFit.cover,
                ),
                color: backColor.withOpacity(0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(icon, size: 40, color: Colors.black),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Checkout $title in your Universe', // Add a subtitle here
                      style: const TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // const Text(
                  //   'A beautiful sunset is one of the most captivating sights nature has to offer.',
                  //   style: TextStyle(
                  //     color: Colors.black,
                  //   ),
                  //   textAlign: TextAlign.start,
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
