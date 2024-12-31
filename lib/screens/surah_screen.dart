import 'package:alquran_app/screens/surah_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'surah_detail_screen.dart';

class SurahScreen extends StatefulWidget {
  @override
  _SurahScreenState createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  List<dynamic> surahList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSurahNames();
  }

  Future<void> fetchSurahNames() async {
    try {
      final response = await http.get(
        Uri.parse('https://quran-api.santrikoding.com/api/surah'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          surahList = data;
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load surah. Status code: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching surah: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Surah Al-Qur\'an'),
        backgroundColor: Color(0xFFE6F1F3),
      ),
      backgroundColor: Color(0xFFE6F1F3),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 129, 155, 160)),
            ))
          : surahList.isEmpty
              ? Center(child: Text('Tidak ada data surah'))
              : ListView.builder(
                  itemCount: surahList.length,
                  itemBuilder: (context, index) {
                    final surah = surahList[index];
                    return Card(
                      color: Colors.white,
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 1,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              surah['nama_latin'] ?? 'Tidak tersedia',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              surah['nama'] ?? '',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arti: ${surah['arti'] ?? 'Tidak tersedia'}',
                              style: GoogleFonts.lato(
                                  fontSize: 13,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w300),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${surah['jumlah_ayat']} Ayat',
                                  style: GoogleFonts.lato(
                                      fontSize: 13,
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  height: 16,
                                  width: 1,
                                  color: Colors.blueGrey,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  surah['tempat_turun'] ?? 'Tidak tersedia',
                                  style: GoogleFonts.lato(
                                      fontSize: 13,
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          final surahId = surah[
                              'nomor'];

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurahListScreen(
                                surahId: surahId, 
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
