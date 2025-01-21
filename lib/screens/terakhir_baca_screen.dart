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
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('lastReadAyats');
      
      if (storedData != null) {
        List<dynamic> decodedData = json.decode(storedData);
        
        Map<int, Map<String, dynamic>> filteredMap = {};
        
        for (var i = decodedData.length - 1; i >= 0; i--) {
          var entry = decodedData[i];
          int surahNumber = entry['surahNumber'] ?? 0;
          
          if (!filteredMap.containsKey(surahNumber)) {
            filteredMap[surahNumber] = entry;
          }
        }
        
        List<dynamic> filteredList = filteredMap.values.toList();
        
        filteredList.sort((a, b) {
          int indexA = decodedData.indexWhere((item) => 
            item['surahNumber'] == a['surahNumber'] && 
            item['ayatNumber'] == a['ayatNumber']);
          int indexB = decodedData.indexWhere((item) => 
            item['surahNumber'] == b['surahNumber'] && 
            item['ayatNumber'] == b['ayatNumber']);
          return indexB.compareTo(indexA);
        });
        
        setState(() {
          lastReadData = filteredList;
          isLoading = false;
        });

        print('Loaded last read ayat: $lastReadData');
        
        await prefs.setString('lastReadAyats', json.encode(filteredList));
      } else {
        setState(() {
          lastReadData = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        lastReadData = [];
        isLoading = false;
      });
      print("Error loading last read ayat: $e");
    }
  }

  Future<void> deleteAyat(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lastReadData.removeAt(index);
    });
    await prefs.setString('lastReadAyats', json.encode(lastReadData));
  }

  Future<void> navigateToSurahList(Map<String, dynamic> data) async {
    final surahNumber = data['surahNumber'] ?? 1;
    final lastReadAyat = data['ayatNumber'] ?? 1;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahListScreen(
          surahId: surahNumber,
          lastReadAyat: lastReadAyat,
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
                      key: Key('${data['surahNumber']}_${data['ayatNumber']}'),
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