import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// Model class for recommendation article
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

// Model class for personal recommendation
class PersonalRecommendation {
  final String title;
  final String description;

  PersonalRecommendation({
    required this.title,
    required this.description,
  });
}

// Simulated user preferences
class UserPreferences {
  int age;
  String location;
  List<String> interests;
  List<String> selectedCategories; // Selected categories based on user preference

  // List of available categories
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
  // Simulated user preferences
  UserPreferences userPreferences = UserPreferences(
    age: 30,
    location: 'New York',
    interests: ['Technology', 'Finance'],
    selectedCategories: ['Technology', 'Finance'], // Default selected categories
  );

  Map<String, List<RecommendationArticle>> articlesMap = {};
  List<PersonalRecommendation> personalRecommendations = [];

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
    List<PersonalRecommendation> recommendations = await generatePersonalRecommendations();
    setState(() {
      personalRecommendations = recommendations;
    });
  }

  // Function to generate personal recommendations based on stored data
  Future<List<PersonalRecommendation>> generatePersonalRecommendations() async {
    List<PersonalRecommendation> recommendations = [];

    // Example logic to generate recommendations based on stored data
    // Replace with your actual implementation based on SQLite data

    // Check for missing insurance (simulated example)
    bool missingInsurance = true; // Replace with actual check
    if (missingInsurance) {
      recommendations.add(PersonalRecommendation(
        title: 'Missing Insurance',
        description: 'You have insurance details missing. Update now to stay protected.',
      ));
    }

    // Check for critical financial news (simulated example)
    bool criticalNewsAvailable = true; // Replace with actual check
    if (criticalNewsAvailable) {
      recommendations.add(PersonalRecommendation(
        title: 'Critical Financial News',
        description: 'Stay updated with the latest financial news to make informed decisions.',
      ));
    }

    // Check for updated credit card offers (simulated example)
    List<String> updatedCreditCards = ['Gold Credit Card', 'Diamond Credit Card']; // Replace with actual check
    if (updatedCreditCards.isNotEmpty) {
      recommendations.add(PersonalRecommendation(
        title: 'Updated Credit Cards',
        description: 'New credit card offers available. Check them out now.',
      ));
    }

    // Check for new local restaurants (simulated example)
    List<String> newRestaurants = ['Cafe DArmas', 'Ride the Dragon - Chinese ']; // Replace with actual check
    if (newRestaurants.isNotEmpty) {
      recommendations.add(PersonalRecommendation(
        title: 'New Restaurants Nearby',
        description: 'Explore new restaurants $newRestaurants that have opened near you.',
      ));
    }

    // Check for important government announcements (simulated example)
    List<String> governmentAnnouncements = ['Link Aadhaar and PAN']; // Replace with actual check
    if (governmentAnnouncements.isNotEmpty) {
      recommendations.add(PersonalRecommendation(
        title: 'Important Government Announcements',
        description: 'Stay informed with recent government announcements to $governmentAnnouncements',
      ));
    }

    return recommendations;
  }

  // Function to fetch recommended articles based on user preferences
  Future<Map<String, List<RecommendationArticle>>> fetchRecommendedArticles(UserPreferences preferences) async {
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
                              style: const TextStyle(fontWeight: FontWeight.bold),
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
                UserPreferences.categories.length,
                (index) {
                  String category = UserPreferences.categories[index];
                  bool isSelected = userPreferences.selectedCategories.contains(category);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
              itemCount: userPreferences.selectedCategories.length,
              itemBuilder: (context, index) {
                String category = userPreferences.selectedCategories[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        '$category Articles',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: articlesMap[category]?.length ?? 0,
                        itemBuilder: (context, idx) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                launchUrl(articlesMap[category]![idx].url);
                              },
                              child: Container(
                                width: 150,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        articlesMap[category]![idx].url,
                                        height: 100,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      articlesMap[category]![idx].title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      articlesMap[category]![idx].description,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
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


