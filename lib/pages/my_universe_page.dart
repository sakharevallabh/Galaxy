import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// Model classes for stored data
class PersonalDetails {
  final String name;
  final int age;
  final String location;

  PersonalDetails({
    required this.name,
    required this.age,
    required this.location,
  });
}

class Vehicle {
  final String make;
  final String model;
  final int year;

  Vehicle({
    required this.make,
    required this.model,
    required this.year,
  });
}

class Expense {
  final String category;
  final double amount;
  final DateTime date;

  Expense({
    required this.category,
    required this.amount,
    required this.date,
  });
}

// Model classes for recommendation article and personal recommendation
class RecommendationArticle {
  final String title;
  final String description;
  final String url;

  RecommendationArticle({
    required this.title,
    required this.description,
    required this.url,
  });

  factory RecommendationArticle.fromJson(Map<String, dynamic> json) {
    return RecommendationArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
    );
  }

  // Function to launch the article URL
  void launchUrl() async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class PersonalRecommendation {
  final String title;
  final String description;

  PersonalRecommendation({
    required this.title,
    required this.description,
  });
}

class UserPreferences {
  int age;
  String location;
  List<String> interests;
  List<String>
      selectedCategories; // Selected categories based on user preference

  UserPreferences({
    required this.age,
    required this.location,
    required this.interests,
    required this.selectedCategories,
  });
}

class MyUniversePage extends StatefulWidget {
  const MyUniversePage({super.key});

  @override
  MyUniversePageState createState() => MyUniversePageState();
}

class MyUniversePageState extends State<MyUniversePage> {
  // Simulated stored data
  List<PersonalDetails> personalDetailsList = [
    PersonalDetails(name: 'John Doe', age: 50, location: 'New York'),
    PersonalDetails(name: 'Jane Smith', age: 25, location: 'Los Angeles'),
    // Add more personal details as needed
  ];

  List<Vehicle> vehicleList = [
    Vehicle(make: 'Toyota', model: 'Camry', year: 2020),
    Vehicle(make: 'Honda', model: 'Civic', year: 2018),
    // Add more vehicles as needed
  ];

  List<Expense> expenseList = [
    Expense(category: 'Groceries', amount: 1000.0, date: DateTime(2024, 6, 1)),
    Expense(category: 'Travel', amount: 200.0, date: DateTime(2023, 5, 15)),
    // Add more expenses as needed
  ];

  // Simulated user preferences
  UserPreferences userPreferences = UserPreferences(
    age: 30,
    location: 'New York',
    interests: ['Technology', 'Finance'],
    selectedCategories: [
      'Technology',
      'Finance'
    ], // Default selected categories
  );

  // Static list of categories
  static const List<String> categories = [
    'Technology',
    'Finance',
    'Health',
    'Sports',
    'Travel',
    'Food',
    'Entertainment',
    'Science',
  ];

  Map<String, List<RecommendationArticle>> articlesMap = {};
  List<PersonalRecommendation> personalRecommendations = [];

  String randomImageURL = 'https://picsum.photos/200/300';

  @override
  void initState() {
    super.initState();
    // Fetch articles and personal recommendations when the page loads
    fetchArticles();
    fetchPersonalRecommendations();
  }

  // Function to fetch articles based on user preferences
  void fetchArticles() async {
    // Fetch articles for selected categories
    articlesMap = await fetchRecommendedArticles(userPreferences);
    setState(() {
      // Update the UI after fetching articles
    });
  }

  // Function to fetch personal recommendations based on stored data
  Future<void> fetchPersonalRecommendations() async {
    List<PersonalRecommendation> recommendations =
        await generatePersonalRecommendations();
    setState(() {
      personalRecommendations = recommendations;
    });
  }

  // Function to generate personal recommendations based on stored data
  Future<List<PersonalRecommendation>> generatePersonalRecommendations() async {
    List<PersonalRecommendation> recommendations = [];

    // Example logic to generate recommendations based on stored data
    // Check for vehicles older than 5 years
    List<Vehicle> oldVehicles = vehicleList
        .where((vehicle) => DateTime.now().year - vehicle.year > 5)
        .toList();
    if (oldVehicles.isNotEmpty) {
      recommendations.add(PersonalRecommendation(
        title: 'Old Vehicles Detected',
        description:
            'Consider upgrading your ${oldVehicles.length > 1 ? 'vehicles' : 'vehicle'}: ${oldVehicles.map((v) => '${v.make} ${v.model}').join(', ')}',
      ));
    }

    // Check for recent large expenses
    DateTime recentDateThreshold = DateTime.now().subtract(const Duration(days: 30));
    List<Expense> largeExpenses = expenseList
        .where((expense) =>
            expense.amount > 500 && expense.date.isAfter(recentDateThreshold))
        .toList();
    if (largeExpenses.isNotEmpty) {
      recommendations.add(PersonalRecommendation(
        title: 'Recent Large Expenses',
        description:
            'You had significant expenses recently in ${largeExpenses.map((e) => e.category).join(', ')}',
      ));
    }

    // Check for age-related recommendations
    if (personalDetailsList.isNotEmpty) {
      int averageAge = personalDetailsList
              .map((details) => details.age)
              .reduce((a, b) => a + b) ~/
          personalDetailsList.length;
      if (averageAge > 30) {
        recommendations.add(PersonalRecommendation(
          title: 'Age Consideration',
          description:
              'Based on average age ($averageAge), consider planning for retirement.',
        ));
      }
    }

    return recommendations;
  }

