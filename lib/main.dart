import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const SahaySetuApp());

final appState = SahaySetuState();

class SahaySetuApp extends StatelessWidget {
  const SahaySetuApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SahaySetu',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B87)),
      scaffoldBackgroundColor: const Color(0xFFF5F8FA),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.only(bottom: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    ),
    home: const RoleLoginScreen(),
  );
}

enum AppRole { citizen, worker }

// Demo-only accounts: these disappear when the app process is reset.
class DemoCitizenAccount {
  DemoCitizenAccount({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
  final String name;
  final String email;
  final String phone;
  final String password;
}

final Map<String, DemoCitizenAccount> demoCitizenAccounts = {};
// Demo worker roster. Real worker accounts must come from the backend.
const Map<String, String> demoWorkerAccounts = {
  'rahul@sahaysetu': 'rahul1234',
  'amit@sahaysetu': 'amit1234',
};

class CivicComplaint {
  CivicComplaint({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.priority,
    required this.createdAt,
    this.photoPath,
    this.ownerEmail,
    this.latitude,
    this.longitude,
    this.department = 'Unassigned',
    this.worker = 'Unassigned',
    this.status = 'Pending',
    this.verified = false,
    this.rating = 0,
  });
  final String id;
  final String category;
  final String title;
  final String description;
  final String priority;
  final DateTime createdAt;
  final String? photoPath;
  final String? ownerEmail;
  final double? latitude;
  final double? longitude;
  String department;
  String worker;
  String status;
  bool verified;
  int rating;
  String get location => latitude == null || longitude == null
      ? 'Location not captured'
      : '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}';
}

class SahaySetuState extends ChangeNotifier {
  String? currentCitizenEmail;
  int _nextId = 1026;
  final List<CivicComplaint> complaints = [
    CivicComplaint(
      id: 'SS-1024',
      category: 'Road Damage',
      title: 'Pothole near main gate',
      description: 'Large pothole causing difficulty for vehicles.',
      priority: 'High',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      latitude: 28.6139,
      longitude: 77.2090,
      department: 'Roads',
      worker: 'Rahul Sharma',
      status: 'In Progress',
    ),
    CivicComplaint(
      id: 'SS-1025',
      category: 'Street Light',
      title: 'Street light not working',
      description: 'Street light is not working near the community gate.',
      priority: 'Medium',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      latitude: 28.6200,
      longitude: 77.2150,
      department: 'Electrical',
      worker: 'Amit Kumar',
      status: 'Pending',
    ),
  ];
  CivicComplaint addComplaint({
    required String category,
    required String description,
    required String priority,
    String? photoPath,
    String? ownerEmail,
    double? latitude,
    double? longitude,
  }) {
    final complaint = CivicComplaint(
      id: 'SS-${_nextId++}',
      category: category,
      title: '$category complaint',
      description: description,
      priority: priority,
      createdAt: DateTime.now(),
      photoPath: photoPath,
      ownerEmail: ownerEmail,
      latitude: latitude,
      longitude: longitude,
    );
    complaints.insert(0, complaint);
    notifyListeners();
    return complaint;
  }

  void assign(CivicComplaint c, String department, String worker) {
    c.department = department;
    c.worker = worker;
    if (c.status == 'Pending') c.status = 'Assigned';
    notifyListeners();
  }

  void updateStatus(CivicComplaint c, String status) {
    c.status = status;
    notifyListeners();
  }

  void verify(CivicComplaint c, int rating) {
    c.verified = true;
    c.rating = rating;
    c.status = 'Closed';
    notifyListeners();
  }

  int get activeCount => complaints.where((c) => c.status != 'Closed').length;
  int get resolvedCount => complaints
      .where((c) => c.status == 'Resolved' || c.status == 'Closed')
      .length;
  int get healthScore => complaints.isEmpty
      ? 100
      : ((complaints.where((c) => c.status == 'Closed').length /
                    complaints.length) *
                100)
            .round();
}

class RoleLoginScreen extends StatefulWidget {
  const RoleLoginScreen({super.key});
  @override
  State<RoleLoginScreen> createState() => _RoleLoginScreenState();
}

class _RoleLoginScreenState extends State<RoleLoginScreen> {
  AppRole role = AppRole.citizen;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool obscurePassword = true;
  bool signingUp = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Please enter your password';
    if (password.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(password)) return 'Include a letter';
    if (!RegExp(r'\d').hasMatch(password)) return 'Include a number';
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Include a symbol (e.g. @ or #)';
    }
    return null;
  }

  void showError(String text) => message(context, text);

  void login() {
    FocusScope.of(context).unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;
    if (role == AppRole.citizen) {
      final account = demoCitizenAccounts[email];
      if (account == null || account.password != password) {
        showError(
          'Account not found or password is incorrect. Please sign up first.',
        );
        return;
      }
      appState.currentCitizenEmail = account.email;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CitizenHome(
            name: account.name,
            email: account.email,
            phone: account.phone,
          ),
        ),
      );
      return;
    }
    // Demo credentials only. Replace with backend-issued worker credentials later.
    final workerName = email.split('@').first;
    if (!demoWorkerAccounts.containsKey(email) ||
        demoWorkerAccounts[email] != password) {
      showError(
        'Invalid worker username or password. Try rahul@sahaysetu / rahul1234 or amit@sahaysetu / amit1234.',
      );
      return;
    }
    final displayName = workerName.isEmpty
        ? 'Field Worker'
        : '${workerName[0].toUpperCase()}${workerName.substring(1)}';
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => WorkerHome(name: displayName)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const CircleAvatar(
                    radius: 38,
                    child: Icon(Icons.location_city, size: 42),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SahaySetu',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Smart Civic Complaint Management',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Continue as',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<AppRole>(
                    segments: const [
                      ButtonSegment(
                        value: AppRole.citizen,
                        label: Text('Citizen'),
                        icon: Icon(Icons.person_outline),
                      ),
                      ButtonSegment(
                        value: AppRole.worker,
                        label: Text('Worker'),
                        icon: Icon(Icons.engineering_outlined),
                      ),
                    ],
                    selected: {role},
                    onSelectionChanged: (s) => setState(() {
                      role = s.first;
                      signingUp = false;
                      formKey.currentState?.reset();
                      passwordController.clear();
                      confirmPasswordController.clear();
                      emailController.clear();
                    }),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    role == AppRole.citizen
                        ? (signingUp
                              ? 'Create citizen account'
                              : 'Citizen sign in')
                        : 'Worker sign in',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      final v = value?.trim().toLowerCase() ?? '';
                      if (v.isEmpty) {
                        return role == AppRole.worker
                            ? 'Please enter your username'
                            : 'Please enter your email';
                      }
                      if (role == AppRole.worker) {
                        if (!RegExp(r'^[a-z]+@sahaysetu$').hasMatch(v)) {
                          return 'Use workerfirstname@sahaysetu';
                        }
                        return null;
                      }
                      if (!v.contains('@') || !v.contains('.')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    textInputAction: signingUp
                        ? TextInputAction.next
                        : TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!signingUp) login();
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      helperText: signingUp
                          ? 'Use at least 8 characters'
                          : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    validator: (value) {
                      if (role == AppRole.worker) {
                        return (value ?? '').isEmpty
                            ? 'Please enter your password'
                            : null;
                      }
                      return validatePassword(value);
                    },
                  ),
                  if (role == AppRole.citizen && signingUp) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                        prefixIcon: Icon(Icons.lock_reset_outlined),
                      ),
                      validator: (value) {
                        if ((value ?? '').isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _SignupExtraFields(
                      onValuesChanged: (name, phone) {
                        _signupName = name;
                        _signupPhone = phone;
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: signingUp ? _createAccount : login,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(signingUp ? 'Create Account' : 'Sign In'),
                    ),
                  ),
                  if (role == AppRole.citizen)
                    TextButton(
                      onPressed: () => setState(() {
                        signingUp = !signingUp;
                        formKey.currentState?.reset();
                        confirmPasswordController.clear();
                      }),
                      child: Text(
                        signingUp
                            ? 'Already have an account? Sign in'
                            : 'New citizen? Create an account',
                      ),
                    ),
                  if (role == AppRole.worker)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Worker accounts are created by the organisation, not through this app.\nUsername format: workerfirstname@sahaysetu\nPassword format: workerfirstname1234\n\nDemo users: rahul@sahaysetu / rahul1234  •  amit@sahaysetu / amit1234',
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  String _signupName = '';
  String _signupPhone = '';

  void _createAccount() {
    FocusScope.of(context).unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    final email = emailController.text.trim().toLowerCase();
    if (_signupName.trim().isEmpty) {
      showError('Please enter your full name.');
      return;
    }
    if (_signupPhone.trim().length < 10) {
      showError('Please enter a valid phone number.');
      return;
    }
    if (demoCitizenAccounts.containsKey(email)) {
      showError('An account with this email already exists.');
      return;
    }
    if (confirmPasswordController.text != passwordController.text) {
      showError('Passwords do not match.');
      return;
    }
    demoCitizenAccounts[email] = DemoCitizenAccount(
      name: _signupName.trim(),
      email: email,
      phone: _signupPhone.trim(),
      password: passwordController.text,
    );
    appState.currentCitizenEmail = email;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CitizenHome(
          name: _signupName.trim(),
          email: email,
          phone: _signupPhone.trim(),
        ),
      ),
    );
  }
}

