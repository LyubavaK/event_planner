import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(EventPlannerApp());
}

class EventPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Planner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EventForm(),
    );
  }
}

class Event {
  String title;
  DateTime startDate;
  DateTime endDate;

  Event({required this.title, required this.startDate, required this.endDate});
}

class EventForm extends StatefulWidget {
  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final List<Event> events = [];
  final TextEditingController titleController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  void _pickStartDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != startDate) {
      setState(() {
        startDate = pickedDate;
      });
    }
  }

  void _pickEndDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != endDate) {
      setState(() {
        endDate = pickedDate;
      });
    }
  }

  void _addEvent() {
    if (titleController.text.isNotEmpty && startDate != null && endDate != null) {
      setState(() {
        events.add(Event(
          title: titleController.text,
          startDate: startDate!,
          endDate: endDate!,
        ));
        titleController.clear();
        startDate = null;
        endDate = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plan Your Events')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Event Title'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(startDate == null ? 'Start Date' : DateFormat.yMd().format(startDate!)),
                ElevatedButton(
                  onPressed: () => _pickStartDate(context),
                  child: Text('Pick Start Date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(endDate == null ? 'End Date' : DateFormat.yMd().format(endDate!)),
                ElevatedButton(
                  onPressed: () => _pickEndDate(context),
                  child: Text('Pick End Date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addEvent,
              child: Text('Add Event'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(events[index].title),
                    subtitle: Text('${DateFormat.yMd().add_jm().format(events[index].startDate)} - ${DateFormat.yMd().add_jm().format(events[index].endDate)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}