  // Function to fetch recommended articles based on user preferences
  Future<Map<String, List<RecommendationArticle>>> fetchRecommendedArticles(
      UserPreferences preferences) async {
    Map<String, List<RecommendationArticle>> articlesMap = {};

    // Simulated fetching of articles based on selected categories
    for (String category in preferences.selectedCategories) {
      List<RecommendationArticle> articles = [];
      for (String url in categoryArticleUrls[category]!) {
        // Simulate fetching article details from URL
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);
          articles.add(RecommendationArticle.fromJson(jsonData));
        } else {
          throw Exception('Failed to load article');
        }
      }
      articlesMap[category] = articles;
    }

    return articlesMap;
  }

  // Function to launch article URL
  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Universe'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Personal Recommendations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: personalRecommendations
                    .map((recommendation) => Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            title: Text(
                              recommendation.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(recommendation.description),
                            onTap: () {
                              // Implement action for each recommendation
                              print('Tapped on: ${recommendation.title}');
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Selected Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Wrap(
              children: List.generate(
                categories.length,
                (index) {
                  String category = categories[index];
                  bool isSelected =
                      userPreferences.selectedCategories.contains(category);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            userPreferences.selectedCategories.add(category);
                          } else {
                            userPreferences.selectedCategories.remove(category);
                          }
                        });
                        // After category selection, fetch updated articles
                        fetchArticles();
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: articlesMap.keys.length,
              itemBuilder: (context, index) {
                String category = articlesMap.keys.toList()[index];
                List<RecommendationArticle> articles =
                    articlesMap[category] ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                         '$category Articles',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 200, // Adjust the height as needed
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: articles.length,
                        itemBuilder: (context, index) {
                          RecommendationArticle article = articles[index];
                          return Container(
                            width: 300, // Adjust the width as needed
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Launch article URL on tap
                                  launchUrl(article.url);
                                },
                                child: SizedBox(
                                width: 150,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        randomImageURL,
                                        height: 100,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      article.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      article.description,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Simulated URLs for articles by category
Map<String, List<String>> categoryArticleUrls = {
  'Technology': [
    'https://jsonplaceholder.typicode.com/posts/1',
    'https://jsonplaceholder.typicode.com/posts/2',
    'https://jsonplaceholder.typicode.com/posts/3',
  ],
  'Finance': [
    'https://jsonplaceholder.typicode.com/posts/4',
    'https://jsonplaceholder.typicode.com/posts/5',
    'https://jsonplaceholder.typicode.com/posts/6',
  ],
  'Health': [
    'https://jsonplaceholder.typicode.com/posts/7',
    'https://jsonplaceholder.typicode.com/posts/8',
    'https://jsonplaceholder.typicode.com/posts/9',
  ],
  'Sports': [
    'https://jsonplaceholder.typicode.com/posts/10',
    'https://jsonplaceholder.typicode.com/posts/11',
    'https://jsonplaceholder.typicode.com/posts/12',
  ],
  'Travel': [
    'https://jsonplaceholder.typicode.com/posts/13',
    'https://jsonplaceholder.typicode.com/posts/14',
    'https://jsonplaceholder.typicode.com/posts/15',
  ],
  'Food': [
    'https://jsonplaceholder.typicode.com/posts/16',
    'https://jsonplaceholder.typicode.com/posts/17',
    'https://jsonplaceholder.typicode.com/posts/18',
  ],
  'Entertainment': [
    'https://jsonplaceholder.typicode.com/posts/19',
    'https://jsonplaceholder.typicode.com/posts/20',
    'https://jsonplaceholder.typicode.com/posts/21',
  ],
  'Science': [
    'https://jsonplaceholder.typicode.com/posts/22',
    'https://jsonplaceholder.typicode.com/posts/23',
    'https://jsonplaceholder.typicode.com/posts/24',
  ],
};