class _SignupExtraFields extends StatefulWidget {
  const _SignupExtraFields({required this.onValuesChanged});
  final void Function(String name, String phone) onValuesChanged;
  @override
  State<_SignupExtraFields> createState() => _SignupExtraFieldsState();
}

class _SignupExtraFieldsState extends State<_SignupExtraFields> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextFormField(
        controller: nameController,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Full name',
          prefixIcon: Icon(Icons.badge_outlined),
        ),
        validator: (v) => v == null || v.trim().isEmpty
            ? 'Please enter your full name'
            : null,
        onChanged: (_) =>
            widget.onValuesChanged(nameController.text, phoneController.text),
      ),
      const SizedBox(height: 14),
      TextFormField(
        controller: phoneController,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: 'Phone number',
          prefixIcon: Icon(Icons.phone_outlined),
        ),
        validator: (v) => v == null || v.trim().length < 10
            ? 'Enter at least 10 digits'
            : null,
        onChanged: (_) =>
            widget.onValuesChanged(nameController.text, phoneController.text),
      ),
    ],
  );
}

class BaseHome extends StatelessWidget {
  const BaseHome({
    super.key,
    required this.title,
    required this.name,
    required this.buildChildren,
    this.email = '',
    this.phone = '',
    this.isCitizen = false,
  });
  final String title, name, email, phone;
  final bool isCitizen;
  final List<Widget> Function() buildChildren;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    drawer: Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(name),
              accountEmail: Text(
                email.isEmpty
                    ? (isCitizen ? 'Citizen account' : 'Demo worker account')
                    : email,
              ),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person, size: 32),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      name: name,
                      email: email,
                      phone: phone,
                      isCitizen: isCitizen,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            if (isCitizen) ...[
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Previous Complaints / Records'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PreviousComplaintsScreen(name: name),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.health_and_safety_outlined),
                title: const Text('City Health Score'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CityHealthScoreScreen(),
                    ),
                  );
                },
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                appState.currentCitizenEmail = null;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const RoleLoginScreen()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    ),
    body: AnimatedBuilder(
      animation: appState,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hello, $name',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          ...buildChildren(),
        ],
      ),
    ),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.isCitizen,
  });
  final String name, email, phone;
  final bool isCitizen;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 42)),
        const SizedBox(height: 18),
        infoTile(Icons.badge_outlined, 'Name', name),
        infoTile(
          Icons.email_outlined,
          'Email',
          email.isEmpty ? 'Demo worker account' : email,
        ),
        if (isCitizen)
          infoTile(
            Icons.phone_outlined,
            'Phone',
            phone.isEmpty ? 'Not provided' : phone,
          ),
      ],
    ),
  );
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool locationReminder = true;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Complaint notifications'),
          subtitle: const Text('Demo preference only'),
          value: notifications,
          onChanged: (v) => setState(() => notifications = v),
        ),
        SwitchListTile(
          title: const Text('Location reminder'),
          subtitle: const Text('Remind me to capture GPS while reporting'),
          value: locationReminder,
          onChanged: (v) => setState(() => locationReminder = v),
        ),
      ],
    ),
  );
}

