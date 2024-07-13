import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: widget.educationDetails[widget.index - 1]['degree']!.isNotEmpty
              ? widget.educationDetails[widget.index - 1]['degree']
              : null,
          decoration: const InputDecoration(labelText: 'Degree'),
          items: ['Graduate', 'Bachelor', 'Master', 'PhD', 'Other']
              .map((degree) => DropdownMenuItem(
                    value: degree,
                    child: Text(degree),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              widget.educationDetails[widget.index - 1]['degree'] = value ?? '';
            });
          },
        ),
        TextFormField(
          controller: widget.institutionControllers[widget.index - 1],
          decoration: const InputDecoration(labelText: 'Institution'),
          onChanged: (value) {
            widget.educationDetails[widget.index - 1]['institution'] = value;
          },
        ),
        TextFormField(
          controller: widget.yearControllers[widget.index - 1],
          decoration: const InputDecoration(labelText: 'Year'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            widget.educationDetails[widget.index - 1]['year'] = value;
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              widget.educationDetails.removeAt(widget.index - 1);
              widget.degreeControllers.removeAt(widget.index - 1);
              widget.institutionControllers.removeAt(widget.index - 1);
              widget.yearControllers.removeAt(widget.index - 1);
            });
          },
          child: const Text('Delete'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
