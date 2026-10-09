import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const SahaySetuApp());
}

class SahaySetuApp extends StatelessWidget {
  const SahaySetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'SahaySetu',

      theme: ThemeData(
        useMaterial3: true,

        colorSchemeSeed: const Color(0xFF176B87),

        scaffoldBackgroundColor: const Color(0xFFF5F8FA),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,

          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),

            borderSide: BorderSide.none,
          ),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}

enum UserRole { citizen, worker }

class Complaint {
  final String id;

  final String category;

  final String title;

  final String description;

  final String location;

  final String priority;

  String status;

  final int relatedReports;

  final String possibleLink;

  final String previousIntervention;

  final bool recurrence;

  final String recommendation;

  Complaint({
    required this.id,

    required this.category,

    required this.title,

    required this.description,

    required this.location,

    required this.priority,

    required this.status,

    required this.relatedReports,

    required this.possibleLink,

    required this.previousIntervention,

    required this.recurrence,

    required this.recommendation,
  });
}

final complaints = <Complaint>[
  Complaint(
    id: 'SS-1024',

    category: 'Road Damage',

    title: 'Pothole near main gate',

    description: 'Large pothole causing difficulty for vehicles.',

    location: 'Sector 62, Main Road',

    priority: 'High',

    status: 'In Progress',

    relatedReports: 3,

    possibleLink: 'Waterlogging / drainage issue',

    previousIntervention: 'Road repair recorded in Aug 2026',

    recurrence: true,

    recommendation: 'Inspect nearby drainage before repeating road repair.',
  ),

  Complaint(
    id: 'SS-1025',

    category: 'Street Light',

    title: 'Street light not working',

    description: 'Street light is not working near the community gate.',

    location: 'Sector 62, Community Gate',

    priority: 'Medium',

    status: 'Pending',

    relatedReports: 1,

    possibleLink: 'Nearby electrical fault',

    previousIntervention: 'No previous intervention found',

    recurrence: false,

    recommendation: 'Inspect the pole wiring and nearby electrical connection.',
  ),
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole role = UserRole.citizen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  const SizedBox(height: 35),

                  CircleAvatar(
                    radius: 38,

                    backgroundColor: Theme.of(context).colorScheme.primary,

                    child: const Icon(
                      Icons.connecting_airports,

                      color: Colors.white,
                      size: 42,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'SahaySetu',

                    textAlign: TextAlign.center,

                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Smart Civic Infrastructure Incident Management',

                    textAlign: TextAlign.center,

                    style: TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    'Login as',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  SegmentedButton<UserRole>(
                    segments: const [
                      ButtonSegment(
                        value: UserRole.citizen,

                        label: Text('Citizen'),

                        icon: Icon(Icons.person),
                      ),

                      ButtonSegment(
                        value: UserRole.worker,

                        label: Text('Worker'),

                        icon: Icon(Icons.engineering),
                      ),
                    ],

                    selected: {role},

                    onSelectionChanged: (value) {
                      setState(() => role = value.first);
                    },
                  ),

                  const SizedBox(height: 20),

                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Email / Phone',

                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),

                  const SizedBox(height: 14),

                  const TextField(
                    obscureText: true,

                    decoration: InputDecoration(
                      labelText: 'Password',

                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),

                  const SizedBox(height: 22),

                  FilledButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,

                        MaterialPageRoute(
                          builder: (_) => role == UserRole.citizen
                              ? const CitizenHome()
                              : const WorkerHome(),
                        ),
                      );
                    },

                    child: const Padding(
                      padding: EdgeInsets.all(14),

                      child: Text('Login'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Demo mode: backend/Firebase can be connected later.',

                    textAlign: TextAlign.center,

                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CitizenHome extends StatelessWidget {
  const CitizenHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SahaySetu'),

        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacement(
              context,

              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),

            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          const Text(
            'Good morning, Citizen',

            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          const Text('Report an issue and track how your city responds.'),

          const SizedBox(height: 18),

          _healthScoreCard(context),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _statCard('Active', '2', Icons.pending_actions)),

              const SizedBox(width: 12),

              Expanded(
                child: _statCard('Resolved', '8', Icons.check_circle_outline),
              ),
            ],
          ),

          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,

              MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
            ),

            icon: const Icon(Icons.add_a_photo),

            label: const Padding(
              padding: EdgeInsets.all(14),

              child: Text('Report Civic Issue'),
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,

              MaterialPageRoute(builder: (_) => const MyComplaintsScreen()),
            ),

            icon: const Icon(Icons.track_changes),

            label: const Text('Track My Complaints'),
          ),

          const SizedBox(height: 24),

          const Text(
            'Recent complaints',

            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ...complaints.map(
            (c) => ComplaintCard(
              complaint: c,

              onTap: () => Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                      ComplaintDetailsScreen(complaint: c, citizen: true),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthScoreCard(BuildContext context) {
    return Card(
      elevation: 0,

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Row(
          children: [
            SizedBox(
              width: 72,

              height: 72,

              child: Stack(
                alignment: Alignment.center,

                children: [
                  CircularProgressIndicator(
                    value: .78,

                    strokeWidth: 8,

                    backgroundColor: Colors.grey.shade200,
                  ),

                  const Text(
                    '78',

                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 18),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'City Health Score',

                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Based on complaint trends, resolution and recurring issues.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Card(
      elevation: 0,

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Icon(icon, size: 28),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            Text(label),
          ],
        ),
      ),
    );
  }
}

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  String category = 'Road Damage';

  String severity = 'High';

  bool locationCaptured = false;

  bool photoCaptured = false;

  final description = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _photo;
  Position? _position;
  bool _isCapturingLocation = false;

  Future<void> _capturePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (!mounted || image == null) return;

      setState(() {
        _photo = image;
        photoCaptured = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera error: $e')));
    }
  }

  Future<void> _captureLocation() async {
    try {
      setState(() => _isCapturingLocation = true);

      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable device location first.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission was not granted.')),
        );
        return;
      }

      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (!mounted) return;

      setState(() {
        _position = pos;
        locationCaptured = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('GPS error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isCapturingLocation = false);
      }
    }
  }

  @override
  void dispose() {
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Civic Issue')),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          _actionTile(
            Icons.camera_alt,

            'Live Photo',

            photoCaptured ? 'Photo captured' : 'Capture issue photo',

            photoCaptured,

            _capturePhoto,
          ),

          _actionTile(
            Icons.location_on,

            'GPS Location',

            _isCapturingLocation
                ? 'Getting GPS location...'
                : (_position == null
                      ? 'Capture current location'
                      : '${_position!.latitude.toStringAsFixed(5)}, '
                            '${_position!.longitude.toStringAsFixed(5)}'),

            locationCaptured,

            _isCapturingLocation ? () {} : _captureLocation,
          ),

          if (_photo != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_photo!.path),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: category,

            decoration: const InputDecoration(labelText: 'Category'),

            items: const [
              'Road Damage',

              'Street Light',

              'Garbage',

              'Water Problem',

              'Drainage',
            ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),

            onChanged: (x) => setState(() => category = x!),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: severity,

            decoration: const InputDecoration(labelText: 'Severity'),

            items: const [
              'Low',
              'Medium',
              'High',
            ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),

            onChanged: (x) => setState(() => severity = x!),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: description,

            maxLines: 5,

            decoration: const InputDecoration(
              labelText: 'Describe the issue',

              hintText: 'Explain what you observed...',

              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 18),

          Card(
            elevation: 0,

            child: ListTile(
              leading: const Icon(Icons.auto_awesome),

              title: const Text('Intelligent classification'),

              subtitle: Text(
                'After submission, the backend can classify this complaint and compare it with nearby/time-related reports.',
              ),
            ),
          ),

          const SizedBox(height: 18),

          FilledButton(
            onPressed: () {
              if (!photoCaptured || _photo == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please capture a live photo first.'),
                  ),
                );
                return;
              }

              if (!locationCaptured || _position == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please capture your GPS location first.'),
                  ),
                );
                return;
              }

              if (description.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please describe the issue first.'),
                  ),
                );
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Form validated. Backend upload is not connected yet.',
                  ),
                ),
              );
            },

            child: const Padding(
              padding: EdgeInsets.all(14),

              child: Text('Submit Complaint'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
    IconData icon,

    String title,

    String subtitle,

    bool done,

    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,

      child: ListTile(
        leading: CircleAvatar(child: Icon(done ? Icons.check : icon)),

        title: Text(title),

        subtitle: Text(subtitle),

        trailing: FilledButton.tonal(
          onPressed: onTap,
          child: Text(done ? 'Done' : 'Add'),
        ),
      ),
    );
  }
}