class PreviousComplaintsScreen extends StatelessWidget {
  const PreviousComplaintsScreen({super.key, required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previous Complaints')),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final mine = appState.complaints
              .where((c) => c.ownerEmail == appState.currentCitizenEmail)
              .toList();
          if (mine.isEmpty) {
            return const Center(
              child: Text(
                'No complaints yet. Report your first civic issue to see it here.',
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: mine
                .map(
                  (c) => ComplaintTile(
                    complaint: c,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CitizenComplaintDetails(complaint: c),
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class CityHealthScoreScreen extends StatelessWidget {
  const CityHealthScoreScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('City Health Score')),
    body: AnimatedBuilder(
      animation: appState,
      builder: (context, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: appState.healthScore / 100,
                      strokeWidth: 12,
                    ),
                    Text(
                      '${appState.healthScore}/100',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 10),
              Text(
                '${appState.resolvedCount} resolved/closed out of ${appState.complaints.length} total complaints',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget statCard(String title, String value, IconData icon) => Card(
  child: Padding(
    padding: const EdgeInsets.all(14),
    child: Column(
      children: [
        Icon(icon, size: 26),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        Text(title, textAlign: TextAlign.center),
      ],
    ),
  ),
);
Widget statusChip(String status) {
  final color = status == 'Closed'
      ? Colors.green
      : status == 'Resolved'
      ? Colors.teal
      : status == 'In Progress'
      ? Colors.blue
      : Colors.orange;
  return Chip(
    label: Text(status),
    visualDensity: VisualDensity.compact,
    side: BorderSide.none,
    backgroundColor: color.withValues(alpha: .12),
    labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
  );
}

class CitizenHome extends StatelessWidget {
  const CitizenHome({
    super.key,
    required this.name,
    this.email = '',
    this.phone = '',
  });
  final String name, email, phone;
  @override
  Widget build(BuildContext context) => BaseHome(
    title: 'Citizen Dashboard',
    name: name,
    email: email,
    phone: phone,
    isCitizen: true,
    buildChildren: () => [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: appState.healthScore / 100,
                      strokeWidth: 7,
                    ),
                    Text(
                      '${appState.healthScore}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'City Health Score',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      Row(
        children: [
          Expanded(
            child: statCard(
              'Active',
              '${appState.activeCount}',
              Icons.pending_actions,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: statCard(
              'Resolved / Closed',
              '${appState.resolvedCount}',
              Icons.task_alt,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
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
      const SizedBox(height: 8),
      const Text(
        'My complaints',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      ...appState.complaints
          .where((c) => c.ownerEmail == email)
          .map(
            (c) => ComplaintTile(
              complaint: c,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CitizenComplaintDetails(complaint: c),
                ),
              ),
            ),
          ),
      if (appState.complaints.where((c) => c.ownerEmail == email).isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'No complaints yet. Tap “Report Civic Issue” to get started.',
            ),
          ),
        ),
    ],
  );
}

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});
  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final formKey = GlobalKey<FormState>();
  final description = TextEditingController();
  final picker = ImagePicker();
  String category = 'Road Damage', priority = 'Medium';
  XFile? photo;
  Position? position;
  bool gettingLocation = false, saving = false;
  Future<void> capturePhoto() async {
    try {
      final x = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );
      if (mounted && x != null) setState(() => photo = x);
    } catch (e) {
      if (mounted) message(context, 'Camera error: $e');
    }
  }

  Future<void> captureGps() async {
    setState(() => gettingLocation = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      if (!enabled) {
        message(context, 'Please turn on device location.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        message(context, 'Location permission not granted.');
        return;
      }
      final value = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!mounted) return;
      setState(() => position = value);
    } catch (e) {
      if (mounted) message(context, 'GPS error: $e');
    } finally {
      if (mounted) setState(() => gettingLocation = false);
    }
  }

  @override
  void dispose() {
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Report Civic Issue')),
    body: Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(
                photo == null ? Icons.camera_alt : Icons.check_circle,
                color: photo == null ? null : Colors.green,
              ),
              title: const Text('Live issue photo'),
              subtitle: Text(
                photo == null
                    ? 'Capture a photo using camera'
                    : 'Photo captured',
              ),
              trailing: FilledButton.tonal(
                onPressed: capturePhoto,
                child: Text(photo == null ? 'Capture' : 'Retake'),
              ),
            ),
          ),
          if (photo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(photo!.path),
                height: 190,
                fit: BoxFit.cover,
              ),
            ),
          Card(
            child: ListTile(
              leading: Icon(
                position == null ? Icons.location_on : Icons.check_circle,
                color: position == null ? null : Colors.green,
              ),
              title: const Text('GPS location'),
              subtitle: Text(
                position == null
                    ? 'Capture the issue location'
                    : '${position!.latitude.toStringAsFixed(5)}, ${position!.longitude.toStringAsFixed(5)}',
              ),
              trailing: FilledButton.tonal(
                onPressed: gettingLocation ? null : captureGps,
                child: Text(
                  gettingLocation
                      ? 'Wait…'
                      : position == null
                      ? 'Capture'
                      : 'Refresh',
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(labelText: 'Issue category'),
            items: const [
              'Road Damage',
              'Street Light',
              'Garbage',
              'Water Problem',
              'Drainage',
            ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (x) => setState(() => category = x ?? category),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: priority,
            decoration: const InputDecoration(labelText: 'Severity'),
            items: const [
              'Low',
              'Medium',
              'High',
            ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (x) => setState(() => priority = x ?? priority),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: description,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Describe the issue',
              hintText: 'What happened and where?',
            ),
            validator: (x) => x == null || x.trim().isEmpty
                ? 'Please describe the issue'
                : null,
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: saving
                ? null
                : () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    if (photo == null) {
                      message(context, 'Please capture an issue photo.');
                      return;
                    }
                    if (position == null) {
                      message(context, 'Please capture GPS location.');
                      return;
                    }
                    setState(() => saving = true);
                    final submittedComplaint = appState.addComplaint(
                      category: category,
                      description: description.text.trim(),
                      priority: priority,
                      photoPath: photo!.path,
                      ownerEmail: appState.currentCitizenEmail,
                      latitude: position!.latitude,
                      longitude: position!.longitude,
                    );
                    setState(() => saving = false);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ComplaintSubmittedScreen(
                          complaint: submittedComplaint,
                        ),
                      ),
                    );
                  },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(saving ? 'Submitting…' : 'Submit Complaint'),
            ),
          ),
        ],
      ),
    ),
  );
}

class ComplaintSubmittedScreen extends StatelessWidget {
  const ComplaintSubmittedScreen({super.key, required this.complaint});
  final CivicComplaint complaint;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Complaint Submitted'),
      automaticallyImplyLeading: false,
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 88),
            const SizedBox(height: 20),
            const Text(
              'Your complaint is submitted successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'You can track your complaint from here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 22),
            Card(
              child: ListTile(
                leading: const Icon(Icons.confirmation_number_outlined),
                title: const Text('Complaint ID'),
                subtitle: Text(
                  complaint.id,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CitizenComplaintDetails(complaint: complaint),
                ),
              ),
              icon: const Icon(Icons.track_changes),
              label: const Padding(
                padding: EdgeInsets.all(14),
                child: Text('Track Complaint'),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}

class WorkerHome extends StatelessWidget {
  const WorkerHome({super.key, required this.name});
  final String name;
  @override
  Widget build(BuildContext context) => BaseHome(
    title: 'Field Worker',
    name: name,
    buildChildren: () => [
      const Text(
        'Assigned tasks',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      ...appState.complaints.map(
        (c) => ComplaintTile(
          complaint: c,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WorkerTaskScreen(complaint: c)),
          ),
        ),
      ),
    ],
  );
}

class WorkerTaskScreen extends StatefulWidget {
  const WorkerTaskScreen({super.key, required this.complaint});
  final CivicComplaint complaint;
  @override
  State<WorkerTaskScreen> createState() => _WorkerTaskScreenState();
}

class _WorkerTaskScreenState extends State<WorkerTaskScreen> {
  late String status;
  XFile? proof;
  final picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    status = widget.complaint.status == 'Assigned'
        ? 'Pending'
        : widget.complaint.status;
  }

