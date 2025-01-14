import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengaturanScreen extends StatefulWidget {
  @override
  _PengaturanScreenState createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  double fontSize = 16.0;
  String fontStyleLatin = 'Amiri';
  String fontStyleArti = 'Lato';

  final List<String> fontStyles = ['Amiri', 'Lato'];

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fontSize = prefs.getDouble('fontSize') ?? 16.0;
      fontStyleLatin = fontStyles.contains(prefs.getString('fontStyleLatin'))
          ? prefs.getString('fontStyleLatin')!
          : 'Amiri'; 
      fontStyleArti = fontStyles.contains(prefs.getString('fontStyleArti'))
          ? prefs.getString('fontStyleArti')!
          : 'Lato'; 
    });
  }

  Future<void> saveSettings(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
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
                activeColor: Color.fromARGB(255, 103, 140, 170),
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
              title: Text('Gaya Font Latin'),
              subtitle: DropdownButton<String>(
                value: fontStyles.contains(fontStyleLatin) ? fontStyleLatin : null,
                isExpanded: true,
                items: fontStyles.map((style) {
                  return DropdownMenuItem(
                    value: style,
                    child: Text(style),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    fontStyleLatin = value!;
                    saveSettings('fontStyleLatin', value);
                  });
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Gaya Font Arti'),
              subtitle: DropdownButton<String>(
                value: fontStyles.contains(fontStyleArti) ? fontStyleArti : null,
                isExpanded: true,
                items: fontStyles.map((style) {
                  return DropdownMenuItem(
                    value: style,
                    child: Text(style),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    fontStyleArti = value!;
                    saveSettings('fontStyleArti', value);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
