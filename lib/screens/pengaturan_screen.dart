import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengaturanScreen extends StatefulWidget {
  @override
  _PengaturanScreenState createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  double fontSize = 16.0;
  String fontStyle = 'Amiri'; 
  double lineSpacing = 1.5; 
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fontSize = prefs.getDouble('fontSize') ?? 16.0;
      fontStyle = prefs.getString('fontStyle') ?? 'Amiri';
      lineSpacing = prefs.getDouble('lineSpacing') ?? 1.5;
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

Future<void> saveSettings(String key, dynamic value) async {
  final prefs = await SharedPreferences.getInstance();
  if (value is double) {
    await prefs.setDouble(key, value);
  } else if (value is String) {
    await prefs.setString(key, value);
  } else if (value is bool) {
    await prefs.setBool(key, value);
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Pengaturan'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          ListTile(
            title: Text('Ukuran Font'),
            subtitle: Slider(
              value: fontSize,
              activeColor: Color(0xFF819BA0),
              min: 12.0,
              max: 30.0,
              divisions: 18,
              label: '${fontSize.toStringAsFixed(1)} pt',
              onChanged: (value) {
                setState(() {
                  fontSize = value;
                  saveSettings('fontSize', value);
                });
              },
            ),
          ),

          Divider(),

          ListTile(
            title: Text('Gaya Font'),
            subtitle: DropdownButton<String>(
              value: fontStyle,
              isExpanded: true,
              items: ['Amiri', 'Lato', 'Modern'].map((style) {
                return DropdownMenuItem(
                  value: style,
                  child: Text(style),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  fontStyle = value!;
                  saveSettings('fontStyle', value);
                });
              },
            ),
          ),

          Divider(),
        ],
      ),
    ),
  );
}

  Widget buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String trailing,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: value.toStringAsFixed(1),
        onChanged: onChanged,
      ),
      trailing: Text(trailing),
    );
  }
}
