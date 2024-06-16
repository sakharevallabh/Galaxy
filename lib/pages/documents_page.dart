import 'package:flutter/material.dart';
import 'package:galaxy/model/document_model.dart';
import 'package:galaxy/views/details/document_details.dart';
import 'package:galaxy/views/forms/add_document.dart';
import 'package:galaxy/views/overview/documents_overview.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  DocumentsPageState createState() => DocumentsPageState();
}

class DocumentsPageState extends State<DocumentsPage> {
  int _selectedIndex = 0;
  final DocumentModel selectedPerson =
      const DocumentModel(name: 'Alice', age: 30, address: '123 Main St');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.folder_shared),
            icon: Icon(Icons.folder_shared_outlined),
            label: 'All Files',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.picture_as_pdf),
            icon: Icon(Icons.picture_as_pdf_outlined),
            label: 'Details',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.note_add),
            icon: Icon(Icons.note_add_outlined),
            label: 'Add New',
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('Documents & Media Galaxy'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // First Route
            const DocumentsOverview(),

            // Second Route
            DocumentDetailsPage(
                person: selectedPerson,
                heroTag: 'document_${selectedPerson.name}'),

            // Third Route
            const AddDocumentView(),
          ],
        ),
      ),
    );
  }
}
