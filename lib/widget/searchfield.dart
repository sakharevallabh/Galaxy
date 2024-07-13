import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

class SearchableField extends StatefulWidget {
  final String fieldName;
  final List<String> suggestions;
  final TextEditingController controller;

  const SearchableField({
    required this.fieldName,
    required this.suggestions,
    required this.controller,
    super.key,
  });

  @override
  SearchableFieldState createState() => SearchableFieldState();
}

class SearchableFieldState extends State<SearchableField> {
  @override
  Widget build(BuildContext context) {
    return SearchField(
      key: Key(widget.fieldName),
      controller: widget.controller,
      suggestions: widget.suggestions
          .where((suggestion) => suggestion.toLowerCase().contains(
              widget.controller.text.toLowerCase()))
          .map((e) => SearchFieldListItem(e))
          .toList(),
      searchInputDecoration: InputDecoration(
        hintText: widget.fieldName,
      ),
      maxSuggestionsInViewPort: 5,
      onSearchTextChanged: (value) {
        setState(() {
          widget.controller.text = value;
        });
        return null;
      },
    );
  }
}
