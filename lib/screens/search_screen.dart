import 'package:alquran_app/screens/surah_detail_screen.dart';
import 'package:alquran_app/screens/surah_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> allSurahData = [];
  List<Map<String, dynamic>> filteredSurahData = [];
  bool isLoading = true;
  String query = "";

  @override
  void initState() {
    super.initState();
    fetchAllSurahData();
  }

  Future<void> fetchAllSurahData() async {
    try {
      final response = await http.get(
        Uri.parse('https://quran-api.santrikoding.com/api/surah'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          allSurahData = List<Map<String, dynamic>>.from(data);
          filteredSurahData = allSurahData;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load surah list');
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      query = newQuery;
      filteredSurahData = allSurahData.where((surah) {
        final surahName = surah['nama_latin']?.toLowerCase() ?? '';
        final arabicName = surah['nama']?.toLowerCase() ?? '';
        final searchQuery = newQuery.toLowerCase();
        return surahName.contains(searchQuery) || arabicName.contains(searchQuery);
      }).toList();
    });
  }

  Future<void> navigateToSurahList(Map<String, dynamic> data) async {
    final surahNumber = data['nomor'] ?? 0; 
    final lastReadAyat = data['lastReadAyat'] ?? 0;
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
        title: Text('Pencarian Surah'),
        backgroundColor: Color(0xFFE6F1F3),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF819BA0)),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Cari surah berdasarkan nama',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF819BA0), width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(Icons.search, color: const Color.fromARGB(255, 44, 75, 101)),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredSurahData.length,
                    itemBuilder: (context, index) {
                      final surah = filteredSurahData[index];
                      final surahNumber = surah['nomor'] ?? 0;
                      final ayatCount = surah['jumlah_ayat'] ?? 0;
                      return ListTile(
                        title: Text(surah['nama_latin'] ?? 'Nama tidak tersedia'),
                        subtitle: Text(surah['nama'] ?? ''),
                        trailing: Text('Ayat: $ayatCount'),
                        onTap: () {
                          navigateToSurahList(surah);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
