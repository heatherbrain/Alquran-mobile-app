import 'package:alquran_app/screens/surah_list_screen.dart';
import 'package:alquran_app/widget/audio_controll_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SurahDetailScreen extends StatefulWidget {
  final String surahName;
  final int surahNumber;
  final int? ayatNumber;
  final int? lastReadAyat;

  const SurahDetailScreen({
    Key? key,
    required this.surahName,
    required this.surahNumber,
    this.ayatNumber,
    this.lastReadAyat,
  }) : super(key: key);

  @override
  _SurahDetailScreenState createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  bool isLoading = true;
  List<dynamic> ayats = [];
  int? lastReadAyatNumber;
  late ScrollController _scrollController;

  double fontSize = 16.0;
  String fontStyleLatin = 'Amiri';
  String fontStyleArti = 'Lato';
  bool isTajwidEnabled = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([
        fetchSurahDetail(),
        loadLastReadAyat(),
        loadSettings(),
      ]);

      if (!mounted) return;

      setState(() => isLoading = false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.lastReadAyat != null && widget.lastReadAyat! > 0) {
          scrollToAyat(widget.lastReadAyat!);
        }
      });
    } catch (e) {
      print("Error initializing data: $e");
      setState(() => isLoading = false);
    }
  }

  void scrollToAyat(int ayatNumber) {
    final targetIndex = ayats.indexWhere((ayat) => ayat['nomor'] == ayatNumber);
    if (targetIndex != -1) {
      final double targetOffset = targetIndex * 155.0;
      _scrollController.animateTo(
        targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> fetchSurahDetail() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://quran-api.santrikoding.com/api/surah/${widget.surahNumber}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => ayats = data['ayat'] ?? []);
      } else {
        throw Exception('Failed to load surah details.');
      }
    } catch (e) {
      print("Error fetching surah detail: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadLastReadAyat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAyat = prefs.getInt('lastReadAyatNumber');
      final savedSurah = prefs.getInt('lastReadSurah');

      if (savedSurah == widget.surahNumber) {
        setState(() => lastReadAyatNumber = savedAyat);
      }
    } catch (e) {
      print("Error loading last read ayat: $e");
    }
  }

  Future<void> saveLastReadAyat(int ayatNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastReadAyatNumber', ayatNumber);
      await prefs.setInt('lastReadSurah', widget.surahNumber);

      final storedData = prefs.getString('lastReadAyats');
      List<dynamic> lastReadAyats =
          storedData != null ? json.decode(storedData) : [];

      lastReadAyats
          .removeWhere((entry) => entry['surahNumber'] == widget.surahNumber);
      lastReadAyats.insert(0, {
        'surahNumber': widget.surahNumber,
        'surahName': widget.surahName,
        'ayatNumber': ayatNumber,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      if (lastReadAyats.length > 10) {
        lastReadAyats = lastReadAyats.sublist(0, 10);
      }

      await prefs.setString('lastReadAyats', json.encode(lastReadAyats));

      setState(() => lastReadAyatNumber = ayatNumber);
    } catch (e) {
      print("Error saving last read ayat: $e");
    }
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        fontSize = prefs.getDouble('fontSize') ?? 16.0;
        fontStyleLatin = prefs.getString('fontStyleLatin') ?? 'Amiri';
        fontStyleArti = prefs.getString('fontStyleArti') ?? 'Lato';
        isTajwidEnabled = prefs.getBool('isTajwidEnabled') ?? true;
      });
    } catch (e) {
      print("Error loading settings: $e");
    }
  }

  String removeHtmlTags(String input) {
    final RegExp htmlTagRegExp =
        RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return input.replaceAll(htmlTagRegExp, '');
  }

  Border? getAyatBorder(int ayatNumber) {
    if (lastReadAyatNumber == ayatNumber || widget.lastReadAyat == ayatNumber) {
      return Border.all(color: const Color(0xFF679AAA), width: 3.0);
    }
    return null;
  }

  void _handleSurahChange(int newSurahNumber, {int? lastReadAyat}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SurahListScreen(
          surahId: newSurahNumber,
          lastReadAyat: lastReadAyat ?? 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
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
                    index % 2 == 0 ? const Color(0xFFE6F1F3) : Colors.white;

                return GestureDetector(
                  onLongPress: () async {
                    await saveLastReadAyat(ayat['nomor']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Ayat ${ayat['nomor']} pada surah ${widget.surahName} disimpan sebagai terakhir baca.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
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
                                    style: const TextStyle(
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
                                  fontStyleLatin,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          removeHtmlTags(
                              ayat['tr'] ?? 'Transliterasi tidak tersedia'),
                          style: GoogleFonts.getFont(
                            fontStyleLatin,
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ayat['idn'] ?? 'Terjemahan tidak tersedia',
                          style: GoogleFonts.getFont(
                            fontStyleArti,
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
      floatingActionButton: AudioControlWidget(
        surahNumber: widget.surahNumber,
        onSurahChange: (int newSurahNumber) {
          _handleSurahChange(newSurahNumber, lastReadAyat: lastReadAyatNumber);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