  Future<void> takeProof() async {
    try {
      final x = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );
      if (mounted && x != null) setState(() => proof = x);
    } catch (e) {
      if (mounted) message(context, 'Camera error: $e');
    }
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
          Text(c.description),
          const SizedBox(height: 12),
          infoTile(Icons.location_on, 'GPS', c.location),
          infoTile(Icons.apartment, 'Department', c.department),
          infoTile(Icons.person, 'Assigned worker', c.worker),
          infoTile(Icons.priority_high, 'Priority', c.priority),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue:
                ['Pending', 'In Progress', 'Resolved'].contains(status)
                ? status
                : 'Pending',
            decoration: const InputDecoration(labelText: 'Update work status'),
            items: const [
              'Pending',
              'In Progress',
              'Resolved',
            ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (x) => setState(() => status = x ?? status),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: takeProof,
            icon: Icon(proof == null ? Icons.camera_alt : Icons.check_circle),
            label: Text(
              proof == null
                  ? 'Capture completion photo'
                  : 'Completion photo captured',
            ),
          ),
          if (proof != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(proof!.path),
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              if (status == 'Resolved' && proof == null) {
                message(
                  context,
                  'Capture completion photo before marking Resolved.',
                );
                return;
              }
              appState.updateStatus(c, status);
              message(context, 'Work status updated to $status in demo.');
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text('Save Work Update'),
            ),
          ),
        ],
      ),
    );
  }
}

