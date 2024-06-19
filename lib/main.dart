import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:galaxy/pages/people_page.dart';
import 'package:galaxy/provider/navigation_provider.dart';
import 'package:galaxy/widget/navigation_drawer_widget.dart';
import 'package:provider/provider.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const My App());
// }

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = "Galaxy Application";

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => NavigationProvider(),
        child: MaterialApp(
          title: title.toString(),
          theme: ThemeData(
            // colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Galaxy View'),
          // color: Colors.amber,
        ),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _addCounter = 0;
  int _shareCounter = 0;

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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildCard(context, 'People', Icons.people, const PeoplePage()),
              _buildCard(context, 'Vehicles', Icons.directions_car,
                  null), // Replace with actual page
              _buildCard(context, 'Accounts', Icons.account_balance,
                  null), // Replace with actual page
              const Text(
                'You have added this many number of items:',
                style: TextStyle(
                  color: Colors.white, // Change text color here
                  fontSize: 16,
                ),
              ),
              Text(
                '$_addCounter',
                //style: Theme.of(context).textTheme.headlineMedium,
                style: const TextStyle(
                  color: Colors.white, // Change text color here
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'You have shared this many number of items:',
                style: TextStyle(
                  color: Colors.white, // Change text color here
                  fontSize: 16,
                ),
              ),
              Text(
                '$_shareCounter',
                //style: Theme.of(context).textTheme.headlineMedium,
                style: const TextStyle(
                  color: Colors.white, // Change text color here
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          ]),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildCard(
      BuildContext context, String title, IconData icon, Widget? page) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Adjust corner radius
      ),
      surfaceTintColor: Colors.white30,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          leading: Icon(icon, size: 30),
          title: Text(title, style: const TextStyle(fontSize: 24)),
          onTap: () {
            if (page != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            }
          },
        ),
      ),
    );
  }
}