class MyComplaintsScreen extends StatelessWidget {
  const MyComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: complaints
            .map(
              (c) => ComplaintCard(
                complaint: c,

                onTap: () => Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        ComplaintDetailsScreen(complaint: c, citizen: true),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final Complaint complaint;

  final VoidCallback onTap;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      margin: const EdgeInsets.only(bottom: 10),

      child: ListTile(
        onTap: onTap,

        leading: CircleAvatar(child: Icon(_icon(complaint.category))),

        title: Text(
          complaint.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(
          '${complaint.location}\n${complaint.status} • ${complaint.priority} priority',
        ),

        isThreeLine: true,

        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  IconData _icon(String category) {
    if (category == 'Street Light') return Icons.lightbulb_outline;

    if (category == 'Garbage') return Icons.delete_outline;

    if (category == 'Water Problem') return Icons.water_drop_outlined;

    return Icons.construction_outlined;
  }
}

class ComplaintDetailsScreen extends StatefulWidget {
  final Complaint complaint;

  final bool citizen;

  const ComplaintDetailsScreen({
    super.key,

    required this.complaint,

    required this.citizen,
  });

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  int rating = 0;

  bool verified = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.complaint;

    return Scaffold(
      appBar: AppBar(title: Text(c.id)),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          Text(
            c.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(c.description),

          const SizedBox(height: 18),

          _info(Icons.location_on, 'Location', c.location),

          _info(Icons.priority_high, 'Priority', c.priority),

          _info(Icons.link, 'Possible linked condition', c.possibleLink),

          _info(Icons.history, 'Previous intervention', c.previousIntervention),

          const SizedBox(height: 16),

          const Text(
            'Incident relationship analysis',

            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Card(
            elevation: 0,

            child: ListTile(
              leading: const Icon(Icons.hub),

              title: Text('${c.relatedReports} related report(s)'),

              subtitle: Text(
                c.recurrence
                    ? 'Recurrence detected after previous intervention.'
                    : 'No recurrence detected for this complaint.',
              ),
            ),
          ),

          const SizedBox(height: 14),

          _timeline(c.status),

          const SizedBox(height: 18),

          if (c.recurrence)
            Card(
              elevation: 0,

              child: ListTile(
                leading: const Icon(Icons.lightbulb_outline),

                title: const Text('Preventive recommendation'),

                subtitle: Text(c.recommendation),
              ),
            ),

          if (widget.citizen && c.status == 'Resolved') ...[
            const SizedBox(height: 18),

            const Text(
              'Verify resolution',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            FilledButton.icon(
              onPressed: () => setState(() => verified = true),

              icon: Icon(verified ? Icons.check : Icons.verified_outlined),

              label: Text(verified ? 'Verified by citizen' : 'Verify work'),
            ),

            const SizedBox(height: 12),

            const Text('Rate the resolution'),

            Row(
              children: List.generate(
                5,

                (i) => IconButton(
                  onPressed: () => setState(() => rating = i + 1),

                  icon: Icon(i < rating ? Icons.star : Icons.star_border),
                ),
              ),
            ),

            if (verified)
              const Text(
                'Complaint can now be closed after citizen verification.',

                style: TextStyle(fontWeight: FontWeight.w600),
              ),
          ],
        ],
      ),
    );
  }

  Widget _info(IconData icon, String title, String value) {
    return Card(
      elevation: 0,

      child: ListTile(
        leading: Icon(icon),

        title: Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),

        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _timeline(String status) {
    const states = ['Pending', 'In Progress', 'Resolved'];

    final current = states.indexOf(status);

    return Card(
      elevation: 0,

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Complaint status',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            for (int i = 0; i < states.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,

                leading: CircleAvatar(
                  child: Icon(
                    i <= current ? Icons.check : Icons.circle_outlined,
                  ),
                ),

                title: Text(states[i]),

                subtitle: i == current ? const Text('Current status') : null,
              ),
          ],
        ),
      ),
    );
  }
}

class WorkerHome extends StatelessWidget {
  const WorkerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Dashboard'),

        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacement(
              context,

              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),

            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          const Text(
            'Assigned Work',

            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          const Text(
            'Review related reports before starting the intervention.',
          ),

          const SizedBox(height: 18),

          Card(
            elevation: 0,

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Row(
                children: [
                  const Icon(Icons.assignment_turned_in_outlined, size: 34),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Assigned today',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        Text('2 complaints • 1 high priority'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          ...complaints.map(
            (c) => ComplaintCard(
              complaint: c,

              onTap: () => Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) => WorkerComplaintScreen(complaint: c),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkerComplaintScreen extends StatefulWidget {
  final Complaint complaint;

  const WorkerComplaintScreen({super.key, required this.complaint});

  @override
  State<WorkerComplaintScreen> createState() => _WorkerComplaintScreenState();
}

class _WorkerComplaintScreenState extends State<WorkerComplaintScreen> {
  String status = 'Pending';

  bool completionPhoto = false;

  @override
  void initState() {
    super.initState();

    status = widget.complaint.status;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.complaint;

    return Scaffold(
      appBar: AppBar(title: Text(c.id)),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          Text(
            c.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(c.location),

          const SizedBox(height: 16),

          Card(
            elevation: 0,

            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.priority_high),

                  title: const Text('Priority'),

                  subtitle: Text(c.priority),
                ),

                ListTile(
                  leading: const Icon(Icons.hub_outlined),

                  title: const Text('Related reports'),

                  subtitle: Text(
                    '${c.relatedReports} nearby/related report(s)',
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.water_drop_outlined),

                  title: const Text('Possible linked condition'),

                  subtitle: Text(c.possibleLink),
                ),

                ListTile(
                  leading: const Icon(Icons.history),

                  title: const Text('Previous intervention'),

                  subtitle: Text(c.previousIntervention),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Work status',

            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: status,

            decoration: const InputDecoration(labelText: 'Status'),

            items: const [
              'Pending',
              'In Progress',
              'Resolved',
            ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),

            onChanged: (x) {
              if (x != null) {
                setState(() => status = x);

                c.status = x;
              }
            },
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () => setState(() => completionPhoto = true),

            icon: Icon(completionPhoto ? Icons.check : Icons.camera_alt),

            label: Text(
              completionPhoto
                  ? 'Completion photo added'
                  : 'Add completion photo',
            ),
          ),

          const SizedBox(height: 12),

          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Status saved as $status')),
              );
            },

            child: const Padding(
              padding: EdgeInsets.all(14),

              child: Text('Save Work Update'),
            ),
          ),

          const SizedBox(height: 16),

          if (status == 'Resolved')
            const Card(
              elevation: 0,

              child: ListTile(
                leading: Icon(Icons.verified_outlined),

                title: Text('Citizen verification pending'),

                subtitle: Text(
                  'The citizen should verify the work before the complaint is finally closed.',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