String departmentFor(String category) {
  if (category == 'Road Damage') return 'Roads';
  if (category == 'Street Light') return 'Electrical';
  if (category == 'Garbage') return 'Sanitation';
  if (category == 'Water Problem') return 'Water Supply';
  return 'Drainage';
}

class ComplaintTile extends StatelessWidget {
  const ComplaintTile({
    super.key,
    required this.complaint,
    required this.onTap,
  });
  final CivicComplaint complaint;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Icon(iconFor(complaint.category))),
      title: Text(
        complaint.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${complaint.id} • ${complaint.location}\n${complaint.department} • ${complaint.priority} priority',
      ),
      isThreeLine: true,
      trailing: statusChip(complaint.status),
    ),
  );
}

IconData iconFor(String category) {
  switch (category) {
    case 'Street Light':
      return Icons.lightbulb_outline;
    case 'Garbage':
      return Icons.delete_outline;
    case 'Water Problem':
      return Icons.water_drop_outlined;
    case 'Drainage':
      return Icons.water;
    default:
      return Icons.construction_outlined;
  }
}

Widget infoTile(IconData icon, String title, String value) => Card(
  child: ListTile(
    leading: Icon(icon),
    title: Text(
      title,
      style: const TextStyle(fontSize: 12, color: Colors.black54),
    ),
    subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
  ),
);
void message(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class CitizenComplaintDetails extends StatefulWidget {
  const CitizenComplaintDetails({super.key, required this.complaint});
  final CivicComplaint complaint;
  @override
  State<CitizenComplaintDetails> createState() =>
      _CitizenComplaintDetailsState();
}

class _CitizenComplaintDetailsState extends State<CitizenComplaintDetails> {
  int rating = 0;
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
          Text(c.description),
          const SizedBox(height: 12),
          infoTile(Icons.category, 'Category', c.category),
          infoTile(Icons.location_on, 'GPS location', c.location),
          infoTile(Icons.apartment, 'Department', c.department),
          infoTile(Icons.person, 'Assigned worker', c.worker),
          infoTile(Icons.priority_high, 'Priority', c.priority),
          const SizedBox(height: 8),
          const Text(
            'Complaint progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          for (final s in [
            'Pending',
            'Assigned',
            'In Progress',
            'Resolved',
            'Closed',
          ])
            ListTile(
              leading: Icon(
                (s == c.status || (s == 'Closed' && c.verified))
                    ? Icons.check_circle
                    : Icons.circle_outlined,
              ),
              title: Text(s),
              subtitle: s == c.status ? const Text('Current status') : null,
            ),
          if (c.status == 'Resolved' && !c.verified) ...[
            const Divider(),
            const Text(
              'Verify the repair',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Please rate the work before closing this complaint.'),
            Row(
              children: List.generate(
                5,
                (i) => IconButton(
                  onPressed: () => setState(() => rating = i + 1),
                  icon: Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: rating == 0
                  ? null
                  : () {
                      appState.verify(c, rating);
                      setState(() {});
                      message(
                        context,
                        'Thank you. Complaint verified and closed in demo.',
                      );
                    },
              icon: const Icon(Icons.verified),
              label: const Text('Verify & Close Complaint'),
            ),
          ],
          if (c.verified)
            Card(
              child: ListTile(
                leading: const Icon(Icons.verified, color: Colors.green),
                title: const Text('Citizen verified'),
                subtitle: Text('Rating: ${c.rating}/5 • Complaint closed'),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
