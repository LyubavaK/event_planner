import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'event_provider.dart';
import 'event.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: MaterialApp(
        title: 'Event Planner',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: EventListScreen(),
      ),
    );
  }
}

class EventListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Planner'),
      ),
      body: ListView.builder(
        itemCount: eventProvider.events.length,
        itemBuilder: (context, index) {
          final event = eventProvider.events[index];
          return ListTile(
            title: Text(event.title),
            subtitle: Text('${event.date.toLocal()}'.split(' ')[0]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEventScreen(eventId: event.id),
                ),
              );
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                eventProvider.deleteEvent(event.id);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEventScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;

  void _submit() {
    if (_titleController.text.isEmpty || _selectedDate == null) {
      return;
    }

    final newEvent = Event(
      id: DateTime.now().toString(),
      title: _titleController.text,
      date: _selectedDate!,
    );

    Provider.of<EventProvider>(context, listen: false).addEvent(newEvent);
    
    // Schedule notification
    NotificationService.showNotification(
      newEvent.hashCode,
      'Event Reminder',
      'You have an event "${newEvent.title}" on ${newEvent.date.toLocal()}',
    );

    Navigator.of(context).pop();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Event Title'),
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Text(_selectedDate == null
                    ? 'No date chosen!'
                    : 'Picked Date: ${_selectedDate!.toLocal()}'.split(' ')[0]),
                Spacer(),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Choose date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditEventScreen extends StatefulWidget {
  final String eventId;

  EditEventScreen({required this.eventId});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late Event event;
  final _titleController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    event = eventProvider.events.firstWhere((e) => e.id == widget.eventId);
    _titleController.text = event.title;
    _selectedDate = event.date;
  }

  void _submit() {
    if (_titleController.text.isEmpty || _selectedDate == null) {
      return;
    }

    final updatedEvent = Event(
      id: event.id,
      title: _titleController.text,
      date: _selectedDate!,
    );

    Provider.of<EventProvider>(context, listen: false).updateEvent(event.id, updatedEvent);
    
    // Schedule notification again if needed
    NotificationService.showNotification(
      updatedEvent.hashCode,
      'Updated Event Reminder',
      'You have an updated event "${updatedEvent.title}" on ${updatedEvent.date.toLocal()}',
    );

    Navigator.of(context).pop();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Event Title'),
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Text(_selectedDate == null
                    ? 'No date chosen!'
                    : 'Picked Date: ${_selectedDate!.toLocal()}'.split(' ')[0]),
                Spacer(),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Choose date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Update Event'),
            ),
          ],
        ),
      ),
    );
  }
}