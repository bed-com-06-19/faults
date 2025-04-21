import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: AdminDashboard(
        isDarkMode: isDarkMode,
        toggleTheme: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const AdminDashboard({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
      body: StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                color: Colors.grey[201],
                child: Row(
                  children: [
                    const Icon(Icons.brightness_2, color: Colors.green),
                    const SizedBox(width: 10),
                    const Text("theme\nlight/dark", style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Switch(
                      value: isDarkMode,
                      onChanged: (val) => toggleTheme(),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text("change password", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: oldPasswordController,
                obscureText: obscureOld,
                decoration: InputDecoration(
                  labelText: 'old password',
                  suffixIcon: IconButton(
                    icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscureOld = !obscureOld),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: obscureNew,
                decoration: InputDecoration(
                  labelText: 'new password',
                  suffixIcon: IconButton(
                    icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscureNew = !obscureNew),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text("close", style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // implement your save logic
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("save"),
                  ),
                ],
              ),
              const Spacer(),
              const Divider(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout),
                label: const Text("log out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
