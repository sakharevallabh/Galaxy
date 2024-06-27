import 'dart:math';
import 'dart:async';
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
  late PageController _pageController = PageController();
  List<String> peopleCarouselImage = ['assets/images/People_Carousel_1.jpeg'];
  List<String> documentsCarouselImage = [
    'assets/images/Documents_Carousel.jpg'
  ];
  List<String> accountsCarouselImage = ['assets/images/Accounts_Carousel.jpeg'];
  List<String> assetsCarouselImage = [
    'assets/images/Assets_Carousel_1.jpeg',
    'assets/images/Assets_Carousel_2.jpeg'
  ];
  List<String> vehiclesCarouselImage = [
    'assets/images/Vehicles_Carousel_1.jpeg'
  ];
  List<String> expensesCarouselImage = [
    'assets/images/Expenses_Carousel_1.jpeg'
  ];
  List<String> achievemetnsCarouselImage = [
    'assets/images/Achievements_Carousel.jpeg'
  ];
  List<String> myUniverseCarouselImage = [
    'assets/images/MyUniverse_Carousel.jpg'
  ];
  String randomString = "";
  List<GlobalKey<FlipCardState>> cardKeys =
      List.generate(8, (index) => GlobalKey<FlipCardState>());
  List<Timer?> timers = List.generate(8, (index) => null);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Initialize timers with different durations
    for (int i = 0; i < 8; i++) {
      int duration = Random().nextInt(30) + 8;
      timers[i] = Timer.periodic(Duration(seconds: duration), (Timer t) {
        if (mounted) {
          if (i < cardKeys.length) {
            cardKeys[i].currentState?.toggleCard();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var timer in timers) {
      timer?.cancel();
    }
    super.dispose();
  }

  String getRandomString(List<String> strings) {
    final random = Random();
    int randomIndex = random.nextInt(strings.length);
    return strings[randomIndex];
  }

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

  Widget _buildCarouselCard(String title, String subtitle, IconData icon,
      Widget? page, Color backColor, String imageFile) {
    return Card(
      shadowColor: Colors.black12,
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
                image: DecorationImage(
                  image: AssetImage(imageFile),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                color: backColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  Widget _buildGridCard(BuildContext context, String title, IconData icon,
      Widget? page, Color backColor, String stats, int index) {
    return FlipCard(
      key: cardKeys[index],
      direction: FlipDirection.HORIZONTAL,
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
              Icon(icon, size: 40, color: backColor),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
              fontSize: 16,
              color: Colors.white70,
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/HomeScreen_Background.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              SizedBox(
                height: 230,
                child: PageView(
                  controller: _pageController,
                  children: [
                    _buildCarouselCard(
                        'People Galaxy',
                        'Store contacts! Don\'t forget them..',
                        Icons.people,
                        const PeoplePage(),
                        Colors.amberAccent,
                        getRandomString(peopleCarouselImage)),
                    _buildCarouselCard(
                        'Documents Galaxy',
                        'Organize files like never before!!',
                        Icons.picture_as_pdf,
                        const DocumentsPage(),
                        Colors.blueAccent,
                        getRandomString(documentsCarouselImage)),
                    _buildCarouselCard(
                        'Accounts Galaxy',
                        'Save Accounts and IDs. Don\'t ever forget.',
                        Icons.account_balance,
                        const AccountsPage(),
                        Colors.redAccent,
                        getRandomString(accountsCarouselImage)),
                    _buildCarouselCard(
                        'Vehicles Galaxy',
                        'Maintain vehicles. Vrooom Vroom Vroom..',
                        Icons.directions_car_rounded,
                        const VehiclesPage(),
                        Colors.purpleAccent,
                        getRandomString(vehiclesCarouselImage)),
                    _buildCarouselCard(
                        'Assets Galaxy',
                        'Manage your Assets like a PRO!!',
                        Icons.real_estate_agent,
                        const AssetsPage(),
                        Colors.greenAccent,
                        getRandomString(assetsCarouselImage)),
                    _buildCarouselCard(
                        'Expenses Galaxy',
                        'Track your expenses. Intelligently!!',
                        Icons.attach_money_rounded,
                        const ExpensesPage(),
                        Colors.pinkAccent,
                        getRandomString(expensesCarouselImage)),
                    _buildCarouselCard(
                        'Achievements Galaxy',
                        'Record your milestones. Aim Higher',
                        Icons.workspace_premium_rounded,
                        const AchivementsPage(),
                        Colors.orangeAccent,
                        getRandomString(achievemetnsCarouselImage)),
                    _buildCarouselCard(
                        'My Universe',
                        'Explore your universe and dive in Galaxies',
                        Icons.auto_awesome_sharp,
                        const MyUniversePage(),
                        Colors.indigoAccent,
                        getRandomString(myUniverseCarouselImage)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SmoothPageIndicator(
                controller: _pageController,
                count: 8,
                effect: const WormEffect(
                  dotColor: Colors.grey,
                  activeDotColor: Colors.black,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(10),
                childAspectRatio:
                    1.5, // Adjusted aspect ratio to reduce card size
                children: [
                  _buildGridCard(
                      context,
                      'People',
                      Icons.people,
                      const PeoplePage(),
                      Colors.amberAccent,
                      'Total People: 50',
                      0),
                  _buildGridCard(
                      context,
                      'Documents',
                      Icons.picture_as_pdf,
                      const DocumentsPage(),
                      Colors.blueAccent,
                      'Total Documents: 120',
                      1),
                  _buildGridCard(
                      context,
                      'Accounts',
                      Icons.account_balance,
                      const AccountsPage(),
                      Colors.redAccent,
                      'Total Accounts: 10',
                      2),
                  _buildGridCard(
                      context,
                      'Vehicles',
                      Icons.directions_car_rounded,
                      const VehiclesPage(),
                      Colors.purpleAccent,
                      'Total Vehicles: 5',
                      3),
                  _buildGridCard(
                      context,
                      'Assets',
                      Icons.real_estate_agent,
                      const AssetsPage(),
                      Colors.greenAccent,
                      'Total Assets: 15',
                      4),
                  _buildGridCard(
                      context,
                      'Expenses',
                      Icons.attach_money_rounded,
                      const ExpensesPage(),
                      Colors.pinkAccent,
                      'Total Expenses: \$2000',
                      5),
                  _buildGridCard(
                      context,
                      'Achievements',
                      Icons.workspace_premium_rounded,
                      const AchivementsPage(),
                      Colors.orangeAccent,
                      'Total Achievements: 20',
                      6),
                  _buildGridCard(
                      context,
                      'My Universe',
                      Icons.auto_awesome_sharp,
                      const MyUniversePage(),
                      Colors.indigoAccent,
                      'Total Items: 100',
                      7),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'No. of stars added in all your Galaxies:',
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
                'No. of stars shared in Multiverse:',
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
              const SizedBox(height: 150),
            ],
          ),
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
