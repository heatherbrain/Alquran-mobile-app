import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SurahDetailScreen extends StatefulWidget {
  final String surahName;
  final int surahNumber;

  SurahDetailScreen({required this.surahName, required this.surahNumber});

  @override
  _SurahDetailScreenState createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  bool isLoading = true;
  List<dynamic> ayats = [];
  int? lastReadAyatNumber;
  final ScrollController _scrollController = ScrollController();

  double fontSize = 16.0;
  String fontStyle = 'Amiri';
  bool isTajwidEnabled = true;

  @override
  void initState() {
    super.initState();
    fetchSurahDetail();
    loadLastReadAyat();
    loadSettings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fontSize = prefs.getDouble('fontSize') ?? 16.0;
      fontStyle = prefs.getString('fontStyle') ?? 'Amiri';
      isTajwidEnabled = prefs.getBool('isTajwidEnabled') ?? true;
    });
  }

  void scrollToLastReadAyat() {
    if (lastReadAyatNumber != null) {
      final index = ayats.indexWhere((ayat) => ayat['nomor'] == lastReadAyatNumber);
      if (index != -1) {
        _scrollController.animateTo(
          index * 100.0,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> fetchSurahDetail() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://quran-api.santrikoding.com/api/surah/${widget.surahNumber}',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ayats = data['ayat'] ?? [];
          isLoading = false;
        });
        scrollToLastReadAyat();
      } else {
        throw Exception('Failed to load surah detail');
      }
    } catch (error) {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadLastReadAyat() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => lastReadAyatNumber = prefs.getInt('lastReadAyatNumber'));
  }

  Future<void> saveLastReadAyat(int ayatNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('lastReadAyats');
    List<dynamic> lastReadAyats = storedData != null ? json.decode(storedData) : [];

    lastReadAyats.removeWhere((entry) =>
        entry['surahNumber'] == widget.surahNumber &&
        entry['ayatNumber'] == ayatNumber);

    lastReadAyats.add({
      'surahNumber': widget.surahNumber,
      'surahName': widget.surahName,
      'ayatNumber': ayatNumber,
    });

    await prefs.setString('lastReadAyats', json.encode(lastReadAyats));
  }

  String removeHtmlTags(String input) {
    final RegExp htmlTagRegExp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return input.replaceAll(htmlTagRegExp, '');
  }

  Border? getAyatBorder(int ayatNumber) {
    return lastReadAyatNumber == ayatNumber
        ? Border.all(color: Color.fromARGB(255, 103, 140, 170), width: 3.0)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF819BA0)),
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: ayats.length,
              itemBuilder: (context, index) {
                final ayat = ayats[index];
                final backgroundColor =
                    index % 2 == 0 ? Color(0xFFE6F1F3) : Colors.white;

                return GestureDetector(
                  onLongPress: () async {
                    await saveLastReadAyat(ayat['nomor']);
                    setState(() => lastReadAyatNumber = ayat['nomor']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Ayat ${ayat['nomor']} pada surah ${widget.surahName} disimpan sebagai terakhir baca.',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: getAyatBorder(ayat['nomor']),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/border1.png',
                                  width: 45,
                                  height: 45,
                                  fit: BoxFit.contain,
                                ),
                                Center(
                                  child: Text(
                                    ayat['nomor'].toString(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Text(
                                ayat['ar'] ?? 'Teks Arab tidak tersedia',
                                textAlign: TextAlign.right,
                                style: GoogleFonts.getFont(
                                  fontStyle,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          removeHtmlTags(ayat['tr'] ?? 'Transliterasi tidak tersedia'),
                          style: GoogleFonts.getFont(
                            fontStyle,
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          ayat['idn'] ?? 'Terjemahan tidak tersedia',
                          style: GoogleFonts.getFont(
                            fontStyle,
                            fontSize: fontSize * 0.9,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}