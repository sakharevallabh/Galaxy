import 'package:flutter/material.dart';
import 'package:Galaxy/provider/assets_data_provider.dart';
import 'package:provider/provider.dart';

class EducationField extends StatefulWidget {
  final int index;
  final List<TextEditingController> degreeControllers;
  final List<TextEditingController> institutionControllers;
  final List<TextEditingController> yearControllers;
  final List<Map<String, String>> educationDetails;

  const EducationField({
    required this.index,
    required this.degreeControllers,
    required this.institutionControllers,
    required this.yearControllers,
    required this.educationDetails,
    super.key,
  });

  @override
  EducationFieldState createState() => EducationFieldState();
}

class EducationFieldState extends State<EducationField> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    if (widget.index < 0 || widget.index >= widget.educationDetails.length) {
      return const SizedBox.shrink();
    }

    if (widget.degreeControllers.length != widget.educationDetails.length ||
        widget.institutionControllers.length != widget.educationDetails.length ||
        widget.yearControllers.length != widget.educationDetails.length) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: widget.educationDetails[widget.index]['degree']!.isNotEmpty
              ? widget.educationDetails[widget.index]['degree']
              : null,
          decoration: const InputDecoration(labelText: 'Degree'),
          items: dataProvider.qualifications
              .map((degree) => DropdownMenuItem(
                    value: degree,
                    child: Text(degree),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              widget.educationDetails[widget.index]['degree'] = value ?? '';
            });
          },
        ),
        TextFormField(
          controller: widget.institutionControllers[widget.index],
          decoration: const InputDecoration(labelText: 'Institution'),
          onChanged: (value) {
            widget.educationDetails[widget.index]['institution'] = value;
          },
        ),
        TextFormField(
          controller: widget.yearControllers[widget.index],
          decoration: const InputDecoration(labelText: 'Year'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            widget.educationDetails[widget.index]['year'] = value;
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              widget.educationDetails.removeAt(widget.index);
              widget.degreeControllers.removeAt(widget.index);
              widget.institutionControllers.removeAt(widget.index);
              widget.yearControllers.removeAt(widget.index);
            });
          },
          child: const Text('Delete'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
