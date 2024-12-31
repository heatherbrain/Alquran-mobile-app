import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'surah_list_screen.dart';

class TerakhirBacaScreen extends StatefulWidget {
  @override
  _TerakhirBacaScreenState createState() => _TerakhirBacaScreenState();
}

class _TerakhirBacaScreenState extends State<TerakhirBacaScreen> {
  bool isLoading = true;
  List<dynamic> lastReadData = [];

  @override
  void initState() {
    super.initState();
    loadLastReadAyat();
  }

  Future<void> loadLastReadAyat() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('lastReadAyats');
    setState(() {
      lastReadData = storedData != null ? json.decode(storedData) : [];
      isLoading = false;
    });
  }

  Future<void> deleteAyat(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => lastReadData.removeAt(index));
    await prefs.setString('lastReadAyats', json.encode(lastReadData));
    if (lastReadData.isEmpty) {
      await prefs.remove('lastReadAyatNumber');
      await prefs.remove('lastReadSurahName');
      await prefs.remove('lastReadSurahNumber');
    }
  }

  Future<void> navigateToSurahList(Map<String, dynamic> data) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahListScreen(
          surahId: data['surahNumber'],
          // ayatNumber: data['ayatNumber'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terakhir Dibaca'),
        backgroundColor: Color(0xFF819BA0),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF819BA0)),
              ),
            )
          : lastReadData.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada data terakhir baca.',
                    style: GoogleFonts.lato(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: lastReadData.length,
                  itemBuilder: (context, index) {
                    final data = lastReadData[index];
                    return Dismissible(
                      key: Key(data['ayatNumber'].toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => deleteAyat(index),
                      background: Container(
                        color: Color.fromARGB(255, 62, 94, 100),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        onTap: () => navigateToSurahList(data),
                        title: Text(
                          'Surah ${data['surahName']} (Ayat ${data['ayatNumber']})',
                          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Surah nomor ${data['surahNumber']}'),
                      ),
                    );
                  },
                ),
    );
  }
}


